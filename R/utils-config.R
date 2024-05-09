#' Read a JSON config file from a path
#'
#' @param config_path path to JSON config file
#'
#' @return a list representation of the JSON config file
#' @export
#'
#' @examples
#' read_config_file(system.file("config", "tasks.json", package = "hubData"))
read_config_file <- function(config_path) {
  jsonlite::fromJSON(
    config_path,
    simplifyVector = TRUE,
    simplifyDataFrame = FALSE
  )
}
