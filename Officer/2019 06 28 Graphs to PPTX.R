##############################################################################################################*
##############################################################################################################*
########          A&E graphs into powerpoints - June 2019                                 ####################
########          Written for the Health Coding Club                                      ####################*
#Data: https://www.england.nhs.uk/statistics/statistical-work-areas/ae-waiting-times-and-activity/ae-attendances-and-emergency-admissions-2018-19/
#Filename:  Monthly A&E Timeseries March 2019 (XLS, 322K)
##############################################################################################################*
##############################################################################################################*


############################################# Loading in the libraries ######################################

#you will need to install.packages first if you haven't pre installed these.

library(tidyverse) #to upload tidyverse
library(tidyxl) #imports data from Excel without forcing it into a rectangular shape
library(unpivotr) #converting data into a rectangular structure

library(officer) #used for the PowerPoint creation
library(rvg) #used for the PowerPoint creation
library(magrittr) #used for the PowerPoint creation
library(rio) #used for the PowerPoint creation

library(grid) #to put more than one graph on a PowerPoint page
library(gridExtra) #to put more than one graph on a PowerPoint page

library(ggplot2)
library(dplyr)

############################################# Set the inputs and variables ######################################

#Create new folder to save work to
dir.create(file.path('R Coding Club/2019 06 28 Graphs to PPTX/Inputs'), recursive = TRUE)
dir.create(file.path('R Coding Club/2019 06 28 Graphs to PPTX/Outputs'), recursive = TRUE)

##Input path - this is where your files are saved. Please note that RStudio prefers / to separate the folders instead of \
path_input <- 'P:/R/home/R Coding Club/2019 06 28 Graphs to PPTX/Inputs'


##Output path - this is where your PowerPoint files will be exported to. 
#If you prefer, this can be the same directory as above but I prefer to keep my Input files in one folder and Output files in another
path_output <- 'P:/R/home/R Coding Club/2019 06 28 Graphs to PPTX/Outputs'



##Input file names
file_AE <- "March-2019-Timeseries-with-growth-charts-GRyQD-2.xlsx"
file_powerpoint <- "PowerPoint_template.pptx"



##Output file names
output_csv <- 'Data extract.csv'
output_powerpoint <- 'Graphs from R in PowerPoint.pptx'



############################################# Loading in the data ######################################



data_AE <- xlsx_cells(path = paste(path_input, file_AE, sep = '/'), #look at the file path and find the named xlsx file
                      sheets = 'A&E Data') #look at the sheet called A&E Data
# I cheekily converted my xls file into a xlsx file to be able to work with the xlsx_cells function
# I also put in "Decision to admit" in the cells where there was no top heading 
# This is to stop these rows being categorised as the previous heading (Emergency Admissions)


########################################## Tidying the data ############################################ 


# I want to convert my merged title rows into tidy data
# I want to use the behead function to start at the first cell of data (D19) and direct RStudio to the appropriate titles and labels
# behead(Compass function from cell D19, Name you want the column to be)
# Available compass functions: "NNW", "N", "NNE", "ENE", "E", "ESE", "SSE", "S", "SSW", "WSW", "W", "WNW"

data_AE_tidy <- data_AE %>%
  
  dplyr::filter(!is_blank, row >= 17) %>% 
  # The title rows begin on row 17 so I am not interested in any rows before this
  
  behead("NNW", "Attendance_Admission") %>% 
  # Since the cell is merged, saying 'go North' from D19 doesn't work, NW isn't a viable function so NNW it had to be
  # The merged top row is attendances or admission so I'm going to call it Attendance_Admission
  
  behead("N", "AE_Type") %>% 
  # Go North from D19 to find the A&E Type headings 
  
  behead("W", "Month") %>% 
  # For some unknown reason, in row 100 there are cells containing the month name so this command is necessary
  
  behead("W", "Period") %>% #The period is in column C with the date on
  # Go West from D19 to find the Period data
  
  dplyr::select(Attendance_Admission, AE_Type, Period, Value = numeric)
  # Columns to put in the data where the numerical values (data from D19 onwards) contain the figures


