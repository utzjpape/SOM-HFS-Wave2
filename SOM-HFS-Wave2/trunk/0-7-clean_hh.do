*Clean and organize parent file

set more off
set seed 23081982 
set sortseed 11041952

use "${gsdData}/0-RawTemp/hh_valid_successful_complete.dta", clear

*Include the correct strata
rename ea psu_id
merge m:1 psu_id using "${gsdDataRaw}/List_Strata_EAs.dta", nogen keep(master match) keepusing(strata_name_list strata_id_list)
rename psu_id ea
assert strata_id== strata_id_list
labmask strata_id, values(strata_name)
drop strata strata_name_list strata_id_list
rename strata_id strata
order strata strata_name type_pop, after(loc_check_barcode)

*Include the correct type of population 
drop type
gen type=1 if (type_pop=="Urban/Rural" | type_pop=="Urban/Rural and Host") & inlist(strata,26,28,30,31,33,37,39,41,43,45,49,51,52,54,57)
replace type=2 if (type_pop=="Urban/Rural" | type_pop=="Urban/Rural and Host") & inlist(strata,25,27,29,32,34,38,40,42,44,48,50,53,55,56)
replace type=3 if (type_pop=="Urban/Rural" | type_pop=="Urban/Rural and Host") & inlist(strata,46,47)
replace type=4 if type_pop=="IDP" 
replace type=5 if type_pop=="Host Only"
label define type_hh 1 "Urban" 2 "Rural" 3 "Urban & Rural" 4 "IDP" 5 "Host"
label values type type_hh
label var type "Urban/Rural/IDP or Host"
drop type_pop

*Correctly identify host households for EAs with interviews for both urban/rural and host 
*EA 198455 2 urban replacement and 1 main host
//PENDING INTERVIEWS FROM THIS EA

*EA 199580 1 replacement urband and 2 replacement host
//PENDING INTERVIEWS FROM THIS EA

*EA 199572 1 replacement urband and 1 main host
//PENDING INTERVIEWS FROM THIS EA

*EA 199578 1 replacement urband and 1 main host
replace type=5 if ea==199578

*EA 199582 1 replacement urband and 1 main host
//PENDING INTERVIEWS FROM THIS EA

*EA 198804 3 main urband and 1 main host
//PENDING INTERVIEWS FROM THIS EA

*EA 205188 1 replacement urband and 1 main host
//PENDING INTERVIEWS FROM THIS EA

*EA 198980 1 replacement urband and 1 main host
replace type=5 if ea==198980

*EA 198902 1 replacement urband and 1 replacement host
//PENDING INTERVIEWS FROM THIS EA

*EA 199371 1 main urban and 1 main host
gen rand_199371=uniform() if ea==199371
sort rand_199371
gen n_199371=_n if ea==199371
replace type=5 if ea==199371 & n_199371<=12
drop rand_199371 n_199371

*EA 202154 1 replacement urband and 1 main host
//PENDING INTERVIEWS FROM THIS EA
replace type=5 if ea==202154

*EA 202160 1 replacement urband and 1 main host
//PENDING INTERVIEWS FROM THIS EA
replace type=5 if ea==202160

*EA 198058 3 replacement urband and 1 main host
//PENDING INTERVIEWS FROM THIS EA

*EA 198082 3 main urband and 1 main host
//PENDING INTERVIEWS FROM THIS EA

*EA 198009 3 main urband and 1 main host
gen rand_198009=uniform() if ea==198009
sort rand_198009
gen n_198009=_n if ea==198009
replace type=5 if ea==198009 & n_198009<=12
drop rand_198009 n_198009

*EA 198004 3 main urband and 1 main host
//PENDING INTERVIEWS FROM THIS EA

*EA 198121 3 replacement urband and 1 replacement host
//PENDING INTERVIEWS FROM THIS EA

*EA 198038 3 main urband and 2 main host
//PENDING INTERVIEWS FROM THIS EA


