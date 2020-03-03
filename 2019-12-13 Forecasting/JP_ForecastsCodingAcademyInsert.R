############## R Coding Academy - 13th December 2019 ###########################
### Workshop code 
### materials taken from everywhere but especially the PAT "ACTIVITY PLANNING 
### FORECASTING CODE" available at https://github.com/NHSEI-Analytics
### also read this https://otexts.com/fpp2/
### ----------------------------------------------------------------------------
### Structure of Workshop:
### * Demo 1: Monthly time series forecast (30 minutes)
### * Exercise 0: Different imput measure (20 mintues)
###   or Exercise 1: Different input data (20 mintues)
### * Demo 2: Identify trend change? (2 minutes)
### * Demo 3: Forecast Central Estimate C.I and P.I (not shown today)
### ----------------------------------------------------------------------------
### As with most applications in R most of the hard work is done for us but   
### there are significant hurdles to get over before we can use the available
### functionality. Here I don't want to focus on the forecasting methodology 
### in terms of which method to use and how to ensure the forecast is robust 
### but rather on how R helps to achieve these goals.
###
### Main learning outcome should be awareness of:
### * forecast package
### * time data formats in R
### * particularly useful functions - stl(), ggtsdisplay(), accuracy()
################################################################################
start_time <- Sys.time() 
dev.off()
path <- "P:/R/Home/CodeVault/DHCdgAcdy_Forecasting131219"
file <- "RForecastNHSItest.csv"

