# column renaming works

    Code
      str(as_model_out_tbl(x, output_type_col = output_type_col))
    Output
      mdl_t_tb [92 x 8] (S3: model_out_tbl/tbl_df/tbl/data.frame)
       $ model_id      : chr [1:92] "hub-baseline" "hub-baseline" "hub-baseline" "hub-baseline" ...
       $ forecast_date : Date[1:92], format: "2023-05-08" "2023-05-08" ...
       $ horizon       : int [1:92] 1 1 1 1 1 1 1 1 1 1 ...
       $ target        : chr [1:92] "wk ahead inc flu hosp" "wk ahead inc flu hosp" "wk ahead inc flu hosp" "wk ahead inc flu hosp" ...
       $ location      : chr [1:92] "US" "US" "US" "US" ...
       $ output_type   : chr [1:92] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: chr [1:92] "0.01" "0.025" "0.05" "0.1" ...
       $ value         : num [1:92] 0 0 0 231 517 637 741 796 847 876 ...

---

    Code
      as_model_out_tbl(x, output_type_col = output_type_col)
    Condition
      Error in `as_model_out_tbl()`:
      x `output_type_col` value "output_type_rename_error" not a valid column name in `x`
      ! Must be one of "forecast_date", "horizon", "target", "location", "output_type_rename", "output_type_id", "value", and "model_id"

# triming to task ids works

    Code
      names(as_model_out_tbl(tbl, trim_to_task_ids = TRUE, hub_con = hub_con))
    Message
      ! `task_id_cols` value "location" not a valid `tbl` column name. Ignored.
    Output
      [1] "model_id"       "forecast_date"  "target"         "horizon"       
      [5] "output_type"    "output_type_id" "value"         

# validating model_out_tbl std column datatypes works

    Code
      as_model_out_tbl(tbl)
    Condition
      Error in `validate_model_out_tbl()`:
      x Wrong datatypes detected in standard columns:
      ! Column `output_type` should be one of <character/factor>, not <integer>.
      ! Column `value` should be <numeric>, not <character>.

