# LOAD PACKAGES ================================================================


# define required packages
required_packages <- c(
  "rgdal",
  "sf",
  "geojsonR",
  "readr",
  "ggplot2",
  "dplyr",
  "stringr"
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


# load geojson for all newly planted trees (Dec 2018 - Dec 2019) of Grün Stadt Zürich
trs <- sf::read_sf("https://www.ogd.stadt-zuerich.ch/wfs/geoportal/Baumersatz?service=WFS&version=1.1.0&request=GetFeature&outputFormat=GeoJSON&typename=baumersatz") %>%
  mutate(across("faellursache", str_replace, "Schaden", "Schäden"))

# schützenswerte und potenziell schützenswerte Gärten und Anlagen von kommunaler Bedeutung (https://www.stadt-zuerich.ch/geodaten/download/_GDP__Inventar_der_schuetzenswerten_Gaerten_und_Anlagen_von_kommunaler_Bedeutung_der_Stadt_Zuerich?format=geojson_link)
grn <- sf::read_sf("https://www.ogd.stadt-zuerich.ch/wfs/geoportal/_GDP__Inventar_der_schuetzenswerten_Gaerten_und_Anlagen_von_kommunaler_Bedeutung_der_Stadt_Zuerich?service=WFS&version=1.1.0&request=GetFeature&outputFormat=GeoJSON&typename=gdp_objekte")


# PLOT DATA ====================================================================


png("03_polygons/03.png", width = 2500, height = 2500, res = 200)

ggplot() +
  geom_sf(
    data = grn,
    fill = "#303200",
    alpha = 0.5,
    colour = "transparent"
  ) +
  geom_sf(
    data = trs,
    # shape = 8,
    size = 4,
    aes(
      colour = faellursache
    )
  ) +
  # scale_color_viridis_d(option = "D") +
  scale_colour_manual(values = c(
    "#440154FF",
    "#3B528BFF",
    "#21908CFF",
    "#5DC863FF",
    "#EB7100"
  )) +
  theme_void() +
  labs(
    colour = "Fällursache"
  ) +
  theme(
    legend.position = c(0.125, 0.2),
    legend.title = element_text(size = rel(1.5)),
    legend.text = element_text(size = rel(1.5))
  )
  # theme_minimal()

dev.off()
