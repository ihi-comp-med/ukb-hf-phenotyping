# R script for step2 phenotyping

input <- snakemake@input
config <- snakemake@config
output <- snakemake@output[[1]]

library(tidyverse)
library(data.table)
# library(vroom)

# for interactive / testing
# config <- yaml::read_yaml("config.yaml")
# input <- list(pheno_step1 = "results/pheno_step1.txt",
#               lvef = "resources/data/lvef_derived.txt")
# output <- "results/ukb_hf_pheno_derived.txt"

df_pheno_step1 <- fread(input$pheno_step1) %>%
  mutate(secondaryHF = ifelse(MI == 1 | congHD == 1 | valveHD == 1, 1, 0))

# check descriptive stats
df_lvef <- fread(input$lvef,
                 select = config$data_spec$lvef %>% .[str_detect(names(.), "^col")] %>% as.character)
setnames(df_lvef, names(config$data_spec$lvef) %>% .[str_detect(., "^col")] %>% str_remove_all("^col_"))

df <- df_lvef[df_pheno_step1, on = "eid"]

# df_lvef <- vroom(input$lvef, delim = "\t",
#                  col_select = config$data_spec$lvef %>% .[str_detect(names(.), "^col")] %>% as.character) %>%
#            set_names(names(config$data_spec$lvef) %>% .[str_detect(., "^col")] %>% str_remove_all("^col_"))
#
# df <- left_join(df_pheno_step1, df_lvef, by = "eid")

# perform step 2 phenotyping
df_pheno_step2 <- df %>%
  mutate(LVSD = ifelse(lvef < 50 | LVSD == 1, 1, 0)) %>%
  mutate(across(HF:secondaryHF, ~replace_na(.x, 0) %>%  as.logical)) %>%
  mutate(pheno1 = case_when(HF ~ "case",
                            !HF ~ "control",
                            TRUE ~ "exclude"),
         pheno2 = case_when(secondaryHF ~ "exclude",
                            HF & !secondaryHF ~ "case",
                            !HF & !secondaryHF ~ "control",
                            TRUE ~ "exclude"),
         pheno3 = case_when(secondaryHF ~ "exclude",
                            HF & !secondaryHF & !LVSD ~ "exclude",
                            HF & !secondaryHF & LVSD ~ "case",
                            !HF & !secondaryHF ~ "control",
                            TRUE ~ "exclude"),
         pheno4 = case_when(secondaryHF ~ "exclude",
                            HF & !secondaryHF & !LVSD & lvef < 50 ~ "exclude",
                            HF & !secondaryHF & !LVSD & lvef >= 50 ~ "case",
                            !HF & !secondaryHF ~ "control",
                            TRUE ~ "exclude"),
         pheno5 = case_when(secondaryHF ~ "exclude",
                            HF & !secondaryHF & !LVSD ~ "exclude",
                            !secondaryHF & LVSD ~ "case",
                            !HF & !secondaryHF & !LVSD ~ "control",
                            TRUE ~ "exclude"),
         pheno6 = case_when(LVSD ~ "case",
                            HF & !LVSD ~ "exclude",
                            !HF & !LVSD ~ "control",
                            TRUE ~ "exclude")) %>%
  mutate(across(HF:secondaryHF, as.numeric))

# write to output
dir.create(dirname(output), showWarnings = F, recursive = T)
fwrite(df_pheno_step2, output, sep = "\t")
