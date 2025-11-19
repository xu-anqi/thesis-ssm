set more off
clear all	

/*-----------------------------------------------------------------------------------
			/* Set up */
-----------------------------------------------------------------------------------*/
*** Setting up working directories
global DIR = "D:/Master_Thesis/data analysis" 
* global DIR = "/Volumes/TOSHIBA/Master_Thesis/data analysis" // home directory

global DATA 	= "$DIR/data" 			// path for data file
global DO 		= "$DIR/do"				// path for dofiles
global OUTPUT   = "$DIR/output"			// path for output
/*-----------------------------------------------------------------------------------
			/* Load Data */
-----------------------------------------------------------------------------------*/
* use "$DATA/subsample.dta", clear

use "$DATA/usa_00009.dta", clear


*===========================
* 1) Sample: couples, avoid miscoding
*===========================
* Keep couples (has a spouse/partner link); IPUMS USA has SPLOC in many years.
drop if sploc == 0

* Flag allocated (edited/imputed) sex/marital/relationship and drop them (Hansen practice)
gen byte any_alloc = (qsex>0) | (qmarst>0) 
drop if any_alloc==1          // see Hansen discussion of allocation issues

*** edu
* Collapse educ into 5 categories
gen edu = .

* Less than high school diploma
replace edu = 0 if inlist(educ, 0,1,2,3,4,5)  // no schooling to grade 11

* High school diploma
replace edu = 1 if educ == 6

* Some college (1–3 years)
replace edu = 2 if inlist(educ, 7, 8, 9)

* Bachelor's degree (4 years)
replace edu = 3 if educ == 10

* Graduate degree (5+ years)
replace edu = 4 if educ == 11

* Set missing for N/A/missing code
replace edu = . if educ == 99 | missing(educ)

* Label values
label define edulbl 0 "Less than high school diploma" ///
                     1 "High school diploma" ///
                     2 "Some college" ///
                     3 "Bachelor's degree" ///
                     4 "Graduate degree"
label values edu edulbl
drop educ



*===========================
* 2) Build same-sex vs different-sex couple indicator, prime age
*===========================
* Build partner look-up from the full data BEFORE filtering
preserve
keep year serial pernum sex age edu incwage
isid year serial pernum, sort          // should be unique person id
rename pernum sploc
rename sex   sex_partner
rename age 	 age_partner
rename edu   edu_partner
rename incwage incwage_partner
isid year serial sploc                 // now unique spouse key
tempfile partners
save `partners', replace
restore


* Many-to-one merge on YEAR + SERIAL + SPLOC
merge 1:1 year serial sploc using `partners' , nogen keep(match master)
* You now have sex_partner

* Keep only people with identified partner
drop if missing(sex_partner)

* Same-sex indicator
gen byte same_sex = (sex==sex_partner)




* Prime age rule (main: at least one 25–54; robustness: both 25–54)
gen byte self_prime    = inrange(age,25,54)
gen byte partner_prime = inrange(age_partner,25,54)

* --- Your requested spec: at least one partner is prime
keep if self_prime | partner_prime

save "$DATA/cohabit_data.dta", replace


*===========================
* 3) Legalization indicator (state × year)
*===========================
* Bring in your Excel
import excel using "$DATA/year_legalized.xlsx", firstrow clear
keep State Abbreviation year_legalized code_ICP
rename code_ICP stateicp
tempfile legal
save `legal', replace

* Merge to your IPUMS master (which must have STATEICP)
use "$DATA/cohabit_data.dta", clear
merge m:1 stateicp using `legal', keep(match master) nogen

save "$DATA/cohabit_data.dta", replace

gen legal = 0
replace legal = 1 if year >= year_legalized 


*===========================
* 4) Clean dependent variables
*===========================

*** working weeks
gen weeks = 0
replace weeks = 7    if wkswork2 == 1   
replace weeks = 20   if wkswork2 == 2   
replace weeks = 33   if wkswork2 == 3   
replace weeks = 43.5 if wkswork2 == 4   
replace weeks = 48.5 if wkswork2 == 5   
replace weeks = 51   if wkswork2 == 6   

* annual hours of workin
gen hours_year = weeks * uhrswork


*** age_sq
gen age_sq = age^2

*** presence of a child under 5
replace nchlt5 = (nchlt5 >= 1)



*** race
* Create a new race variable with 4 categories
gen race4 = .
label define race4lbl 1 "White" 2 "Black" 3 "Asian" 4 "Other"

* White
replace race4 = 1 if race == 1   // white

* Black
replace race4 = 2 if race == 2   // black/african american

* Asian (Chinese, Japanese, Other Asian or Pacific Islander)
replace race4 = 3 if inlist(race, 4, 5, 6)

* Other (American Indian/Alaska Native, Other race, Two races, Three+ races)
replace race4 = 4 if inlist(race, 3, 7, 8, 9)

* Assign the label
label values race4 race4lbl

* drop race
drop race raced


*** ethnicity
replace hispan = (hispan!=0)


*** urban
* Create new variable: 0 = Not urban, 1 = Urban, 2 = Mixed
gen urban = .

* Not urban
replace urban = 0 if metro == 1   // Not in metropolitan area

* Urban 
replace urban = 1 if inlist(metro, 2, 3, 4)

* Mixed (status indeterminable)
replace urban = 2 if metro == 0

* Label the new variable
label define urbanlbl 0 "Not urban" 1 "Urban" 2 "Mixed"
label values urban urbanlbl

* 
drop metro





*** replace missing & defalte monetary terms
replace inctot = . if inctot == 9999999
replace inctot = . if inctot == 9999998
replace incwage = . if inctot == 9999999
replace incwage = . if inctot == 9999998
replace incbus00 = . if inctot == 9999999




gen inctot_99 = inctot * cpi99
gen incwage_99 = incwage * cpi99
gen incbus_99 = incbus00 * cpi99









*** non-labour income
gen inc_nonlabor_99 = inctot_99 - incwage_99 - incbus_99

exit

drop ownershpd hispand educd empstatd empstat cbserial hhwt empstat

save "$DATA/cohabit_data.dta", replace




