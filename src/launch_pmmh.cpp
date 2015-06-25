#include <RcppEigen.h>
#include <string>
#include "pmmh.h"
#include "batterymodel.h"
#include "batterymodel2.h"
#include "batterymodeluniformprior.h"
#include "batterymodel2uniformprior.h"
#include "batterymodelnormalprior.h"
#include "batterymodel2normalprior.h"
using namespace Rcpp;
using namespace std;

// [[Rcpp::export]]
List launch_pmmh_cpp(List inputs, List modellist,
                 List algoparameters){
  string strmodel = as<string>(modellist["model"]);
  string strprior = as<string>(modellist["prior"]);
  NumericMatrix current = inputs["current"];
  NumericMatrix observations = inputs["observations"];
  List theta = inputs["theta"];
  int nparticles = as<int>(algoparameters["nparticles"]);
  int niterations = as<int>(algoparameters["niterations"]);
  NumericMatrix cholesky_proposal = algoparameters["cholesky_proposal"];
  NumericVector initial_theta = algoparameters["initial_theta"];
  HMM* model;
  Prior* prior;
  if (strmodel.compare(string("model1")) == 0){
    model = new BatteryModel();
    if (strprior.compare(string("uniform")) == 0){
      prior = new BatteryModelUniformPrior();
    }
    if (strprior.compare(string("normal")) == 0){
      prior = new BatteryModelNormalPrior();
    }
  }
  if (strmodel.compare(string("model2")) == 0){
    model = new BatteryModel2();
    if (strprior.compare(string("uniform")) == 0){
      prior = new BatteryModel2UniformPrior();
    }
    if (strprior.compare(string("normal")) == 0){
      prior = new BatteryModel2NormalPrior();
    }
  }
  model->set_input(current);
  model->set_parameters(theta);
  model->set_observations(observations);
  PMMH pmmh(nparticles, niterations, model->dim_states);
  pmmh.set_prior(prior);
  pmmh.init(model, initial_theta);
  pmmh.set_proposal_cholesky(cholesky_proposal);
  pmmh.run();

  delete model;
  delete prior;
  return Rcpp::List::create(
                            Rcpp::Named("chain")= pmmh.chain_parameters,
                            Rcpp::Named("naccepts") = pmmh.naccepts,
                            Rcpp::Named("loglikelihood") = pmmh.loglikelihood,
                            Rcpp::Named("loglikelihood_proposal") = pmmh.loglikelihood_proposal,
                            Rcpp::Named("proposals") = pmmh.proposals,
                            Rcpp::Named("nparticles") = nparticles,
                            Rcpp::Named("niterations") = niterations,
                            Rcpp::Named("cholesky_proposal") = cholesky_proposal);
}
