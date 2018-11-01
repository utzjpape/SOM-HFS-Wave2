*Identify vulnerable households 

set more off
set seed 23081980 
set sortseed 11041955




***************************************
* Obtain poor status excluding aid
***************************************

*Identify items consumed but the majority received free/gift from /NGO/aid/Government (i.e.not own production)
use "${gsdData}/1-CleanOutput/food.dta", clear
keep if D_8_free_yn==1 & D_9_free_quant>2 & D_10_free_main!=0
keep StrataID ea hh cons_value_org cons_value_fin

*Correct issue from the pipeline
replace cons_value_fin=cons_value_org if cons_value_fin>=.
collapse (sum) cons_value_fin, by(StrataID ea hh)
save "${gsdTemp}/free_food.dta", replace

*Open the HH dataset
use "${gsdData}/1-CleanOutput/hhq.dta", clear
merge 1:1 StrataID ea hh using "${gsdTemp}/free_food.dta", nogen keep(master match)

*Convert to pc pd Oct17 Birr as tc_imp
replace cons_value_fin=(cons_value_fin/hhsize)/7

*Get total consumption without free food items
gen share_free=cons_value_fin/tc_imp
gen coeff=1-share_free
gen tc_imp_free=coeff*tc_imp

*Obtain poverty rate without free food items
gen poorPPP_free=(tc_imp_free<plinePPP) if !missing(tc_imp_free)
replace poorPPP_free=poor if tc_imp_free>=.
label values poorPPP_free lpoor
gen pweight=hhsize*weight
svyset ea [pw=pweight], strata(strata)
svy: mean poor
svy: mean poorPPP_free
save "${gsdTemp}/working-file_targeting.dta", replace


***************************************
* Identify vulnerable households
***************************************

*Produce HH level variables for the HH head
use "${gsdData}/1-CleanOutput/hhm.dta", clear
keep if ishead==1
gen hhh_disabled=(B_32_hhm_edu_reason==3 |  B_61_hhm_job_search_no==2 |  B_66_hhm_job_obs==6)
rename (B_1_hhm_age B_6_hhm_gender literacy enrolled edu_level_g_jc status) (hhh_age hhh_gender hhh_literacy hhh_school hhh_edu_level hhh_emp_status)
keep StrataID ea hh hhh_age hhh_gender hhh_literacy hhh_school hhh_edu_level hhh_emp_status hhh_disabled
save "${gsdTemp}/hh_head.dta", replace

*HH member variables needed
use "${gsdData}/1-CleanOutput/hhm.dta", clear
gen disabled=(B_32_hhm_edu_reason==3 |  B_61_hhm_job_search_no==2 |  B_66_hhm_job_obs==6)
gen adult_work_age=(B_1_hhm_age>=15 & B_1_hhm_age<=64)
replace adult_work_age=0 if disabled==1
collapse (sum) disabled adult_work_age, by(StrataID ea hh)
save "${gsdTemp}/hh_composition.dta", replace

*Integrate the data
use "${gsdTemp}/working-file_targeting.dta", clear
merge 1:m StrataID ea hh using "${gsdTemp}/hh_head.dta", nogen assert(match)
merge 1:m StrataID ea hh using "${gsdTemp}/hh_composition.dta", nogen assert(match)


*Identify vulnerable households
gen vulnerable=1 if (adult_work_age==0) | (adult_work_age==1 & hhh_gender==2 & hhh_age>=15 & hhh_age<=64)
replace vulnerable=2 if poorPPP_free==1 & vulnerable>=.
replace vulnerable=3 if vulnerable>=.
label define lvulnerable 1 "Vulnerable" 2 "Poor but productive" 3 "Self-reliant"
label values vulnerable lvulnerable



***************************************
* Analysis of vulnerable households
***************************************
svyset ea [pw=weight], strata(strata)
recode origin_country (1=5 "South Sudan & other") (1000=5) (2=2 "Somalia") (4=3 "Eritrea") (5=4 "Sudan") (.z=1 "Host"), gen (host_refugee_country)
qui tabout vulnerable using "${gsdOutput}/Raw_Targeting.xls", svy percent c(col lb ub) npos(col) replace h1("Groups") f(4) 
foreach var in Refugee camp_ref host_refugee_country {
	local label : variable label `var'
	qui tabout `var' vulnerable using "${gsdOutput}/Raw_Targeting.xls", svy percent c(col lb ub) npos(col) append h1("`label'") f(4) 
}
foreach var in Refugee camp_ref host_refugee_country {
	local label : variable label `var'
	qui tabout vulnerable `var' using "${gsdOutput}/Raw_Targeting.xls", svy percent c(col lb ub) npos(col) append h1("`label'") f(4) 
}
insheet using "${gsdOutput}/Raw_Targeting.xls", clear nonames
export excel using "${gsdOutput}/Figures_targeting_v1.xlsx", sheetreplace sheet("Raw_Cause") 
rm "${gsdOutput}/Raw_Targeting.xls"

