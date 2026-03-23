# Main script. 
# The purpose of this script is to call every stage of the data processing pipeline.
# IMPORTANT: This file location has to be set as the working directory when executed in shell.
# Made by: https://github.com/artrx86

# Package Handling ---------------------------

# Package names
packages <- c("this.path")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading (hidden output)
invisible(lapply(packages, library, character.only = TRUE))

# Source calls (script imports) ---------------------------

# Main function ---------------------------
main <- function() {

    # if using R IDE try to change working directory to this script location
    tryCatch({ 
	setwd(this.path::here())
    }, error = function(e) {
    })

    # call the scripts functions
    
}

main()

