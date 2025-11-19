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
foreach s in 1 2 {
    local slbl = cond(`s'==1, "men", "women")
    eststo clear
	
	use "$DATA/cohabit_data.dta", clear
	
	/*
	gen double _u = runiform()
    bysort statefip year: gen byte _keep = _u < 0.0010    // ~0.1% per state-year
    keep if _keep
    drop _u _keep
	*/
	
	gen has_supply = (hours_year > 0)
	keep if sex == `s'
	
    * (1) baseline
     probit has_supply i.same_sex##i.legal ///
        [pweight = perwt], vce(cluster statefip)
    eststo probit1


    * (2) + demo
     probit has_supply i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan ///
        [pweight = perwt], vce(cluster statefip)
    eststo probit2

    * (3) + edu
     probit has_supply i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
        [pweight = perwt], vce(cluster statefip)
    eststo probit3
	

	
    * (5) + state & year FE 
     probit has_supply i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i.statefip i.year ///
        [pweight = perwt], vce(cluster statefip)
    eststo probit5
	

	/* (4) + home ownership, , non-labor income
     probit has_supply i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i.ownershp inc_nonlabor_99 lnw_imp ///
        [pweight = perwt], vce(cluster statefip)
    eststo probit4
	
	
	* (6) + state & year FE 
     probit has_supply i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i.ownershp inc_nonlabor_99 lnw_imp i.statefip i.year ///
        [pweight = perwt], vce(cluster statefip)
    eststo probit6
	*/
	

    * Export one table per sex
    esttab probit1 probit2 probit3 probit5 /*probit4 probit6*/ using "${OUTPUT}/did_`slbl'.txt", ///
        replace se b(3) star(* 0.10 ** 0.05 *** 0.01) ///
        title("DID: Wage, Extensive Margin `=strproper("`slbl'")'") ///
        label stats(ll r2_p r2 N, fmt(2 3 3 0) labels("Log-Likelihood" "Pseudo R-squared" "R-squared" "N"))
}







