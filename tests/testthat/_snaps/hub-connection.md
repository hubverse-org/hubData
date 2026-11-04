# connect_hub returns empty list when model output folder is empty

    Code
      hub_con
    Message
      
      -- <hub_connection/list> --
      
      * hub_name: "Simple Forecast Hub"
      * hub_path: 'test/hub_path'
      * checks: FALSE
      * file_system: "local"
      * model_output_dir: "test/model_output_dir"
      * config_admin: 'hub-config/admin.json'
      * config_tasks: 'hub-config/tasks.json'

---

    Code
      hub_con
    Message
      
      -- <hub_connection/list> --
      
      * hub_name: "Simple Forecast Hub"
      * hub_path: 'test/hub_path'
      * checks: FALSE
      * file_system: "s3"
      * model_output_dir: "test/model_output_dir"
      * config_admin: 'hub-config/admin.json'
      * config_tasks: 'hub-config/tasks.json'

---

    Code
      hub_con
    Message
      
      -- <hub_connection/list> --
      
      * hub_name: "Simple Forecast Hub"
      * hub_path: 'test/hub_path'
      * checks: FALSE
      * file_system: "s3"
      * model_output_dir: "test/model_output_dir"
      * config_admin: 'hub-config/admin.json'
      * config_tasks: 'hub-config/tasks.json'

# connect_hub connection & data extraction works on simple local hub

    Code
      str(dplyr::arrange(out_df, value))
    Output
      tibble [6 x 8] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:6], format: "2023-05-01" "2023-05-01" ...
       $ horizon       : int [1:6] 1 2 1 2 1 2
       $ target        : chr [1:6] "wk ahead inc flu hosp" "wk ahead inc flu hosp" "wk ahead inc flu hosp" "wk ahead inc flu hosp" ...
       $ location      : chr [1:6] "US" "US" "US" "US" ...
       $ output_type   : chr [1:6] "mean" "mean" "mean" "mean" ...
       $ output_type_id: chr [1:6] NA NA NA NA ...
       $ value         : num [1:6] 926 926 945 945 1033 ...
       $ model_id      : chr [1:6] "hub-baseline" "hub-baseline" "hub-baseline" "hub-baseline" ...

# connect_model_output works on local model_output_dir

    Code
      mod_out_con
    Message
      
      -- <mod_out_connection/FileSystemDataset> --
      
      * file_format: "csv(3/3)"
      * checks: TRUE
      * file_system: "LocalFileSystem"
      * model_output_dir: "test/model_output_dir"
      
      -- Connection schema 
    Output
      mod_out_connection with 3 csv files
      8 columns
      origin_date: date32[day]
      target: string
      horizon: int64
      location: string
      output_type: string
      output_type_id: double
      value: int64
      model_id: string

---

    Code
      mod_out_con
    Message
      
      -- <mod_out_connection/FileSystemDataset> --
      
      * file_format: "csv(3/3)"
      * checks: TRUE
      * file_system: "LocalFileSystem"
      * model_output_dir: "test/model_output_dir"
      
      -- Connection schema 
    Output
      mod_out_connection with 3 csv files
      8 columns
      origin_date: date32[day]
      target: string
      horizon: int32
      location: string
      output_type: string
      output_type_id: string
      value: int32
      model_id: string

# connect_model_output fails on empty model_output_dir

    Code
      connect_model_output(mod_out_path)
    Condition
      Error in `connect_model_output()`:
      ! No files of file format "csv" found in model output directory.

---

    Code
      connect_model_output(mod_out_path, file_format = "parquet")
    Condition
      Error in `connect_model_output()`:
      ! No files of file format "parquet" found in model output directory.

---

    Code
      connect_model_output(mod_out_path)
    Condition
      Error in `connect_model_output()`:
      ! No files of file format "csv" found in model output directory.

---

    Code
      connect_model_output(mod_out_path, file_format = "parquet", skip_checks = TRUE)
    Condition
      Error in `connect_model_output()`:
      ! No files of file format "parquet" found in model output directory.

