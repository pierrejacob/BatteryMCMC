rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")
nruns <- 5

output_file <- "Plots/priorcomparison.pdf"

filename <- "u_mag1_size930"
normalfilenames <- paste0("Results/", filename, "_run", 1:nruns, "_model1_normalprior", ".RData")
uniformfilenames <- paste0("Results/", filename, "_run", 1:nruns, "_model1_uniformprior", ".RData")
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
sd_scale = 4.;
mean_Rinf = (Rinfmax + Rinfmin) / 2;
sd_Rinf = (Rinfmax - Rinfmin) / sd_scale;
mean_C1 = (C1max + C1min) / 2;
sd_C1 = (C1max - C1min) / sd_scale;
mean_R1 = (R1max + R1min) / 2;
sd_R1 = (R1max - R1min) / sd_scale;
mean_alpha1 = (alpha1max + alpha1min) / 2;
sd_alpha1 = (alpha1max - alpha1min) / sd_scale;
mean_C2 = (C2max + C2min) / 2;
sd_C2 = (C2max - C2min) / sd_scale;
mean_alpha2 = (alpha2max + alpha2min) / 2;
sd_alpha2 = (alpha2max - alpha2min) / sd_scale;

uniformpriorRinf <- function(x) dunif(x = x, min = Rinfmin, max = Rinfmax)
uniformpriorC1 <- function(x) dunif(x = x, min = C1min, max = C1max)
uniformpriorR1 <- function(x) dunif(x = x, min = R1min, max = R1max)
uniformprioralpha1 <- function(x) dunif(x = x, min = alpha1min, max = alpha1max)
uniformpriorC2 <- function(x) dunif(x = x, min = C2min, max = C2max)
uniformprioralpha2 <- function(x) dunif(x = x, min = alpha2min, max = alpha2max)

normalpriorRinf <- function(x) dnorm(x = x, mean = mean_Rinf, sd = sd_Rinf)
normalpriorC1 <- function(x) dnorm(x = x, mean = mean_C1, sd = sd_C1)
normalpriorR1 <- function(x) dnorm(x = x, mean = mean_R1, sd = sd_R1)
normalprioralpha1 <- function(x) dnorm(x = x, mean = mean_alpha1, sd = sd_alpha1)
normalpriorC2 <- function(x) dnorm(x = x, mean = mean_C2, sd = sd_C2)
normalprioralpha2 <- function(x) dnorm(x = x, mean = mean_alpha2, sd = sd_alpha2)


labels_theta <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]),
                  expression(C[2]), expression(alpha[2]))


normalchain.df <- foreach(irun = 1:nruns, .combine = rbind) %do% {
  load(normalfilenames[irun])
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.df$run <- irun
  chain.df$prior <- "normal"
  chain.df
}

uniformchain.df <- foreach(irun = 1:nruns, .combine = rbind) %do% {
  load(uniformfilenames[irun])
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.df$run <- irun
  chain.df$prior <- "uniform"
  chain.df
}

chain.df <- rbind(normalchain.df, uniformchain.df)
chain.df$prior <- factor(chain.df$prior, levels = c("uniform", "normal"), labels = c("uniform", "normal"))

ngrid <- 100

# pdf(file = output_file, width = 10, height = 5, onefile = TRUE)

