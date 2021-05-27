
##have your libraries explicitly stated for powerbi 

library(magrittr)
library(tidyverse)
library(polite)
library(rvest)
library(readxl)

#have your working directory explicitly stated for powerbi
setwd("G:/CNO-DAT/Data Science/Data Science Hub/DS Products & Projects/2021-04 Vaccine stats RAP")

#polite scraping 
url <- "https://www.england.nhs.uk/statistics/statistical-work-areas/covid-19-vaccinations/"
eng_bow <- polite::bow(url)

tryCatch({
  message("Scraping latest England vaccination statistics")
  eng_scrape <- 
    polite::scrape(eng_bow) %>% 
    rvest::html_nodes("a") %>% # Find all links
    rvest::html_attr("href") %>% # Extract the urls
    stringr::str_subset("COVID-19-daily") %>% #only get the daily files 
    .[[1]] # Pull the first file (latest)
  
  filename <- basename(eng_scrape) #get file name
  
  # Download latest file 
  for(i in 1:length(eng_scrape)){
    if(!file.exists(paste0(filename[i]))){
      download.file(paste0(eng_scrape[i], sep=""),
                    paste(dest = filename[i], sep=""), 
                    mode = 'wb')}}
})

#getting publication date out 
pub_date <- readxl::read_excel(path=paste0(filename[i]), range = "C7", col_names = FALSE) %>%
            .[[1]] %>% lubridate::dmy()

#giving consistent column names 
names <- c("Region", "", "1st dose", "2nd dose","", "Total doses")

##your final output must be a dataframe for powerbi to read it in 
##you can use pipes to add in formatting to your dataframe 
eng_vacc <- readxl::read_xlsx(path=paste0(filename[i]),
                              range = "B14:G21", col_names = names) %>% 
                    select("Region", "1st dose", "2nd dose", "Total doses")%>%
                    mutate(Publication_date = pub_date) %>%
                    na.omit() 

##in powerbi select Get Data> R script > then copy paste this above code to get your dataframe

##if you need to edit your code after you have read it in, go to dataset in your left handside ribbon
##transform data > dataset source settings> you can edit your code! 



##part is for QA and not needed for power bi 
if(!file.exists('data/eng_vaccine.csv')){
  write.csv(eng_vacc, 'data/eng_vaccine.csv', row.names = FALSE) 
} else {
  # Later: append to existing CSV
  write.table(eng_vacc, 'data/eng_vaccine.csv',
              row.names = FALSE, col.names = FALSE,
              sep = ",", append = TRUE)
}





