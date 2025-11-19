# NOTE: To load data, you must download both the extract's data and the DDI
# and also set the working directory to the folder with these files 
# (or change the path below).

rm(list=ls())

#install.packages('ipumsr')
library(ipumsr)
library(dplyr)
library(ggplot2)

setwd("~/Library/CloudStorage/OneDrive-KULeuven/Thesis/data analysis")
setwd("C:/Users/AnqiXu/OneDrive - KU Leuven/Thesis/data analysis")
getwd()

#--------------------
#--Load ipums Data---
#--------------------
ddi <- read_ipums_ddi("usa_00007.xml")
data <- read_ipums_micro(ddi)

#!!!
#!!!skip this when not in test
#!!!
#---------------------------------------------------------------------
#to reduce processing time, randomly select for one year for each state.
#---------------------------------------------------------------------
set.seed(1)

# Define the size of the subset
subset_size <- 10000000
# Sample the rows
sampled_indices <- sample(1:nrow(data), subset_size)
filtered_data <- data[sampled_indices, ]

#selected_year <- data %>%
#  group_by(STATEICP)%>%
#  summarize(selected_year = sample(unique(YEAR), 1)) %>%
#  ungroup()

#filtered_data <- data%>%
#  inner_join(selected_year, by = c("STATEICP"="STATEICP", "YEAR" = "selected_year"))



#---------------------------------------------------------------------
#-------Filter some data
#---------------------------------------------------------------------

#removed group quaters, flagged data, and below age 25 and above age 74
filtered_data <- data %>%
  filter(GQ == 1 | GQ == 2) %>%
  filter(QMARST == 0) %>%
  filter(QSEX == 0) %>%
  filter(AGE >= 25 & AGE <= 74)

#remove some variable that is not in use
filtered_data <- filtered_data%>%
  select(-CBSERIAL,-HHWT,-CLUSTER,-STRATA,-PERWT,-QMARST,-QSEX)


#---------------------------------------------------------------------
#join partner information to identify sexual behaviour
#---------------------------------------------------------------------
partner_info <- filtered_data[,c("SAMPLE","SERIAL","PERNUM","SEX")]
filtered_data <- filtered_data%>%
  left_join(partner_info, by = c("SAMPLE"="SAMPLE","SERIAL"="SERIAL",
            "SPLOC"="PERNUM"), suffix = c("","_partner"))

filtered_data <- filtered_data %>%
  mutate(sex_behaviour = case_when(
    SEX == 1 & SEX_partner == 1 ~ "same-sex cohabiting man",
    SEX == 2 & SEX_partner == 2 ~ "same-sex cohabiting woman",
    SEX == 1 & SEX_partner == 2 ~ "different-sex cohabiting man",
    SEX == 2 & SEX_partner == 1 ~ "different-sex cohabiting woman",
    SEX == 1 & SPLOC == 0 ~ "single man",
    SEX == 2 & SPLOC == 0 ~ "single woman",
    TRUE ~ "unassigned"
  ))

table(filtered_data$sex_behaviour)

#filter sex_behaviour unassigned
filtered_data <- filtered_data%>%
  filter(sex_behaviour != "unassigned")




#---------------------------------------------------------------------
#---With Legalization Year information----
#---------------------------------------------------------------------
library(readxl)
year_legalized <- read_excel("C:/Users/AnqiXu/OneDrive - KU Leuven/Thesis/year_legalized.xlsx", 
                             col_types = c("text", "text", "skip", 
                                           "numeric", "numeric"))
#View(year_legalized)


#year_legalized <- read_excel("C:/Users/r0960207/OneDrive - KU Leuven/Thesis/year_legalized.xlsx", 
#                            col_types = c("text", "text", "skip", 
#                                           "numeric", "numeric"))

year_legalized <- read_excel("~/Library/CloudStorage/OneDrive-KULeuven/Thesis/year_legalized.xlsx", 
                             col_types = c("text", "text", "skip", 
                                           "numeric", "numeric"))
#View(year_legalized)

#filtered_data$STATEICP <- as.numeric(filtered_data$STATEICP)
filtered_data <- filtered_data%>%
  left_join(year_legalized, by = c("STATEICP"="code_ICP"), 
                                   suffix = c("",""))


#na_state_counts <- filtered_data %>%
#  filter(is.na(year_legalized)) %>%
#  group_by(STATEICP) %>%
#  summarise(count = n()) %>%
#  arrange(desc(count))

#na_state_counts

filtered_data <- filtered_data %>%
  filter(!is.na(filtered_data$year_legalized))

#filtered_data$YEAR <- as.numeric(filtered_data$YEAR)
filtered_data <- filtered_data %>%
  mutate(legalized = YEAR > year_legalized)



#---------------------------------------------------------------------
#------------save filtered data for furthur analysis
#---------------------------------------------------------------------
# path to save on the desktop (adjust according to your system)
#file_path <- "filtered_data.RData"

file_path <- "sample.RData"

#file_path <- "data.RData"


save(filtered_data, file = file_path)
#save(data, file = file_path)


