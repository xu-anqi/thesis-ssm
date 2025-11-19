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
global OUTPUT   = "$DIR/output/assumption_test"			// path for output
/*-----------------------------------------------------------------------------------
			/* Load Data */
-----------------------------------------------------------------------------------*/
* use "$DATA/subsample.dta", clear



*===========================
* 1) DID
*===========================	

* Loop over sex: 1 = men, 2 = women
foreach s in 1 {
    local slbl = cond(`s'==1, "men", "women")
    eststo clear
	
	use "$DATA/cohabit_data.dta", clear
	
	*
	gen double _u = runiform()
    bysort statefip year: gen byte _keep = _u < 0.0010    // ~0.1% per state-year
    keep if _keep
    drop _u _keep
	*/
	
	gen has_supply = (hours_year > 0)
	keep if sex == `s'
	


}

    * (3) + edu
hetprobit has_supply i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		, het(age nchild i.race i.hispan i.edu) ///
         vce(cluster statefip)
		 
		 
testparm age nchild i.race i.hispan i.edu, eq(#2)
	





