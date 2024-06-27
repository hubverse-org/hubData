test_that("connect_hub works on local simple forecasting hub", {
  # Simple forecasting Hub example ----

  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  hub_con <- connect_hub(hub_path)

  # Tests that paths are assigned to attributes correctly
  expect_equal(
    attr(hub_con, "file_format"),
    structure(c(3L, 3L, 1L, 1L), dim = c(2L, 2L), dimnames = list(
      c("n_open", "n_in_dir"), c("csv", "parquet")
    ))
  )
  expect_equal(
    attr(hub_con, "file_system"),
    "LocalFileSystem"
  )
  expect_equal(
    class(hub_con),
    c(
      "hub_connection", "UnionDataset", "Dataset", "ArrowObject",
      "R6"
    )
  )

  expect_equal(
    purrr::map_int(
      hub_con$children,
      ~ length(.x$files)
    ),
    c(3L, 1L)
  )

  # overwrite path attributes to make snapshot portable
  attr(hub_con, "model_output_dir") <- "test/model_output_dir"
  attr(hub_con, "hub_path") <- "test/hub_path"
  expect_snapshot(str(hub_con))
})

test_that("connect_hub works on a local simple forecasting hub with no csvs", {
  # Simple forecasting Hub example ----

  hub_path <- system.file("testhubs/parquet", package = "hubUtils")
  hub_con <- connect_hub(hub_path)

  # Tests that paths are assigned to attributes correctly
  expect_equal(
    attr(hub_con, "file_format"),
    structure(c(4L, 4L), dim = 2:1, dimnames = list(c("n_open", "n_in_dir"), "parquet"))
  )
  expect_equal(
    attr(hub_con, "file_system"),
    "LocalFileSystem"
  )
  expect_equal(
    class(hub_con),
    c(
      "hub_connection", "FileSystemDataset", "Dataset", "ArrowObject",
      "R6"
    )
  )

  # overwrite path attributes to make snapshot portable
  attr(hub_con, "model_output_dir") <- "test/model_output_dir"
  attr(hub_con, "hub_path") <- "test/hub_path"
  expect_snapshot(str(hub_con))
})

test_that("connect_hub returns empty list when model output folder is empty", {
  # Local
  hub_path <- system.file("testhubs/empty", package = "hubUtils")
  expect_warning(connect_hub(hub_path))
  hub_con <- suppressWarnings(connect_hub(hub_path))
  attr(hub_con, "model_output_dir") <- "test/model_output_dir"
  attr(hub_con, "hub_path") <- "test/hub_path"
  expect_snapshot(hub_con)

  # S3
  hub_path <- s3_bucket("hubverse/hubutils/testhubs/empty/")
  hub_con <- suppressWarnings(connect_hub(hub_path, skip_checks=FALSE))
  attr(hub_con, "model_output_dir") <- "test/model_output_dir"
  attr(hub_con, "hub_path") <- "test/hub_path"
  expect_snapshot(hub_con)
})

test_that("connect_hub connection & data extraction works on simple local hub", {
  # Simple forecasting Hub example ----

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  hub_con <- connect_hub(hub_path)

  # Tests that paths are assigned to attributes correctly
  expect_equal(
    attr(hub_con, "file_format"),
    structure(c(5L, 5L, 2L, 2L, 1L, 1L), dim = 2:3, dimnames = list(
      c("n_open", "n_in_dir"), c("csv", "parquet", "arrow")
    ))
  )
  expect_equal(
    attr(hub_con, "file_system"),
    "LocalFileSystem"
  )
  expect_equal(
    class(hub_con),
    c(
      "hub_connection", "UnionDataset", "Dataset", "ArrowObject",
      "R6"
    )
  )

  # overwrite path attributes to make snapshot portable
  attr(hub_con, "model_output_dir") <- basename(attr(hub_con, "model_output_dir"))
  attr(hub_con, "hub_path") <- basename(attr(hub_con, "hub_path"))
  expect_snapshot(str(hub_con))

  # Test that NAs are parsed correctly
  out_df <- hub_con %>%
    dplyr::filter(is.na(output_type_id)) %>%
    dplyr::collect()


  expect_snapshot(str(dplyr::arrange(out_df, value)))

  expect_equal(typeof(out_df$output_type_id), "character")
})


