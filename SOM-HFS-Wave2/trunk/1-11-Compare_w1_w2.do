* Compare wave 1 and wave 2 data w.r.t. stable indicators

set more off
set seed 23081980 
set sortseed 11041955


* open combined data set
use "${gsdData}/1-CleanTemp/hh_all.dta", clear
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)

*=====================================================================
* 1 - Prepare variables of interest that aren't yet in the right format
*=====================================================================
* Housingtype: make wave 2 comparable to wave 1
tab house_type, gen(house_type__)
* cooking source
drop cooking 
ren cook2 cooking
ta cooking, gen(cooking__)

* water
ta water, gen(water__)
* tenure
ta tenure1, gen(tenure__)
* floor
ta floor_material, gen(floor__)
* roof
ta roof_material, gen(roof__) 

* Fix labels
la var hhsize "Household size"
foreach i of varlist cooking__* water__* tenure__* floor__* roof__* {
local a : variable label `i'
local a: subinstr local a "==" ": "
label var `i' "`a'"
}

*=====================================================================
* 2 - Prepare data set for analysis
*=====================================================================
* generate indicator variable
* for wave 1 
cap drop ind_profile
replace astrata=. if t==1
gen ind_profile="NW-Rural" if astrata==22
replace ind_profile="NE-Rural" if astrata==21
replace ind_profile="NW-Urban" if astrata==14 | astrata==15
replace ind_profile="NE-Urban" if astrata==12 | astrata==13 
replace ind_profile="Mogadishu" if astrata==11
replace ind_profile="IDP" if astrata==3

* for wave 2
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



*================================================
* Review the displacement story 
*================================================

*Migration or IDP household
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
svy: mean migr_idp if t==1
tabstat migr_idp [aweight=weight_adj] if ind_profile!="IDP" & ind_profile!="Nomad", by(ind_profile)
tabstat migr_idp [aweight=weight_adj] if inlist(ind_profile,"Central-Rural","Jubbaland-Rural","NE-Rural","NW-Rural","SouthWest-Rural"), by(ind_profile)

*Birthplace
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", keep(match) keepusing(ind_profile)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
*Identify members not born on their current region
gen birth_outside=.
replace birth_outside=1 if !inlist(birthplace_som,1,13,16,17,18) & inlist(ind_profile,"NW-Rural","NW-Urban") 
replace birth_outside=0 if inlist(birthplace_som,1,13,16,17,18) & inlist(ind_profile,"NW-Rural","NW-Urban") 
replace birth_outside=1 if !inlist(birthplace_som,6,8,14) & inlist(ind_profile,"Central-Urban","Central-Rural") 
replace birth_outside=0 if inlist(birthplace_som,6,8,14) & inlist(ind_profile,"Central-Urban","Central-Rural") 
replace birth_outside=1 if !inlist(birthplace_som,7,9,10) & inlist(ind_profile,"Jubbaland-Rural","Jubbaland-Urban") 
replace birth_outside=0 if inlist(birthplace_som,7,9,10) & inlist(ind_profile,"Jubbaland-Rural","Jubbaland-Urban") 
replace birth_outside=1 if !inlist(birthplace_som,3) & inlist(ind_profile,"Mogadishu") 
replace birth_outside=0 if inlist(birthplace_som,3) & inlist(ind_profile,"Mogadishu") 
replace birth_outside=1 if !inlist(birthplace_som,4,11,12) & inlist(ind_profile,"NE-Urban","NE-Rural") 
replace birth_outside=0 if inlist(birthplace_som,4,11,12) & inlist(ind_profile,"NE-Urban","NE-Rural") 
replace birth_outside=1 if !inlist(birthplace_som,2,5,15) & inlist(ind_profile,"SouthWest-Rural","SouthWest-Rural") 
replace birth_outside=0 if inlist(birthplace_som,2,5,15) & inlist(ind_profile,"SouthWest-Rural","SouthWest-Rural") 
replace birth_outside=. if birthplace_som>=.
collapse (mean) birth_outside [w=weight_adj], by(ind_profile)

*Always lived in the current dwelling
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", keep(match) keepusing(ind_profile)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tabstat hh_alwayslived [aweight=weight_adj] if t==0, by(ind_profile)
tabstat hh_alwayslived [aweight=weight_adj] if t==1, by(ind_profile)

*Household member level variables
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", keep(match) keepusing(ind_profile)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
replace literacy= . if age<40
bys t strata ea block hh: egen n_adult_literate=sum(literacy) 
collapse (max) n_adult_literate, by (t strata ea block hh ind_profile weight_adj)
svy: mean n_adult_literate if ind_profile=="NW-Rural", over(t)
test Wave1=Wave2
svy: mean n_adult_literate if ind_profile=="NW-Urban", over(t)
test Wave1=Wave2


