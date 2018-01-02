*Check the completeness of submissions between parent and child files
 
set more off
set seed 23081650 
set sortseed 11041895


********************************************************************
*Check all the different sections of the survey agains the parent file
********************************************************************

*Household roster files
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/hhroster_age_valid_successful.dta", nogen assert(match)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/hh_roster_separated_valid_successful.dta", nogen keep(master match)
 
*Motor
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/motor_valid_successful.dta", nogen assert(match master)

*Assets
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/ra_assets_valid_successful.dta", nogen keep(master match)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/ra_assets_prev_valid_successful.dta", nogen keep(match master)

*Food items
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_valid_successful.dta", nogen keep(match master)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_cereals_valid_successful.dta", nogen keep(match master)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_fruit_valid_successful.dta", nogen keep(match master)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_meat_valid_successful.dta", nogen keep(match master)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_vegetables_valid_successful.dta", nogen keep(match master)
  
*Non-food items
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rnf_nonfood_valid_successful.dta", nogen assert(match)
 
*Livestock
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rl_livestock_valid_successful.dta", nogen keep(match master)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rl_livestock_pre_valid_successful.dta", nogen keep(match master)

*Shocks
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/shocks_valid_successful.dta", nogen keep(match master)


********************************************************************
*Check incomplete submissions
********************************************************************
*Food items
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_valid_successful.dta"
keep if _merge==1
drop _merge
save "${gsdTemp}/check_incomplete_food1.dta", replace
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_cereals_valid_successful.dta"
keep if _merge==1
drop _merge
save "${gsdTemp}/check_incomplete_food2.dta", replace
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_fruit_valid_successful.dta"
keep if _merge==1
drop _merge
save "${gsdTemp}/check_incomplete_food3.dta", replace
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_meat_valid_successful.dta"
keep if _merge==1
drop _merge
save "${gsdTemp}/check_incomplete_food4.dta", replace
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_vegetables_valid_successful.dta"
keep if _merge==1
drop _merge
save "${gsdTemp}/check_incomplete_food5.dta", replace

*Non-food items
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rnf_nonfood_valid_successful.dta"
keep if _merge==1
drop _merge
save "${gsdTemp}/check_incomplete_nfood.dta", replace

*Assets
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/ra_assets_valid_successful.dta"
keep if _merge==1
drop _merge
save "${gsdTemp}/check_incomplete_assets.dta", replace

*Identify incomplete submissions
use "${gsdTemp}/check_incomplete_food1.dta", clear
merge 1:1 interview__id using "${gsdTemp}/check_incomplete_food2.dta", nogen keep(match)
merge 1:1 interview__id using "${gsdTemp}/check_incomplete_food3.dta", nogen keep(match)
merge 1:1 interview__id using "${gsdTemp}/check_incomplete_food4.dta", nogen keep(match)
merge 1:1 interview__id using "${gsdTemp}/check_incomplete_food5.dta", nogen keep(match)
keep interview__id
save "${gsdTemp}/incomplete_hhs.dta", replace


********************************************************************
*Introduce corrections
********************************************************************
local files hh hh_roster_separated hhroster_age motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
qui foreach file in `files' {
    use "${gsdData}/0-RawTemp/`file'_valid_successful.dta", clear
	
	*Drop incomplete submissions with no information on food consumption 
	merge m:1 interview__id using "${gsdTemp}/incomplete_hhs.dta"
	drop if _merge==3
	drop _merge
	
	*Drop incomplete submissions with missing values on food and household roster
	drop if interview__id=="07d72a3e85fa4bae962a6b974d48cc5f"

    save "${gsdData}/0-RawTemp/`file'_valid_successful_complete.dta", replace
}

