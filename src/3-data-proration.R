# Data proration script for Census of Population and Housing (CPV) ages for years 2010 and
# 2020 in Iztacalco, Mexico City. 
# Data from: https://en.www.inegi.org.mx/
# The purpose of this script is to evaluate the data quality by using UN, Whipple and Myers indexes. 
#
# Made by: https://github.com/artrx86

# Package Handling ---------------------------
library(dplyr)

# Concentration percentages ---------------------------
get_concentration_percentages <- function(inegi_df = data.frame()) {

    # Function to get the concentration percentages of every age group and sex to make the proration calculations
    # Returns the concentration percentages for each sex as a vector: 
    # c(male_concentration_percentage, female_concentration_percentage)  
    #
    # To calculate every weight we'll use the formula:
    # \alpha = unspecified_population / total_population - unspecified_population
    #
    # An INEGI formated dataframe with the following structure is required as input (inegi_df):
    # | EDAD [string] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    
    # get the unspecified population for every column (in this format is on the last column
    male_unspecified   <- as.numeric(inegi_df[nrow(inegi_df), "HOMBRES"])
    female_unspecified <- as.numeric(inegi_df[nrow(inegi_df), "MUJERES"])
    
    # now get the value of total population for each sex at the time removing the unspecified row values
    # (equivalent to total_population - unspecified_population)
    # first we will get the dataframe without the unspecified row
    inegi_df_no_unspec <- inegi_df %>% head(-1)

    # now we will make the sum of all the values in the males and females columns and save the result into
    # a variable for each gender
    male_total_no_unspec   <- sum(inegi_df_no_unspec$HOMBRES) 
    female_total_no_unspec <- sum(inegi_df_no_unspec$MUJERES) 

    # finally get the concentration percentage in each sex by using the formula:
    male_concentration_percentage   <- male_unspecified / (male_total_no_unspec) 
    female_concentration_percentage <- female_unspecified / (female_total_no_unspec)  

    # put both values into a vector for posterior use
    concentration_percentage_vector <- c(male_concentration_percentage, female_concentration_percentage) 
    
    return(concentration_percentage_vector)
}


# Proration of the unspecified values ---------------------------
get_proration_df <- function(inegi_df = data.frame()) {
    
    # Function to get the prorated unspecified values distributed on every age group and sex
    # as a dataframe in the same format as the input dataframe.
    #
    # Returns the concentration percentages for each sex as a vector: 
    # c(male_concentration_percentage, female_concentration_percentage)  
    #
    # To calculate every weight we'll use the formula:
    # \hat{P}_i = Pi + Pi * \alpha
    #
    # An INEGI formated dataframe with the following structure is required as input (inegi_df):
    # | EDAD [string] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
   
    # get the concentration percentages for male and females population groups
    concentration_percentages_vector <- get_concentration_percentages(inegi_df)
    male_concentration_percentages <- concentration_percentages_vector[1] 
    female_concentration_percentages <- concentration_percentages_vector[2] 

    # get the columns from age, male population and female population and remove the unespecified row
    proration_df <- inegi_df %>% select("EDAD", "HOMBRES", "MUJERES") %>% head(-1) 

    # apply the formula to male population and female population cells
    proration_df["HOMBRES"] <- lapply(proration_df["HOMBRES"],
						    function(x){x + (x * male_concentration_percentages)})

    proration_df["MUJERES"] <- lapply(proration_df["MUJERES"],
						    function(x){x + (x * female_concentration_percentages)})

    # create a column with the sum of both prorated age groups so we get "POB_TOTAL" column again
    proration_df$POB_TOTAL <- proration_df$HOMBRES + proration_df$MUJERES
    
    # reorganize columns
    proration_df <- proration_df %>% select("EDAD", "POB_TOTAL", "HOMBRES", "MUJERES")
    
    return (proration_df)
}

# Validation of the proration values
do_proration_validation <- function(original_df = data.frame(), prorated_df = data.frame()) {
    # Function to validate the proration dataframe values checking if the total popultation for
    # both sexes is still the same.
    #
    # INEGI formated dataframes with the following structure are required as input (original_df, prorated_df):
    # | EDAD [string] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    #
    # Returns TRUE if the validations are passed, else, it will return FALSE 

    if ((sum(original_df$HOMBRES) == sum(prorated_df$HOMBRES)) &
	(sum(original_df$MUJERES) == sum(prorated_df$MUJERES))) {

	return ("passed")

    } else {

	return ("unpassed")
    }
}

