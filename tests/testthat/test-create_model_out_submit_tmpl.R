test_that("create_model_out_submit_tmpl works correctly", {
  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )

  expect_snapshot(str(
    create_model_out_submit_tmpl(hub_con,
      round_id = "2023-01-30"
    )
  ))

  expect_snapshot(str(
    create_model_out_submit_tmpl(hub_con,
      round_id = "2023-01-16"
    )
  ))
  expect_equal(
    unique(suppressMessages(
      create_model_out_submit_tmpl(
        hub_con,
        round_id = "2022-12-19"
      )$forecast_date
    )),
    as.Date("2022-12-19")
  )

  expect_snapshot(str(
    create_model_out_submit_tmpl(
      hub_con,
      round_id = "2023-01-16",
      required_vals_only = TRUE
    )
  ))
  expect_equal(
    unique(suppressMessages(
      create_model_out_submit_tmpl(
        hub_con,
        round_id = "2022-12-19",
        required_vals_only = TRUE,
        complete_cases_only = FALSE
      )$forecast_date
    )),
    as.Date("2022-12-19")
  )


  expect_snapshot(str(
    create_model_out_submit_tmpl(
      hub_con,
      round_id = "2023-01-16",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  ))

  expect_equal(
    unique(suppressMessages(
      create_model_out_submit_tmpl(
        hub_con,
        round_id = "2022-12-19",
        required_vals_only = TRUE,
        complete_cases_only = FALSE
      )$forecast_date
    )),
    as.Date("2022-12-19")
  )

  # Specifying a round in a hub with multiple rounds
  hub_con <- hubData::connect_hub(
    system.file("testhubs/simple", package = "hubUtils")
  )

  expect_snapshot(str(
    create_model_out_submit_tmpl(
      hub_con,
      round_id = "2022-10-01"
    )
  ))

  expect_snapshot(str(
    create_model_out_submit_tmpl(
      hub_con,
      round_id = "2022-10-01",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  ))
  expect_snapshot(str(
    create_model_out_submit_tmpl(
      hub_con,
      round_id = "2022-10-29",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  ))


  expect_snapshot(str(
    create_model_out_submit_tmpl(
      hub_con,
      round_id = "2022-10-29",
      required_vals_only = TRUE
    )
  ))

  # Hub with sample output type
  expect_snapshot(
    create_model_out_submit_tmpl(
      config_tasks = hubUtils::read_config_file(system.file("config", "tasks.json",
        package = "hubData"
      )),
      round_id = "2022-12-26"
    )
  )

  # Hub with sample output type and compound task ID structure
  expect_snapshot(
    create_model_out_submit_tmpl(
      config_tasks = hubUtils::read_config_file(system.file("config", "tasks-comp-tid.json",
        package = "hubData"
      )),
      round_id = "2022-12-26"
    )
  )
  expect_snapshot(
    create_model_out_submit_tmpl(
      config_tasks = hubUtils::read_config_file(
        system.file("config", "tasks-comp-tid.json",
          package = "hubData"
        )
      ),
      round_id = "2022-12-26"
    ) %>%
      dplyr::filter(.data$output_type == "sample")
  )
})

test_that("create_model_out_submit_tmpl errors correctly", {
  # Specifying a round in a hub with multiple rounds
  hub_con <- hubData::connect_hub(system.file("testhubs/simple", package = "hubUtils"))

  expect_snapshot(
    create_model_out_submit_tmpl(
      hub_con,
      round_id = "random_round_id"
    ),
    error = TRUE
  )
  expect_snapshot(
    create_model_out_submit_tmpl(hub_con),
    error = TRUE
  )

  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )
  expect_snapshot(
    create_model_out_submit_tmpl(hub_con),
    error = TRUE
  )

  expect_snapshot(
    create_model_out_submit_tmpl(list()),
    error = TRUE
  )
})
