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

priorRinf <- function(x) dunif(x = x, min = Rinfmin, max = Rinfmax)
priorC1 <- function(x) dunif(x = x, min = C1min, max = C1max)
priorR1 <- function(x) dunif(x = x, min = R1min, max = R1max)
prioralpha1 <- function(x) dunif(x = x, min = alpha1min, max = alpha1max)
priorC2 <- function(x) dunif(x = x, min = C2min, max = C2max)
prioralpha2 <- function(x) dunif(x = x, min = alpha2min, max = alpha2max)

labels_theta <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]),
                  expression(C[2]), expression(alpha[2]))


chain.df <- foreach(irun = 1:nruns, .combine = rbind) %do% {
  load(filenames[irun])
  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.df$run <- irun
  chain.df
}
chain.df$run <- factor(chain.df$run)
# chain.df <- chain.df %>% sample_n(1000)

library(GGally)
theme_update(axis.text.x = element_text(size = 10),
             axis.text.y = element_text(size = 10),
             axis.title.x = element_text(size = 20),
             axis.title.y = element_text(size = 20))
g <- ggpairs(chain.df[,1:6], axisLabels = "show",  columnLabels = labels_theta[1:6],
             params=list(size=10))

p <- ggplot(chain.df, aes(x = X1, group = run, fill = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[1])
p <- p + stat_function(fun = priorRinf, colour = "red", size = 2)
p <- p + theme(axis.title.x = element_text(size = 20))
g <- putPlot(g, p, 1, 1)


p <- ggplot(chain.df, aes(x = X2, group = run, fill = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[2])
p <- p + stat_function(fun = priorC1, colour = "red", size = 2)
g <- putPlot(g, p, 2, 2)

p <- ggplot(chain.df, aes(x = X3, group = run, fill = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[3])
p <- p + stat_function(fun = priorR1, colour = "red", size = 2)
g <- putPlot(g, p, 3, 3)

p <- ggplot(chain.df, aes(x = X4, group = run, fill = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[4])
p <- p + stat_function(fun = prioralpha1, colour = "red", size = 2)
g <- putPlot(g, p, 4, 4)

p <- ggplot(chain.df, aes(x = X5, group = run, fill = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[5])
p <- p + stat_function(fun = priorC2, colour = "red", size = 2)
g <- putPlot(g, p, 5, 5)

p <- ggplot(chain.df, aes(x = X6, group = run, fill = run)) + geom_density(aes(y = ..density..), alpha = 0.1) + xlab(labels_theta[6])
p <- p + stat_function(fun = prioralpha2, colour = "red", size = 2)
g <- putPlot(g, p, 6, 6)

p <- ggplot(chain.df, aes(x = X1, y = X2)) + geom_hex()
g <- putPlot(g, p, 2, 1)

p <- ggplot(chain.df, aes(x = X1, y = X3)) + geom_hex()
g <- putPlot(g, p, 3, 1)

p <- ggplot(chain.df, aes(x = X1, y = X4)) + geom_hex()
g <- putPlot(g, p, 4, 1)

p <- ggplot(chain.df, aes(x = X1, y = X5)) + geom_hex()
g <- putPlot(g, p, 5, 1)

p <- ggplot(chain.df, aes(x = X1, y = X6)) + geom_hex()
g <- putPlot(g, p, 6, 1)

p <- ggplot(chain.df, aes(x = X2, y = X3)) + geom_hex()
g <- putPlot(g, p, 3, 2)

p <- ggplot(chain.df, aes(x = X2, y = X4)) + geom_hex()
g <- putPlot(g, p, 4, 2)

p <- ggplot(chain.df, aes(x = X2, y = X5)) + geom_hex()
g <- putPlot(g, p, 5, 2)

p <- ggplot(chain.df, aes(x = X2, y = X6)) + geom_hex()
g <- putPlot(g, p, 6, 2)

p <- ggplot(chain.df, aes(x = X3, y = X4)) + geom_hex()
g <- putPlot(g, p, 4, 3)

p <- ggplot(chain.df, aes(x = X3, y = X5)) + geom_hex()
g <- putPlot(g, p, 5, 3)

p <- ggplot(chain.df, aes(x = X3, y = X6)) + geom_hex()
g <- putPlot(g, p, 6, 3)

p <- ggplot(chain.df, aes(x = X4, y = X5)) + geom_hex()
g <- putPlot(g, p, 5, 4)

p <- ggplot(chain.df, aes(x = X4, y = X5)) + geom_hex()
g <- putPlot(g, p, 6, 4)

p <- ggplot(chain.df, aes(x = X5, y = X6)) + geom_hex()
g <- putPlot(g, p, 6, 5)

# pdf(file = "Plots/test_ggpairs.pdf", height = 15, width = 15)
# pdf(file = "Plots/u_mag1_size930_model1_uniformprior_ggpairs.pdf", height = 15, width = 15)
# print(g)
# dev.off()

# print(g, left = 1, bottom = 1)
# gg <- grid.ls(print=FALSE)
# idx <- gg$name[grep("text", gg$name)]
# grid.edit(gPath(idx[1]), rot=0, hjust=0.25, gp = gpar(col="red"))
# grid.edit(gPath(idx[2]), rot=0, hjust=0.25, gp = gpar(col="red"))
# grid.edit(gPath(idx[6]), rot=0, hjust=0.25, gp = gpar(col="red"))
# for (i in 1:12){
  # grid.edit(gPath(idx[i]), gp = gpar(cex = 2))
# }

pdf(file = "Plots/test_ggpairs.pdf", height = 15, width = 15, onefile = FALSE)
print(g)
gg <- grid.ls(print=FALSE)
idx <- gg$name[grep("text", gg$name)]
for (i in 1:12){
  grid.edit(gPath(idx[i]), gp = gpar(cex = 1.8))
}
dev.off()
