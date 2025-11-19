# Get target data file unique file extensions.

Get the unique file extension(s) of the target data file(s) in
`target_path`. If `target_path` is a directory, the function will return
the unique file extensions of all files in the directory. If
`target_path` is a file, the function will return the file extension of
that file.

## Usage

``` r
get_target_file_ext(hub_path = NULL, target_path)
```

## Arguments

- hub_path:

  If not `NULL`, must be a `SubTreeFileSystem` class object of the root
  to a cloud hosted hub. Required to trigger the `SubTreeFileSystem`
  method.

- target_path:

  character string. The path to the target data file or directory.
  Usually the output of
  [`get_target_path()`](https://hubverse-org.github.io/hubData/reference/get_target_path.md).

## Examples

``` r
hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
target_path <- get_target_path(hub_path, "time-series")
get_target_file_ext(hub_path, target_path)
#> [1] "csv"
```
