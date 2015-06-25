## script to reproduce all the result files
setwd("~/Dropbox/Battery/BatteryMCMC/inst/reproduce/")
# generate synthetic datasets
source("1.generate.data.R")
#
# (optional) test conditional acceptance rate, to tune the number of particles in the particle filter
source("2.CAR.R")
#
# run a short particle MCMC run (5000 iterations), to tune the covariance matrix of the proposal distribution
# also, stores the last value of the Markov chain.
source("3.pmmh.preliminaryruns.R")
#
# run a long particle MCMC (20000 iterations),
# using the previously obtained covariance matrix and starting value of the Markov chain
source("4.pmmh.runs.R")
# compare with second model
source("4.pmmh.model2.R")
# compare with other prior
source("4.pmmh.normalprior.R")
# compare with other signal / noise ratio (SNR)
source("4.pmmh.SNR.R")
# compare with yet another signal / noise ratio (SNR)
source("4.pmmh.SNR2.R")
#
# Plots
source("5.plot.datainput.R")
source("5.plot.datalength.R")
source("5.plot.ggpairs.R")
source("5.plot.magnitude.R")
source("5.plot.models.R")
source("5.plot.priorcomparison.R")
source("5.plot.SNR.R")
source("5.plot.SNR2.R")

