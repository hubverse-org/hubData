# expand_model_out_val_grid works correctly

    Code
      str(expand_model_out_val_grid(config_tasks, round_id = "2023-01-02"))
    Output
      tibble [3,132 x 6] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:3132], format: "2023-01-02" "2023-01-02" ...
       $ target        : chr [1:3132] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
       $ horizon       : int [1:3132] 2 1 2 1 2 1 2 1 2 1 ...
       $ location      : chr [1:3132] "US" "US" "01" "01" ...
       $ output_type   : chr [1:3132] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:3132] "large_decrease" "large_decrease" "large_decrease" "large_decrease" ...

---

    Code
      str(expand_model_out_val_grid(config_tasks, round_id = "2023-01-02",
        required_vals_only = TRUE))
    Output
      tibble [28 x 5] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:28], format: "2023-01-02" "2023-01-02" ...
       $ horizon       : int [1:28] 2 2 2 2 2 2 2 2 2 2 ...
       $ location      : chr [1:28] "US" "US" "US" "US" ...
       $ output_type   : chr [1:28] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:28] "large_decrease" "decrease" "stable" "increase" ...

---

    Code
      str(expand_model_out_val_grid(config_tasks, round_id = "2022-10-01"))
    Output
      tibble [5,184 x 6] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:5184], format: "2022-10-01" "2022-10-01" ...
       $ target        : chr [1:5184] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:5184] 1 2 3 4 1 2 3 4 1 2 ...
       $ location      : chr [1:5184] "US" "US" "US" "US" ...
       $ output_type   : chr [1:5184] "mean" "mean" "mean" "mean" ...
       $ output_type_id: num [1:5184] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(expand_model_out_val_grid(config_tasks, round_id = "2022-10-01",
        required_vals_only = TRUE))
    Output
      tibble [23 x 5] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:23], format: "2022-10-01" "2022-10-01" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...

---

    Code
      str(expand_model_out_val_grid(config_tasks, round_id = "2022-10-29",
        required_vals_only = TRUE))
    Output
      tibble [23 x 6] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:23], format: "2022-10-29" "2022-10-29" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
       $ age_group     : chr [1:23] "65+" "65+" "65+" "65+" ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...

---

    Code
      str(expand_model_out_val_grid(config_tasks, round_id = "2022-10-29",
        required_vals_only = TRUE, all_character = TRUE))
    Output
      tibble [23 x 6] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : chr [1:23] "2022-10-29" "2022-10-29" "2022-10-29" "2022-10-29" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : chr [1:23] "1" "1" "1" "1" ...
       $ age_group     : chr [1:23] "65+" "65+" "65+" "65+" ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: chr [1:23] "0.01" "0.025" "0.05" "0.1" ...

---

    Code
      expand_model_out_val_grid(config_tasks, round_id = "2022-10-29",
        required_vals_only = TRUE, as_arrow_table = TRUE)
    Output
      Table
      23 rows x 6 columns
      $origin_date <date32[day]>
      $target <string>
      $horizon <int32>
      $age_group <string>
      $output_type <string>
      $output_type_id <double>
      
      See $metadata for additional Schema metadata

---

    Code
      expand_model_out_val_grid(config_tasks, round_id = "2022-10-29",
        required_vals_only = TRUE, all_character = TRUE, as_arrow_table = TRUE)
    Output
      Table
      23 rows x 6 columns
      $origin_date <string>
      $target <string>
      $horizon <string>
      $age_group <string>
      $output_type <string>
      $output_type_id <string>

# expand_model_out_val_grid output controls work correctly

    Code
      str(expand_model_out_val_grid(config_tasks, round_id = "2023-01-02",
        all_character = TRUE))
    Output
      tibble [3,132 x 6] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : chr [1:3132] "2023-01-02" "2023-01-02" "2023-01-02" "2023-01-02" ...
       $ target        : chr [1:3132] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
       $ horizon       : chr [1:3132] "2" "1" "2" "1" ...
       $ location      : chr [1:3132] "US" "US" "01" "01" ...
       $ output_type   : chr [1:3132] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:3132] "large_decrease" "large_decrease" "large_decrease" "large_decrease" ...

