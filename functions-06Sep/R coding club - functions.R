#create test dataframe
df <- tibble::tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

#normalise all the variables using minmax normalisation
df$a <- (df$a - min(df$a, na.rm = TRUE)) / 
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$b <- (df$b - min(df$b, na.rm = TRUE)) / 
  (max(df$b, na.rm = TRUE) - min(df$b, na.rm = TRUE))
df$c <- (df$c - min(df$c, na.rm = TRUE)) / 
  (max(df$c, na.rm = TRUE) - min(df$c, na.rm = TRUE))
df$d <- (df$d - min(df$d, na.rm = TRUE)) / 
  (max(df$d, na.rm = TRUE) - min(df$d, na.rm = TRUE))

#take the first instance of this operation
(df$a - min(df$a, na.rm = TRUE)) /
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))

#It just has the one input df$a

#assign inputs as variables to help identify inputs
x <- df$a
(x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))

#remove duplication by introducing range
rng <- range(x, na.rm = TRUE)
(x - rng[1]) / (rng[2] - rng[1])

#create the function
rescale01 <- function(x){
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

#applying it to our problem
df$a <- rescale01(df$a)
rescale01(c(1,"ns",1))

#simplifying the multiple applications with a for loop
for (i in seq_along(df)) {
  df[[i]] <- rescale01(df[[i]])
}


#note we use [[]]
df[1]
df[[1]]
v <-df[1]
str(v)
v<-df[[1]]
str(v)

#purrr approach for even more simplicity
df <- purrr::map_dfr(df, rescale01)



#Data and detail arguments
mean_ci <- function(x, conf = 0.95) {
  se <- sd(x) / sqrt(length(x))
  alpha <- 1 - conf
  mean(x) + se * qnorm(c(alpha / 2, 1 - alpha / 2))
}

#if an argument has a defult not stating it in the function call will mean the default is used.
x <- runif(100)
mean_ci(x)

#you only state the detail argument if you want to use a different value to the default
mean_ci(x, conf = 0.99)


