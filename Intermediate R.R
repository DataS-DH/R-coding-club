library(rlang)
library(dplyr)
library(magrittr)



# ### Objects, copying, and memory usage --------------------------------------------------

# |- What is an object, it's name and how are they referenced? -----

# Starting memory
memory.size()

x <- c(1:100000)

# Memory after creating a new large vector
memory.size()

y <- x

# Memory after defining a new vector y to be the same as x
memory.size()

z <- c(1:100000)

# Memory after creating a new vector z, without referencing x/y but to be the same as x.
memory.size()

# We can now see the memory "address" for the objects we've created.
lobstr::obj_addr(x)

lobstr::obj_addr(y)

lobstr::obj_addr(z)

# x and y actually reference the same object. The object has two names.
# Z has created an entirely new object although the same as x

# So we've seen that referencing another object doesn't increase memory usage.
# The object is only saved once but we might call it by two names, x and y.


# What if we change y now? What happens to x?

memory.size()

y[[3]] <- 4

lobstr::obj_addr(x)

lobstr::obj_addr(y)

memory.size()

# Now we have two objects. One named x and one named y and as such, both are using up memory.

# R behaves by copy-on-modify. When something is modified, it is copied, and doesn't overwrite the original object.


# Note: run next lines all at once as RStudio does odd things described later.

# Lets follow what happens to the objects a and b below.

a <- c(1,2,3)

# This lets us trace when objects are copied by showing us the addresses.
cat(tracemem(a), "\n")

b <- a
b[[3]] <- 4L

lobstr::obj_addr(b)

# What if modify b again?

b[[3]] <- 5L

lobstr::obj_addr(b)

# In this case we can see that modifying the object doesn't change its address
# Further details below on how this changes and what we define as 'modifying'



# |- How about when we use lists? ----


xyList <- list(x,y)


lobstr::obj_addr(x)

lobstr::obj_addr(xyList)

lobstr::obj_addr(xyList[[1]])


# So is the list xyList still referencing the same objects as before. What happens if we copy the list?

xyList2 <- xyList

lobstr::obj_addr(xyList)
lobstr::obj_addr(xyList2)
# Copying the list behaves as we expect. Same address.


xyList2[[1]][3] <- 4

lobstr::obj_addr(y)
lobstr::obj_addr(xyList2[[2]])
# Modifying the x element of the list doesnt change that the list is referencing the y object.


lobstr::obj_addr(x)
lobstr::obj_addr(xyList2[[1]])
# Because we changed the x element, it no longer points to the x object from before. A new object has been created  (copy-on-modify)

lobstr::ref(xyList, xyList2)
# Here shows a summary of before.


## |- How about when we use data.frames ----

memory.size()

df <- data.frame(x,y)

memory.size()

# Memory hasn't increased by much. It's using the same objects as before.

lobstr::obj_addr(x)
lobstr::obj_addr(y)
lobstr::ref(df)

# Data frames are a bunch of vectors (columns)
# So changing columns will create a single new object. Changing Rows will create multiple new objects.

# Example

df2 <- df

lobstr::ref(x, y, df, df2)
# A summary of what objects addresses are and what are within df and df2

df2[, 2] <- df2[, 2] * 2
# Modifying the 'y' object in df2

lobstr::ref(x, y, df, df2)
# A new object has been created in the second column for df2




# |- Global string pool - Interesting fact about R ----

string <- c("a","a","b","c","abc")

lobstr::ref(string)

lobstr::ref(string, character = TRUE)
# Although we wrote out "a" twice, R is clever and defines them as the same object being referenced.
# This purely helps memory usage. Do not worry about it in your code.

# Example

banana <- "bananas bananas bananas"
lobstr::obj_size(banana)
lobstr::obj_size(rep(banana, 100))


lobstr::obj_size(c("a","b","c"))
lobstr::obj_size(c("a","b","c"), c("d","e","f"))
lobstr::obj_size(c("a","b","c"), c("a","a","a"))



## |- Modifying in place ----
# Objects have three 'states' of bindings/references. 0, 1 or many.

o <- c(1,2,3) # Here we are setting a single name to the vector. A single reference to the object is called 'o'.
pryr::address(o)

# If we modify this, the address won't change. objects with a single binding get a special status so that it doesn't change how often it's been referenced.
# It will stay at a single reference of 1. 
# As soon as an object is referenced 2+, it can never go back to 0 or 1. It will forever be 'many'.

# Run this part at once (see RStudio note below)
o <- c(1,2,3)
pryr::address(o)

