#SIMPLE LINEAR REGRESSION IN R

#The packages you may need
library(ggplot2) #for data visualisation
library(dslabs) #for sample data to practise with
library(MASS)#more sample data to practise with
library(dplyr) #for data manipulation
library(tidyr) # for data manipulation

#Other packages will be introduced during the tutorial

#INTRO

#Performing linear regressions in R is very simple. You don't need to download any additional packages 
#to do the most basic forms of regression.

#However there are lots of additional things you can do to expand your analysis, inspect the data, 
#manipulate it and improve presentation as you would with statistical software like SPSS or STATA.

#This tutorial assumes that your dataset has already been cleaned and is ready for analysis - 
#but will also look at some common checks and manipulations of data.


#PREPARING FOR ANALYSIS
#-----------------------------------------

#1. Check the distribution of the data to check assumptions for different types regression- 
#this is easy to do using ggplot:

ggplot(diamonds, aes(x=price))+
  geom_bar()

#distribution is skewed to the right
#inspect by widening the length of bins

ggplot(diamonds, aes(x=price))+
  geom_histogram(binwidth=1000)


#you can also use the shapito wilkes test - if sample between 3 and 5000

shapiro.test(heights$height)

#2. recode from a continuous variable to an ordinal variable

#use dplyr to recode continuous variable into ordinal 'bins' - 


diamonds_2 <- diamonds %>%
  mutate(price_group = cut(price, breaks=c(0,500,1000, 2000, 3000,4000,5000, 7000, 10000, 20000), labels=c("0-500","501-1000", "1001-2000","2001-3000","3001-4000","4001-5000","5001-6000", "6001-10000","10001-20000" )))

ggplot(diamonds_2, aes(x=price_group))+
  geom_bar()

#Quick check for missing data using Amelia package

library(Amelia)

missmap(diamonds, col=c("blue", "red"), legend=FALSE)#no missing data

#example with missing data
missmap(gapminder, col=c("blue", "red"), legend=FALSE, rank.order=TRUE)


#DESCRIPTIVE STATISTICS
#-------------------------------------

#You can quickly build a table of descriptive stats using summarise function in dplyr

heights_data <- group_by(heights, sex) %>%
  summarise(
    count = n(), #number in each condition/group
    mean = mean(height, na.rm = TRUE), #mean
    median = median(height, na.rm = TRUE), #median
    IQR = IQR(height, na.rm = TRUE), # interquartile range
    sd = sd(height, na.rm = TRUE) # standard deviation
  )


# REGRESSION AND STATISTICAL ANALYSIS
----------------------------------

#1. CORRELATION

#the simplest form of correlation between 2 continuous variables

cor(use="all.obs", diamonds[c('price','x')] )
#as we already know there is no data missing, we can use all observations.
#you can specify complete.obs (listwise deletion), and pairwise.complete.obs (pairwise deletion) alternatively

#We know our price data is not normally distributed and can specify the method we want to use, 
# e.g. in this case with Spearman

cor(diamonds[c('price','x')],use="all.obs", method="spearman" )

#Note: this will provide the coefficient but not the signifigance...

#you can get p value for a single coefficient using cor.test - note need to specify x and y values separately

cor.test(x=diamonds$price,y=diamonds$x, use="all.obs")

#note the p value is the smallest possible output the system can show

#The rcorr( ) function in the Hmisc package produces correlations/covariances and 
#significance levels for pearson and spearman correlations. However, input must be a matrix and pairwise deletion is used.

library(Hmisc)

rcorr(diamonds$price, diamonds$x,type="spearman")


#tidy intoa table

table <- rcorr(diamonds$price, diamonds$x,type="spearman")


#this readout isn't the best looking - here's a quick way to tidy it up

library(broom)

  
table2 <- tidy(table)

#more complex visualisation - use the corrplot package

library(corrplot)

#corrplot helps you visualise a correlation matrix

#select your data for the matrix - in this case we're using columns 1 and 5-10 from diamonds dataset
cut <- as.matrix(diamonds[c(1,5:10)]) 

#create correlation matrix
corr_matrix <- cor(cut)

corrplot(corr_matrix, method="number") # this will display the correlation coefficient

corrplot(corr_matrix, method="color") # there are lots of different visual options to change style


#combine with signifigance test

