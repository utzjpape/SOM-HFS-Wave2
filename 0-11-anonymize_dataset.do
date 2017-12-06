*purpose: process to anonymize the datasets 

set more off
set seed 23082380 
set sortseed 11042355

*load hh data 
use "${gsdData}/0-RawOutput/hh.dta", clear

*generate a new and correct number of hhid for submissions within each strata and EA
sort strata ea key
by strata ea: egen hhid_new=seq() if zone<4
sort strata ea ea_block key
by strata ea ea_block: egen hhid_mog=seq() if zone==4
replace hhid_new=hhid_mog if zone==4 
drop hhid_mog hhid
rename hhid_new hhid
save "${gsdTemp}/hh_anon.dta", replace

*drop unnecessary variables
keep key zone strata ea hhid date enum_team enum_name full_l latx longx accx ea_block
*set seed 
set seed 23082380 

*generate random ID for each household
gen rand = runiform()
sort ea key
by ea: egen hh_anon = rank(rand)
save "${gsdTemp}/hh_anonkey.dta", replace

*generate random ID for each EA: take mean of random variable at the EA level
collapse (mean) rand, by(ea)
egen ea_anon = rank(rand)
save "${gsdTemp}/ea_anonkey.dta", replace

*generate random ID for each block: take mean of random variable at the block level
use "${gsdTemp}/hh_anonkey.dta", clear
collapse (mean) rand, by(ea_block)
egen block_anon = rank(rand)
save "${gsdTemp}/block_anonkey.dta", replace

*generate random ID for each enumerator: take mean of random variable at enumerator level
use "${gsdTemp}/hh_anonkey.dta", clear
collapse (mean) rand, by(enum_name)
egen enum_anon = rank(rand)
save "${gsdTemp}/enum_anonkey.dta", replace

*anonymize hh data
use "${gsdTemp}/hh_anon.dta", clear
merge 1:1 key using "${gsdTemp}/hh_anonkey.dta", assert(match) keep(match master) keepusing(hh_anon) nogenerate
merge m:1 ea using "${gsdTemp}/ea_anonkey.dta", assert(match) keep(match master) keepusing(ea_anon) nogenerate
merge m:1 enum_name using "${gsdTemp}/enum_anonkey.dta", assert(match) keep(match master) keepusing(enum_anon) nogenerate
merge m:1 ea_block using "${gsdTemp}/block_anonkey.dta", assert(match) keep(match master) keepusing(block_anon) nogenerate
replace block=. if strata==201 |  strata==202 |  strata==203  |  strata==204  |  strata==301 |  strata==302 |  strata==303 |  strata==304 |  strata==1103  |  strata==1104  |  strata==1203  |  strata==1204  |  strata==1303  |  strata==1304   
drop ea enum_team enum_name hhid ea_block 
rename (hh_anon ea_anon enum_anon block_anon) (hh ea enum block)
sort hh ea enum block
rename reg_old reg_pess
gen team = 3 if zone==1 
replace team = 3 if zone==2
replace team = 1 if zone==3
replace team = 2 if zone==4 
la var team "Data Collection Team"
label define lteam 1 "SL Team" 2 "SC Team" 3 "PL Team"
label values team lteam
order team strata ea block hh enum reg_pess
recode strata (101 102 103 201 202 203 301 302 303 1103 1203 1303=1 "Urban") (204 304 1104 1204 1304=2 "Rural") (105 205 305=3 "IDP"), gen(type) label(ltype)
gen astrata=11 if strata==101
replace astrata=3 if strata==105 | strata==205 | strata==305
replace astrata=12 if strata==201
replace astrata=13 if strata==202 | strata==203
replace astrata=21 if strata==204
replace astrata=14 if strata==301
replace astrata=15 if strata==302 | strata==303 | strata==1103  | strata==1203 | strata==1303
replace astrata=22 if strata==304 | strata==1204 
label def lastrata 11 "(u): Banadir"  3 "IDP" 12 "(u):Nugaal" 13 "(u):Bari+Mudug" 21 "(r):Bari+Mudug+Nugaal" 14 "(u):Woqooyi Galbeed" 15 "(u):Awdal+Sanaag+Sool+Togdheer" 22 "(r):Awdal+Sanaag+Sool+Togdheer+Woqooyi Galbeed", replace
label values astrata lastrata
label var ea "EA ID"
label var block "Block ID"
label var hh "Household ID"
label var enum "ID of enumerator"

*include the value labels to the old regions
replace reg_pess="Woqooyi Galbeed" if reg_pess=="Woqooyi_Galbeed"
replace reg_pess="Togdheer" if reg_pess=="Togdheer "
merge m:1 reg_pess using "${gsdData}/0-RawTemp/reg_pess.dta", force nogen keep(match) keepusing(pess_id)
drop reg_pess
rename pess_id reg_pess
label var reg_pess "Region (PESS)"
order reg_pess, after(enum)
save "${gsdTemp}/hh_final.dta", replace

