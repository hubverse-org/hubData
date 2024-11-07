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

  # Validate that configs with only point estimate output types returns character (the default)
  # not logical
  config_tasks <- hubUtils::read_config_file(test_path("testdata/configs/v3-tasks-point.json"))
  expect_equal(
    create_hub_schema(config_tasks)$GetFieldByName("output_type_id")$ToString(),
    "output_type_id: string"
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

test_that("create_hub_schema works with config output_type_id_datatype", {
  config_tasks_otid_datatype <- hubUtils::read_config_file(
    testthat::test_path(
      "testdata",
      "configs",
      "tasks-set-otid-datatype.json"
    )
  )
  expect_equal(
    create_hub_schema(
      config_tasks_otid_datatype
    )$GetFieldByName("output_type_id")$ToString(),
    "output_type_id: string"
  )
  expect_equal(
    create_hub_schema(
      config_tasks_otid_datatype,
      output_type_id_datatype = "double"
    )$GetFieldByName("output_type_id")$ToString(),
    "output_type_id: double"
  )
  expect_equal(
    create_hub_schema(
      config_tasks_otid_datatype,
      output_type_id_datatype = "auto"
    )$GetFieldByName("output_type_id")$ToString(),
    "output_type_id: double"
  )
  expect_equal(
    create_hub_schema(
      hubUtils::read_config_file(
        testthat::test_path("testdata", "configs", "nowcast-tasks.json")
      )
    )$ToString(),
    "nowcast_date: date32[day]\ntarget_date: date32[day]\nlocation: string\nclade: string\noutput_type: string\noutput_type_id: string\nvalue: double\nmodel_id: string"
  )
})

test_that("create_hub_schema works with v4 output_type_id configuration", {
  config_tasks <- suppressWarnings(
    hubUtils::read_config_file(test_path("testdata/configs/v4-tasks.json"))
  )
  expect_equal(
    create_hub_schema(config_tasks)$ToString(),
    "forecast_date: date32[day]\ntarget: string\nhorizon: int32\nlocation: string\ntarget_date: date32[day]\noutput_type: string\noutput_type_id: string\nvalue: double\nmodel_id: string"
  )

  # Validate that configs with only point estimate output types returns character (the default)
  config_tasks <- suppressWarnings(
    hubUtils::read_config_file(test_path("testdata/configs/v4-tasks-point.json"))
  )
  expect_equal(
    create_hub_schema(config_tasks)$GetFieldByName("output_type_id")$ToString(),
    "output_type_id: string"
  )
  # Ensure `output_type_id_datatype` arg works with v4 configs
  expect_equal(
    create_hub_schema(
      config_tasks,
      output_type_id_datatype = "double"
    )$GetFieldByName("output_type_id")$ToString(),
    "output_type_id: double"
  )
})