*=====================================================================
* 3- Analysis (regions covered in both waves) outputs, indicator by indicator
*=====================================================================
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
* Set worksheets
foreach r in Mogadishu NE-Urban NE-Rural NW-Urban NW-Rural IDP {
	di "`r'"
	preserve
	la def lt 0 "Wave 1 - `r'" 1 "Wave 2 - `r'", replace
	la val t lt
	keep if ind_profile=="`r'"
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", svy sum c(mean poorPPP_prob lb ub) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
	local i=1
	svy: mean poorPPP_prob, over(t)
	test _subpop_1 = _subpop_2
	*rm "${gsdOutput}/W1W2-comparison_raw2_.xls"
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_`r'.xls", modify
	putexcel A`i' = "Poverty"
	putexcel B`i' =`r(p)'
	* variables of interest
	global vars hhsize hhh_gender hhh_age no_adults no_children tenure__* house_type__* floor__* roof__* cooking__* 
	foreach v of varlist $vars {
		su `v'
		local l : variable label `v'
		tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", svy sum c(mean `v' lb ub) sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		local i=`i'+1
		putexcel A`i' ="`l'"
		putexcel B`i' =`r(p)'
	}

	* HHM-Level data 
	use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
	svyset ea [pweight=weight_adj], strata(strata)
	merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", keep(match) keepusing(ind_profile)
	keep if ind_profile=="`r'"
	la def lt 0 "Wave 1 - `r'" 1 "Wave 2 - `r'", replace
	la val t lt
	* focus on adult literacy
	replace literacy = . if age<40
	la var literacy "Adult literacy (40+)"
	global vars_hhm literacy age gender dependent
	foreach v of varlist $vars_hhm {
		su `v'
		local l : variable label `v'
		tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", svy sum c(mean `v' lb ub) sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
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
	drop v8-v11
	la var v1 "Variable of interest"
	la var v2 "Mean"
	la var v3 "LB"
	la var v4 "UB"
	la var v5 "Mean"
	la var v6 "LB"
	la var v7 "UB"
	
	destring v2-v7, replace
	foreach x of numlist 2/7 {
		replace v`x'= v`x'[_n+1]
		
	}
	drop if v1=="`r'"
	gen n = _n
	sort n
	merge 1:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_`r'.dta", nogen
	sort n
	drop n
	export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_`r'") sheetmodify cell(B3) first(varlabels)
	restore
}



*=====================================================================
* 4- Analysis (regions only in Wave 2) outputs, indicator by indicator
*=====================================================================
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
* Set worksheets
foreach r in Nomad Central-Urban Central-Rural Jubbaland-Urban Jubbaland-Rural SouthWest-Urban SouthWest-Rural {
	di "`r'"
	preserve
	la def lt 0 "Wave 1 - `r'" 1 "Wave 2 - `r'", replace
	la val t lt
	keep if ind_profile=="`r'"
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", svy sum c(mean poorPPP_prob lb ub) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 

	local i=1
	svy: mean poorPPP_prob
	
	* variables of interest
	global vars hhsize hhh_gender hhh_age no_adults no_children tenure__* house_type__* floor__* roof__* cooking__* 
	foreach v of varlist $vars {
		su `v'
		local l : variable label `v'
		tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", svy sum c(mean `v' lb ub) sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	}

	* HHM-Level data 
	use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
	svyset ea [pweight=weight_adj], strata(strata)
	merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", keep(match) keepusing(ind_profile)
	keep if ind_profile=="`r'"
	la def lt 0 "Wave 1 - `r'" 1 "Wave 2 - `r'", replace
	la val t lt
	* focus on adult literacy
	replace literacy = . if age<40
	la var literacy "Adult literacy (40+)"
	global vars_hhm literacy age gender dependent
	foreach v of varlist $vars_hhm {
		su `v'
		local l : variable label `v'
		tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", svy sum c(mean `v' lb ub) sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
	}


	insheet using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", clear 
	drop if v1=="ind_profile"
	drop if v1==""
	drop v8
	la var v1 "Variable of interest"
	la var v2 "Mean"
	la var v3 "LB"
	la var v4 "UB"
	la var v5 "Mean"
	la var v6 "LB"
	la var v7 "UB"
	
	destring v2-v7, replace
	foreach x of numlist 2/7 {
		replace v`x'= v`x'[_n+1]
		
	}
	drop if v1=="`r'"
	export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_`r'") sheetmodify cell(B3) first(varlabels)
	restore
}

*Delete intermediate files
foreach r in Mogadishu NE-Urban NW-Urban NE-Rural NW-Rural IDP {
	erase "${gsdOutput}/W1W2-comparison_raw1_`r'.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_`r'.xls"
}
foreach r in Nomad Central-Urban Central-Rural Jubbaland-Urban Jubbaland-Rural SouthWest-Urban SouthWest-Rural {
	erase "${gsdOutput}/W1W2-comparison_raw1_`r'.xls"

}


*=====================================================================
*5 Checks to food consumption
*=====================================================================
* List of items in Waves 1 and 2
use itemid using "${gsdData}/1-CleanInput/SHFS2016/food.dta", clear
duplicates drop
decode itemid, gen(item_name)
ren itemid itemid_w1
gen item_name_w1 = item_name
tempfile item_list_w1
save `item_list_w1', replace 
use itemid using  "${gsdData}/1-CleanOutput/food.dta", clear
duplicates drop
decode itemid, gen(item_name)
ren itemid itemid_w2
gen item_name_w2 = item_name
tempfile item_list_w2
save `item_list_w2', replace 

* List of items - Wave 1 & 2
use `item_list_w1', clear
*merge 1:1 item_name using `item_list_w2', keep(match)
merge 1:1 item_name using `item_list_w2'
sort item_name
tempfile item_list
save `item_list', replace 


*Number of items consumed per household   
* Wave 1 Data
use "${gsdData}/1-CleanInput/SHFS2016/food.dta", clear
gen ind_profile=6 if astrata==3
replace ind_profile=5 if astrata==22
replace ind_profile=4 if astrata==21
replace ind_profile=3 if astrata==14 | astrata==15
replace ind_profile=2 if astrata==12 | astrata==13 
replace ind_profile=1 if astrata==11
label define lind_profile 1 "Mogadishu (Urban)" 2 "North-east Urban (Nugaal,Bari,Mudug)" 3 "North-west Urban (Woqooyi G,Awdal,Sanaag,Sool,Togdheer)" 4 "North-east Rural (Bari,Mudug,Nugaal)" 5 "North-west Rural (Awdal,Sanaag,Sool,Togdheer,Woqooyi)" 6 "IDP Settlements"
label values ind_profile lind_profile
label var ind_profile "Indicator: Mogadishu, North-East urban/rural, North-West urban/rural & IDPs"

* Dummy for a item consumed by a household
gen item_cons = (cons_usd_org >0 & cons_usd_org < .)
* Number of items consumed per household
bys strata ea block hh  : egen hh_no_items = total (item_cons)
* Number of items consumed per region
collapse (mean) hh_no_items_mn = hh_no_items (median) hh_no_items_md = hh_no_items, by (ind_profile)
ren (hh_no_items_mn hh_no_items_md) (hh_no_items_mn_w1 hh_no_items_md_w1)
decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

tempfile hh_no_items_w1
save `hh_no_items_w1', replace 

* Wave 2 Data
use "${gsdData}/1-CleanOutput/food.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen assert(match) keepusing(ind_profile)

* Dummy for a item consumed by a household
gen item_cons = (cons_usd_org >0 & cons_usd_org < .)
* Number of items consumed per household
bys strata ea block hh  : egen hh_no_items = total (item_cons)
* Number of items consumed per region
collapse (mean) hh_no_items_mn = hh_no_items (median) hh_no_items_md = hh_no_items, by (ind_profile)
ren (hh_no_items_mn hh_no_items_md) (hh_no_items_mn_w2 hh_no_items_md_w2)
decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)
tempfile hh_no_items_w2
save `hh_no_items_w2', replace 

*Merge Wave 1 and 2
use `hh_no_items_w1', clear
merge 1:1 ind_profile using `hh_no_items_w2', nogen

* Dummy for Urban/Rural
gen urban = 1 if strpos(ind_profile_d, "Urban")
replace urban = 0 if strpos(ind_profile_d, "Rural")
lab def urban 1 "Urban" 0 "Rural"
lab val urban urban 

* Impute values for missing values in Wave 1
* Mean and median excluding the region itself
rangestat (mean) hh_no_items_mn_imp=hh_no_items_mn_w2 (median) hh_no_items_md_imp=hh_no_items_md_w2, excludeself int(ind_profile . .) by(urban)
replace hh_no_items_mn_w1 = hh_no_items_mn_imp if mi(hh_no_items_mn_w1)
replace hh_no_items_md_w1 = hh_no_items_md_imp if mi(hh_no_items_md_w1)

* Flag where change between waves 1 and 2 is greater than 25%
gen flag_mn = abs(((hh_no_items_mn_w2 - hh_no_items_mn_w1)/ hh_no_items_mn_w1)*100) > 25
gen flag_md = abs(((hh_no_items_md_w2 - hh_no_items_md_w1)/ hh_no_items_md_w1)*100) > 25

lab var hh_no_items_mn_w1 "Number of items consumed - Mean - Wave 1"
lab var hh_no_items_md_w1 "Number of items consumed - Median - Wave 1"
lab var hh_no_items_mn_w2 "Number of items consumed - Mean - Wave 2"
lab var hh_no_items_md_w2 "Number of items consumed - Median - Wave 2"
lab var flag_mn "Flag - Mean value"
lab var flag_md "Flag - Median value"

drop ind_profile hh_no_items_mn_imp hh_no_items_md_w1
order urban, last

export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_Food_1") sheetmodify cell(B3) firstrow(variables)


*Consumption in Kg per person per day     
* Wave 1 Data
use "${gsdData}/1-CleanInput/SHFS2016/food.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", nogen assert(match using) keepusing(hhsize)
gen ind_profile=6 if astrata==3
replace ind_profile=5 if astrata==22
replace ind_profile=4 if astrata==21
replace ind_profile=3 if astrata==14 | astrata==15
replace ind_profile=2 if astrata==12 | astrata==13 
replace ind_profile=1 if astrata==11
label values ind_profile lind_profile
label var ind_profile "Indicator: Mogadishu, North-East urban/rural, North-West urban/rural & IDPs"
decode itemid, gen(item_name)
merge m:1 item_name using `item_list', nogen keep(match)

gen cons_kg_pers_day = cons_q_kg / (7* hhsize)
collapse (mean) cons_kg_mn = cons_kg_pers_day (median) cons_kg_md = cons_kg_pers_day, by (ind_profile item_name)
ren (cons_kg_mn cons_kg_md) (cons_kg_mn_w1 cons_kg_md_w1)

decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

lab var cons_kg_mn_w1 "Consumption in Kg per person per day - Mean - Wave 1"
lab var cons_kg_md_w1 "Consumption in Kg per person per day - Median - Wave 1"

tempfile cons_kg_w1
save `cons_kg_w1', replace


* Wave 2 Data
use "${gsdData}/1-CleanOutput/food.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen assert(match) keepusing(ind_profile hhsize)
decode itemid, gen(item_name)
merge m:1 item_name using `item_list', nogen keep(match)

gen cons_kg_pers_day = cons_q_kg / (7* hhsize)
collapse (mean) cons_kg_mn = cons_kg_pers_day (median) cons_kg_md = cons_kg_pers_day, by (ind_profile item_name)
ren (cons_kg_mn cons_kg_md) (cons_kg_mn_w2 cons_kg_md_w2)

decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

lab var cons_kg_mn_w2 "Consumption in Kg per person per day - Mean - Wave 2"
lab var cons_kg_md_w2 "Consumption in Kg per person per day - Median - Wave 2"

tempfile cons_kg_w2
save `cons_kg_w2', replace


*Merge Wave 1 and 2
use `cons_kg_w2', clear
merge 1:1 ind_profile item_name using `cons_kg_w1', nogen

order *w2, last

* Dummy for Urban/Rural
gen urban = 1 if strpos(ind_profile_d, "Urban")
replace urban = 0 if strpos(ind_profile_d, "Rural")
lab def urban 1 "Urban" 0 "Rural"
lab val urban urban 

* Impute values for missing values in Wave 1
* Mean and median excluding the region itself
rangestat (mean) cons_kg_mn_imp=cons_kg_mn_w2 (median) cons_kg_md_imp=cons_kg_md_w2, excludeself int(ind_profile . .) by(urban)
replace cons_kg_mn_w1 = cons_kg_mn_imp if mi(cons_kg_mn_w1)
replace cons_kg_md_w1 = cons_kg_md_imp if mi(cons_kg_md_w1)


* Flag where change between waves 1 and 2 is greater than 25%
gen flag_mn = abs(((cons_kg_mn_w2 - cons_kg_mn_w1)/ cons_kg_mn_w1)*100) > 25
gen flag_md = abs(((cons_kg_md_w2 - cons_kg_md_w1)/ cons_kg_md_w1)*100) > 25

lab var flag_mn "Flag - Mean value"
lab var flag_md "Flag - Median value"

drop ind_profile

export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_Food_2") sheetmodify cell(B3) firstrow(variables)




*=====================================================================
* 6 non-food consumption
*=====================================================================

* List of items in Waves 1 and 2
* List of items - Wave 1
use itemid using "${gsdData}/1-CleanInput/SHFS2016/nonfood.dta", clear
duplicates drop
*decode itemid, gen(item_name_w1)
decode itemid, gen(item_name)
ren itemid itemid_w1
gen item_name_w1 = item_name
tempfile item_list_w1
save `item_list_w1', replace 

* List of items - Wave 2
use itemid using "${gsdData}/1-CleanOutput/nonfood.dta", clear
duplicates drop
*decode itemid, gen(item_name_w2)
decode itemid, gen(item_name)
ren itemid itemid_w2
gen item_name_w2 = item_name
tempfile item_list_w2
save `item_list_w2', replace 

* List of items - Wave 1 & 2
use `item_list_w1', clear
*merge 1:1 item_name using `item_list_w2', keep(match)
merge 1:1 item_name using `item_list_w2'
sort item_name
tempfile item_list
save `item_list', replace 

* Number of items consumed per household   
* Wave 1 Data
use "${gsdData}/1-CleanInput/SHFS2016/nonfood.dta", clear
gen ind_profile=6 if astrata==3
replace ind_profile=5 if astrata==22
replace ind_profile=4 if astrata==21
replace ind_profile=3 if astrata==14 | astrata==15
replace ind_profile=2 if astrata==12 | astrata==13 
replace ind_profile=1 if astrata==11
label define lind_profile 1 "Mogadishu (Urban)" 2 "North-east Urban (Nugaal,Bari,Mudug)" 3 "North-west Urban (Woqooyi G,Awdal,Sanaag,Sool,Togdheer)" 4 "North-east Rural (Bari,Mudug,Nugaal)" 5 "North-west Rural (Awdal,Sanaag,Sool,Togdheer,Woqooyi)" 6 "IDP Settlements"
label values ind_profile lind_profile
label var ind_profile "Indicator: Mogadishu, North-East urban/rural, North-West urban/rural & IDPs"

* Dummy for a item consumed by a household
gen item_cons = (purc == 1)
* Number of items consumed per household
bys strata ea block hh  : egen hh_no_items = total (item_cons)

* Number of items consumed per region
collapse (mean) hh_no_items_mn = hh_no_items (median) hh_no_items_md = hh_no_items, by (ind_profile)
ren (hh_no_items_mn hh_no_items_md) (hh_no_items_mn_w1 hh_no_items_md_w1)

decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

tempfile hh_no_items_w1
save `hh_no_items_w1', replace 


* Wave 2 Data
use "${gsdData}/1-CleanOutput/nonfood.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen assert(match) keepusing(ind_profile)

* Dummy for a item consumed by a household
gen item_cons = (purc == 1)
* Number of items consumed per household
bys strata ea block hh  : egen hh_no_items = total (item_cons)

* Number of items consumed per region
collapse (mean) hh_no_items_mn = hh_no_items (median) hh_no_items_md = hh_no_items, by (ind_profile)
ren (hh_no_items_mn hh_no_items_md) (hh_no_items_mn_w2 hh_no_items_md_w2)

decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

tempfile hh_no_items_w2
save `hh_no_items_w2', replace 

*Merge Wave 1 and 2
use `hh_no_items_w1', clear
merge 1:1 ind_profile using `hh_no_items_w2', nogen

* Dummy for Urban/Rural
gen urban = 1 if strpos(ind_profile_d, "Urban")
replace urban = 0 if strpos(ind_profile_d, "Rural")
lab def urban 1 "Urban" 0 "Rural"
lab val urban urban 

* Impute values for missing values in Wave 1
* Mean and median excluding the region itself
rangestat (mean) hh_no_items_mn_imp=hh_no_items_mn_w2 (median) hh_no_items_md_imp=hh_no_items_md_w2, excludeself int(ind_profile . .) by(urban)
replace hh_no_items_mn_w1 = hh_no_items_mn_imp if mi(hh_no_items_mn_w1)
replace hh_no_items_md_w1 = hh_no_items_md_imp if mi(hh_no_items_md_w1)

* Flag where change between waves 1 and 2 is greater than 25%
gen flag_mn = abs(((hh_no_items_mn_w2 - hh_no_items_mn_w1)/ hh_no_items_mn_w1)*100) > 25
gen flag_md = abs(((hh_no_items_md_w2 - hh_no_items_md_w1)/ hh_no_items_md_w1)*100) > 25

lab var hh_no_items_mn_w1 "Number of items consumed - Mean - Wave 1"
lab var hh_no_items_md_w1 "Number of items consumed - Median - Wave 1"
lab var hh_no_items_mn_w2 "Number of items consumed - Mean - Wave 2"
lab var hh_no_items_md_w2 "Number of items consumed - Median - Wave 2"
lab var flag_mn "Flag - Mean value"
lab var flag_md "Flag - Median value"

drop ind_profile hh_no_items_mn_imp hh_no_items_md_w1
order urban, last

export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_NonFood_2") sheetmodify cell(B3) firstrow(variables)



*=====================================================================
* 7 durables
*=====================================================================
* List of items in Waves 1 and 2
* List of items - Wave 1
use itemid using "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
duplicates drop
decode itemid, gen(item_name)
ren itemid itemid_w1
gen item_name_w1 = item_name
tempfile item_list_w1
save `item_list_w1', replace 

* List of items - Wave 2
use itemid using "${gsdData}/1-CleanOutput/assets.dta", clear
duplicates drop
decode itemid, gen(item_name)
ren itemid itemid_w2
gen item_name_w2 = item_name
tempfile item_list_w2
save `item_list_w2', replace 

* List of items - Wave 1 & 2
use `item_list_w1', clear
*merge 1:1 item_name using `item_list_w2', keep(match)
merge 1:1 item_name using `item_list_w2'
sort item_name
tempfile item_list
save `item_list', replace 


* Number of items owned per household
* Wave 1 Data
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
gen ind_profile=6 if astrata==3
replace ind_profile=5 if astrata==22
replace ind_profile=4 if astrata==21
replace ind_profile=3 if astrata==14 | astrata==15
replace ind_profile=2 if astrata==12 | astrata==13 
replace ind_profile=1 if astrata==11
label define lind_profile 1 "Mogadishu (Urban)" 2 "North-east Urban (Nugaal,Bari,Mudug)" 3 "North-west Urban (Woqooyi G,Awdal,Sanaag,Sool,Togdheer)" 4 "North-east Rural (Bari,Mudug,Nugaal)" 5 "North-west Rural (Awdal,Sanaag,Sool,Togdheer,Woqooyi)" 6 "IDP Settlements"
label values ind_profile lind_profile
label var ind_profile "Indicator: Mogadishu, North-East urban/rural, North-West urban/rural & IDPs"

* Dummy for a item owned by a household
gen item_own = (own == 1)
* Number of items owned per household
bys strata ea block hh  : egen hh_no_items = total (item_own)

* Number of items owned per region
collapse (mean) hh_no_items_mn = hh_no_items (median) hh_no_items_md = hh_no_items, by (ind_profile)
ren (hh_no_items_mn hh_no_items_md) (hh_no_items_mn_w1 hh_no_items_md_w1)

decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

tempfile hh_no_items_w1
save `hh_no_items_w1', replace 


* Wave 2 Data
use "${gsdData}/1-CleanOutput/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen assert(match) keepusing(ind_profile)

* Dummy for a item owned by a household
gen item_own = (own == 1)
* Number of items owned per household
bys strata ea block hh  : egen hh_no_items = total (item_own)

* Number of items owned per region
collapse (mean) hh_no_items_mn = hh_no_items (median) hh_no_items_md = hh_no_items, by (ind_profile)
ren (hh_no_items_mn hh_no_items_md) (hh_no_items_mn_w2 hh_no_items_md_w2)

decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

tempfile hh_no_items_w2
save `hh_no_items_w2', replace 

*Merge Wave 1 and 2
use `hh_no_items_w1', clear
merge 1:1 ind_profile using `hh_no_items_w2', nogen

* Dummy for Urban/Rural
gen urban = 1 if strpos(ind_profile_d, "Urban")
replace urban = 0 if strpos(ind_profile_d, "Rural")
lab def urban 1 "Urban" 0 "Rural"
lab val urban urban 

* Impute values for missing values in Wave 1
* Mean and median excluding the region itself
rangestat (mean) hh_no_items_mn_imp=hh_no_items_mn_w2 (median) hh_no_items_md_imp=hh_no_items_md_w2, excludeself int(ind_profile . .) by(urban)
replace hh_no_items_mn_w1 = hh_no_items_mn_imp if mi(hh_no_items_mn_w1)
replace hh_no_items_md_w1 = hh_no_items_md_imp if mi(hh_no_items_md_w1)

* Flag where change between waves 1 and 2 is greater than 25%
gen flag_mn = abs(((hh_no_items_mn_w2 - hh_no_items_mn_w1)/ hh_no_items_mn_w1)*100) > 25
gen flag_md = abs(((hh_no_items_md_w2 - hh_no_items_md_w1)/ hh_no_items_md_w1)*100) > 25

lab var hh_no_items_mn_w1 "Number of items owned - Mean - Wave 1"
lab var hh_no_items_md_w1 "Number of items owned - Median - Wave 1"
lab var hh_no_items_mn_w2 "Number of items owned - Mean - Wave 2"
lab var hh_no_items_md_w2 "Number of items owned - Median - Wave 2"
lab var flag_mn "Flag - Mean value"
lab var flag_md "Flag - Median value"

drop ind_profile hh_no_items_mn_imp hh_no_items_md_w1
order urban, last

export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_Assets_1") sheetmodify cell(B3) firstrow(variables)


* Consumption flow for each durable good
* Wave 1 Data
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
gen ind_profile=6 if astrata==3
replace ind_profile=5 if astrata==22
replace ind_profile=4 if astrata==21
replace ind_profile=3 if astrata==14 | astrata==15
replace ind_profile=2 if astrata==12 | astrata==13 
replace ind_profile=1 if astrata==11
label define lind_profile 1 "Mogadishu (Urban)" 2 "North-east Urban (Nugaal,Bari,Mudug)" 3 "North-west Urban (Woqooyi G,Awdal,Sanaag,Sool,Togdheer)" 4 "North-east Rural (Bari,Mudug,Nugaal)" 5 "North-west Rural (Awdal,Sanaag,Sool,Togdheer,Woqooyi)" 6 "IDP Settlements"
label values ind_profile lind_profile
label var ind_profile "Indicator: Mogadishu, North-East urban/rural, North-West urban/rural & IDPs"

decode itemid, gen(item_name)
merge m:1 item_name using `item_list', nogen keep(match)

collapse (mean) cons_flow_mn = cons_flow (median) cons_flow_md = cons_flow, by (ind_profile item_name)
ren (cons_flow_mn cons_flow_md) (cons_flow_mn_w1 cons_flow_md_w1)

decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

lab var cons_flow_mn_w1 "Consumption flow - Mean - Wave 1"
lab var cons_flow_md_w1 "Consumption flow - Median - Wave 1"

tempfile cons_flow_w1
save `cons_flow_w1', replace


* Wave 2 Data
use "${gsdData}/1-CleanOutput/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen assert(match) keepusing(ind_profile)
decode itemid, gen(item_name)
merge m:1 item_name using `item_list', nogen keep(match)

collapse (mean) cons_flow_mn = cons_flow (median) cons_flow_md = cons_flow, by (ind_profile item_name)
ren (cons_flow_mn cons_flow_md) (cons_flow_mn_w2 cons_flow_md_w2)

decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

lab var cons_flow_mn_w2 "Consumption flow - Mean - Wave 2"
lab var cons_flow_md_w2 "Consumption flow - Median - Wave 2"

tempfile cons_flow_w2
save `cons_flow_w2', replace


*Merge Wave 1 and 2
use `cons_flow_w2', clear
merge 1:1 ind_profile item_name using `cons_flow_w1', nogen

order *w2, last

* Dummy for Urban/Rural
gen urban = 1 if strpos(ind_profile_d, "Urban")
replace urban = 0 if strpos(ind_profile_d, "Rural")
lab def urban 1 "Urban" 0 "Rural"
lab val urban urban 

* Impute values for missing values in Wave 1
* Mean and median excluding the region itself
rangestat (mean) cons_flow_mn_imp=cons_flow_mn_w2 (median) cons_flow_md_imp=cons_flow_md_w2, excludeself int(ind_profile . .) by(urban)
replace cons_flow_mn_w1 = cons_flow_mn_imp if mi(cons_flow_mn_w1)
replace cons_flow_md_w1 = cons_flow_md_imp if mi(cons_flow_md_w1)

* Flag where change between waves 1 and 2 is greater than 25%
gen flag_mn = abs(((cons_flow_mn_w2 - cons_flow_mn_w1)/ cons_flow_mn_w1)*100) > 25
gen flag_md = abs(((cons_flow_md_w2 - cons_flow_md_w1)/ cons_flow_md_w1)*100) > 25

lab var flag_mn "Flag - Mean value"
lab var flag_md "Flag - Median value"

drop ind_profile
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_Assets_2") sheetmodify cell(B3) firstrow(variables)


* Median depreciation rates for each durable good
* Wave 1 Data
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
gen ind_profile=6 if astrata==3
replace ind_profile=5 if astrata==22
replace ind_profile=4 if astrata==21
replace ind_profile=3 if astrata==14 | astrata==15
replace ind_profile=2 if astrata==12 | astrata==13 
replace ind_profile=1 if astrata==11
label define lind_profile 1 "Mogadishu (Urban)" 2 "North-east Urban (Nugaal,Bari,Mudug)" 3 "North-west Urban (Woqooyi G,Awdal,Sanaag,Sool,Togdheer)" 4 "North-east Rural (Bari,Mudug,Nugaal)" 5 "North-west Rural (Awdal,Sanaag,Sool,Togdheer,Woqooyi)" 6 "IDP Settlements"
label values ind_profile lind_profile
label var ind_profile "Indicator: Mogadishu, North-East urban/rural, North-West urban/rural & IDPs"

decode itemid, gen(item_name)
merge m:1 item_name using `item_list', nogen keep(match)

collapse (mean) drate_median_mn = drate_median (median) drate_median_md = drate_median, by (ind_profile item_name)
ren (drate_median_mn drate_median_md) (drate_median_mn_w1 drate_median_md_w1)

decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

lab var drate_median_mn_w1 "Unit Price - Mean - Wave 1"
lab var drate_median_md_w1 "Unit Price - Median - Wave 1"

tempfile drate_median_w1
save `drate_median_w1', replace

* Wave 2 Data
use "${gsdData}/1-CleanOutput/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen assert(match) keepusing(ind_profile)
decode itemid, gen(item_name)
merge m:1 item_name using `item_list', nogen keep(match)

collapse (mean) drate_median_mn = drate_median (median) drate_median_md = drate_median, by (ind_profile item_name)
ren (drate_median_mn drate_median_md) (drate_median_mn_w2 drate_median_md_w2)

decode ind_profile, gen(ind_profile_d)
order ind_profile_d, after(ind_profile)

lab var drate_median_mn_w2 "Unit Price - Mean - Wave 2"
lab var drate_median_md_w2 "Unit Price - Median - Wave 2"

tempfile drate_median_w2
save `drate_median_w2', replace


*Merge Wave 1 and 2
use `drate_median_w2', clear
merge 1:1 ind_profile item_name using `drate_median_w1', nogen

order *w2, last

* Dummy for Urban/Rural
gen urban = 1 if strpos(ind_profile_d, "Urban")
replace urban = 0 if strpos(ind_profile_d, "Rural")
lab def urban 1 "Urban" 0 "Rural"
lab val urban urban 

* Impute values for missing values in Wave 1
* Mean and median excluding the region itself
rangestat (mean) drate_median_mn_imp=drate_median_mn_w2 (median) drate_median_md_imp=drate_median_md_w2, excludeself int(ind_profile . .) by(urban)
replace drate_median_mn_w1 = drate_median_mn_imp if mi(drate_median_mn_w1)
replace drate_median_md_w1 = drate_median_md_imp if mi(drate_median_md_w1)

* Flag where change between waves 1 and 2 is greater than 25%
gen flag_mn = abs(((drate_median_mn_w2 - drate_median_mn_w1)/ drate_median_mn_w1)*100) > 25
gen flag_md = abs(((drate_median_md_w2 - drate_median_md_w1)/ drate_median_md_w1)*100) > 25

lab var flag_mn "Flag - Mean value"
lab var flag_md "Flag - Median value"

drop ind_profile
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_Assets_3") sheetmodify cell(B3) firstrow(variables)



*=====================================================================
* 8 share of food and non-food
*=====================================================================
use "${gsdData}/1-CleanTemp/hh_all.dta", clear
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
replace tc_imp=tc_imp*7*hhsize
gen share_food=tc_imp_f/tc_imp
gen share_nfood=tc_imp_nf/tc_imp
gen ratio_f_nf=share_food/share_nfood

preserve 
keep if t==0
collapse (median) ratio_f_nf, by(ind_profile)
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_Share_Cons") sheetmodify cell(B3) firstrow(variables)
restore

keep if t==1
collapse (median) ratio_f_nf, by(ind_profile)
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_Share_Cons") sheetmodify cell(D3) firstrow(variables)




*=====================================================================
* 9 Non-monetary indicators
*=====================================================================

*Wave 2
use "${gsdData}/1-CleanOutput/hh.dta", clear
gen pweight=weight*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
*Literacy 
qui tabout ind_profile using "${gsdOutput}/Prelim_Analysis_1.xls", svy sum c(mean pliteracy se lb ub) format (2c) sebnone h2(Proprtion literate in hh) replace
*Enrolment
qui tabout ind_profile using "${gsdOutput}/Prelim_Analysis_1.xls", svy sum c(mean penrol se lb ub) format (2c) sebnone h2(Proprtion enrolled (6-17)) append
*Household has at least one economically active member
qui tabout ind_profile using "${gsdOutput}/Prelim_Analysis_1.xls", svy sum c(mean lfp_7d_hh se lb ub) format (2c) sebnone h2(HH has at least one economically active member) append
*Household has at least one employed member
qui tabout ind_profile using "${gsdOutput}/Prelim_Analysis_1.xls", svy sum c(mean emp_7d_hh se lb ub) format (2c) sebnone h2(HH has at least one employed member) append
*Electricity 
qui tabout ind_profile using "${gsdOutput}/Prelim_Analysis_1.xls", svy sum c(mean electricity se lb ub) format (2c) sebnone h2(HH has electricity) append
*Improved sanitation
gen improved_sanitaiton=1 if inlist(toilet,1,2,3,4,5)
replace improved_sanitaiton=0 if improved_sanitaiton==.
qui tabout ind_profile using "${gsdOutput}/Prelim_Analysis_1.xls", svy sum c(mean improved_sanitaiton se lb ub) format (2c) sebnone h2(HH has access to improved sanitation) append
*Improved water
gen piped_water = water
replace piped_water= 1 if inlist(water,1,2)
replace piped_water=0 if inlist(water,3,4,5,.,.a,.b)
qui tabout ind_profile using "${gsdOutput}/Prelim_Analysis_1.xls", svy sum c(mean piped_water se lb ub) format (2c) sebnone h2(HH has access to piped water) append
*Floor of cement
gen floor_cement=(floor_material==1)
qui tabout ind_profile using "${gsdOutput}/Prelim_Analysis_1.xls", svy sum c(mean floor_cement se lb ub) format (2c) sebnone h2(HH has foor of cement) append
*Roof of metal sheets
gen roof_metal=(roof_material==1)
qui tabout ind_profile using "${gsdOutput}/Prelim_Analysis_1.xls", svy sum c(mean roof_metal se lb ub) format (2c) sebnone h2(HH has roof of metal sheets) append

insheet using "${gsdOutput}/Prelim_Analysis_1.xls", clear nonames tab
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_Multi_Deprivation") sheetmodify cell(D3) firstrow(variables)
erase "${gsdOutput}/Prelim_Analysis_1.xls"


*Puntland Wave 1 vs. Wave 2
use "${gsdData}/1-CleanTemp/hh_all.dta", clear
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
*Literacy 
qui tabout t if ind_profile==2 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean pliteracy se lb ub) format (2c) sebnone h2(Proprtion literate NE Urban) replace
qui tabout t if ind_profile==4 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean pliteracy se lb ub) format (2c) sebnone h2(Proprtion literate NE Rural) append
svy: mean pliteracy if ind_profile==2, over(t)
test Wave1 =Wave2
svy: mean pliteracy if ind_profile==4, over(t)
test Wave1 =Wave2

