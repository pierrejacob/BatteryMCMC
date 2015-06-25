rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")
nruns <- 5

output_file <- "Plots/SNRcomparison.pdf"

model1filenames <- paste0("Results/", "u_mag1_size930", "_run", 1:nruns, "_model1_uniformprior", ".RData")
model2filenames <- paste0("Results/", "u_mag1_size930", "_run", 1:nruns, "_model1_uniformprior_SNR", ".RData")

labels_theta <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]),
                  expression(C[2]), expression(alpha[2]), expression(R[2]))


stdchain.df <- foreach(irun = 1:nruns, .combine = rbind) %do% {
  load(model1filenames[irun])
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.df$run <- irun
  chain.df$SNR <- "S/O noise ratio 0.1"
  chain.df
}

SNRchain.df <- foreach(irun = 1:nruns, .combine = rbind) %do% {
  load(model2filenames[irun])
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.df$run <- irun
  chain.df$SNR <- "S/O noise ratio 1.0"
  chain.df
}

chain.df <- rbind(stdchain.df, SNRchain.df)
chain.df$SNR <- factor(chain.df$SNR, levels = c("S/O noise ratio 0.1", "S/O noise ratio 1.0"),
                       labels = c("S/O noise ratio 0.1", "S/O noise ratio 1.0"))


# pdf(file = output_file, width = 10, height = 8, onefile = TRUE)
#
# g <- ggplot(chain.df, aes(x = X1, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[1]) +
#   facet_grid(SNR ~ . )
# g
#
# g <- ggplot(chain.df, aes(x = X2, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[2]) +
#   facet_grid(SNR ~ . )
# g
#
# g <- ggplot(chain.df, aes(x = X3, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[3]) +
#   facet_grid(SNR ~ . )
# g
#
# g <- ggplot(chain.df, aes(x = X4, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[4]) +
#   facet_grid(SNR ~ . )
# g
#
# g <- ggplot(chain.df, aes(x = X5, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[5]) +
#   facet_grid(SNR ~ . )
# g
#
# g <- ggplot(chain.df, aes(x = X6, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[6]) +
#   facet_grid(SNR ~ . )
# g

# dev.off()


## particular parameters
theme_update(axis.text.x = element_text(size = 12),
             axis.text.y = element_text(size = 12),
             axis.title.y = element_text(angle = 90))


g <- ggplot(chain.df, aes(x = X1, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[1]) +
  facet_grid(SNR ~ . )
pdf(file = "Plots/SNRRinf.pdf", width = 8, height = 8)
print(g)
dev.off()

g <- ggplot(chain.df, aes(x = X5, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[5]) +
  facet_grid(SNR ~ . )
pdf(file = "Plots/SNRC2.pdf", width = 8, height = 8)
print(g)
dev.off()