######################### libaries #############################################
list.of.packages <- c("tseries","forecast","dplyr","ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

suppressPackageStartupMessages(library("tseries")) 
suppressPackageStartupMessages(library("forecast"))
suppressPackageStartupMessages(library("dplyr")) 
suppressPackageStartupMessages(library("ggplot2")) 

######################### Read in Data ##########################################
master <- read.csv(file = paste(path, file, sep = "/"),header = T)
head(master)
summary(master)
## master contains:
## * Monthly data from August 2010 to July 2019.
## * Type 1 Departments - Major A&E	
## * Type 2 Departments - Single Specialty	
## * Type 3 Departments - Other A&E/Minor Injury Unit	
## * Total Attendances	
## * Emergency Admissions via Type 1 A&E	
## * Emergency Admissions via Type 2 A&E	
## * Emergency Admissions via Type 3 and 4 A&E	
## * Total Emergency Admissions via A&E	
## * Other Emergency Admissions (i.e not via A&E)	
## * Total Emergency Admissions	
## * Number of patients spending >4 hours from decision to admit to admission	
## * Number of patients spending >12 hours from decision to admit to admission



###########################################################################
##########################  DEMO 1 ########################################
###########################################################################
## For Demo 1 we will only look at one variable - Total Attendances.  
## Notice that the data has been brought in with comma delimiters so these need to be 
## removed and the values saved as a  numeric vector.
master_activity <- as.numeric(gsub(",", "",(levels(master$Total.Attendances)[master$Total.Attendances])))

######################### Create Time Data ##########################################
## It's very useful to tell R which data are time data as this helps with plotting 

########## Side Point - Time/Date formats in R ##########
## See https://statistics.berkeley.edu/computing/r-dates-times
## or https://www.gormanalysis.com/blog/dates-and-times-in-r-without-losing-your-sanity/

## The general rule for date/time data in R is to use the simplest technique possible.

## 1. The builtin as.Date() function handles dates (without times) and uses the standard
##    strptime() formatting to convert almost any date format into R standard (yyyy-mm-dd)
## 2. There's a package called chron but doesn't seem to offer much additional
## 3. Sometimes monthly data can be tricky (especially 3-digit month names) and you may find
##    the yearmon() function in the zoo library useful here.
## 4. The POSIXct and POSIXlt classes handle dates, times and time zones.  However, I find 
##    that POSIXlt is cubersome as it's made to store the data as a list but just takes memory
##    and doesn't add much for me.
## 5. The lubridate library allows additional functionality especially good when trying to 
##    identify something like weekdays or amount of time between two dates.

## Note: in all cases R stores date as a numeric set to number of days since January 1st, 1970
######################## Side Point End ################

## When working with a timeseries we can specify a time series object in R.  This will then 
## allow us to interact and plot the data with R already knowing this is a time series.  
## R understands a time series object as a vector/matrix of equispaceds points in time.
## For this we use ts() assigning a start point and frequency.

startpoint <- c(2010,8)
## Start point is a vector of two numbers which represent the major and 
## minor time axis "ticks".  If the data is monthly and starts at June-11
## then this would be c(2011,6).  Alternatively if the data is hourly and 
## starts at 08:00 on 25th June 2012 then we would need 
## c(2012,24(as.Date("2012-6-25 08:00:00")-as.Date("2012-1-1 00:00:00"))) 

freq <- 12 ## inherent frequency in the data
fmons <- 12*3 ## number of time points to forecast by
trainTestSplit <- 12*3 ## Timepoints to hold for test data

timemaster <- ts(master_activity,start=startpoint, frequency=freq)
## This has created a 1D timeseries vector which stores information about both time point
## and value


######################### Explore and Investigate ######################################
## Let's have a quick look at this data
plot(timemaster,main="Basic plot of time series data", ylab="Activity")

## QUESTION: WHAT FEATURES DO YOU THINK ARE IN THE DATA?

## The skill of forecasting is not in the technique but in the data manipulation.  How to 
## identify and extract features in the time-series so that a statistical model can be 
## fitted to the data is the key question.  Once we have a "clean" timeseries then 
## forecasting forwards becomes simple.

## To help, let's pop some moving averages on the data to get an indicaiton of the variaiton.
par(mfrow = c(2,2))
plot(timemaster, col="gray", main = "Half Year Moving Average Smoothing")
lines(ma(timemaster, order = 3), col = "red", lwd=3)
plot(timemaster, col="gray", main = "1 Year Moving Average Smoothing")
lines(ma(timemaster, order = 6), col = "blue", lwd=3)
plot(timemaster, col="gray", main = "2 Year Moving Average Smoothing")
lines(ma(timemaster, order = 12), col = "green", lwd=3)
plot(timemaster, col="gray", main = "3 Year Moving Average Smoothing")
lines(ma(timemaster, order = 24), col = "yellow4", lwd=3)

## Decompose into trend, seasonality and remainders then plot the ts object
plot(decompose(timemaster))

## Alternative decomposition command [TIP ONE: Use this!]
deco <- stl(log(timemaster), s.window="periodic", robust=TRUE)
autoplot(deco) ## We use autoplot as this understands that there are multiple plots in deco
## Note the grey bars on the right indicate the relative range.  The larger the components are
## comapred to the data, the smaller the signal.


######################### de-seasonalise/differencing ###################################
## These data appear to have seasonality.  We can extract this to create a useable time series
timemaster_seasadj <- timemaster %>% stl(s.window='periodic') %>% seasadj() ## from Forecast package
timemaster_seadiff <- diff(timemaster_seasadj) ## diff2() for second derivative
timemaster_seadiff <- ts(c(ts(timemaster_seadiff[1],start=startpoint,frequency=freq),
                           timemaster_seadiff),start=startpoint,frequency=freq) ##bodge
  
autoplot(ts(data.frame(timemaster,timemaster_seasadj,timemaster_seadiff+mean(timemaster_seasadj)),start = startpoint, frequency=freq),
         main= " Raw versus Seasonal Adjusted Monthly A&E Attendance",ylab="Count") + 
  theme(legend.position="bottom")

## Once we have extracted seasonality, it's important to have a look at the residuals to see 
## if further seasonality or autocorrelation is present within the data
par(mfrow = c(1,2))
Acf(timemaster_seadiff, main ="ACF for Remainder")
Pacf(timemaster_seadiff, main ="PACF for Remainder")
## ACF: Autocorrelation Funciton - linear dependence between two observations with lag h
## PACF: Patial Autoccorrelation Function - dependence after linear stripped out 

## forecast library has a useful combined command which is easier to see
ggtsdisplay(timemaster_seadiff, main="Seasonal Adjusted Data with ACF and PACF plots")

## Check the constant mean and variance by plotting boxplot for the remainder
deco2 <- stl(log(timemaster_seadiff+mean(timemaster_seasadj)), s.window="periodic", robust=TRUE)
timemaster_rem <- deco2$time.series[,3]
par(mfrow = c(1,1))
boxplot(timemaster_rem ~ cycle(timemaster), xlab = "Month",
        ylab = "Activity", main = "Boxplot of Remainder")
## Possibly data has higher vairance further back in time so may need some further cleaning
## but no obvious patterns which will obscure the forcasts.

## Check histogram of remainders to see if residuals have normal distribution
hist(timemaster_rem, density=20, breaks=20, prob=TRUE, xlab="Residuals", ylim=c(0,30), 
     main = "normal curve over histogram")
curve(dnorm(x,mean = mean(timemaster_rem), sd = sqrt(var(timemaster_rem))),
      col = "darkblue", lwd=2 ,add=TRUE ,yaxt="n")
## residuals are fairly normal so no skew remaining

## apply a Ljung-Box Test, Unit Root Test (KPSS test) & Augmented Dickey-Fuller Test (ADF)
Box.test(timemaster_rem, lag = 20, type="Ljung") ## Are remainders white noise
## Looking for rejection : p < 0.05
kpss.test(timemaster_rem) ## Is time series stationary
## Looking to accept : p > 0.05
adf.test(timemaster_rem) ## similar to KPSS. Is there a unit root?
## Looking for rejection : p < 0.05

## Conclusion, we have a timeseries we can now model as we are aware of the key features.

########## Split data into train/test and score a variety of models ######################
ts_train <- head(timemaster,length(timemaster)-trainTestSplit)
ts_test <- tail(timemaster,trainTestSplit)
ts_train_sea <- head(timemaster_seadiff,length(timemaster)-trainTestSplit)
ts_test_sea <- tail(timemaster_seadiff,trainTestSplit)

#Prepare first set of forecasts using Simple Average
fit.sa <- meanf(ts_train_sea, h = fmons)
frcst.sa <- forecast(fit.sa, h = fmons, level = c(80,95))
frcst.sa$x <- frcst.sa$x*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
frcst.sa$mean <- frcst.sa$mean*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
frcst.sa$upper[,1] <- frcst.sa$upper[,1]*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
frcst.sa$lower[,1] <- frcst.sa$lower[,1]*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
accsa<-accuracy(frcst.sa,ts_test)
##  MAPE is a measure of prediction accuracy of a forecasting method
fitlist<-data.frame("Simple Average",accsa[2,5])
colnames(fitlist)<-c("ModelsFitted","MAPEFit")

updateMAPE <- function(mod,acc){
  addfitlist<-data.frame(mod,acc)
  colnames(addfitlist)<-c("ModelsFitted","MAPEFit")
  fitlist<-rbind(fitlist,addfitlist)
}

# Forecasts using Naive (last term = next term)
fit.na <- naive(ts_train_sea, h = fmons)
frcst.na <- forecast(fit.na, h = fmons, level = c(80,95))
frcst.na$x <- frcst.na$x*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
frcst.na$mean <- frcst.na$mean*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
frcst.na$upper[,1] <- frcst.na$upper[,1]*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
frcst.na$lower[,1] <- frcst.na$lower[,1]*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
accna<-accuracy(frcst.na,ts_test)
fitlist <- updateMAPE("Naive",accna[2,5])

# Forecasts using Seasonal Naive (as above but with seasonality)
fit.sna <- snaive(ts_train, h = fmons)
frcst.sna <- forecast(fit.sna, h = fmons, level = c(80,95))
accsna<-accuracy(frcst.sna,ts_test)
fitlist <- updateMAPE("Seasonal Naive",accsna[2,5])

# Forecasts using Linear Regression (average of known = next term)
fit.lm <- tslm(ts_train_sea ~ trend+season)
frcst.lm <- forecast(fit.lm, h = fmons, level = c(80,95))
frcst.lm$x <- frcst.lm$x*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
frcst.lm$mean <- frcst.lm$mean*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
frcst.lm$upper[,1] <- frcst.lm$upper[,1]*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
frcst.lm$lower[,1] <- frcst.lm$lower[,1]*(timemaster/(timemaster_seadiff+mean(timemaster_seasadj)))
accLinReg<-accuracy(frcst.lm,ts_test)
fitlist <- updateMAPE("Linear Regression",accLinReg[2,5])

#Forecasts using auto ARIMA
ARIMAmod<-auto.arima(ts_train)
ARIMAforecasts<-forecast(ARIMAmod,h=fmons)
accARIMA<-accuracy(ARIMAforecasts,ts_test)
fitlist <- updateMAPE("ARIMA",accARIMA[2,5])

#Prepare next forecast outputs using Holt-Winters (aka Triple Exponential Smoothing)
HWmodel <-HoltWinters(ts_train)
HWforecasts<-forecast(HWmodel, h=fmons)
accHW<-accuracy(HWforecasts,ts_test)
fitlist <- updateMAPE("Holt-Winters",accHW[2,5])

#Prepare next forecast outputs using Exponential smoothing state space model
ETSmodel<-ets(ts_train)
ETSforecasts<-forecast(ETSmodel, h=fmons)
accETS<-accuracy(ETSforecasts,ts_test)
fitlist <- updateMAPE("ErrorTrendSeasonality",accETS[2,5])

#Prepare next forecast outputs using Bats 
BATSmodel<-bats(ts_train)
BATSforecasts<-forecast(BATSmodel, h=fmons)
accBATS<-accuracy(BATSforecasts,ts_test)
fitlist <- updateMAPE("BATS",accBATS[2,5])

#Naive and Random Walk Forecasts
RWFforecasts<-rwf(ts_train, h=fmons)  
accRWF<-accuracy(RWFforecasts,ts_test)
fitlist <- updateMAPE("Random Walk",accRWF[2,5])

## Order by MAPE
fitout<-fitlist[order(fitlist[["MAPEFit"]]),]
fitout[1,]

par(mfrow = c(3,3))
plot(frcst.sa,main="Forecasts using an Simple Average", ylab="Activity")
points(frcst.sa$fitted, type='l',col='red')
points(timemaster, type='l',col='black')
plot(frcst.na,main="Forecasts using an Naive", ylab="Activity")
points(frcst.na$fitted, type='l',col='red')
points(timemaster, type='l',col='black')
plot(frcst.sna,main="Forecasts using an Seasonal Naive", ylab="Activity")
points(frcst.sna$fitted, type='l',col='red')
points(timemaster, type='l',col='black')
plot(frcst.lm,main="Forecasts using an LinReg model", ylab="Activity")
points(frcst.lm$fitted, type='l',col='red')
points(timemaster, type='l',col='black')
plot(ARIMAforecasts,main="Forecasts using an ARIMA model", ylab="Activity")
points(ARIMAforecasts$fitted, type='l',col='red')
points(timemaster, type='l',col='black')
plot(HWforecasts,main="Forecasts using an Holtz-Winters model", ylab="Activity")
points(HWforecasts$fitted, type='l',col='red')
points(timemaster, type='l',col='black')
plot(ETSforecasts,main="Forecasts using an Exponetial Smoothing model", ylab="Activity")
points(ETSforecasts$fitted, type='l',col='red')
points(timemaster, type='l',col='black')
plot(BATSforecasts,main="Forecasts using an Naive Bayes model", ylab="Activity")
points(BATSforecasts$fitted, type='l',col='red')
points(timemaster, type='l',col='black')
plot(RWFforecasts,main="Forecasts using an Random Walk model", ylab="Activity")
points(RWFforecasts$fitted, type='l',col='red')
points(timemaster, type='l',col='black')

#Write out the details of the model with the best MAPE 
cat("\n", "Best Model is", as.character(fitout[1,1]),"\n")

########## Use best fit model and create final outputs ######################

finalModel<-HoltWinters(timemaster)
finalforecasts<-forecast(finalModel,h=fmons)
accfinal<-accuracy(finalforecasts)
accfinal[,]

dev.off()
plot(finalforecasts,main="Forecasts using Best model", ylab="Activity")
points(finalforecasts$fitted, type='l',col='red')
## The forecast package creates a timeseries output that when plotted will 
## automatically display the prediction intervals specified e.g.(80,95) 

autoplot(stl(log(timemaster), s.window="periodic", robust=TRUE))
autoplot(stl(log(finalforecasts$mean), s.window="periodic", robust=TRUE))
summary(finalforecasts)




###########################################################################
########################  Exercise 0 ######################################
###########################################################################
## Exercise 0 is to re-create the above using a different variable from 
## master data.  Perhaps Total.Emergency.Admissions.via.A.E

## Step 1: Extract the Activity Data into a vector
master_activity_Ex0 <- as.numeric(gsub(",", "",(levels(master$INSERT CODE)[master$INSERT CODE])))

## Step 2: Define the vector as a time series
timemaster_Ex0 <- INSERT CODE

## Steo 3: Decompose into trend, seasonal and error terms
deco_Ex0 <- stl(INSERT CODE)
autoplot(deco_Ex0)
ggtsdisplay(INSERT CODE)

## Step 4: De-seasonalise? Difference?
INSERT CODE
ggtsdisplay(INSERT CODE, main="Seasonal Adjusted Data with ACF and PACF plots")

## Step 5: Test timeseries if required (Box plot to check constant mean and variance
## and Histogram to check if residuals have normal distribution)
boxplot(INSERT CODE, xlab = "Month",
        ylab = "Activity", main = "Boxplot of Remainder")
hist(INSERT CODE, 
     main = "normal curve over histogram")
curve(dnorm(x,mean = mean(INSERT CODE), sd = sqrt(var(INSERT CODE))),
      col = "darkblue", lwd=2 ,add=TRUE ,yaxt="n")

## Step 6: Split data into train and test
ts_train_Ex0 <- INSERT CODE
ts_test_Ex0 <- INSERT CODE

## STep 7: Forecast (pick a model)
INSERT CODE
INSERT CODE
INSERT CODE
cat("\n", "Model Accuracy is ",INSERT CODE, "\n")

## Step 8: Plot the forecast
plot(INSERT CODE,main="Forecasts using an ARIMA model", ylab="Activity")
points(INSERT CODE, type='l',col='red')
points(timemaster_Ex0, type='l',col='black')

## Is this a good robust forecast?  Would you trust it and if so/not why so/not?





###########################################################################
########################  Exercise 1 ######################################
###########################################################################
## Does more granular data give a better forecast?

path_Ex1 <- "P:/R/Home/CodeVault/DHCdgAcdy_Forecasting131219"
file_Ex1 <- "UFO-Sightings-2015-Update.csv"
master_Ex1 <- read.csv(file = paste(path_Ex1, file_Ex1, sep = "/"),header = T)

head(master_Ex1)
summary(master_Ex1)
## master contains:
## * Date & Time (Excel number format)
## * City 
## * State
## * Position 
## * Shape
## * Duration
## * Summary
## * DayOfYear
## * DayOfWeek
## * WeekNum

## Step 1: Extract the Activity Data
## I've picked out week and day but if your confident you can extract hour & minute 
## from the Date & Time field
df_weekly <- master_Ex1 %>% group_by(WeekNum) %>% tally()
df_daily <- master_Ex1 %>% group_by(DayOfYear) %>% tally()

par(mfrow = c(1,2))
plot(df_weekly,type = "l")
plot(df_daily,type = "l")

## Let's imagine that the weekly data is routinely collected and accesable.  However,
## we want to know if pushing for daily data would give added value to a forecast.

## replace erronous data with moving average imputation
head(df_daily %>% arrange(desc(n)),10)
df_daily$n[310] <- (sum(df_daily$n[301:310])+sum(df_daily$n[312:321]))/20
df_daily$n[184] <- (sum(df_daily$n[175:184])+sum(df_daily$n[186:195]))/20
df_daily$n[1] <- df_daily$n[2]

head(df_weekly %>% arrange(desc(n)),10)
df_weekly$n[45] <- (sum(df_weekly$n[43:44])+sum(df_weekly$n[46:47]))/4
df_weekly$n[27] <- (sum(df_weekly$n[25:26])+sum(df_weekly$n[28:29]))/4


## Step 2: Define the time series (consider the frequency you'll use)
timemaster_Ex1_daily <- INSERT CODE
timemaster_Ex1_weekly <- INSERT CODE

## Steo 3: Decompose into trend, seasonal and error terms
deco_Ex1_D <- INSERT CODE
autoplot(deco_Ex1_D)
ggtsdisplay(timemaster_Ex1_daily, main="Raw Data with ACF and PACF plots")
deco_Ex1_W <- INSERT CODE
autoplot(deco_Ex1_W)
ggtsdisplay(timemaster_Ex1_weekly, main="Raw Data with ACF and PACF plots")

## Steo 4: Seasonality / Differencing?
INSERT CODE

## Step 5: Test timeseries if required (Box plot to check constant mean and variance
## and Histogram to check if residuals have normal distribution)
boxplot(INSERT CODE)
hist(INSERT CODE)
curve(dnorm(x,mean = mean(deco_Ex1_D$time.series[,3]), sd = sqrt(var(deco_Ex1_D$time.series[,3]))),
      col = "darkblue", lwd=2 ,add=TRUE ,yaxt="n")

boxplot(INSERT CODE)
hist(INSERT CODE)
curve(dnorm(x,mean = mean(deco_Ex1_W$time.series[,3]), sd = sqrt(var(deco_Ex1_W$time.series[,3]))),
      col = "darkblue", lwd=2 ,add=TRUE ,yaxt="n")

## Step 6: Split data into test/train
INSERT CODE

## Step 7: Forecast (which model)
INSERT CODE
cat("\n", "Daily Model Accuracy is ",INSERT CODE, "\n")

INSERT CODE
cat("\n", "Weekly Model Accuracy is ",INSERT CODE, "\n")

## Step 8: Plot the forecast
plot(INSERT CODE,main="Daily", ylab="Activity")
points(INSERT CODE, type='l',col='red')
points(ts_d, type='l',col='black')

plot(INSERT CODE,main="Weekly", ylab="Activity")
points(INSERT CODE, type='l',col='red')
points(ts_w, type='l',col='black')

## Would you opt for Daily or Weekly data here?


###########################################################################
########################## Demo 2  ########################################
###########################################################################
## Is there a difference between the most recent period and previous data?

fitlist_ii<-data.frame("Final Model",accfinal[,5])
colnames(fitlist_ii)<-c("ModelsFitted","MAPEFit")
updateMAPE_ii <- function(mod,acc){
  addfitlist_ii<-data.frame(mod,acc)
  colnames(addfitlist_ii)<-c("ModelsFitted","MAPEFit")
  fitlist_ii<-rbind(fitlist_ii,addfitlist_ii)
}

for (ii_TTSplit in (2*freq):length(timemaster_Ex0)-freq){
  ii_fmons <- length(timemaster_Ex0) - ii_TTSplit
  ts_train_ii <- head(timemaster_Ex0,ii_TTSplit)
  ts_test_ii <- tail(timemaster_Ex0,ii_fmons)
  model_ii <-auto.arima(ts_train_ii)
  forecasts_ii<-forecast(model_ii, h=ii_fmons)
  accHW_ii<-accuracy(forecasts_ii,ts_test_ii)
  fitlist_ii <- updateMAPE_ii(print(as.character(ii_TTSplit)),accHW_ii[2,5])
}

plot(fitlist_ii[,2],main="Looking for changes in TimeSeries", ylab="MAPE")
points((as.numeric(timemaster_Ex0)/max(as.numeric(timemaster_Ex0)))*7, type='l',col='red')

## Looking at raw data we find that March 2017 would give the worst forecast 
## This possibly indicates a change in trend.
plot(window(timemaster_Ex0, start = c(2016,3), end = c(2018,3)), type='l',col='black')
## Could be a combination of dip and trend change




###########################################################################
############################  DEMO 3 ######################################
###########################################################################
## How to calculate the CI and PI of trend 

## Occasionally, especially for for range forecasts, we are less interested in 
## the confidence intervals of the where individual data points line and more
## interested in the confidence and prediction of the trend. 

## Therefore, we are sometimes asked to display how confident we are that the 
## mean is fitted correctly and where this may lie in the future

## I haven't found an embedded function for doing this and so the code below 
## demonstrates how one might do this.

## Define ranges
numDataActualPoints <- length(timemaster)
fittedRange <- length(finalforecasts$fitted)-length(finalforecasts$fitted[is.na(finalforecasts$fitted)==TRUE])
fittedStart <- 1+length(finalforecasts$fitted[is.na(finalforecasts$fitted)==TRUE])

## Create a data frame with index | date | actual values | fitted values | CI & PIs
df <- data.frame("periodNum" = c(1:(fittedRange+fmons)),
                 "period"= seq(from = as.Date(master$Period[fittedStart],format = '%d/%m/%Y'),by='month',length.out=fittedRange+fmons),
                 "actual" = c(master_activity[fittedStart:numDataActualPoints],rep(NA,fmons)),
                 "fitted" = c(finalforecasts$fitted[fittedStart:numDataActualPoints],finalforecasts$mean))
df$ci.upper <- NA
df$ci.lower <- NA
df$pi.upper995 <- NA
df$pi.lower995 <- NA
df$pi.upper975 <- NA
df$pi.lower975 <- NA
df$pi.upper95 <- NA
df$pi.lower95 <- NA
df$pi.upper9 <- NA
df$pi.lower9 <- NA

## soft coded user variables 
numDataToFit <- dim(df)[1] - fmons
startFit <- 0
critT <- c(0.995,0.975,0.95,0.9)

# Find the Sum of Squared Errors and the Mean Squared Error
sse <- sum((df$actual[(startFit+1):fittedRange] - df$fitted[(startFit+1):fittedRange])^2)
mse <- sse / (numDataToFit - 2)

# Calculate critical t-value  
t.val995 <- qt(critT[1], numDataToFit - 2)
t.val975 <- qt(critT[2], numDataToFit - 2) 
t.val95 <- qt(critT[3], numDataToFit - 2) 
t.val9 <- qt(critT[4], numDataToFit - 2) 

# Calculate the Sum of Squared Deviations (SSx) and the standard error of the estimate(Syx)
SSx <- sum((df$periodNum[(startFit+1):fittedRange] - mean(df$periodNum[(startFit+1):fittedRange]))^2)
Syx <- sqrt(sum((df$actual[(startFit+1):fittedRange] - df$fitted[(startFit+1):fittedRange])^2) / (numDataToFit - 2))

# Find the standard error of the regression line
c_se <- Syx * sqrt(1/numDataToFit + 
                     (df$periodNum[(startFit+1):fittedRange] - mean(df$periodNum[(startFit+1):fittedRange]))^2 / SSx)

# Find the standard error of the predicted regression line
p_se <- Syx * sqrt(1/numDataToFit + 
                     (df$periodNum[(fittedRange):length(df$period)] - mean(df$periodNum[(startFit+1):fittedRange]))^2 / SSx)

#F_se <- Syx * sqrt(1+1/numDataToFit + 
#                     (df$periodNum[(fittedRange):length(df$period)] - mean(df$periodNum[(startFit+1):fittedRange]))^2 / SSx)

# Confidence Intervals
df$ci.upper[(startFit+1):fittedRange] <- df$fitted[(startFit+1):fittedRange] + t.val9 * c_se
df$ci.lower[(startFit+1):fittedRange] <- df$fitted[(startFit+1):fittedRange] - t.val9 * c_se

# Prediction Intervals 
df$pi.upper995[fittedRange:length(df$period)] <- df$fitted[fittedRange:length(df$period)] + t.val995 * p_se
df$pi.lower995[fittedRange:length(df$period)] <- df$fitted[fittedRange:length(df$period)] - t.val995 * p_se
df$pi.upper975[fittedRange:length(df$period)] <- df$fitted[fittedRange:length(df$period)] + t.val975 * p_se
df$pi.lower975[fittedRange:length(df$period)] <- df$fitted[fittedRange:length(df$period)] - t.val975 * p_se
df$pi.upper95[fittedRange:length(df$period)] <- df$fitted[fittedRange:length(df$period)] + t.val95 * p_se
df$pi.lower95[fittedRange:length(df$period)] <- df$fitted[fittedRange:length(df$period)] - t.val95* p_se
df$pi.upper9[fittedRange:length(df$period)] <- df$fitted[fittedRange:length(df$period)] + t.val9 * p_se
df$pi.lower9[fittedRange:length(df$period)] <- df$fitted[fittedRange:length(df$period)] - t.val9 * p_se

# Plot the fitted linear regression line and the computed confidence bands

ggplot(df, aes(x=period)) + 
  geom_ribbon(aes(ymin = ci.lower, ymax = ci.upper), fill = "grey50") +
  geom_ribbon(aes(ymin = pi.lower995, ymax = pi.upper995), fill = "grey80") +
  geom_ribbon(aes(ymin = pi.lower975, ymax = pi.upper975), fill = "grey70") +
  geom_ribbon(aes(ymin = pi.lower95, ymax = pi.upper95), fill = "grey60") +
  geom_ribbon(aes(ymin = pi.lower9, ymax = pi.upper9), fill = "grey50") +
  geom_point(aes(y=actual), color='#2980B9', size = 2) + 
  geom_line(aes(y=fitted), color='#2C3E50', size = 1) +
  scale_y_continuous(limits = c(0,max(c(df$ci.upper995,df$pi.upper995),na.rm = T)))


cat("\n", "Done, Run time:", format(Sys.time() - start_time, digits = 4), "\n") 
