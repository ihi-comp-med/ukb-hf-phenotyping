# R script for step1 phenotyping

input <- snakemake@input
config <- snakemake@config
output <- snakemake@output

library(tidyverse)
library(vroom)

# for interactive / testing
# config <- yaml::read_yaml("workflow/config.yaml")
# input <- list(hesin_diag = "resources/data/hesin_diag.txt",
#               hesin_oper = "resources/data/hesin_oper.txt",
#               death_cause = "resources/data/death_cause.txt")
# input$code_lists <- glue::glue("{config$dir_codelist}{names(config$step1_pheno)}.tsv")
# output <- "results/pheno_step1.tsv"

data_sources <- c("hesin_diag", "death_cause", "hesin_oper")
target_dict <- c("icd10", "icd9", "opcs4")
target_phenos <- names(config$step1_pheno)

read_data <- function(file, data_source){
  cols <- config$data_spec[[data_source]] %>% .[grepl("^col_", names(.))]
  vroom(file, col_select = all_of(as.character(cols)), na = "") %>% 
    set_names(str_remove_all(names(cols), "^col_")) %>% 
    pivot_longer(cols = -eid, names_to = "dict", values_to = "code") %>% 
    filter(!is.na(code)) %>% 
    mutate(source = data_source)
}

data <- map2_df(input[data_sources], data_sources, read_data) %>% 
  distinct()

step1_phenos <- basename(input$code_lists) %>% str_remove_all("\\.tsv$")
code_lists <- map(input$code_lists, vroom) %>%
  set_names(step1_phenos)

code_search <- function(pheno){
  code_list <- code_lists[[pheno]] %>%
    mutate(Dict = tolower(Dict),
           Code = str_remove_all(Code, "\\.(?=[0-9])")) %>% 
    filter(Dict %in% target_dict) %>% 
    group_by(Dict) %>%
    nest() %>% 
    mutate(regexp = map_chr(data, ~paste0("^(", paste(.x[["Code"]], collapse = "|"), ")$"))) %>% 
    select(Dict, regexp) %>% 
    deframe
    
  sources <- if (config$step1_pheno_data[[pheno]][1] == "ALL") {
    data_sources 
  } else config$step1_pheno_data[[pheno]]
  
  data %>% 
    filter(source %in% sources,
           str_detect(code, code_list[dict])) %>% 
    distinct(eid) %>% 
    mutate(diag = pheno)
}

df_case <- map_df(target_phenos, code_search) %>% mutate(value = 1)

df_case_wide <- data %>% 
  distinct(eid) %>% 
  left_join(df_case, by = "eid")  %>% 
  pivot_wider(id_cols = eid, names_from = diag, values_fill = 0) %>% 
  select(-`NA`)

dir.create(dirname(output), showWarnings = F, recursive = T)
vroom_write(df_case_wide, output)
