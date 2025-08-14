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

# Windows-safe writer: write to tmp, then atomic move over the original
# Local tiny helper for Windows-safe overwrites
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
