#Creating smaller groups of ethnicity

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
EthCompBplot <- EthCompB + geom_bar(aes(fill=Ethnicity))

ggplotly(EthCompBplot)

#as proportions
EthCompP <- ggplot(StopSearch) +
  aes(x=Officer.defined.ethnicity, fill=Ethnicity) +
  geom_bar(position="fill")
ggplotly(EthCompP)


#What proportion of sotps amd searches are on black people
prop.table(table(StopSearch$Ethnicity))

#gender, ethnicity breakdown
EthCompP <- ggplot(StopSearch) +
  aes(x=Ethnicity, fill=Gender) +
  geom_bar()
ggplotly(EthCompP)

EthCompP <- EthCompP + geom_bar(position="fill")
ggplotly(EthCompP)


#age, ethnicity breakdown
EthCompP <- ggplot(StopSearch) +
  aes(x=Ethnicity, fill=Age.range) +
  geom_bar()
ggplotly(EthCompP)

EthCompP <- EthCompP +  geom_bar(position="fill")
ggplotly(EthCompP)

#Lets look at the number of different groups stopped, using age, gender, Ethnicity

SS_AGE <- plyr::count(StopSearch, c("Ethnicity", "Age.range", "Gender"))
SS_AGE$DEMO <- paste0(SS_AGE$Ethnicity, SS_AGE$Age.range, SS_AGE$Gender)

AGEplot <- ggplot(SS_AGE, aes(x=reorder(DEMO, -freq), y=freq, fill=Ethnicity)) + geom_bar(stat="identity") +
  xlab("Population group") +
  ggtitle("Demographic profile of individuals stopped by police for stop & search") + coord_flip() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 30)) +
  guides(fill = FALSE) +
  theme(axis.text.x = element_text(hjust = 0)) +
  theme(plot.title=element_text(size = rel(1.2), lineheight = 1, face = "bold"))

ggplotly(AGEplot) %>% layout(legend=list(orientation="h"))

#plot of groups, so ethnicity, then different bars for age within and then stacked on gender.
#bring in wider ethnicity data, to calcualte proportion of population being SS.
