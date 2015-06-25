#include <RcppEigen.h>
#include "weighted_averages.h"
using namespace Rcpp;


NumericVector wmean(const NumericMatrix & X, const NumericVector & normalized_weights){
  int nrows = X.rows();
  int ncols = X.cols();
  NumericVector weighted_mean(ncols);
  for (int icol = 0; icol < ncols; icol++){
    weighted_mean(icol) = 0.;
    for (int irow = 0; irow < nrows ; irow++){
      weighted_mean(icol) += normalized_weights(irow) * X(irow, icol);
    }
  }
  return weighted_mean;
}

double wmean_vector(const NumericVector & x, const NumericVector & normalized_weights){
  int n = x.size();
//  double sumw = 0;
  double result = 0;
  for (int i = 0; i < n; i++){
//    sumw += unnormalized_w(i);
    result += normalized_weights(i) * x(i);
  }
  return result;
}

// note: this is not the standard unbiased estimator
NumericMatrix wvariance(const NumericMatrix & X, const NumericVector & normalized_weights, const NumericVector & xbar){
  int nrows = X.rows();
  int ncols = X.cols();
  NumericMatrix result(ncols, ncols);
  for (int i = 0; i < ncols; i++){
    for (int j = 0; j < ncols; j++){
      result(i, j) = 0.;
      for (int irow = 0; irow < nrows ; irow++){
        result(i, j) += normalized_weights(irow) * (X(irow, i) - xbar(i)) * (X(irow, j) - xbar(j));
      }
    }
  }
  return result;
}

NumericMatrix wcovariance(const NumericMatrix & X, const NumericMatrix & Y, const NumericVector & normalized_weights,
                          const NumericVector & xbar, const NumericVector & ybar){
  int nrows = X.rows();
  int ncols = X.cols();
  NumericMatrix result(ncols, ncols);
  for (int i = 0; i < ncols; i++){
    for (int j = 0; j < ncols; j++){
      result(i, j) = 0.;
      for (int irow = 0; irow < nrows ; irow++){
        result(i, j) += normalized_weights(irow) * (X(irow, i) - xbar(i)) * (Y(irow, j) - ybar(j));
      }
    }
  }
  return result;
}


