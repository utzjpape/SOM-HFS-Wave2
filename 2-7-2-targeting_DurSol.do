*Identify vulnerable households 

set more off
set seed 23081980 
set sortseed 11041955




***************************************
* Obtain poor status excluding aid
***************************************

*Identify items consumed but the majority received free/gift from /NGO/aid/Government (i.e.not own production)
use "${gsdData}/1-CleanOutput/food.dta", clear
rename itemid foodid 
merge 1:1 strata ea block hh foodid using "${gsdData}/1-CleanInput/food.dta", nogen keep(master match) keepusing(free free_q free_main)
keep if free==1 & free_q>2 & free_main!=0
collapse (sum) cons_usd_imp, by(strata ea block hh)
save "${gsdTemp}/free_food.dta", replace

*Open the HH dataset
use "${gsdData}/1-CleanOutput/hh.dta", clear
merge 1:1 strata ea block hh using "${gsdTemp}/free_food.dta", nogen keep(master match)
merge m:1 astrata using "${gsdData}/1-CleanTemp/food-deflator.dta", nogen assert(match) keep(match)

*Convert to pc pd as tc_imp
replace cons_usd_imp=((cons_usd_imp/hhsize)/7)/deflator


*Get total consumption without free food items
gen share_free=cons_usd_imp/tc_imp
gen coeff=1-share_free
gen tc_imp_free=coeff*tc_imp

*Obtain poverty rate without free food items
gen poorPPP_free=(tc_imp_free<plinePPP) if !missing(tc_imp_free)
replace poorPPP_free=poorPPP if tc_imp_free>=.
label values poorPPP_free lpoor
gen pweight=hhsize*weight
svyset ea [pw=pweight], strata(strata)
svy: mean poorPPP
svy: mean poorPPP_free
save "${gsdTemp}/working-file_targeting.dta", replace


***************************************
* Identify vulnerable households
***************************************

*Produce HH level variables for the HH head
use "${gsdData}/1-CleanOutput/hhm.dta", clear
keep if ishead==1
gen hhh_disabled=(hhm_edu_reason==5 |  hhm_job_search_no==2 |  hhm_job_obs==5)
keep strata ea block hh  hhh_disabled
save "${gsdTemp}/hh_head.dta", replace

*HH member variables needed
use "${gsdData}/1-CleanOutput/hhm.dta", clear
gen disabled=(hhm_edu_reason==5 |  hhm_job_search_no==2 |  hhm_job_obs==5)
gen adult_work_age=(age>=15 & age<=64)
replace adult_work_age=0 if disabled==1
collapse (sum) disabled adult_work_age, by(strata ea block hh)
save "${gsdTemp}/hh_composition.dta", replace

*Integrate the data
use "${gsdTemp}/working-file_targeting.dta", clear
merge 1:m strata ea block hh  using "${gsdTemp}/hh_head.dta", nogen assert(match)
merge 1:m strata ea block hh  using "${gsdTemp}/hh_composition.dta", nogen assert(match)


*Identify vulnerable households
gen vulnerable=1 if (adult_work_age==0) | (adult_work_age==1 & hhh_gender==2 & hhh_age>=15 & hhh_age<=64)
replace vulnerable=2 if poorPPP_free==1 & vulnerable>=.
replace vulnerable=3 if vulnerable>=.
label define lvulnerable 1 "Vulnerable" 2 "Poor but productive" 3 "Self-reliant"
label values vulnerable lvulnerable



***************************************
* Analysis of vulnerable households
***************************************
svyset ea [pweight=weight], strata(strata) singleunit(centered)
keep if type_idp_host<.

qui tabout vulnerable using "${gsdOutput}/Raw_Targeting.xls", svy percent c(col lb ub) npos(col) replace h1("Groups") f(4) 

local label : variable label type_idp_host
qui tabout type_idp_host vulnerable using "${gsdOutput}/Raw_Targeting.xls", svy percent c(col lb ub) npos(col) append h1("`label'") f(4) 
local label : variable label reg_pess
qui tabout reg_pess vulnerable if type==3 using "${gsdOutput}/Raw_Targeting.xls", svy percent c(col lb ub) npos(col) append h1("`label'") f(4) 

local label : variable label type_idp_host
qui tabout vulnerable type_idp_host using "${gsdOutput}/Raw_Targeting.xls", svy percent c(col lb ub) npos(col) append h1("`label'") f(4) 
local label : variable label reg_pess
qui tabout vulnerable reg_pess if type==3 using "${gsdOutput}/Raw_Targeting.xls", svy percent c(col lb ub) npos(col) append h1("`label'") f(4) 

insheet using "${gsdOutput}/Raw_Targeting.xls", clear nonames
export excel using "${gsdOutput}/Figures_targeting_v1.xlsx", sheetreplace sheet("Raw_Cause") 
rm "${gsdOutput}/Raw_Targeting.xls"

