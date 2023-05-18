rm(list=ls())
cat("\014")

library(testthat)

source(here("simple_function.R"))

test_that(
    "Test that hypotenus returns correct values",
    {
        expected <- 5;
        actual <- hypotenus(3,4)
        expect_equal(expected, actual)
    }
)

test_that(
    "Test that hypotenus fun with x='3', y=4 returns error",
    {
        expect_error(
            hypotenus("3",4)
        )
    }
)


test_that(
    "combined tests",
    {
        expect_equal(5, hypotenus(3,4))
        expect_equal(sqrt(2), hypotenus(1,1))
        expect_error( hypotenus("3",4) )
    }
)

test_that(
    "Failing test",
    {
        expect_equal(-5, hypotenus(3,4))

    }
)

#Using the command line
# test_file(here("tests","test_that_example.R"))
# test_file(here("tests","test_that_example.R", "minimal"))
# test_file(here("tests","test_that_example.R", "summary"))
# test_file(here("tests","test_that_example.R", "progress"))
# test_dir(here("tests"))


