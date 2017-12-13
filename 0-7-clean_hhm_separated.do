*clean and organize child file regarding household members

set more off
set seed 23082980 
set sortseed 11042955

use "${gsdData}/0-RawTemp/hhm_valid.dta", clear

********************************************************************
* Removing Empty Records
********************************************************************
* The questionnaire implements a work-around ensuring that the HH respondent always is asked about him or herself after he has given information about all other members. Given the sequence of questions, this creates empty records. The code line below removes these records, as gender is a required question. 
* The code below also members removes accidentally added by enumerators, as these are also empty records. 
drop if hhm_gender==.

********************************************************************
* Relabel 'Don't know' and 'Refused to respond'
********************************************************************
* Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all

**************************************************************************
* Relabel Skip patterns: Please Refer to Questionnaire for relevance conditions
**************************************************************************
* Some missing values are due to the fact that they are not administered, i.e. they don't apply. For example, a child under 10 will not be asked about their profession. These are a special category of missing values and this section categorises them as such. 
* Skip pattern consistency and missing values due to skip patterns . ==> .z
** A. Household Member information
*1. hhm_relation if rhhm_ishead = 0 
assert hhm_relation==. if rhhm_ishead==1 
recode hhm_relation (.=.z) if rhhm_ishead==1
*2. marital status if hhm_age>=15 or hhm_age_dk < 0
assert marital_status==. if hhm_age<15 
recode marital_status (.=.z) if hhm_age<15
*3. birthplace_som if born_somalia == 1
assert birthplace_som==. if born_somalia==0
recode birthplace_som (.=.z) if born_somalia==0
*4. birthplace_outsom if born_somalia==0
assert birthplace_outsom==. if born_somalia==1
recode birthplace_outsom (.=.z) if born_somalia==1
*5. birthplace_specify if birthplace_outsom == 1000
encode birthplace_specify, gen(birthplace_specify_long)
assert birthplace_specify_long == . if birthplace_outsom<1000 | born_somalia==1
recode birthplace_specify_long (.=.z) if birthplace_outsom<1000 | born_somalia==1
*6. migr_oscillation migr_reg migr_pasture hh_alwayslived if age=>15
assert migr_oscillation==. if hhm_age<15
assert migr_pasture==. if hhm_age<15
assert hh_alwayslived==. if hhm_age<15
recode migr_oscillation migr_pasture hh_alwayslived (.=.z) if hhm_age<15
*7. migr_reg if migr_oscillation==0 & age=>15
assert migr_reg==. if hhm_age<15 | migr_oscillation==1
recode migr_reg (.=.z) if hhm_age<15 | migr_oscillation==1
*8. nomad if migr_pasture==1 
assert nomad==. if migr_pasture==0 | hhm_age<15
recode nomad (.=.z) if migr_pasture==0 | hhm_age<15
*9. migr_time_y migr_time_m migr_time_dk migr_from if hh_alwayslived==0
assert migr_time_y==. if hh_alwayslived>0
assert migr_time_m==. if hh_alwayslived>0
assert migr_time_dk==. if hh_alwayslived>0
assert migr_from==. if hh_alwayslived>0
recode migr_time_y migr_time_m migr_time_dk migr_from (.=.z) if hh_alwayslived>0
*10. migr_from_country if migr_from is not Somalia
assert migr_from_country==. if migr_from<1000 | hh_alwayslived>0
recode migr_from_country (.=.z) if migr_from<1000 | hh_alwayslived>0
*11. migr_from_country_other if migr_from_country is other 
assert migr_from_country_other=="" if migr_from_country!=1000 | hh_alwayslived>0
replace migr_from_country_other =".z" if migr_from_country!=1000 | hh_alwayslived>0
*12. Push reasons, pull reasons if hh_alwayslived==0
assert push_reasons==. if hh_alwayslived>0
assert pull_reasons==. if hh_alwayslived>0
recode push_reasons (.=.z) if hh_alwayslived>0
recode pull_reasons (.=.z) if hh_alwayslived>0

