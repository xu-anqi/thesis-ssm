rm(list=ls())
library(dplyr)
library(ggplot2)
library(haven)

setwd("~/Library/CloudStorage/OneDrive-KULeuven/Thesis/data analysis")
getwd()

#filtered data is full data
#load("/Users/angelxu/Library/CloudStorage/OneDrive-KULeuven/Thesis/data analysis/filtered_data.RData")

#sample are not complete data, it is created for testing
load("/Users/angelxu/Library/CloudStorage/OneDrive-KULeuven/Thesis/data analysis/sample.RData")

#-------------------
#---wage compare----
#-------------------

# Calculate mean income for each sex_behaviour
mean_income <- filtered_data %>%
  group_by(sex_behaviour) %>%
  summarize(mean_income = mean(INCWAGE, na.rm = TRUE))%>%
  arrange(desc(mean_income))

# Reorder sex_behaviour based on mean_income in descending order
mean_income$sex_behaviour <- factor(mean_income$sex_behaviour, levels = mean_income$sex_behaviour)

# Assign colors based on sex_behaviour categories
mean_income$pattern <- ifelse(mean_income$sex_behaviour %in% c("same-sex cohabiting man", "same-sex cohabiting woman"), "same-sex cohabiting", "single or different-sex cohabiting")

# Create the ggplot object
plot <- ggplot(mean_income, aes(x = sex_behaviour, y = mean_income, fill = pattern)) +
  geom_col() +  # Use geom_col() for bar plots
  labs(x = "Sex and Cohabiting Behaviour", y = "Mean Income", title = "Mean Income by Sex and Cohabiting Behaviour") +
  geom_text(aes(label = sprintf("$%d", round(mean_income))),
            vjust = -0.5, size = 3, color = "black") +  # Add data labels
  scale_fill_brewer(palette = "Set2", direction = -1) +  # Use ColorBrewer Set2 palette  theme_minimal() +  # Minimal theme
  #scale_fill_viridis_d(option = "D", direction = -1) +  # Invert Viridis color palette
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels
    plot.background = element_rect(fill = "transparent"),  # Transparent plot background
    panel.background = element_rect(fill = "transparent"),  # Transparent panel background
    panel.grid.major = element_blank(),  # Remove major grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    legend.position = "bottom"  # Position legend at the bottom
  )

# Adjust y-axis limits and breaks
plot <- plot + ylim(0, max(mean_income$mean_income) * 1.2)  # Extend y-axis range by 20%
plot <- plot + scale_y_continuous(expand = expansion(mult = c(0.05, 0.1)))  # Adjust y-axis expansion

print(plot)


#---------------------------------------------------------------------
#---How does sex behaviour (cohabiting behaviour) affect the wage?----
#---------------------------------------------------------------------

table(filtered_data$SEX)

filtered_data$RACE <- factor(filtered_data$RACE)
filtered_data$METRO <- factor(filtered_data$METRO)
filtered_data$MARST <- factor(filtered_data$MARST)
#filtered_data$YEAR <- factor(filtered_data$YEAR)
#filtered_data$EDUC <- factor(filtered_data$EDUC)
filtered_data$SEX <- factor(filtered_data$SEX)
filtered_data$STATEICP <- factor(filtered_data$STATEICP)


filtered_data$lnINCWAGE <- log(filtered_data$INCWAGE + 1)



#--------------------------------------------
#both gender, all time, cohabiting and single
#--------------------------------------------
filtered_data <- filtered_data %>%
  mutate(sex_behaviour2 = case_when(
    SEX == 1 & SEX_partner == 1 ~ "same-sex",
    SEX == 2 & SEX_partner == 2 ~ "same-sex",
    #    SEX == 1 & SEX_partner == 2 ~ "different-sex",
    #    SEX == 2 & SEX_partner == 1 ~ "different-sex",
    TRUE ~ "others"
  ))

table(filtered_data$sex_behaviour2)

filtered_data$sex_behaviour2 <- factor(filtered_data$sex_behaviour2)

