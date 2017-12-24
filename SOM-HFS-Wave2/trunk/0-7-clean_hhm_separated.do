*Clean and organize child file regarding separated household members

set more off
set seed 23082980 
set sortseed 11042955


use "${gsdData}/0-RawTemp/hh_roster_separated_valid_successful_complete.dta", clear

********************************************************************
*Clean and prepare data on separated household members
********************************************************************
drop interview__key hh_list_separated hhm_sep_reason_spec hhm_relation_sep_s
order  interview__id hh_roster_separated__id hhm_age_sep hhm_sep_sex hhm_relation_sep  hhm_sep_reason hhm_contact

*Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist interview__id-hhm_contact {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}

*Label and rename variables 
label var hh_roster_separated__id "Separated Member ID"
rename (hh_roster_separated__id hhm_age_sep hhm_sep_sex hhm_relation_sep hhm_sep_reason hhm_contact) (hhm_separated__id hhm_sep_age hhm_sep_sex hhm_sep_relation hhm_sep_reason hhm_sep_contact)

save "${gsdData}/0-RawTemp/hhm_separated_clean.dta", replace


