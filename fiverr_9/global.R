options(shiny.trace = F)  


#---base libraries
library(shiny)
library(shinydashboard)         
library(shinyBS)
library(shinydashboardPlus)  
library(readxl)
library(reshape2)
library(rqdatatable)
library(rhandsontable)
library(shinyEffects)   
library(shinycssloaders) 

library(shinyWidgets)
#shadow boxes
setShadow = shinyEffects::setShadow 

#source scrips
source("modules/trafic_light.R",local=TRUE)   
source("modules/example.R",local=TRUE)   
 
 


#important download guidelines for some libraries
#download version 0.7.5
#devtools::install_github('RinteRface/shinydashboardPlus@v0.7.5')