*Enrolment
qui tabout t if ind_profile==2 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean penrol se lb ub) format (2c) sebnone h2(Proprtion enrolled (6-17) NE Urban) append
qui tabout t if ind_profile==4 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean penrol se lb ub) format (2c) sebnone h2(Proprtion enrolled (6-17) NE Rural) append
svy: mean penrol if ind_profile==2, over(t)
test Wave1 =Wave2
svy: mean penrol if ind_profile==4, over(t)
test Wave1 =Wave2

*Household has at least one economically active member
qui tabout t if ind_profile==2 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean lfp_7d_hh se lb ub) format (2c) sebnone h2(HH has at least one economically active member NE Urban) append
qui tabout t if ind_profile==4 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean lfp_7d_hh se lb ub) format (2c) sebnone h2(HH has at least one economically active member NE Rural) append
svy: mean lfp_7d_hh if ind_profile==2, over(t)
test Wave1 =Wave2
svy: mean lfp_7d_hh if ind_profile==4, over(t)
test Wave1 =Wave2

*Household has at least one employed member
qui tabout t if ind_profile==2 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean emp_7d_hh se lb ub) format (2c) sebnone h2(HH has at least one employed member NE Urban) append
qui tabout t if ind_profile==4 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean emp_7d_hh se lb ub) format (2c) sebnone h2(HH has at least one employed member NE Rural) append
svy: mean emp_7d_hh if ind_profile==2, over(t)
test Wave1 =Wave2
svy: mean emp_7d_hh if ind_profile==4, over(t)
test Wave1 =Wave2

