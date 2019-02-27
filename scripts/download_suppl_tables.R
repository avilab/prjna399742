library(here)
url <- "http://science.sciencemag.org/highwire/filestream/704295/field_highwire_adjunct_files/0/Tables_S1-6.zip"
destfile <- here("data", basename(url))
download.file(url, destfile = destfile)
unzip(destfile, exdir = "data")
file.remove(destfile)
