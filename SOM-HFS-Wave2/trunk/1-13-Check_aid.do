* Task: look at aid inflow in wave 2 and in wave 1
* Specification 1: percentage of HHs with at least some free food
* Wave 2
use "${gsdData}/1-CleanInput/food.dta", clear
keep if mod_item==0
replace free=0 if mi(free)
collapse (max) free (sum) sfree=free, by(strata ea block hh)
replace sfree = sfree/38
save "${gsdTemp}/hh_food_free_bin.dta", replace
* Wave 1
use "${gsdData}/1-CleanInput/SHFS2016/food.dta", clear
keep if mod_item==0
replace free=0 if mi(free)
collapse (max) free (sum) sfree=free, by(strata ea block hh)
replace sfree = sfree/38
append using "${gsdTemp}/hh_food_free_bin.dta", gen(t)
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
save "${gsdTemp}/hh_food_free_bin-w1w2.dta", replace
* start analysis 
use "${gsdData}/1-CleanTemp/hh_all.dta", clear
merge 1:1 t strata ea block hh using "${gsdTemp}/hh_food_free_bin-w1w2.dta", assert(master match) nogen
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
egen ind_t = group(ind_profile t), label
svy: mean sfree, over(ind_t)
preserve
keep if t==1
tabout ind_profile using "${gsdOutput}/Aid-Food_raw1_1.xls", svy sum c(mean free lb ub) sebnone f(3) h1("Households receiving free food, w2") npos(col) replace ptotal(none)
restore
preserve
keep if t==0
tabout ind_profile using "${gsdOutput}/Aid-Food_raw1_2.xls", svy sum c(mean free lb ub) sebnone f(3) h1("Households receiving free food, w2") npos(col) replace ptotal(none)
restore
* prepare significance tests output
putexcel set "${gsdOutput}/Aid-Food_raw1_3.xls", modify
drop if ind_profile>6
levelsof ind_profile, local(ind)
local k=1
foreach i in `ind' {
	preserve
	keep if ind_profile==`i'
	mean free, over(ind_t)
	test _subpop_1 = _subpop_2
	putexcel A`k' ="Group`i'"
	putexcel B`k' =`r(p)'
	local k=`k'+1
	restore
}

insheet using "${gsdOutput}/Aid-Food_raw1_1.xls", clear nonames tab
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Aid-Food_raw1") sheetreplace firstrow(variables)
insheet using "${gsdOutput}/Aid-Food_raw1_2.xls", clear nonames tab
replace v2=v1 if v2==""
drop v1
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Aid-Food_raw1") sheetmodify cell(F1) firstrow(variables)
import excel using "${gsdOutput}/Aid-Food_raw1_3.xls", clear 
ren B p_value
drop A
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Aid-Food_raw1") sheetmodify cell(J2) firstrow(variables)

* Check relation between aid and poverty in PLD
use "${gsdData}/1-CleanTemp/hh_all.dta", clear
merge 1:1 t strata ea block hh using "${gsdTemp}/hh_food_free_bin-w1w2.dta", assert(master match) nogen
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty_all.dta", nogen assert(match master) keepusing(tc_core)

gen pw = weight_cons*hhsize
svyset ea [pweight=pw], strata(strata) singleunit(centered)
svy: reg tc_core t free if inlist(ind_profile, 2, 4) & type==1
outreg2 using "${gsdOutput}/Aid-Food_raw2.xls", replace ctitle("tc_core with aid, NE urban") label excel keep(t free) nocons
svy: reg tc_core t  if inlist(ind_profile, 2, 4) & type==1
outreg2 using "${gsdOutput}/Aid-Food_raw2.xls", append ctitle("tc_core without aid, NE urban") label excel keep(t) nocons
svy: reg tc_core t free if inlist(ind_profile, 2, 4) & type==2
outreg2 using "${gsdOutput}/Aid-Food_raw2.xls", append ctitle("tc_core with aid, NE rural") label excel keep(t free) nocons
svy: reg tc_core t  if inlist(ind_profile, 2, 4) & type==2
outreg2 using "${gsdOutput}/Aid-Food_raw2.xls", append ctitle("tc_core without aid, NE rural") label excel keep(t free) nocons
import delim using "${gsdOutput}/Aid-Food_raw2.txt", clear 
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("Aid-Food_raw2") sheetreplace firstrow(variables)


***********************************************************************************
* Specification 3: approximation of value of free food
* wave 2 -> not possible in Wave 1
use "${gsdData}/1-CleanInput/food.dta", clear
keep if mod_item==0
keep if free==1
keep strata ea block hh foodid free free_q
ren foodid itemid 
merge 1:1 strata ea block hh itemid using "${gsdData}/1-CleanOutput/food.dta", assert(match using) nogen
recode free_q (1=.25) (2=.5) (3=.75) (4=1) (missing=0)
gen cons_usd_free = cons_usd_org*free_q 
collapse (sum) cons_usd_org cons_usd_free, by(strata ea block hh)
gen prop_free = cons_usd_free / cons_usd_org 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", assert(match) nogen
gen pweight = weight*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
svy: mean prop_free, over(type)
svy: mean prop_free, over(ind_profile)

* Look into own production --> Wave 2 only
use "${gsdData}/1-CleanInput/food.dta", clear
keep if mod_item==0
keep if ownprod==1
keep strata ea block hh foodid ownprod
ren foodid itemid 
merge 1:1 strata ea block hh itemid using "${gsdData}/1-CleanOutput/food.dta", assert(match using) nogen
recode ownprod (missing=0)
gen cons_usd_own = cons_usd_org*ownprod 
collapse (sum) cons_usd_org cons_usd_own, by(strata ea block hh)
gen prop_own = cons_usd_own / cons_usd_org 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", assert(match) nogen
gen pweight = weight*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
svy: mean prop_own, over(type)
svy: mean prop_own, over(ind_profile)

