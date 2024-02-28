# connect_hub works on local simple forecasting hub

    Code
      str(hub_con)
    Output
      Classes 'hub_connection', 'UnionDataset', 'Dataset', 'ArrowObject', 'R6' <hub_connection>
        Inherits from: <UnionDataset>
        Public:
          .:xp:.: externalptr
          .unsafe_delete: function () 
          NewScan: function () 
          ToString: function () 
          WithSchema: function (schema) 
          children: active binding
          class_title: function () 
          clone: function (deep = FALSE) 
          initialize: function (xp) 
          metadata: active binding
          num_cols: active binding
          num_rows: active binding
          pointer: function () 
          print: function (...) 
          schema: active binding
          set_pointer: function (xp) 
          type: active binding 
       - attr(*, "hub_name")= chr "Simple Forecast Hub"
       - attr(*, "file_format")= int [1:2, 1:2] 3 3 1 1
        ..- attr(*, "dimnames")=List of 2
        .. ..$ : chr [1:2] "n_open" "n_in_dir"
        .. ..$ : chr [1:2] "csv" "parquet"
       - attr(*, "file_system")= chr "LocalFileSystem"
       - attr(*, "hub_path")= chr "test/hub_path"
       - attr(*, "model_output_dir")= chr "test/model_output_dir"
       - attr(*, "config_admin")=List of 8
        ..$ schema_version: chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/admin-schema.json"
        ..$ name          : chr "Simple Forecast Hub"
        ..$ maintainer    : chr "Consortium of Infectious Disease Modeling Hubs"
        ..$ contact       :List of 2
        .. ..$ name : chr "Joe Bloggs"
        .. ..$ email: chr "j.bloggs@cidmh.com"
        ..$ repository_url: chr "https://github.com/Infectious-Disease-Modeling-Hubs/example-simple-forecast-hub"
        ..$ hub_models    :List of 1
        .. ..$ :List of 3
        .. .. ..$ team_abbr : chr "simple_hub"
        .. .. ..$ model_abbr: chr "baseline"
        .. .. ..$ model_type: chr "baseline"
        ..$ file_format   : chr [1:3] "csv" "parquet" "arrow"
        ..$ timezone      : chr "US/Eastern"
       - attr(*, "config_tasks")=List of 2
        ..$ schema_version: chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/tasks-schema.json"
        ..$ rounds        :List of 2
        .. ..$ :List of 4
        .. .. ..$ round_id_from_variable: logi TRUE
        .. .. ..$ round_id              : chr "origin_date"
        .. .. ..$ model_tasks           :List of 1
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 4
        .. .. .. .. .. ..$ origin_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:2] "2022-10-01" "2022-10-08"
        .. .. .. .. .. ..$ target     :List of 2
        .. .. .. .. .. .. ..$ required: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. ..$ horizon    :List of 2
        .. .. .. .. .. .. ..$ required: int 1
        .. .. .. .. .. .. ..$ optional: int [1:3] 2 3 4
        .. .. .. .. .. ..$ location   :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:54] "US" "01" "02" "04" ...
        .. .. .. .. ..$ output_type    :List of 2
        .. .. .. .. .. ..$ mean    :List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. .. ..$ optional: logi NA
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. ..$ quantile:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 7
        .. .. .. .. .. .. ..$ target_id    : chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_name  : chr "Weekly incident influenza hospitalizations"
        .. .. .. .. .. .. ..$ target_units : chr "count"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_type  : chr "continuous"
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. ..$ submissions_due       :List of 3
        .. .. .. ..$ relative_to: chr "origin_date"
        .. .. .. ..$ start      : int -6
        .. .. .. ..$ end        : int 1
        .. ..$ :List of 4
        .. .. ..$ round_id_from_variable: logi TRUE
        .. .. ..$ round_id              : chr "origin_date"
        .. .. ..$ model_tasks           :List of 1
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 5
        .. .. .. .. .. ..$ origin_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:3] "2022-10-15" "2022-10-22" "2022-10-29"
        .. .. .. .. .. ..$ target     :List of 2
        .. .. .. .. .. .. ..$ required: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. ..$ horizon    :List of 2
        .. .. .. .. .. .. ..$ required: int 1
        .. .. .. .. .. .. ..$ optional: int [1:3] 2 3 4
        .. .. .. .. .. ..$ location   :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:54] "US" "01" "02" "04" ...
        .. .. .. .. .. ..$ age_group  :List of 2
        .. .. .. .. .. .. ..$ required: chr "65+"
        .. .. .. .. .. .. ..$ optional: chr [1:4] "0-5" "6-18" "19-24" "25-64"
        .. .. .. .. ..$ output_type    :List of 2
        .. .. .. .. .. ..$ mean    :List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. .. ..$ optional: logi NA
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. ..$ quantile:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 7
        .. .. .. .. .. .. ..$ target_id    : chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_name  : chr "Weekly incident influenza hospitalizations"
        .. .. .. .. .. .. ..$ target_units : chr "count"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_type  : chr "continuous"
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. ..$ submissions_due       :List of 3
        .. .. .. ..$ relative_to: chr "origin_date"
        .. .. .. ..$ start      : int -6
        .. .. .. ..$ end        : int 1

