# Get the path(s) to the target data file(s) in the hub directory.

Get the path(s) to the target data file(s) in the hub directory.

## Usage

``` r
get_target_path(hub_path, target_type = c("time-series", "oracle-output"))
```

## Arguments

- hub_path:

  Either a character string path to a local Modeling Hub directory or an
  object of class `<SubTreeFileSystem>` created using functions
  [`s3_bucket()`](https://hubverse-org.github.io/hubData/reference/s3_bucket.md)
  or
  [`gs_bucket()`](https://hubverse-org.github.io/hubData/reference/gs_bucket.md)
  by providing a string S3 or GCS bucket name or path to a Modeling Hub
  directory stored in the cloud. For more details consult the [Using
  cloud storage (S3,
  GCS)](https://arrow.apache.org/docs/r/articles/fs.html) in the `arrow`
  package. The hub must be fully configured with valid `admin.json` and
  `tasks.json` files within the `hub-config` directory.

- target_type:

  Type of target data to retrieve matching files. One of "time-series"
  or "oracle-output". Defaults to "time-series".

## Value

a character vector of path(s) to target data file(s) (in the
`target-data` directory) that make the `target_type` requested.

## Examples

``` r
hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
get_target_path(hub_path)
#> /home/runner/work/_temp/Library/hubUtils/testhubs/v5/target_file/target-data/time-series.csv
get_target_path(hub_path, "time-series")
#> /home/runner/work/_temp/Library/hubUtils/testhubs/v5/target_file/target-data/time-series.csv
get_target_path(hub_path, "oracle-output")
#> /home/runner/work/_temp/Library/hubUtils/testhubs/v5/target_file/target-data/oracle-output.csv
# Access cloud data
s3_bucket_name <- get_s3_bucket_name(hub_path)
s3_hub_path <- s3_bucket(s3_bucket_name)
get_target_path(s3_hub_path)
#> target-data/time-series.csv
get_target_path(s3_hub_path, "oracle-output")
#> target-data/oracle-output.csv
```
