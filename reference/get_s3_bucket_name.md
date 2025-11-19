# Get the bucket name for the cloud storage location.

Get the bucket name for the cloud storage location.

## Usage

``` r
get_s3_bucket_name(hub_path = ".")
```

## Arguments

- hub_path:

  Path to a hub directory.

## Value

The bucket name for the cloud storage location.

## Examples

``` r
hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
get_s3_bucket_name(hub_path)
#> [1] "example-complex-forecast-hub"
# Get config info from GitHub
get_s3_bucket_name(
  "https://github.com/hubverse-org/example-complex-forecast-hub"
)
#> [1] "example-complex-forecast-hub"
```