test_that("connect_hub works on local flusight forecasting hub", {
  # Simple forecasting Hub example ----

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  hub_con <- connect_hub(hub_path)

  # Tests that paths are assigned to attributes correctly
  expect_equal(
    attr(hub_con, "file_format"),
    structure(c(5L, 5L, 2L, 2L, 1L, 1L), dim = 2:3, dimnames = list(
      c("n_open", "n_in_dir"), c("csv", "parquet", "arrow")
    ))
  )
  expect_equal(
    attr(hub_con, "file_system"),
    "LocalFileSystem"
  )
  expect_equal(
    class(hub_con),
    c(
      "hub_connection", "UnionDataset", "Dataset", "ArrowObject",
      "R6"
    )
  )

  expect_equal(
    purrr::map_int(
      hub_con$children,
      ~ length(.x$files)
    ),
    c(5L, 2L, 1L)
  )

  # overwrite path attributes to make snapshot portable
  attr(hub_con, "model_output_dir") <- "test/model_output_dir"
  attr(hub_con, "hub_path") <- "test/hub_path"
  expect_snapshot(str(hub_con))
})




test_that("connect_hub file_format override works on local hub", {
  # Simple forecasting Hub example ----

  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  hub_con <- connect_hub(hub_path, file_format = "csv")

  # Tests that paths are assigned to attributes correctly
  expect_equal(
    attr(hub_con, "file_format"),
    structure(c(3L, 3L), dim = 2:1, dimnames = list(c("n_open", "n_in_dir"), "csv"))
  )
  expect_equal(
    attr(hub_con, "file_system"),
    "LocalFileSystem"
  )

  expect_equal(
    class(hub_con),
    c(
      "hub_connection", "FileSystemDataset", "Dataset", "ArrowObject",
      "R6"
    )
  )
})

test_that("Overriding output_type_id data type works correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  con <- connect_hub(hub_path, output_type_id_datatype = "character")

  expect_equal(
    con$schema$output_type_id$ToString(),
    "output_type_id: string"
  )
})


test_that("connect_model_output works on local model_output_dir", {
  # Simple forecasting Hub example ----

  mod_out_path <- system.file("testhubs/simple/model-output", package = "hubUtils")
  mod_out_con <- connect_model_output(mod_out_path)

  # Tests that paths are assigned to attributes correctly
  expect_equal(
    attr(mod_out_con, "file_format"),
    structure(c(3L, 3L), dim = 2:1, dimnames = list(c("n_open", "n_in_dir"), "csv"))
  )
  expect_equal(
    attr(mod_out_con, "file_system"),
    "LocalFileSystem"
  )
  expect_equal(
    class(mod_out_con),
    c(
      "mod_out_connection", "FileSystemDataset", "Dataset", "ArrowObject",
      "R6"
    )
  )
  # overwrite path attributes to make snapshot portable
  attr(mod_out_con, "model_output_dir") <- "test/model_output_dir"
  expect_snapshot(mod_out_con)
  expect_snapshot(str(mod_out_con))


  expect_equal(length(mod_out_con$files), 3L)


  # provide custom schema
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  schema_csv <- create_hub_schema(config_tasks,
    output_type_id_datatype = "character"
  )
  mod_out_con <- connect_model_output(mod_out_path, schema = schema_csv)
  attr(mod_out_con, "model_output_dir") <- "test/model_output_dir"
  expect_snapshot(mod_out_con)
  expect_equal(length(mod_out_con$files), 3L)
})

test_that("connect_model_output fails on empty model_output_dir", {
  # Simple forecasting Hub example ----

  mod_out_path <- system.file("testhubs/empty/model-output", package = "hubUtils")
  expect_snapshot(connect_model_output(mod_out_path), error = TRUE)
  expect_snapshot(connect_model_output(mod_out_path, file_format = "parquet"),
    error = TRUE
  )

  mod_out_path <- s3_bucket("hubverse/hubutils/testhubs/empty/model-output")
  expect_snapshot(connect_model_output(mod_out_path, skip_checks=FALSE), error = TRUE)
})


# PRINT METHODS ----

