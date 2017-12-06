*clean and organize parent file

set more off
set seed 23081982 
set sortseed 11041952

use "${gsdData}/0-RawTemp/hh_valid.dta", clear
********************************************************************
* Relabel 'Don't know' and 'Refused to respond'
********************************************************************
* Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all

**************************************************************************
* Relabel Skip patterns: Please Refer to Questionnaire for relevance conditions
**************************************************************************
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

**************************************************************************
* Cleaning
**************************************************************************
*changing the IDP codes with multiple ea_codes (because the assigned ea_code changed in the middle of the survey)
replace ea="999000050" if full_l=="Boondheere, Safaaradda Talyaaniga, 1-1"
replace ea="999000047" if full_l=="Daynile, Beelo, 4-1"
replace ea="999000045" if full_l=="Daynile, Kulmis, 6-1"
replace ea="999000046" if full_l=="Daynile, Qiyaad, 5-1"
replace ea="999000049" if full_l=="Daynile, Saban Saban 3, 2-1"
replace ea="999000041" if full_l=="Dharkenley, Badbaado2, 10-1"
replace ea="999000040" if full_l=="Dharkenley, Beer Gadiid C, 11-1"
replace ea="999000038" if full_l=="Dharkenley, Dalada Ramla, 13-1"
replace ea="999000036" if full_l=="Dharkenley, Hosweyne, 15-1"
replace ea="999000035" if full_l=="Dharkenley, Nunow, 16-1"
replace ea="999000034" if full_l=="Dharkenley, Samafale, 17-1"
replace ea="999000032" if full_l=="Hodan, Balcad, 19-1"
replace ea="999000031" if full_l=="Hodan, Darasalam, 20-1"
replace ea="999000029" if full_l=="Hodan, Labsame, 22-1"
replace ea="999000027" if full_l=="Hodan, Unlay, 24-1"
replace ea="999000025" if full_l=="Kaaraan, Atowbal 1, 26-1"
replace ea="999000024" if full_l=="Wadajir, Rajo A, 27-1"

*labels not automated by SurveyCTO
label values ea_zone lEA_zone
gen date=date(gg_stime,"YMDhms")
format %td date
label variable ea_zone "Zone"
label variable ea "Enumeration area"
label variable full_l "Enumeration area label"
label variable hhid "Household ID"
label variable treat "Treat"
label variable hhr_id "Respondent ID"
label variable hhh_id "Household head ID"
label variable consent "Enumerator has consent to continue the interview"
label variable l_enterprises_n "Number of enterprise"
label variable l_fulltime_total "Total fulltime workers"
label variable l_parttime_total "Total part-time workers"

