# Dependency index script for Census of Population and Housing (CPV) ages for years 2010 and
# 2020 in Iztacalco, Mexico City. 
# Data from: https://en.www.inegi.org.mx/
# The purpose of this script is to get the Masculinity index from a quinquenial grouped inegi formated
# dataframe. 
#
# Made by: https://github.com/artrx86

# Package Handling ---------------------------
library(dplyr)

# Dependency index -------------------------
get_dependency_index <- function(inegi_quinquenial_df = data.frame(), gender="both") {
    # Returns Dependency index from an Inegi quintenial dataframe formated dataframe with the following
    # structure as input:
    # | starting_age [int/num] | ending_age [int/num] | males [int/num] | females [int/num] | 
    #
    # Used formula:
    # RD = P_{0-14} + P_{65+} / P_{15-64} * 100


    if (gender == "both") {

	# Sum of both genders
	both_genders <- (inegi_quinquenial_df$males + inegi_quinquenial_df$females)

	# apply the formula
	dependency_index <- sum(both_genders[c(1:3, 14:18)]) / sum(both_genders[4:13]) * 100

    } else if (gender == "male") {

	males <- inegi_quinquenial_df$males 
	
	# apply the formula
	dependency_index <- sum(males[c(1:3, 14:18)]) / sum(males[4:13]) * 100

    } else if (gender == "female") {

	females <- inegi_quinquenial_df$females 

	# apply the formula
	dependency_index <- sum(females[c(1:3, 14:18)]) / sum(females[4:13]) * 100
    }

    return (dependency_index)
}

