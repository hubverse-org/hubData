# hubData (development version)

* Support the determination of hub schema from v4 configuration files (#63). Also fixes bug in `create_hub_schema()` where `output_type_id` data type was being incorrectly auto-determined as `logical` when only point estimate output types where being collected by a hub. Now `character` data type is returned for the `output_type_id` for all schema versions in such situations when auto-determined.

# hubData 1.2.3

* Fix bug in `create_hub_schema()` where `output_type_id` data type was being incorrectly determined as `Date` instead of `character` (Reported in https://github.com/reichlab/variant-nowcast-hub/pull/87#issuecomment-2387372238).

# hubData 1.2.2

* Remove dependency on development version of `arrow` package and bump required version to 17.0.0.


# hubData 1.2.1

* Removed dependency on development version of `zoltr` package.
* Fixed minor error in `connect_hub()` article.

# hubData 1.2.0

* Adds a `skip_checks` parameter to the `connect_hub` and `connect_model_output` functions. When `skip_checks` is set to `TRUE`, these functions will bypass the default behavior of scanning the hub's model output directory for invalid files. Omitting these checks results in better performance when connecting to cloud-based hubs but can result in errors when querying the data. This option is only valid when connecting to hubs that meet the following criteria:
    - the model output directory contains only model output data (no `README.md`, for example)
    - the model output files use a single file format.

# hubData 1.1.1

* Fix {tidyselect} warnings by converting internal syntax
* Bump required dplyr version to 1.1.0

# hubData 1.1.0

* Add `"from_config"` option to the `output_type_id_datatype` argument in `create_hub_schema()`, `coerce_to_hub_schema()` and `connect_hub()`. This allows users to set the hub level `output_type_id` column data type through the `tasks.json` `output_type_id_datatype` property introduced in schema version v3.0.1. (#44)

# hubData 1.0.0

* Breaking change: `expand_model_out_val_grid()` and `create_model_out_submit_tmpl()` are now defunct. These functions have been moved to `hubValidations` and replaced by `hubValidations::expand_model_out_grid()` and `hubValidations::submission_tmpl()`, respectively. The old functions will now fail if called and will be removed in a future release.

# hubData 0.2.0

* Adds back-compatible support in `create_hub_schema()` for determining a hub's schema from v3.0.0 sample output type configurations in `tasks.json` files (#27).
* Adds back-compatible support for v3.0.0 sample output type configuration in `tasks.json` files. The primary change is how `output_type_id` values for sample output types are handled in `expand_model_out_val_grid()`. By default, all valid task ID value combinations are expanded, as per any other output type, but `NA`s are returned in the `output_type_id` column. However, if new argument `include_sample_ids` is set to `TRUE`, example sample IDs are included in the `output_type_id` column, demonstrating how compound tasks IDs group rows of task ID combinations into samples. These are unique across modeling tasks. In `create_model_out_submit_tmpl()`, example sample IDs are included in the `output_type_id` column by default (#30). 


# hubData 0.1.1

* Add `collect_zoltar()`, which retrieves data from a [zoltardata.com](https://zoltardata.com/) project and transforms it from Zoltar's native download format into a hubverse one. Zoltar (documentation [here](https://docs.zoltardata.com/)) is a pre-hubverse research project that implements a repository of model forecast results, including tools to administer, query, and visualize uploaded data, along with R and Python APIs to access data programmatically ([zoltr](https://github.com/reichlab/zoltr/) and [zoltpy](https://github.com/reichlab/zoltpy/), respectively.)

# hubData 0.1.0

* Add `collect_hub()` which wraps `dplyr::collect()` and, where possible, converts the output to a `model_out_tbl` class object by default. The function also accepts additional arguments that can be passed to `as_model_out_tbl()`.
* Allow for parsing `tasks.json` config files where both `required` and `optional` properties of task IDs are set to `null`. This change facilitates the encoding of task IDs in modeling tasks where no value is expected for a given task ID. In model output files, the value in such modeling task task IDs will be `NA`.

# hubData 0.0.1

* Initial package release resulting from split of `hubUtils` package. See [`hubUtils` NEWS.md](https://github.com/hubverse-org/hubUtils/blob/main/NEWS.md) for details including previous release notes.
