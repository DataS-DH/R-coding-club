if(!require("remotes")) install.packages("remotes")
if(!require("checkpoint")) install.packages("checkpoint")


pkgs <- checkpoint::scanForPackages(project = "2020-10-22 Interactive Graphs/", use.knitr = TRUE)$pkgs
remotes::install_cran(pkgs)