---

    Code
      expand_model_out_val_grid(config_tasks, round_id = "2023-01-02", all_character = TRUE,
        as_arrow_table = TRUE)
    Output
      Table
      3132 rows x 6 columns
      $forecast_date <string>
      $target <string>
      $horizon <string>
      $location <string>
      $output_type <string>
      $output_type_id <string>

---

    Code
      str(expand_model_out_val_grid(config_tasks, round_id = "2023-01-02",
        required_vals_only = TRUE, all_character = TRUE))
    Output
      tibble [28 x 5] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : chr [1:28] "2023-01-02" "2023-01-02" "2023-01-02" "2023-01-02" ...
       $ horizon       : chr [1:28] "2" "2" "2" "2" ...
       $ location      : chr [1:28] "US" "US" "US" "US" ...
       $ output_type   : chr [1:28] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:28] "large_decrease" "decrease" "stable" "increase" ...

---

    Code
      expand_model_out_val_grid(config_tasks, round_id = "2023-01-02",
        required_vals_only = TRUE, all_character = TRUE, as_arrow_table = TRUE)
    Output
      Table
      28 rows x 5 columns
      $forecast_date <string>
      $horizon <string>
      $location <string>
      $output_type <string>
      $output_type_id <string>

---

    Code
      str(expand_model_out_val_grid(config_tasks, round_id = "2023-01-02",
        required_vals_only = TRUE, all_character = TRUE, as_arrow_table = FALSE,
        bind_model_tasks = FALSE))
    Output
      List of 2
       $ : tibble [5 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : chr [1:5] "2023-01-02" "2023-01-02" "2023-01-02" "2023-01-02" ...
        ..$ horizon       : chr [1:5] "2" "2" "2" "2" ...
        ..$ location      : chr [1:5] "US" "US" "US" "US" ...
        ..$ output_type   : chr [1:5] "pmf" "pmf" "pmf" "pmf" ...
        ..$ output_type_id: chr [1:5] "large_decrease" "decrease" "stable" "increase" ...
       $ : tibble [23 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : chr [1:23] "2023-01-02" "2023-01-02" "2023-01-02" "2023-01-02" ...
        ..$ horizon       : chr [1:23] "2" "2" "2" "2" ...
        ..$ location      : chr [1:23] "US" "US" "US" "US" ...
        ..$ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
        ..$ output_type_id: chr [1:23] "0.01" "0.025" "0.05" "0.1" ...

---

    Code
      expand_model_out_val_grid(config_tasks, round_id = "2023-01-02",
        required_vals_only = TRUE, all_character = TRUE, as_arrow_table = TRUE,
        bind_model_tasks = FALSE)
    Output
      [[1]]
      Table
      5 rows x 5 columns
      $forecast_date <string>
      $horizon <string>
      $location <string>
      $output_type <string>
      $output_type_id <string>
      
      [[2]]
      Table
      23 rows x 5 columns
      $forecast_date <string>
      $horizon <string>
      $location <string>
      $output_type <string>
      $output_type_id <string>
      

# expand_model_out_val_grid errors correctly

    Code
      expand_model_out_val_grid(config_tasks, round_id = "random_round_id")
    Condition
      Error in `hubUtils::get_round_idx()`:
      ! `round_id` must be one of "2022-10-01", "2022-10-08", "2022-10-15", "2022-10-22", or "2022-10-29", not "random_round_id".

---

    Code
      expand_model_out_val_grid(config_tasks)
    Condition
      Error in `hubUtils::get_round_idx()`:
      ! `round_id` must be a character vector, not absent.

---

    Code
      expand_model_out_val_grid(config_tasks)
    Condition
      Error in `hubUtils::get_round_idx()`:
      ! `round_id` must be a character vector, not absent.