*Drop administrative info
drop today examnumber modules__1 modules__2 modules__3 modules__4 modules__5 modules__6 modules__7 modules__8 modules__9 modules__10 modules__11 modules__12 modules__13 modules__14 modules__15 treat_training 
drop ea_barcode ea_barcode_check somsld sld ea_barcode_confirm loc_barcode__Latitude loc_barcode__Longitude loc_barcode__Accuracy loc_barcode__Altitude loc_barcode__Timestamp loc_check_barcode
drop ea_list ea_list_confirm loc_list__Latitude loc_list__Longitude loc_list__Accuracy loc_list__Altitude loc_list__Timestamp loc_check_list 
drop ea_barcode_int original_block original_str original_hh visit_n blid_seg1ret1 strid_seg1ret1 hhid_seg1ret1 loc_hhid_seg1ret1__Latitude loc_hhid_seg1ret1__Longitude loc_hhid_seg1ret1__Accuracy loc_hhid_seg1ret1__Altitude loc_hhid_seg1ret1__Timestamp loc_hhid_check
drop enum_offset beh_treat_opt no_success block bl_replace bl_replace_reason bl_replace1 bl_replace_reason1 bl_replace2 bl_replace_reason2 bl_replace3 bl_replace_reason3 bl_replace4 bl_replace_reason4 chosen_block bl_success n_str_no_success__* str_no_success
drop random_draw int_bl_rep* rep* seg_str_prev1 n_hh hh_no_success n_hh_no_success__* str_loc_check hh_success strc* seg_str seg_hh_prev1 str_loc__Latitude str_loc__Longitude str_loc__Accuracy str_loc__Altitude str_loc__Timestamp
drop hhid_seg1ret0 hh1 hh2 hh3 hh4 hh5 hh6 hh7 hh8 hh9 hh10 hh11 hh12 hh13 hh14 hh15 hh16 hh17 hh18 hh19 hh20 hh_list__0 hh_list__1 hh_list__2 hh_list__3 hh_list__4 hh_list__5 hh_list__6 hh_list__7 hh_list__8 hh_list__9 hh_list__10 hh_list__11 hh_list__12 hh_list__13 hh_list__14 hhh_id1 hhh_id1_int hhh_name hhh_id hh_list_separated__*
drop aa cook_source_sp electricity_fee_spec rf_lowcons1 check1 check2 check3 check4
drop contact_info phone_number follow_up_yn testimonial testimonial_consent share_phone_agencies loc_retry__Latitude loc_retry__Longitude loc_retry__Accuracy loc_retry__Altitude loc_retry__Timestamp loc_check2 enum1 int_break enum2 enum2_1 enum3__0 enum3__1 enum3__2 enum3__3 enum3__4 enum3__5 enum3__6 enum3__7 enum3__8 enum3__9 enum3__10 enum3__11 enum3__12 enum3__13 enum3__14 enum3__1000 enum4 enum5 enum6__0 enum6__1 enum6__2 enum6__3 enum6__4 enum6__5 enum6__6 enum6__7 enum6__8 enum6__9 enum6__10 enum6__11 enum6__12 enum6__13 enum6__14 enum6__1000 enum7 enum8__2 enum8__3 enum8__4 enum8__5 enum8__6 enum8__7 enum8__8 enum8__9 enum8__10 enum8__11 enum8__12 enum8__13 enum8__14 enum8__15 enum9 today_end ssSys_IRnd interview__key
drop has__errors interview__status start_time end_time duration_itw_min date_stata date itw_valid itw_invalid_reason latitude longitude accuracy latitude_str longitude_str accuracy_str gps_coord_y_n lon_min lon_max lat_min lat_max not_within_EA id_ea id_block id_structure id_household block_number_original str_number_original previous_visit_exists previous_visit_valid GPS_pair latitude_pr longitude_pr accuracy_pr distance_meters dist_previous_visit_check successful successful_valid index treat1 treat2 treat3 treat4 val1 val2 val3 val4 succ1 succ2 succ3 succ4 val_succ1 val_succ2 val_succ3 val_succ4
drop status_psu_UR_IDP status_psu_host tot_block x_min x_max y_min y_max main_uri rank_rep_uri rank_rep_uri_2 main_h rank_rep_h sample_initial_uri sample_initial_h sample_final_uri sample_final_h o_ea o_ea_2 o_ea_3 r_seq r_seq_2 r_seq_3 r_date r_ea r_ea_2 r_ea_3 r_reason test_rep o_ea_h o_ea_2_h o_ea_3_h r_seq_h r_seq_2_h r_seq_3_h r_date_h r_ea_h r_ea_2_h r_ea_3_h r_reason_h test_rep_h final_main_uri final_rep_uri final_rank_rep_uri final_rep_uri_2 final_rank_rep_uri_2 final_main_h final_rep_h final_rank_rep_h target_itw_ea nb_val_succ_itw_ea ea_status ea_valid nb_interviews_ea nb_treat1_ea nb_treat2_ea nb_treat3_ea nb_treat4_ea nb_valid_interviews_ea nb_valid_treat1_ea nb_valid_treat2_ea nb_valid_treat3_ea nb_valid_treat4_ea nb_success_interviews_ea nb_success_treat1_ea nb_success_treat2_ea nb_success_treat3_ea nb_success_treat4_ea nb_valid_success_itws_ea nb_valid_success_treat1_ea nb_valid_success_treat2_ea nb_valid_success_treat3_ea nb_valid_success_treat4_ea
drop visit_no consent electricity_str rf_sum_consumed_cereals cook_str
drop strata_name n_str hhr_id_int hhh_id0_int hhm_unite hh_number_original

