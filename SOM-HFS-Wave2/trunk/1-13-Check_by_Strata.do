* Compare Wave 1 vs. Wave 2

set more off
set seed 23081980 
set sortseed 11041955


*Open combined data set
use "${gsdData}/1-CleanTemp/hh_all.dta", clear
gen pweight=weight_adj*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)

*=====================================================================
* Prepare variables of interest that aren't yet in the right format
*=====================================================================
*Housingtype: make wave 2 comparable to wave 1
tab house_type, gen(house_type__)
*Cooking source
drop cooking 
ren cook2 cooking
ta cooking, gen(cooking__)
*Water
ta water, gen(water__)
*Tenure
ta tenure1, gen(tenure__)
*Floor
ta floor_material, gen(floor__)
*Roof
ta roof_material, gen(roof__) 

*Fix labels
la var hhsize "Household size"
foreach i of varlist cooking__* water__* tenure__* floor__* roof__* {
local a : variable label `i'
local a: subinstr local a "==" ": "
label var `i' "`a'"
}

*=====================================================================
* Prepare dataset for analysis
*=====================================================================
*Wave 1 
cap drop ind_profile
replace astrata=. if t==1
gen ind_profile="NW-Rural" if astrata==22
replace ind_profile="NE-Rural" if astrata==21
replace ind_profile="NW-Urban" if astrata==14 | astrata==15
replace ind_profile="NE-Urban" if astrata==12 | astrata==13 
replace ind_profile="Mogadishu" if astrata==11
replace ind_profile="IDP" if astrata==3

*Wave 2
assert strata>100 if t==0
replace ind_profile="Mogadishu"  if strata==37
replace ind_profile="NE-Urban" if strata==39 | strata==41 | strata==43
replace ind_profile="NE-Rural" if strata==38 | strata==40 | strata==42 
replace ind_profile="NW-Urban" if strata==45 | strata==49 | strata==51
replace ind_profile="NW-Urban" if type==1 & (strata==46 | strata==47)
replace ind_profile="NW-Rural" if strata==44 | strata==48 |  strata==50
replace ind_profile="NW-Rural" if type==2 & (strata==46 | strata==47)
replace ind_profile="IDP" if inlist(strata,1,2,3,4,5,6,7)
replace ind_profile="Nomad" if inlist(strata,8,9,10,12,13,14)
replace ind_profile="Central-Urban" if strata==26 | strata==28 |  strata==30
replace ind_profile="Central-Rural" if strata==25 | strata==27 |  strata==29
replace ind_profile="Jubbaland-Urban" if strata==31 | strata==33 |  strata==36
replace ind_profile="Jubbaland-Rural" if strata==32 | strata==34 |  strata==35
replace ind_profile="SouthWest-Urban" if strata==52 | strata==54 |  strata==57
replace ind_profile="SouthWest-Rural" if strata==53 | strata==55 |  strata==56
save "${gsdTemp}/hh_w1w2_comparison.dta", replace

**Check the interquartile range for weights in Wave 1 & 2
preserve
drop if type_idp_host==2
egen w1_mog=iqr(weight_adj) if t==0 & ind_profile=="Mogadishu"
egen w1_neu=iqr(weight_adj) if t==0 & ind_profile=="NE-Urban"
egen w1_ner=iqr(weight_adj) if t==0 & ind_profile=="NE-Rural"
egen w1_nwu=iqr(weight_adj) if t==0 & ind_profile=="NW-Urban"
egen w1_nwr=iqr(weight_adj) if t==0 & ind_profile=="NW-Rural"
egen w1_idp=iqr(weight_adj) if t==0 & ind_profile=="IDP"
egen w2_mog=iqr(weight_adj) if t==1 & ind_profile=="Mogadishu"
egen w2_neu=iqr(weight_adj) if t==1 & ind_profile=="NE-Urban"
egen w2_ner=iqr(weight_adj) if t==1 & ind_profile=="NE-Rural"
egen w2_nwu=iqr(weight_adj) if t==1 & ind_profile=="NW-Urban"
egen w2_nwr=iqr(weight_adj) if t==1& ind_profile=="NW-Rural"
egen w2_idp=iqr(weight_adj) if t==1 & ind_profile=="IDP"
gen x=1
collapse (max) w1_* w2_*, by(x)
restore

