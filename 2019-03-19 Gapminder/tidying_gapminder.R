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

gap_plot <- function(data) {
  data %>%
    arrange(desc(pop)) %>%
    ggplot(aes(gdpPercap, lifeExp)) +
    geom_point(aes(fill=continent, size= pop), shape = 21) +
    scale_x_log10(breaks=2^(-1:7) * 1000) +
    scale_size(range=c(1, 20), guide=FALSE) +
    scale_fill_manual(
      guide = FALSE,
      values=c(
        Africa = "#60D2E6",
        Americas = "#9AE847",
        Asia = "#EC6475",
        Europe = "#FBE84D",
        Oceania = "#A537FD"
      )
    ) +
    labs(
      x="Income (GDP / Capita)",
      y="Life expectancy (years)"
    )
}

gap_plot(gapminder7)

gapminder%>%
  filter(year == 1992) %>%
  gap_plot

by_year <- gapminder %>%
  filter(year %% 3 == 0) %>%
  group_split(year)

plots <- map(by_year, ~ gap_plot(.x))
plots[1]
by_year
