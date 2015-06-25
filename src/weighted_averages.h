#ifndef _INCL_WEIGHTED_AVRG_
#define _INCL_WEIGHTED_AVRG_
#include <RcppEigen.h>
using namespace Rcpp;


// mean of matrix, columnwise, weighted by normalized_weights
// i.e. if X is N x p, normalized_weights must be of size N, and the result is of size p
NumericVector wmean(const NumericMatrix & X, const NumericVector & normalized_weights);

// mean of vector, weighted by normalized_weights (must hence be of same size)
double wmean_vector(const NumericVector & x, const NumericVector & normalized_weights);
            
// covariance of matrix, columnwise, weighted by normalized_weights; 
// xbar is the precomputed weighted mean of X,  for instance computed using wmean above;
// i.e. if X is N x p, normalized_weights must be of size N, and the result is of size p x p
NumericMatrix wvariance(const NumericMatrix & X, const NumericVector & normalized_weights, const NumericVector & xbar);

// covariance between matrices, columnwise, weighted by normalized_weights
// xbar and ybar are the precomputed weighted mean of X and Y;
// i.e. if X and Y are N x p, normalized_weights must be of size N, and the result is of size p x p
NumericMatrix wcovariance(const NumericMatrix & X, const NumericMatrix & Y, const NumericVector & normalized_weights, 
                          const NumericVector & xbar, const NumericVector & ybar);

#endif


//NumericVector mean_cpp(const NumericMatrix & x);
//NumericMatrix covariance_cpp(const NumericMatrix & x);

