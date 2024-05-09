# create_model_out_submit_tmpl works correctly

    Code
      str(create_model_out_submit_tmpl(hub_con, round_id = "2023-01-30"))
    Output
      tibble [3,132 x 7] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:3132], format: "2023-01-30" "2023-01-30" ...
       $ target        : chr [1:3132] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
       $ horizon       : int [1:3132] 2 1 2 1 2 1 2 1 2 1 ...
       $ location      : chr [1:3132] "US" "US" "01" "01" ...
       $ output_type   : chr [1:3132] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:3132] "large_decrease" "large_decrease" "large_decrease" "large_decrease" ...
       $ value         : num [1:3132] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(create_model_out_submit_tmpl(hub_con, round_id = "2023-01-16"))
    Output
      tibble [3,132 x 7] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:3132], format: "2023-01-16" "2023-01-16" ...
       $ target        : chr [1:3132] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
       $ horizon       : int [1:3132] 2 1 2 1 2 1 2 1 2 1 ...
       $ location      : chr [1:3132] "US" "US" "01" "01" ...
       $ output_type   : chr [1:3132] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:3132] "large_decrease" "large_decrease" "large_decrease" "large_decrease" ...
       $ value         : num [1:3132] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(create_model_out_submit_tmpl(hub_con, round_id = "2023-01-16",
        required_vals_only = TRUE))
    Output
      tibble [0 x 7] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : 'Date' num(0) 
       $ target        : chr(0) 
       $ horizon       : int(0) 
       $ location      : chr(0) 
       $ output_type   : chr(0) 
       $ output_type_id: chr(0) 
       $ value         : num(0) 

---

    Code
      str(create_model_out_submit_tmpl(hub_con, round_id = "2023-01-16",
        required_vals_only = TRUE, complete_cases_only = FALSE))
    Message
      ! Column "target" whose values are all optional included as all `NA` column.
      ! Round contains more than one modeling task (2)
      i See Hub's 'tasks.json' file or <hub_connection> attribute "config_tasks" for
        details of optional task ID/output_type/output_type ID value combinations.
    Output
      tibble [28 x 7] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:28], format: "2023-01-16" "2023-01-16" ...
       $ target        : chr [1:28] NA NA NA NA ...
       $ horizon       : int [1:28] 2 2 2 2 2 2 2 2 2 2 ...
       $ location      : chr [1:28] "US" "US" "US" "US" ...
       $ output_type   : chr [1:28] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:28] "large_decrease" "decrease" "stable" "increase" ...
       $ value         : num [1:28] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(create_model_out_submit_tmpl(hub_con, round_id = "2022-10-01"))
    Output
      tibble [5,184 x 7] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:5184], format: "2022-10-01" "2022-10-01" ...
       $ target        : chr [1:5184] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:5184] 1 2 3 4 1 2 3 4 1 2 ...
       $ location      : chr [1:5184] "US" "US" "US" "US" ...
       $ output_type   : chr [1:5184] "mean" "mean" "mean" "mean" ...
       $ output_type_id: num [1:5184] NA NA NA NA NA NA NA NA NA NA ...
       $ value         : int [1:5184] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(create_model_out_submit_tmpl(hub_con, round_id = "2022-10-01",
        required_vals_only = TRUE, complete_cases_only = FALSE))
    Message
      ! Column "location" whose values are all optional included as all `NA` column.
      i See Hub's 'tasks.json' file or <hub_connection> attribute "config_tasks" for
        details of optional task ID/output_type/output_type ID value combinations.
    Output
      tibble [23 x 7] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:23], format: "2022-10-01" "2022-10-01" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
       $ location      : chr [1:23] NA NA NA NA ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:23] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(create_model_out_submit_tmpl(hub_con, round_id = "2022-10-29",
        required_vals_only = TRUE, complete_cases_only = FALSE))
    Message
      ! Column "location" whose values are all optional included as all `NA` column.
      i See Hub's 'tasks.json' file or <hub_connection> attribute "config_tasks" for
        details of optional task ID/output_type/output_type ID value combinations.
    Output
      tibble [23 x 8] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:23], format: "2022-10-29" "2022-10-29" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
       $ location      : chr [1:23] NA NA NA NA ...
       $ age_group     : chr [1:23] "65+" "65+" "65+" "65+" ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:23] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(create_model_out_submit_tmpl(hub_con, round_id = "2022-10-29",
        required_vals_only = TRUE))
    Output
      tibble [0 x 8] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : 'Date' num(0) 
       $ target        : chr(0) 
       $ horizon       : int(0) 
       $ location      : chr(0) 
       $ age_group     : chr(0) 
       $ output_type   : chr(0) 
       $ output_type_id: num(0) 
       $ value         : int(0) 