*assert all non-interviews dropped
local consent "athome adult maycontinue consent"
foreach c of local consent {
	assert `c'==1
}
drop `consent'

*drop useless variables 
drop space deviceid subscriberid gg_* gg_* audio_*min 
drop type confirm* examnumber modules
drop ea_reg ea_dist ea_idp ea_sett ea_nonidp ea_confirm idp_ea_yn firsttime ea_block_confirm
drop reg_string1 reg_string2 curr_filter state_filter long_form zone_l lat_min lat_max long_min long_max seg z
drop seg_hh* hhm_name*
drop hhid_*
drop cl_hh_rep setofstructure_r r_str seg_str upper_bound num_draws setofstructure_r setofrandom_draws unique_draws treat_classic random_seg treat_seg
drop setof*
drop validnames_total linebreak roster
drop hhm_all hhh_id0 hhr_name hhh_name0 hhh_presence hhh_id1 hhh_options hhh_name
drop isvalidated submissiondate start_time end_time my_date
drop remitmore l_lstock_y l_gum_y l_remit_y l_telec_y l_omanuf_y l_taxi_y l_oact_y l_seasonal_total l_totalworkers top3_shocks
drop sws main_small_bus
*drop variables from sample weights 
drop ea_original sample_initial_ea sample_final_ea o_ea r_seq_ea r_reason_ea flag ea_code full_l1 full_l2 full_l3 full_l31 full_l21 ea_idp_final ea_mog eb_full sample_initial_eb sample_final_eb o_eb r_seq_eb r_eb r_reason_eb valid_interviews_eb
*drop empty variables
missings dropvars, force

*organise GPS data
local gps latitude longitude accuracy
foreach v of local gps {
	replace loc`v'=loc_retry`v' if loc`v'==.
}
drop loc_retry* locshort* loc_check* localtitude* latx longx accx 
ren (loclatitude loclongitude locaccuracy) (latx longx accx)

*organise enumerator name, ID and team
ren enum_identity name_stata
*introduce manual corrections
replace name_stata="Ali Mohamed Hassan" if ea_zone==3 & (mod_init_dur==26 | mod_init_dur==9 | mod_init_dur==16 | mod_init_dur==10) & (mod_0_dur==44 | mod_0_dur==95 | mod_0_dur==41 | mod_0_dur==32) & (full_l=="Laas Caanood, 140-1001-0089"  | full_l=="Dharkayn Geenyo, 140-1012-0001" | full_l=="Laas Caanood, 140-1001-0049") & hhid<9
replace name_stata="Abdikadir Ali Farah" if ea_zone==2 & (mod_init_dur==11 | mod_init_dur==12 | mod_init_dur==14 | mod_init_dur==18 | mod_init_dur==19) & (mod_0_dur==115 | mod_0_dur==71 | mod_0_dur==49 | mod_0_dur==58 | mod_0_dur==56 | mod_0_dur==46 | mod_0_dur==38 | mod_0_dur==52)  & (full_l=="Bosaso, Bulo eley BB, 15-1"  | full_l=="Bosaso, Bulo Mingis B, 19-1"  | full_l=="Bosaso, Bulo Mingis A, 13-1" | full_l=="Bosaso, Banadir BB, 17-1")  & hhid>5
replace name_stata="Suleekha Abdi Ibrahim" if ea_zone==3 & hhid<5 & (full_l=="Maluugta, 120-1011-0001"  | full_l=="Hargeysa, 120-1001-0579"  | full_l=="Hargeysa, 120-1001-0412"  | full_l=="Hargeysa, 120-1001-0049"  | full_l=="Geeddeeble, 120-1024-0001" | full_l=="Caada, 120-2043-0001")  
replace name_stata="Sa'ada Ahmed Abdi" if ea_zone==3 & hhid>=5 & hhid<=8 & (full_l=="Maluugta, 120-1011-0001"  | full_l=="Hargeysa, 120-1001-0579"  | full_l=="Hargeysa, 120-1001-0412"  | full_l=="Hargeysa, 120-1001-0049"  | full_l=="Geeddeeble, 120-1024-0001" | full_l=="Caada, 120-2043-0001")  
merge m:m name_stata using "${gsdData}/0-RawTemp/enum.dta", keep(match)
drop if key==""
*assert all master are matched - if not, list names to be added to csv
cap assert _merge!=1
if _rc!=0 {
	di "Add names to '...0-RawInput/enum.csv'"
	list name_stata if _merge==1
}
drop _merge	
gen enum_team_label = t0+", "+t1
labmask enum_team_tidy, values(enum_team_label)

*drop untidy enumerator variables
drop team_id enum_id enum_name team_name enum_check name_stata qr_id qr_idcheck qr_noid noqrid_1 noqrid_2 noqrid_3 noqrid noqrid_conf noqrid_conf_pld name_enum_pull t1 t0 enum_team_label
ren (enum_team_tidy enum_name_tidy) (enum_team enum_name)

*label variables
label variable enum_team "Enumerator team"
label variable enum_name "Enumerator name"
label var date "Date of the interview"
label var ret "Is this a returning visit?"
label var ea_block "ID for each block"
label var nhhm "Number of hh member"
label var res_age "Respondent's age"
label var res_work "Respondent work?"
label var res_active "Is the respondent active"
order *_dur, last
order key ea_zone ea date enum_team enum_name 
order strata,after(ea_zone)
rename ea_zone zone
la def lzone 1 "Other" 2 "Puntland" 3 "Somaliland" 4 "South Central", replace
la val zone lzone


*drop variables with open answers, multiple numeric entries and/or in Somali 
*drop other_income_sources house_type_spec drink_water_spec treat_water_spec cooking_spec toilet_type_spec floor_material_spec roof_material_spec remitchangeother main_market_other oop_visit_provider oop_visit_provider_o oop_overn_provider oop_overn_provider_o improve_specify agent_specify dispute_specify agent_represent_specify taxes_specify l_otheractivity l_mainprod l_fhhmreturn_spec l_acquire_spec l_assoc__spec l_regother l_supconf_spec l_advicebusiness_spec l_collat_spec l_transactions l_transactions_spec l_settledispute_spec shocks0 enum3 enum6 enum8 enum9

save "${gsdData}/0-RawTemp/hh_clean.dta", replace

