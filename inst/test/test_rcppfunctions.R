n <- 100000

library(Rcpp)
cppFunction(" NumericVector test(int n){
  NumericVector sl = wrap(seq_len(n));
  NumericVector lgamma_integers = lgamma(1 + sl);
  return lgamma_integers;
            }")

test(10)
lgamma(2:11)

cppFunction(" NumericVector deal_with_infinity(NumericVector x){
  NumericVector y(x.size());
  x(0) = log(0.);
  for (int i = 0; i < x.size() ; i++){
     y(i) = (2 < x(i));
  }
  return y;
}")

deal_with_infinity(c(3, -Inf, 2, Inf))

cppFunction('List deal_with_lists(){
  List list(3);
  CharacterVector names(3);

  List l2 = List::create(Named("firstname") = 1, Named("secondname") = 2);
  CharacterVector l2names = l2.attr("names");
  for (int i = 0; i < 2; i++){
    list[i] = l2[i];
    names[i] = l2names[i];
  }
  list[2] = 3;
  names[2] = "thirdname";
  list.attr("names") = names;
  return list;
}')
deal_with_lists()