*Include lables for variables without them
label var interview__id "Unique Household ID" 
label var block_id "Block" 
rename nhhm hhsize 
label var hhsize "Household size"
label var nadults "No. Adults in household"
label var water_home "Household has water at home"
label var electricity "Household has electricity"
label var migr_idp "IDP or displaced household"
*Order variables
order interview__id team_id enum_id ea_reg strata type ea block_id
order mod_opt hhsize nadults , after(n_ints)

*Rename variables 
rename return1 return

* Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist interview__id-shock_2 {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}

*Review skip patterns and introduce .z to identify not administered questions
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

**NEXT t_water_disp


*Label values 
label define lyesno 0 "No" 1 "Yes" .a "Don't know" .b "Refused to respond" .z "Not administered" 
label values migr_idp lyesno

local variables migr_disp migr_disp_past hhh_absence_reason disp_hhm_otherloc land_legal_main land_own_dur_n_main ///
      land_legal_main_d tenant_legal water_time light electricity_phone electricity_choice electricity_price electricity_price_curr electricity_fee /// 
      electricity_price_perception electricity_hours electricity_blackout share_num	sewage acc_road_use ///
	  housingtype_disp housingtype_disp_s tenure_disp land_legal_main_disp land_legal_main_disp_d land_use_disp__1 land_use_disp__2 land_use_disp__3 land_use_disp__4 land_use_disp__5 ///
	  land_use_disp__6 land_use_disp__7 land_use_disp__1000 land_use_disp__n98 land_use_disp__n99 land_use_disp_s land_res_disp land_help_disp land_help_disp_spec land_res_reason_disp land_res_reason_disp_spec ///
	  land_back_disp drink_source_disp drink_source_disp_sp t_water_disp t_market_disp t_edu_disp thealth_disp light_disp toilet_disp floor_material_disp roof_material_disp
	  
foreach variable in `variables' {
	label define `variable' .a "Don't know" .b "Refused to respond" .z "Not administered", modify
}

