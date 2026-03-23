# Main script. 
# The purpose of this script is to call every stage of the data processing pipeline.
# IMPORTANT: This file location has to be set as the working directory when executed in shell.
# Made by: https://github.com/artrx86

# Package Handling ---------------------------

# Package names
packages <- c("this.path", "readxl")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading (hidden output)
invisible(lapply(packages, library, character.only = TRUE))

# Source calls (script imports) ---------------------------
source("src/0-data-extract.R")

# Main function ---------------------------
main <- function() {

    # if using R IDE try to change working directory to this script location
    tryCatch({ 
	setwd(this.path::here())
    }, error = function(e) {
    })

    # call the scripts functions
    pop_ages_df2020 <- cpv_ages_to_csv(filename = "data/raw/cpv2020_b_cdmx_01_poblacion.xlsx",
					year = 2020,
					output_file="data/processed/2020_pop_ages.csv")
    
    pop_ages_df2010 <- cpv_ages_to_csv(filename = "data/raw/01_03B_MUNICIPAL_09.xls",
					year = 2010,
					output_file="data/processed/2010_pop_ages.csv")
}

main()
