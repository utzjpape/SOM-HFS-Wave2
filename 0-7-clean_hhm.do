*Clean and organize child file regarding household members

set more off
set seed 23082980 
set sortseed 11042955


********************************************************************
*Household members roster for all households 
********************************************************************
use "${gsdData}/0-RawTemp/hhroster_age_valid_successful_complete.dta", clear
drop hh_list hhm_relation_other birthplace_specify legal_id_type__1000 legal_id_type__n98 legal_id_type__n99 legal_id_spec hhm_edu_level_other absent_specify emp_7d_inac_sp hhm_job_search_no_spec emp_inac_sub_spec hhm_job_obs_spec hhm_job_support_spec emp_12m_additional__n98 emp_12m_additional__n99 resum_empl_reason_spec delivery_spec deliveryassist_spec interview__key hhm_away_m_int

*Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist hhroster_age__id-interview__id {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}
order interview__id hhroster_age__id hhm_age hhm_gender hhm_relation hhm_parent hhm_parent_alive hhm_mar_status hhm_mar_age born_somalia birthplace_som birthplace_outsom legal_id legal_id_type__* 

*Clean some variables
merge m:1 interview__id  using "${gsdData}/0-RawTemp/hh_clean.dta", assert(match) nogen keepusing(hhh_id0)
replace hhm_relation=1 if hhm_relation>=. & hhroster_age__id==hhh_id0
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

*Label and rename variables
local variables hhm_parent hhm_parent_alive hhm_mar_age born_somalia birthplace_som birthplace_outsom ///
      migr_pasture nomad 
foreach variable in `variables' {
	label define `variable' .a "Don't know" .b "Refused to respond" .z "Not administered", modify
}
local variables2 legal_id_type__1 legal_id_type__2 legal_id_type__3 legal_id_type__4 legal_id_type__5 legal_id_type__6 legal_id_type__7 legal_id_type__8 legal_id_type__9 legal_id_type__10 ///
      legal_id_type__11 legal_id_type__12 legal_id_type__13 legal_id_type__14
foreach variable in `variables2' {
	label values `variable' lyesno
}
label var hhroster_age__id "Household member ID"
rename (hhroster_age__id) (hhm_id)

save "${gsdData}/0-RawTemp/hhm_clean.dta", replace

