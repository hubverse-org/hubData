# Connect to a Google Cloud Storage (GCS) bucket

See
[`arrow::gs_bucket()`](https://arrow.apache.org/docs/r/reference/gs_bucket.html)
for details.

## Value

A `SubTreeFileSystem` containing an `GcsFileSystem` and the bucket's
relative path. Note that this function's success does not guarantee that
you are authorized to access the bucket's contents.

## Examples

``` r
if (FALSE) {
bucket <- gs_bucket("voltrondata-labs-datasets")
}
```
