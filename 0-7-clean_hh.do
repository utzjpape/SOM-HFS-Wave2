*Clean and organize parent file

set more off
set seed 23081982 
set sortseed 11041952

use "${gsdData}/0-RawTemp/hh_valid_successful_complete.dta", clear

********************************************************************
*Include the correct strata
********************************************************************
rename ea psu_id
merge m:1 psu_id using "${gsdDataRaw}/List_Strata_EAs.dta", nogen keep(master match) keepusing(strata_name_list strata_id_list)
rename psu_id ea
labmask strata_id, values(strata_name)
drop strata strata_name_list strata_id_list
rename strata_id strata
order strata strata_name type_pop, after(loc_check_barcode)
label define strata_id 8 "Nomad: Central Regions" 9 "Nomad: Galmudug" 10 "Nomad: Jubaland" 12 "Nomad: Puntland" 13 "Nomad: Somaliland" 14 "Nomad: South West", modify

********************************************************************
*Include the correct type of population 
********************************************************************
drop type
gen type=1 if (type_pop=="Urban/Rural" | type_pop=="Urban/Rural and Host" | type_pop=="Host Only") & inlist(strata,26,28,30,31,33,37,39,41,43,45,49,51,52,54,57)
replace type=2 if (type_pop=="Urban/Rural" | type_pop=="Urban/Rural and Host") & inlist(strata,25,27,29,32,34,38,40,42,44,48,50,53,55,56)
replace type=3 if type_pop=="IDP" & inlist(strata,1,2,3,4,5,6,7)
replace type=4 if nomads==.
label define type_hh 1 "Urban" 2 "Rural" 3 "IDP" 4 "Nomads"
label values type type_hh
label var type "Urban/Rural/IDP or Nomad"
drop nomad
*Generate a separate indicators for host and IDPs
gen type_idp_host=1 if type==3
replace type_idp_host=2 if type_pop=="Host Only"
replace type_idp_host=.z if type_idp_host==.
label define type_idp 1 "IDP" 2 "Host Community" .z "Not applicable"
label values type_idp_host type_idp
label var type_idp_host "IDP or Host Community"
drop type_pop
save "${gsdTemp}/hh_valid_successful_complete.dta", replace
* Identify urban and rural households in combined urban and rural strata (using ArcMap created table)
import delim "${gsdDataRaw}/sool_sanaag_urban_PSUs.txt", clear 
ren psu_id ea 
keep ea 
la var ea "EA"
merge 1:m ea using "${gsdTemp}/hh_valid_successful_complete.dta", keep(using match) gen(urban_ind)
replace type=1 if urban_ind==3 & inlist(strata,46,47)
replace type=2 if urban_ind==2 & inlist(strata,46,47)
drop urban_ind 

*Correctly identify host households for EAs with interviews for both urban/rural and host 
*EA 198455 1 urban replacement and 1 replacement host 
*EA not used (not part of the final sample)

*EA 199580 1 replacement urband and 2 replacement host
replace type_idp_host=2 if ea==199580

*EA 199572 1 replacement urband and 1 main host
replace type_idp_host=2 if ea==199572

*EA 199578 1 replacement urband and 1 main host
replace type_idp_host=2 if ea==199578

*EA 199582 1 replacement urband and 1 main host
replace type_idp_host=2 if ea==199582

*EA 198804 3 main urband and 1 main host
gen rand_198804=uniform() if ea==198804
sort rand_198804
gen n_198804=_n if ea==198804
replace type_idp_host=2 if ea==198804 & n_198804<=12
drop rand_198804 n_198804

*EA 205188 1 replacement urband and 1 main host
gen rand_205188=uniform() if ea==205188
sort rand_205188
gen n_205188=_n if ea==205188
replace type_idp_host=2 if ea==205188 & n_205188<=12
drop rand_205188 n_205188

*EA 198980 1 replacement urband and 1 main host
replace type_idp_host=2 if ea==198980

*EA 198902 1 replacement urband and 1 replacement host
replace type_idp_host=2 if ea==198902

*EA 199371 1 main urban and 1 main host
gen rand_199371=uniform() if ea==199371
sort rand_199371
gen n_199371=_n if ea==199371
replace type_idp_host=2 if ea==199371 & n_199371<=12
drop rand_199371 n_199371

*EA 202154 1 replacement urband and 1 main host
replace type_idp_host=2 if ea==202154

*EA 202160 1 replacement urband and 1 main host
replace type_idp_host=2 if ea==202160

*EA 198058 3 replacement urband and 1 main host
replace type_idp_host=2 if ea==198058

*EA 198082 3 main urband and 1 main host
gen rand_198082=uniform() if ea==198082
sort rand_198082
gen n_198082=_n if ea==198082
replace type_idp_host=2 if ea==198082 & n_198082<=12
drop rand_198082 n_198082

*EA 198009 3 main urband and 1 main host
gen rand_198009=uniform() if ea==198009
sort rand_198009
gen n_198009=_n if ea==198009
replace type_idp_host=2 if ea==198009 & n_198009<=12
drop rand_198009 n_198009

