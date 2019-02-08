#Stop and search data
library(tidyverse)
library(kableExtra)

setwd("~/Health_R_coding_club/R-coding-club/")
unzip("19bda6b8c03fcde120a171c3d114cd92575e3a50.zip", exdir= "~/Health_R_coding_club/R-coding-club")

setwd("~/Health_R_coding_club/R-coding-club/2018-12")

filenames <- list.files(full.names=TRUE)

#lets look at one file to understand the format of the data
test <- read.csv(filenames[1], header = TRUE)
All$Time <- All$Date
All$Date <- as.POSIXct(All$Time)


All <- lapply(filenames,function(i){
  read.csv(i, header=TRUE, na.strings = c("", "NA"))
})
StopSearch <- do.call(rbind.data.frame, All)

StopSearch %>% kable() %>% kable_styling()

StopSearch$Time <- StopSearch$Date
StopSearch$Date <- as.POSIXct(StopSearch$Time)
StopSearch$Part.of.a.policing.operation <- as.logical(StopSearch$Part.of.a.policing.operation)
StopSearch$Removal.of.more.than.just.outer.clothing <- as.logical(StopSearch$Removal.of.more.than.just.outer.clothing)
summary(StopSearch)
StopSearch$Outcome.linked.to.object.of.search <- as.logical(StopSearch$Outcome.linked.to.object.of.search)

StopSearch %>% kable() %>% kable_styling()

#Make some pretty plots.
StopSearchEth <- plyr::count(StopSearch, "Self.defined.ethnicity")
Ethplot <- ggplot(StopSearchEth, aes(x=reorder(Self.defined.ethnicity, -freq), y=freq, fill=Self.defined.ethnicity)) + geom_bar(stat="identity") +
  xlab("Ethnicity count") +
  ggtitle("Ethnicity of individuals stopped by police for stop & search") + coord_flip() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 30)) +
  guides(fill = FALSE) +
  theme(axis.text.x = element_text(hjust = 0)) +
  theme(plot.title=element_text(size = rel(1.2), lineheight = 1, face = "bold"))
)
ggplotly(Ethplot) %>% layout(showlegend = FALSE)


StopSearchOEth <- plyr::count(StopSearch, "Officer.defined.ethnicity")
OEthplot <- ggplot(StopSearchOEth, aes(x=reorder(Officer.defined.ethnicity, -freq), y=freq, fill=Officer.defined.ethnicity)) + geom_bar(stat="identity") +
  xlab("Ethnicity count") +
  ggtitle("Ethnicity of individuals stopped by police for stop & search (reported by officer)") + coord_flip() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 30)) +
  guides(fill = FALSE) +
  theme(axis.text.x = element_text(hjust = 0)) +
  theme(plot.title=element_text(size = rel(1.2), lineheight = 1, face = "bold"))
)
ggplotly(OEthplot) %>% layout(showlegend = FALSE)


#Lets see how the self reported ethnicity and officer reported ethnicity match up
EthComp <- table(StopSearch$Self.defined.ethnicity, StopSearch$Officer.defined.ethnicity)
EthComp %>% kable() %>% kable_styling()
