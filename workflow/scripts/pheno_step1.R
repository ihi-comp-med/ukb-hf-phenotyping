# R script for step1 phenotyping

input <- snakemake@input
config <- snakemake@config
output <- snakemake@output

library(data.table)

# for interactive / testing
config <- read_yaml("workflow/config.yaml")
input <- list(hesin_diag = "resources/data/hesin_diag.txt",
              hesin_oper = "resources/data/hesin_oper.txt",
              death_cause = "resources/data/death_cause.txt")
input$code_lists <- fs::dir_ls("resources/code_list")
hesin_diag <- fread(input$d)