# hub_connection print method works

    Code
      hub_con
    Message
      
      -- <hub_connection/UnionDataset> --
      
      * hub_name: "Simple Forecast Hub"
      * hub_path: 'test/hub_path'
      * file_format: "csv(3/3)" and "parquet(1/1)"
      * checks: FALSE
      * file_system: "LocalFileSystem"
      * model_output_dir: "test/model_output_dir"
      * config_admin: 'hub-config/admin.json'
      * config_tasks: 'hub-config/tasks.json'
      
      -- Connection schema 
    Output
      hub_connection
      9 columns
      origin_date: date32[day]
      target: string
      horizon: int32
      location: string
      output_type: string
      output_type_id: double
      value: int32
      model_id: string
      age_group: string

# mod_out_connection print method works

    Code
      mod_out_con
    Message
      
      -- <mod_out_connection/FileSystemDataset> --
      
      * file_format: "csv(3/3)"
      * checks: TRUE
      * file_system: "LocalFileSystem"
      * model_output_dir: "test/model_output_dir"
      
      -- Connection schema 
    Output
      mod_out_connection with 3 csv files
      8 columns
      origin_date: date32[day]
      target: string
      horizon: int64
      location: string
      output_type: string
      output_type_id: double
      value: int64
      model_id: string

# connect_hub data extraction works on simple forecasting hub

    Code
      str(dplyr::collect(dplyr::filter(hub_con, origin_date == "2022-10-08",
      horizon == 2, output_type_id == 0.01)))
    Output
      tibble [3 x 9] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:3], format: "2022-10-08" "2022-10-08" ...
       $ target        : chr [1:3] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp"
       $ horizon       : int [1:3] 2 2 2
       $ location      : chr [1:3] "US" "04" "01"
       $ output_type   : chr [1:3] "quantile" "quantile" "quantile"
       $ output_type_id: num [1:3] 0.01 0.01 0.01
       $ value         : int [1:3] 135 135 135
       $ model_id      : chr [1:3] "hub-baseline" "hub-baseline" "hub-baseline"
       $ age_group     : chr [1:3] NA NA NA

---

    Code
      str(dplyr::collect(dplyr::filter(hub_con, horizon == 2, age_group == "65+")))
    Output
      tibble [69 x 9] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:69], format: "2022-10-15" "2022-10-15" ...
       $ target        : chr [1:69] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:69] 2 2 2 2 2 2 2 2 2 2 ...
       $ location      : chr [1:69] "US" "US" "US" "US" ...
       $ output_type   : chr [1:69] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:69] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:69] 135 137 139 140 141 141 142 143 144 145 ...
       $ model_id      : chr [1:69] "hub-baseline" "hub-baseline" "hub-baseline" "hub-baseline" ...
       $ age_group     : chr [1:69] "65+" "65+" "65+" "65+" ...

---

    Code
      str(dplyr::collect(dplyr::filter(model_output_con, origin_date == "2022-10-08",
      horizon == 2, output_type_id == 0.01)))
    Output
      tibble [3 x 8] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:3], format: "2022-10-08" "2022-10-08" ...
       $ target        : chr [1:3] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp"
       $ horizon       : int [1:3] 2 2 2
       $ location      : chr [1:3] "US" "04" "01"
       $ output_type   : chr [1:3] "quantile" "quantile" "quantile"
       $ output_type_id: num [1:3] 0.01 0.01 0.01
       $ value         : int [1:3] 135 135 135
       $ model_id      : chr [1:3] "hub-baseline" "hub-baseline" "hub-baseline"

# connect_hub works on S3 bucket simple forecasting hub on AWS

    Code
      str(dplyr::collect(dplyr::filter(hub_con, horizon == 2, age_group == "65+")))
    Output
      tibble [69 x 9] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:69], format: "2022-10-15" "2022-10-15" ...
       $ target        : chr [1:69] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:69] 2 2 2 2 2 2 2 2 2 2 ...
       $ location      : chr [1:69] "US" "US" "US" "US" ...
       $ output_type   : chr [1:69] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:69] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:69] 135 137 139 140 141 141 142 143 144 145 ...
       $ model_id      : chr [1:69] "hub-baseline" "hub-baseline" "hub-baseline" "hub-baseline" ...
       $ age_group     : chr [1:69] "65+" "65+" "65+" "65+" ...

