rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")




filenames <- c("u_mag1_size930", "u_mag1_size1890", "u_mag5_size930", "u_mag5_size1890")
filename <- filenames[1]
n <- length(filenames)
Prior <- new(Module( "batterymodeluniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModelUniformPrior)
initial_theta <- Prior$rprior()

niterations <- 100
nparticles <- 128

variance_proposal <- diag(c(0.001**2, 0.1**2, 0.05**2, 0.05**2, 10**2, 0.05**2))
cholesky_proposal <- chol(variance_proposal)
load(paste0("Data/", filename, ".RData"))

modellist <- list(model = "model1", prior = "uniform")
algorithmic_parameters <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_proposal, initial_theta = initial_theta)
inputs <- list(current = synthetic_data$current, observations = synthetic_data$observations, theta = parameters)
results_model1 <- launch_pmmh(inputs, modellist, algorithmic_parameters)

Prior <- new(Module( "batterymodel2uniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModel2UniformPrior)
initial_theta2 <- Prior$rprior()

variance_proposal2 <- diag(c(0.001**2, 0.1**2, 0.05**2, 0.05**2, 10**2, 0.05**2, 5**2))
cholesky_proposal2 <- chol(variance_proposal2)
algorithmic_parameters2 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_proposal2, initial_theta = initial_theta2)
modellist2 <- list(model = "model2", prior = "uniform")
inputs2 <- list(current = synthetic_data$current, observations = synthetic_data$observations2, theta = parameters)

results_model2 <- launch_pmmh(inputs2, modellist2, algorithmic_parameters2)
