# Masculinity index (human-sex ratio outside hispanic countries) script for Census of Population and Housing (CPV) ages for years 2010 and
# 2020 in Iztacalco, Mexico City. 
# Data from: https://en.www.inegi.org.mx/
# The purpose of this script is to get the Masculinity index from a quinquenial grouped inegi formated
# dataframe. 
#
# Made by: https://github.com/artrx86

# Package Handling ---------------------------
library(dplyr)

# Masculinity index -------------------------
get_masc_index_df <- function(inegi_quinquenial_df = data.frame()) {
    # Returns masculinity index from an Inegi quintenial dataframe formated dataframe with the following
    # structure as input:
    # | starting_age [int/num] | ending_age [int/num] | males [int/num] | females [int/num] | 
    #
    # Used formula:
    # IM_{(5i)-(5i+4)}= P^M_{(5i)-(5i+4)}/ P^F_{(5i)-(5i+4)} * 100
    # i \in \{0, 1, 2, 3, ..., 16\} and 85+ group

    masc_index_df <- inegi_quinquenial_df

    # Apply the formula for every row 
    masc_index_df$masculinity_index <- (masc_index_df$males / masc_index_df$females) * 100

    masc_index_df <- masc_index_df %>% select("starting_age", "ending_age", "masculinity_index")

    return(masc_index_df)
}