# connect_hub works on a local simple forecasting hub with no csvs

    Code
      str(hub_con)
    Output
      Classes 'hub_connection', 'FileSystemDataset', 'Dataset', 'ArrowObject', 'R6' <hub_connection>
        Inherits from: <FileSystemDataset>
        Public:
          .:xp:.: externalptr
          .class_title: function () 
          .unsafe_delete: function () 
          NewScan: function () 
          ToString: function () 
          WithSchema: function (schema) 
          class_title: function () 
          clone: function (deep = FALSE) 
          files: active binding
          filesystem: active binding
          format: active binding
          initialize: function (xp) 
          metadata: active binding
          num_cols: active binding
          num_rows: active binding
          pointer: function () 
          print: function (...) 
          schema: active binding
          set_pointer: function (xp) 
          type: active binding 
       - attr(*, "hub_name")= chr "Simple Forecast Hub"
       - attr(*, "file_format")= int [1:2, 1] 4 4
        ..- attr(*, "dimnames")=List of 2
        .. ..$ : chr [1:2] "n_open" "n_in_dir"
        .. ..$ : chr "parquet"
       - attr(*, "file_system")= chr "LocalFileSystem"
       - attr(*, "hub_path")= chr "test/hub_path"
       - attr(*, "model_output_dir")= chr "test/model_output_dir"
       - attr(*, "config_admin")=List of 8
        ..$ schema_version: chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/admin-schema.json"
        ..$ name          : chr "Simple Forecast Hub"
        ..$ maintainer    : chr "Consortium of Infectious Disease Modeling Hubs"
        ..$ contact       :List of 2
        .. ..$ name : chr "Joe Bloggs"
        .. ..$ email: chr "j.bloggs@cidmh.com"
        ..$ repository_url: chr "https://github.com/Infectious-Disease-Modeling-Hubs/example-simple-forecast-hub"
        ..$ hub_models    :List of 1
        .. ..$ :List of 3
        .. .. ..$ team_abbr : chr "simple_hub"
        .. .. ..$ model_abbr: chr "baseline"
        .. .. ..$ model_type: chr "baseline"
        ..$ file_format   : chr [1:3] "csv" "parquet" "arrow"
        ..$ timezone      : chr "US/Eastern"
       - attr(*, "config_tasks")=List of 2
        ..$ schema_version: chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/tasks-schema.json"
        ..$ rounds        :List of 2
        .. ..$ :List of 4
        .. .. ..$ round_id_from_variable: logi TRUE
        .. .. ..$ round_id              : chr "origin_date"
        .. .. ..$ model_tasks           :List of 1
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 4
        .. .. .. .. .. ..$ origin_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:2] "2022-10-01" "2022-10-08"
        .. .. .. .. .. ..$ target     :List of 2
        .. .. .. .. .. .. ..$ required: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. ..$ horizon    :List of 2
        .. .. .. .. .. .. ..$ required: int 1
        .. .. .. .. .. .. ..$ optional: int [1:3] 2 3 4
        .. .. .. .. .. ..$ location   :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:54] "US" "01" "02" "04" ...
        .. .. .. .. ..$ output_type    :List of 2
        .. .. .. .. .. ..$ mean    :List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. .. ..$ optional: logi NA
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. ..$ quantile:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 7
        .. .. .. .. .. .. ..$ target_id    : chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_name  : chr "Weekly incident influenza hospitalizations"
        .. .. .. .. .. .. ..$ target_units : chr "count"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_type  : chr "continuous"
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. ..$ submissions_due       :List of 3
        .. .. .. ..$ relative_to: chr "origin_date"
        .. .. .. ..$ start      : int -6
        .. .. .. ..$ end        : int 1
        .. ..$ :List of 4
        .. .. ..$ round_id_from_variable: logi TRUE
        .. .. ..$ round_id              : chr "origin_date"
        .. .. ..$ model_tasks           :List of 1
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 5
        .. .. .. .. .. ..$ origin_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:3] "2022-10-15" "2022-10-22" "2022-10-29"
        .. .. .. .. .. ..$ target     :List of 2
        .. .. .. .. .. .. ..$ required: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. ..$ horizon    :List of 2
        .. .. .. .. .. .. ..$ required: int 1
        .. .. .. .. .. .. ..$ optional: int [1:3] 2 3 4
        .. .. .. .. .. ..$ location   :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:54] "US" "01" "02" "04" ...
        .. .. .. .. .. ..$ age_group  :List of 2
        .. .. .. .. .. .. ..$ required: chr "65+"
        .. .. .. .. .. .. ..$ optional: chr [1:4] "0-5" "6-18" "19-24" "25-64"
        .. .. .. .. ..$ output_type    :List of 2
        .. .. .. .. .. ..$ mean    :List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. .. ..$ optional: logi NA
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. ..$ quantile:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 7
        .. .. .. .. .. .. ..$ target_id    : chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_name  : chr "Weekly incident influenza hospitalizations"
        .. .. .. .. .. .. ..$ target_units : chr "count"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_type  : chr "continuous"
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. ..$ submissions_due       :List of 3
        .. .. .. ..$ relative_to: chr "origin_date"
        .. .. .. ..$ start      : int -6
        .. .. .. ..$ end        : int 1

