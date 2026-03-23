# Excel data extraction script for Census of Population and Housing (CPV) ages for years 2010 and 2020 in Iztacalco, Mexico City. 
# Data from: https://en.www.inegi.org.mx/
# The purpose of this script is to get the population ages information.
# The reason to backup the data into csv files is in case we need that information for
# future reference without having excel dependencies.
#
# Made by: https://github.com/artrx86

# Package Handling ---------------------------

library(readxl)


# Excel to CSV processing ---------------------------
# Excel to filtered csv function

# function to get the Iztacalco CPV ages from the excel file
cpv_ages_to_csv <- function(filename = "",
			    year = 2010,
			    output_file = ""){
    if (year == 2020){
	
	# read excel 
	df <- read_excel(filename,
			 sheet = "03",
			 col_names = FALSE,
			 range = "C834:F935") 
	# adjust colnames
	colnames(df) <- c("EDAD", "POB_TOTAL", "HOMBRES", "MUJERES") 
	
	# write csv
	write.csv(df, output_file, row.names = FALSE)
	
	return (df)
    
    } else if (year == 2010) { 
	
	# read excel 
	df <- read_excel(filename,
			 col_names = FALSE,
	    		 range = "C835:F936") 


	# adjust colnames
	colnames(df) <- c("EDAD", "POB_TOTAL", "HOMBRES", "MUJERES") 
	
	# write csv
	write.csv(df, output_file, row.names = FALSE)
	
	return (df)
    }
}

