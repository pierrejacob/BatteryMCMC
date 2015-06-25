rm(list = ls())
library(BatteryMCMC)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

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

# input file names
# filenames <- c("u_mag1_size930", "u_mag1_size1890", "u_mag5_size930", "u_mag5_size1890")
filenames <- c("u_mag1_size635", "u_mag1_size762", "u_mag1_size1016")
Ns <- c(64, 128, 192, 256)


Prior <- new(Module( "batterymodeluniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModelUniformPrior)
initial_thetas <- rbind(Prior$rprior(),Prior$rprior(),Prior$rprior())

## computed conditional acceptance rates
library(foreach)
library(doMC)
registerDoMC(cores=4)
cholesky_proposal <- diag(rep(0, 6))

df <- foreach(itheta = 1:nrow(initial_thetas), .combine = rbind) %:%
  foreach(nparticles = Ns, .combine = rbind) %:%
  foreach(ifile = 1:length(filenames), .combine = rbind) %dopar%{
    load(paste0("Data/", filenames[ifile], ".RData"))
    initial_theta <- initial_thetas[itheta,]
    synthetic_data$theta <- synthetic_data$parameters
    synthetic_data$observations <- synthetic_data$observations_model1
    algorithmic_parameters <- list(nparticles = nparticles, niterations = 100, cholesky_proposal = cholesky_proposal, initial_theta = initial_theta)
    modellist <- list(model = "model1", prior = "uniform")
    results <- launch_pmmh(synthetic_data, modellist, algorithmic_parameters)
    car <- results$naccepts / results$niterations
    data.frame(itheta = itheta, nparticles = nparticles, file = filenames[ifile], car = car)
  }

save(df, initial_thetas, file = "CAR.RData")

load("CAR.RData")
for (f in filenames){
  print(df %>% filter(file == f) %>% arrange(nparticles))
}
# df %>% filter(file == "u_mag1_size930") %>% arrange(nparticles)
# df %>% filter(file == "u_mag5_size930") %>% arrange(nparticles)
# df %>% filter(file == "u_mag1_size1890") %>% arrange(nparticles)
# df %>% filter(file == "u_mag5_size1890") %>% arrange(nparticles)

# operf --callgraph Rscript 2.CAR.R
# opreport --callgraph | less



