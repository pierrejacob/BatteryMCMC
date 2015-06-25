#include <RcppEigen.h>
#include "lineargaussian.h"
#include "tree.h"
using namespace Rcpp;
using namespace std;

LinearGaussian::LinearGaussian()
  {
  this->dim_parameters = 3;
  this->dim_states = 1;
  this->dim_observation = 1;
}

void LinearGaussian::set_parameters(const List & constants){
  this->rho = as<double>(constants["rho"]);
  this->sigma = as<double>(constants["sigma"]);
  this->sigma2 = sigma*sigma;
  this->tau = as<double>(constants["tau"]);
  this->tau2 = tau*tau;
  this->Minus1Div2SdTransSquared  = -1.0 / (2*sigma2);
  this->Minus1Div2SdMeasurSquared = -1.0 / (2*tau2);
}

void LinearGaussian::update_parameters(const NumericVector & parameters){
  this->rho = parameters(0);
  this->sigma = parameters(1);
  this->sigma2 = sigma*sigma;
  this->tau = parameters(2);
  this->tau2 = tau*tau;
  this->Minus1Div2SdTransSquared  = -1.0 / (2*sigma2);
  this->Minus1Div2SdMeasurSquared = -1.0 / (2*tau2);
}


void LinearGaussian::rinit(NumericMatrix & xparticles){
  RNGScope scope;
  int nparticles = xparticles.nrow();
  std::fill(xparticles.begin(), xparticles.end(), 0);
  xparticles(_,0) = rnorm(nparticles, 0, sigma / sqrt(1 - rho*rho));
}

// prior proposal
void LinearGaussian::rtransition(Tree* tree, NumericMatrix & xparticles, int step){
  RNGScope scope;
  int nparticles = xparticles.nrow();
  NumericVector trans_noise = rnorm(nparticles, 0, sigma);
  for (int iparticle = 0; iparticle < nparticles; iparticle++){
    int j = tree->l_star(iparticle);
    xparticles(iparticle, 0) = rho * tree->x_star(j, 0) + trans_noise(iparticle);
  }
}

void LinearGaussian::init_and_weight(NumericMatrix & xparticles, NumericVector & logweights){
  RNGScope scope;
  int nparticles = xparticles.nrow();
  std::fill(xparticles.begin(), xparticles.end(), 0);
  xparticles(_,0) = rnorm(nparticles, 0, sigma / sqrt(1 - rho*rho));
  for (int iparticle = 0; iparticle < nparticles; iparticle++){
    logweights(iparticle) = Minus1Div2SdMeasurSquared * (xparticles(iparticle,0) - observations(0, 0)) *
      (xparticles(iparticle,0) - observations(0, 0));
  }
}

// optimal proposal
void LinearGaussian::transition_and_weight(Tree* tree, NumericMatrix & xparticles, NumericVector & logweights, int step){
  RNGScope scope;
  int nparticles = xparticles.nrow();
  NumericVector trans_noise = rnorm(nparticles, 0, 1);
  double var = sigma2*tau2 / (sigma2 + tau2);
  double sd = sqrt(var);
  double Minus1Div2Sd = -1.0 / (2*(sigma2 + tau2));
  for (int iparticle = 0; iparticle < nparticles; iparticle++){
    int j = tree->l_star(iparticle);
    xparticles(iparticle, 0) = var * ((rho * tree->x_star(j, 0)) / sigma2 + observations(step, 0) / tau2);
    xparticles(iparticle, 0) = xparticles(iparticle, 0) + sd *  trans_noise(iparticle);
    logweights(iparticle) = Minus1Div2Sd * (rho * tree->x_star(j, 0) - observations(step, 0)) *
      (rho * tree->x_star(j, 0) - observations(step, 0));
  }
}

NumericMatrix LinearGaussian::robs(NumericMatrix & hstates){
  RNGScope scope;
  NumericVector obs_noise = rnorm(hstates.nrow(), 0, 1);
  NumericMatrix observations(hstates.nrow(), 1);
  for (int time = 0; time < hstates.nrow(); time++){
    observations(time, 0) = hstates(time, 0) + tau * obs_noise(time);
  }
  return observations;
}

//
// double LinearGaussian::dtransition(NumericVector & last_xparticle, NumericVector & new_xparticle, int step){
//   return exp(Minus1Div2SdTransSquared * (new_xparticle(0) - rho * last_xparticle(0)) * (new_xparticle(0) - rho * last_xparticle(0)));
// }
//
// void LinearGaussian::transition(NumericMatrix & xparticles, int nparticles, int step){
//   NumericVector trans_noise = rnorm(nparticles, 0, sdtransition);
//   xparticles(_, 0) = rho * xparticles(_, 0) + trans_noise;
// }
//
// void LinearGaussian::weight(const NumericMatrix & xparticles, int nparticles, int step, NumericVector & logweights){
//   logweights = Minus1Div2SdMeasurSquared *
//     (xparticles(_, 0) - observations(step, 0)) * (xparticles(_, 0) - observations(step, 0));
// }

//void LinearGaussian::transition_and_weight(NumericMatrix & xparticles, int nparticles, int step,
                                       //                                     NumericVector & logweights){
  //  NumericVector trans_noise = rnorm(nparticles, 0, sdtransition);
  //  xparticles(_, 0) = rho * xparticles(_, 0) + trans_noise;
  //  logweights = Minus1Div2SdMeasurSquared *
    //            (xparticles(_, 0) - observations(step, 0)) * (xparticles(_, 0) - observations(step, 0));
  //}

//void LinearGaussian::transition_and_weight(NumericMatrix & xparticles, int nparticles, int step,
                                       //                                     NumericVector & logweights, NumericMatrix & transformed_thetas){
  //  NumericVector trans_noise = exp(transformed_thetas(_,1)) * rnorm(nparticles, 0, 1);
  //  xparticles(_, 0) = exp(transformed_thetas(_,0)) * xparticles(_, 0) + trans_noise;
  //  logweights = (-0.5/(exp(2 * transformed_thetas(_,2)))) *
    //            (xparticles(_, 0) - observations(step, 0)) * (xparticles(_, 0) - observations(step, 0));
  //}

// NumericVector get_observations(LinearGaussian* m) { return m->observations; }
// NumericMatrix get_hidden_states(LinearGaussian* m) { return m->hidden_states; }
RCPP_EXPOSED_CLASS(HMM)

// expose LinearGaussian
RCPP_MODULE(LinearGaussian_module) {
  class_<LinearGaussian>( "LinearGaussian" )
  .constructor()
  .field( "rho", &LinearGaussian::rho)
  // .method( "set_observations", &LinearGaussian::set_observations)
  // .method( "set_parameters", &LinearGaussian::set_parameters)
// //   .method( "generate_observations", &generate_observations)
//   // .method( "get_hidden_states", &get_hidden_states)
//   // .method( "get_observations", &get_observations)
  ;
}