# connect_hub returns empty list when model output folder is empty

    Code
      hub_con
    Message
      
      -- <hub_connection/list> --
      
      * hub_name: "Simple Forecast Hub"
      * hub_path: 'test/hub_path'
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
      * file_system: "s3"
      * model_output_dir: "test/model_output_dir"
      * config_admin: 'hub-config/admin.json'
      * config_tasks: 'hub-config/tasks.json'

# connect_hub connection & data extraction works on simple local hub

    Code
      str(hub_con)
    Output
      Classes 'hub_connection', 'UnionDataset', 'Dataset', 'ArrowObject', 'R6' <hub_connection>
        Inherits from: <UnionDataset>
        Public:
          .:xp:.: externalptr
          .unsafe_delete: function () 
          NewScan: function () 
          ToString: function () 
          WithSchema: function (schema) 
          children: active binding
          class_title: function () 
          clone: function (deep = FALSE) 
          initialize: function (xp) 
          metadata: active binding
          num_cols: active binding
          num_rows: active binding
          pointer: function () 
          print: function (...) 
          schema: active binding
          set_pointer: function (xp) 
          type: active binding 
       - attr(*, "hub_name")= chr "US CDC FluSight"
       - attr(*, "file_format")= int [1:2, 1:3] 5 5 2 2 1 1
        ..- attr(*, "dimnames")=List of 2
        .. ..$ : chr [1:2] "n_open" "n_in_dir"
        .. ..$ : chr [1:3] "csv" "parquet" "arrow"
       - attr(*, "file_system")= chr "LocalFileSystem"
       - attr(*, "hub_path")= chr "flusight"
       - attr(*, "model_output_dir")= chr "forecasts"
       - attr(*, "config_admin")=List of 9
        ..$ schema_version  : chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/admin-schema.json"
        ..$ name            : chr "US CDC FluSight"
        ..$ maintainer      : chr "US CDC"
        ..$ contact         :List of 2
        .. ..$ name : chr "Joe Bloggs"
        .. ..$ email: chr "joe.blogs@cdc.gov"
        ..$ repository_host : chr "GitHub"
        ..$ repository_url  : chr "https://github.com/cdcepi/Flusight-forecast-data"
        ..$ file_format     : chr [1:3] "csv" "parquet" "arrow"
        ..$ timezone        : chr "US/Eastern"
        ..$ model_output_dir: chr "forecasts"
       - attr(*, "config_tasks")=List of 2
        ..$ schema_version: chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/tasks-schema.json"
        ..$ rounds        :List of 1
        .. ..$ :List of 4
        .. .. ..$ round_id_from_variable: logi TRUE
        .. .. ..$ round_id              : chr "forecast_date"
        .. .. ..$ model_tasks           :List of 2
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 4
        .. .. .. .. .. ..$ forecast_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:23] "2022-12-12" "2022-12-19" "2022-12-26" "2023-01-02" ...
        .. .. .. .. .. ..$ target       :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr "wk flu hosp rate change"
        .. .. .. .. .. ..$ horizon      :List of 2
        .. .. .. .. .. .. ..$ required: int 2
        .. .. .. .. .. .. ..$ optional: int 1
        .. .. .. .. .. ..$ location     :List of 2
        .. .. .. .. .. .. ..$ required: chr "US"
        .. .. .. .. .. .. ..$ optional: chr [1:53] "01" "02" "04" "05" ...
        .. .. .. .. ..$ output_type    :List of 1
        .. .. .. .. .. ..$ pmf:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: chr [1:5] "large_decrease" "decrease" "stable" "increase" ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 3
        .. .. .. .. .. .. .. ..$ type   : chr "double"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. .. .. ..$ maximum: int 1
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 8
        .. .. .. .. .. .. ..$ target_id    : chr "wk flu hosp rate change"
        .. .. .. .. .. .. ..$ target_name  : chr "weekly influenza hospitalization rate change"
        .. .. .. .. .. .. ..$ target_units : chr "rate per 100,000 population"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk flu hosp rate change"
        .. .. .. .. .. .. ..$ target_type  : chr "nominal"
        .. .. .. .. .. .. ..$ description  : chr "This target represents the change in the rate of new hospitalizations per week comparing the week ending two da"| __truncated__
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 4
        .. .. .. .. .. ..$ forecast_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:23] "2022-12-12" "2022-12-19" "2022-12-26" "2023-01-02" ...
        .. .. .. .. .. ..$ target       :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr "wk ahead inc flu hosp"
        .. .. .. .. .. ..$ horizon      :List of 2
        .. .. .. .. .. .. ..$ required: int 2
        .. .. .. .. .. .. ..$ optional: int 1
        .. .. .. .. .. ..$ location     :List of 2
        .. .. .. .. .. .. ..$ required: chr "US"
        .. .. .. .. .. .. ..$ optional: chr [1:53] "01" "02" "04" "05" ...
        .. .. .. .. ..$ output_type    :List of 2
        .. .. .. .. .. ..$ quantile:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. ..$ mean    :List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. .. ..$ optional: logi NA
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "double"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 8
        .. .. .. .. .. .. ..$ target_id    : chr "wk ahead inc flu hosp"
        .. .. .. .. .. .. ..$ target_name  : chr "weekly influenza hospitalization incidence"
        .. .. .. .. .. .. ..$ target_units : chr "rate per 100,000 population"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk ahead inc flu hosp"
        .. .. .. .. .. .. ..$ target_type  : chr "discrete"
        .. .. .. .. .. .. ..$ description  : chr "This target represents the counts of new hospitalizations per horizon week."
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. ..$ submissions_due       :List of 3
        .. .. .. ..$ relative_to: chr "forecast_date"
        .. .. .. ..$ start      : int -6
        .. .. .. ..$ end        : int 2

