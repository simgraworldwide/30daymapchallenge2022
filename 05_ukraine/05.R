# LOAD PACKAGES ================================================================


# define required packages
required_packages <- c(
  "sf",
  "readr",
  "ggplot2",
  "dplyr",
  "rnaturalearth",
  "rnaturalearthdata"
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


# country borders
eur <- ne_countries(returnclass = "sf") %>%
  filter(
    continent == "Europe",
    geounit != "Russia" # Russia decided to not be part of Europe on 2014-02-27
  )

# number of refugees per country
# https://data.unhcr.org/en/situations/ukraine
# did not have time to build a scraper so let's skip day 5

# PLOT DATA ====================================================================


ggplot() +
  geom_sf(
    data = eur,
    fill = "#0057B8",
    colour = "#FFD700"
  )
