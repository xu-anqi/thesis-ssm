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
global OUTPUT   = "$DIR/output/1_exten_supply"			// path for output
/*-----------------------------------------------------------------------------------
			/* Load Data */
-----------------------------------------------------------------------------------*/
/*
use "$DATA/cohabit_data.dta", clear

tab hours_year if hours_year == 0
tab incwage_99 if incwage_99 == 0
tab hours_year if incwage_99 == 0
*/

*===========================
* 1) DID
*===========================	

* Loop over sex: 1 = men, 2 = women
foreach s in 2 {
    local slbl = cond(`s'==1, "men", "women")
    eststo clear
	
	use "$DATA/cohabit_data.dta", clear
	
	/*
	gen double _u = runiform()
    bysort statefip year: gen byte _keep = _u < 0.010    // ~ 1% per state-year
    keep if _keep
    drop _u _keep
	*/
	
	gen has_supply = (hours_year > 0)
	keep if sex == `s'
	
}

***********************************************
* Pre-trend Interaction Test
***********************************************


* Event time (signed)
bysort statefip (year): egen g = min(cond(legal==1, year, .))
gen relt = year - g
drop if missing(relt)

* Balanced window
replace relt = -6 if relt < -6
replace relt =  6 if relt >  6
replace relt = relt+6

/* --- Extensive margin: LPM event-study ---
reghdfe has_supply i.same_sex##i.relt, ///
    absorb(statefip year) vce(cluster statefip)

* Joint test of pre-leads
levelsof relt if relt<=4, local(preleads)
local T
foreach k of local preleads {
    local T `T' 1.same_sex#`k'.relt
}
test `T'


	
exit
*/

*** intensive margin ***
drop if missing(lnw)

reghdfe lnw i.same_sex##i.relt , ///
    absorb(statefip year) vce(cluster statefip)

levelsof relt if relt<=4, local(pre)
local T
foreach k of local pre {
    local T `T' 1.same_sex#`k'.relt
}
test `T'

