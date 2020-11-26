setwd("J:/FPAEIG/FPMA/Analysis/Briefing and Reporting/Monthly CWA & Prody/National Activity Product/RJoinSession")

library(readxl)
library(tidyverse)
library(dplyr)
library(tidyr)

#Read in the data

Finance <- read_excel("JoinsExample.xlsx",1)
Activity <- read_excel("JoinsExample.xlsx",2)

#The joins on one variable with the same name

EfficInner <- inner_join(Finance, Activity, by = "Provider" )
EfficOuter <- full_join(Finance, Activity, by = "Provider" )
EfficLeft <- left_join(Finance, Activity, by = "Provider" )
EfficRight <- right_join(Finance, Activity, by = "Provider" )

#The joins for two variables
Finance2 <- read_excel("JoinsExample.xlsx",4)
Activity2 <- read_excel("JoinsExample.xlsx",5)

EfficInner2 <- inner_join(Finance2, Activity2, by = c("Provider","CCG" ))
EfficOuter2 <- full_join(Finance2, Activity2, by = c("Provider","CCG" ) )
EfficLeft2 <- left_join(Finance2, Activity2, by = c("Provider","CCG" ) )
EfficRight2 <- right_join(Finance2, Activity2, by = c("Provider","CCG" )) 

#Joins with different names
Finance3 <- read_excel("JoinsExample.xlsx",6)
Activity3 <- read_excel("JoinsExample.xlsx",7)

EfficInner3 <- inner_join(Finance3, Activity3, by = c("Provider"= "Code" ))
EfficOuter3 <- full_join(Finance3, Activity3, by = c("Provider"= "Code" ) )
EfficLeft3 <- left_join(Finance3, Activity3, by = c("Provider"= "Code" ) )
EfficRight3 <- right_join(Finance3, Activity3, by = c("Provider"= "Code" )) 

#Now on to semi joins

EfficSemi <- semi_join(Finance, Activity, by = "Provider")

EfficAnti <- anti_join(Finance,Activity, by = "Provider")

RegionMap <- read_excel("JoinsExample.xlsx",8)

EfficRegion <- left_join(EfficInner, RegionMap, by = "Provider")

EfficRegion <- EfficRegion %>% group_by(Region) %>% summarise(Spend = sum(Spend), Operations = sum(Operations))
