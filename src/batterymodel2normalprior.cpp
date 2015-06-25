#include <RcppEigen.h>
#include "batterymodel2normalprior.h"
using namespace Rcpp;
using namespace std;


BatteryModel2NormalPrior::BatteryModel2NormalPrior(): BatteryModelNormalPrior() {
  this->dim_parameters = 7;
  R2min = 10;
  R2max = 100;
  mean_R2 = (R2max + R2min) / 2;
  sd_R2 = (R2max - R2min) / sd_scale;
}

NumericVector BatteryModel2NormalPrior::logdprior(const NumericVector & parameters){
  NumericVector logdensityvalue(1);
  logdensityvalue(0) = 0.;
  double R2 = parameters(6);
  if (R2 < R2min || R2 > R2max){
    logdensityvalue(0) = log(0);
    return logdensityvalue;
  } else {
    logdensityvalue(0) = (-0.5/(sd_R2*sd_R2)) * pow(R2 - mean_R2, 2);
    NumericVector v = BatteryModelNormalPrior::logdprior(parameters);
    return v + logdensityvalue;
  }
}

NumericVector BatteryModel2NormalPrior::rprior(){
  NumericVector draw(dim_parameters);
  std::fill(draw.begin(), draw.end(), -1.0);
  while (draw(6) < R2min || draw(6) > R2max){
    NumericVector R2vec = rnorm(1, mean_R2, sd_R2);
    draw(6) = R2vec(0);
  }
  NumericVector otherparameters = BatteryModelNormalPrior::rprior();
  for (int i = 0; i < dim_parameters-1; i++){
    draw(i) = otherparameters(i);
  }
  return draw;
}

void BatteryModel2NormalPrior::set_hyperparameters(const List & constants){
  BatteryModelNormalPrior::set_hyperparameters(constants);
  R2min = as<double>(constants["R2min"]);
  R2max = as<double>(constants["R2max"]);
  mean_R2 = (R2max + R2min) / 2;
  sd_R2 = (R2max - R2min) / sd_scale;
}

//  expose BatteryModel2NormalPrior
RCPP_MODULE(batterymodel2normalprior_module) {
  class_<BatteryModel2NormalPrior>( "BatteryModel2NormalPrior" )
  .constructor()
  .method ("rprior", &BatteryModel2NormalPrior::rprior)
  ;
}

