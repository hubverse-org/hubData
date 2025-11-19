# Check whether a path contains Hive-style partitioning

This function checks if a given file or directory path includes one or
more Hive-style partition segments (i.e., subdirectories formatted as
`key=value`). This function can operate in a strict or lenient mode,
depending on whether you want to catch malformed partition-like
segments.

## Usage

``` r
is_hive_partitioned_path(path, strict = TRUE)
```

## Arguments

- path:

  Character string. Path to a file or directory.

- strict:

  Logical. If `TRUE`, the function will throw an error if any malformed
  partition segments are found (e.g., `=value`, missing key, or
  malformed `=` without a value). If `FALSE`, it simply returns `TRUE`
  if any valid `key=value` segments are found.

## Value

A logical value: `TRUE` if the path contains one or more valid
Hive-style partition segments, `FALSE` otherwise.

## Details

A valid partition segment must:

- Contain an equals sign (`=`)

- Have a non-empty key before the equals sign

- May have an empty value (interpreted as `NA` in most Hive/Arrow
  contexts)

In strict mode, the function validates that all `key=value` segments are
well-formed and will abort if any are not.

## See also

[`extract_hive_partitions()`](https://hubverse-org.github.io/hubData/reference/extract_hive_partitions.md)
to extract key-value pairs from Hive-style paths.

## Examples

``` r
is_hive_partitioned_path("data/country=US/year=2024/file.parquet")
#> [1] TRUE
is_hive_partitioned_path("data/country=/year=2024/", strict = TRUE)
#> [1] TRUE
# is_hive_partitioned_path("data/=US/year=2024/", strict = TRUE) # This will error
```
