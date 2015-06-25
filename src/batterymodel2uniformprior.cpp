#include <RcppEigen.h>
#include "batterymodel2uniformprior.h"
using namespace Rcpp;
using namespace std;


BatteryModel2UniformPrior::BatteryModel2UniformPrior() : BatteryModelUniformPrior(){
  this->dim_parameters = 7;
  R2min = 10;
  R2max = 100;
}

NumericVector BatteryModel2UniformPrior::logdprior(const NumericVector & parameters){
  NumericVector logdensityvalue(1);
  logdensityvalue(0) = 0.;
  double R2 = parameters(6);
  if (R2 < R2min || R2 > R2max){
    logdensityvalue(0) = log(0);
    return logdensityvalue;
  } else {
    return BatteryModelUniformPrior::logdprior(parameters);
  }
}

NumericVector BatteryModel2UniformPrior::rprior(){
  NumericVector draw = runif(dim_parameters);
  NumericVector otherparameters = BatteryModelUniformPrior::rprior();
  for (int i = 0; i < dim_parameters-1; i++){
    draw(i) = otherparameters(i);
  }
  draw(6) = R2min + (R2max - R2min) * draw(6);
  return draw;
}

void BatteryModel2UniformPrior::set_hyperparameters(const List & constants){
  BatteryModelUniformPrior::set_hyperparameters(constants);
  R2min = as<double>(constants["R2min"]);
  R2max = as<double>(constants["R2max"]);
}

//  expose BatteryModel2UniformPrior
RCPP_MODULE(batterymodel2uniformprior_module) {
  class_<BatteryModel2UniformPrior>( "BatteryModel2UniformPrior" )
  .constructor()
  .method ("rprior", &BatteryModel2UniformPrior::rprior)
  ;
}

