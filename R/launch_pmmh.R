#'@rdname launch_pmmh
#'@title launch_pmmh
#'@description launch_pmmh
#'@export
launch_pmmh <- function(inputs, model, algoparameters){
  return(launch_pmmh_cpp(inputs, model, algoparameters))
}
