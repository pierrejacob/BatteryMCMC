#include <RcppEigen.h>
#include "batterymodeluniformprior.h"
using namespace Rcpp;
using namespace std;


BatteryModelUniformPrior::BatteryModelUniformPrior(){
  this->dim_parameters = 6;
  Rinfmin = 0.005;
  Rinfmax = 0.10;
  R1min = 0.05;
  R1max = 0.50;
  C1min = 1;
  C1max = 5;
  C2min = 300;
  C2max = 500;
  alpha1min = 0.4;
  alpha1max = 1.0;
  alpha2min = 0.4;
  alpha2max = 1.0;
}

NumericVector BatteryModelUniformPrior::logdprior(const NumericVector & parameters){
  double Rinf = parameters(0);
  double C1 = parameters(1);
  double R1 = parameters(2);
  double alpha1 = parameters(3);
  double C2 = parameters(4);
  double alpha2 = parameters(5);

  NumericVector logdensityvalue(1);
  logdensityvalue(0) = 0.;
  if (Rinf < Rinfmin || Rinf > Rinfmax ||
      C1 < C1min || C1 > C1max ||
      R1 < R1min || R1 > R1max ||
      alpha1 < alpha1min || alpha1 > alpha1max ||
      C2 < C2min || C2 > C2max ||
      alpha2 < alpha2min || alpha2 > alpha2max){
    logdensityvalue(0) = log(0.);
  }
  return logdensityvalue;
}

NumericVector BatteryModelUniformPrior::rprior(){
  NumericVector draw = runif(dim_parameters);
  draw(0) = Rinfmin + (Rinfmax - Rinfmin) * draw(0);
  draw(1) = C1min + (C1max - C1min) * draw(1);
  draw(2) = R1min + (R1max - R1min) * draw(2);
  draw(3) = alpha1min + (alpha1max - alpha1min) * draw(3);
  draw(4) = C2min + (C2max - C2min) * draw(4);
  draw(5) = alpha2min + (alpha2max - alpha2min) * draw(5);
  return draw;
}

void BatteryModelUniformPrior::set_hyperparameters(const List & constants){
  Rinfmin =  as<double>(constants["Rinfmin"]);
  Rinfmax = as<double>(constants["Rinfmax"]);
  R1min = as<double>(constants["R1min"]);
  R1max = as<double>(constants["R1max"]);
  C1min = as<double>(constants["C1min"]);
  C1max = as<double>(constants["C1max"]);
  C2min = as<double>(constants["C2min"]);
  C2max = as<double>(constants["C2max"]);
  alpha1min = as<double>(constants["alpha1min"]);
  alpha1max = as<double>(constants["alpha1max"]);
  alpha2min = as<double>(constants["alpha2min"]);
  alpha2max = as<double>(constants["alpha2max"]);
}

//  expose BatteryModelUniformPrior
RCPP_MODULE(batterymodeluniformprior_module) {
  class_<BatteryModelUniformPrior>( "BatteryModelUniformPrior" )
  .constructor()
  .method ("rprior", &BatteryModelUniformPrior::rprior)
  ;
}