res1<- cor.mtest(cut , conf.level = .95)# creates p values

corrplot(corr_matrix, p.mat = res1$p, sig.level= .05)# combine with coefficients -
#p values must be included with p.mat expression

#you can set your signifigance level using sig.level nad show which are signifigant=
corrplot(corr_matrix, method="color", p.mat = res1$p, insig = "label_sig",
         sig.level = c(.001, .01, .05), pch.cex = 1.2, pch.col = "black")


#MULTIPLE REGRESSION

#can be performed in base r using the lm function with y as dependent variable

fit <- lm(y ~ x1 + x2 + x3, data=mydata)#example

mrdiamonds <- lm( price ~  carat + z,data=diamonds)
summary(mrdiamonds)

mrdiamondstable <- tidy(mrdiamonds)


#other useful functions

coefficients(mrdiamonds) # model coefficients
confint(mrdiamonds, level=0.95) # CIs for model parameters 
fitted(mrdiamonds) # predicted values
anova(mrdiamonds) # anova table 
vcov(mrdiamonds) # covariance matrix for model parameters 
influence(mrdiamonds) # regression diagnostics

#plot residuals
#you can inspect residual quickly using base r plot function

plot(mrdiamonds)

#or you can use GG plot to create custom visualisations
#first add  redisuals and predicted values to your dataset

#will use a smaller dataset to illustrate this
d <- iris %>% 
  select(-Species)

# Fit the model - using the '.' runs MR with all remaining varianbles
fit <- lm(Sepal.Width ~ ., data = iris)

# Obtain predicted and residual values
d$predicted <- predict(fit)
d$residuals <- residuals(fit)

# Create plot
d %>% 
  gather(key = "iv", value = "x", -Sepal.Width, -predicted, -residuals) %>% 
  # use gather function on independent variables
  ggplot(aes(x = x, y = Sepal.Width)) + #plot actuals
  geom_point(aes(color = residuals)) + #plot residuals
  guides(color = FALSE) +
  geom_point(aes(y = predicted), shape = 1) +#plot predicted
  facet_grid(~ iv, scales = "free_x") + 
  #facet grid function allows you to show all independent variables side by side
  theme_bw()+
  #you can also add connecting lines between actual and predicted
  geom_segment(aes(xend = x, yend = predicted), alpha = .2) 




#TESTS OF DIFFERENCE
#-----------------------------------

#Chi Squared test

#check dataset for categorical variables
str(Cars93)

#produce table with variables to use

Ctable <- table(Cars93$Origin, Cars93$AirBags) #Air bags
Dtable <- table(Cars93$Origin, Cars93$Man.trans.avail) #manual transmission

print(Ctable)
chisq.test(Ctable) #not signifigant

print(Dtable)
chisq.test(Dtable) #p= <0.0001


#t-test - 
#paired (two related variables) e.g. before and after treatment

t.test(x~y, paired=TRUE)

#need to order dataset to make sure results are paired

sleep2 <- sleep %>%
  group_by(group, ID)


# Paired t-test - 
t.test( extra~group , sleep2, paired=TRUE, altneraitve = "two.sided")

#can state two sided or one sided hypothesis

#in reality though this data set may be too small to run a t-tes unless it meets test for normality so:

#as sample test < 30 need to run test for normality

shapiro.test(sleep$extra)
#does meet the test for normality

#wilcoxon:non parametric alternative to paired t test



wilcox.test(extra ~ group,sleep2, paired = TRUE, alternative = "two.sided")

#there is a zero value in this dataset which promted the warning...


#independent t-test
t.test(y1, y2, paired=FALSE)
#are mean heights same for men and women (this data is normally distributed)


t.test(heights$height~heights$sex, paired = FALSE)

#You can use the var.equal = TRUE option to specify equal variances 
#and a pooled variance estimate. You can use the alternative="less" or alternative="greater" option 
#to specify a one tailed test.





#RESOURCES:

#offline: discovering statistics using r by andy field

#Online:
#using corrplot https://cran.r-project.org/web/packages/corrplot/corrplot.pdf
#Nice visual tutorial for corrplot: https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html

# t-tests: https://datascienceplus.com/t-tests/

#plotting residuals
#http://www.r-tutor.com/elementary-statistics/simple-linear-regression/residual-plot


