* Combine and harmonize wave 1 and wave 2 data

set more off
set seed 23081980 
set sortseed 11041955



*=====================================================================
* HH level dataset 
*=====================================================================
use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear
*Deal with weight naming for wave 1
ren weight weight_unadjusted
ren weight_adj weight
*We want to make sure that wave 2 labels are applied to wave 1 reg_pess variable
ren reg_pess region
*Rename tenure to make sure
ren house_ownership tenure
*Append wave 2 data
append using "${gsdData}/1-CleanOutput/hh.dta", gen(t)
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
*Update IDP variable to include Wave 1 IDPs; don't count nomads as IDPs
replace migr_idp = 1 if ind_profile==6 & t==0
replace migr_idp =0 if ind_profile ==13
*Label overall groups
la def ltype 1 "Urban" 2 "Rural" 3 "IDP" 4 "Nomads"
la val type ltype
*Housingtype: make wave 2 comparable to wave 1
recode housingtype (9=7) (7 8 10 11 12 = 1000)
replace house_type=housingtype if t==1
recode house_type (7=1000)
*Deal with tenure 
recode tenure (1=1 "Own") (2=2 "Rent") (3/max=3 "Other"), gen(tenure1)
la var tenure1 "Tenure, harmonised"
*Deal with region
replace reg_pess = region if mi(reg_pess)
drop region
*Harmonise weights
replace weight_cons = weight if t==1
ren weight weight_adj
*Cooking source
recode cook (1=1 "Wood") (2 13 = 2 "Charcoal") (3 17 18 = 3 "Gas") (4=4 "Electricity") (5/12 14/16 19 1000 = 1000 "Other"), gen(cook2)
la var cook2 "Cooking source, harmonised"
*Create comparable wave 1 and wave 2 sample
gen comparable_w1_w2=1 if inlist(ind_profile,1,2,3,4,5,6)
replace comparable_w1_w2=0 if comparable_w1_w2==.
replace comparable_w1_w2=0 if ind_profile==6 & t==1 & !inlist(strata,4,5,6) 
label values comparable_w1_w2 lyesno
save "${gsdTemp}/hh_w1_w2.dta", replace


*=====================================================================
* Auxiliary hhq-poverty data set
*=====================================================================
use "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", clear
append using "${gsdData}/1-CleanTemp/hhq-poverty.dta", gen(t)
merge 1:1 t strata ea block hh using "${gsdTemp}/hh_w1_w2.dta", assert(match) keep(match) keepusing(type weight_adj reg_pess)
save "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", replace 


*=====================================================================
* HHM level dataset
*=====================================================================
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
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1_w2.dta", assert(match) keep(match) keepusing(type weight_adj reg_pess ind_profile type) nogen
*Create comparable wave 1 and wave 2 sample
gen comparable_w1_w2=1 if inlist(ind_profile,1,2,3,4,5,6)
replace comparable_w1_w2=0 if comparable_w1_w2==.
replace comparable_w1_w2=0 if ind_profile==6 & t==1 & !inlist(strata,4,5,6) 
label values comparable_w1_w2 lyesno
save "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", replace



