#ifndef HMM_H_
#define HMM_H_
#include <RcppEigen.h>

using namespace Rcpp;

class Tree;

class HMM {
public:
  HMM();
	virtual ~HMM();
  virtual void set_input(const NumericMatrix & input);
  virtual void set_observations(const NumericMatrix & observations);
  virtual void generate_observations(int datalength);
  virtual void set_parameters(const List & constants) {};
  virtual NumericVector get_parameters() {NumericVector::create(0.) ; }
  virtual void precomputation() {};
  virtual void update_parameters(const NumericVector & parameters) {};
  virtual NumericMatrix robs(NumericMatrix & hstates)  { NumericMatrix m(1,1) ;    m(0,0) = 0;    return m ;};
  // generate first states into xparticles
  virtual void rinit(NumericMatrix & xparticles) = 0;
  // model transition (to generate the data and for the bootstrap particle filter)
  virtual void rtransition(Tree* tree, NumericMatrix & xparticles, int step) = 0;
  // initial step and weighting
  virtual void init_and_weight(NumericMatrix & xparticles, NumericVector & logweights) = 0;
  // next step and weighting
  virtual void transition_and_weight(Tree* tree, NumericMatrix & xparticles, NumericVector & logweights, int step) = 0;
  // log prior probability density function
  // virtual NumericVector logdprior() {return NumericVector::create(0.);}
  // attributes
  NumericMatrix states;
  NumericMatrix observations;
  NumericMatrix input;
  int datalength;
  int dim_parameters;
  int dim_states;
  int dim_observation;
  int dim_input;
  // int truncation;
};

#endif
