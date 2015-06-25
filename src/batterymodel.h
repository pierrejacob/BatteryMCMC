#ifndef _INCL_FULLMODL_
#define _INCL_FULLMODL_
#include <RcppEigen.h>
#include "HMM.h"
using namespace Rcpp;

class BatteryModel : public HMM{
  public:
  BatteryModel();
  void set_input(const NumericMatrix & input);
  void set_parameters(const List & constants);
  NumericVector get_parameters();
  void precomputation();
  void update_parameters(const NumericVector & parameters);
  void rinit(NumericMatrix & xparticles);
  void rtransition(Tree* tree, NumericMatrix & xparticles, int step);
  void init_and_weight(NumericMatrix & xparticles, NumericVector & logweights);
  void transition_and_weight(Tree* tree, NumericMatrix & xparticles, NumericVector & logweights, int step);
  NumericMatrix robs(NumericMatrix & hstates);
  // model parameters
  double sigma_x, sigma_y;
  double cst_x, cst_y;
  double opt_prop_term1, opt_prop_term2;
  NumericMatrix opt_prop_var;
  Eigen::MatrixXd opt_prop_cholesky;
  double R1, Rinf;
  double alpha1, alpha2;
  double C1, C2;
  double Ts;
  // precomputed terms to speed up competition
  double term11,term12,term21,term22, A_0_1, A_0_2;
  NumericVector coeff1, coeff2, integers, sign, lgamma_integers_plus_two;
  NumericVector term21input, term22input, Rinfinput;
  double sum1,sum2;
  NumericVector xkp1;
};

#endif
