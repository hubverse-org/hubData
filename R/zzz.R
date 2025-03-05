# We use `<<-` below to modify the package's namespace.
# It doesn't modify the global environment.
# We do this to prevent build time dependencies on {memoise},
# as recommended in <http://memoise.r-lib.org/reference/memoise.html#details>.
# Cf. <https://github.com/r-lib/memoise/issues/76> for further details.
.onLoad <- function(libname, pkgname) {
  get_target_file_ext.SubTreeFileSystem <<- memoise::memoise(get_target_file_ext.SubTreeFileSystem)
  get_target_path.SubTreeFileSystem <<- memoise::memoise(get_target_path.SubTreeFileSystem)
}
