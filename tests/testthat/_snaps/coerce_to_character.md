# coerce_to_hub_schema works

    Code
      str(coerce_to_hub_schema(tbl, config_tasks))
    Output
      tibble [23 x 7] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:23], format: "2022-10-08" "2022-10-08" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
       $ location      : chr [1:23] "US" "US" "US" "US" ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:23] 135 137 139 140 141 141 142 143 144 145 ...

---

    Code
      coerce_to_hub_schema(tbl, config_tasks, as_arrow_table = TRUE)
    Output
      Table
      23 rows x 7 columns
      $origin_date <date32[day]>
      $target <string>
      $horizon <int32>
      $location <string>
      $output_type <string>
      $output_type_id <double>
      $value <int32>

---

    Code
      str(coerce_to_character(tbl))
    Output
      tibble [23 x 7] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : chr [1:23] "2022-10-08" "2022-10-08" "2022-10-08" "2022-10-08" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : chr [1:23] "1" "1" "1" "1" ...
       $ location      : chr [1:23] "US" "US" "US" "US" ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: chr [1:23] "0.01" "0.025" "0.05" "0.1" ...
       $ value         : chr [1:23] "135" "137" "139" "140" ...

---

    Code
      coerce_to_character(tbl, as_arrow_table = TRUE)
    Output
      Table
      23 rows x 7 columns
      $origin_date <string>
      $target <string>
      $horizon <string>
      $location <string>
      $output_type <string>
      $output_type_id <string>
      $value <string>

