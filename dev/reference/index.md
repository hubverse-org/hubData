# Package index

## All functions

- [`arrow_to_r_datatypes`](https://hubverse-org.github.io/hubData/dev/reference/arrow_to_r_datatypes.md)
  : Mapping of Arrow types to base R types

- [`as_r_schema()`](https://hubverse-org.github.io/hubData/dev/reference/as_r_schema.md)
  [`arrow_schema_to_string()`](https://hubverse-org.github.io/hubData/dev/reference/as_r_schema.md)
  [`is_supported_arrow_type()`](https://hubverse-org.github.io/hubData/dev/reference/as_r_schema.md)
  [`validate_arrow_schema()`](https://hubverse-org.github.io/hubData/dev/reference/as_r_schema.md)
  : Convert or validate an Arrow schema for compatibility with base R
  column types

- [`coerce_to_hub_schema()`](https://hubverse-org.github.io/hubData/dev/reference/coerce_to_hub_schema.md)
  [`coerce_to_character()`](https://hubverse-org.github.io/hubData/dev/reference/coerce_to_hub_schema.md)
  : Coerce data.frame/tibble column data types to hub schema data types
  or character.

- [`collect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/collect_hub.md)
  : Collect Hub model output data

- [`collect_zoltar()`](https://hubverse-org.github.io/hubData/dev/reference/collect_zoltar.md)
  : Load forecasts from zoltardata.com in hubverse format

- [`connect_hub()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
  [`connect_model_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_hub.md)
  : Connect to model output data.

- [`connect_target_oracle_output()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_oracle_output.md)
  **\[experimental\]** : Open connection to oracle-output target data

- [`connect_target_timeseries()`](https://hubverse-org.github.io/hubData/dev/reference/connect_target_timeseries.md)
  **\[experimental\]** : Open connection to time-series target data

- [`create_hub_schema()`](https://hubverse-org.github.io/hubData/dev/reference/create_hub_schema.md)
  : Create a Hub arrow schema

- [`create_model_out_submit_tmpl()`](https://hubverse-org.github.io/hubData/dev/reference/create_model_out_submit_tmpl.md)
  **\[defunct\]** : Create a model output submission file template

- [`create_oracle_output_schema()`](https://hubverse-org.github.io/hubData/dev/reference/create_oracle_output_schema.md)
  : Create oracle-output target data file schema

- [`create_timeseries_schema()`](https://hubverse-org.github.io/hubData/dev/reference/create_timeseries_schema.md)
  : Create time-series target data file schema

- [`expand_model_out_val_grid()`](https://hubverse-org.github.io/hubData/dev/reference/expand_model_out_val_grid.md)
  **\[defunct\]** : Create expanded grid of valid task ID and output
  type value combinations

- [`extract_hive_partitions()`](https://hubverse-org.github.io/hubData/dev/reference/extract_hive_partitions.md)
  : Extract Hive-style partition key-value pairs from a path

- [`get_s3_bucket_name()`](https://hubverse-org.github.io/hubData/dev/reference/get_s3_bucket_name.md)
  : Get the bucket name for the cloud storage location.

- [`get_target_data_colnames()`](https://hubverse-org.github.io/hubData/dev/reference/get_target_data_colnames.md)
  : Get expected target data column names from config

- [`get_target_file_ext()`](https://hubverse-org.github.io/hubData/dev/reference/get_target_file_ext.md)
  : Get target data file unique file extensions.

- [`get_target_path()`](https://hubverse-org.github.io/hubData/dev/reference/get_target_path.md)
  : Get the path(s) to the target data file(s) in the hub directory.

- [`gs_bucket`](https://hubverse-org.github.io/hubData/dev/reference/gs_bucket.md)
  : Connect to a Google Cloud Storage (GCS) bucket

- [`is_hive_partitioned_path()`](https://hubverse-org.github.io/hubData/dev/reference/is_hive_partitioned_path.md)
  : Check whether a path contains Hive-style partitioning

- [`load_model_metadata()`](https://hubverse-org.github.io/hubData/dev/reference/load_model_metadata.md)
  : Compile hub model metadata

- [`print(`*`<hub_connection>`*`)`](https://hubverse-org.github.io/hubData/dev/reference/print.hub_connection.md)
  [`print(`*`<mod_out_connection>`*`)`](https://hubverse-org.github.io/hubData/dev/reference/print.hub_connection.md)
  :

  Print a `<hub_connection>` or `<mod_out_connection>` S3 class object

- [`r_to_arrow_datatypes()`](https://hubverse-org.github.io/hubData/dev/reference/r_to_arrow_datatypes.md)
  : Create R type to Arrow DataType mapping

- [`s3_bucket`](https://hubverse-org.github.io/hubData/dev/reference/s3_bucket.md)
  : Connect to an AWS S3 bucket
