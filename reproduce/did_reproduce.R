rm(list=ls())
library(dplyr)
library(ggplot2)
library(haven)

setwd("~/Library/CloudStorage/OneDrive-KULeuven/Thesis/data analysis")
getwd()

load("/Users/angelxu/Library/CloudStorage/OneDrive-KULeuven/Thesis/data analysis/filtered_data.RData")
load("C:/Users/AnqiXu/OneDrive - KU Leuven/Thesis/data analysis/filtered_data.RData")
#-------------------
#--- DID ----
#-------------------

#cohabit
cohabit_data <- filtered_data %>%
  filter(SPLOC!=0)

cohabit_data <- cohabit_data %>%
  mutate(same_sex = case_when(
    SEX == 1 & SEX_partner == 1 ~ 1,
    SEX == 2 & SEX_partner == 2 ~ 1,
    SEX == 1 & SEX_partner == 2 ~ 0,
    SEX == 2 & SEX_partner == 1 ~ 0
  ))

cohabit_data$UHRSWORK <- as.integer(cohabit_data$UHRSWORK)

cohabit_data$legalized <- as.numeric(cohabit_data$legalized)

#preparation of data
cohabit_data$RACE <- factor(cohabit_data$RACE)
cohabit_data$METRO <- factor(cohabit_data$METRO)
cohabit_data$MARST <- factor(cohabit_data$MARST)
cohabit_data$SEX <- factor(cohabit_data$SEX)
cohabit_data$STATEICP <- factor(cohabit_data$STATEICP)
cohabit_data$lnINCWAGE <- log(cohabit_data$INCWAGE + 1)

cohabit_data$interaction <- cohabit_data$same_sex*cohabit_data$legalized

#not sure
cohabit_data$YEAR <- factor(cohabit_data$YEAR)

#male dataset
cohabit_data_male <- cohabit_data %>%
  filter(SEX==1)
#female dataset
cohabit_data_female <- cohabit_data %>%
  filter(SEX==2)


#male 2003-2015
cohabit_data_male$YEAR <- as.integer(cohabit_data_male$YEAR)
cohabit_data_male$YEAR = cohabit_data_male$YEAR + 1999
cohabit_data_male_reproduce <- cohabit_data_male %>%
  filter(YEAR>=2003 & YEAR <=2015)
cohabit_data_male_reproduce <- cohabit_data_male_reproduce %>%
  filter(UHRSWORK!=0)
table(cohabit_data_male_reproduce$UHRSWORK)
cohabit_data_male$YEAR <- as.factor(cohabit_data_male$YEAR)


did <- lm(UHRSWORK ~ same_sex+legalized+interaction
          +AGE+RACE+METRO+MARST+EDUC+YEAR+STATEICP+NCHILD, 
          data = cohabit_data_male_reproduce)
summary(did)

#female 2003-2015
cohabit_data_female$YEAR <- as.integer(cohabit_data_female$YEAR)
cohabit_data_female_reproduce <- cohabit_data_female %>%
  filter(YEAR>=2003 & YEAR <=2015)
cohabit_data_female$YEAR <- as.factor(cohabit_data_female$YEAR)

rm(did)
did <- lm(UHRSWORK ~ same_sex+legalized+interaction
          +AGE+RACE+METRO+MARST+EDUC+YEAR+STATEICP+NCHILD, 
          data = cohabit_data_female_reproduce)
summary(did)