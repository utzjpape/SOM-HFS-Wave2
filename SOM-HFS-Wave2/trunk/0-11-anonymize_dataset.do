*Process to anonymize the datasets 

set more off
set seed 23082380 
set sortseed 11042355


********************************************************************
*Generate random ID for each household
********************************************************************
use "${gsdData}/0-RawTemp/hh_for_anon.dta", clear
keep interview__id ea block_id team_id enum_id
gen rand = runiform()
sort ea interview__id
by ea: egen hh_anon = rank(rand)
save "${gsdTemp}/hh_anonkey.dta", replace


********************************************************************
*Generate random ID for each EA: take mean of random variable at the EA level
********************************************************************
collapse (mean) rand, by(ea)
egen ea_anon = rank(rand)
save "${gsdTemp}/ea_anonkey.dta", replace


********************************************************************
*Generate random ID for each block: take mean of random variable at the block level
********************************************************************
use "${gsdTemp}/hh_anonkey.dta", clear
collapse (mean) rand, by(block_id)
egen block_anon = rank(rand)
save "${gsdTemp}/block_anonkey.dta", replace


********************************************************************
*Generate random ID for each enumerator: take mean of random variable at enumerator level
********************************************************************
use "${gsdTemp}/hh_anonkey.dta", clear
collapse (mean) rand, by(enum_id)
egen enum_anon = rank(rand)
save "${gsdTemp}/enum_anonkey.dta", replace


********************************************************************
*Generate random ID for each team: take mean of random variable at the team level
********************************************************************
use "${gsdTemp}/hh_anonkey.dta", clear
collapse (mean) rand, by(team_id)
egen team_anon = rank(rand)
save "${gsdTemp}/team_anonkey.dta", replace


********************************************************************
*Anonymize hh data
********************************************************************
use "${gsdData}/0-RawTemp/hh_for_anon.dta", clear
merge 1:1 interview__id using "${gsdTemp}/hh_anonkey.dta", assert(match) keep(match master) keepusing(hh_anon) nogenerate
merge m:1 ea using "${gsdTemp}/ea_anonkey.dta", assert(match) keep(match master) keepusing(ea_anon) nogenerate
merge m:1 block_id using "${gsdTemp}/block_anonkey.dta", assert(match) keep(match master) keepusing(block_anon) nogenerate
merge m:1 enum_id using "${gsdTemp}/enum_anonkey.dta", assert(match) keep(match master) keepusing(enum_anon) nogenerate
merge m:1 team_id using "${gsdTemp}/team_anonkey.dta", assert(match) keep(match master) keepusing(team_anon) nogenerate
order region strata ea_anon block_anon hh_anon  enum_anon team_anon
drop team_id enum_id ea block_id
rename (hh_anon ea_anon enum_anon block_anon team_anon) (hh ea enum block team)
sort hh ea enum block
* Include analytical strata in line with Wave 1
gen astrata = 1 if ind_profile==6
replace astrata = 2 if inlist(strata,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24)
replace astrata = 3 if ind_profile==1
replace astrata = 4 if strata==43
replace astrata = 5 if inlist(strata, 39, 41)
replace astrata = 6 if strata==51
replace astrata = 7 if inlist(strata, 45, 49, 46, 47)
replace astrata = 8 if strata==26 | strata==28 |  strata==30
replace astrata = 9 if strata==31 | strata==33 |  strata==36
replace astrata = 10 if strata==52 | strata==54 |  strata==57
replace astrata = 11 if inlist(strata, 38, 40, 42)
replace astrata = 12 if inlist(strata, 44, 48, 50)
replace astrata = 13 if strata==25 | strata==27 |  strata==29
replace astrata = 14 if strata==32 | strata==34 |  strata==35
replace astrata = 15 if strata==53 | strata==55 |  strata==56
label def lastrata 1 "IDP" 2 "Nomadic" 3 "(u):Banadir"  4 "(u):Nugaal" 5 "(u):Bari+Mudug" 6 "(u):Woqooyi_Galbeed" 7 "(u):Awdal+Sanaag+Sool+Togdheer" 8 "(u):Hiraan+MiddleShabelle+Galgaduud" 9 "(u):Gedo+LowerJuba+MiddleJuba" 10 "(u):Bay+Bakool+LowerShabelle" 11 "(r):Bari+Mudug+Nugaal" 12 "(r):Awdal+Togdheer+Woqooyi" 13 "(r):Hiraan+MiddleShabelle+Galgaduud" 14 "(r):Gedo+LowerJuba+MiddleJuba" 15 "(r):Bay+Bakool+LowerShabelle", replace 
label values astrata lastrata
label  var team "Data Collection Team"
label var ea "EA ID"
label var block "Block ID"
label var hh "Household ID"
label var enum "ID of enumerator"
la var astrata "Analytical strata"
save "${gsdTemp}/hh_final.dta", replace


