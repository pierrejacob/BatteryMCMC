## tutorial
# remove all objects
rm(list = ls())
# load the package
library(BatteryMCMC)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

# parameters used to generate the data
parameters <- list(
  Rinf = 0.01,
  C1 = 3,
  R1 = 0.2,
  R2 = 50,
  alpha1 = 0.8,
  C2 = 400,
  alpha2 = 0.5,
  sigma_x = 0.002,
  sigma_y = 0.02,
  Ts = 1/2000)

# load the input file
input_file <- "u_mag1_size635"
current <- matrix(read.csv(file = paste0("Data/", input_file, ".csv"), header = FALSE)$V1, ncol = 1)
qplot(x = 1:nrow(current), y = current[,1], geom = "line") + xlab("time") + ylab("current")

# model 1
Model1 <- new(Module("battery_module", PACKAGE = "BatteryMCMC")$BatteryModel)
# specify the input
Model1$set_input(current)
# specify the parameters
Model1$set_parameters(parameters)
# generate the observations
Model1$generate_observations(nrow(current))
# get the hidden states
states_model1 <- Model1$get_states()
# get the observations
observations_model1 <- Model1$get_observations()
# plot hidden states
hidden_states.df <- melt(data.frame(cbind(1:nrow(current), states_model1)), id.vars = "X1")
hidden_states.df$variable <- factor(hidden_states.df$variable, levels = c("X2", "X3"), labels = c("state 1", "state 2"))
g <- ggplot(hidden_states.df, aes(x = X1, y = value, colour = variable))
g <- g + geom_line() + xlab("time")
g
# plot observations
qplot(x = 1:nrow(current), y = observations_model1[,1], geom = "line") + xlab("time") + ylab("observations")

# now we want to do particle MCMC
# initialize chain using a draw from the prior distribution
Prior <- new(Module( "batterymodeluniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModelUniformPrior)
theta_init <- Prior$rprior()
# set a covariance matrix for the proposal distribution
variance_proposal1 <- diag(c(0.001**2, 0.1**2, 0.05**2, 0.05**2, 10**2, 0.05**2))
cholesky_proposal1 <- chol(variance_proposal1)
# set a number of iterations
niterations <- 100
# set a number of particles
nparticles <- 128

PMCMC <- new(Module( "PMMH_module", PACKAGE = "BatteryMCMC")$PMMH, nparticles, niterations, 2)
PMCMC$set_prior(Prior)
PMCMC$init(Model1, theta_init)
PMCMC$set_proposal_cholesky(cholesky_proposal1)
PMCMC$run()

# acceptance rate
cat("acceptance rate: ", 100*PMCMC$naccepts /PMCMC$niterations, "%\n")

# generated chain
matplot(PMCMC$chain_parameters)
matplot(PMCMC$chain_parameters[,3])
