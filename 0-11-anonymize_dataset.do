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
label  var team "Data Collection Team"
label var ea "EA ID"
label var block "Block ID"
label var hh "Household ID"
label var enum "ID of enumerator"
save "${gsdTemp}/hh_final.dta", replace


********************************************************************
*Anonymize hhm data
********************************************************************
use "${gsdData}/0-RawOutput/hhm_clean.dta", replace
merge m:1 interview__id using "${gsdTemp}/hh_final.dta", assert(match) keepusing(region strata ea block hh enum team) nogenerate
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
	merge m:1 interview__id using "${gsdTemp}/hh_final.dta", keep(match) keepusing(region strata ea block hh enum team) nogenerate
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
