# LOAD PACKAGES ================================================================


# define required packages
required_packages <- c(
  "ggnewscale",
  "rgdal",
  "broom",
  # "sp",
  "rgeos",
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

# geodata for the municipality shapes and lakes
tmp <- tempfile()
dir <- tempdir()
download.file("https://www.web.statistik.zh.ch/ogd/daten/ressourcen/KTZH_00000151_00001254.zip", tmp)
unzip(tmp, exdir = dir)
gde <- rgdal::readOGR(paste0(dir, "/GEN_A4_GEMEINDEN_2019_epsg2056_json/GEN_A4_GEMEINDEN_SEEN_2019_epsg2056.json"))
gde$ID <- paste0(gde$ART_TEXT, gde$NAME)
file.remove(tmp)
unlink(dir)

# voting data
vot_raw <- readr::read_csv("https://www.web.statistik.zh.ch/ogd/data/KANTON_ZUERICH_abstimmungsarchiv_gemeinden.csv")


# DATA WRANGLING ===============================================================


# voting data
vot <- vot_raw %>%
  filter(stringr::str_detect(ABSTIMMUNGSTAG, "201|2009")) %>%
  # at this stage, check the amount of total votes in the period with "n_distinct(vot$VORLAGE_LANGBEZ)" and you will find, there were 192
  mutate(vote_ktn = ifelse(sum(AZ_JA_STIMMEN) > sum(AZ_NEIN_STIMMEN), "JA", "NEIN")) %>%
  group_by(VORLAGE_LANGBEZ) %>%
  mutate(
    vote_gde = ifelse(AZ_JA_STIMMEN > AZ_NEIN_STIMMEN, "JA", "NEIN"),
    count = ifelse(vote_gde == vote_ktn, 1, 0)
  ) %>%
  group_by(BFS) %>%
  summarise(wins = sum(count))

# extract centroids
# ctr <- data.frame(matrix(NA, length(gde), 3, dimnames = list(NULL, c("ID", "ctr_long", "ctr_lat"))))
# for(i in 1:length(gde)){
#   ctr[i,] <- c(gde$ID[i], round(gde@polygons[[i]]@labpt, 0))
# }
ctr <- data.frame(matrix(NA, length(gde), 2, dimnames = list(NULL, c("ctr_long", "ctr_lat"))))
for(i in 1:length(gde)){
  ctr[i,] <- gde@polygons[[i]]@labpt
}
ctr <- ctr %>%
  mutate(ID = gde$ID)

# convert geodata to df for ggplotting
gde_df <- broom::tidy(gde, region = "ID") %>%
  rename("ID" = "id") %>%
  left_join(gde@data, by = "ID") %>%
  # join voting data
  left_join(vot, by = "BFS") %>%
  left_join(ctr, by = "ID") %>%
  mutate(
    cat = case_when(
      wins > median(wins, na.rm = TRUE) ~ "WINNER",
      wins <= median(wins, na.rm = TRUE) ~ "LOSER",
      TRUE ~ "LAKE"
    )
  )

# PLOT DATA ====================================================================


png("03_polygons/03.png", width = 2500, height = 2500, res = 200)

# ggplot() +
#   geom_polygon(
#     data = gde_df,
#     colour = "white",
#     aes(
#       x = long,
#       y = lat,
#       group = group,
#       fill = wins
#     )
#   ) +
#   theme_minimal() +
#   scale_fill_gradientn(
#     colours = c(
#       "#00797B",
#       "#B1D6D7",
#       # "#FFFFFF",
#       "#E6B8CB",
#       "#B01657"
#     ),
#     na = "#EEEEEE"
#   )


ggplot() +
  geom_polygon(
    data = gde_df %>%
      filter(cat == "WINNER"),
    colour = "white",
    aes(
      x = long,
      y = lat,
      group = group,
      fill = wins
    )
  ) +
  scale_fill_gradientn(
    colours = c("#B1D6D7", "#00797B"),
    # guide = guide_colourbar(
    #   order = 1,
    #   title = NULL
    # ),
  ) +
  ggnewscale::new_scale_fill() +
  geom_polygon(
    data = gde_df %>%
      filter(cat == "LOSER"),
    colour = "white",
    aes(
      x = long,
      y = lat,
      group = group,
      # colour = factor(vmax)
      fill = wins
    )
  ) +
  scale_fill_gradientn(
    colours = c("#B01657", "#E6B8CB"),
    # guide = guide_colourbar(
    #   order = 2,
    #   title = NULL,
    # )
  ) +
  ggnewscale::new_scale_fill() +
  geom_polygon(
    data = gde_df %>%
      filter(cat == "LAKE"),
    colour = "white",
    fill = "#EEEEEE",
    aes(
      x = long,
      y = lat,
      group = group
    )
  ) +
  geom_text(
    data = gde_df %>%
      filter(NAME %in% c("Dietikon", "Fischenthal")) %>%
      select(NAME, ctr_long, ctr_lat) %>%
      distinct(NAME, .keep_all = T),
    aes(
      x = ctr_long,
      y = ctr_lat,
      label = NAME
    ),
    # alpha = .3,
    colour = "black",
    fontface = "bold",
    nudge_x = 500,
    size = 5
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "none",
    text = element_text(family = "Arial")
  ) +
  labs(
    x = "",
    y = ""
  )

dev.off()



