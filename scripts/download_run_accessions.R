library(httr)
library(glue)
library(dplyr)
library(readr)
library(tidyr)
library(stringr)
library(xml2)
library(readxl)
library(here)

project <- "PRJNA399742"
study <- "SRP116709"

#' Retrieve fastq file info and urls
r <- GET(glue("http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession={study}&result=read_run"))
read_run <- content(r, encoding = "UTF-8") %>% read_delim(delim = "\t")


all_samples <- read_run %>% 
  select(experiment_title, run_accession, fastq_ftp, read_count, base_count, fastq_bytes, fastq_md5) %>% 
  separate(fastq_ftp, into = c("fq1", "fq2"), sep = ";") %>% 
  separate(fastq_bytes, into = c("fq1_bytes", "fq2_bytes"), sep = ";") %>%
  separate(fastq_md5, into = c("fq1_md5", "fq2_md5"), sep = ";") %>% 
  rename(sample = run_accession)

shotgun <- filter(all_samples, str_detect(experiment_title, "shotgun"))

#' Runs and samples
url <- glue("https://www.ebi.ac.uk/ena/data/view/{project}&portal=read_run&display=xml")
r <- GET(url)
read_run <- content(r, encoding = "UTF-8")
contents <- read_run %>% 
  read_xml() %>% 
  xml_contents()

alias <- contents %>% 
  xml_attrs() %>% 
  do.call(rbind, .) %>% 
  as_tibble()

acc_sample <- alias %>%
  filter(str_detect(alias, "shotgun")) %>% 
  mutate(subject = str_replace(alias, "TGshotgun_(\\d+).R\\d\\.fastq.gz", "\\1")) %>% 
  select(sample = accession, subject)

samples <- left_join(acc_sample, shotgun)

read_excel(here("data/aao3290_Matson_SM-Table-S5.xlsx"), sheet = 2, col_names = TRUE)


write_delim(shotgun, here("output/samples_remote.tsv"), delim = "\t")

