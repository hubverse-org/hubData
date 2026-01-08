test_that("coerce_to_hub_schema works", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  tbl <- arrow::read_csv_arrow(
    fs::path(
      hub_path,
      "model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv"
    )
  ) %>%
    coerce_to_character()

  expect_snapshot(str(
    coerce_to_hub_schema(tbl, config_tasks)
  ))
  expect_snapshot(
    coerce_to_hub_schema(tbl, config_tasks, as_arrow_table = TRUE)
  )
  expect_snapshot(
    coerce_to_hub_schema(
      tbl,
      config_tasks,
      as_arrow_table = TRUE,
      skip_date_coercion = TRUE
    )
  )
})

test_that("coerce_to_character works", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  tbl <- arrow::read_csv_arrow(
    fs::path(
      hub_path,
      "model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv"
    )
  )
  expect_snapshot(str(
    coerce_to_character(tbl)
  ))
  expect_snapshot(
    coerce_to_character(tbl, as_arrow_table = TRUE)
  )
})