*=====================================================================
* Additional recode of variables that make sense between W1 and W2
*=====================================================================
*HHM level variables
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
gen child_boy=(gender==1) if age<=14 & !missing(gender) & !missing(age)
gen youth_male=(gender==1) if age>14 & age<=24 & !missing(gender) & !missing(age)
gen adult_male=(gender==1) if age>=25 & !missing(gender) & !missing(age)
collapse (sum) child_boy youth_male adult_male, by(t strata ea block hh)
save "${gsdTemp}/hhm_n_age_gender.dta", replace
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
replace literacy=. if age<30
bys t strata ea block hh: egen n_literate=sum(literacy) if !missing(literacy)
gen dum_iliterate_adult_hh=(n_literate==0) if !missing(n_literate)
gen pliteracy_25=n_literate/hhsize if !missing(literacy)
bys t strata ea block hh: egen n_dependent=sum(dependent)
collapse (max) n_literate dum_iliterate_adult_hh pliteracy_25 n_dependent, by(t strata ea block hh)
label var pliteracy_25 "Literacy HHM 30 years or more"
save "${gsdTemp}/hhm_literacy.dta", replace

*House type
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
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
/*
gen sanitation_comparable=1 if t==0 & toilet_type==2
replace sanitation_comparable=1 if t==1 & inlist(toilet,3,6,7,8) 
replace sanitation_comparable=2 if t==0 & toilet_type==1
replace sanitation_comparable=2 if t==1 & toilet==1
replace sanitation_comparable=3 if sanitation_comparable==.
replace sanitation_comparable=. if t==0 & toilet_type>=. 
replace sanitation_comparable=. if t==1 & toilet>=.
label define lsanitation_comparable 1 "Pit Latrine" 2 "Flush" 3 "Public/Open/Other"
label values sanitation_comparable lsanitation_comparable
label var sanitation_comparable "HH toilet (Comparable W1 & W2"
ta sanitation_comparable, gen(sanitation_comparable_)
*/
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
*Include dummy for categorical variables
ta house_type_comparable, gen(house_type_comparable__)
ta cook_comparable, gen(cook_comparable)
ta floor_comparable, gen(floor_comparable)

*Include a measure of households that have always live there
preserve 
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
bys t strata ea block hh: egen n_always=sum(hh_alwayslived)
gen x=1 if hh_alwayslived<.
bys t strata ea block hh: egen n_adult=sum(x)
gen prop_alwayslive=n_always/n_adult
collapse (max) prop_alwayslive, by(t strata ea block hh)
save "${gsdTemp}/hh_w1w2_alwayslive.dta", replace
restore
merge 1:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_alwayslive.dta", assert(match) nogen
save "${gsdTemp}/hh_w1w2_comparison.dta", replace


*=====================================================================
* RESTRICT THE ANALYSIS TO HARGEYSA + BURCO
*=====================================================================
//V1 Case: Hargeysa + Burco / Including IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
*Wave 2: make sure all HHs are from Burco & Hargeysa 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
drop if t==1 & !inlist(district,"Burco","Hargeysa")
drop district
*Wave 1: make sure all HHs are from Burco & Hargeysa 
merge 1:1 strata ea block hh using "${gsdDataRaw}/Wave_1/hh_w1_district.dta", nogen keep(master match) keepusing(district)
drop if t==0 & !inlist(district,"Burco","Hargeisa")
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V1.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}

import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_1") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


//V2 Case: Hargeysa + Burco / Excluding IDPs/Migrants / Including Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
*Wave 2: make sure all HHs are from Burco & Hargeysa 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
drop if t==1 & !inlist(district,"Burco","Hargeysa")
drop district
*Wave 1: make sure all HHs are from Burco & Hargeysa 
merge 1:1 strata ea block hh using "${gsdDataRaw}/Wave_1/hh_w1_district.dta", nogen keep(master match) keepusing(district)
drop if t==0 & !inlist(district,"Burco","Hargeisa")
drop if migr_idp==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V2.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_2") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


