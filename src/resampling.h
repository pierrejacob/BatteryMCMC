#ifndef _INCL_RESAMPLING_
#define _INCL_RESAMPLING_
#include <RcppEigen.h>
using namespace Rcpp;

// permute the ancestors so that whenever o(i) > 0, a(i) = i; allows in-place resampling
void permute(IntegerVector & a, const int & nparticles);
// systematic resampling, weights have to sum to 1
void systematic(IntegerVector & ancestors, const NumericVector & weights, const int & nparticles);
// multinomial resampling, weights don't have to sum to 1
void multinomial(IntegerVector & ancestors, const NumericVector & weights);

#endif
