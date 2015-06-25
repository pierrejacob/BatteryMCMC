rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")
nruns <- 5

output_file <- "Plots/datalengthcomparison.pdf"

longfilenames <- paste0("Results/", "u_mag1_size1890", "_run", 1:nruns, "_model1_uniformprior", ".RData")
stdfilenames <- paste0("Results/", "u_mag1_size930", "_run", 1:nruns, "_model1_uniformprior", ".RData")
shortfilenames <- paste0("Results/", "u_mag1_size635", "_run", 1:nruns, "_model1_uniformprior", ".RData")

labels_theta <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]),
                  expression(C[2]), expression(alpha[2]))

longchain.df <- foreach(irun = 1:nruns, .combine = rbind) %do% {
  load(longfilenames[irun])
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.df$run <- irun
  chain.df$datalength <- "T=1890"
  chain.df
}

stdchain.df <- foreach(irun = 1:nruns, .combine = rbind) %do% {
  load(stdfilenames[irun])
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.df$run <- irun
  chain.df$datalength <- "T=930"
  chain.df
}

shortchain.df <- foreach(irun = 1:nruns, .combine = rbind) %do% {
  load(shortfilenames[irun])
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.df$run <- irun
  chain.df$datalength <- "T=635"
  chain.df
}

chain.df <- rbind(longchain.df, stdchain.df, shortchain.df)
chain.df$datalength <- factor(chain.df$datalength, levels = c("T=635", "T=930", "T=1890"))

# pdf(file = output_file, width = 10, height = 5, onefile = TRUE)

g <- ggplot(chain.df, aes(x = X1, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[1]) +
  facet_grid(datalength ~ . )
g

g <- ggplot(chain.df, aes(x = X2, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[2]) +
  facet_grid(datalength ~ . )
g

g <- ggplot(chain.df, aes(x = X3, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[3]) +
  facet_grid(datalength ~ . )
g

g <- ggplot(chain.df, aes(x = X4, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[4]) +
  facet_grid(datalength ~ . )
g

g <- ggplot(chain.df, aes(x = X5, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[5]) +
  facet_grid(datalength ~ . )
g

g <- ggplot(chain.df, aes(x = X6, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[6]) +
  facet_grid(datalength ~ . )
g
# dev.off()

## particular parameters
theme_update(axis.text.x = element_text(size = 12),
             axis.text.y = element_text(size = 12),
             axis.title.y = element_text(angle = 90))

g <- ggplot(chain.df, aes(x = X1, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[1]) +
  facet_grid(datalength ~ . )
pdf(file = "Plots/datalengthRinf.pdf", width = 8, height = 8)
print(g)
dev.off()

g <- ggplot(chain.df, aes(x = X5, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[5]) +
  facet_grid(datalength ~ . )
pdf(file = "Plots/datalengthC2.pdf", width = 8, height = 8)
print(g)
dev.off()
