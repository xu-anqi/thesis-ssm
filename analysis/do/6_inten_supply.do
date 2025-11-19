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
global OUTPUT   = "$DIR/output/1_inten_supply"			// path for output
/*-----------------------------------------------------------------------------------
			/* Load Data */
-----------------------------------------------------------------------------------*/

/*
use "$DATA/cohabit_data.dta", clear
exit
*/

*===========================
* 1) DID
*===========================	

* Loop over sex: 1 = men, 2 = women
foreach s in 1 2 {
    local slbl = cond(`s'==1, "men", "women")
    eststo clear
	
	use "$DATA/cohabit_data.dta", clear
	drop if hours_year == 0

	/*
	gen double _u = runiform()
    bysort statefip year: gen byte _keep = _u < 0.0010    // ~0.1% per state-year
    keep if _keep
    drop _u _keep
	*/
	
	keep if sex == `s'
	
    * (1) baseline
     reghdfe hours_year i.same_sex##i.legal ///
        , vce(cluster statefip)
    eststo lpm1


    * (2) + demo
     reghdfe hours_year i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan ///
        , vce(cluster statefip)
    eststo lpm2

    * (3) + edu
     reghdfe hours_year i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
        , vce(cluster statefip)
    eststo lpm3
	
    * (5) + state & year FE 
     reghdfe hours_year i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
        , absorb(statefip year) vce(cluster statefip)
    eststo lpm5
	
	* (4) + home ownership, , non-labor income
     reghdfe hours_year i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i.ownershp inc_nonlabor_99 lnw_imp ///
        , vce(cluster statefip)
    eststo lpm4
	
	* (6) + state & year FE 
     reghdfe hours_year i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i.ownershp inc_nonlabor_99 lnw_imp ///
        , absorb(statefip year) vce(cluster statefip)
    eststo lpm6
	

    * Export one table per sex
    esttab lpm1 lpm2 lpm3 lpm5 lpm4 lpm6 using "${OUTPUT}/did_`slbl'.txt", ///
        replace se b(3) star(* 0.10 ** 0.05 *** 0.01) ///
        title("DID: Labour Supply Intensive Margin - `=strproper("`slbl'")'") ///
        label stats(r2 N, fmt(3 0) labels("R-squared" "N"))
}







