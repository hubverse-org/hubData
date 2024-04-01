test_that("collect_hub works on local simple forecasting hub", {
  # Simple forecasting Hub example ----

  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  hub_con <- connect_hub(hub_path)


  # Collect whole hub
  expect_snapshot(collect_hub(hub_con))
  expect_s3_class(
    collect_hub(hub_con),
    c("model_out_tbl", "tbl_df", "tbl", "data.frame")
  )

  # Collect after filtering
  expect_snapshot(
    dplyr::filter(hub_con, is.na(output_type_id)) %>%
      collect_hub()
  )
  expect_s3_class(
    dplyr::filter(hub_con, is.na(output_type_id)) %>%
      collect_hub(),
    c("model_out_tbl", "tbl_df", "tbl", "data.frame")
  )


  # Pass arguments to as_model_out_tbl
  expect_snapshot(
    dplyr::filter(hub_con, is.na(output_type_id)) %>%
      collect_hub(remove_empty = TRUE)
  )

  # Check that tibble retuned and message issued when coercion to model_out_tbl
  # not possible
  expect_snapshot(
    dplyr::filter(hub_con, is.na(output_type_id)) %>%
      dplyr::select(target) %>%
      collect_hub()
  )
  expect_s3_class(
    dplyr::filter(hub_con, is.na(output_type_id)) %>%
      dplyr::select(target) %>%
      collect_hub() %>%
      suppressMessages() %>%
      suppressWarnings(),
    c("tbl_df", "tbl", "data.frame")
  )

  # Check that silencing works when coercion not possible
  expect_snapshot(
    dplyr::filter(hub_con, is.na(output_type_id)) %>%
      dplyr::select(target) %>%
      collect_hub(silent = TRUE)
  )
  expect_s3_class(
    dplyr::filter(hub_con, is.na(output_type_id)) %>%
      dplyr::select(target) %>%
      collect_hub(silent = TRUE),
    c("tbl_df", "tbl", "data.frame")
  )
})


test_that("collect_hub returns NULL with warning when model output folder is empty", {
  hub_path <- system.file("testhubs/empty", package = "hubUtils")
  hub_con <- suppressWarnings(connect_hub(hub_path))
  # Collect whole hub
  expect_snapshot(collect_hub(hub_con))
})


test_that("collect_hub works on model output directories", {
  mod_out_path <- system.file("testhubs/simple/model-output",
    package = "hubUtils"
  )
  mod_out_con <- connect_model_output(mod_out_path)

  expect_s3_class(
    collect_hub(mod_out_con),
    c("model_out_tbl", "tbl_df", "tbl", "data.frame")
  )

  expect_snapshot(
    dplyr::filter(mod_out_con, is.na(output_type_id)) %>%
      collect_hub()
  )

  # Check behaviour when coercion to model_out_tbl not possible
  expect_snapshot(
    dplyr::filter(mod_out_con, is.na(output_type_id)) %>%
      dplyr::select(target) %>%
      collect_hub()
  )
  expect_snapshot(
    dplyr::filter(mod_out_con, is.na(output_type_id)) %>%
      dplyr::select(target) %>%
      collect_hub(silent = TRUE)
  )
})
