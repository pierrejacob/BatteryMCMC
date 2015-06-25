#ifndef _INCL_NORMPRIOR2_
#define _INCL_NORMPRIOR2_
#include <RcppEigen.h>
#include "batterymodelnormalprior.h"
using namespace Rcpp;

class BatteryModel2NormalPrior : public BatteryModelNormalPrior{
  public:
    BatteryModel2NormalPrior();
  NumericVector logdprior(const NumericVector & parameters);
  NumericVector rprior();
  void set_hyperparameters(const List & constants);
  //
  double R2min, R2max;
  double mean_R2, sd_R2;
};

#endif

