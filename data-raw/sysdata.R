## code to prepare `std_col_datatypes` dataset goes here
std_col_datatypes <- list(
  model_id = c("character", "factor"),
  output_type = c("character", "factor"),
  value = "numeric"
)

usethis::use_data(std_col_datatypes, overwrite = TRUE, internal = TRUE)