//V3 Case: Hargeysa + Burco / Excluding IDPs/Migrants + Born Outside / Including  Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
*Wave 2: make sure all HHs are from Burco & Hargeysa 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
drop if t==1 & !inlist(district,"Burco","Hargeysa")
drop district
*Wave 1: make sure all HHs are from Burco & Hargeysa 
merge 1:1 strata ea block hh using "${gsdDataRaw}/Wave_1/hh_w1_district.dta", nogen keep(master match) keepusing(district)
drop if t==0 & !inlist(district,"Burco","Hargeisa")
drop if migr_idp==1
drop if hhh_outstate==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V3.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_3") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


//V4 Case: Hargeysa + Burco / Excluding IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
*Wave 2: make sure all HHs are from Burco & Hargeysa 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
drop if t==1 & !inlist(district,"Burco","Hargeysa")
drop district
*Wave 1: make sure all HHs are from Burco & Hargeysa 
merge 1:1 strata ea block hh using "${gsdDataRaw}/Wave_1/hh_w1_district.dta", nogen keep(master match) keepusing(district)
drop if t==0 & !inlist(district,"Burco","Hargeisa")
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V4.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_4") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


//V5 Case: Hargeysa + Burco / Excluding IDPs/Migrants + Born Outside + Not always live there / No Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
*Wave 2: make sure all HHs are from Burco & Hargeysa 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
drop if t==1 & !inlist(district,"Burco","Hargeysa")
drop district
*Wave 1: make sure all HHs are from Burco & Hargeysa 
merge 1:1 strata ea block hh using "${gsdDataRaw}/Wave_1/hh_w1_district.dta", nogen keep(master match) keepusing(district)
drop if t==0 & !inlist(district,"Burco","Hargeisa")
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V5.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
svyset, clear
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	ttest `v', by(t) unequal
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_5") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

*Check average age and age distribution * 
foreach k in 1 2 3 4 {
	use "${gsdTemp}/hh_w1w2_comparison_V`k'.dta", clear
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdData}/1-CleanTemp/hhm_all.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)

	* Average age
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean age) sebnone f(3) h1("Age") npos(col) replace ptotal(none) 
	local i=1
	svy: mean age, over(t)
	test _subpop_1 = _subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "Age"
	putexcel B`i' =`r(p)'
	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren B p_value
	sort v1
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="ind_profile"
	drop if v1==""
	drop v4 v5 
	la var v1 "Variable of interest"
	la var v2 "Mean"
	la var v3 "Mean"
	destring v2-v3, replace
	foreach x of numlist 2/3 {
		replace v`x'= v`x'[_n+1]
	}
	drop if v1=="NW-Urban"
	gen n = _n
	sort n
	merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
	sort n
	drop n
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_`k'_2") sheetreplace first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

	* Age distribution
	use "${gsdTemp}/hh_w1w2_comparison_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdData}/1-CleanTemp/hhm_all.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if t==0, svy pop c(perc lb ub) f(5) sebnone h2("Age Distribution, w1") npos(col) replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==1, svy pop c(perc lb ub) f(5) sebnone h2("Age Distribution, w2") npos(col) replace ptotal(none) 
	drop if mi(literacy)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==0, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w1")  replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls" if t==1, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w2")  replace ptotal(none) 
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear nonames tab
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(A3) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	drop v1 
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(F3) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	drop v1 
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(J4) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	drop v1 
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(L4) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls"
}

*=====================================================================
* COMPARISON W/SLHS 2013
*=====================================================================




*=====================================================================
* OTHER CHECKS
*=====================================================================
*Check sampling weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
rename district district_w2
merge 1:1 strata ea block hh using "${gsdDataRaw}/Wave_1/hh_w1_district.dta", nogen keep(master match) keepusing(district)
*Woqooyi Galbeed
keep if reg_pess==18
egen tot_w1_reg_18=sum(weight_adj) if t==0 
egen tot_w2_reg_18=sum(weight_adj) if t==1 
scatter weight_adj t 
gen new_weight_adj=weight_adj if t==1
replace new_weight_adj=weight_adj*4.5 if t==0
scatter new_weight_adj t 

*Obtain the phone number for a phone survey 
use "${gsdTemp}/hh_w1w2_comparison_V4.dta", clear
*Wave 1
keep if t==0
merge 1:1 strata ea block hh using "${gsdDataRaw}/Wave_1/hh_w1_district.dta", nogen keep(master match) keepusing(district contact_info phone_number)
drop if contact_info==0 
drop if phone_number==.
drop if phone_number<3138719
tab t
*Wave 2
use "${gsdTemp}/hh_w1w2_comparison_V4.dta", clear
keep if t==1
merge 1:1 strata ea block hh using "${gsdTemp}/hh_final.dta", nogen keep(match) keepusing(interview__id)
merge 1:1 interview__id using "${gsdData}/0-RawTemp/hh_valid_successful_complete.dta", nogen keep(match)
drop if follow_up_yn==0
drop if phone_number==""
tab t

*Literacy rate directly 
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen assert(match) keepusing(ind_profile)
keep if ind_profile=="NW-Urban"
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
rename district district_w2
merge m:1 strata ea block hh using "${gsdDataRaw}/Wave_1/hh_w1_district.dta", nogen keep(master match) keepusing(district)
replace literacy=. if age<30
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
svy: mean literacy if district=="Hargeisa" | district=="Burco"	
svy: mean literacy if district_w2=="Hargeysa" | district_w2=="Burco"	
*Literacy rate by enumerator
keep if inlist(district,"Hargeisa","Burco") | inlist(district_w2,"Burco","Hargeysa")
graph bar literacy if t==0, over(enum, sort(1))
graph bar literacy if t==1, over(enum, sort(1))

*HHM separated roster for Hargeysa and Burco in W2
use "${gsdData}/1-CleanOutput/hhm_separated.dta", clear
gen t=1
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(master match) keepusing(ind_profile)
keep if ind_profile=="NW-Urban"
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
keep if district=="Hargeysa" | district=="Burco"	
tab hhm_sep_reason, m

*Population pyramid 2017
use "${gsdData}/1-CleanOutput/hhm.dta", clear 
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", assert(match) keepusing(weight type ind_profile) nogen
keep if ind_profile==3
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
drop if !inlist(district,"Burco","Hargeysa")
svyset ea [pweight=weight_adj], strata(strata)
qui tabout age_cat_narrow gender using "${gsdOutput}/Somaliland_Comparison_3.xls", svy pop c(freq se) f(3) sebnone h1(Age distribution (5-year intervals) by gender - Urban) append


*=====================================================================
* COMPARE ASSETS - Share of households owning each item
*=====================================================================
/*
use "${gsdData}/1-CleanOutput/assets.dta", clear
gen t=1
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(match) keepusing(ind_profile weight_cons weight_adj hhsize)
keep if ind_profile=="NW-Urban"
recode own_n (missing=0)
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
keep if district=="Hargeysa" | district=="Burco"
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
save "${gsdTemp}/assets_nwurban_w2.dta", replace
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
keep strata ea block hh itemid own_n
reshape wide own_n, i(strata ea block hh) j(itemid)
recode own_n* (.=0)
reshape long own_n, i(strata ea block hh) j(itemid)
gen t=0
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(match using) keepusing(ind_profile weight_cons weight_adj hhsize)
keep if ind_profile=="NW-Urban"
merge m:1 strata ea block hh using "${gsdDataRaw}/Wave_1/hh_w1_district.dta", nogen keep(master match) keepusing(district)
keep if district=="Hargeisa" | district=="Burco"
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
append using "${gsdTemp}/assets_nwurban_w2.dta"
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

tab itemid, gen(item_)
foreach k of varlist item_* {
local a : variable label `k'
local a : subinstr local a "itemid==" ""
label var `k' "`a'"
}


cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

local i=1
levelsof itemid, local(items) 
foreach item of local items {
	replace item_`item' = 0 if own_n==0
	local l : variable label item_`item'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if itemid==`item', sum c(mean item_`item') sebnone f(5) h1("`l'") npos(col) append ptotal(none) 
	svy: mean own_n if itemid==`item', over(t)
	test _subpop_1==_subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "`l'"
	putexcel B`i' =`r(p)'
	local i=`i'+1
}

import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_5") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
*/

*=====================================================================
* COMPARE ASSETS - Average number of each item owned
*=====================================================================
use "${gsdData}/1-CleanOutput/assets.dta", clear
*Wave 2
gen t=1
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(match) keepusing(ind_profile weight_cons weight_adj hhsize)
keep if ind_profile=="NW-Urban"
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh-PESS_district.dta", nogen keep(master match) keepusing(district) 
keep if district=="Hargeysa" | district=="Burco"
*Include owning zero assets 
replace own_n=0 if own==0
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
save "${gsdTemp}/assets_nwurban_w2.dta", replace
*Wave 1 ID zeros
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta"
keep if _merge==2 | (strata==101 & ea==85 & block==11 & hh==4)
keep strata ea block hh itemid own_n
replace itemid=1 if itemid==.
reshape wide own_n, i(strata ea block hh) j(itemid)
reshape long
drop if strata==101 & ea==85 & block==11 & hh==4
replace own_n=0 if own_n==.
save "${gsdTemp}/assets_nwurban_w2_noassets.dta", replace
*Wave 1 
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
keep strata ea block hh itemid own_n
append using "${gsdTemp}/assets_nwurban_w2_noassets.dta"
replace own_n=0 if own_n==.
gen t=0
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(master match) keepusing(ind_profile weight_cons weight_adj hhsize)
keep if ind_profile=="NW-Urban" | ind_profile==""
merge m:1 strata ea block hh using "${gsdDataRaw}/Wave_1/hh_w1_district.dta", nogen keep(master match) keepusing(district)
keep if district=="Hargeisa" | district=="Burco"
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
append using "${gsdTemp}/assets_nwurban_w2.dta"
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tab itemid, gen(item_)
foreach k of varlist item_* {
local a : variable label `k'
local a : subinstr local a "itemid==" ""
label var `k' "`a'"
}
drop if mi(own_n)
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
preserve
local i=1
levelsof itemid, local(items) 
qui foreach item of local items {
	su own_n
	local l : variable label item_`item'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if itemid==`item', svy sum c(mean own_n) sebnone f(5) h1("`l'") append ptotal(none)
	svy: mean own_n if itemid==`item', over(t)
	cap test _subpop_1==_subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "`l'"
	cap putexcel B`i' =`r(p)'
	local i=`i'+1
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
replace v3="" if v4==""
drop v4 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_6") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
restore
*Check median values
levelsof itemid, local(items) 
qui foreach item of local items {
	preserve 
	keep if itemid==`item'
	collapse (median) own_n [aweight=weight_adj], by(t)
	gen itemid=`item'
	reshape wide own_n, i(itemid) j(t)
	save "${gsdTemp}/W1W2-comparison_assets_`item'.dta", replace
	restore
}
use "${gsdTemp}/W1W2-comparison_assets_1.dta", clear
qui forval i=2/37 {
	append using "${gsdTemp}/W1W2-comparison_assets_`i'.dta"
}
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_v1.xlsx", sheet("Raw_7") sheetmodify cell(B3) first(varlabels)



*=====================================================================
* RESTRICT THE ANALYSIS TO WOQOOYI 
*=====================================================================
//V1 Case: Woqooyi / Including IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
keep if reg_pess==18
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V1.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}