foreach var in water_home electricity land_use_disp__1 land_use_disp__2 land_use_disp__3 land_use_disp__4 land_use_disp__5 land_use_disp__6 land_use_disp__7 {
	label values `var' lyesno
	
}






*Drop 
drop idp_ea_yn housingtype_s drink_water_spec cook_source spec_water_spec light_sp electricity_price_kdk toilet_ot sewage_spec land_use_disp__1000 land_use_disp__n98 land_use_disp__n99
drop waste_spec floor_material_sp roof_material_sp land_help_disp_spec housingtype_disp_s land_use_disp_s land_res_reason_disp_spec
drop land_help_disp land_res_reason_disp drink_source_disp_sp

/*
*Relabel Skip patterns: Please Refer to Questionnaire for relevance conditions
* Module D
foreach v of varlist rent_own* {
	assert missing(`v') if house_ownership!=1
	recode `v' (.=.z) if house_ownership!=1
}
tab1 rent*,m

foreach v of varlist rentn_own* {
	assert missing(`v') if house_ownership<=1
	recode `v' (.=.z) if house_ownership<=1
}
tab1 rentn*,m

foreach v in land_owned1 ownership_land1 {
	assert missing(`v') if house_ownership!=2 & house_ownership<=1
	recode `v' (.=.z) if house_ownership!=2 & house_ownership<=1
}

foreach v in land_used ownership_land2 land_owned2 plot2_ag {
	assert missing(`v') if house_ownership_own2!=1
	recode `v' (.=.z) if house_ownership_own2!=1
}

foreach v in remit12m_amount remit12m_amount_c remit12m_amount_kdk {
	assert missing(`v') if remit12m!=1
	recode `v' (.=.z) if remit12m!=1
}

assert missing(remit12mbefore) if remit12m==1
recode remit12mbefore (.=.z) if remit12m==1

*assert missing(remitmoreless) if !(remit12m==1 | (remit12m==0 & remit12mbefore<0) | (remit12m<0 & remit12mbefore>=0))
*recode remitmoreless (.=.z) if !(remit12m==1 | (remit12m==0 & remit12mbefore<0) | (remit12m<0 & remit12mbefore>=0))

assert missing(remitchange) if !(remitmoreless>0 | (remit12m!=1 & remit12mbefore==1))
recode remitchange (.=.z) if !(remitmoreless>0 | (remit12m!=1 & remit12mbefore==1))


* Module E
foreach v of varlist e_other_* {
	assert missing(`v') if e_otheritems!=1
	recode `v' (.=.z) if e_otheritems!=1
}

* Module F 
foreach v of varlist f_other_* {
	assert missing(`v') if f_otheritems!=1
	recode `v' (.=.z) if f_otheritems!=1
}

* Module J
foreach v of varlist doc_n police_n {
	assert missing(`v'_bribe) if `v'<=0 
	recode `v'_bribe (.=.z) if `v'<=0
}

assert missing(ag_rep_nonsomaliland) if ea_zone==3
recode ag_rep_nonsomaliland (.=.z) if ea_zone==3

assert missing(ag_rep_somaliland) if ea_zone!=3
recode ag_rep_somaliland (.=.z) if ea_zone!=3

