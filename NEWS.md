# hubData 0.1.1

* Add `collect_zoltar()`, which retrieves data from a [zoltardata.com](https://zoltardata.com/) project and transforms it from Zoltar's native download format into a hubverse one. Zoltar (documentation [here](https://docs.zoltardata.com/)) is a pre-hubverse research project that implements a repository of model forecast results, including tools to administer, query, and visualize uploaded data, along with R and Python APIs to access data programmatically ([zoltr](https://github.com/reichlab/zoltr/) and [zoltpy](https://github.com/reichlab/zoltpy/), respectively.)

# hubData 0.1.0

* Add `collect_hub()` which wraps `dplyr::collect()` and, where possible, converts the output to a `model_out_tbl` class object by default. The function also accepts additional arguments that can be passed to `as_model_out_tbl()`.
* Allow for parsing `tasks.json` config files where both `required` and `optional` properties of task IDs are set to `null`. This change facilitates the encoding of task IDs in modeling tasks where no value is expected for a given task ID. In model output files, the value in such modeling task task IDs will be `NA`.

# hubData 0.0.1

* Initial package release resulting from split of `hubUtils` package. See [`hubUtils` NEWS.md](https://github.com/Infectious-Disease-Modeling-Hubs/hubUtils/blob/main/NEWS.md) for details including previous release notes.
