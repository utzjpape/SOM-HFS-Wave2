* Compare wave 1 and wave 2 data w.r.t. stable indicators

set more off
set seed 23081980 
set sortseed 11041955

* open combined data set
use "${gsdData}/1-CleanTemp/hh_all.dta", clear
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)

* 1 - Prepare variables of interest that aren't yet in the right format
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

* 2 - Prepare data set for analysis
* generate indicator variable
* for wave 1 
cap drop ind_profile
assert astrata==. if t==1
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


* 3- Analysis (regions covered in both waves) outputs, indicator by indicator
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
* Set worksheets
foreach r in Mogadishu NE-Urban NE-Rural NW-Urban NW-Rural IDP {
	di "`r'"
	preserve
	la def lt 0 "Wave 1 - `r'" 1 "Wave 2 - `r'", replace
	la val t lt
	keep if ind_profile=="`r'"
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", svy sum c(mean poorPPP lb ub) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
	local i=1
	svy: mean poorPPP, over(t)
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
	replace literacy = . if age<15
	la var literacy "Adult literacy (15+)"
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
	export excel using "${gsdOutput}/W1W2-comparison_v1.xlsx", sheet("Raw_`r'") sheetmodify cell(B3) first(varlabels)
	restore
}

* 4- Analysis (regions only in Wave 2) outputs, indicator by indicator
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
* Set worksheets
foreach r in Nomad Central-Urban Central-Rural Jubbaland-Urban Jubbaland-Rural SouthWest-Urban SouthWest-Rural {
	di "`r'"
	preserve
	la def lt 0 "Wave 1 - `r'" 1 "Wave 2 - `r'", replace
	la val t lt
	keep if ind_profile=="`r'"
	tabout ind_profile t using "${gsdOutput}/W1W2-comparison_raw1_`r'.xls", svy sum c(mean poorPPP lb ub) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 

	local i=1
	svy: mean poorPPP
	
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
	replace literacy = . if age<15
	la var literacy "Adult literacy (15+)"
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
	export excel using "${gsdOutput}/W1W2-comparison_v1.xlsx", sheet("Raw_`r'") sheetmodify cell(B3) first(varlabels)
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

/*

** Temporary: look into number of items consumed
use "${gsdData}/1-CleanOutput/food.dta", clear
* count number of core items consumed per household
*keep if mod_item==0
gen x = cons_q>0 & cons_q<.
collapse (sum) no_items = x (mean) av_cons_q = cons_q_kg, by(strata ea block hh weight hhsize)
replace no_items = no_items/hhsize
la var no_items "Items consumed p.c."
replace av_cons_q = av_cons_q / hhsize
la var av_cons_q "Average quantity per capita"


merge 1:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", keep(match) keepusing(ind_profile)
gen pw = weight*hhsize
svyset ea [pweight=pw], strata(strata)

svy: mean no_items, over(ind_profile)
svy: mean av_cons_q, over(ind_profile)

save "${gsdData}/1-CleanTemp/food_cons.dta", replace

use "${gsdData}/1-CleanInput/SHFS2016/food.dta", clear
* count number of core items consumed per household
*keep if mod_item==0
gen x = cons_q>0 & cons_q<.
collapse (sum) no_items = x (mean) av_cons_q = cons_q_kg, by(strata ea block hh weight hhsize)
replace no_items = no_items/hhsize
la var no_items "Items consumed p.c."
replace av_cons_q = av_cons_q / hhsize
la var av_cons_q "Average quantity per capita"

merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", keep(match) keepusing(ind_profile)
gen pw = weight*hhsize
svyset ea [pweight=pw], strata(strata)

svy: mean no_items, over(ind_profile)
svy: mean av_cons_q, over(ind_profile)

append using "${gsdData}/1-CleanTemp/food_cons.dta", gen(t)

svy: mean no_items, over(ind_profile t)
svy: mean av_cons_q, over(ind_profile t)
