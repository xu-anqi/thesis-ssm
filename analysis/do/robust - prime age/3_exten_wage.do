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
global OUTPUT   = "$DIR/output/robust-prime"			// path for output
/*-----------------------------------------------------------------------------------
			/* Load Data */
-----------------------------------------------------------------------------------*/
* use "$DATA/subsample.dta", clear



*===========================
* 1) DID
*===========================	

* Loop over sex: 1 = men, 2 = women
foreach s in 1 2 {
    local slbl = cond(`s'==1, "men", "women")
    eststo clear
	
	use "$DATA/cohabit_data.dta", clear
	drop if age < 25
	drop if age > 54
	/*
	gen double _u = runiform()
    bysort statefip year: gen byte _keep = _u < 0.0010    // ~0.1% per state-year
    keep if _keep
    drop _u _keep
	*/
	
	gen has_wage = (incwage > 0)
	keep if sex == `s'
	
    * (1) baseline
     probit has_wage i.same_sex##i.legal ///
        , vce(cluster statefip)
    eststo probit1
	margins r.same_sex, dydx(legal) post
	estimates store ame1


    * (2) + demo
     probit has_wage i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan ///
        , vce(cluster statefip)
    eststo probit2
	margins r.same_sex, dydx(legal) post
	estimates store ame2

    * (3) + edu
     probit has_wage i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
        , vce(cluster statefip)
    eststo probit3
	margins r.same_sex, dydx(legal) post
	estimates store ame3

	
    * (5) + state & year FE 
     probit has_wage i.same_sex##i.legal age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu ///
		i. statefip i.year ///
        , vce(cluster statefip)
    eststo probit5
	margins r.same_sex, dydx(legal) post
	estimates store ame5


    * Export one table per sex
    esttab probit1 probit2 probit3 /*probit4*/ probit5 using "${OUTPUT}/exten_`slbl'.txt", ///
        replace se b(3) star(* 0.10 ** 0.05 *** 0.01) ///
        title("DID: Wage, Extensive Margin `=strproper("`slbl'")'") ///
        label stats(ll r2_p r2 N, fmt(2 3 3 0) labels("Log-Likelihood" "Pseudo R-squared" "R-squared" "N"))
		
		
		esttab ame1 ame2 ame3 ame5 ///
		using "${OUTPUT}/ame_`slbl'.txt", ///
		replace b(3) se star(* 0.10 ** 0.05 *** 0.01) ///
		title("AME: Wage `=strproper("`slbl'")'") ///
		label nodepvars nonumber
		
}







