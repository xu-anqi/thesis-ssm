rm(list=ls())
library(dplyr)
library(ggplot2)
library(haven)

setwd("C:/Users/AnqiXu/OneDrive - KU Leuven/Thesis/data analysis")

#setwd("~/Library/CloudStorage/OneDrive-KULeuven/Thesis/data analysis")
getwd()


#load full data here
#load("/Users/angelxu/Library/CloudStorage/OneDrive-KULeuven/Thesis/data analysis/filtered_data.RData")
#load("C:/Users/AnqiXu/OneDrive - KU Leuven/Thesis/data analysis/filtered_data.RData")

#load sample for testing
#load("/Users/angelxu/Library/CloudStorage/OneDrive-KULeuven/Thesis/data analysis/sample.RData")
load("C:/Users/AnqiXu/OneDrive - KU Leuven/Thesis/data analysis/sample.RData")

#----------------------
#---descriptive data---
#----------------------



#glimpse(filtered_data)
#summary(filtered_data$UHRSWORK)


#cohabit, filter only cohabiting couples.
cohabit_data <- filtered_data %>%
  filter(SPLOC!=0)

#same_sex = 1 indicates same_sex cohabiting, 0 indicating different-sex cohabiting
cohabit_data <- cohabit_data %>%
  mutate(same_sex = case_when(
    SEX == 1 & SEX_partner == 1 ~ 1,
    SEX == 2 & SEX_partner == 2 ~ 1,
    SEX == 1 & SEX_partner == 2 ~ 0,
    SEX == 2 & SEX_partner == 1 ~ 0
  ))

#calculate weeks of work and annual hours of work
cohabit_data <- cohabit_data %>%
  mutate(WKSWORKMID = case_when(
    WKSWORK2 == 0 ~ 0,
    WKSWORK2 == 1 ~ 7,
    WKSWORK2 == 2 ~ 27,
    WKSWORK2 == 3 ~ 33,
    WKSWORK2 == 4 ~ 43.5,
    WKSWORK2 == 5 ~ 48.5,
    WKSWORK2 == 6 ~ 51,
    TRUE ~ NA_real_  
  ))


cohabit_data <- cohabit_data %>%
  mutate(annualHRSWORK = WKSWORKMID * UHRSWORK)

#some descriptive results
mean_summary <- cohabit_data %>%
  group_by(same_sex, SEX) %>%
  summarize(
    mean_annualHRSWORK = mean(annualHRSWORK, na.rm = TRUE),
    mean_UHRSWORK = mean(UHRSWORK, na.rm = TRUE),
    mean_NCHILD = mean(NCHILD, na.rm = TRUE),
    mean_AGE = mean(AGE, na.rm = TRUE),
    mean_INCWAGE = mean(INCWAGE, na.rm = TRUE),
    mean_wagerate = mean(INCWAGE/UHRSWORK, na.rm = TRUE)
  ) %>%
  arrange(desc(SEX))

mean_summary

#control variables
#race
table(cohabit_data$RACE)

cohabit_data <- cohabit_data %>%
  mutate(RACE_RECODED = case_when(
    RACE == 1 ~ 1,  # White
    RACE == 2 ~ 2,  # Black/African American
    RACE %in% c(4, 5, 6) ~ 3,  # Asian: Chinese, Japanese, Other Asian or Pacific Islander
    RACE %in% c(3, 7, 8, 9) ~ 4,  # Others: American Indian, Other race, Two/Three major races
    TRUE ~ NA_real_  # Handle missing or unknown values
  ))

#Age and age square
cohabit_data <- cohabit_data %>%
  mutate(AGE_square = AGE^2)

#number of children in the household: NCHILD
#the presence of a child under the age of five
cohabit_data <- cohabit_data %>%
  mutate(has_children_under5 = ifelse(NCHLT5 > 0, 1, 0))

