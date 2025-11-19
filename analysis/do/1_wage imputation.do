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
global OUTPUT   = "$DIR/output"			// path for output
/*-----------------------------------------------------------------------------------
			/* Load Data */
-----------------------------------------------------------------------------------*/

use "$DATA/cohabit_data.dta", clear


*===========================
* 1) wage imputation
*===========================
gen hourly_99 = incwage_99 / hours_year if hours_year>0 & incwage_99>0
gen lnw    = ln(hourly_99)       if hourly_99>0
gen lnw_imp = 0

**********************
******* SEX == 1******
**********************

reghdfe lnw i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i.ownershp inc_nonlabor_99 i. edu_partner ///
		if hourly_99>0 & sex ==1 ///
       , absorb(statefip year) vce(cluster statefip)

predict lnw_hat_1, xb

* Imputed log wage for the whole sample
replace lnw_imp = lnw if sex == 1
replace lnw_imp = lnw_hat_1 if missing(lnw) & sex == 1


**********************
******* SEX == 2******
**********************
reghdfe lnw i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i.ownershp inc_nonlabor_99 i. edu_partner ///
		if hourly_99>0 & sex ==2 ///
       , absorb(statefip year) vce(cluster statefip)

predict lnw_hat_2, xb

* Imputed log wage for the whole sample
replace lnw_imp = lnw if sex == 2
replace lnw_imp = lnw_hat_2 if missing(lnw) & sex == 2




***
save "$DATA/cohabit_data", replace




