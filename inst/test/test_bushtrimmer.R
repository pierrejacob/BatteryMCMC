# remove all objects from R environment
rm(list = ls())
# load package
try(detach(package:BatteryMCMC))
library(BatteryMCMC)
# load custom theme for the plots
# it requires the packages ggplot2, gridExtra, reshape
setmytheme()
# fix the random seed
set.seed(17)
# Load bush trimmer
mod <- Module( "module_tree", PACKAGE = "BatteryMCMC");
tree_class <- mod$Tree

a_to_o <- function(a){
  n <- length(a)
  o <- rep(0, n)
  for (i in 1:n){
    o[a[i]] = o[a[i]] + 1
  }
  return(o)
}

N <- 32
M <- N
Tree <- new( tree_class, N, M, 1)
Tree$init(matrix(1:N, ncol = 1))
time_horizon <- 30
ancestors <- matrix(nrow = N, ncol = time_horizon)

for (t in 1:time_horizon){
  cat("time ", t, " size ", Tree$M, "\n")
  a <- sample(1:N, size = N, replace = TRUE)
  ancestors[,t] <- a
  Tree$update(matrix(1:N, ncol = 1), a - 1)
}

length(Tree$a_star)
# head(Tree$x_star, 100)
# o <- a_to_o(a)
# Tree$prune(o)
# Tree$a_star
# Tree$nroots

lineages <- matrix(nrow = N, ncol = time_horizon + 1)
lineages[,time_horizon+1] <- 1:N
for (i in 1:N){
  for (t in time_horizon:1){
    lineages[i,t] <- ancestors[lineages[i,t+1],t]
  }
}
apply(X = lineages, MARGIN = 2, FUN = function(x) length(unique(x)))
matplot(t(lineages), type = "l", col ="black")


lineages2 <- matrix(nrow = N, ncol = time_horizon +1)
for (i in 1:N){
  lineages2[i,] <- Tree$get_path( i-1)
}
# matplot(t(lineages2), type = "l")
all(lineages == lineages2)
length(unique(lineages[,1]))

Tree$nsteps
Tree$retrieve_xgeneration(3)
all(sort(Tree$x_star[Tree$l_star+1,1]) == Tree$retrieve_xgeneration(0))

