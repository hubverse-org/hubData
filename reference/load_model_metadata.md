# Compile hub model metadata

Loads in hub model metadata for all models or a specified subset of
models and compiles it into a tibble with one row per model.

## Usage

``` r
load_model_metadata(hub_path, model_ids = NULL)
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
  package.

- model_ids:

  A vector of character strings of models for which to load metadata.
  Defaults to NULL, in which case metadata for all models is loaded.

## Value

`tibble` with model metadata. One row for each model, one column for
each top-level field in the metadata file. For metadata files with
nested structures, this tibble may contain list-columns where the
entries are lists containing the nested metadata values.

## Examples

``` r
# Load in model metadata from local hub
hub_path <- system.file("testhubs/simple", package = "hubUtils")
load_model_metadata(hub_path)
#> # A tibble: 2 × 15
#>   model_id        team_abbr model_abbr team_name        model_name model_version
#>   <chr>           <chr>     <chr>      <chr>            <chr>      <chr>        
#> 1 hub-baseline    hub       baseline   Hub Coordinatio… Baseline   1.0          
#> 2 team1-goodmodel team1     goodmodel  Team1            Good Model 1.0          
#> # ℹ 9 more variables: model_contributors <list>, website_url <chr>,
#> #   repo_url <lgl>, license <chr>, include_viz <lgl>, include_ensemble <lgl>,
#> #   include_eval <lgl>, model_details <list>, ensemble_of_hub_models <lgl>
load_model_metadata(hub_path, model_ids = c("hub-baseline"))
#> # A tibble: 1 × 15
#>   model_id     team_abbr model_abbr team_name           model_name model_version
#>   <chr>        <chr>     <chr>      <chr>               <chr>      <chr>        
#> 1 hub-baseline hub       baseline   Hub Coordination T… Baseline   1.0          
#> # ℹ 9 more variables: model_contributors <list>, website_url <chr>,
#> #   repo_url <lgl>, license <chr>, include_viz <lgl>, include_ensemble <lgl>,
#> #   include_eval <lgl>, model_details <list>, ensemble_of_hub_models <lgl>
```
