rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

filenames <- c("u_mag1_size930", "u_mag5_size930", "u_mag1_size635", "u_mag1_size1890")
n <- length(filenames)
Ns <- c(128, 128, 128, 256)


Prior <- new(Module( "batterymodeluniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModelUniformPrior)
initial_thetas1 <- foreach( i = 1:n, .combine = rbind) %dopar%{
  Prior$rprior()
}
initial_thetas1 <- matrix(initial_thetas1, nrow = n, byrow = FALSE)
variance_proposal1 <- diag(c(0.001**2, 0.1**2, 0.05**2, 0.05**2, 10**2, 0.05**2))
cholesky_proposal1 <- chol(variance_proposal1)

niterations <- 5000

# # run model 1 for each file
# foreach(i = 1:n, .combine = c) %dopar% {
#   nparticles <- Ns[i]
#   load(paste0("Data/", filenames[i], ".RData"))
#
#   modellist1 <- list(model = "model1", prior = "uniform")
#   algorithmic_parameters1 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_proposal1, initial_theta = initial_thetas1[i,])
#   inputs1 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model1, theta = synthetic_data$parameters)
#   results <- launch_pmmh(inputs1, modellist1, algorithmic_parameters1)
#   cholesky_preliminary <- try(chol(cov(results$chain[(results$niterations/2):results$niterations,])))
#   theta_preliminary <- results$chain[results$niterations,]
#   save(synthetic_data, cholesky_preliminary, theta_preliminary, results, file = paste0("Results/", filenames[i], "_model1_uniformprior_preliminary.RData"))
#   1
# }

# # run model 2 for u_mag1_size930
# nparticles <- 128
# filename <- "u_mag1_size930"
# load(paste0("Data/", filename, ".RData"))
# Prior2 <- new(Module( "batterymodel2uniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModel2UniformPrior)
# initial_thetas2 <- Prior2$rprior()
# variance_proposal2 <- diag(c(0.001**2, 0.1**2, 0.05**2, 0.05**2, 10**2, 0.05**2, 5**2))
# cholesky_proposal2 <- chol(variance_proposal2)
# modellist2 <- list(model = "model2", prior = "uniform")
# algorithmic_parameters2 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_proposal2, initial_theta = initial_thetas2)
# inputs2 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model2, theta = synthetic_data$parameters)
# results <- launch_pmmh(inputs2, modellist2, algorithmic_parameters2)
# cholesky_preliminary <- try(chol(cov(results$chain[(results$niterations/2):results$niterations,])))
# theta_preliminary <- results$chain[results$niterations,]
# save(synthetic_data, cholesky_preliminary, theta_preliminary, results, file = paste0("Results/", filename, "_model2_uniformprior_preliminary.RData"))

# # run model 1 with normal prior for u_mag1_size930
# nparticles <- 128
# filename <- "u_mag1_size930"
# Prior <- new(Module( "batterymodelnormalprior_module", PACKAGE = "BatteryMCMC")$BatteryModelNormalPrior)
# initial_thetas1 <- Prior$rprior()
# load(paste0("Data/", filename, ".RData"))
# modellist1 <- list(model = "model1", prior = "normal")
# algorithmic_parameters1 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_proposal1, initial_theta = initial_thetas1)
# inputs1 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model1, theta = synthetic_data$parameters)
# results <- launch_pmmh(inputs1, modellist1, algorithmic_parameters1)
# cholesky_preliminary <- try(chol(cov(results$chain[(results$niterations/2):results$niterations,])))
# theta_preliminary <- results$chain[results$niterations,]
# save(synthetic_data, cholesky_preliminary, theta_preliminary, results, file = paste0("Results/", filename, "_model1_normalprior_preliminary.RData"))

# # run model 1 with another signal / noise ratio  for u_mag1_size930
# nparticles <- 128
# filename <- "u_mag1_size930"
# Prior <- new(Module( "batterymodeluniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModelUniformPrior)
# initial_thetas1 <- Prior$rprior()
# load(paste0("Data/", filename, ".RData"))
# modellist1 <- list(model = "model1", prior = "uniform")
# algorithmic_parameters1 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_proposal1, initial_theta = initial_thetas1)
# inputs1 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model1_SNR, theta = synthetic_data$parameters_SNR)
# results <- launch_pmmh(inputs1, modellist1, algorithmic_parameters1)
# cholesky_preliminary <- try(chol(cov(results$chain[(results$niterations/2):results$niterations,])))
# theta_preliminary <- results$chain[results$niterations,]
# save(synthetic_data, cholesky_preliminary, theta_preliminary, results, file = paste0("Results/", filename, "_model1_uniformprior_SNR_preliminary.RData"))

# run model 1 with another signal / noise ratio  for u_mag1_size930
nparticles <- 128
filename <- "u_mag1_size930"
Prior <- new(Module( "batterymodeluniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModelUniformPrior)
initial_thetas1 <- Prior$rprior()
load(paste0("Data/", filename, ".RData"))
modellist1 <- list(model = "model1", prior = "uniform")
algorithmic_parameters1 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_proposal1, initial_theta = initial_thetas1)
inputs1 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model1_SNR2, theta = synthetic_data$parameters_SNR2)
results <- launch_pmmh(inputs1, modellist1, algorithmic_parameters1)
cholesky_preliminary <- try(chol(cov(results$chain[(results$niterations/2):results$niterations,])))
theta_preliminary <- results$chain[results$niterations,]
save(synthetic_data, cholesky_preliminary, theta_preliminary, results, file = paste0("Results/", filename, "_model1_uniformprior_SNR2_preliminary.RData"))
