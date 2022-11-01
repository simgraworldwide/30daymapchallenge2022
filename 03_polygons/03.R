# LOAD PACKAGES ================================================================


# define required packages
required_packages <- c(
  "rgdal",
  "broom",
  "geojsonR",
  "readr",
  "ggplot2",
  "dplyr"
)


## load CRAN packages
if (exists("required_packages")) {
  # install required packages that are not installed yet:
  new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    install.packages(new_packages)
  }
  lapply(
    required_packages,
    library,
    character.only = TRUE
  )
}

rm(new_packages, required_packages)


# LOAD DATA ====================================================================

