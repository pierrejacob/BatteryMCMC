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

N <- 328
M <- N
time_horizon <- 100
Tree <- new( tree_class, N, M)
xs <- matrix(nrow = N, ncol = time_horizon + 1)
ancestors <- matrix(nrow = N, ncol = time_horizon)
x <- rnorm(N)
xs[,1] <- x
Tree$init(matrix(x, ncol = 1))

for (t in 1:time_horizon){
  cat("time ", t, " size ", Tree$M, "\n")
  a <- sample(1:N, size = N, replace = TRUE)
  ancestors[,t] <- a
  x <- rnorm(N)
  xs[,(t+1)] <- x
  Tree$update(matrix(x, ncol = 1), a - 1)
}

x_paths <- matrix(nrow = N, ncol = time_horizon +1)
for (i in 1:N){
  x_paths[i,] <- Tree$get_path( i-1)
}

## compute sum of element in each branch
sums <- apply(x_paths, 1, sum)

# algorithm that computes these sums in less than N x T
already_computed <- rep(0, Tree$M)
computed_terms <- rep(0, Tree$M)
trajectory_indices <- rep(0, time_horizon+1)
quicksums <- rep(0, N)
l_star <- Tree$l_star
a_star <- Tree$a_star
x_star <- Tree$x_star
# first particle
# going back in time to find the trajectory indices
for (iparticle in 0:(N-1)){
  j <- l_star[iparticle+1]
  trajectory_indices[time_horizon+1] <- j
  step <- time_horizon - 1
  while (j >= 0 && step >= 0 && already_computed[j+1] == 0){
    j <- a_star[j+1] # +1 because R vectors start at 1
    trajectory_indices[step+1] <- j
    step <- step - 1
  }
  step <- step + 1 # time at which the retrieval stopped
  # unlist(sapply(X = trajectory_indices, FUN = function(i) x_star[i+1,1])) - x_paths[1,]
  index_in_a_star <- trajectory_indices[step+1]
  if (already_computed[index_in_a_star+1] == 0){
    computed <- x_star[index_in_a_star+1,1]
    already_computed[index_in_a_star+1] = 1
    computed_terms[index_in_a_star+1] <- computed
  } else {
    computed <- computed_terms[index_in_a_star+1]
  }

  # going forward in time
  for (k in (step+1):(time_horizon)){
    index_in_a_star <- trajectory_indices[k+1]
    computed <- computed + x_star[index_in_a_star+1,1]
    already_computed[index_in_a_star+1] <- 1
    computed_terms[index_in_a_star+1] <- computed
  }
  quicksums[iparticle+1] <- computed
}

summary(quicksums - sums)
summary(sums - computed_terms[l_star+1])
weights <- rexp(time_horizon+1)
# weights <- rep(1, time_horizon+1)
wsums <- apply(x_paths, 1, function(row) sum(weights*row))
summary(as.numeric(Tree$weighted_sums(matrix(weights, ncol = 1))) - wsums)