** B. Education Variables
*1. hhm_read hhm_write hhm_edu_current only if age>5
assert hhm_read==. if hhm_age<=5
assert hhm_write==. if hhm_age<=5
assert hhm_edu_current==. if hhm_age<=5
recode hhm_read hhm_write hhm_edu_current (.=.z) if hhm_age<=5
*2. hhm_edu_ever if age>5 & and not currently enrolled
assert hhm_edu_ever==. if hhm_age<=5 | hhm_edu_current==1
recode hhm_edu_ever (.=.z) if hhm_age<=5 | hhm_edu_current==1
*3. hhm_edu_level and hhm_edu_years only if ever enrolled or currently enrolled
assert hhm_edu_level==. if hhm_edu_current!=1 & hhm_edu_ever!=1 | hhm_age<=5  
assert hhm_edu_years==. if hhm_edu_current!=1 & hhm_edu_ever!=1 | hhm_age<=5  
recode hhm_edu_level hhm_edu_years (.=.z) if hhm_edu_current!=1 & hhm_edu_ever!=1 | hhm_age<=5 
*4. edu level other specify if edu level other was selected
assert hhm_edu_level_other=="" if hhm_edu_level!=1000
*5. Repeat 1-3 for Koranic education
assert hhm_edu_k_current==. if hhm_age<=5
recode hhm_edu_k_current (.=.z) if hhm_age<=5
assert hhm_edu_k_ever==. if hhm_age<=5 | hhm_edu_k_current==1
recode hhm_edu_k_ever (.=.z) if hhm_age<=5 | hhm_edu_k_current==1
assert hhm_edu_k_years==. if hhm_edu_k_current!=1 & hhm_edu_k_ever!=1 | hhm_age<=5  
recode hhm_edu_k_years (.=.z) if hhm_edu_k_current!=1 & hhm_edu_k_ever!=1 | hhm_age<=5 
*6. absence if currently enrolled
assert absent_duration==. if hhm_edu_k_current!=1 & hhm_edu_current!=1 
recode absent_duration (.=.z) if hhm_edu_k_current!=1 & hhm_edu_current!=1 
assert absent_reason==. if hhm_edu_k_current!=1 & hhm_edu_current!=1 | (absent_duration==0 | absent_duration>.)
recode absent_reason (.=.z) if hhm_edu_k_current!=1 & hhm_edu_current!=1 | (absent_duration==0 | absent_duration>.)
assert absent_specify=="" if hhm_edu_k_current!=1 & hhm_edu_current!=1 | absent_reason!=1000

** C. Labour
*1. occupation if age>=15
assert isco==. if hhm_age<15
recode isco (.=.z) if hhm_age<15
*2. Individual occupation questions according to isco reply
foreach i of numlist 1/9 {
	assert isco0`i' == . if isco!=`i' | hhm_age<15
	recode isco0`i' (.=.z) if isco!=`i' | hhm_age<15
}
assert isco10==. if isco!=10 | hhm_age<15
recode isco10 (.=.z) if isco!=10 | hhm_age<15
*3. business organisation is relevant if occupation is true
assert benadir==. if isco<0 | isco>. | hhm_age<15
recode benadir (.=.z) if isco<0 | isco>. | hhm_age<15
*4. earned income, own business if older than 10.
assert employ_hh==. if hhm_age<10
assert business_own==. if hhm_age<10
recode employ_hh business_own (.=.z) if hhm_age<10
*5. Business registration
*need zone variable
merge m:1 key using  "${gsdData}/0-RawTemp/hh_valid.dta", keepusing(zone) keep(3) nogen
* This doesn't work and needs clearing up; see Diagnostics file
/*
assert b_regoff==. if business_own!=1 | hhm_age<10 | zone!=1
assert b_mocai==. if business_own!=1 | hhm_age<10 | zone!=1
recode b_regoff b_mocai (.=.z) if business_own!=1 | hhm_age<10 | zone!=1  
tab1 b_regoff b_mocai,m
assert b_moc==. if business_own!=1 | hhm_age<10 | zone==1
assert b_locgov==. if business_own!=1 | hhm_age<10 | inrange(zone, 1,2)
*/
assert b_choc==. if business_own!=1 | hhm_age<10
recode b_choc (.=.z) if business_own!=1 | hhm_age<10