########################################## Attendance graph  ########################################### 



unique(data_AE_tidy$Attendance_Admission) # What different options does this column have?
unique(data_AE_tidy$AE_Type) # What different options does this column have?
unique(data_AE_tidy$Period) # What different options does this column have?


# I want to look at A&E attendances for the 3 different department types from April 2018 onwards
data_for_graph1 <- data_AE_tidy %>%
  dplyr::filter(Period >= ("2018-04-01"),
         Attendance_Admission == "A&E attendances",
         AE_Type %in% c("Type 1 Departments - Major A&E", 
                        "Type 2 Departments - Single Specialty", 
                        "Type 3 Departments - Other A&E/Minor Injury Unit")) %>%
  dplyr::mutate(AE_Type = dplyr::case_when(AE_Type == "Type 1 Departments - Major A&E" ~ "Type 1",
                             AE_Type == "Type 2 Departments - Single Specialty" ~ "Type 2",
                             AE_Type == "Type 3 Departments - Other A&E/Minor Injury Unit" ~ "Type 3",
                             TRUE ~ AE_Type))
#since all of the labels are really long, the case_when statement changes the longer labels into ones that are more brief


data_for_graph1 
# Take a look at the data. Since the data is coming up with some pretty large numbers, I'm going to reduce these figures


# I want to reduce the Values by 1000
data_for_graph1 <- data_for_graph1 %>%
  dplyr::mutate(Value = Value / 1000) # Divide by 1,000 to reduce the big values


# I want to put in my organisation's colour scheme into the graphs
my_colours <- c(rgb(0,114,198, max=255), rgb(160, 0, 84, max=255), rgb(0,173,198, max=255), rgb(0,56,147, max=255))
my_lines <- c("solid", "solid", "dotted", "solid") #solid lines for all except the provider plans


graph_line1 <- ggplot(data = data_for_graph1, 
                     aes(x = Period,
                         y = Value,
                         colour = AE_Type,
                         group = AE_Type,
                         linetype = AE_Type)) +
  geom_line(size = 1) + 
  scale_colour_manual(values=my_colours) + #Use the colours specified in my_colours variable
  scale_linetype_manual(values = my_lines) +
  theme_minimal() + 
  ggtitle(paste('A&E attendances from April 2018 onwards')) + 
  theme(legend.position="bottom",
        legend.title = element_blank()) +
  labs(x = element_blank(),
       y = "Attendances (1,000s)") 

graph_line1 # view the graph to check that it looks OK



########################################## Admission graph  ############################################ 


# I just want a dataset for Emergency admissions
data_emergency_admissions <- data_AE_tidy %>%
  dplyr::filter(Attendance_Admission == "Emergency Admissions")


unique(data_emergency_admissions$AE_Type) # What different options does this column have?
unique(data_AE_tidy$Period) # What different options does this column have?


# I want to exclude the total figures from my emergency admissions dataset
data_for_graph2 <- data_emergency_admissions %>%
  dplyr::filter(AE_Type %in% c("Emergency Admissions via Type 1 A&E",
                        "Emergency Admissions via Type 2 A&E",
                        "Emergency Admissions via Type 3 and 4 A&E",
                        "Other Emergency Admissions (i.e not via A&E)"),
         Period >= ("2018-10-01")) %>%
  dplyr::mutate(AE_Type = case_when(AE_Type == "Emergency Admissions via Type 1 A&E" ~ "Type 1",
                   AE_Type == "Emergency Admissions via Type 2 A&E" ~ "Type 2",
                   AE_Type == "Emergency Admissions via Type 3 and 4 A&E" ~ "Type 3 and 4",
                   AE_Type == "Other Emergency Admissions (i.e not via A&E)" ~ "Other",
                   TRUE ~ AE_Type)) %>%
  dplyr::mutate(Value = Value / 1000) # Divide by 1,000 to reduce the big values

data_for_graph2 # Take a look at the data


