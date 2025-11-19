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
global OUTPUT   = "$DIR/output/hansen"			// path for output
/*-----------------------------------------------------------------------------------
			/* Load Data */
-----------------------------------------------------------------------------------*/
* use "$DATA/subsample.dta", clear

use "$DATA/cohabit_data.dta", clear


*===========================
* 1) DID
*===========================



* Loop over sex: 1 = men, 2 = women
foreach s in 1 2 {
    local slbl = cond(`s'==1, "men", "women")
    eststo clear

    * (1) baseline
    quietly reghdfe hours_year i.same_sex##i.legal ///
        if sex==`s', vce(cluster statefip)
    eststo lpm1


    * (2) + demo
    quietly reghdfe hours_year i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan ///
        if sex==`s', vce(cluster statefip)
    eststo lpm2

    * (3) + edu
    quietly reghdfe hours_year i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
        if sex==`s', vce(cluster statefip)
    eststo lpm3
	
	* (4) + home ownership, log imputed wage, non-labor income
    quietly reghdfe hours_year i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i.ownershp inc_nonlabor_99 lnw_imp ///
        if sex==`s', vce(cluster statefip)
    eststo lpm4
	
	
    * (5) + state & year FE (absorbed)
    quietly reghdfe hours_year i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i.ownershp inc_nonlabor_99 lnw_imp ///
        if sex==`s', absorb(statefip year) vce(cluster statefip)
    eststo lpm5

    * Export one table per sex
    esttab lpm1 lpm2 lpm3 lpm4 lpm5 using "${OUTPUT}/did_`slbl'.txt", ///
        replace se b(3) star(* 0.10 ** 0.05 *** 0.01) ///
        title("DID: labour supply `=strproper("`slbl'")'") ///
        label stats(r2 N, fmt(3 0) labels("R-squared" "N"))
}







