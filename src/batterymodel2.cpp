#include <RcppEigen.h>
#include "batterymodel2.h"
#include "tree.h"
#include "mvnorm.h"
using namespace Rcpp;
using namespace std;


BatteryModel2::BatteryModel2(){
  this->dim_parameters = 7;
  this->dim_states = 2;
  this->dim_observation = 1;
  this->xkp1 = NumericVector(this->dim_states);
  this->opt_prop_var = NumericMatrix(this->dim_states, this->dim_states);
  this->opt_prop_cholesky = Eigen::MatrixXd(this->dim_states, this->dim_states);
}

void BatteryModel2::set_input(const NumericMatrix & input){
  this->input = clone<NumericMatrix>(input);
  datalength = this->input.nrow();
  // create vector with 1, 2, ... datalength
  integers = wrap(seq_len(datalength));
  // lgamma(3), lgamma(4), ... lgamma(datalength + 2)
  lgamma_integers_plus_two = lgamma(2 + integers);
  // sign = -1, 1, -1, 1, ....
  sign = NumericVector(datalength);
  sign(0) = -1;
  for (int i = 1; i < datalength; i++){
    sign(i) = -1 * sign(i-1);
  }
  coeff1 = NumericVector(datalength);
  coeff2 = NumericVector(datalength);
  term21input = NumericVector(datalength);
  term22input = NumericVector(datalength);
  Rinfinput = NumericVector(datalength);
}


void BatteryModel2::set_parameters(const List & constants){
  this->Rinf = as<double>(constants["Rinf"]);
  this->C1 = as<double>(constants["C1"]);
  this->R1 = as<double>(constants["R1"]);
  this->R2 = as<double>(constants["R2"]);
  this->alpha1 = as<double>(constants["alpha1"]);
  this->C2 = as<double>(constants["C2"]);
  this->alpha2 = as<double>(constants["alpha2"]);
  this->sigma_x = as<double>(constants["sigma_x"]);
  this->sigma_y = as<double>(constants["sigma_y"]);
  this->Ts = as<double>(constants["Ts"]);
  this->precomputation();
}

NumericVector BatteryModel2::get_parameters(){
  NumericVector theta(dim_parameters);
  theta(0) = this->Rinf;
  theta(1) = this->C1;
  theta(2) = this->R1;
  theta(3) = this->alpha1;
  theta(4) = this->C2;
  theta(5) = this->alpha2;
  theta(6) = this->R2;
  return theta;
}

void BatteryModel2::update_parameters(const NumericVector & parameters){
  // parameters = (Rinf, C1, R1, alpha1, C2, alpha2)
  this->Rinf = parameters(0);
  this->C1 = parameters(1);
  this->R1 = parameters(2);
  this->alpha1 = parameters(3);
  this->C2 = parameters(4);
  this->alpha2 = parameters(5);
  this->R2 = parameters(6);
  this->precomputation();
}

void BatteryModel2::precomputation(){
  // cst_x = -1.0 / (2*pow(sigma_x, 2)); // ?
  cst_y  = -1.0 / (2*pow(sigma_y, 2));
  A_0_1 = alpha1 - pow(Ts, alpha1) / (R1 * C1);
  A_0_2 = alpha2 - pow(Ts, alpha2) / (R2 * C2);
  // coeff = A_1, A_2, A_3, ...
  coeff1 = sign * exp(lgamma(alpha1 + 1.) - lgamma_integers_plus_two - lgamma(alpha1 - integers));
  coeff2 = sign * exp(lgamma(alpha2 + 1.) - lgamma_integers_plus_two - lgamma(alpha2 - integers));
  term21input = (pow(Ts, alpha1) / C1) * input(_, 0);
  term22input = (pow(Ts, alpha2) / C2) * input(_, 0);
  Rinfinput = Rinf * input(_,0);
  opt_prop_var(0,0) = pow(sigma_x,2) - pow(sigma_x, 4) / (2*pow(sigma_x,2) + pow(sigma_y,2));
  opt_prop_var(1,0) = - pow(sigma_x, 4) / (2*pow(sigma_x,2) + pow(sigma_y,2));
  opt_prop_var(0,1) = opt_prop_var(1,0);
  opt_prop_var(1,1) = opt_prop_var(0,0);
  const Eigen::Map<Eigen::MatrixXd> opt_prop_var_(as<Eigen::Map<Eigen::MatrixXd> >(opt_prop_var));
  opt_prop_cholesky = opt_prop_var_.llt().matrixU();
  opt_prop_term1 = pow(sigma_x,2) / (2*pow(sigma_x,2) + pow(sigma_y,2));
  opt_prop_term2 = -1.0 / (4*pow(sigma_x,2) + 2*pow(sigma_y, 2));
}


void BatteryModel2::rinit(NumericMatrix & xparticles){
  RNGScope scope;
  // generates x_0
  std::fill(xparticles.begin(), xparticles.end(), 0);
}

NumericMatrix BatteryModel2::robs(NumericMatrix & hstates){
  RNGScope scope;
  NumericMatrix observations(hstates.nrow(), dim_observation);
  NumericVector obs_noise = rnorm(hstates.nrow(), 0, 1);
  for (int time = 0; time < hstates.nrow(); time++){
    double mean_y = hstates(time, 0) + hstates(time, 1) + Rinfinput(time);
    observations(time, 0) = mean_y + sigma_y * obs_noise(time);
  }
  return observations;
}

