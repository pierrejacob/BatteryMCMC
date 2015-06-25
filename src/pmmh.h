#ifndef _INCL_PMMH_
#define _INCL_PMMH_
#include <RcppEigen.h>

using namespace Rcpp;

class HMM;
class ParticleFilter;
class Prior;

class PMMH
{
  public:
  PMMH(int nparticles, int niterations, int dim_states);
  ~PMMH();
  void init(HMM* model, NumericVector initial_parameters);
  void run();
  void set_prior(Prior * prior);
  // void set_prior(Prior & prior);
  void set_proposal_cholesky(const NumericMatrix & cholesky_proposal);
  // attributes
  NumericVector input;
  NumericVector observations;
  HMM* model;
  Prior* prior;
  ParticleFilter* pf;
  int nparticles;
  int niterations;
  int dim_parameters;
  int dim_states;
  NumericMatrix chain_parameters;
  NumericMatrix proposals;
  NumericVector loglikelihood_proposal;
  NumericVector logdposterior_proposal;
  Eigen::MatrixXd cholesky_proposal;
  NumericVector logdposterior;
  NumericVector loglikelihood;
  NumericVector log_uniforms_for_mcmc;
  int naccepts;
};
#endif
