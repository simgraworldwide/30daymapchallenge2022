# LOAD PACKAGES ================================================================


# define required packages
required_packages <- c(
  "sf",
  "readr",
  "ggplot2",
  "dplyr"
)

# load CRAN packages
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


# SBB
sbb <- read_sf("https://data.sbb.ch/explore/dataset/linie-mit-polygon/download/?format=geojson&timezone=Europe/Berlin&lang=de")


# PLOT DATA ====================================================================


ggplot() +
  geom_sf(
    data = sbb,
    colour = "black"
  )
