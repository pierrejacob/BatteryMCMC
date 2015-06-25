#include <RcppEigen.h>
#include "tree.h"
using namespace Rcpp;
using namespace std;

Tree::Tree(int N, int M, int dimx) : N(N), M(M), dimx(dimx) {
  if (this->M < 3*this->N){
    this->M = 3*this->N;
  }
  this->nsteps = 0;
  a_star = IntegerVector(this->M);
  o_star = IntegerVector(this->M);
  x_star = NumericMatrix(this->M, this->dimx);
  l_star = IntegerVector(this->N);
  already_computed = IntegerVector(this->M);
  computed_terms = NumericMatrix(this->M, this->dimx);
  this->reset();
}

Tree::~Tree(){
  //
}

void Tree::reset(){
  this->nsteps = 0;
  std::fill(a_star.begin(), a_star.end(), 0);
  std::fill(o_star.begin(), o_star.end(), 0);
  std::fill(already_computed.begin(), already_computed.end(), -1);
  std::fill(computed_terms.begin(), computed_terms.end(), 0);
}

void Tree::init(NumericMatrix x_0){
  for (int i = 0; i < N; i ++){
    a_star(i) = -2;
    x_star(i,_) = x_0(i,_);
    l_star(i) = i;
  }
}

void Tree::insert(NumericMatrix x, IntegerVector a){
  nsteps ++;
  // b_t <- gather(l_star, a) // indices of the parents of new generation
  IntegerVector b(N);
  for (int i = 0; i < N; i ++){
    b(i) = l_star(a(i));
  }
  // z_star <- transform prefix sum(o_star, 1_0)
  // l_star <- lower bound (z_star, [1,...,N])
  int slot = 0;
  int i = 0;
  while (slot < N && i < M){
    if (o_star(i) == 0){
      l_star(slot) = i;
      slot ++;
    }
    i++;
  } // here we can test whether slot == N, ie whether we found enough slots
  if (slot < N){
    // if not double the size of vectors
    int old_M = this->M;
    double_size();
    for (i = slot; i < N; i++){
      l_star(i) = old_M + i - slot;
    }
  }
  // a_star <- scatter(b_t, l_star)
  // x_star <- scatter(x_t, l_star)
  for (int i = 0; i < N; i ++){
    a_star(l_star(i)) = b(i);
    x_star(l_star(i),_) = x(i,_);
  }
}

void Tree::prune(IntegerVector o){
  // o_star <- scatter(o_t, l_star)
  for (int i = 0; i < N; i ++){
    o_star(l_star(i)) = o(i);
  }
  //
  int j, new_j;
  for (int i = 0; i < N; i ++){
    j = l_star(i);
    while (j >= 0 && o_star(j) == 0){
      j = a_star(j);
      if (j >= 0){
        o_star(j) = o_star(j) - 1;
      }
    }
  }
}

void Tree::update(NumericMatrix x, IntegerVector a){
  // convert ancestor vector to offspring vector
  IntegerVector o(N);
  std::fill(o.begin(), o.end(), 0);
  for (int i = 0; i < N; i++){
    o(a(i)) ++;
  }
  // prune tree
  this->prune(o);
  // insert new generation
  this->insert(x, a);
}

void Tree::double_size(){
  int old_M = this->M;
  this->M = 2*old_M;
//  cout << "doubling size of tree to " << this->M << endl;
  IntegerVector new_a_star(this->M);
  IntegerVector new_o_star(this->M);
  NumericMatrix new_x_star(this->M, this->dimx);
  already_computed = IntegerVector(this->M);
  computed_terms = NumericMatrix(this->M, this->dimx);
  for (int i = 0; i < old_M; i++){
    new_a_star(i) = a_star(i);
    new_x_star(i,_) = x_star(i,_);
    new_o_star(i) = o_star(i);
  }
  this->a_star = new_a_star;
  this->x_star = new_x_star;
  this->o_star = new_o_star;
}

NumericMatrix Tree::get_path(int n){
  NumericMatrix path(this->nsteps + 1, dimx);
  int j = this->l_star(n);
  path(this->nsteps,_) = this->x_star(j,_);
  int step = this->nsteps - 1;
  while (j >= 0 && step >= 0){
    j = this->a_star(j);
    path(step,_) = this->x_star(j,_);
    step --;
  }
  return path;
}

NumericMatrix Tree::retrieve_xgeneration(int lag){
  NumericMatrix xgeneration(N, dimx);
  for (int i_particle = 0; i_particle < N; i_particle ++){
    int j = this->l_star(i_particle);
    for (int i_step = 0; i_step < lag; i_step++){
      j = this->a_star(j);
    }
    xgeneration(i_particle,_) = this->x_star(j,_);
  }
  return xgeneration;
}

NumericMatrix Tree::weighted_sums(NumericMatrix & weights){
  // compute for each branch x_{1:T}, the sum:
  // sum_{i=1}to{T} weights_i x_i
  // weights has to be of size at least nsteps
  // and same number of column as x
  // already computed could be storing nsteps so that there's no need
  // to re-initialize it at every step
  NumericMatrix results(N, dimx);
  NumericVector computed(dimx);
  IntegerVector trajectory_indices(nsteps+1);
  // int numbervisitednodes = 0;
  // std::fill(already_computed.begin(), already_computed.end(), 0);
  int step, j, index_in_a_star, idim, k;
  for (int i_particle = 0; i_particle < N; i_particle ++){
    j = this->l_star(i_particle);
    trajectory_indices(nsteps) = j;
    step = this->nsteps - 1;
    while (j >= 0 && step >= 0 && already_computed(j) != nsteps){
      j = this->a_star(j);
      trajectory_indices(step) = j;
      step --;
    }
    step++;
    index_in_a_star = trajectory_indices(step);
    if (already_computed(index_in_a_star) != nsteps){
      for (idim = 0; idim < dimx; idim ++){
        computed(idim) = weights(step,idim) * x_star(index_in_a_star,idim);
        computed_terms(index_in_a_star,idim) = computed(idim) ;
      }
      already_computed(index_in_a_star) = nsteps;
    } else {
      for (idim = 0; idim < dimx; idim ++){
        computed(idim) = computed_terms(index_in_a_star,idim);
      }
    }
    // going forward in time
    for (k = step+1; k < nsteps+1; k++){
      index_in_a_star = trajectory_indices(k);
      for (idim = 0; idim < dimx; idim ++){
        computed(idim) = computed(idim) + weights(k,idim) * x_star(index_in_a_star,idim);
        computed_terms(index_in_a_star,idim) = computed(idim) ;
      }
      already_computed(index_in_a_star) = nsteps;
    }
    for (idim = 0; idim < dimx; idim ++){
      results(i_particle,idim) = computed(idim);
    }
  }
  return results;
}

RCPP_MODULE(module_tree) {
  class_<Tree>( "Tree" )
  .constructor<int,int,int>()
  .field( "N", &Tree::N)
  .field( "M", &Tree::M)
  .field( "dimx", &Tree::dimx)
  .field( "nsteps", &Tree::nsteps)
  .field( "a_star", &Tree::a_star)
  .field( "o_star", &Tree::o_star)
  .field( "x_star", &Tree::x_star)
  .field( "l_star", &Tree::l_star)
  .method( "init", &Tree::init)
  .method( "insert", &Tree::insert)
  .method( "prune", &Tree::prune)
  .method( "update", &Tree::update)
  .method( "get_path", &Tree::get_path)
  .method( "retrieve_xgeneration", &Tree::retrieve_xgeneration)
  .method( "weighted_sums", &Tree::weighted_sums)
  ;
}
