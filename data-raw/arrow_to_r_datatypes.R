## code to prepare `arrow_to_r_datatypes` dataset goes here
arrow_to_r_datatypes <- c(
  bool = "logical",
  int32 = "integer",
  int64 = "integer",
  float = "double", # promoted in R
  double = "double",
  string = "character",
  `date32[day]` = "Date",
  `timestamp[ms]` = "POSIXct"
)

usethis::use_data(arrow_to_r_datatypes, overwrite = TRUE)
