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

# load geojson for traffic network
rds <- rgdal::readOGR("https://www.ogd.stadt-zuerich.ch/wfs/geoportal/Signalisierte_Geschwindigkeiten?service=WFS&version=1.1.0&request=GetFeature&outputFormat=GeoJSON&typename=vz_tbl_tempo_l")

# convert data to df
rds_df <- broom::tidy(rds, region = "id")
# make sure the shapefile attribute table has an id column
rds$id <- base::rownames(rds@data)
# join the attribute table from the spatial object to the new data frame
rds_df <- dplyr::left_join(rds_df, rds@data, by = "id") %>%
  dplyr::mutate(vmax_bin = dplyr::case_when(
    vmax <= 30 ~ "≤30",
    vmax >= 60 ~ "≥60",
    TRUE ~ "50"
  ))

# load accident data
acc <- readr::read_csv("https://data.stadt-zuerich.ch/dataset/sid_dav_strassenverkehrsunfallorte/download/RoadTrafficAccidentLocations.csv") %>%
  dplyr::select(-dplyr::contains(c("_it", "_fr", "_en"))) %>%
  stats::setNames(., base::tolower(base::names(.)))

# filter accident data to contain only accidents with bicycle involvement
acc_bcl <- acc %>%
  dplyr::filter(
    accidentinvolvingbicycle == TRUE,
    # accidenttype_de == "Parkierunfall"
    accidenttype_de %in% c(
      "Abbiegeunfall",
      "Einbiegeunfall",
      "Frontalkollision",
      "Fussgängerunfall",
      "Parkierunfall",
      "Überholunfall oder Fahrstreifenwechsel"
    )
  ) %>%
  # transform coordinates form lv95 to wgs83
  dplyr::mutate(
    helpere = ((accidentlocation_chlv95_e - 2600000)/1000000),
    helpern = ((accidentlocation_chlv95_n - 1200000)/1000000),
    accidentlocation_wgs83_e = (2.6779094 + (4.728982 * helpere) + (0.791484 * helpere * helpern) + (0.1306 * helpere * helpern^2) - (0.0436 * helpere^3)) * 100 / 36,
    accidentlocation_wgs83_n = (16.9023892 + (3.238272 * helpern) - (0.270978 * helpere^2) - (0.002528 * helpern^2) - (0.0447 * helpere^2 * helpern) - (0.0140 * helpern^3)) * 100 / 36
  ) %>%
  dplyr::select(-c(
    helpere,
    helpern
  ))


# DRAW MAP =====================================================================

png("01_02_points_lines/01_02.png", width = 2800, height = 2500, res = 200)

ggplot2::ggplot() +
  ggplot2::geom_path(
    data = rds_df,
    ggplot2::aes(
      x = long,
      y = lat,
      group = group,
      # colour = factor(vmax)
      colour = factor(vmax_bin, levels = c("≤30", "50", "≥60"))
    )
  ) +
  ggplot2::scale_color_manual(values = c("#BA9746", "#466EA1", "#C13B3B")) +
  ggplot2::geom_point(
    data = acc_bcl,
    ggplot2::aes(
      x = accidentlocation_wgs83_e,
      y = accidentlocation_wgs83_n,
      shape = accidenttype_de
    ),
    size = 0.5
  ) +
  ggplot2::theme_minimal() +
  ggplot2::labs(
    # title = "Accident Locations involving Bicycles in Zurich 2011-2021",
    # subtitle = "by Type of Accident and (current) Speed Limit",
    shape = "Accident Type",
    colour = "Speed Limit",
    caption="Data: Stadt Zürich"
  ) +
  ggplot2::theme(legend.position = c(0.125, 0.2))

dev.off()