*6. Work in last 12 months if age=>10
foreach v in emp_12m_appr emp_12m_farm emp_12m_paid emp_12m_busi emp_12m_help {
	assert `v'==. if hhm_age<10
	recode `v' (.=.z) if hhm_age<10
}
*7. emp_12m_prim
assert emp_12m_prim==. if emp_12m_act_y<=1 | hhm_age<10
recode emp_12m_prim (.=.z) if emp_12m_act_y<=1 | hhm_age<10
tab emp_12m_prim,m
*8. emp ever
foreach v in emp_ever_appr emp_ever_farm emp_ever_paid emp_ever_busi emp_ever_help {
	assert `v'==. if emp_12m_act_y!=0 | hhm_age<10
	recode `v' (.=.z) if emp_12m_act_y!=0 | hhm_age<10
}
*9. Emp last seven days
assert emp_7d_act==. if emp_ever_act_y<=0 & emp_ever_act_dk==0 | hhm_age<10
recode emp_7d_act (.=.z) if emp_ever_act_y<=0 & emp_ever_act_dk==0 | hhm_age<10

foreach v in emp_7d_hours emp_7d_hours_kdk emp_7d_prim emp_7d_prim_sector {
	assert `v'==. if emp_7d_act!=1 | hhm_age<10
	recode `v' (.=.z) if emp_7d_act!=1 | hhm_age<10
} 

foreach v of varlist emp_7d_inac emp_7d_hh emp_7d_temp emp_available {
	assert `v'==. if emp_7d_act!=0 & (emp_ever_act_y>0 | emp_ever_act_dk>0) | hhm_age<10
	recode `v' (.=.z) if emp_7d_act!=0 & (emp_ever_act_y>0 | emp_ever_act_dk>0) | hhm_age<10
}

assert emp_7d_hh_hrs==. if emp_7d_hh!=1 | hhm_age<10
recode emp_7d_hh_hrs (.=.z) if emp_7d_hh!=1 | hhm_age<10

assert emp_status==. if !(emp_7d_act==1 | emp_7d_temp==1 | (emp_7d_act==0 & emp_available==1 & emp_ever_act_y>0)) | hhm_age<10
recode emp_status (.=.z) if !(emp_7d_act==1 | emp_7d_temp==1 | (emp_7d_act==0 & emp_available==1 & emp_ever_act_y>0)) | hhm_age<10
*10. Job search: if age=>10
assert hhm_job_search==. if hhm_age<10
recode hhm_job_search (.=.z) if hhm_age<10
assert hhm_job_search_type==. if hhm_job_search!=1 | hhm_age<10
recode hhm_job_search_type (.=.z) if hhm_job_search!=1 | hhm_age<10
assert hhm_job_search_no==. if hhm_job_search!=0 | hhm_age<10
recode hhm_job_search_no (.=.z) if hhm_job_search!=0 | hhm_age<10

********************************************************************
* Adjust Value Labels
********************************************************************
labmm .z "Not administered"
labdu , dryrun report
labdu , delete report
labellist 

********************************************************************
* Labelling and Dropping unnessary variables
********************************************************************

label var rhhm_name "Name of hh member"
label var rhhm_ishead "Is hh member the hh head?"
label var pos "Number of member within the household"
rename pos member_id 

drop child_key birthplace_specify birthplace_som birthplace_outsom setofhhm rhhm_name setofillnesses emp_12m_a emp_12m_f emp_12m_p emp_12m_b emp_12m_h emp_12m_reminder emp_12m_a_som emp_12m_f_som emp_12m_p_som emp_12m_b_som emp_12m_h_som emp_12m_reminder_som 
drop emp_12m_appr_y emp_12m_farm_y emp_12m_paid_y emp_12m_busi_y emp_12m_help_y emp_12m_appr_dk emp_12m_farm_dk emp_12m_paid_dk emp_12m_busi_dk emp_12m_help_dk emp_12m_act_dk emp_12m_act_y
drop emp_ever_appr_y emp_ever_farm_y emp_ever_paid_y emp_ever_busi_y emp_ever_help_y emp_ever_appr_dk emp_ever_farm_dk emp_ever_paid_dk emp_ever_busi_dk emp_ever_help_dk emp_ever_act_y emp_ever_act_dk emp_ever_act_no
drop zone_l
label var key "Key to merge with parent"
order key member_id

*drop empty variables
missings dropvars, force 

*drop variables with open answers, multiple numeric entries and/or in Somali
*drop migr_from_country_other hhm_edu_level_other absent_specify illnesses0 top2_illnesses delivery_spec 


save "${gsdData}/0-RawTemp/hhm_clean.dta", replace
