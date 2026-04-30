# Spline script for Census of Population and Housing (CPV) ages for years 2010 and
# 2020 in Iztacalco, Mexico City. 
# Data from: https://en.www.inegi.org.mx/
# The purpose of this script is making interpolation spline and quadrature factor fixing
# tools to handle the data from the INEGI CPV. 
#
# Made by: https://github.com/artrx86

# Package Handling ---------------------------
library(dplyr)

# Spline handler -------------------------
get_spline_df <- function(inegi_df = data.frame(), gender="males", spar_value = 0) {
    # applies spline smoothing to an INEGI formated dataframe with the following
    # structure required as input (inegi_df):
    # | EDAD [string] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    # also a gender parameter that can be "males" or "females", "both" is not defined here
    # and a spar value according to the needs of the analyst

    if (gender == "males") {
	gender_column = inegi_df$HOMBRES
    }
    

    else if (gender == "females") {
	gender_column = inegi_df$MUJERES
    }

    return(smooth.spline(seq(0,100), gender_column[1:101],  spar = spar_value)) 
}

# Quadrature Factor handlers -------------------------
get_quadrature_factor_df <- function(corrected_inegi_df = data.frame(), inegi_df = data.frame()) {
    # applies quadrature factor to a corrected INEGI formated dataframe with the following
    # structure required as input (corrected_inegi_df):
    # | EDAD [string] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    # The uncorrected dataframe (inegi_df) with the same structure is also required as input

    quadrature_fact_df <- corrected_inegi_df 

    # fi calculation (fi = \hat{P}_i / \hat{P}_{total})
    quadrature_fact_df$HOMBRES <- quadrature_fact_df$HOMBRES / sum(quadrature_fact_df$HOMBRES)
    quadrature_fact_df$MUJERES <- quadrature_fact_df$MUJERES / sum(quadrature_fact_df$MUJERES)
    
    # \hat{P}^f calculation (\hat{P}^f = P_{total} * fi ) 
    quadrature_fact_df$HOMBRES <- sum(inegi_df$HOMBRES) * quadrature_fact_df$HOMBRES
    quadrature_fact_df$MUJERES <- sum(inegi_df$MUJERES) * quadrature_fact_df$MUJERES
    
    
    quadrature_fact_df$POB_TOTAL <- quadrature_fact_df$HOMBRES + quadrature_fact_df$MUJERES 

    # append a row with NA values for compatibility purposes
    quadrature_fact_df <- rbind(quadrature_fact_df, list(NA, 0, 0, 0))

    return(quadrature_fact_df)
}


do_quadrature_factor_validation <- function(quadrature_factor_inegi_df = data.frame(), inegi_df = data.frame()) {
    # structure required as input (inegi_df, quadrature_factor_inegi_df):
    # | EDAD [string] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    if (all.equal(sum(quadrature_factor_inegi_df$HOMBRES), sum(inegi_df$HOMBRES)) & all.equal(sum(quadrature_factor_inegi_df$MUJERES), sum(inegi_df$MUJERES))) {
	return ("passed")
    }
    else {
	return("not passed") 
    }
}

