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

# Note: r_to_arrow_datatypes is not saved as data because Arrow DataType objects
# are external pointers that cannot be serialized. Instead, it's created via
# a helper function .r_to_arrow_datatypes() in R/utils-arrow-types.R

usethis::use_data(arrow_to_r_datatypes, overwrite = TRUE)

usethis::use_data(
  arrow_to_r_datatypes,
  internal = TRUE,
  overwrite = TRUE
)