#Hispanic
table(cohabit_data$HISPAN)
cohabit_data <- cohabit_data %>%
  mutate(HISPAN_RECODED = case_when(
    HISPAN == 0 ~ 0,  # Not Hispanic
    HISPAN %in% c(1, 2, 3, 4) ~ 1,  # Hispanic (Mexican, Puerto Rican, Cuban, Other)
    HISPAN == 9 ~ NA_real_  # Not Reported (optional, can also use 0 if preferred)
  ))

#home ownership OWNERSHP


#urban residence METRO
table(cohabit_data$METRO)
cohabit_data <- cohabit_data %>%
  mutate(METRO_RECODED = case_when(
    METRO == 1 ~ 0, #rural
    METRO %in% c(2,3,4) ~ 1, #urban
    METRO == 0 ~ 2 #mixed
  ))
table(cohabit_data$METRO_RECODED)

#educational attainment
table(cohabit_data$EDUC)
cohabit_data <- cohabit_data %>%
  mutate(EDUC_RECODED = case_when(
    EDUC %in% c(0, 1, 2, 3, 4, 5) ~ 0,  # Less than high school
    EDUC == 6 ~ 1,  # High school diploma
    EDUC %in% c(7, 8, 9) ~ 2,  # Some college
    EDUC == 10 ~ 3,  # Bachelor's degree
    EDUC == 11 ~ 4,  # Graduate degree
    EDUC == 99 ~ 5  # Missing
  ))
table(cohabit_data$EDUC_RECODED)

#non-labor income(total income minus the sum of income from wages, salary, 
#non-farm business, and farming) 
#INCTOT-INCWAGE


#the partner/spouse’s income from salary and wages
partner_info <- cohabit_data[,c("SAMPLE","SERIAL","PERNUM","INCWAGE","EDUC_RECODED")]
cohabit_data <- cohabit_data%>%
  left_join(partner_info, by = c("SAMPLE"="SAMPLE","SERIAL"="SERIAL",
                                 "SPLOC"="PERNUM"), suffix = c("","_partner"))
#INCWAGE_partner




#natural log of the respondent’s hourly wage
#USE the wage imputation method below!
#for now test with working sample
#working_subset <- cohabit_data %>%
#  filter(annualHRSWORK>0 & INCWAGE > 0)
#working_subset$log_hourly_wage <- log(working_subset$INCWAGE 
#                                      / working_subset$annualHRSWORK)


#Hourly wage is equal to income from work divided by hours of work.
#cohabit_data <- cohabit_data %>%
#  mutate(log_hourly_wage = ifelse(annualHRSWORK > 0 & INCWAGE > 0, 
#                                  log(INCWAGE / annualHRSWORK), 
#                                  NA_real_))
#using wage imputation method
#part_time_women <- cohabit_data %>%
#  filter(cohabit_data$UHRSWORK < 20 & SEX==2)
#part_time_men <- cohabit_data %>%
#  filter(cohabit_data$UHRSWORK < 20 & SEX==1)







#-------------------
#--- DID ----
#-------------------
# did estimator for interaction term of same_sex and legalized
# legalized takes a value of one for respondents living in states that have marriage equality at the time of the survey
cohabit_data$legalized <- as.integer(cohabit_data$legalized)

#male dataset
cohabit_data_male <- cohabit_data %>%
  filter(SEX==1)
#female dataset
cohabit_data_female <- cohabit_data %>%
  filter(SEX==2)



did_male <- lm(annualHRSWORK ~ same_sex+legalized+same_sex*legalized
               +AGE+AGE_square+NCHILD+has_children_under5+factor(RACE_RECODED)
               +factor(HISPAN_RECODED)+factor(METRO_RECODED)+factor(EDUC_RECODED)
               +INCWAGE_partner+factor(YEAR)+factor(STATEICP), 
               data = cohabit_data_male)

summary(did_male)

did_female <- lm(annualHRSWORK ~ same_sex+legalized+same_sex*legalized
               +AGE+AGE_square+NCHILD+has_children_under5+factor(RACE_RECODED)
               +factor(HISPAN_RECODED)+factor(METRO_RECODED)+factor(EDUC_RECODED)
               +INCWAGE_partner+factor(YEAR)+factor(STATEICP), 
               data = cohabit_data_female)
summary(did_female)

