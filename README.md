
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hubData <a href="https://hubverse-org.github.io/hubData/"><img src="man/figures/logo.png" align="right" height="131" alt="hubData website" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/hubData)](https://CRAN.R-project.org/package=hubData)
[![R-CMD-check](https://github.com/hubverse-org/hubData/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hubverse-org/hubData/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

The goal of hubData is to provide tools for accessing and working with
hubverse Hub data.

This package is part of the [hubverse](https://hubverse.io)
ecosystem, which aims to provide a set of tools for infectious disease
modeling hubs to share and collaborate on their work.

## Installation

### Latest

You can install the [latest version of hubData from the
R-universe](https://hubverse-org.r-universe.dev/hubData):

``` r
install.packages("hubData", repos = c("https://hubverse-org.r-universe.dev", "https://cloud.r-project.org"))
```

### Development

If you want to test out new features that have not yet been released,
you can install the development version of hubData from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("hubverse-org/hubData")
```

> [!NOTE]
>
> `hubData` has a dependency on the `arrow` package. For troubleshooting
> `arrow` installation problems, please consult the [`arrow` package
> documentation](https://arrow.apache.org/docs/r/#installation).
>
> You could also try installing the package from the [Apache R Universe
> repository](https://apache.r-universe.dev) with:
>
> ``` r
> install.packages("arrow", repos = c("https://apache.r-universe.dev", "https://cran.r-project.org"))
> ```

------------------------------------------------------------------------

## Code of Conduct

Please note that the hubData package is released with a [Contributor
Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.

## Contributing

Interested in contributing back to the open-source Hubverse project?
Learn more about how to [get involved in the Hubverse
Community](https://docs.hubverse.io/en/latest/overview/contribute.html) or
[how to contribute to the hubData package](.github/CONTRIBUTING.md).
