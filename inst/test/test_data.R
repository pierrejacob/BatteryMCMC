rm(list = ls())
library(BatteryMCMC)
setmytheme()

# syntheticdata <- read.csv(file = system.file(package = "Battery", "extdata/syntheticdata.csv"), header = FALSE)
current <- read.csv(file = "~/Dropbox/Battery/Data/current.csv", header = FALSE)$V1
voltage <- read.csv(file = "~/Dropbox/Battery/Data/voltage.csv", header = FALSE)$V1
time <- seq(from = 0, by = 1/2e3, length.out = length(current))
syntheticdata <- data.frame(cbind(time, current, voltage))
names(syntheticdata) <- c("time", "current", "voltage")
syntheticdata <- subset(syntheticdata, time < 0.05)
# syntheticdata <- syntheticdata[floor(seq(from = 1, to = dim(syntheticdata)[1], length.out = 500)),]
head(syntheticdata)
gcurrent <- ggplot(syntheticdata, aes(x = time, y = current)) + geom_line()
gvoltage <- ggplot(syntheticdata, aes(x = time, y = voltage)) + geom_line()
grid.arrange(gcurrent, gvoltage)
