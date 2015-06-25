#ifndef _INCL_MODL_
#define _INCL_MODL_
#include <RcppEigen.h>
#include "HMM.h"
using namespace Rcpp;

// hidden autoregressive model
// X_0 ~ Normal(0, 1)
// X_t = rho X_t-1 + sigma * Normal(0,1)
// Y_t = X_t + tau * Normal(0,1)
// parameters = (rho, sigma, tau) = (theta_0, theta_1, theta_2)

class LinearGaussian : public HMM{
public:
  LinearGaussian();
  void set_parameters(const List & constants);
  void update_parameters(const NumericVector & parameters);
    // model equations
  void rinit(NumericMatrix & xparticles);
  void rtransition(Tree* tree, NumericMatrix & xparticles, int step);
  void init_and_weight(NumericMatrix & xparticles, NumericVector & logweights);
  void transition_and_weight(Tree* tree, NumericMatrix & xparticles, NumericVector & logweights, int step);
  NumericMatrix robs(NumericMatrix & hstates);
  double rho;
  double sigma;
  double sigma2;
  double tau;
  double tau2;
  double Minus1Div2SdMeasurSquared;
  double Minus1Div2SdTransSquared;
};

#endif