*Improved sanitation
gen improved_sanitation=1 if inlist(toilet_type,1,1000) 
replace improved_sanitation=1 if inlist(toilet,1,2,3,4,5) 
replace improved_sanitation=0 if improved_sanitation==.
qui tabout t if ind_profile==2 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean improved_sanitation se lb ub) format (2c) sebnone h2(HH has access to improved sanitation NE Urban) append
qui tabout t if ind_profile==4 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean improved_sanitation se lb ub) format (2c) sebnone h2(HH has access to improved sanitation NE Rural) append
svy: mean improved_sanitation if ind_profile==2, over(t)
test Wave1 =Wave2
svy: mean improved_sanitation if ind_profile==4, over(t)
test Wave1 =Wave2

*Improved water
gen piped_water = water
replace piped_water= 1 if inlist(water,1,2)
replace piped_water=0 if inlist(water,3,4,5,.,.a,.b)
qui tabout t if ind_profile==2 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean piped_water se lb ub) format (2c) sebnone h2(HH has access to piped water NE Urban) append
qui tabout t if ind_profile==4 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean piped_water se lb ub) format (2c) sebnone h2(HH has access to piped water NE Rural) append
svy: mean piped_water if ind_profile==2, over(t)
test Wave1 =Wave2
svy: mean piped_water if ind_profile==4, over(t)
test Wave1 =Wave2

