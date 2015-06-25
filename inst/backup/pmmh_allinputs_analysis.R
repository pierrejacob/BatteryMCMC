rm(list = ls())
library(BatteryMCMC)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")
guideparse <- function(x) parse(text=x)

labels_theta <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]), expression(C[2]), expression(alpha[2]))

# filenames <- c("u_155", "u_310", "u_465", "u_620", "u_775", "u_930")
filenames <- c("u_mag1_size930", "u_mag1_size1890", "u_mag5_size930", "u_mag5_size1890")
filenames <- c(paste0(filenames, "_long_secondstep"), paste0(filenames, "_2_secondstep"))


plot_file <- function(filename){
  load(file = paste0("Results/", filename, ".RData"))
  result <- result_secondstep
  ConvertResults <- function(results){
    chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
    chain.meltdf <- melt(chain.df, id.vars = "iteration")
    chain.meltdf$variable <- factor(chain.meltdf$variable, levels = paste0("X", 1:6), labels = labels_theta)
    return(list(chain = chain.df, chainmelt = chain.meltdf))
  }

  res <- ConvertResults(result)
  cat("% accept:",  100*result$naccepts / result$niterations, "%\n")
  cat("% oustide:", 100*sum(is.infinite(result$loglikelihood_proposal)) / result$niterations, "%\n")
  chol(cov(res$chain[,1:6]))

  pdf(file = paste0("Results/", filename, ".pdf"), width = 10, height = 5, onefile = TRUE)
  g <- ggplot(res$chainmelt, aes(x = iteration, y = value, colour = variable, group = variable))+
    geom_line() + scale_y_log10() + scale_color_discrete(labels = guideparse)
  print(g)

  cor_melt = melt(cor(res$chain[,1:6]))
  gcor <- ggplot(cor_melt, aes(Var1, Var2, fill=value, label=round(value, 2))) +
    scale_fill_gradient2() + geom_tile() + geom_text()
  gcor <- gcor + xlab("") + ylab("")
  gcor <- gcor + scale_x_discrete(labels = labels_theta) + scale_y_discrete(labels = labels_theta)
  gcor <- gcor + guides(fill = guide_colourbar(barwidth = 25)) + theme( axis.title.y = element_text(size = 25, angle= 90))
  print(gcor)


  print(ggplot(res$chain, aes(x = X1, y = ..density..)) + geom_histogram() + xlab(labels_theta[1]))
  print(ggplot(res$chain, aes(x = X2, y = ..density..)) + geom_histogram() + xlab(labels_theta[2]))
  print(ggplot(res$chain, aes(x = X3, y = ..density..)) + geom_histogram() + xlab(labels_theta[3]))
  print(ggplot(res$chain, aes(x = X4, y = ..density..)) + geom_histogram() + xlab(labels_theta[4]))
  print(ggplot(res$chain, aes(x = X5, y = ..density..)) + geom_histogram() + xlab(labels_theta[5]))
  print(ggplot(res$chain, aes(x = X6, y = ..density..)) + geom_histogram() + xlab(labels_theta[6]))

  print(ggplot(res$chain, aes(x = X1, y = X2)) + geom_point() + xlab(labels_theta[1]) + ylab(labels_theta[2]))
  print(ggplot(res$chain, aes(x = X1, y = X3)) + geom_point() + xlab(labels_theta[1]) + ylab(labels_theta[3]))
  print(ggplot(res$chain, aes(x = X1, y = X4)) + geom_point() + xlab(labels_theta[1]) + ylab(labels_theta[4]))
  print(ggplot(res$chain, aes(x = X2, y = X4)) + geom_point() + xlab(labels_theta[2]) + ylab(labels_theta[4]))
  print(ggplot(res$chain, aes(x = X5, y = X6)) + geom_point() + xlab(labels_theta[5]) + ylab(labels_theta[6]))
  dev.off()
}

indices <- 1:8
for (i in indices){
  try(plot_file(filenames[i]))
}