void BatteryModel2::rtransition(Tree* tree, NumericMatrix & xparticles, int step){
  // generates x_step given past, so step has to be > 0
  RNGScope scope;
  int nparticles = xparticles.nrow();
  NumericVector trans_noise1 = rnorm(nparticles, 0, 1);
  NumericVector trans_noise2 = rnorm(nparticles, 0, 1);
  NumericMatrix coefficients(step, dim_states); // store A_0, ..., A_k-1
  coefficients(step-1, 0) = A_0_1; // A_0 in the last row
  coefficients(step-1, 1) = A_0_2;
  for (int i = 0; i < step - 2; i++){
    coefficients(step - 2 - i, 0) = coeff1(i);
    coefficients(step - 2 - i, 1) = coeff2(i);
  }
  NumericMatrix meanxk = tree->weighted_sums(coefficients);
  for (int iparticle = 0; iparticle < nparticles; iparticle++){
    xkp1(0) = meanxk(iparticle, 0) + term21input(step - 1);
    xkp1(1) = meanxk(iparticle, 1) + term22input(step - 1);
    xparticles(iparticle, 0) = xkp1(0) + sigma_x * trans_noise1(iparticle);
    xparticles(iparticle, 1) = xkp1(1) + sigma_x * trans_noise2(iparticle);
  }
}

void BatteryModel2::init_and_weight(NumericMatrix & xparticles, NumericVector & logweights){
  RNGScope scope;
  std::fill(xparticles.begin(), xparticles.end(), 0);
  int nparticles = xparticles.nrow();
  for (int iparticle = 0; iparticle < nparticles; iparticle++){
    logweights(iparticle) = (xparticles(iparticle, 0) + xparticles(iparticle, 1) + Rinfinput(0) - observations(0, 0));
    logweights(iparticle) = logweights(iparticle) * logweights(iparticle) * cst_y;
  }
}

void BatteryModel2::transition_and_weight(Tree* tree, NumericMatrix & xparticles, NumericVector & logweights, int step){
  RNGScope scope;
  int nparticles = xparticles.nrow();
  // std::fill(xkp1.begin(), xkp1.end(), 0);
  NumericMatrix trans_noise = centered_rmvnorm(nparticles, opt_prop_cholesky);
  int index_coefficient;
  int index_past_step;
  NumericMatrix coefficients(step, dim_states); // store A_0, ..., A_k-1
  coefficients(step-1, 0) = A_0_1; // A_0 in the last row
  coefficients(step-1, 1) = A_0_2;
  for (int i = 0; i < step - 2; i++){
    coefficients(step - 2 - i, 0) = coeff1(i);
    coefficients(step - 2 - i, 1) = coeff2(i);
  }
  NumericMatrix meanxk = tree->weighted_sums(coefficients);
  for (int iparticle = 0; iparticle < nparticles; iparticle++){
    // need to check the maths on this at some point
    xkp1(0) = meanxk(iparticle, 0) + term21input(step - 1);
    xkp1(1) = meanxk(iparticle, 1) + term22input(step - 1);
    xparticles(iparticle, 0) = xkp1(0) + opt_prop_term1 * (observations(step, 0) - (xkp1(0) + xkp1(1) + Rinfinput(step))) + trans_noise(iparticle, 0);
    xparticles(iparticle, 1) = xkp1(1) + opt_prop_term1 * (observations(step, 0) - (xkp1(0) + xkp1(1) + Rinfinput(step))) + trans_noise(iparticle, 1);
    logweights(iparticle) = opt_prop_term2 * (xkp1(0) + xkp1(1) + Rinfinput(step) - observations(step, 0)) * (xkp1(0) + xkp1(1) + Rinfinput(step) - observations(step, 0));
  }
}

NumericVector get_observations(BatteryModel2* m) { return m->observations; }
NumericMatrix get_states(BatteryModel2* m) { return m->states; }
void set_input(BatteryModel2* m, NumericMatrix input) { return m->set_input(input); }
void set_observations(BatteryModel2* m, NumericMatrix observations) { return m->set_observations(observations); }
void generate_observations(BatteryModel2* m, int datalength) { return m->generate_observations(datalength); }

// // expose BatteryModel2
RCPP_MODULE(battery2_module) {
  class_<BatteryModel2>( "BatteryModel2" )
  .constructor()
  .field( "Rinf", &BatteryModel2::Rinf)
  .field( "C1", &BatteryModel2::C1)
  .field( "R1", &BatteryModel2::R1)
  .field( "R2", &BatteryModel2::R2)
  .field( "alpha1", &BatteryModel2::alpha1)
  .field( "C2", &BatteryModel2::C2)
  .field( "alpha2", &BatteryModel2::alpha2)
  .field( "A_0_1", &BatteryModel2::A_0_1)
  .field( "A_0_2", &BatteryModel2::A_0_2)
  .field( "coeff1", &BatteryModel2::coeff1)
  .field( "coeff2", &BatteryModel2::coeff2)

  .method( "get_observations", &get_observations)
  .method( "get_states", &get_states)
  .method( "set_observations", &set_observations)
  .method( "set_input", &set_input)
  .method( "generate_observations", &generate_observations)
  .method( "set_parameters", &BatteryModel2::set_parameters)
  .method( "get_parameters", &BatteryModel2::get_parameters)

  ;
}