*Floor of cement
gen floor_cement=(floor_material==1) if !missing(floor_material)
qui tabout t if ind_profile==2 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean floor_cement se lb ub) format (2c) sebnone h2(HH has foor of cement NE Urban) append
qui tabout t if ind_profile==4 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean floor_cement se lb ub) format (2c) sebnone h2(HH has foor of cement NE Rural) append
svy: mean floor_cement if ind_profile==2, over(t)
test Wave1 =Wave2
svy: mean floor_cement if ind_profile==4, over(t)
test Wave1 =Wave2

*Roof of metal sheets
gen roof_metal=(roof_material==1) if !missing(roof_material)
qui tabout t if ind_profile==2 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean roof_metal se lb ub) format (2c) sebnone h2(HH has roof of metal sheets NE Urban) append
qui tabout t if ind_profile==4 using "${gsdOutput}/Prelim_Analysis_2.xls", svy sum c(mean roof_metal se lb ub) format (2c) sebnone h2(HH has roof of metal sheets NE Rural) append
svy: mean roof_metal if ind_profile==2, over(t)
test Wave1 =Wave2
svy: mean roof_metal if ind_profile==4, over(t)
test Wave1 =Wave2

insheet using "${gsdOutput}/Prelim_Analysis_2.xls", clear nonames tab
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Raw_Multi_Deprivation_W1_2") sheetmodify cell(D3) firstrow(variables)
erase "${gsdOutput}/Prelim_Analysis_2.xls"
