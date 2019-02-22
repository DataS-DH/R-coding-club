#Creating smaller groups of ethnicity
if (!require(tidyverse)) {
  install.packages("tidyverse")
  library(tidyverse)
}

if (!require(plotly)) {
  install.packages("plotly")
  library(plotly)
}
library(tidyverse)
library(plotly)

setwd("~/Health_R_coding_club")

#Look at how it ientifies variable types differently between the two functions.
StopSearch <- read_csv("StopSearchDec.csv")
str(StopSearch)
StopSearch <- read.csv("StopSearchDec.csv")
str(StopSearch)

#Convert date and time back to date format.
StopSearch$Date <- as.POSIXct(StopSearch$Time)

#Lets focus on the ethnicity data again and create broader groups for self defined ethnicity
levels(StopSearch$Self.defined.ethnicity)

levels(StopSearch$Officer.defined.ethnicity)

#ordering of the if's is really important, finds the match and removes matchin items from future searches (doesn't check everything everytime and overwrite)
StopSearch$Ethnicity <- ifelse(grepl("Mixed", StopSearch$Self.defined.ethnicity),"Mixed",ifelse(
  grepl("White", StopSearch$Self.defined.ethnicity), "White", ifelse(
    grepl("Asian", StopSearch$Self.defined.ethnicity),"Asian", ifelse(
      grepl("Black", StopSearch$Self.defined.ethnicity),"Black", "Other"))))
head(StopSearch)

#check if assignment looks sensible
table(StopSearch$Ethnicity, StopSearch$Self.defined.ethnicity)

#Now we can cross reference self defined and officer defined ethnicity again
table(StopSearch$Ethnicity, StopSearch$Officer.defined.ethnicity)

#Let's visualise it again using code from last week.
EthCompB <- ggplot(StopSearch, aes(Officer.defined.ethnicity))
EthCompB + geom_bar()
EthCompBplot <- EthCompB + geom_bar(aes(fill= Ethnicity))

ggplotly(EthCompBplot)

#as proportions
EthCompP <- ggplot(StopSearch) +
  aes(x= Officer.defined.ethnicity, fill= Ethnicity) +
  geom_bar(position= "fill")
ggplotly(EthCompP)


#What proportion of sotps amd searches are on black people
prop.table(table(StopSearch$Ethnicity))

#gender, ethnicity breakdown
EthCompP <- ggplot(StopSearch) +
  aes(x= Ethnicity, fill= Gender) +
  geom_bar()
ggplotly(EthCompP)

EthCompP <- EthCompP + geom_bar(position= "fill")
ggplotly(EthCompP)


#age, ethnicity breakdown
EthCompP <- ggplot(StopSearch) +
  aes(x = Ethnicity, fill=Age.range) +
  geom_bar()
ggplotly(EthCompP)

EthCompP <- EthCompP +  geom_bar(position = "fill")
ggplotly(EthCompP)

#Lets look at the number of different groups stopped, using age, gender, Ethnicity

SS_AGE <- plyr::count(StopSearch, c("Ethnicity", "Age.range", "Gender"))
SS_AGE$DEMO <- paste0(SS_AGE$Ethnicity, SS_AGE$Age.range, SS_AGE$Gender)

AGEplot <- ggplot(SS_AGE, aes(x = reorder(DEMO, -freq), y=freq, fill=Ethnicity)) + geom_bar(stat="identity") +
  xlab("Population group") +
  ggtitle("Demographic profile of individuals stopped by police for stop & search") + coord_flip() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 30)) +
  guides(fill = FALSE) +
  theme(axis.text.x = element_text(hjust = 0)) +
  theme(plot.title = element_text(size = rel(1.2), lineheight = 1, face = "bold"))

ggplotly(AGEplot) %>% layout(legend = list(orientation="h"))
 
#playing around to find the best way to present the data to show potentia bias

#a super simple thing we can do is this
with(StopSearch, barplot(ftable(Age.range, Ethnicity, Gender), beside = TRUE))

#a tidyverse attempt

#summarise the dataframe - create means of scores by Type
StopSearch1 <- StopSearch %>% group_by(Gender, Ethnicity, Age.range) %>% summarise(count = n())

#create plot
ggplot(StopSearch1, aes(x = Gender, y = count, fill = Ethnicity)) +
  geom_bar(stat = "identity") +
  facet_wrap(~Age.range, nrow = 1)

#Make the x axis legable
demo_plot <- ggplot(StopSearch1, aes(x = reorder(Ethnicity, -count), y = count, fill = Age.range)) +
  geom_bar(stat = "identity") +
  xlab("") +
  facet_wrap(~Age.range, nrow = 1) +
  theme(axis.text.x = element_text(angle = 50, hjust = 1))

ggplotly(demo_plot) %>% layout(legend = list(orientation = "h", y = 0.93, x = 0.34))

#bring in wider ethnicity data, to calcualte proportion of population being SS.
#Note population data covers England and Wales whereas te stop & search data only covers England. 
pop_eth <- read.csv("population-of-england-and-wales-by-ethnicity.csv")
levels(pop_eth$Ethnicity)
pop_ethnicity <- subset(pop_eth, Ethnicity == "Asian" | Ethnicity == "Black" | Ethnicity == "Mixed" | Ethnicity == "White" | Ethnicity == "Other")

#format stop search data to have same view.
SS_ethnicity <- StopSearch %>% group_by(Ethnicity) %>% summarise(Freq = n())

#create proportion variable
SS_ethProp <- StopSearch %>% group_by(Ethnicity) %>% 
  summarise( percent = 100 * n() / nrow(StopSearch))
SS_ethnicity <- merge(SS_ethProp, SS_ethnicity)

SS_ethnicity <- merge(SS_ethnicity, pop_ethnicity)
colnames(SS_ethnicity) <- c("Ethnicity", "SS_prop", "Freq", "pop_Freq", "pop_prop" )

#we need to fix the format of the pop_Freq variable

SS_ethnicity$prop_Stop <- SS_ethnicity$Freq/SS_ethnicity$pop_Freq

#plot the data
ggplot(SS_ethnicity) + geom_bar(aes(x=Ethnicity, y=prop_Stop))

SSeth_prop <- gather(SS_ethnicity, variable, value, c(SS_prop, pop_prop), factor_key = TRUE)
SSeth_prop <- SSeth_prop[,-c(2:3)]





#I would ideally like to look at this through a geographic lense, but there is only an annoynimised long/lat data points.
#How do we translate this into a geographical boundary like LSOA, LA.

