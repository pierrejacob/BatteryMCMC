#ifndef _INCL_NORMPRIOR_
#define _INCL_NORMPRIOR_
#include <RcppEigen.h>
#include "prior.h"
using namespace Rcpp;

class BatteryModelNormalPrior : public Prior{
  public:
    BatteryModelNormalPrior();
  virtual NumericVector logdprior(const NumericVector & parameters);
  virtual NumericVector rprior();
  virtual void set_hyperparameters(const List & constants);
  //
  double Rinfmin, Rinfmax, R1min, R1max, C1min, C1max, C2min, C2max, alpha1min, alpha1max, alpha2min, alpha2max;
  double sd_scale;
  double mean_Rinf, sd_Rinf, mean_R1, sd_R1, mean_C1, sd_C1, mean_alpha1, sd_alpha1, mean_alpha2, sd_alpha2, mean_C2, sd_C2;
};

#endif

