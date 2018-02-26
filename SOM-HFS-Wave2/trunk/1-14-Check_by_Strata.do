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
replace literacy=. if age<25
bys t strata ea block hh: egen n_literate=sum(literacy)
gen dum_iliterate_adult_hh=(n_literate==0)
bys t strata ea block hh: egen n_dependent=sum(dependent)
collapse (max) n_literate dum_iliterate_adult_hh n_dependent, by(t strata ea block hh)
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

gen imp_sanitation_comparable=1 if t==0 & inlist(toilet_type,1,1000) 
replace imp_sanitation_comparable=1 if t==1 & inlist(toilet,1,2,3,4,5) 
replace imp_sanitation_comparable=0 if imp_sanitation_comparable==. 
replace imp_sanitation_comparable=. if t==0 & toilet_type>=.
replace imp_sanitation_comparable=. if t==1 & toilet>=.
label var imp_sanitation_comparable "HH with improve sanitation"
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
save "${gsdTemp}/hh_w1w2_comparison.dta", replace


*=====================================================================
* Comparison between Wave 1 and 2 for regions covered in both
*=====================================================================
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
*hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water imp_sanitation_comparable 

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
	gen pweight=weight_adj*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)
	global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water imp_sanitation_comparable 
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