---

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

# connect_hub works on local flusight forecasting hub

    Code
      str(hub_con)
    Output
      Classes 'hub_connection', 'UnionDataset', 'Dataset', 'ArrowObject', 'R6' <hub_connection>
        Inherits from: <UnionDataset>
        Public:
          .:xp:.: externalptr
          .unsafe_delete: function () 
          NewScan: function () 
          ToString: function () 
          WithSchema: function (schema) 
          children: active binding
          class_title: function () 
          clone: function (deep = FALSE) 
          initialize: function (xp) 
          metadata: active binding
          num_cols: active binding
          num_rows: active binding
          pointer: function () 
          print: function (...) 
          schema: active binding
          set_pointer: function (xp) 
          type: active binding 
       - attr(*, "hub_name")= chr "US CDC FluSight"
       - attr(*, "file_format")= int [1:2, 1:3] 5 5 2 2 1 1
        ..- attr(*, "dimnames")=List of 2
        .. ..$ : chr [1:2] "n_open" "n_in_dir"
        .. ..$ : chr [1:3] "csv" "parquet" "arrow"
       - attr(*, "file_system")= chr "LocalFileSystem"
       - attr(*, "hub_path")= chr "test/hub_path"
       - attr(*, "model_output_dir")= chr "test/model_output_dir"
       - attr(*, "config_admin")=List of 9
        ..$ schema_version  : chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/admin-schema.json"
        ..$ name            : chr "US CDC FluSight"
        ..$ maintainer      : chr "US CDC"
        ..$ contact         :List of 2
        .. ..$ name : chr "Joe Bloggs"
        .. ..$ email: chr "joe.blogs@cdc.gov"
        ..$ repository_host : chr "GitHub"
        ..$ repository_url  : chr "https://github.com/cdcepi/Flusight-forecast-data"
        ..$ file_format     : chr [1:3] "csv" "parquet" "arrow"
        ..$ timezone        : chr "US/Eastern"
        ..$ model_output_dir: chr "forecasts"
       - attr(*, "config_tasks")=List of 2
        ..$ schema_version: chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/tasks-schema.json"
        ..$ rounds        :List of 1
        .. ..$ :List of 4
        .. .. ..$ round_id_from_variable: logi TRUE
        .. .. ..$ round_id              : chr "forecast_date"
        .. .. ..$ model_tasks           :List of 2
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 4
        .. .. .. .. .. ..$ forecast_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:23] "2022-12-12" "2022-12-19" "2022-12-26" "2023-01-02" ...
        .. .. .. .. .. ..$ target       :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr "wk flu hosp rate change"
        .. .. .. .. .. ..$ horizon      :List of 2
        .. .. .. .. .. .. ..$ required: int 2
        .. .. .. .. .. .. ..$ optional: int 1
        .. .. .. .. .. ..$ location     :List of 2
        .. .. .. .. .. .. ..$ required: chr "US"
        .. .. .. .. .. .. ..$ optional: chr [1:53] "01" "02" "04" "05" ...
        .. .. .. .. ..$ output_type    :List of 1
        .. .. .. .. .. ..$ pmf:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: chr [1:5] "large_decrease" "decrease" "stable" "increase" ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 3
        .. .. .. .. .. .. .. ..$ type   : chr "double"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. .. .. ..$ maximum: int 1
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 8
        .. .. .. .. .. .. ..$ target_id    : chr "wk flu hosp rate change"
        .. .. .. .. .. .. ..$ target_name  : chr "weekly influenza hospitalization rate change"
        .. .. .. .. .. .. ..$ target_units : chr "rate per 100,000 population"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk flu hosp rate change"
        .. .. .. .. .. .. ..$ target_type  : chr "nominal"
        .. .. .. .. .. .. ..$ description  : chr "This target represents the change in the rate of new hospitalizations per week comparing the week ending two da"| __truncated__
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 4
        .. .. .. .. .. ..$ forecast_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:23] "2022-12-12" "2022-12-19" "2022-12-26" "2023-01-02" ...
        .. .. .. .. .. ..$ target       :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr "wk ahead inc flu hosp"
        .. .. .. .. .. ..$ horizon      :List of 2
        .. .. .. .. .. .. ..$ required: int 2
        .. .. .. .. .. .. ..$ optional: int 1
        .. .. .. .. .. ..$ location     :List of 2
        .. .. .. .. .. .. ..$ required: chr "US"
        .. .. .. .. .. .. ..$ optional: chr [1:53] "01" "02" "04" "05" ...
        .. .. .. .. ..$ output_type    :List of 2
        .. .. .. .. .. ..$ quantile:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. ..$ mean    :List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. .. ..$ optional: logi NA
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "double"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 8
        .. .. .. .. .. .. ..$ target_id    : chr "wk ahead inc flu hosp"
        .. .. .. .. .. .. ..$ target_name  : chr "weekly influenza hospitalization incidence"
        .. .. .. .. .. .. ..$ target_units : chr "rate per 100,000 population"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk ahead inc flu hosp"
        .. .. .. .. .. .. ..$ target_type  : chr "discrete"
        .. .. .. .. .. .. ..$ description  : chr "This target represents the counts of new hospitalizations per horizon week."
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. ..$ submissions_due       :List of 3
        .. .. .. ..$ relative_to: chr "forecast_date"
        .. .. .. ..$ start      : int -6
        .. .. .. ..$ end        : int 2

