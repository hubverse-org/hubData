test_that("create_hub_schema works correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  schema_csv <- create_hub_schema(config_tasks)
  expect_equal(
    schema_csv$ToString(),
    "origin_date: date32[day]\ntarget: string\nhorizon: int32\nlocation: string\nage_group: string\noutput_type: string\noutput_type_id: double\nvalue: int32\nmodel_id: string"
  )

  schema_csv <- create_hub_schema(config_tasks,
    output_type_id_datatype = "character"
  )
  expect_equal(
    schema_csv$ToString(),
    "origin_date: date32[day]\ntarget: string\nhorizon: int32\nlocation: string\nage_group: string\noutput_type: string\noutput_type_id: string\nvalue: int32\nmodel_id: string"
  )

  schema_part <- create_hub_schema(config_tasks,
    partitions = list(
      team_abbr = arrow::utf8(),
      model_abbr = arrow::utf8()
    )
  )
  expect_equal(
    schema_part$ToString(),
    "origin_date: date32[day]\ntarget: string\nhorizon: int32\nlocation: string\nage_group: string\noutput_type: string\noutput_type_id: double\nvalue: int32\nteam_abbr: string\nmodel_abbr: string"
  )


  schema_null <- create_hub_schema(config_tasks,
    output_type_id_datatype = "character",
    partitions = NULL
  )
  expect_equal(
    schema_null$ToString(),
    "origin_date: date32[day]\ntarget: string\nhorizon: int32\nlocation: string\nage_group: string\noutput_type: string\noutput_type_id: string\nvalue: int32"
  )

  expect_equal(
    create_hub_schema(config_tasks,
      output_type_id_datatype = "character",
      partitions = NULL,
      r_schema = TRUE
    ),
    c(
      origin_date = "Date", target = "character", horizon = "integer",
      location = "character", age_group = "character", output_type = "character",
      output_type_id = "character", value = "integer"
    )
  )

  expect_equal(
    create_hub_schema(config_tasks,
      output_type_id_datatype = "character",
      r_schema = TRUE
    ),
    c(
      origin_date = "Date", target = "character", horizon = "integer",
      location = "character", age_group = "character", output_type = "character",
      output_type_id = "character", value = "integer", model_id = "character"
    )
  )
})

test_that("create_hub_schema works with sample output types", {
  expect_equal(
    create_hub_schema(
      jsonlite::fromJSON(
        testthat::test_path("testdata", "configs", "tasks-samples-pass.json"),
        simplifyVector = TRUE,
        simplifyDataFrame = FALSE
      )
    )$ToString(),
    "forecast_date: date32[day]\ntarget: string\nhorizon: int32\nlocation: string\noutput_type: string\noutput_type_id: string\nvalue: double\nmodel_id: string"
  )

  expect_equal(
    create_hub_schema(
      jsonlite::fromJSON(
        testthat::test_path("testdata", "configs", "tasks-samples-tid-from-sample.json"),
        simplifyVector = TRUE,
        simplifyDataFrame = FALSE
      )
    )$ToString(),
    "forecast_date: date32[day]\ntarget: string\nhorizon: int32\nlocation: string\noutput_type: string\noutput_type_id: int32\nvalue: double\nmodel_id: string"
  )

  expect_equal(
    create_hub_schema(
      jsonlite::fromJSON(
        testthat::test_path("testdata", "configs", "tasks-samples-old-schema.json"),
        simplifyVector = TRUE,
        simplifyDataFrame = FALSE
      )
    )$ToString(),
    "forecast_date: date32[day]\ntarget: string\nhorizon: int32\nlocation: string\noutput_type: string\noutput_type_id: string\nvalue: double\nmodel_id: string"
  )
})
