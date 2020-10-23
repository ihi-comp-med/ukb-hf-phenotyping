# R script for step2 phenotyping

input <- snakemake@input
config <- snakemake@config
output <- snakemake@output[[1]]

library(tidyverse)
library(vroom)

# for interactive / testing
# config <- yaml::read_yaml("config.yaml")
# input <- list(pheno_step1 = "results/pheno_step1.tsv",
#               lvef = "resources/data/lvef_derived.txt")
# output <- "results/ukb_hf_pheno_derived.txt"

df_pheno_step1 <- vroom(input$pheno_step1, delim = "\t") %>%
  mutate(secondaryHF = ifelse(MI == 1 | congHD == 1 | valveHD == 1, 1, 0))

# check descriptive stats

df_lvef <- vroom(input$lvef, delim = "\t",
                 col_select = config$data_spec$lvef %>% .[str_detect(names(.), "^col")] %>% as.character) %>%
           set_names(names(config$data_spec$lvef) %>% .[str_detect(., "^col")] %>% str_remove_all("^col_"))

df <- left_join(df_pheno_step1, df_lvef, by = "eid")

# perform step 2 phenotyping
df_pheno_step2 <- df %>%
  mutate(LVSD = ifelse(lvef < 50 | LVSD == 1, 1, 0)) %>%
  mutate(across(MI:secondaryHF, ~replace_na(.x, 0) %>%  as.logical)) %>%
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
                            TRUE ~ "exclude")) %>%
  mutate(across(MI:secondaryHF, as.numeric))

# write to output
dir.create(dirname(output), showWarnings = F, recursive = T)
vroom_write(df_pheno_step2, output, delim = "\t")
