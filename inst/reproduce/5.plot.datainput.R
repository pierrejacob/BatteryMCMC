rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")
nruns <- 5
filenames <- paste0("Results/", "u_mag1_size930_run", 1:nruns, "_model1_uniformprior", ".RData")
Rinfmin = 0.005;
Rinfmax = 0.10;
R1min = 0.05;
R1max = 0.50;
C1min = 1;
C1max = 5;
C2min = 300;
C2max = 500;
alpha1min = 0.4;
alpha1max = 1.0;
alpha2min = 0.4;
alpha2max = 1.0;
# load(filenames[1])
# names(results)
load("Data/u_mag1_size930.RData")

theme_update(axis.text.x = element_text(size = 12),
             axis.text.y = element_text(size = 12),
             axis.title.y = element_text(angle = 90))
pdf(file = "Plots/input.pdf", width = 10, height = 5)
g <- qplot(x = 1:length(synthetic_data$current), y = synthetic_data$current, geom = "line")
g <- g + xlab("time") + ylab("input")
print(g)
dev.off()

pdf(file = "Plots/observations.pdf", width = 10, height = 5)
g <- qplot(x = 1:length(synthetic_data$observations_model1), y = synthetic_data$observations_model1, geom = "line")
g <- g + xlab("time") + ylab("observations")
print(g)
dev.off()
