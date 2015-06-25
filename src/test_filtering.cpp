#include <RcppEigen.h>
#include "pf.h"
#include "lineargaussian.h"
#include "batterymodel.h"
using namespace Rcpp;
using namespace std;

List particle_filtering_LG(List theta, NumericMatrix observations, int nparticles){
  LinearGaussian model;
  model.set_observations(observations);
  model.set_parameters(theta);
  ParticleFilter pf(nparticles, model.dim_states);
  pf.init(&model);
  pf.reset();
  pf.filtering();
  NumericVector csts(observations.rows());
  double tau = as<double>(theta["tau"]);
  double c = -0.5 * log(2 * 3.141593 * (tau*tau));
  for (int i = 0; i < observations.rows(); i++){
    csts(i) = (i+1) * c;
  }
  return Rcpp::List::create(Rcpp::Named("loglikelihood")= csts + pf.get_loglikelihood(),
                            Rcpp::Named("filtering_means") = pf.filtering_means);
}

List particle_filtering_battery(List theta, NumericMatrix input, NumericMatrix observations, int nparticles){
  BatteryModel model;
  model.set_input(input);
  model.set_parameters(theta);
  model.set_observations(observations);
  ParticleFilter pf(nparticles, model.dim_states);
  pf.init(&model);
  pf.reset();
  pf.filtering();
  return Rcpp::List::create(Rcpp::Named("loglikelihood")= pf.get_loglikelihood(),
                            Rcpp::Named("filtering_means") = pf.filtering_means);
}

NumericVector particle_filtering_battery_ntimes(List theta, NumericMatrix input, NumericMatrix observations, int nparticles, int ntimes){
  BatteryModel model;
  model.set_input(input);
  model.set_parameters(theta);
  model.set_observations(observations);
  ParticleFilter pf(nparticles, model.dim_states);
  pf.init(&model);
  NumericVector ll(ntimes);
  for (int itime = 0; itime < ntimes; itime ++){
    // cerr << "reset" << endl;
    pf.reset();
    // cerr << "filtering" << endl;
    pf.filtering();
    // cerr << "saving" << endl;
    NumericVector l = pf.get_loglikelihood();
    ll(itime) = l[observations.nrow()-1];
    // return pf.get_loglikelihood();
  }
  return ll;
}


RCPP_MODULE(filtering_module) {
  function("particle_filtering_LG" , &particle_filtering_LG);
  function("particle_filtering_battery" , &particle_filtering_battery);
  function("particle_filtering_battery_ntimes", &particle_filtering_battery_ntimes);
}