# connect_model_output works on local model_output_dir

    Code
      mod_out_con
    Message
      
      -- <mod_out_connection/FileSystemDataset> --
      
      * file_format: "csv(3/3)"
      * file_system: "LocalFileSystem"
      * model_output_dir: "test/model_output_dir"
      
      -- Connection schema 
    Output
      mod_out_connection with 3 csv files
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
      str(mod_out_con)
    Output
      Classes 'mod_out_connection', 'FileSystemDataset', 'Dataset', 'ArrowObject', 'R6' <mod_out_connection>
        Inherits from: <FileSystemDataset>
        Public:
          .:xp:.: externalptr
          .class_title: function () 
          .unsafe_delete: function () 
          NewScan: function () 
          ToString: function () 
          WithSchema: function (schema) 
          class_title: function () 
          clone: function (deep = FALSE) 
          files: active binding
          filesystem: active binding
          format: active binding
          initialize: function (xp) 
          metadata: active binding
          num_cols: active binding
          num_rows: active binding
          pointer: function () 
          print: function (...) 
          schema: active binding
          set_pointer: function (xp) 
          type: active binding 
       - attr(*, "file_format")= int [1:2, 1] 3 3
        ..- attr(*, "dimnames")=List of 2
        .. ..$ : chr [1:2] "n_open" "n_in_dir"
        .. ..$ : chr "csv"
       - attr(*, "file_system")= chr "LocalFileSystem"
       - attr(*, "model_output_dir")= chr "test/model_output_dir"

---

    Code
      mod_out_con
    Message
      
      -- <mod_out_connection/FileSystemDataset> --
      
      * file_format: "csv(3/3)"
      * file_system: "LocalFileSystem"
      * model_output_dir: "test/model_output_dir"
      
      -- Connection schema 
    Output
      mod_out_connection with 3 csv files
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

