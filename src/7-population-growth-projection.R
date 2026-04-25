# Population growth rate and projections tools script for Census of Population and Housing (CPV)
# ages for years 2010 and 2020 in Iztacalco, Mexico City. 
# Data from: https://en.www.inegi.org.mx/
# The purpose of this script is to get the  
# dataframe. 
#
# Made by: https://github.com/artrx86

# Package Handling ---------------------------
library(dplyr)

# Population growth rates getters ------------------------
get_geometric_pg_rate <- function(inegi_quinquenial_df = data.frame(),
				  comparison_df = data.frame(),
				  years_passed = numeric()) {
    # Gets the population growth rate considering a geometric population growing
    # between two INEGI quinquenial formated dataframes with the following
    # structure required as input (inegi_quinquenial_df, comparison_df):
    # | starting_age [int/num] | ending_age [int/num] | males [int/num] | females [int/num] | 
    # Should be ordered from the first to last (inegi_quinquenial_df[first, ex: 2010], comparison_df[last, ex: 2020])

    # get the structure of inegi_quinquenial_df
    geometric_pg_rate_df <- inegi_quinquenial_df

    # make the calculations based on the geometrical rate formula (r_{g,i} = (P_{t+n, i} / P_{t, i})^{1/n} - 1)
    geometric_pg_rate_df$males <- (( comparison_df$males / inegi_quinquenial_df$males ) ^ ( 1 / years_passed)) - 1 
    geometric_pg_rate_df$females <- (( comparison_df$females / inegi_quinquenial_df$females ) ^ ( 1 / years_passed)) - 1 
    
    return(geometric_pg_rate_df)
}

get_exponential_pg_rate <- function(inegi_quinquenial_df = data.frame(),
				    comparison_df = data.frame(),
				    years_passed = numeric()) {
    # Gets the population growth rate considering an exponential population growing
    # between two INEGI quinquenial formated dataframes with the following
    # structure required as input (inegi_quinquenial_df, comparison_df):
    # | starting_age [int/num] | ending_age [int/num] | males [int/num] | females [int/num] | 
    # Should be ordered from the first to last (inegi_quinquenial_df[first, ex: 2010], comparison_df[last, ex: 2020])

    # get the structure of inegi_quinquenial_df
    exponential_pg_rate_df <- inegi_quinquenial_df

    # make the calculations based on the exponential rate formula (r_{e,i} = ln(\frac{P_{t+n, i}}{P_{t, i}}) / n)
    exponential_pg_rate_df$males <- (log( comparison_df$males / inegi_quinquenial_df$males )) / years_passed
    exponential_pg_rate_df$females <- (log( comparison_df$females / inegi_quinquenial_df$females )) / years_passed    

    return(exponential_pg_rate_df)
}

# Population growth projections getters ------------------------
get_geometric_pg_projection <- function(inegi_quinquenial_df = data.frame(),
					projection_rates_df = data.frame(),
					years_projection_time = numeric()) {
    # Generates a Population growth projection considering a geometric population growing
    # between two INEGI quinquenial formated dataframes with the following
    # structure required as input (inegi_quinquenial_df, projection_rates_df):
    # | starting_age [int/num] | ending_age [int/num] | males [int/num] | females [int/num] | 
    # Where inegi_quinquenial_df is the original populations dataframe and the projection_dates_df is a dataframe
    # with the same structure but with growing rates instead of population values.

    # get the structure of inegi_quinquenial_df
    geometric_pg_projection_df <- inegi_quinquenial_df

    # make the calculations based on the geometrical rate formula ( P_{t+n, i} = P_{t, i} * (1 + r_{g,i})^n )

    geometric_pg_projection_df$males <- inegi_quinquenial_df$males * 
					((1 + projection_rates_df$males)^(years_projection_time))

    geometric_pg_projection_df$females <- inegi_quinquenial_df$females * 
					((1 + projection_rates_df$females)^(years_projection_time))
    
    return(geometric_pg_projection_df)
}

get_exponential_pg_projection <- function(inegi_quinquenial_df = data.frame(),
					projection_rates_df = data.frame(),
					years_projection_time = numeric()) {
    # Generates a Population growth projection considering an exponential population growing
    # between two INEGI quinquenial formated dataframes with the following
    # structure required as input (inegi_quinquenial_df, projection_rates_df):
    # | starting_age [int/num] | ending_age [int/num] | males [int/num] | females [int/num] | 
    # Where inegi_quinquenial_df is the original populations dataframe and the projection_dates_df is a dataframe
    # with the same structure but with growing rates instead of population values.

    # get the structure of inegi_quinquenial_df
    exponential_pg_projection_df <- inegi_quinquenial_df

    # make the calculations based on the exponential rate formula ( P_{t+n, i} = P_{t, i} * (e^{r_{e,i} * n})

    exponential_pg_projection_df$males <- inegi_quinquenial_df$males *
					  (exp(projection_rates_df$males * years_projection_time))

    exponential_pg_projection_df$females <- inegi_quinquenial_df$females *
					    (exp(projection_rates_df$females * years_projection_time))
    
    return(exponential_pg_projection_df)
}