*=====================================================================
* HH level dataset 
*=====================================================================
* Additional recode of variables that make sense between W1 and W2
*HHM level variables
use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear
gen child_boy=(gender==1) if age<=14 & !missing(gender) & !missing(age)
gen youth_male=(gender==1) if age>14 & age<=24 & !missing(gender) & !missing(age)
gen adult_male=(gender==1) if age>=25 & !missing(gender) & !missing(age)
collapse (sum) child_boy youth_male adult_male, by(t strata ea block hh)
save "${gsdTemp}/hhm_n_age_gender.dta", replace
use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear
replace literacy=. if age<30
bys t strata ea block hh: egen n_literate=sum(literacy) if !missing(literacy)
gen dum_iliterate_adult_hh=(n_literate==0) if !missing(n_literate)
gen pliteracy_25=n_literate/hhsize if !missing(literacy)
bys t strata ea block hh: egen n_dependent=sum(dependent)
collapse (max) n_literate dum_iliterate_adult_hh pliteracy_25 n_dependent, by(t strata ea block hh)
label var pliteracy_25 "Literacy HHM 30 years or more"
save "${gsdTemp}/hhm_literacy.dta", replace
*House type
use "${gsdTemp}/hh_w1_w2.dta", clear
gen house_type_comparable=.
replace house_type_comparable=1 if inlist(house_type,2,4)
replace house_type_comparable=2 if house_type==3
replace house_type_comparable=3 if inlist(house_type,1,5,6,1000)
label define lhouse_type_comparable 1 "Shared house/apartment" 2 "Separated house" 3 "Apartment/Buus/Bas/Cariish/Other"
label values house_type_comparable lhouse_type_comparable
label var house_type_comparable "Type of house (Comparable W1 & W2)"
*Tenure 
gen tenure_own_rent=(inlist(tenure,1,2)) if !missing(tenure)
label var tenure_own_rent "HH Own/Rent the dwelling" 
*Water
gen piped_water = water
replace piped_water= 1 if inlist(water,1,2)
replace piped_water=0 if inlist(water,3,4,5,.,.a,.b)
label var piped_water "HH has access to piped water"
*Treate water
gen protected_water=(treated_water==2) if !missing(treated_water)
label var protected_water "HH uses protected source of water"
*Cook wood and gas
gen cook_comparable=.
replace cook_comparable=1 if inlist(cook,1,3)
replace cook_comparable=2 if cook==2
replace cook_comparable=3 if cook_comparable==. & !missing(cook)
label define lcook_comparable 1 "Wood or Gas Stove" 2 "Charcoal Stove" 3 "Other"
label values cook_comparable lcook_comparable
label var cook_comparable "Cooking source (Comparable W1 & W2)"
*Improved sanitation
gen sanitation_comparable=1 if t==0 & toilet_type==2 | toilet_type==1
replace sanitation_comparable=1 if t==1 & inlist(toilet,1,3,6,7,8) 
replace sanitation_comparable=0 if sanitation_comparable==.
replace sanitation_comparable=. if t==0 & toilet_type>=. 
replace sanitation_comparable=. if t==1 & toilet>=.
label var sanitation_comparable "HH toilet Pit Latrine or Flush"
*Floor material
gen floor_comparable=1 if floor_material==1
replace floor_comparable=2 if floor_material==2 | floor_material==3
replace floor_comparable=3 if inlist(floor_material,4,1000)
label var floor_comparable "HH type of floor"
*Roof material
gen roof_metal=(roof_material==1)
label var roof_metal "HH with roof of metal"
*Include hhm level variables created 
merge 1:m t strata ea block hh using "${gsdTemp}/hhm_n_age_gender.dta", assert(match) nogen 
merge 1:m t strata ea block hh using "${gsdTemp}/hhm_literacy.dta", assert(match) nogen 

*Include a measure of households that have always live there
preserve 
use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear
bys t strata ea block hh: egen n_always=sum(hh_alwayslived)
gen x=1 if hh_alwayslived<.
bys t strata ea block hh: egen n_adult=sum(x)
gen prop_alwayslive=n_always/n_adult
collapse (max) prop_alwayslive, by(t strata ea block hh)
save "${gsdTemp}/hh_w1w2_alwayslive.dta", replace
restore
merge 1:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_alwayslive.dta", assert(match) nogen
save "${gsdTemp}/hh_w1_w2.dta", replace

* Prepare variables of interest that aren't yet in the right format
*Housingtype: make wave 2 comparable to wave 1
tab house_type, gen(house_type__)
*Cooking source
drop cooking 
ren cook2 cooking
la var n_dependent "No. Dependents"
la var dum_iliterate_adult_hh "All illiterate adults"
la var n_literate "No. Literate"
la var adult_male "No. Adult males"
la var youth_male "No. Youth males"
la var child_boy "No. Child boys"
la var comparable_w1_w2 "HH in comparable region between W1 & 2"
order comparable_w1_w2 , after(type)
drop supp_som_usd supp_som_pcpd

* save HH data set
save "${gsdData}/1-CleanOutput/hh_w1_w2.dta", replace