test_that("hub_connection print method works", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  hub_con <- connect_hub(hub_path)
  attr(hub_con, "model_output_dir") <- "test/model_output_dir"
  attr(hub_con, "hub_path") <- "test/hub_path"

  expect_snapshot(hub_con)
  expect_snapshot(print(hub_con, verbose = TRUE))
})

test_that("mod_out_connection print method works", {
  mod_out_path <- system.file("testhubs/simple/model-output", package = "hubUtils")
  mod_out_con <- connect_model_output(mod_out_path)
  attr(mod_out_con, "model_output_dir") <- "test/model_output_dir"

  expect_snapshot(mod_out_con)
})




test_that("connect_hub data extraction works on simple forecasting hub", {
  # Simple forecasting Hub example ----

  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  hub_con <- connect_hub(hub_path)

  suppressMessages(library(dplyr))
  expect_snapshot(hub_con %>%
    dplyr::filter(
      origin_date == "2022-10-08",
      horizon == 2,
      output_type_id == 0.01
    ) %>%
    dplyr::collect() %>%
    str())

  expect_snapshot(hub_con %>%
    dplyr::filter(
      horizon == 2,
      age_group == "65+"
    ) %>%
    dplyr::collect() %>%
    str())


  model_output_dir <- system.file("testhubs/simple/model-output", package = "hubUtils")
  model_output_con <- connect_model_output(model_output_dir = model_output_dir)
  expect_snapshot(model_output_con %>%
    dplyr::filter(
      origin_date == "2022-10-08",
      horizon == 2,
      output_type_id == 0.01
    ) %>%
    dplyr::collect() %>%
    str())
})


test_that("connect_hub works on S3 bucket simple forecasting hub on AWS", {
  # Simple forecasting Hub example ----

  hub_path <- s3_bucket("hubverse/hubutils/testhubs/simple/")
  hub_con <- connect_hub(hub_path, skip_checks=FALSE)

  # Tests that paths are assigned to attributes correctly
  expect_equal(
    attr(hub_con, "file_format"),
    structure(c(3L, 3L, 1L, 1L), dim = c(2L, 2L), dimnames = list(
      c("n_open", "n_in_dir"), c("csv", "parquet")
    ))
  )

  expect_equal(
    attr(hub_con, "file_system"),
    "S3FileSystem"
  )

  expect_equal(
    class(hub_con),
    c(
      "hub_connection", "UnionDataset", "Dataset", "ArrowObject",
      "R6"
    )
  )

  # overwrite path attributes to make snapshot portable
  attr(hub_con, "model_output_dir") <- "test/model_output_dir"
  attr(hub_con, "hub_path") <- "test/hub_path"
  expect_snapshot(str(hub_con))

  expect_snapshot(hub_con %>%
    dplyr::filter(
      horizon == 2,
      age_group == "65+"
    ) %>%
    dplyr::collect() %>%
    str())
})


test_that("connect_hub & connect_model_output fail correctly", {
  expect_snapshot(connect_hub("random/hub/path"), error = TRUE)
  expect_snapshot(connect_model_output("random/model-output/"), error = TRUE)

  temp_dir <- tempdir()
  expect_snapshot(connect_hub(temp_dir), error = TRUE)

  dir.create(fs::path(temp_dir, "hub-config"))
  expect_error(
    connect_hub(temp_dir),
    regexp = "Config file .*admin.* does not exist at path"
  )

  fs::dir_copy(
    system.file("testhubs/simple/hub-config", package = "hubUtils"),
    temp_dir
  )
  expect_error(
    connect_hub(temp_dir),
    regexp = "Directory .*model-output.* does not exist at path"
  )
})

test_that("connect_hub detects unopenned files correctly", {
  hub_path <- testthat::test_path("testdata/error_file")
  expect_snapshot(connect_hub(hub_path))
})

test_that("output_type_id_datatype arg works in connect_hub on local hub", {
  # Simple forecasting Hub example ----
  hub_path <- system.file("testhubs/simple", package = "hubUtils")

  # Test default reverts to "auto"
  expect_equal(
    connect_hub(hub_path)$schema$GetFieldByName("output_type_id")$ToString(),
    "output_type_id: double"
  )
  # Test that override works
  expect_equal(
    connect_hub(
      hub_path,
      output_type_id_datatype = "character"
    )$schema$GetFieldByName("output_type_id")$ToString(),
    "output_type_id: string"
  )
})