o[[3]] <- 4
o[[3]] <- 5
o[[3]] <- 6
pryr::address(o)

# Whenever you use most functions on an object, that object gets referenced, thus increasing its number to 'many' and introducing more copies.
# primitive functions don't do this. (Functions writting in C)
# Primitive include: This includes [[<-, [<-, @<-, $<-, attr<-, attributes<-, class<-, dim<-, dimnames<-, names<-, and levels<-. 


# |- RSTUDIO AND IT'S INFLUENCE ON ADDRESSES  ----

# RStudio is odd, and actually every object has 2 references/bindings. The environment (top right box) has it's own reference.
# As such, every time you create an object via the command line it will make a copy.

# This doesnt affect code inside functions and so shouldn't affect performance. But does make this script slightly more difficult to explore.

# TODO: make this RMarkdown script

# Example - run this line by line, then all at once.

rstudio_example <- c(4,5,6)
pryr::address(rstudio_example)

rstudio_example[[3]] <- 7
pryr::address(rstudio_example)
rstudio_example[[3]] <- 8
pryr::address(rstudio_example)
rstudio_example[[3]] <- 9
pryr::address(rstudio_example)

###




# |- Why are my for loops so slow? It might be because you're making lots of copies -----

x <- data.frame(matrix(runif(5 * 1e4), ncol = 5))

# Take median across each column
medians <- vapply(x, median, numeric(1))

# For each column, minus the median from the value
cat(tracemem(x), "\n")
lobstr::ref(x)

for (i in seq_along(medians)) {
  x[[i]] <- x[[i]] - medians[[i]]
}

# We can see it's made 5 copies. This is not using primitive functions.  [[.data.frame is a regular function and increased x's referencing.

# Modifying a list uses internal C code, thus not increasing references each time. Lists are pretty great for keeping your memory down!

y <- as.list(x)

cat(tracemem(y), "\n")
lobstr::ref(y)

for (i in 1:5) {
  y[[i]] <- y[[i]] - medians[[i]]
}

lobstr::ref(y)

# If you've got memory issues, cat(tracemem(x), "\n") can help you see where you may be copying big data frames.









# ### if, ifelse, and switch --------------------------------------------------

# What is the difference between IF and IFELSE?

# If statements can only take a single TRUE or FALSE test, if you put more in R will just take the first entry.
if (TRUE) { "output" }
if (c(TRUE, FALSE)) {"output" }
if (c(FALSE, TRUE)) { "output" }

# If else however can take a vector input, which means we can have a vector output of test results.
ifelse(TRUE,  "output", "failed")
ifelse(c(TRUE, FALSE),  "output", "failed")
ifelse(c(FALSE, TRUE),  "output", "failed")

# If else also allows missing values whereas if does not
ifelse(c(FALSE, NA, TRUE),  "output", "failed")
if (NA) { "output" }


# But, there are certain problems we may encounter.

# Problem 1: What if I have multiple conditions I want to test?
# For this we can use if () {} else 

x <- 5

if(x == 1){ "output 1"
  } else if(x == 2){ "output 2"
  } else if(x == 3){ "output 3"
  } else if(x == 4){ "output 4"
  } else {"failed"}

# But this could get tedious, especially with long pieces of code. 

# Instead we can use the switch function. This allows us multiple values that x can take in a much shorter bit of code.

switch(as.character(x),
       "1" = "output 1",
       "2" = "output 2",
       "3" = "output 3",
       "4" = "output 4",
       "Failed")


# Problem 2: What if I have vectorised input BUT - I have multiple possible outcomes?

# I think everyone will have done this at some point in their coding journey.

ifelse(FALSE,  "output", 
       ifelse(FALSE,  "output 2", 
              ifelse(FALSE,  "output 3", "failed")))

# This code can get long and looks untidy, especially if you need to reorder the ifelse statements later.

# Instead we can use case_when (familiar for those using SQL) from dplyr

x <- c(1,2,3,4)

dplyr::case_when(
  x == 1 ~ "output 1",
  x == 2 ~ "output 2",
  x == 3 ~ "output 3",
  TRUE ~ "failed"
)

# This can also replace the switch() from before. But switch is base R whereas case_when is not.



# ### Non-standard evaluation and !! bang-bang ------------------------------------------------------------------

## SE and NSE

# Before we start, we need a rough understanding of Non-standard evaluation.
# Parts of R utilise Non-standard evaluation (NSE), which roughly lets you
# modify an expression or its meaning after it has been issued but before it is executed. 
# For instance

