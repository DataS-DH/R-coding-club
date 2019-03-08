install.packages("gapminder")
library(gapminder)

install.packages("tidyverse")
library(tidyverse)

gm_data <- gapminder

gapminder %>%
  filter(year == 2015) ->
  gapminder15

gapminder %>%
  filter(year == 2007) ->
  gapminder7

gapminder7 %>% 
  ggplot(aes(income, life_exp))

gapminder7 %>%
  ggplot(aes(gdpPercap, lifeExp))
