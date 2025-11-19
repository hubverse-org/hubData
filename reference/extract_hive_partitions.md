# Extract Hive-style partition key-value pairs from a path

Given a filesystem path, this function extracts Hive-style partition
key-value pairs (i.e., path components formatted as `key=value`). It
supports decoding URL-encoded values (e.g., `"wk%20flu"` → `"wk flu"`),
and handles empty values (e.g., `"key="`) as `NA`, consistent with Hive
and Arrow semantics.

## Usage

``` r
extract_hive_partitions(path, strict = TRUE)
```

## Arguments

- path:

  A character string of length 1: the path to a file or directory.

- strict:

  Logical. If `TRUE`, invalid partition segments (e.g., `=value`, or
  just `=`) will trigger an error. If `FALSE`, only valid `key=value`
  components are returned.

## Value

A named character vector where the names are partition keys and the
values are decoded values. Returns `NULL` if no valid partitions are
found.

## Details

If `strict = TRUE`, the function will abort with a detailed error
message if any malformed partition-like segments are found.

## See also

[`is_hive_partitioned_path()`](https://hubverse-org.github.io/hubData/reference/is_hive_partitioned_path.md)

## Examples

``` r
extract_hive_partitions("data/country=US/year=2024/file.parquet")
#> country    year 
#>    "US"  "2024" 
extract_hive_partitions("data/country=/year=2024/", strict = TRUE)
#> country    year 
#>      NA  "2024" 
# extract_hive_partitions("data/=US/year=2024/", strict = TRUE) # This will error
```