import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_v1.xlsx", sheet("Raw_1") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


//V2 Case: Woqooyi / Excluding IDPs/Migrants / Including Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
keep if reg_pess==18
drop if migr_idp==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V2.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_v1.xlsx", sheet("Raw_2") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


//V3 Case: _Woqooyi / Excluding IDPs/Migrants + Born Outside / Including  Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
keep if reg_pess==18
drop if migr_idp==1
drop if hhh_outstate==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V3.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_v1.xlsx", sheet("Raw_3") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


//V4 Case: Woqooyi / Excluding IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
keep if reg_pess==18
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V4.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_v1.xlsx", sheet("Raw_4") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


*Check average age and age distribution * 
foreach k in 1 2 3 4  {
	use "${gsdTemp}/hh_w1w2_comparison_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdData}/1-CleanTemp/hhm_all.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)

	* Average age
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean age) sebnone f(3) h1("Age") npos(col) replace ptotal(none) 
	local i=1
	svy: mean age, over(t)
	test _subpop_1 = _subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "Age"
	putexcel B`i' =`r(p)'
	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren B p_value
	sort v1
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="ind_profile"
	drop if v1==""
	drop v4 v5 
	la var v1 "Variable of interest"
	la var v2 "Mean"
	la var v3 "Mean"
	destring v2-v3, replace
	foreach x of numlist 2/3 {
		replace v`x'= v`x'[_n+1]
	}
	drop if v1=="NW-Urban"
	gen n = _n
	sort n
	merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
	sort n
	drop n
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_v1.xlsx", sheet("Raw_`k'_2") sheetreplace first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

	* Age distribution
	use "${gsdTemp}/hh_w1w2_comparison_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdData}/1-CleanTemp/hhm_all.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if t==0, svy pop c(perc lb ub) f(5) sebnone h2("Age Distribution, w1") npos(col) replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==1, svy pop c(perc lb ub) f(5) sebnone h2("Age Distribution, w2") npos(col) replace ptotal(none) 
	drop if mi(literacy)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==0, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w1")  replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls" if t==1, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w2")  replace ptotal(none) 
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear nonames tab
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(A3) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	drop v1 
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(F3) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	drop v1 
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(J4) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	drop v1 
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(L4) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls"
}


*=====================================================================
* RESTRICT THE ANALYSIS TO WOQOOYI + EXCLUDE WEIGHTS OUTLIERS + RESCALE
*=====================================================================
//V1 Case: Woqooyi + Change weights/ Including IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
keep if reg_pess==18
drop if t==1 & weight_adj>2000
egen w_tot=sum(weight_adj) if t==1
gen scale_n=123390/w_tot
replace weight_adj=weight_adj*scale_n if t==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V1.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}

import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_noweight_v1.xlsx", sheet("Raw_1") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


//V2 Case: Woqooyi + Change weights/ Excluding IDPs/Migrants / Including Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
keep if reg_pess==18
drop if t==1 & weight_adj>2000
egen w_tot=sum(weight_adj) if t==1
gen scale_n=123390/w_tot
replace weight_adj=weight_adj*scale_n if t==1
drop if migr_idp==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V2.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_noweight_v1.xlsx", sheet("Raw_2") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


//V3 Case: _Woqooyi + Change weights/ Excluding IDPs/Migrants + Born Outside / Including  Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
keep if reg_pess==18
drop if t==1 & weight_adj>2000
egen w_tot=sum(weight_adj) if t==1
gen scale_n=123390/w_tot
replace weight_adj=weight_adj*scale_n if t==1
drop if migr_idp==1
drop if hhh_outstate==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V3.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_noweight_v1.xlsx", sheet("Raw_3") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


//V4 Case: Woqooyi + Change weights/ Excluding IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
keep if ind_profile=="NW-Urban"
keep if reg_pess==18
drop if t==1 & weight_adj>2000
egen w_tot=sum(weight_adj) if t==1
gen scale_n=123390/w_tot
replace weight_adj=weight_adj*scale_n if t==1
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
*Poverty figures
la def lt 0 "Wave 1 - NW-Urban" 1 "Wave 2 - NW-Urban", replace
la val t lt
drop pweight
save "${gsdTemp}/hh_w1w2_comparison_V4.dta", replace
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
local i=1
svy: mean poorPPP_prob, over(t)
test _subpop_1 = _subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
putexcel A`i' = "Poverty"
putexcel B`i' =`r(p)'
*Variables of interest
drop pweight
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
qui foreach v of varlist $vars {
	su `v'
	local l : variable label `v'
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	svy: mean `v', over(t)
	test _subpop_1 = _subpop_2
	local i=`i'+1
	putexcel A`i' ="`l'"
	putexcel B`i' =`r(p)'
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="ind_profile"
drop if v1==""
drop v4 v5 
la var v1 "Variable of interest"
la var v2 "Mean"
la var v3 "Mean"
destring v2-v3, replace
foreach x of numlist 2/3 {
	replace v`x'= v`x'[_n+1]
}
drop if v1=="NW-Urban"
gen n = _n
sort n
merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
sort n
drop n
export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_noweight_v1.xlsx", sheet("Raw_4") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"


*Check average age and age distribution * 
foreach k in 1 2 3 4  {
	use "${gsdTemp}/hh_w1w2_comparison_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdData}/1-CleanTemp/hhm_all.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)

	* Average age
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean age) sebnone f(3) h1("Age") npos(col) replace ptotal(none) 
	local i=1
	svy: mean age, over(t)
	test _subpop_1 = _subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "Age"
	putexcel B`i' =`r(p)'
	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren B p_value
	sort v1
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="ind_profile"
	drop if v1==""
	drop v4 v5 
	la var v1 "Variable of interest"
	la var v2 "Mean"
	la var v3 "Mean"
	destring v2-v3, replace
	foreach x of numlist 2/3 {
		replace v`x'= v`x'[_n+1]
	}
	drop if v1=="NW-Urban"
	gen n = _n
	sort n
	merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
	sort n
	drop n
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_noweight_v1.xlsx", sheet("Raw_`k'_2") sheetreplace first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

	* Age distribution
	use "${gsdTemp}/hh_w1w2_comparison_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdData}/1-CleanTemp/hhm_all.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if t==0, svy pop c(perc lb ub) f(5) sebnone h2("Age Distribution, w1") npos(col) replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==1, svy pop c(perc lb ub) f(5) sebnone h2("Age Distribution, w2") npos(col) replace ptotal(none) 
	drop if mi(literacy)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==0, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w1")  replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls" if t==1, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w2")  replace ptotal(none) 
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear nonames tab
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_noweight_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(A3) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	drop v1 
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_noweight_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(F3) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	drop v1 
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_noweight_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(J4) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	drop v1 
	export excel using "${gsdOutput}/W1W2-comparison_NW-Urban_Woqooyi_noweight_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(L4) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls"
}



/*
*=====================================================================
* Comparison between Wave 1 and 2 for regions covered in both
*=====================================================================
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
*hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable

* Set worksheets
qui foreach r in Mogadishu NE-Urban NE-Rural NW-Urban NW-Rural IDP {
	di "`r'"
	preserve
	la def lt 0 "Wave 1 - `r'" 1 "Wave 2 - `r'", replace
	la val t lt
	keep if ind_profile=="`r'"
	*Poverty figures
	drop pweight
	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
	local i=1
	svy: mean poorPPP_prob, over(t)
	test _subpop_1 = _subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_`r'.xls", modify
	putexcel A`i' = "Poverty"
	putexcel B`i' =`r(p)'
	*Variables of interest
	drop pweight
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
	foreach v of varlist $vars {
		su `v'
		local l : variable label `v'
		tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		local i=`i'+1
		putexcel A`i' ="`l'"
		putexcel B`i' =`r(p)'
}
	import excel using "${gsdOutput}/W1W2-comparison_raw2_`r'.xls", clear 
	ren A v1
	ren B p_value
	sort v1
	save "${gsdTemp}/W1W2-comparison_raw2_`r'.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", clear 
	drop if v1=="ind_profile"
	drop if v1==""
	drop v4 v5 
	la var v1 "Variable of interest"
	la var v2 "Mean"
	la var v3 "Mean"
	
	destring v2-v3, replace
	foreach x of numlist 2/3 {
		replace v`x'= v`x'[_n+1]
		
	}
	drop if v1=="`r'"
	gen n = _n
	sort n
	merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_`r'.dta", nogen
	sort n
	drop n
	export excel using "${gsdOutput}/W1W2-comparison_By_Strata_v1.xlsx", sheet("Raw_`r'") sheetmodify cell(B3) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_`r'.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_`r'.xls"
	restore
}

