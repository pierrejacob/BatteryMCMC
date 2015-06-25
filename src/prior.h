#ifndef PRIOR_H_
#define PRIOR_H_
#include <RcppEigen.h>

using namespace Rcpp;

class Prior {
public:
  Prior();
  virtual ~Prior();
  // evaluate log density of prior of the parameters
  // return a NumericVector of size 1, so that the value can be Inf or NAN
  virtual NumericVector logdprior(const NumericVector & parameters) {return NumericVector::create(0.);}
  // generate one parameter realisation from the prior distribution
  virtual NumericVector rprior() {return NumericVector::create(0.);}
  // set prior hyper parameters
  virtual void set_hyperparameters(const List & constants) {};
  // dimension of the parameter vector
  int dim_parameters;

};

#endif
