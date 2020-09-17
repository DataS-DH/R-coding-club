
## Catching errors in workflow
## STOPIFNOT should be STOP-function-IFNOT
rm(list=ls())
cat("\014")
library(dplyr)
library(here)
library(readxl)


file <- here("test_excel_file.xlsx")

#Look at the data


pipe_print <- function(x, sheet){
    print(paste0("Number of rows in ", sheet, " ", nrow(x)))
    return(x)
}


#Catching errors - main sheet 2 does not exist
df <-
    tryCatch(
        read_excel(file, sheet="Main sheet2", col_types = "text")%>%
            rename(Pack_size=`Pack size`, Concessionary_price=`Current CP`) %>%
            select(Drug, Pack_size, Status, Concessionary_price) %>%
            pipe_print("Main sheet") ,
        error=function(e){
            NA
        }
    )

stopifnot(!is.na(df))
print("SHOULD NOT GET HERE IF USING MAIN SHEET 2")
print("Doing lots of other stuff ..... ")

#########################################################################################
# The importance of functions

import_fn <- function(file, sheet_name){
    print(paste0("[INFO]: Working on file ", file))

    # Get CP from file
    df <-
        tryCatch(
            df <- read_excel(file, sheet=sheet_name, col_types = "text") %>%
                rename(Pack_size=`Pack size`, Concessionary_price=`Current CP`) %>%
                select(Drug, Pack_size, Status, Concessionary_price) %>%
                pipe_print(sheet_name) ,
            error=function(e){
                NA
            }
        )
    stopifnot(!is.na(df))

    print("Doing some more processing")

    return(df)
}

#load data
rm(df, DF)
DF <- import_fn(file, sheet_name="Main sheet")
if(exists("DF")){
    print("Pushing to database")
} else {
    print("[ERROR]: cannot load data")
}


rm(DF)
DF <- import_fn(file, sheet_name="another_sheet")
if(exists("DF")){
    print("Pushing to database")
} else {
    print("[ERROR]: cannot load data")
}


