#include <RcppEigen.h>
#include "batterymodelnormalprior.h"
using namespace Rcpp;
using namespace std;


BatteryModelNormalPrior::BatteryModelNormalPrior(){
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
  sd_scale = 4.;
  mean_Rinf = (Rinfmax + Rinfmin) / 2;
  sd_Rinf = (Rinfmax - Rinfmin) / sd_scale;
  mean_C1 = (C1max + C1min) / 2;
  sd_C1 = (C1max - C1min) / sd_scale;
  mean_R1 = (R1max + R1min) / 2;
  sd_R1 = (R1max - R1min) / sd_scale;
  mean_alpha1 = (alpha1max + alpha1min) / 2;
  sd_alpha1 = (alpha1max - alpha1min) / sd_scale;
  mean_C2 = (C2max + C2min) / 2;
  sd_C2 = (C2max - C2min) / sd_scale;
  mean_alpha2 = (alpha2max + alpha2min) / 2;
  sd_alpha2 = (alpha2max - alpha2min) / sd_scale;
}

NumericVector BatteryModelNormalPrior::logdprior(const NumericVector & parameters){
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
  } else {
    logdensityvalue(0) =
      (-0.5/(sd_Rinf*sd_Rinf)) * pow(Rinf - mean_Rinf, 2) +
      (-0.5/(sd_C1*sd_C1)) * pow(C1 - mean_C1, 2) +
      (-0.5/(sd_R1*sd_R1)) * pow(R1 - mean_R1, 2) +
      (-0.5/(sd_alpha1*sd_alpha1)) * pow(alpha1 - mean_alpha1, 2) +
      (-0.5/(sd_C2*sd_C2)) * pow(C2 - mean_C2, 2) +
      (-0.5/(sd_alpha2*sd_alpha2)) * pow(alpha1 - mean_alpha2, 2);
  }
  return logdensityvalue;
}

NumericVector BatteryModelNormalPrior::rprior(){
  NumericVector draw(dim_parameters);
  std::fill(draw.begin(), draw.end(), -1.0);
  while (draw(0) < Rinfmin || draw(0) > Rinfmax){
    NumericVector Rinfvec = rnorm(1, mean_Rinf, sd_Rinf);
    draw(0) = Rinfvec(0);
  }
  while (draw(1) < C1min || draw(1) > C1max){
    NumericVector Cvec = rnorm(1, mean_C1, sd_C1);
    draw(1) = Cvec(0);
  }
  while (draw(2) < R1min || draw(2) > R1max){
    NumericVector Rvec = rnorm(1, mean_R1, sd_R1);
    draw(2) = Rvec(0);
  }
  while (draw(3) < alpha1min || draw(3) > alpha1max){
    NumericVector alpha_vec = rnorm(1, mean_alpha1, sd_alpha1);
    draw(3) = alpha_vec(0);
  }
  while (draw(4) < C2min || draw(4) > C2max){
    NumericVector Cvec = rnorm(1, mean_C2, sd_C2);
    draw(4) = Cvec(0);
  }
  while (draw(5) < alpha2min || draw(5) > alpha2max){
    NumericVector alpha_vec = rnorm(1, mean_alpha2, sd_alpha2);
    draw(5) = alpha_vec(0);
  }
  return draw;
}

void BatteryModelNormalPrior::set_hyperparameters(const List & constants){
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
  mean_Rinf = (Rinfmax + Rinfmin) / 2;
  sd_Rinf = (Rinfmax - Rinfmin) / sd_scale;
  mean_C1 = (C1max + C1min) / 2;
  sd_C1 = (C1max - C1min) / sd_scale;
  mean_R1 = (R1max + R1min) / 2;
  sd_R1 = (R1max - R1min) / sd_scale;
  mean_alpha1 = (alpha1max + alpha1min) / 2;
  sd_alpha1 = (alpha1max - alpha1min) / sd_scale;
  mean_C2 = (C2max + C2min) / 2;
  sd_C2 = (C2max - C2min) / sd_scale;
  mean_alpha2 = (alpha2max + alpha2min) / 2;
  sd_alpha2 = (alpha2max - alpha2min) / sd_scale;
}

//  expose BatteryModelNormalPrior
RCPP_MODULE(batterymodelnormalprior_module) {
  class_<BatteryModelNormalPrior>( "BatteryModelNormalPrior" )
  .constructor()
  .method ("rprior", &BatteryModelNormalPrior::rprior)
  ;
}

