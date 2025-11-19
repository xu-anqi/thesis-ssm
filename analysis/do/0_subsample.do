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
global OUTPUT   = "$DIR/output"			// path for output
/*-----------------------------------------------------------------------------------
			/* Load Data */
-----------------------------------------------------------------------------------*/
* use "$DATA/usa_00008.dta", clear
use "$DATA/cohabit_data.dta", clear


* ---- toggle: 1 = small dev run, 0 = full sample ----
global DEV 1



*===========================
* 1) Optional DEV subsample
*    - stratified by state-year so composition stays similar
*    - reproducible via set seed above
*===========================
if $DEV {
    gen double _u = runiform()
    bysort statefip year: gen byte _keep = _u < 0.010    // ~1% per state-year
    keep if _keep
    drop _u _keep
    di as res ">> DEV RUN: keeping ~10% per state-year"
}
else {
    di as res ">> FULL RUN"
}



save "$DATA/subsample.dta", replace


