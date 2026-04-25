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
source("src/4-masculinity-index.R")
source("src/5-dependency-index.R")
source("src/6-spline-quadrature-factor.R")
source("src/7-population-growth-projection.R")

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
get_whipple_index(ages_df = pop_ages_df2020, gender = "male") # male whipple's index for 2020: 121.3968
get_whipple_index(ages_df = pop_ages_df2020, gender = "female") # female whipple's index for 2020: 120.0111
get_whipple_index(ages_df = pop_ages_df2020, gender = "both") # both genders whipple's index for 2020: 120.667

get_whipple_index(ages_df = pop_ages_df2010, gender = "male") # male whipple's index for 2010: 117.4276
get_whipple_index(ages_df = pop_ages_df2010, gender = "female") # female whipple's index for 2010: 118.0947
get_whipple_index(ages_df = pop_ages_df2010, gender = "both") # both genders whipple's index for 2010: 117.7829

# Myers' index
get_myers_index(ages_df = pop_ages_df2020, gender = "male") # male Myers' index for 2020: 9.422554 
get_myers_index(ages_df = pop_ages_df2020, gender = "female") # female Myers' index for 2020: 9.218148 
get_myers_index(ages_df = pop_ages_df2020, gender = "both") # both genders Myers' index for 2020: 9.315056

get_myers_index(ages_df = pop_ages_df2010, gender = "male") # male Myers' index for 2010: 8.88766 
get_myers_index(ages_df = pop_ages_df2010, gender = "female") # female Myers' index for 2010: 8.614865
get_myers_index(ages_df = pop_ages_df2010, gender = "both") # both genders Myers' index for 2010: 8.743216

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

# Masculinity (sex-ratio) Index ---------------------------
# Group prorated dataframe by quinquenials 
prorated_pop_ages_quin_df2020 <- get_quinquenial_format_df(ages_df = prorated_pop_ages_df2020)
prorated_pop_ages_quin_df2010 <- get_quinquenial_format_df(ages_df = prorated_pop_ages_df2010)

masc_index_df2020 <- get_masc_index_df(prorated_pop_ages_quin_df2020)
masc_index_df2010 <- get_masc_index_df(prorated_pop_ages_quin_df2010)

# Visualization of the dataframes
View(masc_index_df2020)
View(masc_index_df2010)

# Dependency Ratio ---------------------------
# Dependency ratio for 2020
get_dependency_index(prorated_pop_ages_quin_df2020, gender = "male") # 40.48327
get_dependency_index(prorated_pop_ages_quin_df2020, gender = "female") # 42.19211
get_dependency_index(prorated_pop_ages_quin_df2020, gender = "both") # 41.37474

# Dependency ratio for 2010
get_dependency_index(prorated_pop_ages_quin_df2010, gender = "male") # 44.40538 
get_dependency_index(prorated_pop_ages_quin_df2010, gender = "female") # 43.99956
get_dependency_index(prorated_pop_ages_quin_df2010, gender = "both") # 44.19202 

# Spline function application ---------------------------
# first we make the prorated_pop_ages_df2020 graph to apply the spline in a more visual way 
plot(seq(0,100), prorated_pop_ages_df2020$HOMBRES[1:101], pch = 16, col = "violet", main = "males")
plot(seq(0,100), prorated_pop_ages_df2020$MUJERES[1:101], pch = 16, col = "violet", main = "females")

# now we make the same with the 2010 data
plot(seq(0,100), prorated_pop_ages_df2010$HOMBRES[1:101], pch = 16, col = "violet", main = "males")
plot(seq(0,100), prorated_pop_ages_df2010$MUJERES[1:101], pch = 16, col = "violet", main = "females")

# apply spline to the dataframes
spline_2020df_males <- get_spline_df(prorated_pop_ages_df2020, "males", 0.425)
spline_2020df_females <- get_spline_df(prorated_pop_ages_df2020, "females", 0.425)

spline_2010df_males <- get_spline_df(prorated_pop_ages_df2010, "males", 0.425)
spline_2010df_females <- get_spline_df(prorated_pop_ages_df2010, "females", 0.425)

# graphs to check how smooth is the spline
plot(seq(0,101), prorated_pop_ages_df2020$HOMBRES, type = "l", pch = 16, col = "violet", main = "males")
lines(spline_2020df_males, col = "blue", lwd = 2)

plot(seq(0,101), prorated_pop_ages_df2020$MUJERES, type = "l", pch = 16, col = "violet", main = "females")
lines(spline_2020df_females, col = "blue", lwd = 2)

plot(seq(0,101), prorated_pop_ages_df2010$HOMBRES, type = "l", pch = 16, col = "violet", main = "males")
lines(spline_2010df_males, col = "blue", lwd = 2)

plot(seq(0,101), prorated_pop_ages_df2010$MUJERES, type = "l", pch = 16, col = "violet", main = "females")
lines(spline_2010df_females, col = "blue", lwd = 2)

spline_corrected_2020df <- data.frame(EDAD = spline_2020df_males$x,
				      POB_TOTAL = (spline_2020df_males$y + spline_2020df_females$y),
				      HOMBRES = spline_2020df_males$y,
				      MUJERES = spline_2020df_females$y)

spline_corrected_2010df <- data.frame(EDAD = spline_2010df_males$x,
				      POB_TOTAL = (spline_2010df_males$y + spline_2010df_females$y),
				      HOMBRES = spline_2010df_males$y,
				      MUJERES = spline_2010df_females$y)

# Quadrature factor application ---------------------------
quadrature_factor_2020df <- get_quadrature_factor_df(corrected_inegi_df = spline_corrected_2020df,
						     inegi_df = prorated_pop_ages_df2020) 
