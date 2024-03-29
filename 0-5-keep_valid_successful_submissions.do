*Keep valid and successul submissions

set more off
set seed 23081920 
set sortseed 11041925


********************************************************************
*Prepare one dataset including nomads
********************************************************************
use "${gsdData}/0-RawTemp/hh_valid_keys_and_EAs.dta", clear
gen nomads=0
append using "${gsdData}/0-RawTemp/hh_valid_keys_and_WPs.dta", force
save "${gsdData}/0-RawTemp/hh_valid_keys_and_EAs_all.dta", replace

local files hh_roster_separated motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
qui foreach file in `files' {
    use "${gsdData}/0-RawTemp/`file'_manual_cleaning.dta", clear
	append using "${gsdData}/0-RawTemp/`file'_manual_cleaning_nomads.dta", force
	save "${gsdData}/0-RawTemp/`file'_manual_cleaning_all.dta", replace
}

* Include education data in hhm level data 
use "${gsdData}/0-RawTemp/hhroster_age_after_phone_survey.dta", clear
append using "${gsdData}/0-RawTemp/hhroster_age_nomads_after_phone_survey.dta", force
save "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning_all.dta", replace

********************************************************************
*Obtain keys for valid and successful submissions from valid EAs 
********************************************************************
use "${gsdData}/0-RawTemp/hh_valid_keys_and_EAs_all.dta", clear
keep interview__id itw_valid itw_invalid_reason successful_valid ea
*Drop submissions from EA which became urban settlement 
drop if ea==5309000
*Drop replacement submissions without record of the original household
drop if ea==160751 | ea==198061 
keep if successful_valid==1
keep interview__id 
save "${gsdTemp}/hh_id_successful_valid.dta", replace


********************************************************************
*Save hh datasets
********************************************************************
use "${gsdData}/0-RawTemp/hh_valid_keys_and_EAs_all.dta", clear
merge 1:1 interview__id using "${gsdTemp}/hh_id_successful_valid.dta", nogen keep(match)
save "${gsdData}/0-RawTemp/hh_valid_successful.dta", replace


********************************************************************
*Save the other modules
********************************************************************
local files hh_roster_separated hhroster_age motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
qui foreach file in `files' {
    use "${gsdData}/0-RawTemp/`file'_manual_cleaning_all.dta", clear
	merge m:1 interview__id using "${gsdTemp}/hh_id_successful_valid.dta", nogen keep(match)
	save "${gsdData}/0-RawTemp/`file'_valid_successful.dta", replace
}

