#ifndef _INCL_UNIFPRIOR_
#define _INCL_UNIFPRIOR_
#include <RcppEigen.h>
#include "prior.h"
using namespace Rcpp;

class BatteryModelUniformPrior : public Prior{
public:
  BatteryModelUniformPrior();
  virtual NumericVector logdprior(const NumericVector & parameters);
  virtual NumericVector rprior();
  virtual void set_hyperparameters(const List & constants);
  //
  double Rinfmin, Rinfmax, R1min, R1max, C1min, C1max, C2min, C2max, alpha1min, alpha1max, alpha2min, alpha2max;
};

#endif

