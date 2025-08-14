# helper-hubs.R

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
# - Uses testthat::teardown_env() by default, so cleanup happens after the test.
use_example_hub_editable <- function(
  which = c("file", "dir"),
  .local_envir = testthat::teardown_env()
) {
  which <- rlang::arg_match(which)
  src <- use_example_hub_readonly(which)

  parent <- fs::path_temp(
    paste0("hub-", which, "-", sprintf("%08x", as.integer(runif(1, 0, 2^31))))
  )
  fs::dir_create(parent, recurse = TRUE)
  withr::defer(fs::dir_delete(parent), envir = .local_envir)

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