ols_all <- lm(lnINCWAGE ~ sex_behaviour2+SEX+AGE+RACE+METRO+MARST+EDUC+YEAR+STATEICP+NCHILD, data = filtered_data)

summary(ols_all)
#0.69, significant 99% level

#------------------------------------
#both gender, all time, cohabiting
#------------------------------------
filtered_data <- filtered_data %>%
  mutate(sex_behaviour2 = case_when(
    SEX == 1 & SEX_partner == 1 ~ "same-sex",
    SEX == 2 & SEX_partner == 2 ~ "same-sex",
    SEX == 1 & SEX_partner == 2 ~ "different-sex",
    SEX == 2 & SEX_partner == 1 ~ "different-sex",
    TRUE ~ "others"
  ))

ols_data <- filtered_data %>%
  filter(sex_behaviour2 != "others")

table(ols_data$sex_behaviour2)

filtered_data$sex_behaviour2 <- factor(filtered_data$sex_behaviour2)

ols_cohabit <- lm(lnINCWAGE ~ sex_behaviour2+SEX+AGE+RACE+METRO+MARST+EDUC+YEAR+STATEICP+NCHILD, data = ols_data)

summary(ols_cohabit)
#0.47, significant 99% level

#-----------------------------------------
#both gender, before legalize, cohabiting
#-----------------------------------------
filtered_data <- filtered_data %>%
  mutate(sex_behaviour2 = case_when(
    SEX == 1 & SEX_partner == 1 ~ "same-sex",
    SEX == 2 & SEX_partner == 2 ~ "same-sex",
    SEX == 1 & SEX_partner == 2 ~ "different-sex",
    SEX == 2 & SEX_partner == 1 ~ "different-sex",
    TRUE ~ "others"
  ))

ols_data <- filtered_data %>%
  filter(sex_behaviour2 != "others")
ols_data <- ols_data %>%
  filter(legalized == FALSE)

table(ols_data$sex_behaviour2)

filtered_data$sex_behaviour2 <- factor(filtered_data$sex_behaviour2)

ols_cohabit <- lm(lnINCWAGE ~ sex_behaviour2+SEX+AGE+RACE+METRO+MARST+EDUC+YEAR+STATEICP+NCHILD, data = ols_data)

summary(ols_cohabit)
#0.68, significant 99% level

#-----------------------------------------
#male, all time, cohabiting
#-----------------------------------------
filtered_data <- filtered_data %>%
  mutate(sex_behaviour2 = case_when(
    SEX == 1 & SEX_partner == 1 ~ "same-sex",
    SEX == 2 & SEX_partner == 2 ~ "same-sex",
    SEX == 1 & SEX_partner == 2 ~ "different-sex",
    SEX == 2 & SEX_partner == 1 ~ "different-sex",
    TRUE ~ "others"
  ))

ols_data <- filtered_data %>%
  filter(sex_behaviour2 != "others")
ols_data <- ols_data %>%
  filter(SEX == 1)

table(ols_data$sex_behaviour2)
table(ols_data$SEX)

ols_cohabit_male <- lm(lnINCWAGE ~ sex_behaviour2+AGE+RACE+METRO+MARST+EDUC+YEAR+STATEICP+NCHILD, data = ols_data)

summary(ols_cohabit_male)
#0.13, significant 90% level

#-----------------------------------------
#male, before legalized, cohabiting
#-----------------------------------------
filtered_data <- filtered_data %>%
  mutate(sex_behaviour2 = case_when(
    SEX == 1 & SEX_partner == 1 ~ "same-sex",
    SEX == 2 & SEX_partner == 2 ~ "same-sex",
    SEX == 1 & SEX_partner == 2 ~ "different-sex",
    SEX == 2 & SEX_partner == 1 ~ "different-sex",
    TRUE ~ "others"
  ))

ols_data <- filtered_data %>%
  filter(sex_behaviour2 != "others")
ols_data <- ols_data %>%
  filter(SEX == 1)
ols_data <- ols_data %>%
  filter(legalized == FALSE)