# connect_hub works on S3 bucket simple parquet forecasting hub on AWS

    Code
      str(dplyr::collect(dplyr::filter(hub_con, horizon == 2, age_group == "65+")))
    Output
      tibble [69 x 9] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:69], format: "2022-10-15" "2022-10-15" ...
       $ target        : chr [1:69] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:69] 2 2 2 2 2 2 2 2 2 2 ...
       $ location      : chr [1:69] "US" "US" "US" "US" ...
       $ age_group     : chr [1:69] "65+" "65+" "65+" "65+" ...
       $ output_type   : chr [1:69] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:69] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:69] 135 137 139 140 141 141 142 143 144 145 ...
       $ model_id      : chr [1:69] "hub-baseline" "hub-baseline" "hub-baseline" "hub-baseline" ...

# connect_hub works on parquet-only hub when skip_checks is TRUE

    Code
      hub_con
    Message
      
      -- <hub_connection/FileSystemDataset> --
      
      * hub_name: "Simple Forecast Hub"
      * hub_path: 'test/hub_path'
      * file_format: "parquet(4/4)"
      * checks: FALSE
      * file_system: "LocalFileSystem"
      * model_output_dir: "test/model_output_dir"
      * config_admin: 'hub-config/admin.json'
      * config_tasks: 'hub-config/tasks.json'
      
      -- Connection schema 
    Output
      hub_connection with 4 Parquet files
      9 columns
      origin_date: date32[day]
      target: string
      horizon: int32
      location: string
      age_group: string
      output_type: string
      output_type_id: double
      value: int32
      model_id: string

---

    Code
      str(dplyr::collect(dplyr::filter(hub_con, horizon == 2, age_group == "65+")))
    Output
      tibble [69 x 9] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:69], format: "2022-10-15" "2022-10-15" ...
       $ target        : chr [1:69] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:69] 2 2 2 2 2 2 2 2 2 2 ...
       $ location      : chr [1:69] "US" "US" "US" "US" ...
       $ age_group     : chr [1:69] "65+" "65+" "65+" "65+" ...
       $ output_type   : chr [1:69] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:69] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:69] 135 137 139 140 141 141 142 143 144 145 ...
       $ model_id      : chr [1:69] "hub-baseline" "hub-baseline" "hub-baseline" "hub-baseline" ...

# connect_hub & connect_model_output fail correctly

    Code
      connect_hub("random/hub/path")
    Condition
      Error in `connect_hub()`:
      x Directory 'random/hub/path' does not exist.

---

    Code
      connect_model_output("random/model-output/")
    Condition
      Error in `connect_model_output()`:
      x Directory 'random/model-output/' does not exist.

# connect_hub detects unopenned files correctly

    Code
      connect_hub(hub_path, skip_checks = FALSE)
    Condition
      Warning:
      !  The following potentially invalid model output file not opened successfully.
      'testdata/error_file/model-output/baseline/2022-11-28-baseline.csv'
    Message
      
      -- <hub_connection/FileSystemDataset> --
      
      * hub_name: "Simple Forecast Hub"
      * hub_path: 'testdata/error_file'
      * file_format: "csv(8/9)"
      * checks: TRUE
      * file_system: "LocalFileSystem"
      * model_output_dir: "testdata/error_file/model-output"
      * config_admin: 'hub-config/admin.json'
      * config_tasks: 'hub-config/tasks.json'
      
      -- Connection schema 
    Output
      hub_connection with 8 csv files
      8 columns
      origin_date: date32[day]
      horizon: int32
      location: string
      target: string
      output_type: string
      output_type_id: double
      value: int32
      model_id: string

# connect_hub doesn't validate files when skip_checks is TRUE

    Code
      connect_hub(hub_path, skip_checks = TRUE)
    Message
      
      -- <hub_connection/FileSystemDataset> --
      
      * hub_name: "Simple Forecast Hub"
      * hub_path: 'testdata/error_file'
      * file_format: "csv(9/9)"
      * checks: FALSE
      * file_system: "LocalFileSystem"
      * model_output_dir: "testdata/error_file/model-output"
      * config_admin: 'hub-config/admin.json'
      * config_tasks: 'hub-config/tasks.json'
      
      -- Connection schema 
    Output
      hub_connection with 9 csv files
      8 columns
      origin_date: date32[day]
      horizon: int32
      location: string
      target: string
      output_type: string
      output_type_id: double
      value: int32
      model_id: string