---

    Code
      create_model_out_submit_tmpl(config_tasks = read_config_file(system.file(
        "config", "tasks.json", package = "hubData")), round_id = "2022-12-26")
    Output
      # A tibble: 42 x 7
         forecast_date target        horizon location output_type output_type_id value
         <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
       1 2022-12-26    wk ahead inc~       2 US       mean        <NA>              NA
       2 2022-12-26    wk ahead inc~       1 US       mean        <NA>              NA
       3 2022-12-26    wk ahead inc~       2 01       mean        <NA>              NA
       4 2022-12-26    wk ahead inc~       1 01       mean        <NA>              NA
       5 2022-12-26    wk ahead inc~       2 02       mean        <NA>              NA
       6 2022-12-26    wk ahead inc~       1 02       mean        <NA>              NA
       7 2022-12-26    wk ahead inc~       2 US       sample      s1                NA
       8 2022-12-26    wk ahead inc~       1 US       sample      s2                NA
       9 2022-12-26    wk ahead inc~       2 01       sample      s3                NA
      10 2022-12-26    wk ahead inc~       1 01       sample      s4                NA
      # i 32 more rows

---

    Code
      create_model_out_submit_tmpl(config_tasks = read_config_file(system.file(
        "config", "tasks-comp-tid.json", package = "hubData")), round_id = "2022-12-26")
    Output
      # A tibble: 42 x 7
         forecast_date target        horizon location output_type output_type_id value
         <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
       1 2022-12-26    wk ahead inc~       2 US       mean        <NA>              NA
       2 2022-12-26    wk ahead inc~       1 US       mean        <NA>              NA
       3 2022-12-26    wk ahead inc~       2 01       mean        <NA>              NA
       4 2022-12-26    wk ahead inc~       1 01       mean        <NA>              NA
       5 2022-12-26    wk ahead inc~       2 02       mean        <NA>              NA
       6 2022-12-26    wk ahead inc~       1 02       mean        <NA>              NA
       7 2022-12-26    wk ahead inc~       2 US       sample      1                 NA
       8 2022-12-26    wk ahead inc~       2 01       sample      1                 NA
       9 2022-12-26    wk ahead inc~       2 02       sample      1                 NA
      10 2022-12-26    wk ahead inc~       1 US       sample      2                 NA
      # i 32 more rows

---

    Code
      create_model_out_submit_tmpl(config_tasks = read_config_file(system.file(
        "config", "tasks-comp-tid.json", package = "hubData")), round_id = "2022-12-26") %>%
        dplyr::filter(.data$output_type == "sample")
    Output
      # A tibble: 6 x 7
        forecast_date target         horizon location output_type output_type_id value
        <date>        <chr>            <int> <chr>    <chr>       <chr>          <dbl>
      1 2022-12-26    wk ahead inc ~       2 US       sample      1                 NA
      2 2022-12-26    wk ahead inc ~       2 01       sample      1                 NA
      3 2022-12-26    wk ahead inc ~       2 02       sample      1                 NA
      4 2022-12-26    wk ahead inc ~       1 US       sample      2                 NA
      5 2022-12-26    wk ahead inc ~       1 01       sample      2                 NA
      6 2022-12-26    wk ahead inc ~       1 02       sample      2                 NA

# create_model_out_submit_tmpl errors correctly

    Code
      create_model_out_submit_tmpl(hub_con, round_id = "random_round_id")
    Condition
      Error in `hubUtils::get_round_idx()`:
      ! `round_id` must be one of "2022-10-01", "2022-10-08", "2022-10-15", "2022-10-22", or "2022-10-29", not "random_round_id".

---

    Code
      create_model_out_submit_tmpl(hub_con)
    Condition
      Error in `checkmate::assert_string()`:
      ! argument "round_id" is missing, with no default

---

    Code
      create_model_out_submit_tmpl(hub_con)
    Condition
      Error in `checkmate::assert_string()`:
      ! argument "round_id" is missing, with no default

---

    Code
      create_model_out_submit_tmpl(list())
    Condition
      Error in `create_model_out_submit_tmpl()`:
      ! Assertion on 'hub_con' failed: Must inherit from class 'hub_connection', but has class 'list'.

