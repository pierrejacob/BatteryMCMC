rm(list = ls())
library(BatteryMCMC)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

launch_pmmh <- function(filename, nparticles, niterations1, niterations2, suffix = ""){
  current <- matrix(read.csv(file = paste0("Data/", filename, ".csv"), header = FALSE)$V1, ncol = 1)
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
  module <- Module( "generate_data_module", PACKAGE = "BatteryMCMC")
  battery_data <- module$generate_data_battery(parameters, current, nrow(current))
  module <- Module( "pmmh_module", PACKAGE = "BatteryMCMC")

  variance_proposal <- diag(c(0.001**2, 0.1**2, 0.05**2, 0.05**2, 10**2, 0.05**2))

  cholesky_proposal <- chol(variance_proposal)

  result_firststep <- module$pmmh_battery(parameters, initial_theta, current,
                                          battery_data$observations, nparticles, niterations1, cholesky_proposal)
  save(result_firststep, file = paste0("Results/", filename, suffix,  "_firststep.RData"))
  cholesky_proposal <- chol(cov(result_firststep$chain))
  result_secondstep <- module$pmmh_battery(parameters, initial_theta, current,
                                           battery_data$observations, nparticles, niterations2, cholesky_proposal)
  save(result_secondstep, file = paste0("Results/", filename, suffix, "_secondstep.RData"))
}

library(foreach)
library(doMC)
registerDoMC(cores = 8)
filenames <- c("u_mag1_size930", "u_mag1_size1890", "u_mag5_size930", "u_mag5_size1890")
niterations1 <- 1000
niterations2 <- 10000
nparticles <- c(256, 256, 256, 256)

foreach(i = 1:4, .combine = c) %dopar% {
  launch_pmmh(filenames[i], nparticles[i], niterations1, niterations2, suffix = "_1")
  1
}

niterations1 <- 5000
niterations2 <- 50000
nparticles <- c(512, 512, 512, 512)
foreach(i = 1:4, .combine = c) %dopar% {
  launch_pmmh(filenames[i], nparticles[i], niterations1, niterations2, suffix = "_2")
  1
}


# operf --callgraph Rscript test_pmmh.R
# opreport --callgraph | less

