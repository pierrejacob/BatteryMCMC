rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")
nruns <- 5

output_file <- "Plots/magnitudecomparison.pdf"
mag1filenames <- paste0("Results/", "u_mag1_size930_run", 1:nruns, "_model1_uniformprior", ".RData")
mag5filenames <- paste0("Results/", "u_mag5_size930_run", 1:nruns, "_model1_uniformprior", ".RData")

labels_theta <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]),
                  expression(C[2]), expression(alpha[2]))


mag1chain.df <- foreach(irun = 1:nruns, .combine = rbind) %do% {
  load(mag1filenames[irun])
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.df$run <- irun
  chain.df$mag <- "mag1"
  chain.df
}

mag5chain.df <- foreach(irun = 1:nruns, .combine = rbind) %do% {
  load(mag5filenames[irun])
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.df$run <- irun
  chain.df$mag <- "mag5"
  chain.df
}

chain.df <- rbind(mag1chain.df, mag5chain.df)
chain.df$mag <- factor(chain.df$mag, levels = c("mag1", "mag5"), labels = c("-1/+1", "-5/+5"))

#
# pdf(file = output_file, width = 10, height = 5, onefile = TRUE)

g <- ggplot(chain.df, aes(x = X1, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[1]) +
  facet_grid(mag ~ . )
g

g <- ggplot(chain.df, aes(x = X2, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[2]) +
  facet_grid(mag ~ . )
g

g <- ggplot(chain.df, aes(x = X3, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[3]) +
  facet_grid(mag ~ . )
g

g <- ggplot(chain.df, aes(x = X4, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[4]) +
  facet_grid(mag ~ . )
g

g <- ggplot(chain.df, aes(x = X5, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[5]) +
  facet_grid(mag ~ . )
g

g <- ggplot(chain.df, aes(x = X6, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[6]) +
  facet_grid(mag ~ . )
g

# dev.off()

## particular parameters
theme_update(axis.text.x = element_text(size = 12),
             axis.text.y = element_text(size = 12),
             axis.title.y = element_text(angle = 90))

g <- ggplot(chain.df, aes(x = X1, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[1]) +
  facet_grid(mag ~ . )
pdf(file = "Plots/magnitudeRinf.pdf", width = 8, height = 8)
print(g)
dev.off()

g <- ggplot(chain.df, aes(x = X5, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[5]) +
  facet_grid(mag ~ . )
pdf(file = "Plots/magnitudeC2.pdf", width = 8, height = 8)
print(g)
dev.off()


