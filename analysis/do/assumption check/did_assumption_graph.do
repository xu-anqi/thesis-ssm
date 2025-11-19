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
foreach s in 1 {
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




***********************************************
* check parallel pre-trend (binscatter)
***********************************************


* Create a categorical variable combining type_employment & post2006
gen group = same_sex * 2 + legal
label define group_lbl 0 "Different-sex (Pre)" 1 "Different-sex (Post)" ///
                      2 "Same-sex (Pre)" 3 "Same-sex (Post)"
label values group group_lbl

* Binscatter with separate trends before and after 2006
binscatter lnw relt, by(group) ///
    lcolor(blue blue orange orange) ///
    title("Parallel Trends Assumption") ///
    xtitle("Relative Year") ytitle("log of wage") ///
    legend(order(1 "Different-sex (Pre)" 2 "Different-sex (Post)" ///
                 3 "Same-sex (Pre)" 4 "Same-sex (Post)")) ///
    xlabel(, angle(45)) xline(0, lcolor(red) lpattern(shortdash) lwidth(medium))
graph export "${OUTPUT}/parallel2.png", replace



* Binscatter with controls
binscatter lnw relt, by(group) ///
    lcolor(blue blue orange orange) ///
	controls(age age_sq nchild ///
        i.nchlt5 i.race i.hispan i.edu) ///
    title("Conditional Parallel Trends Assumption") ///
    xtitle("Relative Year") ytitle("log of wage") ///
    legend(order(1 "Different-sex (Pre)" 2 "Different-sex (Post)" ///
                 3 "Same-sex (Pre)" 4 "Same-sex (Post)")) ///
    xlabel(, angle(45)) xline(0, lcolor(red) lpattern(shortdash) lwidth(medium))
graph export "${OUTPUT}/parallel3.png", replace


***********************************************
* check parallel pre-trend (unconditional)
***********************************************
drop if missing(lnw)


collapse (mean) lnw (sd) lnw_sd=lnw (count) N = lnw, by(relt same_sex)
gen upper = lnw + 1.96 * (lnw_sd / sqrt(N))
gen lower = lnw - 1.96 * (lnw_sd / sqrt(N))

twoway (rarea lower upper relt if same_sex == 0, color(blue%20)) ///
       (line lnw relt if same_sex == 0, lcolor(blue) lpattern(solid)) ///
       (rarea lower upper relt if same_sex == 1, color(orange%20)) ///
       (line lnw relt if same_sex == 1, lcolor(orange) lpattern(dash)) ///
       , xline(0, lcolor(red) lpattern(shortdash) lwidth(medium)) ///
       title("Average log of wage") ///
       xtitle("Relative Year") ytitle("Log(wage)") ///
       legend(order(2 "Different-sex (Control)" 4 "Same-esex (Treated)")) ///
       xlabel(, angle(45))
graph export "${OUTPUT}/parallel1.png", replace
exit

*/



exit



binscatter if_savings syear, ///
	by(group) ///
	controls(age female i.migback married hh_size nchild full_time years_employ ///
	education_years) ///
    lcolor(blue blue orange orange) ///
    title("Conditional Parallel Trends Assumption: Proportion with Savings") ///
    xtitle("Year") ytitle("Proportion with Savings") ///
    legend(order(1 "Self-Employed (Pre-2006)" 2 "Self-Employed (Post-2006)" ///
                 3 "Employee (Pre-2006)" 4 "Employee (Post-2006)")) ///
    xlabel(, angle(45)) xline(2006, lcolor(red) lpattern(shortdash) lwidth(medium))
graph export "${OUT_OUTPUT}parallel_if3.png", replace


*** amount saved (excluding 0) ***

* Filter people who always save
gen has_zero = (if_savings == 0)
bysort hid (syear): egen any_zero = max(has_zero)
drop if any_zero == 1

drop if if_savings == .
drop if savings_amount == .

* Binscatter with separate trends before and after 2006
binscatter savings_amount syear, by(group) ///
    lcolor(blue blue orange orange) ///
    title("Parallel Trends Assumption: Amount Saved") ///
    xtitle("Year") ytitle("amount saved") ///
    legend(order(1 "Self-Employed (Pre-2006)" 2 "Self-Employed (Post-2006)" ///
                 3 "Employee (Pre-2006)" 4 "Employee (Post-2006)")) ///
    xlabel(, angle(45)) xline(2006, lcolor(red) lpattern(shortdash) lwidth(medium))
graph export "${OUT_OUTPUT}parallel_amount2.png", replace

* Binscatter with controls
binscatter savings_amount syear, ///
	controls(age female i.migback married hh_size nchild full_time years_employ ///
	education_years) ///
	by(group) ///
    lcolor(blue blue orange orange) ///
    title("Conditional Parallel Trends Assumption: Amount Saved") ///
    xtitle("Year") ytitle("amount saved") ///
    legend(order(1 "Self-Employed (Pre-2006)" 2 "Self-Employed (Post-2006)" ///
                 3 "Employee (Pre-2006)" 4 "Employee (Post-2006)")) ///
    xlabel(, angle(45)) xline(2006, lcolor(red) lpattern(shortdash) lwidth(medium))
graph export "${OUT_OUTPUT}parallel_amount3.png", replace



*** log amount saved (excluding 0) ***


gen log_savings = log(savings_amount)

* Binscatter with separate trends before and after 2006
binscatter log_savings syear, by(group) ///
    lcolor(blue blue orange orange) ///
    title("Parallel Trends Assumption: Log Amount Saved") ///
    xtitle("Year") ytitle("log amount saved") ///
    legend(order(1 "Self-Employed (Pre-2006)" 2 "Self-Employed (Post-2006)" ///
                 3 "Employee (Pre-2006)" 4 "Employee (Post-2006)")) ///
    xlabel(, angle(45)) xline(2006, lcolor(red) lpattern(shortdash) lwidth(medium))
graph export "${OUT_OUTPUT}parallel_log_amount2.png", replace


* Binscatter with controls
binscatter log_savings syear, ///
	controls(age female i.migback married hh_size nchild full_time years_employ ///
	education_years) ///
	by(group) ///
    lcolor(blue blue orange orange) ///
    title("Conditional Parallel Trends Assumption: Log Amount Saved") ///
    xtitle("Year") ytitle("log amount saved") ///
    legend(order(1 "Self-Employed (Pre-2006)" 2 "Self-Employed (Post-2006)" ///
                 3 "Employee (Pre-2006)" 4 "Employee (Post-2006)")) ///
    xlabel(, angle(45)) xline(2006, lcolor(red) lpattern(shortdash) lwidth(medium))
graph export "${OUT_OUTPUT}parallel_log_amount3.png", replace



*** saving rate (excluding 0) ***

keep if savings_amount != 0 & !missing(savings_amount)
drop if household_income <= 0
drop if missing(household_income)
gen saving_rate = savings_amount/household_income

* Binscatter with separate trends before and after 2006
binscatter saving_rate syear, by(group) ///
    lcolor(blue blue orange orange) ///
    title("Parallel Trends Assumption: Saving Rate") ///
    xtitle("Year") ytitle("saving rate") ///
    legend(order(1 "Self-Employed (Pre-2006)" 2 "Self-Employed (Post-2006)" ///
                 3 "Employee (Pre-2006)" 4 "Employee (Post-2006)")) ///
    xlabel(, angle(45)) xline(2006, lcolor(red) lpattern(shortdash) lwidth(medium))
graph export "${OUT_OUTPUT}parallel_saving_rate2.png", replace

* Binscatter with controls
binscatter saving_rate syear, ///
	controls(age female i.migback married hh_size nchild full_time years_employ ///
	education_years) ///
	by(group) ///
    lcolor(blue blue orange orange) ///
    title("Conditional Parallel Trends Assumption: Saving Rate") ///
    xtitle("Year") ytitle("saving rate") ///
    legend(order(1 "Self-Employed (Pre-2006)" 2 "Self-Employed (Post-2006)" ///
                 3 "Employee (Pre-2006)" 4 "Employee (Post-2006)")) ///
    xlabel(, angle(45)) xline(2006, lcolor(red) lpattern(shortdash) lwidth(medium))
graph export "${OUT_OUTPUT}parallel_saving_rate3.png", replace

log close
