rm(list = ls())
library(BatteryMCMC)
setmytheme()
set.seed(17)

current <- matrix(read.csv(file = "~/Dropbox/Battery/Data/u_mag1_size930.csv", header = FALSE)$V1, ncol = 1)
parameters <- list(
  Rinf = 0.01,
  C1 = 3,
  R1 = 0.2,
  alpha1 = 0.8,
  C2 = 400,
  alpha2 = 0.5,
  sigma_x = 0.002,
  sigma_y = 0.02,
  Ts = 1/2000)

initial_theta <- c(parameters$Rinf, parameters$C1, parameters$R1, parameters$alpha1, parameters$C2, parameters$alpha2)
labels_theta <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]), expression(C[2]), expression(alpha[2]))
module <- Module( "generate_data_module", PACKAGE = "BatteryMCMC")
battery_data <- module$generate_data_battery(parameters, current, nrow(current))
module <- Module( "pmmh_module", PACKAGE = "BatteryMCMC")
niterations <- 100
nparticles <- 64
variance_proposal <- diag(c(0.001**2, 0.1**2, 0.05**2, 0.05**2, 10**2, 0.05**2))

cholesky_proposal <- chol(variance_proposal)

res <- module$pmmh_battery(parameters, initial_theta, current,
                           battery_data$observations, nparticles, niterations, cholesky_proposal)
cat("% accept:",  100*res$naccepts / res$niterations, "%\n")
cat("% oustide:", 100*sum(is.infinite(res$loglikelihood_proposal)) / res$niterations, "%\n")
#
# chain.df <- data.frame(res$chain, iteration = 1:niterations)
#
# ggplot(chain.df, aes(x = X1, y = ..density..)) + geom_histogram()
# ggplot(chain.df, aes(x = X2, y = ..density..)) + geom_histogram()
# ggplot(chain.df, aes(x = X3, y = ..density..)) + geom_histogram()
# ggplot(chain.df, aes(x = X4, y = ..density..)) + geom_histogram()
# ggplot(chain.df, aes(x = X5, y = ..density..)) + geom_histogram()
# ggplot(chain.df, aes(x = X6, y = ..density..)) + geom_histogram()
#
# chain.df <- melt(chain.df, id.vars = "iteration")
# chain.df$variable <- factor(chain.df$variable, levels = paste0("X", 1:6), labels = labels_theta)
# guideparse <- function(x) parse(text=x)
# ggplot(chain.df, aes(x = iteration, y = value, colour = variable, group = variable))+
#   geom_line() + scale_y_log10() + scale_color_discrete(labels = guideparse)

# operf --callgraph Rscript test_pmmh.R
# opreport --callgraph | less

