# Print a `<hub_connection>` or `<mod_out_connection>` S3 class object

Print a `<hub_connection>` or `<mod_out_connection>` S3 class object

## Usage

``` r
# S3 method for class 'hub_connection'
print(x, verbose = FALSE, ...)

# S3 method for class 'mod_out_connection'
print(x, verbose = FALSE, ...)
```

## Arguments

- x:

  A `<hub_connection>` or `<mod_out_connection>` S3 class object.

- verbose:

  Logical. Whether to print the full structure of the object. Defaults
  to `FALSE`.

- ...:

  Further arguments passed to or from other methods.

## Functions

- `print(hub_connection)`: print a `<hub_connection>` object.

- `print(mod_out_connection)`: print a `<mod_out_connection>` object.

## Examples

``` r
hub_path <- system.file("testhubs/simple", package = "hubUtils")
hub_con <- connect_hub(hub_path)
hub_con
#> 
#> ── <hub_connection/UnionDataset> ──
#> 
#> • hub_name: "Simple Forecast Hub"
#> • hub_path: /home/runner/work/_temp/Library/hubUtils/testhubs/simple
#> • file_format: "csv(3/3)" and "parquet(1/1)"
#> • checks: TRUE
#> • file_system: "LocalFileSystem"
#> • model_output_dir:
#>   "/home/runner/work/_temp/Library/hubUtils/testhubs/simple/model-output"
#> • config_admin: hub-config/admin.json
#> • config_tasks: hub-config/tasks.json
#> 
#> ── Connection schema 
#> hub_connection
#> 9 columns
#> origin_date: date32[day]
#> target: string
#> horizon: int32
#> location: string
#> output_type: string
#> output_type_id: double
#> value: int32
#> model_id: string
#> age_group: string
print(hub_con)
#> 
#> ── <hub_connection/UnionDataset> ──
#> 
#> • hub_name: "Simple Forecast Hub"
#> • hub_path: /home/runner/work/_temp/Library/hubUtils/testhubs/simple
#> • file_format: "csv(3/3)" and "parquet(1/1)"
#> • checks: TRUE
#> • file_system: "LocalFileSystem"
#> • model_output_dir:
#>   "/home/runner/work/_temp/Library/hubUtils/testhubs/simple/model-output"
#> • config_admin: hub-config/admin.json
#> • config_tasks: hub-config/tasks.json
#> 
#> ── Connection schema 
#> hub_connection
#> 9 columns
#> origin_date: date32[day]
#> target: string
#> horizon: int32
#> location: string
#> output_type: string
#> output_type_id: double
#> value: int32
#> model_id: string
#> age_group: string
print(hub_con, verbose = TRUE)
#> 
#> ── <hub_connection/UnionDataset> ──
#> 
#> • hub_name: "Simple Forecast Hub"
#> • hub_path: /home/runner/work/_temp/Library/hubUtils/testhubs/simple
#> • file_format: "csv(3/3)" and "parquet(1/1)"
#> • checks: TRUE
#> • file_system: "LocalFileSystem"
#> • model_output_dir:
#>   "/home/runner/work/_temp/Library/hubUtils/testhubs/simple/model-output"
#> • config_admin: hub-config/admin.json
#> • config_tasks: hub-config/tasks.json
#> 
#> ── Connection schema 
#> hub_connection
#> 9 columns
#> origin_date: date32[day]
#> target: string
#> horizon: int32
#> location: string
#> output_type: string
#> output_type_id: double
#> value: int32
#> model_id: string
#> age_group: string
#> Classes 'hub_connection', 'UnionDataset', 'Dataset', 'ArrowObject', 'R6' <hub_connection>
#>   Inherits from: <UnionDataset>
#>   Public:
#>     .:xp:.: externalptr
#>     .unsafe_delete: function () 
#>     NewScan: function () 
#>     ToString: function () 
#>     WithSchema: function (schema) 
#>     children: active binding
#>     class_title: function () 
#>     clone: function (deep = FALSE) 
#>     initialize: function (xp) 
#>     metadata: active binding
#>     num_cols: active binding
#>     num_rows: active binding
#>     pointer: function () 
#>     print: function (...) 
#>     schema: active binding
#>     set_pointer: function (xp) 
#>     type: active binding 
#>  - attr(*, "hub_name")= chr "Simple Forecast Hub"
#>  - attr(*, "file_format")= int [1:2, 1:2] 3 3 1 1
#>   ..- attr(*, "dimnames")=List of 2
#>   .. ..$ : chr [1:2] "n_open" "n_in_dir"
#>   .. ..$ : chr [1:2] "csv" "parquet"
#>  - attr(*, "checks")= logi TRUE
#>  - attr(*, "file_system")= chr "LocalFileSystem"
#>  - attr(*, "hub_path")= chr "/home/runner/work/_temp/Library/hubUtils/testhubs/simple"
#>  - attr(*, "model_output_dir")= chr "/home/runner/work/_temp/Library/hubUtils/testhubs/simple/model-output"
#>  - attr(*, "config_admin")=List of 8
#>   ..$ schema_version: chr "https://raw.githubusercontent.com/hubverse-org/schemas/main/v2.0.0/admin-schema.json"
#>   ..$ name          : chr "Simple Forecast Hub"
#>   ..$ maintainer    : chr "Consortium of Infectious Disease Modeling Hubs"
#>   ..$ contact       :List of 2
#>   .. ..$ name : chr "Joe Bloggs"
#>   .. ..$ email: chr "j.bloggs@cidmh.com"
#>   ..$ repository_url: chr "https://github.com/hubverse-org/example-simple-forecast-hub"
#>   ..$ hub_models    :List of 1
#>   .. ..$ :List of 3
#>   .. .. ..$ team_abbr : chr "simple_hub"
#>   .. .. ..$ model_abbr: chr "baseline"
#>   .. .. ..$ model_type: chr "baseline"
#>   ..$ file_format   : chr [1:3] "csv" "parquet" "arrow"
#>   ..$ timezone      : chr "US/Eastern"
#>   ..- attr(*, "schema_id")= chr "https://raw.githubusercontent.com/hubverse-org/schemas/main/v2.0.0/admin-schema.json"
#>   ..- attr(*, "type")= chr "admin"
#>   ..- attr(*, "class")= chr [1:2] "config" "list"
#>  - attr(*, "config_tasks")=List of 2
#>   ..$ schema_version: chr "https://raw.githubusercontent.com/hubverse-org/schemas/main/v2.0.0/tasks-schema.json"
#>   ..$ rounds        :List of 2
#>   .. ..$ :List of 4
#>   .. .. ..$ round_id_from_variable: logi TRUE
#>   .. .. ..$ round_id              : chr "origin_date"
#>   .. .. ..$ model_tasks           :List of 1
#>   .. .. .. ..$ :List of 3
#>   .. .. .. .. ..$ task_ids       :List of 4
#>   .. .. .. .. .. ..$ origin_date:List of 2
#>   .. .. .. .. .. .. ..$ required: NULL
#>   .. .. .. .. .. .. ..$ optional: chr [1:2] "2022-10-01" "2022-10-08"
#>   .. .. .. .. .. ..$ target     :List of 2
#>   .. .. .. .. .. .. ..$ required: chr "wk inc flu hosp"
#>   .. .. .. .. .. .. ..$ optional: NULL
#>   .. .. .. .. .. ..$ horizon    :List of 2
#>   .. .. .. .. .. .. ..$ required: int 1
#>   .. .. .. .. .. .. ..$ optional: int [1:3] 2 3 4
#>   .. .. .. .. .. ..$ location   :List of 2
#>   .. .. .. .. .. .. ..$ required: NULL
#>   .. .. .. .. .. .. ..$ optional: chr [1:54] "US" "01" "02" "04" ...
#>   .. .. .. .. ..$ output_type    :List of 2
#>   .. .. .. .. .. ..$ mean    :List of 2
#>   .. .. .. .. .. .. ..$ output_type_id:List of 2
#>   .. .. .. .. .. .. .. ..$ required: NULL
#>   .. .. .. .. .. .. .. ..$ optional: logi NA
#>   .. .. .. .. .. .. ..$ value         :List of 2
#>   .. .. .. .. .. .. .. ..$ type   : chr "integer"
#>   .. .. .. .. .. .. .. ..$ minimum: int 0
#>   .. .. .. .. .. ..$ quantile:List of 2
#>   .. .. .. .. .. .. ..$ output_type_id:List of 2
#>   .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
#>   .. .. .. .. .. .. .. ..$ optional: NULL
#>   .. .. .. .. .. .. ..$ value         :List of 2
#>   .. .. .. .. .. .. .. ..$ type   : chr "integer"
#>   .. .. .. .. .. .. .. ..$ minimum: int 0
#>   .. .. .. .. ..$ target_metadata:List of 1
#>   .. .. .. .. .. ..$ :List of 7
#>   .. .. .. .. .. .. ..$ target_id    : chr "wk inc flu hosp"
#>   .. .. .. .. .. .. ..$ target_name  : chr "Weekly incident influenza hospitalizations"
#>   .. .. .. .. .. .. ..$ target_units : chr "count"
#>   .. .. .. .. .. .. ..$ target_keys  :List of 1
#>   .. .. .. .. .. .. .. ..$ target: chr "wk inc flu hosp"
#>   .. .. .. .. .. .. ..$ target_type  : chr "continuous"
#>   .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
#>   .. .. .. .. .. .. ..$ time_unit    : chr "week"
#>   .. .. ..$ submissions_due       :List of 3
#>   .. .. .. ..$ relative_to: chr "origin_date"
#>   .. .. .. ..$ start      : int -6
#>   .. .. .. ..$ end        : int 1
#>   .. ..$ :List of 4
#>   .. .. ..$ round_id_from_variable: logi TRUE
#>   .. .. ..$ round_id              : chr "origin_date"
#>   .. .. ..$ model_tasks           :List of 1
#>   .. .. .. ..$ :List of 3
#>   .. .. .. .. ..$ task_ids       :List of 5
#>   .. .. .. .. .. ..$ origin_date:List of 2
#>   .. .. .. .. .. .. ..$ required: NULL
#>   .. .. .. .. .. .. ..$ optional: chr [1:3] "2022-10-15" "2022-10-22" "2022-10-29"
#>   .. .. .. .. .. ..$ target     :List of 2
#>   .. .. .. .. .. .. ..$ required: chr "wk inc flu hosp"
#>   .. .. .. .. .. .. ..$ optional: NULL
#>   .. .. .. .. .. ..$ horizon    :List of 2
#>   .. .. .. .. .. .. ..$ required: int 1
#>   .. .. .. .. .. .. ..$ optional: int [1:3] 2 3 4
#>   .. .. .. .. .. ..$ location   :List of 2
#>   .. .. .. .. .. .. ..$ required: NULL
#>   .. .. .. .. .. .. ..$ optional: chr [1:54] "US" "01" "02" "04" ...
#>   .. .. .. .. .. ..$ age_group  :List of 2
#>   .. .. .. .. .. .. ..$ required: chr "65+"
#>   .. .. .. .. .. .. ..$ optional: chr [1:4] "0-5" "6-18" "19-24" "25-64"
#>   .. .. .. .. ..$ output_type    :List of 2
#>   .. .. .. .. .. ..$ mean    :List of 2
#>   .. .. .. .. .. .. ..$ output_type_id:List of 2
#>   .. .. .. .. .. .. .. ..$ required: NULL
#>   .. .. .. .. .. .. .. ..$ optional: logi NA
#>   .. .. .. .. .. .. ..$ value         :List of 2
#>   .. .. .. .. .. .. .. ..$ type   : chr "integer"
#>   .. .. .. .. .. .. .. ..$ minimum: int 0
#>   .. .. .. .. .. ..$ quantile:List of 2
#>   .. .. .. .. .. .. ..$ output_type_id:List of 2
#>   .. .. .. .. .. .. .. ..$ required: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
#>   .. .. .. .. .. .. .. ..$ optional: NULL
#>   .. .. .. .. .. .. ..$ value         :List of 2
#>   .. .. .. .. .. .. .. ..$ type   : chr "integer"
#>   .. .. .. .. .. .. .. ..$ minimum: int 0
#>   .. .. .. .. ..$ target_metadata:List of 1
#>   .. .. .. .. .. ..$ :List of 7
#>   .. .. .. .. .. .. ..$ target_id    : chr "wk inc flu hosp"
#>   .. .. .. .. .. .. ..$ target_name  : chr "Weekly incident influenza hospitalizations"
#>   .. .. .. .. .. .. ..$ target_units : chr "count"
#>   .. .. .. .. .. .. ..$ target_keys  :List of 1
#>   .. .. .. .. .. .. .. ..$ target: chr "wk inc flu hosp"
#>   .. .. .. .. .. .. ..$ target_type  : chr "continuous"
#>   .. .. .. .. .. .. ..$ is_step_ahead: logi TRUE
#>   .. .. .. .. .. .. ..$ time_unit    : chr "week"
#>   .. .. ..$ submissions_due       :List of 3
#>   .. .. .. ..$ relative_to: chr "origin_date"
#>   .. .. .. ..$ start      : int -6
#>   .. .. .. ..$ end        : int 1
#>   ..- attr(*, "schema_id")= chr "https://raw.githubusercontent.com/hubverse-org/schemas/main/v2.0.0/tasks-schema.json"
#>   ..- attr(*, "type")= chr "tasks"
#>   ..- attr(*, "class")= chr [1:2] "config" "list"
mod_out_path <- system.file("testhubs/simple/model-output", package = "hubUtils")
mod_out_con <- connect_model_output(mod_out_path)
print(mod_out_con)
#> 
#> ── <mod_out_connection/FileSystemDataset> ──
#> 
#> • file_format: "csv(3/3)"
#> • checks: TRUE
#> • file_system: "LocalFileSystem"
#> • model_output_dir:
#>   "/home/runner/work/_temp/Library/hubUtils/testhubs/simple/model-output"
#> 
#> ── Connection schema 
#> mod_out_connection with 3 csv files
#> 8 columns
#> origin_date: date32[day]
#> target: string
#> horizon: int64
#> location: string
#> output_type: string
#> output_type_id: double
#> value: int64
#> model_id: string
```
