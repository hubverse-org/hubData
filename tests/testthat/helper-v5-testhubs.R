# Paths to embedded example hubs (as provided)
hubutils_target_file_hub <- function() {
  system.file("testhubs/v5/target_file", package = "hubUtils")
}
hubutils_target_dir_hub <- function() {
  system.file("testhubs/v5/target_dir", package = "hubUtils")
}

# Use the hub in-place (no edits)
use_example_hub_readonly <- function(which = c("file", "dir")) {
  which <- rlang::arg_match(which)
  if (which == "file") hubutils_target_file_hub() else hubutils_target_dir_hub()
}

# Make a temp working copy (persists for the calling TEST only)
# Cleanup is tied to the test via withr::local_tempdir(.local_envir = ...)
use_example_hub_editable <- function(
  which = c("file", "dir"),
  .local_envir = testthat::teardown_env()
) {
  which <- rlang::arg_match(which)
  src <- use_example_hub_readonly(which)

  # Create a scoped temp dir (deleted after the test)
  parent <- withr::local_tempdir(
    pattern = "testhub-",
    .local_envir = .local_envir
  )

  # Copy so the returned path IS the hub root (contains `target-data`)
  dst <- fs::path(parent, fs::path_file(src))
  fs::dir_copy(src, dst, overwrite = TRUE)
  dst
}

# Windows-safe writer: write to tmp, then atomic move over the original
.local_safe_overwrite <- function(write_fun, dest_path, ...) {
  gc()
  Sys.sleep(0.2)
  tmp <- fs::file_temp(ext = fs::path_ext(dest_path))
  on.exit(try(fs::file_delete(tmp), silent = TRUE), add = TRUE)
  write_fun(tmp, ...)
  gc()
  Sys.sleep(0.2)
  fs::file_move(tmp, dest_path)
  dest_path
}

# Split a single CSV into per-target CSVs under target-data/<target_type>/
split_csv_by_target <- function(
  hub_path,
  dat,
  target_type = c("oracle-output", "time-series")
) {
  target_type <- rlang::arg_match(target_type)
  out_dir <- fs::path(hub_path, "target-data", target_type)

  # Clean up any previous contents
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  fs::dir_create(out_dir)

  split(dat, dat$target) |>
    purrr::iwalk(function(df, tgt) {
      tgt_safe <- gsub(" ", "_", tgt, fixed = TRUE)
      path <- fs::path(out_dir, paste0("target-", tgt_safe), ext = "csv")
      .local_safe_overwrite(
        function(path_out) arrow::write_csv_arrow(df, file = path_out),
        path
      )
    })

  out_dir
}

# Write hive-partitioned parquet by target under target-data/<target_type>/
write_hive_parquet_by_target <- function(
  hub_path,
  dat,
  target_type = c("oracle-output", "time-series")
) {
  target_type <- rlang::arg_match(target_type)
  out_dir <- fs::path(hub_path, "target-data", target_type)

  # Clean up any previous contents
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  fs::dir_create(out_dir)

  arrow::write_dataset(
    dat,
    out_dir,
    partitioning = "target",
    format = "parquet"
  )
  out_dir
}
