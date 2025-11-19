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
global OUTPUT   = "$DIR/output/mech-kid/exten"			// path for output
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
	
	drop if missing(nchild)
	gen has_kid = (nchild > 0)
	keep if has_kid == `p'

	/*
	gen double _u = runiform()
    bysort statefip year: gen byte _keep = _u < 0.0010    // ~0.1% per state-year
    keep if _keep
    drop _u _keep
	*/
	
	gen has_wage = (incwage > 0)
	
    * (1) baseline
     probit has_wage i.same_sex##i.legal ///
        /*[pweight = perwt]*/, vce(cluster statefip)
    eststo probit1


    * (2) + demo
     probit has_wage i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan ///
        /*[pweight = perwt]*/, vce(cluster statefip)
    eststo probit2

    * (3) + edu
     probit has_wage i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
        /*[pweight = perwt]*/, vce(cluster statefip)
    eststo probit3
	

	
    * (5) + state & year FE 
     probit has_wage i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i. statefip i.year ///
        /*[pweight = perwt]*/, vce(cluster statefip)
    eststo probit5

    * Export one table per sex
    esttab probit1 probit2 probit3 /*probit4*/ probit5 using "${OUTPUT}/did_`plbl'_`slbl'.txt", ///
        replace se b(3) star(* 0.10 ** 0.05 *** 0.01) ///
        title("DID: Wage, Extensive Margin, `=strproper("`plbl'")'  `=strproper("`slbl'")'") ///
        label stats(ll r2_p r2 N, fmt(2 3 3 0) labels("Log-Likelihood" "Pseudo R-squared" "R-squared" "N"))
}
}






