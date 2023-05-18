
library(dplyr)
library(assertive)


hypotenus <- function(x, y){

    #check x
    tryCatch(
        x %>%
            assert_is_numeric() %>%
            assert_all_are_greater_than(0) ,
        error=function(e){
            NULL
            stop('ERROR')
        }
    )

    #check y
    tryCatch(
        y %>%
            assert_is_numeric() %>%
            assert_all_are_greater_than(0) ,
        error=function(e){
            NULL
            stop('ERROR')
        }
    )

    #calculation
    if(!is.null(x)  & !is.null(y)) z <- sqrt( x^2 + y^2 )
    return( z )
}

