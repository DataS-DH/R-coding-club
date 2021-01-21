
setwd("C:/R/Coffee & Coding")

#Amend column names so the spaces are replaced with spaces
colnames(data) <- str_replace_all(colnames(data), " ", "_")

#code example with issue trying to sum
#summarise data
data %>%
  select (Grade, FTE) %>%
  group_by(Grade) %>%
  filter (Staff_group=='HCHS Doctors') %>%
  summarise(sum(FTE))

#Step 1 - what does the error say?

#Step 2 - go through the basic checks (spelling, brackets, commas, function)

#Step 3 - troubleshooting code line by line
data %>%
  select (Grade, FTE) %>%
  group_by(Grade) %>%
  filter (Staff_group=='HCHS Doctors') %>%
  summarise(sum(FTE))

#Step 4 - tackoverflow or Google