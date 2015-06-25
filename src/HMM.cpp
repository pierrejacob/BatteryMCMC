#include <RcppEigen.h>
#include "HMM.h"
#include "tree.h"
using namespace Rcpp;
using namespace std;

HMM::HMM() {
}

HMM::~HMM() {
}

void HMM::set_observations(const NumericMatrix & observations){
  this->observations = clone<NumericMatrix>(observations);
  this->datalength = this->observations.nrow();
  this->states = NumericMatrix(datalength, dim_states);
  std::fill(states.begin(), states.end(), 0);
}

void HMM::set_input(const NumericMatrix & input){
  this->input = clone<NumericMatrix>(input);
  this->datalength = this->input.nrow();
}


void HMM::generate_observations(int datalength){
  this->datalength = datalength;
  int nparticles = 1;
  Tree* tree = new Tree(1, datalength + 20, dim_states);
  states = NumericMatrix(datalength, dim_states);
  NumericMatrix xparticles(1, dim_states);
  rinit(xparticles);
  tree->init(xparticles);
  IntegerVector ancestors(nparticles);
  ancestors(0) = 0;
  for (int istate = 0; istate < dim_states; istate++){
    states(0, istate) = xparticles(0, istate);
  }
  for (int k = 1; k < datalength; k++){
    rtransition(tree, xparticles, k);
    tree->insert(xparticles, ancestors);
    for (int istate = 0; istate < dim_states; istate++){
      states(k, istate) = xparticles(0, istate);
    }
  }
  observations = robs(states);
  delete tree;
}
