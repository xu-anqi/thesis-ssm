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
global OUTPUT   = "$DIR/output/mech-kid5/inten"			// path for output
/*-----------------------------------------------------------------------------------
			/* Load Data */
-----------------------------------------------------------------------------------*/
* use "$DATA/subsample.dta", clear



*===========================
* 1) DID
*===========================	

* Loop over sex: 1 = men, 2 = women
foreach p in 0 1  {
	local plbl = cond(`p'==1, "with kid", "without kid" )
	
foreach s in 1 2 {
    local slbl = cond(`s'==1, "men", "women")
    eststo clear
	
	use "$DATA/cohabit_data.dta", clear
	keep if sex == `s'
	
	drop if missing(nchlt5)
	gen has_kid = (nchlt5 > 0)
	keep if has_kid == `p'

	/*
	gen double _u = runiform()
    bysort statefip year: gen byte _keep = _u < 0.010    // ~1% per state-year
    keep if _keep
    drop _u _keep
	*/
	
	gen has_wage = (incwage > 0)
	drop if missing(lnw)
	
    * (1) baseline
     reghdfe lnw i.same_sex##i.legal ///
        , vce(cluster statefip)
    eststo lpm1


    * (2) + demo
     reghdfe lnw i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan ///
        , vce(cluster statefip)
    eststo lpm2

    * (3) + edu
     reghdfe lnw i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
        , vce(cluster statefip)
    eststo lpm3

	
    * (5) + state & year FE 
     reghdfe lnw i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
        , absorb(statefip year) vce(cluster statefip)
    eststo lpm5

    * Export one table per sex per primary/secondary
    esttab lpm1 lpm2 lpm3 /*probit4*/ lpm5 using "${OUTPUT}/did_`plbl'_`slbl'.txt", ///
        replace se b(3) star(* 0.10 ** 0.05 *** 0.01) ///
        title("DID: Wage Intensive Margin, `=strproper("`plbl'")' , `=strproper("`slbl'")'") ///
        label stats(r2 N, fmt(3 0) labels("R-squared" "N"))
		
		
}
}