# hub_connection print method works

    Code
      hub_con
    Message
      
      -- <hub_connection/UnionDataset> --
      
      * hub_name: "Simple Forecast Hub"
      * hub_path: 'test/hub_path'
      * file_format: "csv(3/3)" and "parquet(1/1)"
      * file_system: "LocalFileSystem"
      * model_output_dir: "test/model_output_dir"
      * config_admin: 'hub-config/admin.json'
      * config_tasks: 'hub-config/tasks.json'
      
      -- Connection schema 
    Output
      hub_connection
      origin_date: date32[day]
      target: string
      horizon: int32
      location: string
      output_type: string
      output_type_id: double
      value: int32
      model_id: string
      age_group: string

---

    Code
      print(hub_con, verbose = TRUE)
    Message
      
      -- <hub_connection/UnionDataset> --
      
      * hub_name: "Simple Forecast Hub"
      * hub_path: 'test/hub_path'
      * file_format: "csv(3/3)" and "parquet(1/1)"
      * file_system: "LocalFileSystem"
      * model_output_dir: "test/model_output_dir"
      * config_admin: 'hub-config/admin.json'
      * config_tasks: 'hub-config/tasks.json'
      
      -- Connection schema 
    Output
      hub_connection
      origin_date: date32[day]
      target: string
      horizon: int32
      location: string
      output_type: string
      output_type_id: double
      value: int32
      model_id: string
      age_group: string
      Classes 'hub_connection', 'UnionDataset', 'Dataset', 'ArrowObject', 'R6' <hub_connection>
        Inherits from: <UnionDataset>
        Public:
          .:xp:.: externalptr
          .unsafe_delete: function () 
          NewScan: function () 
          ToString: function () 
          WithSchema: function (schema) 
          children: active binding
          class_title: function () 
          clone: function (deep = FALSE) 
          initialize: function (xp) 
          metadata: active binding
          num_cols: active binding
          num_rows: active binding
          pointer: function () 
          print: function (...) 
          schema: active binding
          set_pointer: function (xp) 
          type: active binding 
       - attr(*, "hub_name")= chr "Simple Forecast Hub"
       - attr(*, "file_format")= int [1:2, 1:2] 3 3 1 1
        ..- attr(*, "dimnames")=List of 2
        .. ..$ : chr [1:2] "n_open" "n_in_dir"
        .. ..$ : chr [1:2] "csv" "parquet"
       - attr(*, "file_system")= chr "LocalFileSystem"
       - attr(*, "hub_path")= chr "test/hub_path"
       - attr(*, "model_output_dir")= chr "test/model_output_dir"
       - attr(*, "config_admin")=List of 8
        ..$ schema_version: chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/admin-schema.json"
        ..$ name          : chr "Simple Forecast Hub"
        ..$ maintainer    : chr "Consortium of Infectious Disease Modeling Hubs"
        ..$ contact       :List of 2
        .. ..$ name : chr "Joe Bloggs"
        .. ..$ email: chr "j.bloggs@cidmh.com"
        ..$ repository_url: chr "https://github.com/Infectious-Disease-Modeling-Hubs/example-simple-forecast-hub"
        ..$ hub_models    :List of 1
        .. ..$ :List of 3
        .. .. ..$ team_abbr : chr "simple_hub"
        .. .. ..$ model_abbr: chr "baseline"
        .. .. ..$ model_type: chr "baseline"
        ..$ file_format   : chr [1:3] "csv" "parquet" "arrow"
        ..$ timezone      : chr "US/Eastern"
       - attr(*, "config_tasks")=List of 2
        ..$ schema_version: chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/tasks-schema.json"
        ..$ rounds        :List of 2
        .. ..$ :List of 4
        .. .. ..$ round_id_from_variable: logi TRUE
        .. .. ..$ round_id              : chr "origin_date"
        .. .. ..$ model_tasks           :List of 1
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 4
        .. .. .. .. .. ..$ origin_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:2] "2022-10-01" "2022-10-08"
        .. .. .. .. .. ..$ target     :List of 2
        .. .. .. .. .. .. ..$ required: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. ..$ horizon    :List of 2
        .. .. .. .. .. .. ..$ required: int 1
        .. .. .. .. .. .. ..$ optional: int [1:3] 2 3 4
        .. .. .. .. .. ..$ location   :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:54] "US" "01" "02" "04" ...
        .. .. .. .. ..$ output_type    :List of 2
        .. .. .. .. .. ..$ mean    :List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. .. ..$ optional: logi NA
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. ..$ quantile:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 7
        .. .. .. .. .. .. ..$ target_id    : chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_name  : chr "Weekly incident influenza hospitalizations"
        .. .. .. .. .. .. ..$ target_units : chr "count"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_type  : chr "continuous"
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. ..$ submissions_due       :List of 3
        .. .. .. ..$ relative_to: chr "origin_date"
        .. .. .. ..$ start      : int -6
        .. .. .. ..$ end        : int 1
        .. ..$ :List of 4
        .. .. ..$ round_id_from_variable: logi TRUE
        .. .. ..$ round_id              : chr "origin_date"
        .. .. ..$ model_tasks           :List of 1
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 5
        .. .. .. .. .. ..$ origin_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:3] "2022-10-15" "2022-10-22" "2022-10-29"
        .. .. .. .. .. ..$ target     :List of 2
        .. .. .. .. .. .. ..$ required: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. ..$ horizon    :List of 2
        .. .. .. .. .. .. ..$ required: int 1
        .. .. .. .. .. .. ..$ optional: int [1:3] 2 3 4
        .. .. .. .. .. ..$ location   :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:54] "US" "01" "02" "04" ...
        .. .. .. .. .. ..$ age_group  :List of 2
        .. .. .. .. .. .. ..$ required: chr "65+"
        .. .. .. .. .. .. ..$ optional: chr [1:4] "0-5" "6-18" "19-24" "25-64"
        .. .. .. .. ..$ output_type    :List of 2
        .. .. .. .. .. ..$ mean    :List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. .. ..$ optional: logi NA
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. ..$ quantile:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 7
        .. .. .. .. .. .. ..$ target_id    : chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_name  : chr "Weekly incident influenza hospitalizations"
        .. .. .. .. .. .. ..$ target_units : chr "count"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_type  : chr "continuous"
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. ..$ submissions_due       :List of 3
        .. .. .. ..$ relative_to: chr "origin_date"
        .. .. .. ..$ start      : int -6
        .. .. .. ..$ end        : int 1