graph_bar1 <- ggplot(data = data_for_graph2, 
       aes(x = Period,
           y = Value,
           group = AE_Type,
           colour = AE_Type,
           fill = AE_Type)) +
  geom_bar(stat = "identity") + #create a bar chart using the Values column
  scale_fill_manual(values = my_colours) + #Use the colours specified in my_colours variable for the inside of the bars
  scale_colour_manual(values=my_colours) +  #Use the colours specified in my_colours variable for the outline of the bars
  theme_minimal() + 
  ggtitle(paste('Emergency admissions from October 2018 onwards')) + 
  theme(legend.position="bottom",
        legend.title = element_blank()) +
  labs(x = element_blank(),
       y = "Admissions (1,000s)") 

graph_bar1 #Take a look at the bar chart


########################################## Creating the PPT ############################################ 


## TITLE SLIDE
# Read in the PowerPoint template (ensure that is a blank PPT)
this_ppt <- read_pptx(paste(path_input, file_powerpoint, sep = '/')) 


# Add a slide as layout = Title (for different layouts, go to your PowerPoint and select the layout dropdown - the names are the same)
this_ppt <- add_slide(x = this_ppt, layout = 'Title Slide', master = "Office Theme")


# Put a title on the title slide
this_ppt <- ph_with_text(x = this_ppt, type = "ctrTitle", str = "A&E Example PowerPoint") 


# Add a subtitle on the title slide
#this_ppt <- ph_with_text(x = this_ppt, type = "subTitle", str = "Attendances and Admissions") 


## TITLE AND CONTENT SLIDE 1
# Insert a new title and content slide
this_ppt <- add_slide(x = this_ppt, layout = 'Title and Content', master = "Office Theme")  


# Put a title on the title and content slide
this_ppt <- ph_with_text(x = this_ppt, type = "title", str = "A&E attendances") 


# Insert the A&E ggplot into the "body" section of the slide
this_ppt <- ph_with_vg(x = this_ppt, code = grid.arrange(graph_line1, nrow =  1), type = "body")


## TITLE AND CONTENT SLIDE 2
# Insert a new title and content slide
this_ppt <- add_slide(x = this_ppt, layout = 'Title and Content', master = "Office Theme")  


# Put a title on the title and content slide
this_ppt <- ph_with_text(x = this_ppt, type = "title", str = "A&E admissions") 


# Insert the admissions ggplot into the "body" section of the slide 
this_ppt <- ph_with_vg(x = this_ppt, code = grid.arrange(graph_bar1, nrow =  1), type = "body")


## TITLE AND CONTENT SLIDE 3
# Insert a new title and content slide
this_ppt <- add_slide(x = this_ppt, layout = 'Title and Content', master = "Office Theme")  


# Put a title on the title and content slide
this_ppt <- ph_with_text(x = this_ppt, type = "title", str = "A&E attendances and admissions") 


# Insert both the A&E and admissions ggplots in 2 rows
this_ppt <- ph_with_vg(x = this_ppt, code = grid.arrange(graph_line1, graph_bar1, nrow =  2), type = "body")


## TWO CONTENT SLIDE
# Insert a new Two Content slide
this_ppt <- add_slide(x = this_ppt, layout = 'Two Content', master = "Office Theme")  


# Put a title on the slide
this_ppt <- ph_with_text(x = this_ppt, type = "title", str = "More A&E attendances and admissions") 


# Put in the 1 by 2 grid of the ggplots, on the left
this_ppt <- ph_with_vg(x = this_ppt, code = grid.arrange(graph_line1, graph_bar1, nrow =  2), type = "body", index = 1)


# Put in some text, on the right
this_ppt <- ph_with_text(x = this_ppt, type = "body", index = 2, str = "Here be comments")


##  OOPS
# Forgot the subtitle on title slide
this_ppt <- on_slide(this_ppt, index = 1)
this_ppt <- ph_with_text(x = this_ppt, type = "subTitle", str = "Attendances and Admissions") 

########################################## Exporting the data ########################################## 

print(this_ppt, #what variable to print out
      paste(path_output, output_powerpoint, sep = "/")) #where to print it to

write.csv(data_AE_tidy, paste(path_output,output_csv, sep = '/'), row.names = FALSE) #export the data in a CSV file

