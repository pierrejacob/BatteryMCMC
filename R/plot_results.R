#' @rdname plot_results
#' @title plot_results
#' @description plot_results
#' @export
plot_results <- function(filename, save = FALSE){
  if (length(grep("RData", filename)) == 0){
    stop("filename should point to a RData file")
  }
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
  R2min = 10;
  R2max = 100;
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
  mean_R2 = (R2max + R2min) / 2;
  sd_R2 = (R2max - R2min) / sd_scale;

  if (length(grep("model1", filename)) == 1){
    model <- "model1"
  } else {
    if (length(grep("model2", filename)) == 1){
      model <- "model2"
    } else {
      stop("result files should have either 'model1' or 'model2' in its name")
    }
  }
  if (length(grep("unif", filename)) == 1){
    priorRinf <- function(x) dunif(x = x, min = Rinfmin, max = Rinfmax)
    priorC1 <- function(x) dunif(x = x, min = C1min, max = C1max)
    priorR1 <- function(x) dunif(x = x, min = R1min, max = R1max)
    prioralpha1 <- function(x) dunif(x = x, min = alpha1min, max = alpha1max)
    priorC2 <- function(x) dunif(x = x, min = C2min, max = C2max)
    prioralpha2 <- function(x) dunif(x = x, min = alpha2min, max = alpha2max)
    priorR2 <- function(x) dunif(x = x, min = R2min, max = R2max)
  } else {
    priorRinf <- function(x) dnorm(x = x, mean = mean_Rinf, sd = sd_Rinf)
    priorC1 <- function(x) dnorm(x = x, mean = mean_C1, sd = sd_C1)
    priorR1 <- function(x) dnorm(x = x, mean = mean_R1, sd = sd_R1)
    prioralpha1 <- function(x) dnorm(x = x, mean = mean_alpha1, sd = sd_alpha1)
    priorC2 <- function(x) dnorm(x = x, mean = mean_C2, sd = sd_C2)
    prioralpha2 <- function(x) dnorm(x = x, mean = mean_alpha2, sd = sd_alpha2)
    priorR2 <- function(x) dnorm(x = x, mean = mean_R2, sd = sd_R2)
  }
  output_file <- gsub("RData", "pdf", filename)
  load(filename)
  cat("acceptance rate:", 100 * results$naccepts / results$niterations, "% using", results$nparticles, "particles\n")
  cat("% oustide:", 100*sum(is.infinite(results$loglikelihood_proposal)) / results$niterations, "%\n")

  if (model == "model1"){
    labels_theta <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]),
                      expression(C[2]), expression(alpha[2]))
  } else {
    labels_theta <- c(expression(R[infinity]), expression(C[1]), expression(R[1]), expression(alpha[1]),
                      expression(C[2]), expression(alpha[2]), expression(R[2]))
  }

  chain.df <- data.frame(results$chain, iteration = 1:nrow(results$chain))
  chain.meltdf <- melt(chain.df, id.vars = "iteration")
  chain.meltdf$variable <- factor(chain.meltdf$variable, levels = as.vector(unique(chain.meltdf$variable)), labels = labels_theta)
  guideparse <- function(x) parse(text=x)
  if (save){
    pdf(file = output_file, width = 10, height = 5, onefile = TRUE)
  }
  g <- ggplot(chain.meltdf, aes(x = iteration, y = value, colour = variable, group = variable))+
    geom_line() + scale_y_log10() + scale_color_discrete(labels = guideparse)
  print(g)

  cor_melt = melt(cor(chain.df %>% select(-iteration)))
  gcor <- ggplot(cor_melt, aes(Var1, Var2, fill=value, label=round(value, 2))) +
    scale_fill_gradient2() + geom_tile() + geom_text()
  gcor <- gcor + xlab("") + ylab("")
  gcor <- gcor + scale_x_discrete(labels = labels_theta) + scale_y_discrete(labels = labels_theta)
  gcor <- gcor + guides(fill = guide_colourbar(barwidth = 25)) + theme( axis.title.y = element_text(size = 25, angle= 90))
  print(gcor)

  g <- ggplot(chain.df, aes(x = X1)) + geom_histogram(aes(y = ..density..)) + xlab(labels_theta[1])
  g <- g + stat_function(fun = priorRinf, colour = "red", size = 2)
  print(g)

  g <- ggplot(chain.df, aes(x = X2)) + geom_histogram(aes(y = ..density..)) + xlab(labels_theta[2])
  g <- g + stat_function(fun = priorC1, colour = "red", size = 2)
  print(g)

  g <- ggplot(chain.df, aes(x = X3)) + geom_histogram(aes(y = ..density..)) + xlab(labels_theta[3])
  g <- g + stat_function(fun = priorR1, colour = "red", size = 2)
  print(g)

  g <- ggplot(chain.df, aes(x = X4)) + geom_histogram(aes(y = ..density..)) + xlab(labels_theta[4])
  g <- g + stat_function(fun = prioralpha1, colour = "red", size = 2)
  print(g)

  g <- ggplot(chain.df, aes(x = X5)) + geom_histogram(aes(y = ..density..)) + xlab(labels_theta[5])
  g <- g + stat_function(fun = priorC2, colour = "red", size = 2)
  print(g)

  g <- ggplot(chain.df, aes(x = X6)) + geom_histogram(aes(y = ..density..)) + xlab(labels_theta[6])
  g <- g + stat_function(fun = prioralpha2, colour = "red", size = 2)
  print(g)
  if (model == "model2"){
    g <- ggplot(chain.df, aes(x = X7)) + geom_histogram(aes(y = ..density..)) + xlab(labels_theta[7])
    g <- g + stat_function(fun = priorR2, colour = "red", size = 2)
    print(g)
  }

  print(ggplot(chain.df, aes(x = X1, y = X2)) + geom_point() + xlab(labels_theta[1]) + ylab(labels_theta[2]))
  print(ggplot(chain.df, aes(x = X1, y = X3)) + geom_point() + xlab(labels_theta[1]) + ylab(labels_theta[3]))
  print(ggplot(chain.df, aes(x = X1, y = X4)) + geom_point() + xlab(labels_theta[1]) + ylab(labels_theta[4]))
  print(ggplot(chain.df, aes(x = X2, y = X4)) + geom_point() + xlab(labels_theta[2]) + ylab(labels_theta[4]))
  print(ggplot(chain.df, aes(x = X5, y = X6)) + geom_point() + xlab(labels_theta[5]) + ylab(labels_theta[6]))

  if (save){
    dev.off()
  }
}
