# DATA NOT TO USE ==============================================================


## THING IS HUGE ---------------------------------------------------------------

# Data Source needs to be mentioned: Quelle: Kantonale Raumplanungsfachstellen, INFOPLAN-ARE
# Data found here: https://www.are.admin.ch/are/de/home/raumentwicklung-und-raumplanung/grundlagen-und-daten/bauzonenstatistik-schweiz.html
# 2012
# temp1 <- base::tempfile()
# temp2 <- base::tempfile()
# utils::download.file("https://www.kgk-cgc.ch/download_file/238/239", temp1)
# utils::unzip(temp1, exdir = temp2)
# bauzonen_2012 <- rgdal::readOGR(base::paste0(temp2, "/ch_are_bauzonen.shp"))
# base::unlink(c(temp1, temp2))
# rm(temp1, temp2)
# # 2017
# temp3 <- base::tempfile()
# temp4 <- base::tempfile()
# utils::download.file("https://www.kgk-cgc.ch/download_file/237/239", temp3)
# utils::unzip(temp3, exdir = temp4)
# bauzonen_2017 <- rgdal::readOGR(base::paste0(temp4, "/ch_are_bauzonen.shp"))
# # remove tmp-files
# base::unlink(c(temp3, temp4))
# base::rm(temp3, temp4)

