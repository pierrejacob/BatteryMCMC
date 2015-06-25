#ifndef _INCL_UNIFPRIOR2_
#define _INCL_UNIFPRIOR2_
#include <RcppEigen.h>
#include "batterymodeluniformprior.h"
using namespace Rcpp;

class BatteryModel2UniformPrior : public BatteryModelUniformPrior {
  public:
    BatteryModel2UniformPrior();
  NumericVector logdprior(const NumericVector & parameters);
  NumericVector rprior();
  void set_hyperparameters(const List & constants);
  //
  double R2min, R2max;
};

#endif