table(ols_data$sex_behaviour2)
table(ols_data$SEX)

ols_illegal_male <- lm(lnINCWAGE ~ sex_behaviour2+AGE+RACE+METRO+MARST+EDUC+YEAR+STATEICP+NCHILD, data = ols_data)

summary(ols_illegal_male)
#0.45, 99%

#-----------------------------------------
#female, all time, cohabiting
#-----------------------------------------
filtered_data <- filtered_data %>%
  mutate(sex_behaviour2 = case_when(
    SEX == 1 & SEX_partner == 1 ~ "same-sex",
    SEX == 2 & SEX_partner == 2 ~ "same-sex",
    SEX == 1 & SEX_partner == 2 ~ "different-sex",
    SEX == 2 & SEX_partner == 1 ~ "different-sex",
    TRUE ~ "others"
  ))

ols_data <- filtered_data %>%
  filter(sex_behaviour2 != "others")
ols_data <- ols_data %>%
  filter(SEX == 2)

table(ols_data$sex_behaviour2)
table(ols_data$SEX)

ols_cohabit_female <- lm(lnINCWAGE ~ sex_behaviour2+AGE+RACE+METRO+MARST+EDUC+YEAR+STATEICP+NCHILD, data = ols_data)

summary(ols_cohabit_female)
#0.82, significant 99% level


#-----------------------------------------
#female, before legalized, cohabiting
#-----------------------------------------
filtered_data <- filtered_data %>%
  mutate(sex_behaviour2 = case_when(
    SEX == 1 & SEX_partner == 1 ~ "same-sex",
    SEX == 2 & SEX_partner == 2 ~ "same-sex",
    SEX == 1 & SEX_partner == 2 ~ "different-sex",
    SEX == 2 & SEX_partner == 1 ~ "different-sex",
    TRUE ~ "others"
  ))

ols_data <- filtered_data %>%
  filter(sex_behaviour2 != "others")
ols_data <- ols_data %>%
  filter(SEX == 2)
ols_data <- ols_data %>%
  filter(legalized == FALSE)

table(ols_data$sex_behaviour2)
table(ols_data$SEX)

ols_illegal_female <- lm(lnINCWAGE ~ sex_behaviour2+AGE+RACE+METRO+MARST+EDUC+YEAR+STATEICP+NCHILD, data = ols_data)

summary(ols_illegal_female)
#0.92, significant 99% level









#----------------------------
#TEST

not_legalized <- subset(filtered_data, legalized == FALSE)

#not legalized, male, cohabiting
not_legalized_male <- subset(not_legalized, SEX == 1)
not_legalized_male <- subset(not_legalized_male, sex_behaviour!="single man")
table(not_legalized_male$sex_behaviour)

not_legalized_male$sex_behaviour_num <- ifelse(not_legalized_male$sex_behaviour == "same-sex cohabiting man", 1, 0)
not_legalized_male$interaction_sexbe_year <- not_legalized_male$sex_behaviour_num * 
  not_legalized_male$YEAR
ols_notlegalized_male <- lm(lnINCWAGE ~ sex_behaviour+YEAR+interaction_sexbe_year+AGE+RACE+METRO+MARST+EDUC+STATEICP+NCHILD, data = not_legalized_male)
summary(ols_notlegalized_male)



#test 2000
test_2000 <- subset(not_legalized_male, YEAR == 2000)
test_ols <- lm(lnINCWAGE ~ sex_behaviour++AGE+RACE+MARST+EDUC+NCHILD, 
               data = test_2000)
summary(test_ols)

#test 2000-2010
test_2010 <- subset(not_legalized_male, YEAR >= 2000 & YEAR <= 2001)
test_ols <- lm(lnINCWAGE ~ sex_behaviour+YEAR+AGE+RACE+MARST+EDUC+NCHILD+STATEICP, 
               data = test_2010)
summary(test_ols)


ols <- lm(lnINCWAGE ~ sex_behaviour2+AGE+RACE+METRO+MARST+EDUC+YEAR+STATEICP+NCHILD, data = filtered_data)

summary(ols)



