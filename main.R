# Main script. 
# The purpose of this script is to call every stage of the data processing pipeline.
# IMPORTANT: This file location has to be set as the working directory when executed in shell.
# Made by: https://github.com/artrx86

# Package Handling ---------------------------

# Package names
packages <- c("this.path", "readxl", "ggplot2", "dplyr")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading (hidden output)
invisible(lapply(packages, library, character.only = TRUE))

# Source calls (script imports) ---------------------------
source("src/0-data-extract.R")
source("src/1-data-evaluation-population-pyramid.R")
source("src/2-data-evaluation-age-eval-indexes.R")
source("src/3-data-proration.R")

# if using R IDE try to change working directory to this script location
tryCatch({ 
    setwd(this.path::here())
}, error = function(e) {
})

# call the scripts functions

# Data extraction ---------------------------

pop_ages_df2020 <- cpv_ages_to_csv(filename = "data/raw/cpv2020_b_cdmx_01_poblacion.xlsx",
    				year = 2020,
    				output_file="data/processed/2020_pop_ages.csv")

pop_ages_df2010 <- cpv_ages_to_csv(filename = "data/raw/01_03B_MUNICIPAL_09.xls",
    				year = 2010,
    				output_file="data/processed/2010_pop_ages.csv")


# Evaluation ---------------------------

# population pyramids graphication 
pop_ages_pyramid2020 <- graph_pop_pyramid(inegi_df = pop_ages_df2020)
pop_ages_pyramid2010 <- graph_pop_pyramid(inegi_df = pop_ages_df2010)

# Visualization (recomended at 1080p resolution per image)
pop_ages_pyramid2020
pop_ages_pyramid2010

# Whipple's index
get_whipple_index(ages_df = pop_ages_df2020, genre = "male") # male whipple's index for 2020: 121.3968
get_whipple_index(ages_df = pop_ages_df2020, genre = "female") # female whipple's index for 2020: 120.0111
get_whipple_index(ages_df = pop_ages_df2020, genre = "both") # both genders whipple's index for 2020: 120.667

get_whipple_index(ages_df = pop_ages_df2010, genre = "male") # male whipple's index for 2010: 117.4276
get_whipple_index(ages_df = pop_ages_df2010, genre = "female") # female whipple's index for 2010: 118.0947
get_whipple_index(ages_df = pop_ages_df2010, genre = "both") # both genders whipple's index for 2010: 117.7829

# Myers' index
get_myers_index(ages_df = pop_ages_df2020, genre = "male") # male Myers' index for 2020: 9.422554 
get_myers_index(ages_df = pop_ages_df2020, genre = "female") # female Myers' index for 2020: 9.218148 
get_myers_index(ages_df = pop_ages_df2020, genre = "both") # both genders Myers' index for 2020: 9.315056

get_myers_index(ages_df = pop_ages_df2010, genre = "male") # male Myers' index for 2010: 8.88766 
get_myers_index(ages_df = pop_ages_df2010, genre = "female") # female Myers' index for 2010: 8.614865
get_myers_index(ages_df = pop_ages_df2010, genre = "both") # both genders Myers' index for 2010: 8.743216

# From right here we'll work with quinquenial age groups for some calculations
pop_ages_quin_df2020 <- get_quinquenial_format_df(ages_df = pop_ages_df2020)
pop_ages_quin_df2010 <- get_quinquenial_format_df(ages_df = pop_ages_df2010)

# United Nations index
get_un_age_accuracy_index(ages_df = pop_ages_quin_df2020) # United Nations index for 2020: 15.40797
get_un_age_accuracy_index(ages_df = pop_ages_quin_df2010) # United Nations index for 2010: 18.33055

# Data proration ---------------------------

# prorated ages by gender dataframe: 
prorated_pop_ages_df2020 <- get_proration_df(pop_ages_df2020)
prorated_pop_ages_df2010 <- get_proration_df(pop_ages_df2010)

# Dataframes visualization
View(prorated_pop_ages_df2020)
View(prorated_pop_ages_df2010) 

# Validation that checks if totals are still the same
do_proration_validation(original_df = pop_ages_df2020, prorated_df = prorated_pop_ages_df2020)
do_proration_validation(original_df = pop_ages_df2010, prorated_df = prorated_pop_ages_df2010)

