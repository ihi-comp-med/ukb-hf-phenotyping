# R script for step1 phenotyping

input <- snakemake@input
config <- snakemake@config
output <- snakemake@output

library(data.table)
library(tidyverse)

# for interactive / testing
config <- yaml::read_yaml("workflow/config.yaml")
input <- list(hesin_diag = "resources/data/hesin_diag.txt",
              hesin_oper = "resources/data/hesin_oper.txt",
              death_cause = "resources/data/death_cause.txt")
input$code_lists <- glue::glue("{config$dir_codelist}{names(config$step1_pheno)}.tsv")

read_data <- function(data){
  cols <- config$data_spec[data] %>% keep(str_detect("^col_"))
}
data <- map(input, fread)

step1_phenos <- basename(input$code_lists) %>% str_remove_all("\\.tsv$")
code_lists <- map(input$code_lists, fread) %>%
  set_names(step1_phenos)

code_search <- function(data, code)
