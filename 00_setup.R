## ===============================
## 00_setup.R — global settings
## ===============================

# Clean workspace
rm(list = ls())

# Seed for reproducibility 
seed <- 444
set.seed(seed)

## Load libraries 
required_packages <- c(
"tidyverse","igraph","haven","tibble","reshape2","tryCatchLog",
"futile.logger","dplyr","tidyr","furrr","doParallel","iterators",
"parallel","progress","doSNOW","progress","sjmisc","Publish","here")

# Function to install (if missing) and load packages
load_pkg <- function(pkg){
  if (!require(pkg, character.only = TRUE)) {
    message("Install: ", pkg)
    if (pkg == "ggtree") {
      if (!requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager", dependencies = TRUE)
      }
      BiocManager::install("ggtree", ask = FALSE, update = TRUE)
      
    } else {
      install.packages(pkg, dependencies = TRUE)
    }
    if (!require(pkg, character.only = TRUE)) {
      warning("This package are not installed: ", pkg)
    }
  }
}

invisible(
  suppressWarnings(
    suppressPackageStartupMessages(
      suppressMessages(
        sapply(required_packages, load_pkg)
      )
    )
  )
)

# Suppress life cycle warnings
Sys.setenv(LIFECYCLE_WARNINGS = "quiet")

## Conflict preferences
## Define Directories 
dir_raw  <- "data"
dir_proc <- "data/processed"
dir_figs    <- here::here("output", "figures")
dir_tabs    <- here::here("output", "tables")

# Create directories if they don't exist
dirs_list <- c(dir_raw, dir_proc, dir_figs, dir_tabs)
sapply(dirs_list, function(x) if(!dir.exists(x)) dir.create(x, recursive = TRUE))

# Table packages
info_sesion <- sessionInfo()
char_packages <- names(info_sesion$otherPkgs)

get_cite <- function(pkg){
  cit <- citation(pkg)
  if(length(cit) > 0){
    format(cit[[1]], style = "text") 
  } else {
    "R Core Team"
  }
}

tabla_pkgs <- data.frame(
  Library = char_packages,
  Version = sapply(char_packages, function(x) as.character(packageVersion(x))),
  #Citation = sapply(char_packages, get_cite),
  row.names = NULL
)

table_pkgs <- tabla_pkgs[order(tabla_pkgs$Library), ] #alphabetic format

if (requireNamespace("knitr", quietly = TRUE)) {
  latex_table <- knitr::kable(table_pkgs, 
                              format = "latex", 
                              booktabs = TRUE,
                              caption = "R packages used in this article",
                              label = "tab:packages",
                              row.names = FALSE)
  cat(latex_table, file = file.path(dir_tabs, "table_packages.tex"))
}#LaTeX format
