*Clean and organize child file regarding household members

set more off
set seed 23082980 
set sortseed 11042955


********************************************************************
*Household members roster for all households 
********************************************************************
use "${gsdData}/0-RawTemp/hhroster_age_valid_successful_complete.dta", clear
drop hh_list hhm_relation_other birthplace_specify legal_id_type__1000 legal_id_type__n98 legal_id_type__n99 legal_id_spec hhm_edu_level_other absent_specify emp_7d_inac_sp hhm_job_search_no_spec emp_inac_sub_spec hhm_job_obs_spec hhm_job_support_spec emp_12m_additional__n98 emp_12m_additional__n99 resum_empl_reason_spec delivery_spec deliveryassist_spec interview__key hhm_away_m_int hhm_edu_reason_sp
drop emp_7d_p emp_7d_a emp_7d_f emp_7d_b emp_7d_h emp_7d_a_yn emp_7d_p_yn emp_7d_f_yn emp_7d_b_yn emp_7d_h_yn emp_7d_count emp_7d_prim_int

*Drop incomplete household member responses
drop if hhm_age<0 & hhm_gender<0 & hhm_relation<0


*Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist hhroster_age__id-interview__id {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}
order interview__id hhroster_age__id hhm_age hhm_gender hhm_relation hhm_parent hhm_parent_alive hhm_mar_status hhm_mar_age born_somalia birthplace_som birthplace_outsom legal_id legal_id_type__* 
order hhm_edu_years_kdk, before(hhm_edu_years)
order emp_7d_hours_kdk, before(emp_7d_hours) 
order emp_prev_hours_kdk, before (emp_prev_hours)

*Clean some variables
merge m:1 interview__id  using "${gsdData}/0-RawOutput/hh_clean.dta", assert(match) nogen keepusing(hhh_id0 migr_idp hhr_id)
replace hhm_relation=1 if hhroster_age__id==hhh_id0 & hhh_id0<.
*Assing household head 
replace hhm_gender=1 if hhroster_age__id==1 & interview__id=="a285a77c94db45c79aec91e4fd401b53"
replace hhm_relation=1 if hhroster_age__id==1 & interview__id=="a285a77c94db45c79aec91e4fd401b53"
label define hhm_relation 1 "Household Head" .a "Don't know" .b "Refused to respond" .z "Not administered", modify
drop hhh_id0