quadrature_factor_2010df <- get_quadrature_factor_df(corrected_inegi_df = spline_corrected_2010df,
						     inegi_df = prorated_pop_ages_df2010) 
# visualization 
View(quadrature_factor_2020df)
View(quadrature_factor_2010df)

# validation tests
print(do_quadrature_factor_validation(quadrature_factor_inegi_df = quadrature_factor_2020df,
				      inegi_df = prorated_pop_ages_df2020))

print(do_quadrature_factor_validation(quadrature_factor_inegi_df = quadrature_factor_2010df,
				      inegi_df = prorated_pop_ages_df2010))

# Poblational Pyramid Pt. 2 ---------------------------

# convert quadrature_factor_20XXdf to quinquenial formating
quadrature_factor_quin_2020df <-  get_quinquenial_format_df(ages_df = quadrature_factor_2020df)
			
quadrature_factor_quin_2010df <-  get_quinquenial_format_df(ages_df = quadrature_factor_2010df)

View(quadrature_factor_quin_2020df)
View(quadrature_factor_quin_2010df)

quadrature_factor_quin_pyramid_2020df <- quadrature_factor_quin_2020df
quadrature_factor_quin_pyramid_2010df <- quadrature_factor_quin_2010df

quadrature_factor_quin_pyramid_2020df$age <- paste(sprintf("%02d",
							   quadrature_factor_quin_2020df$starting_age),
						   "-", 
						   sprintf("%02d",quadrature_factor_quin_2020df$ending_age))

quadrature_factor_quin_pyramid_2010df$age <- paste(sprintf("%02d",
							   quadrature_factor_quin_2010df$starting_age),
						   "-", 
						   sprintf("%02d",quadrature_factor_quin_2010df$ending_age))

# select the columns to use
quadrature_factor_quin_pyramid_2020df <- quadrature_factor_quin_pyramid_2020df %>% select("EDAD"="age",
									  "MUJERES" = "females",
									  "HOMBRES" = "males") 

quadrature_factor_quin_pyramid_2010df <- quadrature_factor_quin_pyramid_2010df %>% select("EDAD"="age",
									  "MUJERES" = "females",
									  "HOMBRES" = "males") 

# get the pyramids
quadrature_factor_quin_pyramid_2020 <- graph_pop_pyramid(inegi_df = quadrature_factor_quin_pyramid_2020df)
quadrature_factor_quin_pyramid_2010 <- graph_pop_pyramid(inegi_df = quadrature_factor_quin_pyramid_2010df)

quadrature_factor_quin_pyramid_2020
quadrature_factor_quin_pyramid_2010

# Population Growth  ---------------------------
date_2020_census <- as.Date("2020-03-15")
date_2010_census <- as.Date("2010-06-12")

years_passed_btwn_census <-  as.numeric(difftime(date_2020_census, date_2010_census, units = "days") / 365)

# getting population growth rates (9.76 aprox. years in this case)

geometric_pg_2010_2020_rate_df <- get_geometric_pg_rate(inegi_quinquenial_df = quadrature_factor_quin_2010df, comparison_df = quadrature_factor_quin_2020df, years_passed=years_passed_btwn_census)
exponential_pg_2010_2020_rate_df <- get_exponential_pg_rate(inegi_quinquenial_df = quadrature_factor_quin_2010df, comparison_df = quadrature_factor_quin_2020df, years_passed=years_passed_btwn_census)

View(geometric_pg_2010_2020_rate_df)
View(exponential_pg_2010_2020_rate_df)

# Getting population projections 

# up to 2015-06-30 from 2010-06-12

date_2015_projection <- as.Date("2015-06-30")

projection_2010_2015_years_passed <- as.numeric(difftime(date_2015_projection, 
							 date_2010_census,
							 units = "days") / 365)

geom_projection_2010_2015_df <- get_geometric_pg_projection(inegi_quinquenial_df = quadrature_factor_quin_2010df,
						       projection_rates_df = geometric_pg_2010_2020_rate_df,
						       years_projection_time = projection_2010_2015_years_passed) 

exp_projection_2010_2015_df <- get_exponential_pg_projection(inegi_quinquenial_df = quadrature_factor_quin_2010df,
			    projection_rates_df = exponential_pg_2010_2020_rate_df,
			    years_projection_time = projection_2010_2015_years_passed) 

# up to 2015-06-30 from 2010-06-12
date_2020_projection <- as.Date("2020-06-30")

projection_2020_2020_years_passed <- as.numeric(difftime(date_2020_projection, 
							 date_2020_census,
							 units = "days") / 365)

geom_projection_2020_2020_df <- get_geometric_pg_projection(inegi_quinquenial_df = quadrature_factor_quin_2020df,
						       projection_rates_df = geometric_pg_2010_2020_rate_df,
						       years_projection_time = projection_2020_2020_years_passed) 

exp_projection_2020_2020_df <- get_exponential_pg_projection(inegi_quinquenial_df = quadrature_factor_quin_2020df,
			    projection_rates_df = exponential_pg_2010_2020_rate_df,
			    years_projection_time = projection_2020_2020_years_passed) 

# Data visualization

# Pre-Projected dataframes

View(quadrature_factor_quin_2010df)		
View(quadrature_factor_quin_2020df)	

# Projections up to 2015-06-30		      	
View(geom_projection_2010_2015_df)	
View(exp_projection_2010_2015_df) 			 

# Projections to 2020-06-30		
View(geom_projection_2020_2020_df)	
View(exp_projection_2020_2020_df) 	

# why geometric and exponential growth assumptions
# yields the same population projections: 
# https://pubmed.ncbi.nlm.nih.gov/12159257/