*anonymize hhm data
use "${gsdData}/0-RawOutput/hhm.dta", replace
merge m:1 key using "${gsdTemp}/hh_final.dta",	assert(match) keepusing(zone team strata ea block hh enum) nogenerate
order team strata ea block hh enum 
drop key
save "${gsdData}/1-CleanInput/hhm.dta", replace
use "${gsdData}/0-RawOutput/hhm_c_illnesses.dta", replace
merge m:1 key using "${gsdTemp}/hh_final.dta",	keep(match master) keepusing(zone team strata ea block hh enum) nogenerate
order team strata ea block hh enum 
drop key
save "${gsdData}/1-CleanInput/illnesses.dta", replace

*anonymize other sections of the survey
use "${gsdData}/0-RawOutput/hh_e_food.dta", replace
merge m:1 key using "${gsdTemp}/hh_final.dta",	keep(match master) keepusing(zone team strata ea block hh enum astrata type) nogenerate
order team strata ea block hh enum 
drop key
save "${gsdData}/1-CleanInput/food.dta", replace
use "${gsdData}/0-RawOutput/hh_f_nfood.dta", replace
merge m:1 key using "${gsdTemp}/hh_final.dta",	keep(match master) keepusing(zone team strata ea block hh enum astrata type) nogenerate
order team strata ea block hh enum 
drop key
save "${gsdData}/1-CleanInput/nonfood.dta", replace
use "${gsdData}/0-RawOutput/hh_g_livestock.dta", replace
merge m:1 key using "${gsdTemp}/hh_final.dta",	keep(match master) keepusing(zone team strata ea block hh enum) nogenerate
order team strata ea block hh enum 
drop key
save "${gsdData}/1-CleanInput/livestock.dta", replace
use "${gsdData}/0-RawOutput/hh_h_assets.dta", replace
merge m:1 key using "${gsdTemp}/hh_final.dta",	keep(match master) keepusing(zone team strata ea block hh enum astrata type) nogenerate
order team strata ea block hh enum 
drop key
save "${gsdData}/1-CleanInput/assets.dta", replace
use "${gsdData}/0-RawOutput/hh_k_fsecurity.dta", replace
merge m:1 key using "${gsdTemp}/hh_final.dta",	keep(match master) keepusing(zone team strata ea block hh enum) nogenerate
order team strata ea block hh enum 
drop key
save "${gsdData}/1-CleanInput/fsecurity.dta", replace
use "${gsdData}/0-RawOutput/hh_l_incomesources.dta", replace
merge m:1 key using "${gsdTemp}/hh_final.dta",	keep(match master) keepusing(zone team strata ea block hh enum) nogenerate
order team strata ea block hh enum 
drop key
save "${gsdData}/1-CleanInput/incomesources.dta", replace
use "${gsdData}/0-RawOutput/hh_m_enterprises.dta", replace
merge m:1 key using "${gsdTemp}/hh_final.dta",	keep(match master) keepusing(zone team strata ea block hh enum) nogenerate
order team strata ea block hh enum 
drop key
save "${gsdData}/1-CleanInput/enterprises.dta", replace
use "${gsdData}/0-RawOutput/hh_n_shocks.dta", replace
merge m:1 key using "${gsdTemp}/hh_final.dta",	keep(match master) keepusing(zone team strata ea block hh enum) nogenerate
order team strata ea block hh enum 
drop key
save "${gsdData}/1-CleanInput/shocks.dta", replace
 
*Next, drop identifying information from hh
use "${gsdTemp}/hh_final.dta", clear
drop key date district full_l nhhm latx longx accx n_str n_hh treat replacement_bl original_bl rep hhr_id today
drop contact_info phone_number share_phone_agencies enum1 enum2 enum2_1 enum3 enum4 enum5 enum6 enum7 enum8 enum9 formdef_version mod_init_dur mod_0_dur mod_a_dur mod_b_dur mod_c_dur mod_d_dur mod_e_dur mod_f_dur mod_g_dur mod_h_dur mod_i_dur mod_j_dur mod_k_dur mod_l_dur mod_m_dur mod_n_dur phone_g_dur mod_o_dur ret visit_n
save "${gsdData}/1-CleanInput/hh.dta", replace
 
*Finally, include the files from SLHS 2013 into 1-CleanInput 
foreach dataset in "hh" "hhm" "food_consumption_clean" "paasche_r" "paasche_u" {
	use "${gsdDataRaw}/SLHS13/`dataset'.dta", clear
	save "${gsdData}/1-CleanInput/SLHS13/`dataset'.dta", replace
}
use "${gsdDataRaw}/Country_comparison.dta", clear
save "${gsdData}/1-CleanInput/Country_comparison.dta", replace