*EA 198004 3 main urband (replaced with EA 198057) and 1 main host (replaced with
replace type_idp_host=2 if ea==204882

*EA 198121 3 replacement urband and 1 replacement host
*EA not used (not part of the final sample)

*EA 198038 3 main urband and 2 main host
gen rand_198038=uniform() if ea==198038
sort rand_198038
gen n_198038=_n if ea==198038
replace type_idp_host=2 if ea==198038 & n_198038<=24
drop rand_198038 n_198038


********************************************************************
*Include lables for variables without them
********************************************************************
label var interview__id "Unique Household ID" 
label var block_id "Block" 
label var nadults "No. Adults in household"
label var water_home "Household has water at home"
label var electricity "Household has electricity"
label var migr_idp "IDP or displaced household"

*Include correct figure for household size
drop nhhm 
preserve 
use "${gsdData}/0-RawTemp/hhroster_age_valid_successful_complete.dta", clear
*Drop incomplete household member responses
drop if hhm_age<0 & hhm_gender<0 & hhm_relation<0
bys interview__id: gen no_hhm=_n
collapse (max) hhsize=no_hhm, by(interview__id)
save "${gsdTemp}/hhsize.dta", replace
restore
merge 1:1 interview__id using "${gsdTemp}/hhsize.dta", nogen assert(match)
label var hhsize "Household size"

*Order variables
order interview__id team_id enum_id ea_reg strata type type_idp_host ea block_id
order mod_opt hhsize nadults , after(n_ints)

*Rename variables 
rename return1 return


********************************************************************
*Check skip patterns: please refer to the questionnaire for relevat conditions
********************************************************************
*migr_disp_past
assert mi(migr_disp_past) if !(no_success==0 & migr_disp==0)
*migr_disp
assert migr_disp==1 if  migr_disp==1
*no_success
assert mi(fishing_yn) if !(no_success==0)
assert !mi(hhr_id)
assert !mi(hhh_id0)
assert mi(hhh_absence_reason) if !(hhh_presence==0)
foreach v of varlist housingtype tenure drink_water do_treat electricity_grid cook toilet share_facility waste ///
    floor_material roof_material tmarket tedu thealth acc_road street_light phone_network2 acc_legal acc_trans acc_int {
	assert !mi(`v') 	
}
*assert mi(housingtype_s) if housingtype != 1000
assert mi(land_own_dur_n_main) if tenure != 1
assert mi(land_legal_main) if tenure != 1
assert mi(land_legal_main_d) if land_legal_main != 1
assert !mi(tenant_legal) if inlist(tenure,2,5)
*assert mi(drink_water_spec) if drink_water != 1000
destring cook_source_sp, replace
assert mi(cook_source_sp) if cook_source != 1000
assert mi(treat_water) if do_treat != 1
*assert mi(spec_water_spec) if treat_water != 1000
assert mi(light) if electricity_grid != 0
*assert mi(light_sp) if light != 1000
assert mi(electricity_phone) if electricity != 1
assert mi(electricity_choice) if electricity_grid != 1
assert mi(electricity_meter) if electricity_grid != 1
assert mi(electricity_fee) if electricity_meter != 0 & electricity_grid != 1
assert mi(electricity_meter) if electricity_grid != 1
assert mi(electricity_price_perception) if electricity_grid != 1
assert mi(electricity_hours) if electricity != 1
assert mi(electricity_blackout) if !(electricity_hours>16)
*assert mi(toilet_ot) if toilet != 1000
assert mi(share_num) if share_facility != 1
assert mi(sewage) if !inlist(toilet,3,4,5,7)
*assert mi(sewage_spec) if sewage != 1000
*assert mi(waste_spec) if waste != 1000
*assert mi(floor_material_sp) if floor_material != 1000
*assert mi(roof_material_sp) if roof_material != 1000
assert mi(acc_road_use) if !(acc_road>0)
*foreach v of varlist housingtype_disp - roof_material_disp {
*	assert mi(`v') if migr_idp != 1
*}
*assert mi(housingtype_disp_s) if housingtype_disp != 1000
assert mi(land_legal_main_disp) if !inlist(tenure_disp,1,2,3)
assert mi(land_legal_main_disp_d) if land_legal_main_disp != 1
*assert mi(land_use_disp_s) if land_use_disp__1000 != 1
assert mi(land_res_disp) if land_use_disp__7 != 1
assert mi(land_help_disp) if land_res_disp != 1
destring land_help_disp_spec, replace
*assert mi(land_help_disp_spec) if land_help_disp != 1000
assert mi(land_res_reason_disp) if land_res_disp != 0
*assert mi(land_res_reason_disp_spec) if land_res_reason_disp != 1000
*assert mi(drink_source_disp_sp) if drink_source_disp != 1000
*Agricultural land
assert !mi(land_access_yn)
assert mi(land_unit) if land_access_yn != 1
*assert mi(land_unit_spec) if land_unit != 1000
assert mi(land_tenure) if land_access_yn != 1
*assert mi(land_tenure_sp) if land_tenure != 1000
foreach v of varlist land_own_dur_n land_legal  {
	assert mi(`v') if land_tenure != 1
}
assert mi(land_legal_d) if land_legal != 1
assert mi(land_access_yn_disp) if migr_idp != 1
assert mi(land_unit_disp) if land_access_yn_disp != 1
*assert mi(land_unit_spec_disp) if land_unit_disp != 1000
assert mi(land_tenure_disp) if land_access_yn_disp != 1
foreach v of varlist land_own_dur_n_disp land_legal_disp  {
	assert mi(`v') if land_tenure_disp != 1
}
assert mi(land_legal_d_disp) if land_legal_disp != 1
assert mi(land_lost_disp) if land_access_yn_disp != 1
assert mi(landag_use_disp) if land_lost_disp != 1
*assert mi(landag_use_disp_spec) if landag_use_disp != 1000
*Food Security and Coping
foreach v of varlist hunger - social_saf_net social_ease - social_ease {
	assert !mi(`v')
}
*assert mi(social_saf_net_spec) if social_saf_net != 1000
foreach v of varlist cop_lessprefrerred - cop_reducemeals {
    di "`v'"
	assert inrange(`v',-999999999,7)
}
*Sources of income and remittances
foreach v of varlist lhood assist* {
	assert !mi(`v')
}
*assert mi(lhood_spec) if lhood != 1000
foreach v of varlist intremit12m_yn remit12m_yn {
	assert !mi(`v')
}
assert mi(intremit12m) if intremit12m_yn != 1
assert mi(intremit12m_amount) if intremit12m == 2
assert mi(intremit12m_amount_c) if mi(intremit12m_amount)
assert mi(intremit_relation) if !inlist(intremit12m,1,2,3)
destring intremit_relation_sp, replace
assert mi(intremit_relation_sp) if intremit_relation != 1000
assert mi(intremit_source) if !inlist(intremit12m,1,2,3)
assert mi(intremit_source_mig) if !inlist(intremit12m,1,2,3) & intremit_source != 1
*assert mi(intremit_mode_sp) if intremit_mode__1000 == 0
assert mi(intremit_freq) if !inlist(intremit12m,1,2,3)
assert mi(remit12m) if remit12m_yn != 1
assert mi(remit12m_amount) if !inlist(remit12m,1,3)
assert mi(remit12m_amount_c) if mi(remit12m_amount)
assert mi(remit_relation) if !inlist(remit12m,1,2,3)
destring remit_relation_sp, replace
*assert mi(remit_relation_sp) if remit_relation != 1000
assert mi(remit_source) if !inlist(remit12m,1,2,3)
assert mi(remit_source_mig) if !inlist(remit12m,1,2,3) & remit_source != 1
assert mi(remit12m_loc) if !inlist(remit12m,1,2,3)
*assert mi(remit12m_loc_sp) if remit12m_loc != 1000
*assert mi(remit_mode_sp) if remit_mode__1000 == 0
assert mi(remit_freq) if !inlist(remit12m,1,2,3)
assert mi(remitmoreless) if remit12m_yn != 1
assert mi(remitchange) if !(remitmoreless!=0 & remit12m_yn==1)
assert mi(remit12m_before) if remit12m !=0
assert mi(remit_disp_yn) if migr_idp != 1
assert mi(remit_disp) if remit_disp_yn != 1
assert mi(remit_disp_moreless) if !(migr_idp==1 & remit_disp_yn==1)
foreach v of varlist okay_lie_n last_meal last_bread last_meat last_fruit last_pulses {
	assert mi(`v') if beh_treat_opt != 1
}
forval i=1/18 {
	assert !mi(rf_relevanceyn1__`i')
}
forval i=19/31 {
	assert !mi(rf_relevanceyn2__`i')
}
forval i=32/44 {
	assert !mi(rf_relevanceyn3__`i')
}
forval i=45/69 {
	assert !mi(rf_relevanceyn4__`i')
}
forval i=70/114 {
	assert !mi(rf_relevanceyn__`i')
}
forval i= 1001/1003 {
	assert !mi(rnf_relevanceyn1__`i')
}
forval i= 1005/1010 {
	assert !mi(rnf_relevanceyn1__`i')
}
forval i= 1011/1035 {
	assert !mi(rnf_relevanceyn2__`i')
}
forval i= 1036/1070 {
	assert !mi(rnf_relevanceyn3__`i')
}
forval i= 1072/1090 {
	assert !mi(rnf_relevanceyn4__`i')
}
forval i= 1/7 {
	assert !mi(rl_raise__`i')
}
forval i= 1/7 {
	assert !mi(rl_raise_prev_yn__`i') if migr_idp == 1
}
forval i= 1/37 {
	assert !mi(ra_own__`i')
}
forval i= 1/37 {
	assert !mi(ra_own_prev__`i') if migr_idp == 1
}
*Module I: Perceptions and social services
*Risk attitudes 
foreach v of varlist beh_time_mon beh_time_yr beh_time_risk beh_risk_bus trust_people life_control {
	assert !mi(`v')
}
assert mi(beh_time_mon_more) if beh_time_mon != 1
assert mi(beh_time_mon_less) if beh_time_mon != 2
assert mi(beh_time_yr_more) if beh_time_yr != 1
assert mi(beh_time_yr_less) if beh_time_yr != 2
*Personal views and living conditions
foreach v of varlist health_satisfaction school_satisfaction empl_satisfaction {
	assert !mi(`v')
}
foreach v of varlist neighbreelate neighborrelate_disp {
	assert mi(`v') if migr_idp != 1
}
foreach v of varlist idp_compensation employment_opportunities standard_living settle_dispute {
	assert !mi(`v')
}
*assert mi(settle_dispute_spec) if settle_dispute != 1000
foreach v of varlist police_competence justice_confidence improve_community agent_of_change {
	assert !mi(`v')
}
*assert mi(improve_specify) if improve_community != 1000
*assert mi(agent_specify) if agent_of_change != 1000
assert mi(legal_id_disp) if !(migr_idp == 1 & migr_disp_past == 1)
foreach v of varlist legal_id_access_disp ag_rep rep_satisfied taxes {
	assert !mi(`v')
}
*assert mi(agent_represent_specify) if ag_rep != 1000
assert mi(elec_process) if sld != 0
destring taxes_other_specify, replace
assert mi(taxes_other_specify) if taxes_specify__1000 == 0
assert mi(idp_presence) if migr_idp != 0
foreach v of varlist women_work - clan_interact {
	assert !mi(`v')
}
*Freedom of movement and safety
foreach v of varlist move_free conf_nonphys_harm__5 {
	assert !mi(`v')
}
*Module J: Displacement
foreach v of varlist disp_from - inf_want_sp {
	destring `v', replace
	*assert mi(`v') if !(no_success==0 & migr_idp==1)
}
assert mi(disp_from_region) if !(disp_from==15 | disp_from==24)
*assert mi(disp_reason_spec) if disp_reason != 1000
assert mi(disp_site_reason) if disp_site == 1
*assert mi(disp_site_reason_spec) if disp_site_reason != 1000
*assert mi(disp_arrive_reason_spec) if disp_arrive_reason != 1000
assert mi(disp_temp_return_reason) if disp_temp_return != 1
*assert mi(disp_temp_return_reason_s) if disp_temp_return_reason != 1000
assert mi(disp_comm_otherloc_loc_c) if !(disp_comm_otherloc_d==15 | disp_comm_otherloc_d==24)
*assert mi(disp_shelterpay_who_spec) if disp_shelterpay_who__1000==0
assert mi(disp_shelterpay_what) if disp_shelterpay != 1
*assert mi(disp_shelterpay_what_spec) if disp_shelterpay_what != 1000
foreach v of varlist move_want move_want_time move_to_loc move_yes_push* move_yes_pull* {
	*assert mi(`v') if move_want_yn != 1
}
foreach v of varlist move_no_push* move_no_pull*  {
	*assert mi(`v') if move_want_yn != 0
}
foreach v of varlist move_no_org*  {
	*assert mi(`v') if move_want != 2
}
*assert mi(move_no_org_spec) if move_no_org__1000 == 0
foreach v of varlist move_help*  {
	*assert mi(`v') if mi(move_want_yn)
}
*assert mi(move_help_spec) if move_help__1000 == 0
*Information needs
*assert mi(inf_source_sp) if inf_source != 1000
*assert mi(inf_source_add_sp) if inf_source_add__1000 == 0
*Module K: Fishing
assert mi(fishing_not_only_days) if fishing_only_occ != 0 
assert mi(fishing_others) if fishing_alone != 0
foreach v of varlist boat_kind* fishing_boat_origin fishing_others_own_boat fishing_distance {
	assert mi(`v') if fishing_boat != 1
}
assert mi(fishing_others_share) if !(fishing_alone==0 & fishing_boat==1)
*assert mi(fishing_use_spec) if fishing_use != 1000
assert mi(fishing_with_sons) if fishing_sons != 1
*Module L: Shocks
*assert mi(shocks0_sp) if shocks0__1000 == 0


* Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist interview__id-shock_2 {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}


********************************************************************
*Introduce .z to identify not administered questions
********************************************************************
replace migr_disp=.z if idp_ea_yn==1 
replace migr_disp_past=.z if migr_disp==1 
replace hhh_absence_reason=.z if hhh_presence!=0
replace disp_hhm_otherloc=.z if hhm_separated!=1
replace land_own_dur_n_main=.z if tenure!=1
replace land_legal_main=.z if tenure!=1
replace land_legal_main_d=.z if land_legal_main!=1
replace tenant_legal=.z if (tenure<2 | tenure>5)
replace water_time=.z if drink_water<3 & cook_source<3
replace light=.z if electricity_grid!=0
replace electricity_phone=.z if electricity!=1
replace electricity_choice=.z if electricity_grid!=1
replace electricity_price=.z if electricity_grid!=1
replace electricity_price_curr=.z if electricity_grid!=1 & electricity_price>0
replace electricity_fee=.z if electricity_meter!=0 | electricity_grid!=1
replace electricity_price_perception=.z if electricity_grid!=1
replace electricity_hours=.z if electricity!=1
replace electricity_blackout=.z if electricity_hours<=16 
replace share_num=.z if share_facility!=1
replace sewage=.z if toilet!=3 & toilet!=4 & toilet!=5 & toilet!=7
replace acc_road_use=.z if acc_road<=0
qui foreach var of varlist housingtype_disp-roof_material_disp {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		replace `var'=.z if migr_idp!=1
}
		if "`type'" == "str" { 
		replace `var'=".z" if migr_idp!=1
}
}
replace land_legal_main_disp=.z if  tenure_disp>3
replace land_legal_main_disp_d=.z if land_legal_main_disp!=1
replace land_res_disp=.z if land_use_disp__7!=1
replace land_back_disp=.z if land_use_disp__5!=1 & land_use_disp__7!=1
replace land_access_kdk=.z if land_access_yn!=1
replace land_access=.z if land_access_yn!=1 | land_access_kdk>=.
replace land_unit=.z if land_access_yn!=1
replace land_tenure=.z if land_access_yn!=1
replace land_own_dur_n=.z if land_access_yn!=1
replace land_legal=.z if land_tenure!=1
replace land_legal_d=.z if land_legal!=1
replace land_access_yn_disp=.z if migr_idp!=1
replace land_access_disp_kdk=.z if land_access_yn_disp!=1
replace land_access_disp=.z if land_access_yn_disp!=1 | land_access_disp_kdk>=.
replace land_unit_disp=.z if land_access_yn_disp!=1
replace land_tenure_disp=.z if land_access_yn_disp!=1
replace land_own_dur_n_disp=.z if land_tenure_disp!=1
replace land_legal_disp=.z if land_tenure_disp!=1
replace land_legal_d_disp=.z if land_legal_disp!=1
replace land_lost_disp=.z if land_access_yn_disp!=1
replace landag_use_disp=.z if land_lost_disp!=1
replace lhood_prev=.z if migr_idp!=1
replace intremit12m=.z if intremit12m_yn!=1
replace intremit12m_amount_kdk=.z if intremit12m==2 | intremit12m>=.
replace intremit12m_amount=.z if (intremit12m==2 | intremit12m>=.) & intremit12m_amount_kdk>=.
replace intremit12m_amount_c=.z if intremit12m_amount>=.
replace intremit_relation=.z if intremit12m>=.
replace intremit_source=.z if intremit12m>=.
replace intremit_source_mig=.z if intremit12m>=. | intremit_source!=1
foreach var in intremit_mode__1 intremit_mode__2 intremit_mode__3 intremit_mode__4 intremit_mode__5 intremit_mode__6 intremit_mode__7 intremit_mode__8 intremit_mode__9 intremit_freq {
	replace `var'=.z if intremit12m>=.
}
replace remit12m=.z if remit12m_yn!=1
replace remit12m_amount_kdk=.z if remit12m==2 | remit12m>=.
replace remit12m_amount=.z if (remit12m==2 | remit12m>=.) & remit12m_amount_kdk>=.
replace remit12m_amount_c=.z if remit12m_amount>=.
replace remit_relation=.z if remit12m>=.
replace remit_source=.z if remit12m>=.
replace remit_source_mig=.z if remit12m>=. | remit_source!=1
replace remit12m_loc=.z if remit12m>=.
foreach var in remit_mode__1 remit_mode__2 remit_mode__3 remit_mode__4 remit_mode__5 remit_mode__6 remit_mode__7 remit_mode__8 remit_mode__9 remit_freq {
	replace `var'=.z if remit12m>=.
}
replace remitmoreless=.z if remit12m_yn!=1
replace remitchange=.z if remit12m_yn!=1 | remitmoreless==0
replace remit12m_before=.z if remit12m!=0
replace remit_disp_yn=.z if migr_idp!=1
replace remit_disp=.z if remit_disp_yn!=1
replace remit_disp_moreless=.z if migr_idp!=1 | remit_disp_yn!=1
replace supp_somosom__1=.z if supp_som_yn!=1 
replace supp_somosom__2=.z if supp_som_yn!=1 
replace supp_somosom__3=.z if supp_som_yn!=1
replace supp_som_amount=.z if supp_som_yn!=1
replace supp_som_amount_c=.z if supp_som_amount>=.
replace supp_som_amount_kdk=.z if supp_som_yn!=1
replace okay_lie_n=.z if beh_treat_opt!=1
foreach var in last_meal last_bread last_meat last_fruit last_pulses {
	replace `var'=.z if beh_treat_opt!=1
}
foreach var in rf_relevanceyn1__4 rf_relevanceyn1__11 rf_relevanceyn1__16 rf_relevanceyn2__22 rf_relevanceyn2__27 rf_relevanceyn3__35 rf_relevanceyn3__36 rf_relevanceyn3__40 rf_relevanceyn3__42 rf_relevanceyn3__43 rf_relevanceyn4__55 rf_relevanceyn4__62 rf_relevanceyn4__64 rf_relevanceyn__83 rf_relevanceyn__84 rf_relevanceyn__86 rf_relevanceyn__92 rf_relevanceyn__100 rf_relevanceyn__105 rf_relevanceyn__107 rf_relevanceyn__112  {
	replace `var'=.z if mod_opt!=1
}
foreach var in rf_relevanceyn1__6 rf_relevanceyn1__10 rf_relevanceyn2__28 rf_relevanceyn2__29 rf_relevanceyn3__32 rf_relevanceyn3__41 rf_relevanceyn4__56 rf_relevanceyn4__63 rf_relevanceyn4__65 rf_relevanceyn__71 rf_relevanceyn__78 rf_relevanceyn__94 rf_relevanceyn__95 rf_relevanceyn__96 rf_relevanceyn__97 rf_relevanceyn__98 rf_relevanceyn__106 rf_relevanceyn__114 {
	replace `var'=.z if mod_opt!=2
}
foreach var in rf_relevanceyn1__3 rf_relevanceyn1__8 rf_relevanceyn1__12 rf_relevanceyn2__24 rf_relevanceyn2__25 rf_relevanceyn3__34 rf_relevanceyn4__46 rf_relevanceyn4__61 rf_relevanceyn4__66 rf_relevanceyn4__67 rf_relevanceyn4__69 rf_relevanceyn__70 rf_relevanceyn__72 rf_relevanceyn__77 rf_relevanceyn__79 rf_relevanceyn__91 rf_relevanceyn__93 rf_relevanceyn__101 rf_relevanceyn__104 {
	replace `var'=.z if mod_opt!=3
}
foreach var in rf_relevanceyn1__15 rf_relevanceyn2__21 rf_relevanceyn2__23 rf_relevanceyn2__30 rf_relevanceyn3__37 rf_relevanceyn3__38 rf_relevanceyn3__39 rf_relevanceyn4__49 rf_relevanceyn4__58 rf_relevanceyn4__60 rf_relevanceyn4__68 rf_relevanceyn__73 rf_relevanceyn__87 rf_relevanceyn__88 rf_relevanceyn__89 rf_relevanceyn__99 rf_relevanceyn__102 rf_relevanceyn__113  {
	replace `var'=.z if mod_opt!=4
}
foreach var in rnf_relevanceyn2__1015 rnf_relevanceyn2__1016 rnf_relevanceyn2__1020 rnf_relevanceyn2__1022 rnf_relevanceyn2__1032 rnf_relevanceyn3__1036 rnf_relevanceyn3__1039 rnf_relevanceyn3__1040 rnf_relevanceyn3__1046 rnf_relevanceyn3__1055 rnf_relevanceyn3__1064 rnf_relevanceyn4__1076 rnf_relevanceyn4__1077 rnf_relevanceyn4__1087 {
	replace `var'=.z if mod_opt!=1
}
foreach var in rnf_relevanceyn1__1002 rnf_relevanceyn1__1006 rnf_relevanceyn2__1014 rnf_relevanceyn3__1038 rnf_relevanceyn3__1042 rnf_relevanceyn3__1045 rnf_relevanceyn3__1049 rnf_relevanceyn3__1051 rnf_relevanceyn3__1053 rnf_relevanceyn3__1059 rnf_relevanceyn3__1060 rnf_relevanceyn4__1073 rnf_relevanceyn4__1075 rnf_relevanceyn4__1088 rnf_relevanceyn4__1089 {
	replace `var'=.z if mod_opt!=2
}
foreach var in rnf_relevanceyn1__1003 rnf_relevanceyn2__1011 rnf_relevanceyn2__1025 rnf_relevanceyn2__1029 rnf_relevanceyn2__1030 rnf_relevanceyn2__1031 rnf_relevanceyn3__1037 rnf_relevanceyn3__1041 rnf_relevanceyn3__1043 rnf_relevanceyn3__1047 rnf_relevanceyn3__1048 rnf_relevanceyn3__1050 rnf_relevanceyn3__1054 rnf_relevanceyn3__1061 rnf_relevanceyn3__1062 rnf_relevanceyn4__1074 {
	replace `var'=.z if mod_opt!=3
}
foreach var in rnf_relevanceyn2__1004 rnf_relevanceyn2__1012 rnf_relevanceyn2__1021 rnf_relevanceyn2__1034 rnf_relevanceyn3__1044 rnf_relevanceyn3__1052 rnf_relevanceyn3__1056 rnf_relevanceyn3__1057 rnf_relevanceyn3__1058 rnf_relevanceyn3__1063 rnf_relevanceyn3__1065 rnf_relevanceyn3__1066 rnf_relevanceyn4__1072 rnf_relevanceyn4__1081 rnf_relevanceyn4__1090 {
	replace `var'=.z if mod_opt!=4
}
foreach var in rl_raise_prev_yn__1 rl_raise_prev_yn__2 rl_raise_prev_yn__3 rl_raise_prev_yn__4 rl_raise_prev_yn__5 rl_raise_prev_yn__6 rl_raise_prev_yn__7 {
	replace `var'=.z if migr_idp!=1
}

foreach var of varlist ra_own_prev__1-ra_own_prev__37 {
	replace `var'=.z if migr_idp!=1
}
replace beh_time_mon_more=.z if beh_time_mon!=1
replace beh_time_mon_less=.z if beh_time_mon!=2
replace beh_time_yr_more =.z if beh_time_yr!=1
replace beh_time_yr_less=.z if beh_time_yr!=2
replace neighbreelate=.z if migr_idp!=1 
replace neighborrelate_disp=.z if migr_idp!=1
replace settle_dispute_satis=.z if settle_dispute<. 
replace dispute_resolve_police=.z if settle_dispute==4 | settle_dispute>=.
replace legal_id_disp=.z if migr_idp!=1 | migr_disp_past!=1
replace elec_process=.z if sld!=0
foreach var in taxes_specify__1 taxes_specify__2 taxes_specify__3 taxes_specify__4 taxes_specify__5 taxes_specify__6 taxes_specify__7 taxes_specify__8 {
	replace `var'=.z if taxes!=1
}
replace idp_presence=.z if migr_idp!=0
replace disp_from=.z if migr_idp!=1 
replace disp_from_region=.z if (disp_from!=15 & disp_from!=24)
replace disp_date_kdk=.z if migr_idp!=1 
replace disp_date="" if disp_date=="##N/A##"
replace disp_date=".z" if disp_date_kdk>=.
replace disp_reason=.z if migr_idp!=1 
replace disp_site=.z if migr_idp!=1 
replace disp_site_reason=.z if migr_idp!=1 | disp_site<=1
replace disp_arrive_reason=.z if migr_idp!=1  
replace disp_arrive_date_kdk=.z if migr_idp!=1  
replace disp_arrive_date=".z" if disp_arrive_date_kdk>=.
replace disp_arrive_with=.z if migr_idp!=1 
replace disp_temp_return=.z if migr_idp!=1  
replace disp_temp_return_n_kdk=.z if disp_temp_return!=1
replace disp_temp_return_n=.z if disp_temp_return!=1 | disp_temp_return_n_kdk>=.
replace disp_temp_return_reason=.z if disp_temp_return!=1
replace disp_comm_otherloc_d=.z if migr_idp!=1 
replace disp_comm_otherloc_loc_c=.z if (disp_comm_otherloc_d!=15 & disp_comm_otherloc_d!=24)
replace disp_try=.z if migr_idp!=1 
replace disp_shelterpay=.z if migr_idp!=1 
foreach var in disp_shelterpay_who__1 disp_shelterpay_who__2 disp_shelterpay_who__3 disp_shelterpay_who__4 disp_shelterpay_who__5 disp_shelterpay_who__6 {
	replace `var'=.z if disp_shelterpay!=1
}
replace disp_shelterpay_what=.z if disp_shelterpay!=1
replace move_want_yn=.z if migr_idp!=1 
replace move_want=.z if move_want_yn!=1
replace move_want_time=.z if move_want_yn!=1 
replace move_to_loc=.z if move_want_yn!=1
foreach var in move_no_push__1 move_no_push__2 move_no_push__3 move_no_push__5 move_no_push__6 move_no_push__7 {
	replace `var'=.z if move_want_yn!=0
}
foreach var in move_no_pull__1 move_no_pull__2 move_no_pull__3 move_no_pull__4 move_no_pull__5 move_no_pull__6 move_no_pull__7 move_no_pull__8 move_no_pull__9 move_no_pull__10 move_no_pull__11 {
	replace `var'=.z if move_want_yn!=0
}
foreach var in move_yes_push__1 move_yes_push__2 move_yes_push__3 move_yes_push__4 move_yes_push__5 move_yes_push__6 move_yes_push__7 move_yes_push__8 move_yes_push__9 move_yes_push__10 move_yes_push__11 {
	replace `var'=.z if move_want_yn!=1
}
foreach var in move_no_org__1 move_no_org__2 move_no_org__3 move_no_org__4 move_no_org__5 move_no_org__6 move_no_org__7 move_no_org__8 move_no_org__9 move_no_org__10 move_no_org__11 {
	replace `var'=.z if move_want!=2
}
foreach var in move_yes_pull__1 move_yes_pull__2 move_yes_pull__3 move_yes_pull__4 move_yes_pull__5 move_yes_pull__6 move_yes_pull__7 {
	replace `var'=.z if move_want_yn!=1
}
foreach var in move_help__1 move_help__2 move_help__3 move_help__4 move_help__5 move_help__6 move_help__7 move_help__8 move_help__9 move_help__10 move_help__11 move_help__12 move_help__13 move_help__14 move_help__15 move_help__16 move_help__17 {
	replace `var'=.z if move_want_yn>=.
}
replace inf_source=.z if migr_idp!=1
replace inf_source_more=.z if migr_idp!=1
foreach var in inf_source_add__1 inf_source_add__2 inf_source_add__3 inf_source_add__4 inf_source_add__5 inf_source_add__6 inf_source_add__7 inf_source_add__8 inf_source_add__9 inf_source_add__10 {
	replace `var'=.z if inf_source_more!=1
}
replace inf_comp=.z if migr_idp!=1
foreach var in inf_want__1 inf_want__2 inf_want__3 inf_want__4 inf_want__5 inf_want__6 inf_want__7 inf_want__8 inf_want__9 inf_want__10 inf_want__11 inf_want__12 {	 
	replace `var'=.z if inf_comp!=0	
}
replace hhm_fishing_resp=.z if fishing_yn!=1
replace fishing_only_occ=.z if fishing_yn!=1 
replace fishing_not_only_days_kdk=.z if fishing_only_occ!=0
replace fishing_not_only_days=.z if fishing_only_occ!=0 | fishing_not_only_days_kdk>=.
replace fishing_alone=.z if fishing_yn!=1 
replace fishing_others=.z if fishing_alone!=0
replace fishing_boat=.z if fishing_yn!=1
foreach var in boat_kind__1 boat_kind__2 boat_kind__3 boat_kind__4 {
	replace `var'=.z if fishing_boat!=1	
}
replace fishing_boat_origin=.z if fishing_boat!=1
replace fishing_others_own_boat=.z if fishing_boat!=1
replace fishing_others_share=.z if fishing_alone!=0 | fishing_boat!=1
replace fishing_distance=.z if fishing_boat!=1
foreach var in fishing_gear_used__1 fishing_gear_used__2 fishing_gear_used__3 fishing_gear_used__4 fishing_gear_used__5 fishing_gear_used__6 fishing_gear_used__7 fishing_gear_used__8 fishing_gear_used__9 fishing_gear_used__10 fishing_gear_used__11 fishing_equipment__1 fishing_equipment__2 fishing_equipment__3 fishing_equipment__4 fishing_equipment__5 fishing_equipment__6 fishing_equipment__7 fishing_equipment__8 fishing_equipment__9 fishing_equipment__10 fishing_equipment__11 high_season__1 high_season__2 high_season__3 high_season__4 high_season__5 high_season__6 high_season__7 high_season__8 high_season__9 high_season__10 high_season__11 high_season__12 low_season__1 low_season__2 low_season__3 low_season__4 low_season__5 low_season__6 low_season__7 low_season__8 low_season__9 low_season__10 low_season__11 low_season__12 {
	replace `var'=.z if fishing_yn!=1
}
replace bad_season_kdk=.z if fishing_yn!=1 
replace bad_season=.z if bad_season_kdk>=.
foreach var in fishing_volume__1 fishing_volume__2 fishing_volume__3 fishing_volume__4 fishing_volume__5 fishing_volume__6 fishing_volume__7 fishing_volume__8 fishing_volume__9 fishing_volume__10 fishing_volume__11 fishing_volume__12 fishing_volume__13 fishing_volume__14 fishing_volume__15 fishing_volume__16 fishing_volume__17 fishing_volume__18 fishing_volume__19 fishing_volume__20 fishing_volume__21 fishing_volume__22 fishing_volume__23 fishing_volume__24 fishing_volume__25 fishing_volume__26 fishing_volume__27 fishing_volume__28 fishing_volume__29 fishing_volume__30 fishing_volume__31 fishing_volume__32 fishing_volume__33 fishing_volume__34 fishing_volume__35 fishing_volume__36 fishing_volume__37 fishing_volume__38 fishing_volume__39 fishing_volume__40 fishing_volume__41 fishing_volume__42 fishing_volume__43 fishing_volume__44 fishing_volume__45 {
	replace `var'=.z if fishing_yn!=1 
}
replace fishing_use=.z if  fishing_yn!=1 
replace fishing_sons=.z if fishing_yn!=1 
replace fishing_with_sons=.z if fishing_sons!=1
replace fishing_no_sons=.z if fishing_sons!=1 | fishing_with_sons!=1


********************************************************************
*Label values correctly 
********************************************************************
local variables migr_disp migr_disp_past hhh_absence_reason disp_hhm_otherloc land_legal_main land_own_dur_n_main ///
      land_legal_main_d tenant_legal water_time light electricity_phone electricity_choice electricity_price electricity_price_curr electricity_fee /// 
      electricity_price_perception electricity_hours electricity_blackout share_num	sewage acc_road_use ///
	  housingtype_disp housingtype_disp_s tenure_disp land_legal_main_disp land_legal_main_disp_d land_use_disp__1 land_use_disp__2 land_use_disp__3 land_use_disp__4 land_use_disp__5 ///
	  land_use_disp__6 land_use_disp__7 land_use_disp__1000 land_use_disp__n98 land_use_disp__n99 land_use_disp_s land_res_disp land_help_disp land_help_disp_spec land_res_reason_disp land_res_reason_disp_spec ///
	  land_back_disp drink_source_disp t_water_disp t_market_disp t_edu_disp thealth_disp light_disp toilet_disp floor_material_disp roof_material_disp ///
	  land_access_kdk land_access land_unit land_tenure land_own_dur_n land_legal land_legal_d	land_access_yn_disp land_access_disp_kdk land_access_disp land_unit_disp land_tenure_disp land_own_dur_n_disp land_legal_disp land_legal_d_disp land_lost_disp landag_use_disp ///
      lhood_prev intremit12m intremit12m_amount_kdk intremit12m_amount intremit12m_amount_c intremit_relation intremit_source intremit_source_mig intremit_freq ///
      remit12m remit12m_amount_kdk remit12m_amount remit12m_amount_c remit_relation remit_source remit_source_mig remit12m_loc remit_freq remitmoreless remitchange remit12m_before remit_disp_yn remit_disp remit_disp_moreless /// 
	  supp_som_amount supp_som_amount_c supp_som_amount_kdk	okay_lie_n last_meal last_bread last_meat last_fruit last_pulses beh_time_mon_more beh_time_mon_less beh_time_yr_more beh_time_yr_less neighbreelate neighborrelate_disp settle_dispute_satis dispute_resolve_police legal_id_disp idp_presence ///
      disp_from disp_from_region disp_date_kdk disp_date disp_reason disp_site disp_site_reason disp_arrive_reason disp_arrive_date_kdk disp_arrive_date disp_arrive_with disp_temp_return disp_temp_return_n_kdk disp_temp_return_n disp_temp_return_reason  ///
	  disp_comm_otherloc_d disp_comm_otherloc_loc_c disp_try disp_shelterpay disp_shelterpay_what move_want_yn move_want move_want_time move_to_loc inf_source inf_source_more inf_comp hhm_fishing_resp fishing_only_occ fishing_alone fishing_boat fishing_not_only_days_kdk fishing_not_only_days fishing_others ///
      fishing_boat_origin fishing_others_own_boat fishing_others_share fishing_distance bad_season_kdk bad_season fishing_use fishing_sons fishing_with_sons fishing_no_sons
foreach variable in `variables' {
	label define `variable' .a "Don't know" .b "Refused to respond" .z "Not administered", modify
}
label define lyesno 0 "No" 1 "Yes" .a "Don't know" .b "Refused to respond" .z "Not administered" 
label values migr_idp lyesno
local variables2 water_home electricity land_use_disp__1 land_use_disp__2 land_use_disp__3 land_use_disp__4 land_use_disp__5 land_use_disp__6 land_use_disp__7 assist__1 assist__2 assist__3  ///
      intremit_mode__1 intremit_mode__2 intremit_mode__3 intremit_mode__4 intremit_mode__5 intremit_mode__6 intremit_mode__7 intremit_mode__8 intremit_mode__9  ///
      remit_mode__1 remit_mode__2 remit_mode__3 remit_mode__4 remit_mode__5 remit_mode__6 remit_mode__7 remit_mode__8 remit_mode__9 supp_somosom__1 supp_somosom__2 supp_somosom__3 beh_treat_opt ///
	  rf_relevanceyn1__1 rf_relevanceyn1__2 rf_relevanceyn1__5 rf_relevanceyn1__7 rf_relevanceyn1__9 rf_relevanceyn1__13 rf_relevanceyn1__14 rf_relevanceyn1__17 rf_relevanceyn1__18 rf_relevanceyn2__19 rf_relevanceyn2__20 rf_relevanceyn2__26 rf_relevanceyn2__31 rf_relevanceyn3__33 rf_relevanceyn3__44 rf_relevanceyn4__45 rf_relevanceyn4__47 rf_relevanceyn4__48 rf_relevanceyn4__50 rf_relevanceyn4__51  ///
	  rf_relevanceyn4__52 rf_relevanceyn4__53 rf_relevanceyn4__54 rf_relevanceyn4__57 rf_relevanceyn4__59 rf_relevanceyn__74 rf_relevanceyn__75 rf_relevanceyn__76 rf_relevanceyn__80 rf_relevanceyn__81 rf_relevanceyn__82 rf_relevanceyn__85 rf_relevanceyn__90 rf_relevanceyn__103 rf_relevanceyn__108 rf_relevanceyn__109 rf_relevanceyn__110 rf_relevanceyn__111 ///
	  rf_relevanceyn1__4 rf_relevanceyn1__11 rf_relevanceyn1__16 rf_relevanceyn2__22 rf_relevanceyn2__27 rf_relevanceyn3__35 rf_relevanceyn3__36 rf_relevanceyn3__40 rf_relevanceyn3__42 rf_relevanceyn3__43 rf_relevanceyn4__55 rf_relevanceyn4__62 rf_relevanceyn4__64 rf_relevanceyn__83 rf_relevanceyn__84 rf_relevanceyn__86 rf_relevanceyn__92 rf_relevanceyn__100 rf_relevanceyn__105 rf_relevanceyn__107 rf_relevanceyn__112 ///
	  rf_relevanceyn1__6 rf_relevanceyn1__10 rf_relevanceyn2__28 rf_relevanceyn2__29 rf_relevanceyn3__32 rf_relevanceyn3__41 rf_relevanceyn4__56 rf_relevanceyn4__63 rf_relevanceyn4__65 rf_relevanceyn__71 rf_relevanceyn__78 rf_relevanceyn__94 rf_relevanceyn__95 rf_relevanceyn__96 rf_relevanceyn__97 rf_relevanceyn__98 rf_relevanceyn__106 rf_relevanceyn__114 ///
	  rf_relevanceyn1__3 rf_relevanceyn1__8 rf_relevanceyn1__12 rf_relevanceyn2__24 rf_relevanceyn2__25 rf_relevanceyn3__34 rf_relevanceyn4__46 rf_relevanceyn4__61 rf_relevanceyn4__66 rf_relevanceyn4__67 rf_relevanceyn4__69 rf_relevanceyn__70 rf_relevanceyn__72 rf_relevanceyn__77 rf_relevanceyn__79 rf_relevanceyn__91 rf_relevanceyn__93 rf_relevanceyn__101 rf_relevanceyn__104 ///
	  rf_relevanceyn1__15 rf_relevanceyn2__21 rf_relevanceyn2__23 rf_relevanceyn2__30 rf_relevanceyn3__37 rf_relevanceyn3__38 rf_relevanceyn3__39 rf_relevanceyn4__49 rf_relevanceyn4__58 rf_relevanceyn4__60 rf_relevanceyn4__68 rf_relevanceyn__73 rf_relevanceyn__87 rf_relevanceyn__88 rf_relevanceyn__89 rf_relevanceyn__99 rf_relevanceyn__102 rf_relevanceyn__113  ///
	  rnf_relevanceyn1__1001 rnf_relevanceyn1__1005 rnf_relevanceyn1__1007 rnf_relevanceyn1__1008 rnf_relevanceyn1__1009 rnf_relevanceyn1__1010 rnf_relevanceyn2__1013 rnf_relevanceyn2__1017 rnf_relevanceyn2__1018 rnf_relevanceyn2__1019 rnf_relevanceyn2__1023 rnf_relevanceyn2__1024 rnf_relevanceyn2__1026 rnf_relevanceyn2__1027 rnf_relevanceyn2__1028 ///
	  rnf_relevanceyn2__1033 rnf_relevanceyn2__1035 rnf_relevanceyn3__1067 rnf_relevanceyn3__1068 rnf_relevanceyn3__1069 rnf_relevanceyn3__1070 rnf_relevanceyn4__1078 rnf_relevanceyn4__1079 rnf_relevanceyn4__1080 rnf_relevanceyn4__1082 rnf_relevanceyn4__1083 rnf_relevanceyn4__1084 rnf_relevanceyn4__1085 rnf_relevanceyn4__1086  ///
	  rnf_relevanceyn2__1015 rnf_relevanceyn2__1016 rnf_relevanceyn2__1020 rnf_relevanceyn2__1022 rnf_relevanceyn2__1032 rnf_relevanceyn3__1036 rnf_relevanceyn3__1039 rnf_relevanceyn3__1040 rnf_relevanceyn3__1046 rnf_relevanceyn3__1055 rnf_relevanceyn3__1064 rnf_relevanceyn4__1076 rnf_relevanceyn4__1077 rnf_relevanceyn4__1087  ///
	  rnf_relevanceyn1__1002 rnf_relevanceyn1__1006 rnf_relevanceyn2__1014 rnf_relevanceyn3__1038 rnf_relevanceyn3__1042 rnf_relevanceyn3__1045 rnf_relevanceyn3__1049 rnf_relevanceyn3__1051 rnf_relevanceyn3__1053 rnf_relevanceyn3__1059 rnf_relevanceyn3__1060 rnf_relevanceyn4__1073 rnf_relevanceyn4__1075 rnf_relevanceyn4__1088 rnf_relevanceyn4__1089  ///
	  rnf_relevanceyn1__1003 rnf_relevanceyn2__1011 rnf_relevanceyn2__1025 rnf_relevanceyn2__1029 rnf_relevanceyn2__1030 rnf_relevanceyn2__1031 rnf_relevanceyn3__1037 rnf_relevanceyn3__1041 rnf_relevanceyn3__1043 rnf_relevanceyn3__1047 rnf_relevanceyn3__1048 rnf_relevanceyn3__1050 rnf_relevanceyn3__1054 rnf_relevanceyn3__1061 rnf_relevanceyn3__1062 rnf_relevanceyn4__1074  ///
	  rnf_relevanceyn2__1004 rnf_relevanceyn2__1012 rnf_relevanceyn2__1021 rnf_relevanceyn2__1034 rnf_relevanceyn3__1044 rnf_relevanceyn3__1052 rnf_relevanceyn3__1056 rnf_relevanceyn3__1057 rnf_relevanceyn3__1058 rnf_relevanceyn3__1063 rnf_relevanceyn3__1065 rnf_relevanceyn3__1066 rnf_relevanceyn4__1072 rnf_relevanceyn4__1081 rnf_relevanceyn4__1090  /// 
	  rl_raise__1 rl_raise__2 rl_raise__3 rl_raise__4 rl_raise__5 rl_raise__6 rl_raise__7 rl_raise_prev_yn__1 rl_raise_prev_yn__2 rl_raise_prev_yn__3 rl_raise_prev_yn__4 rl_raise_prev_yn__5 rl_raise_prev_yn__6 rl_raise_prev_yn__7 ra_own__1-ra_own__37 ra_own_prev__1-ra_own_prev__37  taxes_specify__1 taxes_specify__2 taxes_specify__3 taxes_specify__4 taxes_specify__5 taxes_specify__6 taxes_specify__7 taxes_specify__8 ///
      conf_nonphys_harm__1 conf_nonphys_harm__2 conf_nonphys_harm__3 conf_nonphys_harm__4 conf_nonphys_harm__5 disp_shelterpay_who__1 disp_shelterpay_who__2 disp_shelterpay_who__3 disp_shelterpay_who__4 disp_shelterpay_who__5 disp_shelterpay_who__6 boat_kind__1 boat_kind__2 boat_kind__3 boat_kind__4  ///
      fishing_gear_used__1 fishing_gear_used__2 fishing_gear_used__3 fishing_gear_used__4 fishing_gear_used__5 fishing_gear_used__6 fishing_gear_used__7 fishing_gear_used__8 fishing_gear_used__9 fishing_gear_used__10 fishing_gear_used__11 fishing_equipment__1 fishing_equipment__2 fishing_equipment__3 fishing_equipment__4 fishing_equipment__5 fishing_equipment__6 fishing_equipment__7 fishing_equipment__8 fishing_equipment__9 fishing_equipment__10 ///
	  fishing_equipment__11 high_season__1 high_season__2 high_season__3 high_season__4 high_season__5 high_season__6 high_season__7 high_season__8 high_season__9 high_season__10 high_season__11 high_season__12 low_season__1 low_season__2 low_season__3 low_season__4 low_season__5 low_season__6 low_season__7 low_season__8 low_season__9 low_season__10 low_season__11 low_season__12  ///
	  shocks0__1 shocks0__2 shocks0__3 shocks0__4 shocks0__5 shocks0__6 shocks0__7 shocks0__8 shocks0__9 shocks0__10 shocks0__11 shocks0__12 shocks0__13 shocks0__14 shocks0__15 shocks0__16 shocks0__17 shocks0__18 
foreach variable in `variables2' {
	label values `variable' lyesno
}
label define limportant 0 "Not important" 1 "Most important" 2 "2nd most important" 3 "3rd most important" .a "Don't know" .b "Refused to respond" .z "Not administered" 
local variables3 move_no_push__1 move_no_push__2 move_no_push__3 move_no_push__5 move_no_push__6 move_no_push__7 ///
   	  move_no_pull__1 move_no_pull__2 move_no_pull__3 move_no_pull__4 move_no_pull__5 move_no_pull__6 move_no_pull__7 move_no_pull__8 move_no_pull__9 move_no_pull__10 move_no_pull__11 ///
	  move_yes_push__1 move_yes_push__2 move_yes_push__3 move_yes_push__4 move_yes_push__5 move_yes_push__6 move_yes_push__7 move_yes_push__8 move_yes_push__9 move_yes_push__10 move_yes_push__11 ///
	  move_no_org__1 move_no_org__2 move_no_org__3 move_no_org__4 move_no_org__5 move_no_org__6 move_no_org__7 move_no_org__8 move_no_org__9 move_no_org__10 move_no_org__11 ///
	  move_yes_pull__1 move_yes_pull__2 move_yes_pull__3 move_yes_pull__4 move_yes_pull__5 move_yes_pull__6 move_yes_pull__7 ///
	  inf_source_add__1 inf_source_add__2 inf_source_add__3 inf_source_add__4 inf_source_add__5 inf_source_add__6 inf_source_add__7 inf_source_add__8 inf_source_add__9 inf_source_add__10 ///
      inf_want__1 inf_want__2 inf_want__3 inf_want__4 inf_want__5 inf_want__6 inf_want__7 inf_want__8 inf_want__9 inf_want__10 inf_want__11 inf_want__12 ///
      fishing_volume__1 fishing_volume__2 fishing_volume__3 fishing_volume__4 fishing_volume__5 fishing_volume__6 fishing_volume__7 fishing_volume__8 fishing_volume__9 fishing_volume__10 fishing_volume__11 fishing_volume__12  ///
	  fishing_volume__13 fishing_volume__14 fishing_volume__15 fishing_volume__16 fishing_volume__17 fishing_volume__18 fishing_volume__19 fishing_volume__20 fishing_volume__21 fishing_volume__22 fishing_volume__23 fishing_volume__24 fishing_volume__25 fishing_volume__26 fishing_volume__27 fishing_volume__28 fishing_volume__29 fishing_volume__30 fishing_volume__31 fishing_volume__32 fishing_volume__33 fishing_volume__34 fishing_volume__35 fishing_volume__36 fishing_volume__37 fishing_volume__38 fishing_volume__39 fishing_volume__40 fishing_volume__41 fishing_volume__42 fishing_volume__43 fishing_volume__44 fishing_volume__45	  
foreach variable in `variables3' {
	label values `variable' limportant
}
label define limportantyn 0 "Not important" 1 "Important" .a "Don't know" .b "Refused to respond" .z "Not administered" 
local variables4 move_help__1 move_help__2 move_help__3 move_help__4 move_help__5 move_help__6 move_help__7 move_help__8 move_help__9 move_help__10 move_help__11 move_help__12 move_help__13 move_help__14 move_help__15 move_help__16 move_help__17
foreach variable in `variables4' {
	label values `variable' limportantyn
}

drop intremit_mode_sp
label define lintremitmode 1 "1st choice" 2 "2nd choice" 3 "3rd choice" 4 "4th choice" 5 "5th choice" 6 "6th choice" 7 "7th choice" 8 "8th choice" 9 "9th choice" .x "Option not chosen", replace
label values intremit_mode_* lremitmode

* generate cleaned GPS coordinates for HH
gen double long_x = str_loc__Longitude if str_loc__Longitude>-1000
gen gps_comment = 1 if !mi(long_x) 
replace long_x = loc_hhid_seg1ret1__Longitude if (mi(long_x) | long_x<-1000) & loc_hhid_seg1ret1__Longitude>-1000
replace gps_comment = 1 if !mi(long_x) & mi(gps_comment)
replace long_x = loc_list__Longitude if (mi(long_x) | long_x<-1000) & loc_list__Longitude>-1000
replace gps_comment = 2 if !mi(long_x) & mi(gps_comment)
replace long_x = loc_barcode__Longitude if (mi(long_x) | long_x<-1000) & loc_barcode__Longitude>-1000
replace gps_comment = 2 if !mi(long_x) & mi(gps_comment)
replace long_x = loc_retry__Longitude if (mi(long_x) | long_x<-1000) & loc_retry__Longitude>-1000
replace gps_comment = 3 if !mi(long_x) & mi(gps_comment)
la var long_x "Longitude HH"
la var gps_comment "GPS comment"
la def lgps_comment 1 "Taken at household" 2 "Taken at EA" 3 "Taken after interview", replace
la val gps_comment lgps_comment

gen double lat_y = str_loc__Latitude if str_loc__Latitude>-1000
replace lat_y = loc_hhid_seg1ret1__Latitude if (mi(lat_y)| lat_y<-1000) & loc_hhid_seg1ret1__Latitude>-1000
replace lat_y = loc_list__Latitude if (mi(lat_y)| lat_y<-1000) & loc_list__Latitude>-1000
replace lat_y = loc_barcode__Latitude if (mi(lat_y)| lat_y<-1000) & loc_barcode__Latitude>-1000
replace lat_y = loc_retry__Latitude if (mi(lat_y)| lat_y<-1000) & loc_retry__Latitude>-1000
replace lat_y=. if lat_y<-1000
la var lat_y "Latitude HH"

gen double alt_z = str_loc__Altitude if str_loc__Altitude>-1000
replace alt_z = loc_hhid_seg1ret1__Altitude if (mi(alt_z)| alt_z<-1000) & loc_hhid_seg1ret1__Altitude>-1000
replace alt_z = loc_list__Altitude if (mi(alt_z)| alt_z<-1000) & loc_list__Altitude>-1000
replace alt_z = loc_barcode__Altitude if (mi(alt_z)| alt_z<-1000) & loc_barcode__Altitude>-1000
replace alt_z = loc_retry__Altitude if (mi(alt_z)| alt_z<-1000) & loc_retry__Altitude>-1000
replace alt_z = . if alt_z<-1000
la var alt_z "Altitude GPS"

gen double acc_xy = str_loc__Accuracy if str_loc__Accuracy>-1000
replace acc_xy = loc_hhid_seg1ret1__Accuracy if (mi(acc_xy)| acc_xy<-1000) & loc_hhid_seg1ret1__Accuracy>-1000
replace acc_xy = loc_list__Accuracy if (mi(acc_xy)| acc_xy<-1000) & loc_list__Accuracy>-1000
replace acc_xy = loc_barcode__Accuracy if (mi(acc_xy)| acc_xy<-1000) & loc_barcode__Accuracy>-1000
replace acc_xy = loc_retry__Accuracy if (mi(acc_xy)| acc_xy<-1000) & loc_retry__Accuracy>-1000
replace acc_xy = . if acc_xy<-1000
la var acc_xy "Accuracy GPS"

* Fix ID of household head
replace hhh_id = hhh_id0 if mi(hhh_id)
replace hhh_id=1 if hhh_id0==.

save "${gsdTemp}/hh_pre_clean.dta", replace

*********************************************************************
* Export data for updated sampling frame
*********************************************************************
drop if type==4
ren (id_household id_structure id_block) (hh_id str_id bl_id)
* there is one HH in the relevant structure, so hh_id has to be 1
drop if hh_id<0
replace hh_id=1 if hh_id==.b
drop if mi(n_str)
bysort strata ea bl_id str_id: egen no_hh = mean(n_hh)
bysort strata ea bl_id: egen no_str = mean(n_str)
bysort strata ea: egen no_bl = mean(n_bl)
assert no_bl==n_bl
gen strata_id = strata
order hh_id hhsize no_hh str_id no_str bl_id no_bl ea strata strata_id long_x lat_y alt_z acc_xy gps_comment
keep hh_id hhsize no_hh str_id no_str bl_id no_bl ea strata strata_id long_x lat_y alt_z acc_xy gps_comment
save "${gsdData}/0-RawOutput/hh_str_bl_ea.dta", replace
export delim using "${gsdOutput}/hh_str_bl_ea.csv", replace 

********************************************************************
*Drop administrative info & specify questions
********************************************************************
use "${gsdTemp}/hh_pre_clean.dta", clear
drop acc_xy alt_z gps_comment strata_id today examnumber modules__1 modules__2 modules__3 modules__4 modules__5 modules__6 modules__7 modules__8 modules__9 modules__10 modules__11 modules__12 modules__13 modules__14 modules__15 treat_training 
drop ea_barcode ea_barcode_check somsld ea_barcode_confirm loc_barcode__Latitude loc_barcode__Longitude loc_barcode__Accuracy loc_barcode__Altitude loc_barcode__Timestamp loc_check_barcode
drop ea_list ea_list_confirm loc_list__Latitude loc_list__Longitude loc_list__Accuracy loc_list__Altitude loc_list__Timestamp loc_check_list 
drop ea_barcode_int original_block original_str original_hh visit_n blid_seg1ret1 strid_seg1ret1 hhid_seg1ret1 loc_hhid_seg1ret1__Latitude loc_hhid_seg1ret1__Longitude loc_hhid_seg1ret1__Accuracy loc_hhid_seg1ret1__Altitude loc_hhid_seg1ret1__Timestamp loc_hhid_check
drop enum_offset block bl_replace bl_replace_reason bl_replace1 bl_replace_reason1 bl_replace2 bl_replace_reason2 bl_replace3 bl_replace_reason3 bl_replace4 bl_replace_reason4 chosen_block bl_success 
drop random_draw int_bl_rep* rep* seg_str_prev1 str_loc_check hh_success strc* seg_str seg_hh_prev1 str_loc__Latitude str_loc__Longitude str_loc__Accuracy str_loc__Altitude str_loc__Timestamp
drop hhid_seg1ret0 hh1 hh2 hh3 hh4 hh5 hh6 hh7 hh8 hh9 hh10 hh11 hh12 hh13 hh14 hh15 hh16 hh17 hh18 hh19 hh20 hh_list__0 hh_list__1 hh_list__2 hh_list__3 hh_list__4 hh_list__5 hh_list__6 hh_list__7 hh_list__8 hh_list__9 hh_list__10 hh_list__11 hh_list__12 hh_list__13 hh_list__14 hhh_id1 hhh_id1_int hhh_name hhh_id0 hh_list_separated__*
drop aa cook_source_sp electricity_fee_spec rf_lowcons1 check1 check2 check3 check4
drop contact_info phone_number follow_up_yn testimonial testimonial_consent share_phone_agencies loc_retry__Latitude loc_retry__Longitude loc_retry__Accuracy loc_retry__Altitude loc_retry__Timestamp loc_check2 enum1 int_break enum2 enum2_1 enum3__0 enum3__1 enum3__2 enum3__3 enum3__4 enum3__5 enum3__6 enum3__7 enum3__8 enum3__9 enum3__10 enum3__11 enum3__12 enum3__13 enum3__14 enum3__1000 enum4 enum5 enum6__0 enum6__1 enum6__2 enum6__3 enum6__4 enum6__5 enum6__6 enum6__7 enum6__8 enum6__9 enum6__10 enum6__11 enum6__12 enum6__13 enum6__14 enum6__1000 enum7 enum8__2 enum8__3 enum8__4 enum8__5 enum8__6 enum8__7 enum8__8 enum8__9 enum8__10 enum8__11 enum8__12 enum8__13 enum8__14 enum8__15 enum9 today_end ssSys_IRnd interview__key
drop has__errors interview__status start_time end_time duration_itw_min date_stata date itw_valid itw_invalid_reason latitude longitude accuracy latitude_str longitude_str accuracy_str gps_coord_y_n lon_min lon_max lat_min lat_max not_within_EA id_ea id_block id_structure id_household block_number_original str_number_original previous_visit_exists previous_visit_valid GPS_pair latitude_pr longitude_pr accuracy_pr distance_meters dist_previous_visit_check successful successful_valid index treat1 treat2 treat3 treat4 val1 val2 val3 val4 succ1 succ2 succ3 succ4 val_succ1 val_succ2 val_succ3 val_succ4
drop status_psu_UR_IDP status_psu_host tot_block x_min x_max y_min y_max main_uri rank_rep_uri rank_rep_uri_2 main_h rank_rep_h sample_initial_uri sample_initial_h sample_final_uri sample_final_h o_ea o_ea_2 o_ea_3 r_seq r_seq_2 r_seq_3 r_date r_ea r_ea_2 r_ea_3 r_reason test_rep o_ea_h o_ea_2_h o_ea_3_h r_seq_h r_seq_2_h r_seq_3_h r_date_h r_ea_h r_ea_2_h r_ea_3_h r_reason_h test_rep_h final_main_uri final_rep_uri final_rank_rep_uri final_rep_uri_2 final_rank_rep_uri_2 final_main_h final_rep_h final_rank_rep_h target_itw_ea nb_val_succ_itw_ea ea_status ea_valid nb_interviews_ea nb_treat1_ea nb_treat2_ea nb_treat3_ea nb_treat4_ea nb_valid_interviews_ea nb_valid_treat1_ea nb_valid_treat2_ea nb_valid_treat3_ea nb_valid_treat4_ea nb_success_interviews_ea nb_success_treat1_ea nb_success_treat2_ea nb_success_treat3_ea nb_success_treat4_ea nb_valid_success_itws_ea nb_valid_success_treat1_ea nb_valid_success_treat2_ea nb_valid_success_treat3_ea nb_valid_success_treat4_ea
drop visit_no consent electricity_str rf_sum_consumed_cereals cook_str
drop strata_name hhr_id_int hhh_id0_int hhm_unite hh_number_original
drop idp_ea_yn housingtype_s drink_water_spec cook_source spec_water_spec light_sp electricity_price_kdk toilet_ot sewage_spec land_use_disp__1000 land_use_disp__n98 land_use_disp__n99
drop waste_spec floor_material_sp roof_material_sp land_help_disp_spec housingtype_disp_s land_use_disp_s land_res_reason_disp_spec
drop land_help_disp land_res_reason_disp drink_source_disp_sp land_unit_spec land_tenure_sp land_unit_spec_disp landag_use_disp_spec social_saf_net_spec lhood_spec lhood_prev_spec
drop intremit_relation_sp intremit_mode__1000 intremit_mode__n98 intremit_mode__n99 remit12m_loc_sp remit_relation_sp remit_mode__1000 remit_mode__n98 remit_mode__n99 remit_mode_sp supp_somosom__n98 supp_somosom__n99  remit12m_before 
drop rl_raise__1000 rl_other rl_raise_prev_yn__1000 settle_dispute_spec improve_specify agent_specify agent_represent_specify sld taxes_specify__1000 taxes_specify__n98 taxes_specify__n99 taxes_other_specify disp_site_reason_spec 
drop disp_reason_spec disp_arrive_reason_spec disp_temp_return_reason_s disp_shelterpay_who__1000 disp_shelterpay_who__n98 disp_shelterpay_who__n99 disp_shelterpay_who_spec disp_shelterpay_what_spec move_no_push__1000 move_no_push__n98 
drop move_no_push__n99 move_no_push_spec move_no_pull__1000 move_no_pull__n98 move_no_pull__n99 move_no_pull_spec move_yes_push__1000 move_yes_push__n98 move_yes_push__n99 move_yes_push_spec move_no_org__1000 move_no_org__n98 move_no_org__n99 move_no_org_spec 
drop move_yes_pull__1000 move_yes_pull__n98 move_yes_pull__n99 move_yes_pull_spec move_help__1000 move_help__n98 move_help__n99 move_help_spec inf_source_add__1000 inf_source_add__n98 inf_source_add__n99 inf_source_add_sp inf_want__n98 inf_want__n99 inf_want_sp fishing_gear_used__1000 
drop fishing_gear_used__n98 fishing_gear_used__n99 fishing_equipment__n98 fishing_equipment__n99 high_season__n998 high_season__n999 low_season__n98 low_season__n99 fishing_volume__1000 fishing_volume__n98 fishing_volume__n99 fishing_use_spec shocks0__1000 shocks0_sp inf_source_sp no_success


********************************************************************
*Further tidy and save
********************************************************************
rename ea_reg region
label var region "Somali region"
sort strata interview__id
save "${gsdData}/0-RawOutput/hh_clean.dta", replace
