#'@rdname setmytheme
#'@title Set graphical theme
#'@description Sets various options used to produce the plots.
#'@export
setmytheme <- function(){
  library(ggplot2)
  library(gridExtra)
  library(reshape2)
  library(dplyr)
  theme_set(theme_bw())
  theme_update(axis.text.x = element_text(size = 20),
               axis.text.y = element_text(size = 20),
               axis.title.x = element_text(size = 25),
               axis.title.y = element_text(size = 25, angle= 0),
               legend.text = element_text(size = 25),
               legend.title = element_text(size = 25),
               title = element_text(size = 25),
               strip.text = element_text(size = 25),
               legend.position = "bottom")
}