* Module K
* No South Central
foreach v of varlist meals_adult meals_adult_kdk meals_childrenu5 meals_childrenu5_kdk nomoney cop_lesspreferred cop_lesspreferred_kdk cop_limitportion cop_limitportion_kdk cop_limitadult cop_limitadult_kdk cop_reducemeals cop_reducemeals_kdk cop_borrowrely cop_borrowrely_kdk cop_skip cop_skip_kdk cop_collect cop_collect_kdk cop_soldmore cop_eatelsewhere cop_spentsav cop_seeds cop_borrow cop_sellassets cop_reduceexp cop_migrate cop_beg cop_sellfemales cop_contsell cop_sellmonths {	
	assert missing(`v') if ea_zone==4
	* We don't want to touch string variables, so identify them first
	capture confirm str var `v'
	if _rc!=0 {
		recode `v' (.=.z) if ea_zone==4
	}
}

foreach v of varlist cop_lesspreferred cop_lesspreferred_kdk cop_limitportion cop_limitportion_kdk cop_limitadult cop_limitadult_kdk cop_reducemeals cop_reducemeals_kdk cop_borrowrely cop_borrowrely_kdk cop_skip cop_skip_kdk cop_collect cop_collect_kdk {
	assert missing(`v') if nomoney!=1
	recode `v' (.=.z) if nomoney!=1
}

assert missing(cop_contsell) if cop_soldmore!=1
recode cop_contsell (.=.z) if cop_soldmore!=1
assert missing(cop_sellmonths) if cop_soldmore!=1 & cop_contsell!=1
recode cop_sellmonths (.=.z) if cop_soldmore!=1 & cop_contsell!=1

* Module M
* Module was not administered in South Central
foreach v of varlist l_* {	
	assert missing(`v') if ea_zone==4
	* We don't want to touch string variables, so identify them first
	capture confirm str var `v'
	if _rc!=0 {
		recode `v' (.=.z) if ea_zone==4
	}
}

* The following questions were not administered if the household owned no enterprises
foreach v of varlist l_enterprise_main l_mainprod l_sic1 l_sic1_kdk l_sic2 l_sic2_kdk l_sic3 l_sic3_kdk l_fhhm l_fhhmabroad l_fhhmcountry l_fhhmcountryspec l_fhhmreturn l_fhhmreturn_spec l_coownersm l_coownersm_kdk l_coownersf l_coownersf_kdk l_acquire l_acquire_spec l_famowned l_joined l_joined_spec l_entstart_y l_entstart_m l_entstart_kdk l_entstart_warn l_assoc l_assoc_ l_assoc__spec setofrep_reg l_reglocalyn l_regease l_regfee l_regfee_c l_regfeekdk l_reggift l_reglocalyear l_reglocalyear_warn l_regother l_regother_spec l_telecom l_elec l_transp l_land l_tax l_customs l_courts l_labourreg l_pooreduc l_buspermits l_acctofin l_polenv l_crime l_unregcomp l_accwater l_wastedisp l_intconn l_electricitysourceyn l_electricitysource l_poweroutages l_outagedur l_outagedur_kdk l_elechours l_elechours_kdk l_entwater l_internetyn l_intaccess l_intaccess_spec l_int_purch l_int_delserv l_int_emailclient l_int_website l_int_rnd l_int_ad l_fulltime_pm l_fulltime_pm_kdk l_fulltime_um l_fulltime_um_kdk l_fulltime_pf l_fulltime_pf_kdk l_fulltime_uf l_fulltime_uf_kdk l_fulltime_total l_parttime_pm l_parttime_pm_kdk l_parttime_um l_parttime_um_kdk l_parttime_pf l_parttime_pf_kdk l_parttime_uf l_parttime_uf_kdk l_parttime_total l_seasonal_pm l_seasonal_pm_kdk l_seasonal_um l_seasonal_um_kdk l_seasonal_pf l_seasonal_pf_kdk l_seasonal_uf l_seasonal_uf_kdk l_seasonal_total l_totalworkers l_wunder30 l_wunder30_kdk l_wfamily l_wfamily_kdk l_wexpat l_wexpat_kdk l_mainpercent l_totalsales_val l_totalsales_cur l_totalsaleskdk l_suppsub l_suppinf l_supconf l_supconf_spec l_labour_val l_labour_cur l_labourkdk l_rawint_val l_rawint_cur l_rawintkdk l_fuel_val l_fuel_cur l_fuelkdk l_eleccost_val l_eleccost_cur l_eleccostkdk l_mach_val l_mach_cur l_machkdk l_land_val l_land_cur l_landkdk l_prodcosto_val l_prodcosto_cur l_prodcostokdk l_records l_finproducts l_advicebusiness l_advicebusiness_spec l_loanyn l_loan_nreason l_loan_nreason_spec l_loankind l_loankind_spec l_loankindrecent l_loanreason l_loanreason_spec l_appoutcome l_loanamount_val l_loanamount_cur l_loanamountkdk l_collat_yn l_collat l_collat_spec l_collat_val l_collat_c l_collatkdk l_loansn l_loansn_kdk l_loans_val l_loans_cur l_loanskdk l_mobile l_transactions l_transactions_spec l_recremit l_latepay l_settledispute l_settledispute_spec l_busdisp l_busdispo l_busconfl l_busconfl_spec l_daystoresolve l_daystoresolve_kdk l_payforsec l_theftloss {
	assert missing(`v') if l_enterprises_n==0
	* We don't want to touch string variables, so identify them first
	capture confirm str var `v'
	if _rc!=0 {
		recode `v' (.=.z) if l_enterprises_n==0
	}
}

assert missing(l_enterprise_main) if l_enterprises_n<=1
recode l_enterprise_main (.=.z)  if l_enterprises_n<=1

assert missing(l_sic2) if l_sic1_kdk!=1
recode l_sic2 (.=.z) if l_sic1_kdk!=1

assert missing(l_sic3) if l_sic2_kdk!=1
recode l_sic3 (.=.z) if l_sic2_kdk!=1

foreach v of varlist l_fhhmcountry l_fhhmreturn {
	assert missing(`v') if l_fhhmabroad!=1
	recode `v' (.=.z)  if l_fhhmabroad!=1
}

assert missing(l_joined) if l_famowned!=1
recode l_joined (.=.z) if l_famowned!=1

assert missing(l_entstart_warn) if l_entstart_y>=1900
recode l_entstart_warn (.=.z) if l_entstart_y>=1900

assert missing(l_assoc_) if l_assoc!=1
recode l_assoc_ (.=.z) if l_assoc!=1

assert missing(l_regease) if l_reglocalyn!=1
recode l_regease (.=.z) if l_reglocalyn!=1

foreach v in l_regfee_c l_regfeekdk l_reggift l_reglocalyear l_regfee {
	assert missing(`v') if l_reglocalyn!=1
	recode `v' (.=.z) if l_reglocalyn!=1
}

* l_regother is select multiple

foreach v in l_telecom l_elec l_transp l_land l_tax l_customs l_courts l_labourreg l_pooreduc l_buspermits l_acctofin l_polenv l_crime l_unregcomp l_accwater l_wastedisp l_intconn l_electricitysourceyn l_electricitysource {
	assert missing(`v') if l_enterprises_n==0
	recode `v' (.=.z) if l_enterprises_n==0
}

assert missing(l_electricitysource) if l_electricitysourceyn!=1
recode l_electricitysource (.=.z) if l_electricitysourceyn!=1

assert missing(l_poweroutages) if l_electricitysourceyn!=1
recode l_poweroutages (.=.z) if l_electricitysourceyn!=1


foreach v in l_outagedur l_outagedur_kdk l_elechours l_elechours_kdk {
	assert missing(`v') if l_poweroutages<=0
	recode `v' (.=.z) if l_poweroutages<=0
}

foreach v in l_intaccess l_int_purch l_int_delserv l_int_emailclient l_int_website l_int_rnd l_int_ad {
	assert missing(`v') if l_internetyn!=1
	recode `v' (.=.z) if l_internetyn!=1
}

assert missing(l_loan_nreason) if l_loanyn!=0
recode l_loan_nreason (.=.z) if l_loanyn!=0

foreach v in l_loankind l_loanreason l_appoutcome l_loanamount_val l_loanamount_cur l_loanamountkdk l_collat_yn {
	assert missing(`v') if l_loanyn!=1
	recode `v' (.=.z) if l_loanyn!=1
}	

foreach v in l_collat_val l_collat_c l_collatkdk l_collat {
	assert missing(`v') if l_collat_yn!=1
	recode 	`v' (.=.z) if l_collat_yn!=1
}
	
foreach v in l_loans_val l_loans_cur l_loanskdk {
	assert missing(`v') if l_loansn<=0
	recode `v' (.=.z) if l_loansn<=0
}

foreach v in l_busdisp l_busdispo {
	assert missing(`v') if l_settledispute<=0
	recode `v' (.=.z) if l_settledispute<=0
}

* Section N
* Part was not administered in South-Central
foreach v of varlist shock_1 shock_2 shock_3 {
	assert missing(`v') if ea_zone==4
	recode `v' (.=.z) if ea_zone==4
}
	
assert missing(shock_1) if shocks0<="0"
recode shock_1 (.=.z) if shocks0<="0"

assert missing(shock_2) if shocks0<="1"
recode shock_2 (.=.z) if shocks0<="1"

assert missing(shock_3) if strlen(shocks0) < 2
recode shock_3 (.=.z) if strlen(shocks0) < 2

*/



*Further cleaning and tidy 
rename ea_reg region
label var region "Somali region"



sort strata interview__id
save "${gsdData}/0-RawTemp/hh_clean.dta", replace

