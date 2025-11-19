/*-----------------------------------------------------------------------------------
Name: Anqi Xu
Last update: 2024
This do file does : 
	Set up working directories and user-written programs
-----------------------------------------------------------------------------------*/
set more off
clear all	

/*-----------------------------------------------------------------------------------
			/* Set up */
-----------------------------------------------------------------------------------*/
*** Setting up working directories
global DIR = "D:/Master_Thesis/data analysis" 

*global DIR = "/Volumes/TOSHIBA/Master_Thesis/data analysis" // home directory

global DATA 	= "$DIR/data" 			// path for data file
global DO 		= "$DIR/do"				// path for dofiles
global OUTPUT   = "$DIR/output/descriptive"			// path for output
/*-----------------------------------------------------------------------------------
			/* Load Data */
-----------------------------------------------------------------------------------*/
* use "$DATA/usa_00008.dta", clear
use "$DATA/cohabit_data.dta", clear

/*
    gen double _u = runiform()
    bysort statefip year: gen byte _keep = _u < 0.010    // ~1% per state-year
    keep if _keep
    drop _u _keep
*/



*========================================================
* Minimal collapse -> Excel (Men/Women × Legal × Same-sex)
*========================================================

* --- Grouping variables (edit if needed) ---
* sex: 1=Men, 2=Women (or your coding)
* legal: 0/1 indicator for SSM legal status in state-year
* same_sex: 1=same-sex couple, 0=different-sex couple
local groupvars sex legal same_sex


gen wage_imp = exp(lnw)

gen race_w = (race4==1)
gen race_b = (race4==2)
gen race_a = (race4==3)
gen race_o = (race4==4)

gen urban_not = (urban ==0)
gen urban_urban = (urban == 1)
gen urban_mixed = (urban == 2)

gen edu_less = (edu == 0)
gen edu_high = (edu == 1)
gen edu_some = (edu == 2)
gen edu_bach = (edu == 3)
gen edu_grad = (edu == 4)

replace ownershp = ownershp - 1

* --- Variables to summarize (edit names if needed) ---
local vars ///
    hourly_99           /// wage rate (no imputation)
    wage_imp             /// wage rate (with imputation)
    hours_year           /// hours worked last year
    incwage_99           /// wage/salary income last year (1999$)
    age nchild nchlt5    /// demographics
    race_w race_b race_a race_o hispan urban_not urban_urban urban_mixed    /// race code, hispanic=1, urban=1
    edu_less edu_high edu_some edu_bach edu_grad         /// education code
    ownershp            /// home ownership (1=own)
    inc_nonlabor_99           /// non-labour income

preserve
keep `groupvars' `vars'

* --- Collapse: means, SDs, and counts ---
* Unweighted:
collapse (mean) `vars' (count) N=age , by(`groupvars')

* If you want ACS person-weights, replace the previous line with:
* collapse (mean) `vars' (sd) `vars' (count) N=sex [pw=perwt], by(`groupvars')

* Note: Stata will name SD columns like sd_varname (e.g., sd_wage_imp).
*       N is the count of non-missing 'sex' in each cell.

* --- Export to Excel ---
sort sex legal same_sex
export excel using "$OUTPUT/descriptive_mean.xlsx", firstrow(variables) replace
restore


keep `groupvars' `vars'

* --- Collapse: means, SDs, and counts ---
* Unweighted:
collapse (sd) `vars' (count) N=age , by(`groupvars')

* If you want ACS person-weights, replace the previous line with:
* collapse (mean) `vars' (sd) `vars' (count) N=sex [pw=perwt], by(`groupvars')

* Note: Stata will name SD columns like sd_varname (e.g., sd_wage_imp).
*       N is the count of non-missing 'sex' in each cell.

* --- Export to Excel ---
sort sex legal same_sex
export excel using "$OUTPUT/descriptive_sd.xlsx", firstrow(variables) replace








