# Excel data evaluation script for Census of Population and Housing (CPV) ages for years 2010 and
# 2020 in Iztacalco, Mexico City. 
# Data from: https://en.www.inegi.org.mx/
# The purpose of this script is to generate the age pyramids for the Iztacalco population 
#
# Made by: https://github.com/artrx86

# Package Handling ---------------------------

library(ggplot2)

# Dataframe formating ---------------------------

pop_to_ggplot2 <- function(inegi_df = data.frame()) {

    # Transform an INEGI formated dataframe with the following structure as input:
    # | EDAD [str] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    
    # Into an more ggplot2 friendly dataframe with the following structure as output:
    # | EDAD [str] | POBLACION [int/num] | GENERO[str] | 

    # all ages formating
    if (nrow(inegi_df) >= 101) {
	inegi_df[101, "EDAD"] <- "Mayor o igual a 100 años"
    }
    # quinquenial formating
    else if (nrow(inegi_df) == 19) {
	inegi_df <- head(inegi_df, -1)
	inegi_df[18, "EDAD"] <- "Mayor o igual a 85 años"
    } 

    # Separate the dataframe into male and female gender to do a vertical join
    ggplot_df_males <- inegi_df[,c("EDAD", "HOMBRES")]
    ggplot_df_females <- inegi_df[,c("EDAD", "MUJERES")]
     
    # add a gender column to identify them
    ggplot_df_males$GENERO <- "H"
    ggplot_df_females$GENERO <- "M"
    
    # Rename the HOMBRES/MUJERES column to POBLACION to do the vertical join
    names(ggplot_df_males)[names(ggplot_df_males) == 'HOMBRES'] <- 'POBLACION'
    names(ggplot_df_females)[names(ggplot_df_females) == 'MUJERES'] <- 'POBLACION'
     
    # Do the vertical join and return the resulting dataframe
    ggplot_df = rbind(ggplot_df_males, ggplot_df_females)
   
    # Finally convert POBLACION variable to percentage
    ggplot_df$POBLACION <- ggplot_df$POBLACION / sum(ggplot_df$POBLACION) * 100
  
    return (ggplot_df)
}


# Population pyramids ---------------------------
graph_pop_pyramid <- function(inegi_df = data.frame()) {

    # Generates a pyramid type graph based on an INEGI formated dataframe with the following
    # structure as input:
    # | EDAD [str] | POB_TOTAL [int/num] | HOMBRES [int/num] | MUJERES [int/num] | 
    
    # format the dataframe to get the graph into a ggplot2 friendly structure
    data  <- pop_to_ggplot2(inegi_df)
    
    # graph using ggplot2
    # (code [lines 53:62] taken and adapted from: https://www.statology.org/POBLACION-pyramid-in-r/)
    ggplot(data, aes(x = EDAD, fill = GENERO,
                     y = ifelse(test = GENERO == "H",
                                yes = -POBLACION, no = POBLACION))) +
    geom_bar(stat = "identity") +
    scale_y_continuous(labels = abs, limits = max(data$POBLACION) * c(-1,1)) +
    labs(title = "Piramide de Población", x = "Edad", y = "Porcentaje de población") +
    scale_colour_manual(values = c("steelblue", "pink"),
                          aesthetics = c("colour", "fill")) +
    coord_flip()
}