*Introduce skip patterms 
replace hhm_parent=.z if hhm_relation==3 | hhm_age>=18
replace hhm_parent_alive=.z if hhm_parent!=0
replace hhm_mar_age=.z if hhm_mar_status==6 | hhm_mar_status>=.
replace born_somalia=.z if hhm_relation!=1
replace birthplace_som=.z if hhm_relation!=1 | born_somalia!=1 
replace birthplace_outsom=.z if hhm_relation!=1 | born_somalia!=0
forval i=1/14 {
	replace legal_id_type__`i'=.z if legal_id!=1
}
replace migr_pasture=.z if hhm_away_m<=0 | hhm_away_m>=.
replace nomad=.z if migr_pasture!=1
replace migr_reason=.z if hhm_relation==1 | hh_alwayslived!=0
replace migr_from=.z if hhm_relation==1 | migr_reason!=1
foreach var in hhm_read hhm_write hhm_edu_current hhm_edu_k_current hhm_edu_reason hhm_edu_disp hhm_edu_ever hhm_edu_years hhm_edu_years_kdk hhm_edu_level absent_duration_yn absent_reason {
	replace `var'=.z if hhm_age<=5 | hhm_age>=.
}
replace hhm_edu_reason=.z if hhm_edu_current!=0 | hhm_age>20
replace hhm_edu_disp=.z if migr_idp!=1
replace hhm_edu_ever=.z if hhm_edu_current!=0 | hhm_edu_disp!=0
replace hhm_edu_years_kdk=.z if hhm_edu_ever!=1 & hhm_edu_current!=1 & hhm_edu_disp!=1
replace hhm_edu_years=.z if hhm_edu_years_kdk>=.
replace hhm_edu_level=.z if  hhm_edu_ever!=1 & hhm_edu_current!=1 & hhm_edu_disp!=1
replace absent_duration_yn=.z if hhm_edu_current!=1 | hhm_age>18
replace absent_reason=.z if absent_duration_yn!=1
foreach var in hhm_resp emp_7d_paid emp_7d_busi emp_7d_help emp_7d_farm emp_7d_appr emp_7d_active emp_7d_temp emp_7d_inac emp_12m_active emp_12m_detail emp_ever_active emp_ever_detail  {
	replace `var'=.z if hhm_age<10
}
replace hhm_resp=.z if hhroster_age__id==hhr_id
replace emp_7d_temp=.z if emp_7d_active!=0
replace emp_7d_inac=.z if emp_7d_temp!=1
replace emp_12m_active=.z if emp_7d_active!=0 | emp_7d_temp!=0
replace emp_12m_detail=.z if emp_12m_active!=1
replace emp_ever_active=.z if emp_12m_active!=0
replace emp_ever_detail=.z if emp_ever_active!=1
foreach var in hhm_job_search hhm_job_search_no hhm_available emp_inac_sub unemp_7d_dur hhm_job_search_dur hhm_job_obs hhm_job_support unemp_7d {
	replace `var'=.z if emp_7d_active!=0 | emp_7d_temp!=0
}
replace hhm_job_search_no=.z if hhm_job_search!=0 
replace hhm_available=.z if hhm_job_search!=1
replace emp_inac_sub=.z if hhm_job_search!=0
replace unemp_7d_dur=.z if hhm_job_search!=1
replace hhm_job_search_dur=.z if hhm_job_search!=1 
replace hhm_job_obs=.z if hhm_job_search!=1  
replace hhm_job_support=.z if hhm_job_search!=1  
foreach var in emp_7d_prim emp_7d_months emp_7d_hours emp_7d_hours_kdk emp_7d_prim_isic uemp_want emp_12m_additional_yn emp_12m_additional__1 emp_12m_additional__2 emp_12m_additional__3 emp_12m_additional__4 emp_12m_additional__5 {
	replace `var'=.z if emp_7d_active!=1 & emp_7d_temp!=1
}
replace emp_7d_hours=.z if emp_7d_hours_kdk>=.
replace emp_12m_additional_yn=.z if emp_7d_active!=1 & emp_7d_temp!=1 
forval i=1/5 {
	replace emp_12m_additional__`i'=.z if emp_12m_additional_yn!=1
}
foreach var in emp_prev_d emp_prev emp_prev_prim_isic emp_prev_change emp_prev_months emp_prev_hours_kdk emp_prev_hours resum_empl resum_empl_reason {
	replace `var'=.z if migr_idp!=1 | hhm_age<10 | emp_ever_active==0
}
replace emp_prev=.z if emp_prev_d!=1
replace emp_prev_prim_isic=.z if emp_prev_d!=1 
replace emp_prev_change=.z if emp_prev_d!=1 
replace emp_prev_months=.z if emp_prev_d!=1
replace emp_prev_hours=.z if emp_prev_d!=1 | emp_prev_hours_kdk>=.
replace resum_empl=.z if migr_idp!=1 | emp_prev_d!=1
replace resum_empl_reason=.z if resum_empl!=0
foreach var in births prenatalcare delivery deliveryassist births_ever births_age {
	replace `var'=.z if hhm_gender!=2
}
replace births=.z if hhm_age<12 | hhm_age>65
replace prenatalcare=.z if births!=1
replace delivery=.z if births!=1 
replace deliveryassist=.z if births!=1  
replace births_ever=.z if births==1 | hhm_age<12 | hhm_age>65
replace births_age=.z if births_ever!=1 & births!=1

*Label and rename variables
local variables hhm_parent hhm_parent_alive hhm_mar_age born_somalia birthplace_som birthplace_outsom ///
      migr_pasture nomad migr_reason migr_from hhm_read hhm_write hhm_edu_current hhm_edu_k_current hhm_edu_reason ///
      hhm_edu_disp hhm_edu_ever hhm_edu_years_kdk hhm_edu_years hhm_edu_level absent_duration_yn absent_reason	hhm_resp emp_7d_paid ///
	  emp_7d_busi emp_7d_help emp_7d_farm emp_7d_appr emp_7d_temp emp_7d_inac emp_12m_active emp_12m_detail emp_ever_active ///
	  emp_ever_detail hhm_job_search hhm_job_search_no hhm_available emp_inac_sub unemp_7d_dur hhm_job_search_dur hhm_job_obs hhm_job_support ///
      emp_7d_prim emp_7d_months emp_7d_hours_kdk emp_7d_hours emp_7d_prim_isic uemp_want emp_12m_additional_yn emp_prev_d emp_prev emp_prev_prim_isic ///
	  emp_prev_change emp_prev_months emp_prev_hours_kdk emp_prev_hours resum_empl resum_empl_reason births prenatalcare delivery deliveryassist births_ever births_age
foreach variable in `variables' {
	label define `variable' .a "Don't know" .b "Refused to respond" .z "Not administered", modify
}
local variables2 legal_id_type__1 legal_id_type__2 legal_id_type__3 legal_id_type__4 legal_id_type__5 legal_id_type__6 legal_id_type__7 legal_id_type__8 legal_id_type__9 legal_id_type__10 ///
      legal_id_type__11 legal_id_type__12 legal_id_type__13 legal_id_type__14 emp_7d_active unemp_7d /// 
      emp_12m_additional__1  emp_12m_additional__2 emp_12m_additional__3 emp_12m_additional__4 emp_12m_additional__5 	  
foreach variable in `variables2' {
	label values `variable' lyesno
}
label var hhroster_age__id "Household member ID"
label var emp_7d_active "Active household member in the last 7 days"
label var unemp_7d "Unemployed household member in the last 7 days"
rename (hhroster_age__id) (hhm_id)
drop migr_idp hhr_id

save "${gsdData}/0-RawOutput/hhm_clean.dta", replace

