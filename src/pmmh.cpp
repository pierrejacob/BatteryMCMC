#include <RcppEigen.h>
#include "pmmh.h"
#include "HMM.h"
#include "resampling.h"
#include "pf.h"
#include "mvnorm.h"
#include "prior.h"
using namespace Rcpp;
using namespace std;

PMMH::PMMH(int nparticles, int niterations, int dim_states)
: nparticles(nparticles), niterations(niterations), dim_states(dim_states)
{
  pf = new ParticleFilter(nparticles, dim_states);
}

PMMH::~PMMH(){
  delete pf;
}

void PMMH::init(HMM * model, NumericVector initial_parameters){
  this->model = model;
  this->model->update_parameters(initial_parameters);
  this->dim_parameters = this->model->dim_parameters;
  this->cholesky_proposal = Eigen::MatrixXd::Identity(dim_parameters, dim_parameters);
  this->pf->init(model);
  this->chain_parameters = NumericMatrix(niterations, dim_parameters);
  this->proposals = NumericMatrix(niterations, dim_parameters);
  this->loglikelihood = NumericVector(niterations);
  this->logdposterior = NumericVector(niterations);
  this->loglikelihood_proposal = NumericVector(niterations);
  this->logdposterior_proposal = NumericVector(niterations);
  this->log_uniforms_for_mcmc = log(runif(niterations));
  this->chain_parameters.row(0) = initial_parameters;
  this->proposals.row(0) = initial_parameters;
  this->pf->filtering();
  this->loglikelihood(0) = this->pf->loglikelihood_estimate();
  this->loglikelihood_proposal(0) = this->loglikelihood(0);
  NumericVector prior_value = this->prior->logdprior(initial_parameters);
  this->logdposterior(0) = this->loglikelihood(0) + prior_value(0);
  this->logdposterior_proposal(0) = this->logdposterior(0);
}

void PMMH::run(){
  naccepts = 0;
  NumericVector proposal(dim_parameters);
  NumericMatrix proposal_noise = centered_rmvnorm(niterations, cholesky_proposal);
  for (int iteration = 1; iteration < niterations; iteration ++){
    // if (iteration % 100 == 0){
      // cout << "iteration " << iteration << " / " << niterations << endl;
      // cout << "acceptance rate so far " << 100 * naccepts / iteration << "% " <<  endl;
    // }
    proposal = clone<NumericVector>(chain_parameters.row(iteration - 1));
    for (int idim = 0; idim < dim_parameters; idim ++){
      proposal(idim) = proposal(idim) + proposal_noise(iteration, idim);
    }
    bool accept = false;
    NumericVector prior_proposal = this->prior->logdprior(proposal);
    proposals.row(iteration) = clone<NumericVector>(proposal);
    LogicalVector is_finite_prior = is_finite(prior_proposal);
    if (is_finite_prior(0)){
      model->update_parameters(proposal);
      pf->filtering();
      loglikelihood_proposal(iteration) = pf->loglikelihood_estimate();
      logdposterior_proposal(iteration) = loglikelihood_proposal(iteration) + prior_proposal(0);
      if (log_uniforms_for_mcmc(iteration) < (logdposterior_proposal(iteration) - logdposterior(iteration - 1))){
        accept = true;
      }
    } else { // prior = -Inf, no need to compute the likelihood
      loglikelihood_proposal(iteration) = prior_proposal(0);
      logdposterior_proposal(iteration) = prior_proposal(0);
    }

    if (accept){
      logdposterior(iteration) = logdposterior_proposal(iteration);
      loglikelihood(iteration) = loglikelihood_proposal(iteration);
      chain_parameters.row(iteration) = clone<NumericVector>(proposal);
      naccepts ++;
    } else {
      logdposterior(iteration) = logdposterior(iteration - 1);
      loglikelihood(iteration) = loglikelihood(iteration - 1);
      chain_parameters.row(iteration) = clone<NumericVector>(chain_parameters.row(iteration - 1));
    }
  }
}

void PMMH::set_prior(Prior * prior){
  this->prior = prior;
}

void PMMH::set_proposal_cholesky(const NumericMatrix & cholesky_proposal_){
  cholesky_proposal = as<Eigen::MatrixXd>(cholesky_proposal_);
}


RCPP_EXPOSED_CLASS(HMM)
RCPP_EXPOSED_CLASS(Prior)

RCPP_MODULE(PMMH_module) {
  class_<PMMH>("PMMH")
  .constructor<int,int,int>()
  .method( "set_prior", &PMMH::set_prior)
  .method( "init", &PMMH::init)
  .method( "run", &PMMH::run)
  .method( "set_proposal_cholesky", &PMMH::set_proposal_cholesky)

  .field( "niterations", &PMMH::niterations)
  .field( "nparticles", &PMMH::nparticles)
  .field( "chain_parameters", &PMMH::chain_parameters)
  .field( "proposals", &PMMH::proposals)
  .field( "naccepts", &PMMH::naccepts)
  .field( "loglikelihood", &PMMH::loglikelihood)
  .field( "loglikelihood_proposal", &PMMH::loglikelihood_proposal)
  .field( "cholesky_proposal", &PMMH::cholesky_proposal)
  ;
}
