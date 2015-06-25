#ifndef _INCL_PF_
#define _INCL_PF_
#include <RcppEigen.h>
using namespace Rcpp;

class HMM;
class Tree;


class ParticleFilter
{
  public:
  ParticleFilter(int nparticles, int dim_states);
  virtual ~ParticleFilter();
  // initialise the particle filter (which is not the first step of the particle filter)
  virtual void init(HMM* hmm);
  // reset all the objects, as if init was just called
  virtual void reset();
  // first step of the particle filter
  virtual void first_step();
  // one step of the particle filter
  virtual void step(int step);
  // normalize weights
  virtual void compute_weights(int step);
  // all steps of the particle filter
  virtual void filtering();
  // set the Effective Sample Size threshold for adaptive resampling
  void set_ess_threshold(double ess);
  // return incremental loglikelihoods
  NumericVector get_incremental_ll();
  // return (cumulative) loglikelihoods
  NumericVector get_loglikelihood();
  // return last cumulative loglikelihood
  double loglikelihood_estimate();
  // number of particles
  int nparticles;
  //
  int dim_states;
  // pointer to the hidden markov model
  HMM* hmm;
  // pointer to the particle tree
  Tree* tree;
  // number of observations
  int datalength;
  // ESS threshold between 0 and 1 for adaptive resampling
  double ess_threshold;
  double maxlogweights;
  // xparticles
  NumericMatrix xparticles;
  // incremental log weights
  NumericVector logweights;
  // weights
  NumericVector weights;
  // total weights (i.e. since last resampling)
  NumericVector totalweights;
  // total log weights (i.e. since last resampling)
  NumericVector totallogweights;
  // total normalized weights (i.e. since last resampling)
  NumericVector normalized_weights;
  // sum of logweights at each step
  NumericVector sum_weights;

  // vector of Effective Sample Sizes
  NumericVector ess;
  // incremental loglikelihood
  NumericVector incremental_ll;
  // ancestors of current generation
  IntegerVector ancestors;
  // filtering mean computed forward
  NumericMatrix filtering_means;
};
#endif


