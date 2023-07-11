library(shiny)
library(shinyjs)
library(DT)
library(vcd)
library(GGally)
library(MASS)
library(RColorBrewer)
library(datasets)
library(corrgram)
library(visdat)
library(forecast)
library(tidytext)
library(tidyverse)
library(janeaustenr)
library(stringr)
library(wordcloud2)
library(reshape2)
library(pls)
library(ggplot2)
library(devtools)
library(car)
library(shinycssloaders)
library(lubridate)
library(summarytools)
library(rlang)
library(rpart)
library(rpart.plot)
library(caret)
library(naniar)
library(recipes)
library(visdat)
library(rpart)
library(glmnet)
library(Matrix)
library(dplyr)

dat <- read.csv("data2.csv", header = TRUE, stringsAsFactors = TRUE, na.strings = c("NA","N/A"))

#replace numeric missing values -99 with NA
dat[dat == -99] <- NA
#replace categorical missing values -- with NA
dat[dat == "--"] <- NA

#Creating new level for POLITICS
dat$POLITICS <- as.character(dat$POLITICS) #convert away from factor
dat$POLITICS[is.na( dat$POLITICS )] <- "NONE"
dat$POLITICS <- as.factor(dat$POLITICS) # convert back to factor

#assign 0 to free health care
dat$HEALTHCARE_COST[is.na(dat$HEALTHCARE_COST)] <- 0


#Create shadow variables
dat$POPULATION_SHADOW <- as.numeric(is.na(dat$POPULATION)) 
dat$AGE25_PROPTN_SHADOW <- as.numeric(is.na(dat$AGE25_PROPTN))
dat$AGE_MEDIAN_SHADOW <- as.numeric(is.na(dat$AGE_MEDIAN))
dat$AGE50_PROPTN_SHADOW <- as.numeric(is.na(dat$AGE50_PROPTN))
dat$POP_DENSITY_SHADOW <- as.numeric(is.na(dat$POP_DENSITY))
dat$GDP_SHADOW <- as.numeric(is.na(dat$GDP))
dat$INFANT_MORT_SHADOW <- as.numeric(is.na(dat$INFANT_MORT))
dat$DOCS_SHADOW <- as.numeric(is.na(dat$DOCS))
dat$VAX_RATE_SHADOW <- as.numeric(is.na(dat$VAX_RATE))
dat$HEALTHCARE_COST_SHADOW <- as.numeric(is.na(dat$HEALTHCARE_COST))

#create train-test split
train <- dat[dat$OBS_TYPE == "Train",]
test <- dat[dat$OBS_TYPE == "Test",]

#numeric variables
choicesA <- colnames(dat[,c(3:11,13)])

choicesB <- colnames(dat[,c(3,7,12,13)])

#categorical variables
choicesC <- colnames(dat[,c(2,12)])








