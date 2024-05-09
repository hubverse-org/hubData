# read_config_file works

    Code
      read_config_file(system.file("config", "tasks.json", package = "hubData"))
    Output
      $schema_version
      [1] "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v3.0.0/tasks-schema.json"
      
      $rounds
      $rounds[[1]]
      $rounds[[1]]$round_id_from_variable
      [1] TRUE
      
      $rounds[[1]]$round_id
      [1] "forecast_date"
      
      $rounds[[1]]$model_tasks
      $rounds[[1]]$model_tasks[[1]]
      $rounds[[1]]$model_tasks[[1]]$task_ids
      $rounds[[1]]$model_tasks[[1]]$task_ids$forecast_date
      $rounds[[1]]$model_tasks[[1]]$task_ids$forecast_date$required
      NULL
      
      $rounds[[1]]$model_tasks[[1]]$task_ids$forecast_date$optional
       [1] "2022-12-12" "2022-12-19" "2022-12-26" "2023-01-02" "2023-01-09"
       [6] "2023-01-16" "2023-01-23" "2023-01-30" "2023-02-06" "2023-02-13"
      [11] "2023-02-20" "2023-02-27" "2023-03-06" "2023-03-13" "2023-03-20"
      [16] "2023-03-27" "2023-04-03" "2023-04-10" "2023-04-17" "2023-04-24"
      [21] "2023-05-01" "2023-05-08" "2023-05-15"
      
      
      $rounds[[1]]$model_tasks[[1]]$task_ids$target
      $rounds[[1]]$model_tasks[[1]]$task_ids$target$required
      NULL
      
      $rounds[[1]]$model_tasks[[1]]$task_ids$target$optional
      [1] "wk ahead inc flu hosp"
      
      
      $rounds[[1]]$model_tasks[[1]]$task_ids$horizon
      $rounds[[1]]$model_tasks[[1]]$task_ids$horizon$required
      [1] 2
      
      $rounds[[1]]$model_tasks[[1]]$task_ids$horizon$optional
      [1] 1
      
      
      $rounds[[1]]$model_tasks[[1]]$task_ids$location
      $rounds[[1]]$model_tasks[[1]]$task_ids$location$required
      [1] "US"
      
      $rounds[[1]]$model_tasks[[1]]$task_ids$location$optional
      [1] "01" "02"
      
      
      
      $rounds[[1]]$model_tasks[[1]]$output_type
      $rounds[[1]]$model_tasks[[1]]$output_type$sample
      $rounds[[1]]$model_tasks[[1]]$output_type$sample$output_type_id_params
      $rounds[[1]]$model_tasks[[1]]$output_type$sample$output_type_id_params$is_required
      [1] TRUE
      
      $rounds[[1]]$model_tasks[[1]]$output_type$sample$output_type_id_params$type
      [1] "character"
      
      $rounds[[1]]$model_tasks[[1]]$output_type$sample$output_type_id_params$min_samples_per_task
      [1] 50
      
      $rounds[[1]]$model_tasks[[1]]$output_type$sample$output_type_id_params$max_samples_per_task
      [1] 100
      
      
      $rounds[[1]]$model_tasks[[1]]$output_type$sample$value
      $rounds[[1]]$model_tasks[[1]]$output_type$sample$value$type
      [1] "integer"
      
      $rounds[[1]]$model_tasks[[1]]$output_type$sample$value$minimum
      [1] 0
      
      
      
      $rounds[[1]]$model_tasks[[1]]$output_type$mean
      $rounds[[1]]$model_tasks[[1]]$output_type$mean$output_type_id
      $rounds[[1]]$model_tasks[[1]]$output_type$mean$output_type_id$required
      NULL
      
      $rounds[[1]]$model_tasks[[1]]$output_type$mean$output_type_id$optional
      [1] NA
      
      
      $rounds[[1]]$model_tasks[[1]]$output_type$mean$value
      $rounds[[1]]$model_tasks[[1]]$output_type$mean$value$type
      [1] "double"
      
      $rounds[[1]]$model_tasks[[1]]$output_type$mean$value$minimum
      [1] 0
      
      
      
      
      $rounds[[1]]$model_tasks[[1]]$target_metadata
      $rounds[[1]]$model_tasks[[1]]$target_metadata[[1]]
      $rounds[[1]]$model_tasks[[1]]$target_metadata[[1]]$target_id
      [1] "wk ahead inc flu hosp"
      
      $rounds[[1]]$model_tasks[[1]]$target_metadata[[1]]$target_name
      [1] "weekly influenza hospitalization incidence"
      
      $rounds[[1]]$model_tasks[[1]]$target_metadata[[1]]$target_units
      [1] "rate per 100,000 population"
      
      $rounds[[1]]$model_tasks[[1]]$target_metadata[[1]]$target_keys
      $rounds[[1]]$model_tasks[[1]]$target_metadata[[1]]$target_keys$target
      [1] "wk ahead inc flu hosp"
      
      
      $rounds[[1]]$model_tasks[[1]]$target_metadata[[1]]$target_type
      [1] "discrete"
      
      $rounds[[1]]$model_tasks[[1]]$target_metadata[[1]]$description
      [1] "This target represents the counts of new hospitalizations per horizon week."
      
      $rounds[[1]]$model_tasks[[1]]$target_metadata[[1]]$is_step_ahead
      [1] TRUE
      
      $rounds[[1]]$model_tasks[[1]]$target_metadata[[1]]$time_unit
      [1] "week"
      
      
      
      
      $rounds[[1]]$model_tasks[[2]]
      $rounds[[1]]$model_tasks[[2]]$task_ids
      $rounds[[1]]$model_tasks[[2]]$task_ids$forecast_date
      $rounds[[1]]$model_tasks[[2]]$task_ids$forecast_date$required
      NULL
      
      $rounds[[1]]$model_tasks[[2]]$task_ids$forecast_date$optional
       [1] "2022-12-12" "2022-12-19" "2022-12-26" "2023-01-02" "2023-01-09"
       [6] "2023-01-16" "2023-01-23" "2023-01-30" "2023-02-06" "2023-02-13"
      [11] "2023-02-20" "2023-02-27" "2023-03-06" "2023-03-13" "2023-03-20"
      [16] "2023-03-27" "2023-04-03" "2023-04-10" "2023-04-17" "2023-04-24"
      [21] "2023-05-01" "2023-05-08" "2023-05-15"
      
      
      $rounds[[1]]$model_tasks[[2]]$task_ids$target
      $rounds[[1]]$model_tasks[[2]]$task_ids$target$required
      NULL
      
      $rounds[[1]]$model_tasks[[2]]$task_ids$target$optional
      [1] "wk flu hosp rate change"
      
      
      $rounds[[1]]$model_tasks[[2]]$task_ids$horizon
      $rounds[[1]]$model_tasks[[2]]$task_ids$horizon$required
      [1] 2
      
      $rounds[[1]]$model_tasks[[2]]$task_ids$horizon$optional
      [1] 1
      
      
      $rounds[[1]]$model_tasks[[2]]$task_ids$location
      $rounds[[1]]$model_tasks[[2]]$task_ids$location$required
      [1] "US"
      
      $rounds[[1]]$model_tasks[[2]]$task_ids$location$optional
      [1] "01" "02"
      
      
      
      $rounds[[1]]$model_tasks[[2]]$output_type
      $rounds[[1]]$model_tasks[[2]]$output_type$pmf
      $rounds[[1]]$model_tasks[[2]]$output_type$pmf$output_type_id
      $rounds[[1]]$model_tasks[[2]]$output_type$pmf$output_type_id$required
      [1] "large_decrease" "decrease"       "stable"         "increase"      
      [5] "large_increase"
      
      $rounds[[1]]$model_tasks[[2]]$output_type$pmf$output_type_id$optional
      NULL
      
      
      $rounds[[1]]$model_tasks[[2]]$output_type$pmf$value
      $rounds[[1]]$model_tasks[[2]]$output_type$pmf$value$type
      [1] "double"
      
      $rounds[[1]]$model_tasks[[2]]$output_type$pmf$value$minimum
      [1] 0
      
      $rounds[[1]]$model_tasks[[2]]$output_type$pmf$value$maximum
      [1] 1
      
      
      
      
      $rounds[[1]]$model_tasks[[2]]$target_metadata
      $rounds[[1]]$model_tasks[[2]]$target_metadata[[1]]
      $rounds[[1]]$model_tasks[[2]]$target_metadata[[1]]$target_id
      [1] "wk flu hosp rate change"
      
      $rounds[[1]]$model_tasks[[2]]$target_metadata[[1]]$target_name
      [1] "weekly influenza hospitalization rate change"
      
      $rounds[[1]]$model_tasks[[2]]$target_metadata[[1]]$target_units
      [1] "rate per 100,000 population"
      
      $rounds[[1]]$model_tasks[[2]]$target_metadata[[1]]$target_keys
      $rounds[[1]]$model_tasks[[2]]$target_metadata[[1]]$target_keys$target
      [1] "wk flu hosp rate change"
      
      
      $rounds[[1]]$model_tasks[[2]]$target_metadata[[1]]$target_type
      [1] "nominal"
      
      $rounds[[1]]$model_tasks[[2]]$target_metadata[[1]]$description
      [1] "This target represents the change in the rate of new hospitalizations per week comparing the week ending two days prior to the forecast_date to the week ending h weeks after the forecast_date."
      
      $rounds[[1]]$model_tasks[[2]]$target_metadata[[1]]$is_step_ahead
      [1] TRUE
      
      $rounds[[1]]$model_tasks[[2]]$target_metadata[[1]]$time_unit
      [1] "week"
      
      
      
      
      
      $rounds[[1]]$submissions_due
      $rounds[[1]]$submissions_due$relative_to
      [1] "forecast_date"
      
      $rounds[[1]]$submissions_due$start
      [1] -6
      
      $rounds[[1]]$submissions_due$end
      [1] 2
      
      
      
      

