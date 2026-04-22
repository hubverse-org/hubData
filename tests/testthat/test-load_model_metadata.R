test_that("load_model_metadata fails correctly", {
  # Incorrect hub path throws an error
  expect_error(
    load_model_metadata("no-hub"),
    regexp = "* directory does not exist."
  )

  # No model-metadata folder throws an error
  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  expect_error(
    load_model_metadata(hub_path),
    regexp = ".*model-metadata.* directory not found in root of Hub"
  )

  # Empty model-metadata folder throws an error
  hub_path <- system.file("testhubs/empty", package = "hubUtils")
  expect_error(
    load_model_metadata(hub_path),
    regexp = "* directory is empty."
  )
})

test_that("load_model_metadata works correctly and retuns one row per model.", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  expect_snapshot(str(load_model_metadata(hub_path)))
  expect_snapshot(str(
    load_model_metadata(hub_path, model_ids = c("hub-baseline"))
  ))
  hub_path <- test_path("testdata/error_hub")
  expect_snapshot(str(
    load_model_metadata(hub_path)
  ))
})

# Contains all three of team_abbr, model_abbr, model_id
test_that("resulting tibble has team_abbr, model_abbr, and model_id_columns", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  model_metadata <- load_model_metadata(hub_path)
  expect_snapshot(str(model_metadata))
  expect_true(all(
    c("team_abbr", "model_abbr", "model_id") %in% names(model_metadata)
  ))
})

test_that("Top-level array fields yield list columns, even if they are absent or length-1", {
  hub_path <- test_path("testdata/array_hub")

  # metadata should be loadable for one model at a time, yielding a 1-row tibble in every case
  # Top-level array fields should render as lists (or NA if absent)
  individual_metadata <- purrr::map(
    purrr::set_names(c(
      "no-entry",
      "single-entry",
      "multi-entry",
      "two-arrays"
    )),
    \(x) load_model_metadata(hub_path, model_ids = x)
  )

  purrr::iwalk(individual_metadata, \(x, idx) {
    ptype_mandatory <- if (idx == "no-entry") logical() else list()
    ptype_optional <- if (idx == "two-arrays") list() else logical()
    expect_s3_class(x, "tbl_df")
    expect_shape(x, nrow = 1L)
    expect_vector(x$mandatory_array_valued_metadata, ptype = ptype_mandatory)
    expect_vector(x$optional_array_valued_metadata, ptype = ptype_optional)
    expect_vector(x$model_name, ptype = character())
  })

  # it should be possible to load two models with different choices:
  metadata_for_two_models <- load_model_metadata(
    hub_path,
    model_ids = c("no-entry", "two-arrays")
  )
  expect_s3_class(metadata_for_two_models, "tbl_df")
  expect_shape(metadata_for_two_models, nrow = 2L)
  expect_vector(
    metadata_for_two_models$mandatory_array_valued_metadata,
    ptype = list()
  )
  expect_vector(
    metadata_for_two_models$optional_array_valued_metadata,
    ptype = list()
  )
  expect_vector(metadata_for_two_models$model_name, ptype = character())

  # model metadata files with different length top-level arrays for the same key should be row-bindable
  model_metadata <- load_model_metadata(hub_path)
  expect_snapshot(str(model_metadata))
  # array columns should be lists, but others should be character, etc
  expect_vector(model_metadata$mandatory_array_valued_metadata, ptype = list())
  expect_vector(model_metadata$optional_array_valued_metadata, ptype = list())
  expect_vector(model_metadata$model_name, ptype = character())

  # there should be no duplicate model ids
  expect_equal(model_metadata$model_id, unique(model_metadata$model_id))

  # row-binding the single-row tibbles that result from
  # loading models individually should yield the jointly-loaded metadata
  # if we ensure the same row order.
  manual_complete_metadata <- dplyr::bind_rows(individual_metadata)
  expect_equal(
    dplyr::arrange(model_metadata, .data$model_id),
    dplyr::arrange(manual_complete_metadata, .data$model_id)
  )
})

# Specifying non-existent models throws an error
test_that("Specifying models that don't provide metadata throws an error", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  expect_error(
    load_model_metadata(hub_path, model_ids = "non-existent"),
    regexp = "* not valid model ID"
  )
})

# Output is a tibble
test_that("output is a tibble", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  model_metadata <- load_model_metadata(hub_path)
  expect_true(any(class(model_metadata) %in% c("tbl", "tbl_df", "data.frame")))
})
