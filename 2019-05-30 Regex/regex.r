### Start of Section 1

library("eurostat")
library("tidyverse")
library("lubridate")

toc <- get_eurostat_toc()

toc %>%
  filter(str_detect(title, "death")) %>%
  View()

death_data <- get_eurostat("hlth_cd_anr")

View(death_data)

### End of Section 1
 

uk_deaths <- death_data %>%
  filter(geo=="UK")

View(uk_deaths)

## End of Section 1

## Start of Section 2
uk_deaths %>%
  filter(age=="TOTAL") %>%
  filter(str_detect(sex, "[MF]")) %>% # Filtering out total deaths
  group_by(sex, time) %>% 
  summarise(values=sum(values, na.rm = T)) %>% # Collapsing cause of death so we only have total deaths, sex and date
  # (There is double-counting. Filtering to remove double-counting is an exercise for the reader.)
  ggplot(aes(x=time,y=values, colour=sex)) + geom_line() + theme_minimal() # ggplot it.
## End of Section 2

## Start of Section 3

death_data %>%
  filter(str_detect(icd10, "[HK]")) %>%
  pull(icd10) %>%
  unique() ## Too many codes!

death_data %>%
  filter(str_detect(icd10, "^[HK]")) %>%
  pull(icd10) %>%
  unique() ## Too many codes!

## End of section 3

## Start of Section 3

unclean_data <- uk_deaths %>%
  mutate(year = year(time)) %>%
  mutate(month = month(time)) %>%
  mutate(day = day(time)) %>%
  mutate(format = runif(nrow(uk_deaths))) %>%
  mutate(untidy_time = if_else(format<0.5,
                               paste(year, month, day, sep = "/"),
                               paste(day, month, year, sep="/"))) %>%
  select(-c(time, year, month, day, format))


unclean_data %>%
  mutate(year = str_extract(untidy_time, "[0-9]{4}") %>%
           as.numeric())

## End

