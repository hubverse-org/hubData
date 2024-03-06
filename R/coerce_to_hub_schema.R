#' Coerce data.frame/tibble column data types to hub schema data types or character.
#'
#' @param tbl a model output data.frame/tibble
#' @param skip_date_coercion Logical. Whether to skip coercing dates. This can be faster,
#' especially for larger `tbl`s.
#' @param as_arrow_table Logical. Whether to return an arrow table. Defaults to `FALSE`.
#' @inheritParams create_hub_schema
#'
#' @return `tbl` with column data types coerced to hub schema data types or character.
#' if `as_arrow_table = TRUE`, output is also converted to arrow table.
#' @describeIn coerce_to_hub_schema coerce columns to hub schema data types.
#' @export
coerce_to_hub_schema <- function(tbl, config_tasks, skip_date_coercion = FALSE,
                                 as_arrow_table = FALSE) {
  tbl_schema <- create_hub_schema(
    config_tasks,
    partitions = NULL,
    r_schema = TRUE
  )
  tbl_schema <- tbl_schema[names(tbl)]

  # Coerce data types according to hub schema
  if (skip_date_coercion) {
    tbl[, ] <- purrr::map2(
      .x = names(tbl_schema),
      .y = tbl_schema,
      ~ if (.y == "Date") {
        tbl[[.x]]
      } else {
        get(paste0("as.", .y))(tbl[[.x]])
      }
    )
  } else {
    tbl[, ] <- purrr::map2(
      .x = names(tbl_schema),
      .y = tbl_schema,
      ~ if (.y == "Date") {
        as.Date(tbl[[.x]], format = "%Y-%m-%d")
      } else {
        get(paste0("as.", .y))(tbl[[.x]])
      }
    )
  }
  if (as_arrow_table) {
    return(arrow::arrow_table(tbl))
  } else {
    return(tibble::as_tibble(tbl))
  }
}

#' @export
#' @describeIn coerce_to_hub_schema coerce all columns to character
coerce_to_character <- function(tbl, as_arrow_table = FALSE) {
  chr_schema <- purrr::map(
    names(tbl),
    ~ arrow::field(.x, arrow::string())
  ) %>%
    arrow::schema()

  tbl <- arrow::arrow_table(tbl)$cast(chr_schema)
  if (as_arrow_table) {
    return(tbl)
  } else {
    return(tibble::as_tibble(tbl))
  }
}