# mod_out_connection print method works

    Code
      mod_out_con
    Message
      
      -- <mod_out_connection/FileSystemDataset> --
      
      * file_format: "csv(3/3)"
      * file_system: "LocalFileSystem"
      * model_output_dir: "test/model_output_dir"
      
      -- Connection schema 
    Output
      mod_out_connection with 3 csv files
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
      hub_con %>% dplyr::filter(origin_date == "2022-10-08", horizon == 2,
      output_type_id == 0.01) %>% dplyr::collect() %>% str()
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
      hub_con %>% dplyr::filter(horizon == 2, age_group == "65+") %>% dplyr::collect() %>%
        str()
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
      model_output_con %>% dplyr::filter(origin_date == "2022-10-08", horizon == 2,
      output_type_id == 0.01) %>% dplyr::collect() %>% str()
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
      str(hub_con)
    Output
      Classes 'hub_connection', 'UnionDataset', 'Dataset', 'ArrowObject', 'R6' <hub_connection>
        Inherits from: <UnionDataset>
        Public:
          .:xp:.: externalptr
          .unsafe_delete: function () 
          NewScan: function () 
          ToString: function () 
          WithSchema: function (schema) 
          children: active binding
          class_title: function () 
          clone: function (deep = FALSE) 
          initialize: function (xp) 
          metadata: active binding
          num_cols: active binding
          num_rows: active binding
          pointer: function () 
          print: function (...) 
          schema: active binding
          set_pointer: function (xp) 
          type: active binding 
       - attr(*, "hub_name")= chr "Simple Forecast Hub"
       - attr(*, "file_format")= int [1:2, 1:2] 3 3 1 1
        ..- attr(*, "dimnames")=List of 2
        .. ..$ : chr [1:2] "n_open" "n_in_dir"
        .. ..$ : chr [1:2] "csv" "parquet"
       - attr(*, "file_system")= chr "S3FileSystem"
       - attr(*, "hub_path")= chr "test/hub_path"
       - attr(*, "model_output_dir")= chr "test/model_output_dir"
       - attr(*, "config_admin")=List of 8
        ..$ schema_version: chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/admin-schema.json"
        ..$ name          : chr "Simple Forecast Hub"
        ..$ maintainer    : chr "Consortium of Infectious Disease Modeling Hubs"
        ..$ contact       :List of 2
        .. ..$ name : chr "Joe Bloggs"
        .. ..$ email: chr "j.bloggs@cidmh.com"
        ..$ repository_url: chr "https://github.com/Infectious-Disease-Modeling-Hubs/example-simple-forecast-hub"
        ..$ hub_models    :List of 1
        .. ..$ :List of 3
        .. .. ..$ team_abbr : chr "simple_hub"
        .. .. ..$ model_abbr: chr "baseline"
        .. .. ..$ model_type: chr "baseline"
        ..$ file_format   : chr [1:3] "csv" "parquet" "arrow"
        ..$ timezone      : chr "US/Eastern"
       - attr(*, "config_tasks")=List of 2
        ..$ schema_version: chr "https://raw.githubusercontent.com/Infectious-Disease-Modeling-Hubs/schemas/main/v2.0.0/tasks-schema.json"
        ..$ rounds        :List of 2
        .. ..$ :List of 4
        .. .. ..$ round_id_from_variable: logi TRUE
        .. .. ..$ round_id              : chr "origin_date"
        .. .. ..$ model_tasks           :List of 1
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 4
        .. .. .. .. .. ..$ origin_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:2] "2022-10-01" "2022-10-08"
        .. .. .. .. .. ..$ target     :List of 2
        .. .. .. .. .. .. ..$ required: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. ..$ horizon    :List of 2
        .. .. .. .. .. .. ..$ required: int 1
        .. .. .. .. .. .. ..$ optional: int [1:3] 2 3 4
        .. .. .. .. .. ..$ location   :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:54] "US" "01" "02" "04" ...
        .. .. .. .. ..$ output_type    :List of 2
        .. .. .. .. .. ..$ mean    :List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. .. ..$ optional: logi NA
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. ..$ quantile:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 7
        .. .. .. .. .. .. ..$ target_id    : chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_name  : chr "Weekly incident influenza hospitalizations"
        .. .. .. .. .. .. ..$ target_units : chr "count"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_type  : chr "continuous"
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. ..$ submissions_due       :List of 3
        .. .. .. ..$ relative_to: chr "origin_date"
        .. .. .. ..$ start      : int -6
        .. .. .. ..$ end        : int 1
        .. ..$ :List of 4
        .. .. ..$ round_id_from_variable: logi TRUE
        .. .. ..$ round_id              : chr "origin_date"
        .. .. ..$ model_tasks           :List of 1
        .. .. .. ..$ :List of 3
        .. .. .. .. ..$ task_ids       :List of 5
        .. .. .. .. .. ..$ origin_date:List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:3] "2022-10-15" "2022-10-22" "2022-10-29"
        .. .. .. .. .. ..$ target     :List of 2
        .. .. .. .. .. .. ..$ required: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. ..$ horizon    :List of 2
        .. .. .. .. .. .. ..$ required: int 1
        .. .. .. .. .. .. ..$ optional: int [1:3] 2 3 4
        .. .. .. .. .. ..$ location   :List of 2
        .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. ..$ optional: chr [1:54] "US" "01" "02" "04" ...
        .. .. .. .. .. ..$ age_group  :List of 2
        .. .. .. .. .. .. ..$ required: chr "65+"
        .. .. .. .. .. .. ..$ optional: chr [1:4] "0-5" "6-18" "19-24" "25-64"
        .. .. .. .. ..$ output_type    :List of 2
        .. .. .. .. .. ..$ mean    :List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: NULL
        .. .. .. .. .. .. .. ..$ optional: logi NA
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. .. ..$ quantile:List of 2
        .. .. .. .. .. .. ..$ output_type_id:List of 2
        .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
        .. .. .. .. .. .. .. ..$ optional: NULL
        .. .. .. .. .. .. ..$ value         :List of 2
        .. .. .. .. .. .. .. ..$ type   : chr "integer"
        .. .. .. .. .. .. .. ..$ minimum: int 0
        .. .. .. .. ..$ target_metadata:List of 1
        .. .. .. .. .. ..$ :List of 7
        .. .. .. .. .. .. ..$ target_id    : chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_name  : chr "Weekly incident influenza hospitalizations"
        .. .. .. .. .. .. ..$ target_units : chr "count"
        .. .. .. .. .. .. ..$ target_keys  :List of 1
        .. .. .. .. .. .. .. ..$ target: chr "wk inc flu hosp"
        .. .. .. .. .. .. ..$ target_type  : chr "continuous"
        .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
        .. .. .. .. .. .. ..$ time_unit    : chr "week"
        .. .. ..$ submissions_due       :List of 3
        .. .. .. ..$ relative_to: chr "origin_date"
        .. .. .. ..$ start      : int -6
        .. .. .. ..$ end        : int 1

---

    Code
      hub_con %>% dplyr::filter(horizon == 2, age_group == "65+") %>% dplyr::collect() %>%
        str()
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

---

    Code
      connect_hub(temp_dir)
    Condition
      Error in `connect_hub()`:
      x 'hub-config' directory not found in root of Hub.

