## Environments in R

# Note: most of the following is taken from Hadley Wickham's Advanced R book.

library(rlang)

# An environment is similar to a named list except for a few exceptions.

# The role of environments is to bind a set of names to a set of values. 
# These bindings have no order, they're effectively all in a jumbled up bag.

# Environments also behave different to objects, they are not copied when modified.

# Environments can also contain themselves.



# Let's create an environment

rlang::env()

e1 <- env(
  a = FALSE,
  b = "a",
  c = 2.3,
  d = 1:3,
)

# We can now overwrite 'd' in the environment e1 to be itself.

e1$d <- e1

# To check, we can't use normal notation.

e1$d

# instead we need  

env_print(e1)

env_print(e1$c) # This doesn't work as 'c' isn't an environment

env_print(e1$d)

env_names(e1)
names(e1)


### Different environments

# The current environment is where your code is current executing from.

current_env()

# The global environment is often called your 'workspace' and is where all your computation takes place.
# Except for when you're running things like functions.

global_env()


# To compare environments we can use the 'identical()' command, we can not use '=='. 
# Because == is for vectorised variables, and environments have no order.


identical(global_env(), current_env())


global_env() == current_env()

### Parents

# Every environment has a parent, and if a name is not found in the environment, it will then search
# the parent environment, and continue until found. You can set parent environments, else it will default
# to the current environment. 

e2a <- env(d = 4, e = 5)
e2b <- env(e2a, a = 1, b = 2, c = 3)

env_parents(e2b)

# Parents can't go on forever and the final environment is the empty environment. All parents
# will terminate here. By default env_parents() will stop at the global environment rather than
# the empty environment.

# This is useful since packages become parents of the global environment.

# You can find the parent environment with the following function.

parent.env(e2b)


## Super assignment

# The '<-' function is used to assign values to names in your current work space.

# The '<<-' is a super assigner, it will *never* create a variable in the current workspace.
# Instead it will modify one in the parent environment, and if it doesnt find an existing variable
# there, it will instead create it in the the global environment.

# One use of this is create variable in a function to exist outside that function after.


test <- function(a){ 
   a <- 1
   b <- 2*a
   #return(b)
   }

test(a)


func <- function(f) {
  x <<- f
}

x

func(1)

x


### Using environments 

# Environments behave similarly to lists.

e3 <- env(x = 1, y = 2)
e3$x

e3$z <- 3
e3[["z"]]

# One aspect is we can't use numeric indices to call parts of the environment.
e3[[3]]

# Because there is no order to an environment, there is not 'third' thing to call upon.

#### MAYBE ADD MORE HERE.

# Two ways to create new variables in an environment


env_poke(e3, "a", 100)
e3$a

env_bind(e3, a = 10, b = 20)
env_names(e3)

# A differentiation between lists and environment is setting variables to 'Null'.
# An environment will keep that variable as null because you want need to reference it.
# A list will remove that object.
# Instead you must unbind and object in an environment. This won't delete it, until the garbage
# collector does.

e3$a <- NULL
env_has(e3, "a")

env_unbind(e3, "a")
env_has(e3, "a")

# Current environment functions

get(), assign(), exists(), and rm() # are all current environment functions.


## Advanced bindings for environments.

env_bind_lazy() # creates delayed bindings, these are evaluated the *first* time they're evaluated.
# They behave the same way as function arguments. 

env_bind_lazy(current_env(), b = {Sys.sleep(1); 1})

system.time(print(b))

system.time(print(b))

# The primary use of delayed bindings is in autoload(), which allows R packages to provide datasets
# that behave like they are loaded in memory, even though they're only loaded from disk when needed.

env_bind_active() #creates active bindings, these evaluate everytime they're accessed.

env_bind_active(current_env(), z1 = function(val) runif(1))

z1

z1

### Recursing over environments

### MORE HERE


### Special Environments

# Most environments will be created by R itself, not by you. For instance, each time you load in a package,
# The package becomes a parent of the Global environment. The immediate parent of the Global Env is the last
# package you loaded.

# You may have encountered some warnings when loading packages 

library(plyr)
library(dplyr)

# both plyr and dplyr have some functions with the same name. Since dplyr was attached last, that package's
# functions will be called first.

search_envs()

# Here is a list of packages loaded, note two of the last ones;
# Autoloads (delayed bindings of datasets that come with packages, to stop them using memory until called)
# package:base (all the base R functions, these get masked by newer loaded packages)

search_envs()

## Function Environments

# Everytime a fuction is created it binds the current environment. 


y <- 1
f <- function(x) x + y
fn_env(f) # You can get the function environment with fn_env()

# or

environment(f)

# Here f() binds the environment that binds the name f to the function. But this may not always be the case.

e <- env()
e$g <- function() 1

# Here, g is bound in a new environment but g() binds the global environment.

# This shows the distinction in being bound and binding; how we find g, compared to how g finds its variables.



### Namespaces

# As we saw earlier when loading plyr and dplyr, the order of which we load the packages will affect which 
# function we may end up calling if both packages have the same named function. What if we have functions within
# a package that rely on each other and they end up referencing the wrong function?
# Namespaces are the solution to this problem.

# E.g. the way sd() relies on var(), what if a library masked var to a different function?
sd

var 

# Each function in a package is associated with two environments, the package environment and a namespace environment.
# The package environment is for how the user interacts with the package via ::, it's parent determined by load order.
# The namespace is internal to the package, it's how the package functions finds its variables.


# This is why being bound and binding to environments is so crucial and what packages rely on.
# Every binding in the package environment is also found in the namespace environment; this ensures every
# function can use every other function in the package.

# But some bindings only occur in the namespace
# environment. These are known as internal or non-exported objects, which make it possible to hide 
# internal implementation details from the user.



# So each namespace has an imports environment that contains bindings to all functions used by the package. (think dependencies and base)
# To stop importing base functions, the base namespace is actually the parents of the imports environment. 
# Next its parent is the global environment and so forth.

# There's no direct link between the package and namespace environments; the link is defined by the function environments.



## Further reading: execution environments and Call stacks.




