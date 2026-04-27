# Data quality evaluation script for Census of Population and Housing (CPV) ages for years 2010 and
# 2020 in Iztacalco, Mexico City. 
# Data from: https://en.www.inegi.org.mx/
# The purpose of this script is to evaluate the data quality by using UN, Whipple and Myers indexes. 
#
# Made by: https://github.com/artrx86

# Package Handling ---------------------------
library(dplyr)

# Dataframe formating for evaluation ---------------------------

get_indexes_format_df <- function(ages_df = data.frame(),
			      gender = "both") {

    # Returns a formated dataframe in a friendly format for indexes (Whipple's, Myer's) 
    # evaluation from an INEGI formated dataframe with the following structure as input (ages_df):
    # | EDAD [string] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    # 
    # To select the gender to get the formated dataframe values, the param gender = "male", "female", "both"
    # is used.
   
    # For this evaluation we will not be counting on the unspecified information
    index_formated_df <- ages_df %>% head(-1)

    # add a column with the age as an integer value
    index_formated_df$age = c(0:100)

    # get the columns required for the dataframe according to the selected gender
    if (gender == "male") {
	index_formated_df <- index_formated_df %>% select("age", "population"="HOMBRES")

    }
    # apply the formula to the dataframe by using for cycles

    else if (gender == "female") {
	index_formated_df <- index_formated_df %>% select("age", "population"="MUJERES")
    }

    else if (gender == "both") {
	index_formated_df <- index_formated_df %>% select("age", "population"="POB_TOTAL")
    }

    return(index_formated_df)
}

# Quinquenial dataframe formating ---------------------------
get_quinquenial_format_df <- function(ages_df = data.frame()) {  
    # Returns a formated dataframe in a friendly format (information in quinquenials)
    #
    # evaluation from an INEGI formated dataframe with the following structure as input (ages_df):
    # | EDAD [string] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    # 
    # Output dataframe format:
    # | starting_age [int] | ending_age [int] | males [int/num] | females [int/num] |

    quinquenial_formated_df <- ages_df 

    # add a column with the staring age of the range as integer values to group by starting_ages
    quinquenial_formated_df$starting_age = c(rep(seq(0, 85, by = 5), each = 5), rep(85, each=11), 101)
   
    # add an unspecified value row for unspecified data
    # get the columns required for the dataframe
    quinquenial_formated_df <- quinquenial_formated_df %>% select("starting_age", "males"="HOMBRES", "females"="MUJERES")
    
    # group by ranges of every 5 years (quinquenials) 
    quinquenial_formated_df <- aggregate(cbind(quinquenial_formated_df$males, quinquenial_formated_df$females),
			       by = list(starting_age = quinquenial_formated_df$starting_age),
			       FUN = sum)

    # add the end of the age ranges for future purposes an readbility of the dataframe
    quinquenial_formated_df$ending_age = c(seq(4, 84, by = 5), NA, NA)

    # Convert the last age range to NA for unspecified information
    quinquenial_formated_df$starting_age[19]  <- NA
    # restore column names
    quinquenial_formated_df <- quinquenial_formated_df %>% select("starting_age", "ending_age", "males"="V1", "females"="V2")  

    return(quinquenial_formated_df)
 }


# Whipple's index ---------------------------

get_whipple_index <- function(ages_df = data.frame(),
			      gender = "both") {
    
    # Returns Whipple's index from an INEGI formated dataframe with the following
    # structure as input (ages_df):
    # | EDAD [string] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    # 
    # To select the gender to get Whipple's index, the param gender = "male", "female", "both"
    # is used
    # Used formula: $\frac{5 \sum_5^12}{\sum_{i=23}^{62} Pi} * 100$

    # dataframe formating
    whipple_pop_df <- get_indexes_format_df(ages_df, gender) 
    
    # get the sum for the numerator
    whipple_numerator <- 5 * with(whipple_pop_df, sum(population[(age %% 5 == 0) & (25 <= age) & (age <= 60)])) 

    # get the sum for the denominator
    whipple_denominator <- with(whipple_pop_df, sum(population[(23 <= age) & (age <= 62)])) 

    # complete the fraction and multiply by 100
    whipple_index <- (whipple_numerator / whipple_denominator) * 100 

    return(whipple_index)
}

