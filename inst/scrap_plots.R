rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

filename <- paste0("Results/", "u_mag1_size930_model1_normalprior_SNR_preliminary", ".RData")
filename <- paste0("Results/", "u_mag1_size930_run2_model1_normalprior_SNR", ".RData")
load(filename)

cat("acceptance rate:", 100 * results$naccepts / results$niterations, "% using", results$nparticles, "particles\n")
print(cholesky_preliminary)
theta_preliminary

labels_theta1 <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]), expression(C[2]), expression(alpha[2]))
labels_theta <- labels_theta2 <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]), expression(C[2]), expression(alpha[2]), expression(R[2]))

ConvertResults <- function(results){
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.meltdf <- melt(chain.df, id.vars = "iteration")
  if (ncol(results$chain) == 6){
    chain.meltdf$variable <- factor(chain.meltdf$variable, levels = paste0("X", 1:6), labels = labels_theta1)
  } else {
    chain.meltdf$variable <- factor(chain.meltdf$variable, levels = paste0("X", 1:7), labels = labels_theta2)
  }
  return(list(chain = chain.df, chainmelt = chain.meltdf))
}

res <- ConvertResults(results)
cat("% oustide:", 100*sum(is.infinite(results$loglikelihood_proposal)) / results$niterations, "%\n")
# chol(cov(res$chain[,1:6]))
guideparse <- function(x) parse(text=x)
g <- ggplot(res$chainmelt, aes(x = iteration, y = value, colour = variable, group = variable))+
  geom_line() + scale_y_log10() + scale_color_discrete(labels = guideparse)
print(g)
#
# print(ggplot(res$chain, aes(x = X1, y = ..density..)) + geom_histogram() + xlab(labels_theta[1]))
# print(ggplot(res$chain, aes(x = X2, y = ..density..)) + geom_histogram() + xlab(labels_theta[2]))
# print(ggplot(res$chain, aes(x = X3, y = ..density..)) + geom_histogram() + xlab(labels_theta[3]))
# print(ggplot(res$chain, aes(x = X4, y = ..density..)) + geom_histogram() + xlab(labels_theta[4]))
# print(ggplot(res$chain, aes(x = X5, y = ..density..)) + geom_histogram() + xlab(labels_theta[5]))
# print(ggplot(res$chain, aes(x = X6, y = ..density..)) + geom_histogram() + xlab(labels_theta[6]))
#
# print(ggplot(res$chain, aes(x = X1, y = X2)) + geom_point() + xlab(labels_theta[1]) + ylab(labels_theta[2]))
# print(ggplot(res$chain, aes(x = X1, y = X3)) + geom_point() + xlab(labels_theta[1]) + ylab(labels_theta[3]))
# print(ggplot(res$chain, aes(x = X1, y = X4)) + geom_point() + xlab(labels_theta[1]) + ylab(labels_theta[4]))
# print(ggplot(res$chain, aes(x = X2, y = X4)) + geom_point() + xlab(labels_theta[2]) + ylab(labels_theta[4]))
# print(ggplot(res$chain, aes(x = X5, y = X6)) + geom_point() + xlab(labels_theta[5]) + ylab(labels_theta[6]))