g <- ggplot(chain.df, aes(x = X1, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[1]) +
  facet_grid(prior ~ . )

grid <- seq(from = range(chain.df$X1)[1], to = range(chain.df$X1)[2], length.out = ngrid)
dprior <- data.frame(x = rep(grid, 2), priorvalues = c(uniformpriorRinf(grid), normalpriorRinf(grid)),
                     prior = c(rep("uniform", ngrid),rep("normal", ngrid)))
g + geom_line(data = dprior, aes(x = x, y = priorvalues, group = NULL), colour = "red")

g <- ggplot(chain.df, aes(x = X2, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[2]) +
  facet_grid(prior ~ . )

grid <- seq(from = range(chain.df$X2)[1], to = range(chain.df$X2)[2], length.out = ngrid)
dprior <- data.frame(x = rep(grid, 2), priorvalues = c(uniformpriorC1(grid), normalpriorC1(grid)),
                     prior = c(rep("uniform", ngrid),rep("normal", ngrid)))
g + geom_line(data = dprior, aes(x = x, y = priorvalues, group = NULL), colour = "red")


g <- ggplot(chain.df, aes(x = X3, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[3]) +
  facet_grid(prior ~ . )
grid <- seq(from = range(chain.df$X3)[1], to = range(chain.df$X3)[2], length.out = ngrid)
dprior <- data.frame(x = rep(grid, 2), priorvalues = c(uniformpriorR1(grid), normalpriorR1(grid)),
                     prior = c(rep("uniform", ngrid),rep("normal", ngrid)))
g + geom_line(data = dprior, aes(x = x, y = priorvalues, group = NULL), colour = "red")


g <- ggplot(chain.df, aes(x = X4, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[4]) +
  facet_grid(prior ~ . )
grid <- seq(from = range(chain.df$X4)[1], to = range(chain.df$X4)[2], length.out = ngrid)
dprior <- data.frame(x = rep(grid, 2), priorvalues = c(uniformprioralpha1(grid), normalprioralpha1(grid)),
                     prior = c(rep("uniform", ngrid),rep("normal", ngrid)))
g + geom_line(data = dprior, aes(x = x, y = priorvalues, group = NULL), colour = "red")


g <- ggplot(chain.df, aes(x = X5, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[5]) +
  facet_grid(prior ~ . )
grid <- seq(from = range(chain.df$X5)[1], to = range(chain.df$X5)[2], length.out = ngrid)
dprior <- data.frame(x = rep(grid, 2), priorvalues = c(uniformpriorC2(grid), normalpriorC2(grid)),
                     prior = c(rep("uniform", ngrid),rep("normal", ngrid)))
g + geom_line(data = dprior, aes(x = x, y = priorvalues, group = NULL), colour = "red")

g <- ggplot(chain.df, aes(x = X6, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[6]) +
  facet_grid(prior ~ . )
grid <- seq(from = range(chain.df$X6)[1], to = range(chain.df$X6)[2], length.out = ngrid)
dprior <- data.frame(x = rep(grid, 2), priorvalues = c(uniformprioralpha2(grid), normalprioralpha2(grid)),
                     prior = c(rep("uniform", ngrid),rep("normal", ngrid)))
g + geom_line(data = dprior, aes(x = x, y = priorvalues, group = NULL), colour = "red")


# dev.off()

## particular parameters
theme_update(axis.text.x = element_text(size = 12),
             axis.text.y = element_text(size = 12),
             axis.title.y = element_text(angle = 90))

g <- ggplot(chain.df, aes(x = X1, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[1]) +
  facet_grid(prior ~ . )

grid <- seq(from = range(chain.df$X1)[1], to = range(chain.df$X1)[2], length.out = ngrid)
dprior <- data.frame(x = rep(grid, 2), priorvalues = c(uniformpriorRinf(grid), normalpriorRinf(grid)),
                     prior = c(rep("uniform", ngrid),rep("normal", ngrid)))
g <- g + geom_line(data = dprior, aes(x = x, y = priorvalues, group = NULL), colour = "red")
pdf(file = "Plots/priorRinf.pdf", width = 8, height = 8)
print(g)
dev.off()

g <- ggplot(chain.df, aes(x = X5, group = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[5]) +
  facet_grid(prior ~ . )
grid <- seq(from = range(chain.df$X5)[1], to = range(chain.df$X5)[2], length.out = ngrid)
dprior <- data.frame(x = rep(grid, 2), priorvalues = c(uniformpriorC2(grid), normalpriorC2(grid)),
                     prior = c(rep("uniform", ngrid),rep("normal", ngrid)))
g <- g + geom_line(data = dprior, aes(x = x, y = priorvalues, group = NULL), colour = "red")
pdf(file = "Plots/priorC2.pdf", width = 8, height = 8)
print(g)
dev.off()
