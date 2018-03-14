* Combine and harmonize wave 1 and wave 2 data

set more off
set seed 23081980 
set sortseed 11041955

* HH level dataset 
use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear
* deal with weight naming for wave 1
ren weight weight_unadjusted
ren weight_adj weight
* we want to make sure that wave 2 labels are applied to wave 1 reg_pess variable
ren reg_pess region
* rename tenure to make sure
ren house_ownership tenure
* append wave 2 data
append using "${gsdData}/1-CleanOutput/hh.dta", gen(t)
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
* Update IDP variable to include Wave 1 IDPs
replace migr_idp = 1 if ind_profile==6 & t==0
* Label overall groups
la def ltype 1 "Urban" 2 "Rural" 3 "IDP" 4 "Nomads"
la val type ltype
* Housingtype: make wave 2 comparable to wave 1
recode housingtype (9=7) (7 8 10 11 12 = 1000)
replace house_type=housingtype if t==1
recode house_type (7=1000)
* Deal with tenure 
recode tenure (1=1 "Own") (2=2 "Rent") (3/max=3 "Other"), gen(tenure1)
la var tenure1 "Tenure, harmonised"
* Deal with region
replace reg_pess = region if mi(reg_pess)
drop region
* harmonise weights
replace weight_cons = weight if t==1
ren weight weight_adj
* cooking source
recode cook (1=1 "Wood") (2 13 = 2 "Charcoal") (3 17 18 = 3 "Gas") (4=4 "Electricity") (5/12 14/16 19 1000 = 1000 "Other"), gen(cook2)
la var cook2 "Cooking source, harmonised"
* save HH data set
save "${gsdData}/1-CleanTemp/hh_all.dta", replace
*Create comparable wave 1 and wave 2 sample
keep if inlist(ind_profile,1,2,3,4,5,6)
drop if ind_profile==6 & t==1 & !inlist(strata,4,5,6) 
gen idp=ind_profile==6
save "${gsdData}/1-CleanTemp/hh_all_comparable.dta", replace

* HHM level dataset
use "${gsdData}/1-CleanInput/SHFS2016/hhm.dta", clear
ren weight weight_unadjusted
gen enrolled=edu_status==1 if inrange(age, 6, 17)
la var enrolled "Enrolled at school age (6-17)"
append using "${gsdData}/1-CleanOutput/hhm.dta", gen(t)
order t
drop reg_pess
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
drop weight
cap drop dependent
gen dependent = age<15 | age>64
la var dependent "Dependents"
merge m:1 t strata ea block hh using "${gsdData}/1-CleanTemp/hh_all.dta", assert(match) keep(match) keepusing(type weight_adj reg_pess ind_profile type) nogen
save "${gsdData}/1-CleanTemp/hhm_all.dta", replace
*Create comparable wave 1 and wave 2 sample
keep if inlist(ind_profile,1,2,3,4,5,6)
drop if ind_profile==6 & t==1 & !inlist(strata,4,5,6) 
gen idp=ind_profile==6
save "${gsdData}/1-CleanTemp/hhm_all_comparable.dta", replace

* Auxiliary hhq-poverty data set
use "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", clear
append using "${gsdData}/1-CleanTemp/hhq-poverty.dta", gen(t)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/hh_all.dta", assert(match) keep(match) keepusing(type weight_adj reg_pess)
save "${gsdData}/1-CleanTemp/hhq-poverty_all.dta", replace 