# Myers' index
get_myers_index <- function(ages_df = data.frame(),
			      gender = "both") {

    # Returns a list with Myers' index, and a dataframe with the concentration weights of each
    # age last digits from an INEGI formated dataframe with the following
    # structure as input:
    # | EDAD [string] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    #
    # output structure:
    # list(myers_index [numeric], weights_df [data.frame])
    # To select the gender to get Myers' index, the param gender = "male", "female", "both"
    # is used
    # Used formula:
    # M_j = ( (\frac{a_jp_j + a_j'p_j'}{\sum_0^9(a_jp_j + a_j'p_j')}) - 10% ) * 100
    # I_M = \sum_j^9\|M_j\|, 0 < M_j < 180
   
    # dataframe formating
    myers_pop_df <- get_indexes_format_df(ages_df, gender) 
    
    # P_j construction so pj_vector = c(P_0, P_1, P_2, P_3, ..., P_9) where:
    # P_j = \sum_{i \geq 1}{6} P_{10i + j}
    pj_vector <- c() 
    
    for (j in 0:9) {

	# sum the population ages that finishes in the j digit 
	pj_vector <- pj_vector %>% append(with(myers_pop_df,
				  sum(population[age %in% (j + (10 * 1:6))])
				  )) 
    }
    
    # a_j vector, so aj_vector <- c(1, 2, 3, ..., 10)
    aj_vector <- 1:10
    
    # a_jP_j vector, so ajpj_vector = c(1 * P_0, 2 * P_1, 3 * P_2, ..., 10 * P_9)
    ajpj_vector = aj_vector * pj_vector

    # P_j' construction so pj_alt_vector = c(P_0, P_1, P_2, P_3, ..., P_9) where:
    # P_j' = \sum_{i \geq 2}{7} P_{20i + j}
    pj_alt_vector <- c() 
    
    for (j in 0:9) {

	# sum the population ages that finishes in the j digit 
	pj_alt_vector <- pj_alt_vector %>% append(with(myers_pop_df,
				  sum(population[age %in% (j + (10 * 2:7))])
				  )) 
    }

    # a_j' vector, so aj_alt_vector <- c(9, 8, 7, ..., 0)
    aj_alt_vector <- 9:0
    
    # a_j'P_j' vector, so aj_alt_pj_alt_vector = c(1 * P_0, 2 * P_1, 3 * P_2, ..., 10 * P_9)
    aj_alt_pj_alt_vector <- aj_alt_vector * pj_alt_vector

    # now we do the M_j formula with the obtained elements
    mj_vector <- ((ajpj_vector + aj_alt_pj_alt_vector) /
		  sum(ajpj_vector + aj_alt_pj_alt_vector) - 0.10) * 100    

    # make returnable the individual concentration weights of every digit
    # for comprobations in a dataframe 
    mj_digits <- 0:9
    weights_df <- data.frame(mj_digits, mj_vector)
    names(weights_df) <- c("Digit", "Concentration")

    # finally get Myers' index
    myers_index <- sum(abs(mj_vector))
   
    return(list(myers_index, weights_df))
}

# UN Age Sex Accuracy Index 
get_un_age_accuracy_index <- function(ages_df_quinquenial = data.frame()) {

    # Returns UN Age Sex Accuracy Index from an Inegi quintenial dataframe formated dataframe with the following
    # structure as input:
    # | starting_age [int/num] | ending_age [int/num] | males [int/num] | females [int/num] | 
    #
    # Used formula:
    # I_UN = I_M + I_F + 3I_{BS}
    # where;
    # I_M = Males Index, I_F = Females Index, I_{BS} = Both Sexes Index

    # Dataframe formating 
    un_pop_df <- ages_df_quinquenial 
  
    # get only from 0-4 to 70-74 age ranges 
    un_pop_df <- un_pop_df %>% head(-4)
    
    # un_pop_df <- ages_df %>% head(-)
    # male r calculation
    r_m_vector <- c()

    for (i in 2:14) {
	r_m_vector <- r_m_vector %>% append(abs((2 * (un_pop_df$males[i])) / ((un_pop_df$males[i-1]) + (un_pop_df$males[i+1])) - 1))
    }

    # female r calculation
    r_f_vector <- c()

    for (i in 2:14) {
	r_f_vector <- r_f_vector %>% append(abs((2 * (un_pop_df$females[i])) / ((un_pop_df$females[i-1]) + (un_pop_df$females[i+1])) - 1))
    }

    # I_m calculation
    i_m <- ((1 / 13 ) * sum(r_m_vector)) * 100

    # I_F calculation
    i_f <- ((1 / 13 ) * sum(r_f_vector)) * 100

    # R_j calculation
    r_j_vector <- c()

    for (i in 2:14) {
	r_j_vector <- r_j_vector %>% append(abs(((un_pop_df$males[i]) / (un_pop_df$females[i]))  - ((un_pop_df$males[i + 1]) / (un_pop_df$females[i + 1]))))
    }

    # I_{BS} calculation
    i_bs <- ((1 / 13 ) * sum(r_j_vector)) * 100
   
    # UN Age Accuracy Index calculation
    un_age_accuracy_index <- i_m + i_f + (3 * i_bs) 

    return(un_age_accuracy_index)
}

