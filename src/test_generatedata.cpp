#include <RcppEigen.h>
#include "lineargaussian.h"
#include "batterymodel.h"
using namespace Rcpp;
using namespace std;

List generate_data_LG(List theta, int datalength){
  LinearGaussian model;
  model.set_parameters(theta);
  model.generate_observations(datalength);
  return Rcpp::List::create(Rcpp::Named("observations")= model.observations,
                            Rcpp::Named("states")= model.states);
}

List generate_data_battery(List theta, NumericMatrix input, int datalength){
  BatteryModel model;
  model.set_input(input);
  model.set_parameters(theta);
  model.generate_observations(datalength);
  return Rcpp::List::create(Rcpp::Named("observations")= model.observations,
                            Rcpp::Named("states")= model.states);
}


RCPP_MODULE(generate_data_module) {
  function("generate_data_LG" , &generate_data_LG);
  function("generate_data_battery" , &generate_data_battery);
}
