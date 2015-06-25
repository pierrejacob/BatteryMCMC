#include <RcppEigen.h>
#include "pf.h"
#include "HMM.h"
#include "resampling.h"
#include "weighted_averages.h"
#include "tree.h"
using namespace Rcpp;
using namespace std;


ParticleFilter::ParticleFilter(int nparticles, int dim_states)
: nparticles(nparticles), dim_states(dim_states)
{
  ess_threshold = 1.0;
  tree = new Tree(nparticles, 20*nparticles, dim_states);
}

ParticleFilter::~ParticleFilter()
{
  delete tree;
}

void ParticleFilter::set_ess_threshold(double ess){
  this->ess_threshold = ess;
}

void ParticleFilter::init(HMM* hmm){
  this->hmm = hmm;
  this->datalength = hmm->datalength;
  this->xparticles = NumericMatrix(nparticles, hmm->dim_states);
  this->logweights = NumericVector(nparticles);
  this->weights = NumericVector(nparticles);
  this->totallogweights = NumericVector(nparticles);
  this->totalweights = NumericVector(nparticles);
  this->normalized_weights = NumericVector(nparticles);
  this->sum_weights = NumericVector(this->datalength);
  this->ancestors = IntegerVector(nparticles);
  this->filtering_means = NumericMatrix(this->datalength, hmm->dim_states);
  this->incremental_ll = NumericVector(this->datalength);
  this->reset();
}

void ParticleFilter::reset(){
  this->tree->reset();
  std::fill(this->xparticles.begin(), this->xparticles.end(), 0);
  std::fill(this->logweights.begin(), this->logweights.end(), 0);
  std::fill(this->weights.begin(), this->weights.begin(), 1);
  std::fill(this->totalweights.begin(), this->totalweights.begin(), 1);
  std::fill(this->totallogweights.begin(), this->totallogweights.end(), 0);
  std::fill(this->normalized_weights.begin(), this->normalized_weights.end(), 1./nparticles);
  std::fill(this->incremental_ll.begin(), this->incremental_ll.end(), 0);
}

void ParticleFilter::compute_weights(int step){
  maxlogweights = max(logweights);
  this->sum_weights(step) = sum(exp(logweights));
  for (int i_particle = 0; i_particle < nparticles; i_particle ++){
    weights(i_particle) = exp(logweights(i_particle) - maxlogweights);
  }
  incremental_ll(step) = maxlogweights + log(wmean_vector(weights, normalized_weights));
  totallogweights = totallogweights + logweights;
  totalweights = exp(totallogweights - max(totallogweights));
  normalized_weights =  totalweights / sum(totalweights);
}

void ParticleFilter::first_step(){
  hmm->init_and_weight(xparticles, logweights);
  this->compute_weights(0);
}

void ParticleFilter::step(int step){
  hmm->transition_and_weight(tree, xparticles, logweights, step);
  this->compute_weights(step);
  systematic(ancestors, normalized_weights, nparticles);
  permute(ancestors, nparticles);
  for (int iparticle = 0; iparticle < nparticles; iparticle ++){
    if (iparticle != ancestors(iparticle)){
      xparticles(iparticle,_) = xparticles(ancestors(iparticle),_);
    }
  }
  std::fill(totallogweights.begin(), totallogweights.end(), 0);
  std::fill(normalized_weights.begin(), normalized_weights.end(), 1./nparticles);
}

void ParticleFilter::filtering(){
  this->reset();
  this->first_step();
  tree->init(xparticles);
  for (int k = 1; k < datalength; k++){
    this->step(k);
    tree->update(xparticles, ancestors);
  }
}

NumericVector ParticleFilter::get_loglikelihood(){
  return cumsum(incremental_ll);
}

double ParticleFilter::loglikelihood_estimate(){
  return sum(incremental_ll);
}

//
// RCPP_EXPOSED_CLASS(HMM)
// RCPP_MODULE(particle_filter) {
//   class_<ParticleFilter>( "ParticleFilter" )
//   .constructor<int>()
//   .method( "init", &ParticleFilter::init)
//   .field( "datalength", &ParticleFilter::datalength)
//   .method( "filtering", &ParticleFilter::filtering)
//   .field( "filtering_means", &ParticleFilter::filtering_means)
//   .field( "incremental_ll", &ParticleFilter::incremental_ll)
//   .field( "sum_weights", &ParticleFilter::sum_weights)
//   .field( "ess", &ParticleFilter::ess)
//   .method( "get_loglikelihood", &ParticleFilter::get_loglikelihood)
//   .method( "set_ess_threshold", &ParticleFilter::set_ess_threshold)
//   ;
// }