subset(mtcars, hp > 250) 

# the function subset interrupts hp > 250 before it is run,instead it looks for a column called hp in mtcars
# rather than look for an object hp in the workspace. If we were to use standard evaluation it would be

mtcars[mtcars$hp > 250,]

# You can tell if something is quoted by running it alone in the console. 'hp' will give an error but 'mtcars$hp' will show you the data.

## NSE in tidyverse

# When we use the tidyverse, we directly refer to column names rather than directly referencing the column within an object (using NSE)

mtcars %>%
  mutate(NewColumn = 2*mpg)

# rather than (though it will work)

mtcars %>%
  mutate(NewColumn = 2*mtcars$mpg) 


## A problem encountered in using NSE in dplyr - functions

# Here is a function that creates a count of the number of rows for a grouping variable

group_func <- function(grouping_var){
  
  data %>%
    group_by(grouping_var) %>%
    summarise(n())
  
}

# If we try use that function on a small table of favourite foods and colours 

data <- data.frame(matrix(c("Fish fingers","Burgers","Purple","Green"),ncol=2,byrow = TRUE))
names(data) <- c("Favourite food","Favourite Colour")
data

group_func(`Favourite food`)


# So why doesn't this work? 

# When we run the function R is searching for 'grouping_var' within it's scope and not searching for `Favourite food`,
# it is quoting the argument 'grouping_var' and not finding it.
# When it is quoted rather than evaluated that means the function is using NSE.

# Some loose definitions
# 'Evaluated' argument - obeys R's usual evaluation rules. R passes arguments by value, they are evaluated in the calling environment and the values are passed 
#               to the function
# 'Quoted' argument - To capture an unevaluated expression - these are captured by a function and processed in a different way. As we saw with 
#                     subset(mtcars, hp > 250), hp is being captured by the function and processed to search for that column name in mtcars.
# 'Unquotation - To be able to selectively evaluate parts of an otherwise quoted expression. Unquoting a single expression will evaluate it, and inline
#                the results.

# So how do we resolve our problem?

# 1. We have to quote our argument
# 2. We have to tell dplyr it is already quoted, which is done by unquoting it

# The bang-bang !! operator in rlang will unquote it for us

group_func_fixed <- function(grouping_var){
  
  data %>%
    group_by(!!grouping_var) %>%
    summarise(n())
  
}

group_func_fixed(quo(`Favourite food`))

# Now `Favourite food` isn't being searching for in the global environment, it holds evaluation. It is now being quoted and unquoted in the function.


## Another problem - for loops

# Outside of functions we may come into an issue with say a for loop

for(i in names(data)){
  
  data %>%
    group_by(i) %>%
    summarise(n()) %>%
    print()
  
}

# This time we have gone a further step back, we are now inputting a string, and so we need to convert it to a symbol as that is what dplyr expects.
# Using rlang::sym we can do this

names(data)

rlang::sym(names(data)[1])

# Now using what we had before we can fix the for loop

for(i in names(data)){
  
  symbol_i <- rlang::sym(i)
  
  data %>%
    group_by(!!symbol_i) %>%
    summarise(n()) %>%
    print()
  
}




# The detail is more convoluted as described here, with quasiquoting and quosures. 

# For further information see: https://adv-r.hadley.nz/metaprogramming.html








# ### Rounding in R -----------------------------------------------------------

# In school (at least in my academic years), we were taught to round as follows;

# 0.0-0.49 rounds to 0
# 0.50-0.99 rounds to 1

# R uses a 'round-to-even' method to round. Which treats the exact value of 0.50 differently, it rounds to the nearest even number
# 0.5 -> 0
round(0.5,0)
# 1.5 -> 2
round(1.5,0)

# This is actually an international standard of rounding: IEC 60559 standard for computers

# The issues lies is that ending in .5 actually is exactly the same distance away from 0 and 1. 0.5 - 0.5 = 0, 0.5 + 0.5 = 1. 

# Rounding up as taught in school introduces a systematic bias, everything is rounded away from 0.

# This is important to note if you are rounding tables for publication.

# Here is an alternative function to R's base round() function, which rounds x.5 values to the nearest even integer

round2 = function(x, n) {
  posneg = sign(x)
  z = abs(x)*10^n
  z = z + 0.5
  z = trunc(z)
  z = z/10^n
  z*posneg
}


round2(0.5, 0)
round2(1.5, 0)