********************************************************************
*Anonymize hhm data
********************************************************************
use "${gsdData}/0-RawOutput/hhm_clean.dta", replace
merge m:1 interview__id using "${gsdTemp}/hh_final.dta", assert(match) keepusing(region strata ea block hh enum team astrata) nogenerate
order region strata ea block hh enum team
drop interview__id
save "${gsdData}/1-CleanInput/hhm.dta", replace
use "${gsdData}/0-RawOutput/hhm_separated_clean.dta", replace
merge m:1 interview__id using "${gsdTemp}/hh_final.dta", keep(match master) keepusing(region strata ea block hh enum team) nogenerate
order region strata ea block hh enum team
drop interview__id
save "${gsdData}/1-CleanInput/hhm_separated.dta", replace


********************************************************************
*Anonymize other sections of the survey
********************************************************************
foreach x in "nfood" "shocks" "food" "livestock" "livestock_pre" "motor" "assets" "assets_prev"  {
	use "${gsdData}/0-RawOutput/hh_`x'_clean.dta", replace
	merge m:1 interview__id using "${gsdTemp}/hh_final.dta", keep(match) keepusing(region strata ea block hh enum team astrata) nogenerate
	order region strata ea block hh enum team
	drop interview__id
	save "${gsdData}/1-CleanInput/`x'.dta", replace
}


*********************************************************************
* Save correspondence tables with GPS 
**********************************************************************
use "${gsdTemp}/hh_final.dta", clear
export delim interview__id region strata ea block hh lat_y long_x using "${gsdData}/0-RawTemp/Wave2_hh_coordinates.csv", replace
keep interview__id region strata ea block hh lat_y long_x
save "${gsdData}/0-RawTemp/Wave2_hh_coordinates.dta", replace


********************************************************************
* Drop identifying information from hh
********************************************************************
use "${gsdTemp}/hh_final.dta", clear
drop interview__id lat_y long_x n_str str_no_success n_str_no_success__* n_hh hh_no_success n_hh_no_success__*
drop n_bl n_ints int_no return EAs_toinclude Nb_itwstobeconducted Nb_blocks_EA Dummy_oneblock id_wp water_point water_point_confirm loc_wp__Latitude loc_wp__Longitude loc_wp__Accuracy loc_wp__Altitude loc_wp__Timestamp loc_wp_check hhid_nomad listing_round listing_day res_name phone original_hhid_nomad original_listing_round original_listing_day phone_to_call consent_tracking barcode_tracking tracking_phone_yn tracking_phone enum_name status_wp WPs_toinclude not_within_WP id_listing_day id_listing_round listing_day_original listing_round_original main_wp rank_rep_wp sample_initial_wp sample_final_wp o_wp o_wp_2 o_wp_3 r_wp final_main_wp final_rep_wp final_rank_rep_wp target_itw_wp nb_val_succ_itw_wp wp_status wp_valid nb_interviews_wp nb_treat1_wp nb_treat2_wp nb_treat3_wp nb_treat4_wp nb_valid_interviews_wp nb_valid_treat1_wp nb_valid_treat2_wp nb_valid_treat3_wp nb_valid_treat4_wp nb_success_interviews_wp nb_success_treat1_wp nb_success_treat2_wp nb_success_treat3_wp nb_success_treat4_wp nb_valid_success_itws_wp nb_valid_success_treat1_wp nb_valid_success_treat2_wp nb_valid_success_treat3_wp nb_valid_success_treat4_wp
save "${gsdData}/1-CleanInput/hh.dta", replace


**********************************************************************
* Take care of sharing data 
**********************************************************************
/*
* data export for sharing
cap mkdir "${gsdData}/0-RawOutput/SharedRawAnonymized"
drop weight
cap drop ind_profile astrata
label drop strata_id
* ".z" looks confusing in wholly numeric variables -> change it to standard missing 
ds, not(vallabel)
foreach var of varlist `r(varlist)' {
	cap recode `var' (.z = .)
}
export delim using "${gsdData}/0-RawOutput/SharedRawAnonymized/hh.csv", replace

foreach x in "hhm" "hhm_separated" "nfood" "shocks" "food" "livestock" "livestock_pre" "motor" "assets" "assets_prev" {
	use "${gsdData}/1-CleanInput/`x'.dta", clear
	merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", keep(match) keepusing(type) nogenerate
	label drop strata_id
	order type, after(region)
	ds, not(vallabel)
	foreach var of varlist `r(varlist)' {
		cap recode `var' (.z = .)
	}
	export delim using "${gsdData}/0-RawOutput/SharedRawAnonymized/`x'.csv", replace
}

	
cd "${gsdData}/0-RawOutput/SharedRawAnonymized"
zipfile *.csv, saving(SHFSw2_RawData)
