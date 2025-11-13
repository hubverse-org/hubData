# Connect to an AWS S3 bucket

See
[`arrow::s3_bucket()`](https://arrow.apache.org/docs/r/reference/s3_bucket.html)
for details.

## Value

A `SubTreeFileSystem` containing an `S3FileSystem` and the bucket's
relative path. Note that this function's success does not guarantee that
you are authorized to access the bucket's contents.

## Examples

``` r
if (FALSE) {
bucket <- s3_bucket("voltrondata-labs-datasets")
}
if (FALSE) {
# Turn on debug logging. The following line of code should be run in a fresh
# R session prior to any calls to `s3_bucket()` (or other S3 functions)
Sys.setenv("ARROW_S3_LOG_LEVEL" = "DEBUG")
bucket <- s3_bucket("voltrondata-labs-datasets")
}
```
