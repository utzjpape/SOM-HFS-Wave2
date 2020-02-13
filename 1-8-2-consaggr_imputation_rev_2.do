*Impute complete consumption

set more off
set seed 23081985 
set sortseed 11041985

********************************************************************
*Define the number of imputations
********************************************************************
local n = 100

********************************************************************
*Prepare household dataset
********************************************************************
use "${gsdData}/1-CleanTemp/hh.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_fcons_all.dta", keepusing(cons*) nogen assert(match) keep(match)
rename cons_f* cons_all_f*
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_fcons.dta", keepusing(cons*) nogen assert(match) keep(match)
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_nfcons_all.dta", keepusing(cons*) nogen assert(match) keep(match)
rename cons_nf* cons_all_nf*
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_nfcons.dta", keepusing(cons*) nogen assert(match) keep(match)
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_durables_all.dta", keepusing(cons_d) nogen assert(match)
rename cons_d cons_all_d
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_durables.dta", keepusing(cons_d) nogen assert(match)
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhm-hh.dta", keepusing(pchild psenior hhsex hhempl hhedu hhh_literacy) nogen assert(match)

*Ensure core food consumption
assert cons_f0 > 0 | missing(cons_f0) 
foreach v of var cons_f1 cons_f2 cons_f3 cons_f4 cons_nf? cons_d {
	replace `v' = .c if cons_f0 == 0
}

*Require positive food core consumption (otherwise, we assume data is missing)
drop if missing(cons_f0) & !inlist(ind_profile,9,4)

*Prepare model variables
replace hhempl = 0 if missing(hhempl)
replace hhsex = 1 if missing(hhsex)
replace hhedu = 0 if missing(hhedu)

*Replace education for literacy for the household head 
drop hhedu 
rename hhh_literacy hhedu

*Clean variables for model
recode housingtype (1/2=1 "Apartament") (3/4=2 "House") (5/6=3 "Hut") (7/max=4 "Other") (missing=4), gen(hh_type) label(lhh_type)
recode drink_water (1/3=1 "Piped") (4=2 "Tap") (5/9=3 "Tap or well") (10/max=4 "Delivered") (missing=4), gen(hh_drinkwater) label(lhh_drinkwater)
recode floor_material (1/2=1 "Solid") (3=2 "Mud") (4/max=3 "Wood/other") (missing=3), gen(hh_floor) label(lhh_floor)
recode tenure (1=1 "Rent") (2=2 "Own") (3/5=3 "Provided") (6/max=4 "Occupation") (missing=4), gen(hh_ownership) label(lhh_ownership)
recode hunger (1=0 "Never") (2=1 "Rarely") (3/max=2 "Often") (missing=2), gen(hh_hunger) label(lhh_hunger)
recode remit12m (missing=0)

*Prepare smaller dataset
rename (mod_opt type) (opt_mod hh_ptype)
keep ind_profile region astrata strata ea block hh hhsize weight opt_mod pchild psenior hhempl hhsex hhedu hh_type hh_drinkwater hh_floor hh_ownership hh_hunger remit12m cons_f? cons_nf? cons_d hh_ptype migr_disp cons_all_*
drop if weight>=.

*Prepare consumption variables
*Make sure missing modules have missing consumption
forvalues i = 1/4 {
	replace cons_f`i' = . if opt_mod!=`i'
	replace cons_nf`i' = . if opt_mod!=`i'
}

*Adjust to per capita per day 
forvalues i = 0/4 {
	replace cons_f`i' = cons_f`i' / hhsize / 7
	replace cons_nf`i' = cons_nf`i' / hhsize / 7
	label var cons_f`i' "Collected food consumption mod `i' pc pd curr USD"
	label var cons_nf`i' "Collected non-food consumption mod `i' pc pd curr USD"
	gen mi_cons_f`i' = cons_f`i' if !inlist(ind_profile,4,9)
	gen mi_cons_nf`i' = cons_nf`i' if !inlist(ind_profile,4,9)
	label var mi_cons_f`i' "Imputed food consumption mod `i' pc pd curr USD"
	label var mi_cons_nf`i' "Imputed non-food consumption mod `i' pc pd curr USD"
}
replace cons_d = cons_d / hhsize / 7
gen mi_cons_d = cons_d if !inlist(ind_profile,4,9)
label var cons_d "Consumption flow of durables pc pd curr USD"
label var mi_cons_d "Imputed consumption flow of durables pc pd curr USD"

*Create some aggregates
egen cons_f =  rowtotal(mi_cons_f?)
egen cons_nf =  rowtotal(mi_cons_nf?)
label var cons_f "Collected food consumption pc pd curr USD"
label var cons_nf "Collected non-food consumption pc pd curr USD"
xtile pmi_cons_f0 = mi_cons_f0 [pweight=weight], nquantiles(4)
xtile pmi_cons_nf0 = mi_cons_nf0 [pweight=weight], nquantiles(4)
xtile pmi_cons_d = mi_cons_d [pweight=weight], nquantiles(4)
foreach k of numlist 4 9 {
	xtile pmi_cons_f0_ex`k' = cons_all_f0 [pweight=weight] if inlist(ind_profile,`k'), nquantiles(4)
	xtile pmi_cons_nf0_ex`k' = cons_all_nf0 [pweight=weight] if inlist(ind_profile,`k'), nquantiles(4)
	xtile pmi_cons_d_ex`k' = cons_all_d [pweight=weight] if inlist(ind_profile,`k'), nquantiles(4)
	foreach v in pmi_cons_nf0 pmi_cons_f0 pmi_cons_d {
		replace `v' = `v'_ex`k' if mi(`v')
	}
}
drop cons_all_*
* Create regional-by-population type disaggregation 
recode ind_profile (4=2) (9=11), gen(ind_profile_impute)
gen rural = hh_ptype==2

********************************************************************
*Build the model and run the imputation
********************************************************************
*Log and regularize for zero consumption
foreach var of varlist mi_cons_f1 mi_cons_f2 mi_cons_f3 mi_cons_f4 mi_cons_nf1 mi_cons_nf2 mi_cons_nf3 mi_cons_nf4 mi_cons_f0 mi_cons_nf0 mi_cons_d {

	*Remember 0 consumption
	gen `var'_0 = `var'==0 if !missing(`var') & !inlist(ind_profile,4,9)

	replace `var' = .01 if `var'<=0
	replace `var' = log(`var')
}

* Change aggregation 
local model = "hhsize pchild psenior i.hhsex i.hhempl hhedu i.hh_type i.hh_drinkwater i.hh_floor i.hh_ownership i.ind_profile_impute rural i.hh_hunger i.remit12m"
local model = "i.pmi_cons_f0 i.pmi_cons_nf0 i.pmi_cons_d `model'"
save "${gsdData}/1-CleanTemp/mi-pre_rev_2.dta", replace

*Run imputation
use "${gsdData}/1-CleanTemp/mi-pre_rev_2.dta", clear
xtset, clear
mi set wide
mi register imputed mi_cons_f1 mi_cons_f2 mi_cons_f3 mi_cons_f4 mi_cons_nf1 mi_cons_nf2 mi_cons_nf3 mi_cons_nf4 mi_cons_f0 mi_cons_nf0 mi_cons_d
mi register regular hh* 

*Multi-variate normal imputation using MCMC 
set seed 23081985 
mi impute mvn mi_cons_f1 mi_cons_f2 mi_cons_f3 mi_cons_f4 mi_cons_nf1 mi_cons_nf2 mi_cons_nf3 mi_cons_nf4 mi_cons_f0 mi_cons_nf0 mi_cons_d  = `model',  add(`n') burnin(1000)
save "${gsdTemp}/mi_rev_2.dta", replace


********************************************************************
*Include the poverty line and obtain the poverty status
********************************************************************
use "${gsdTemp}/mi_rev_2.dta", clear

*Transform into household-level dataset and out of log-space
foreach var of varlist mi_cons_f1 mi_cons_f2 mi_cons_f3 mi_cons_f4 mi_cons_nf1 mi_cons_nf2 mi_cons_nf3 mi_cons_nf4 mi_cons_f0 mi_cons_nf0 mi_cons_d {
	mi xeq: replace `var' = exp(`var')	
	mi xeq: replace `var' = 0 if `var'_0==1 
	drop `var'_0
}

*Include deflator 
merge m:1 astrata using "${gsdData}/1-CleanTemp/food-deflator.dta", nogen assert(match) keep(match)
gen hhweight = weight * hhsize

*Create aggregates
mi passive: egen mi_cons_f = rowtotal(mi_cons_f?)
mi passive: egen mi_cons_nf = rowtotal(mi_cons_nf?)
label var mi_cons_f "Imputed food consumption pc pd curr USD"
label var mi_cons_nf "Imputed non-food consumption pc pd curr USD"

gen tc_core = (cons_f0 + cons_nf0)/deflator + cons_d
egen pre_tc_summ =rowtotal(cons_f0 cons_f1 cons_f2 cons_f3 cons_f4 cons_nf0 cons_nf1 cons_nf2 cons_nf3 cons_nf4) 
gen tc_summ=pre_tc_summ / deflator + cons_d
mi passive: gen tc_imp = (mi_cons_f + mi_cons_nf) / deflator + mi_cons_d

*Add exchange rate
gen team=1 
merge m:1 team using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(global_er) assert(match using) keep(match)
merge m:1 team using "${gsdData}/1-CleanTemp/inflation.dta", nogen keepusing(gg) assert(match using) keep(match)

*SPVA Poverty line (inflation from Dec 2017)
gen plinePPP = 10731 * gg * 1.9 / global_er
label var plinePPP "2011 PPP 1.90 USD Poverty Line in 2017 USD Somalia (inflation from Dec 2017)"
drop gg

*Rev Poverty line (inflation from weighted average Dec 2017-Feb 2018)
merge m:1 team using "${gsdData}/1-CleanTemp/inflation_rev.dta", nogen keepusing(gg) assert(match using) keep(match)
gen plinePPP_rev = 10731 * gg * 1.9 / global_er
label var plinePPP_rev "2011 PPP 1.90 USD Poverty Line in 2017 USD Somalia (inflation from Dec 17 - Feb 18)"
drop team gg global_er 

*Calculate poverty
mi passive: gen poorPPP = tc_imp < plinePPP if !missing(tc_imp)
label var poorPPP "Below 2011 PPP poverty line"

mi passive: gen poorPPP_rev = tc_imp < plinePPP_rev if !missing(tc_imp)
label var poorPPP "Below 2011 PPP poverty line (Rev Pline)"
label define lpoorPPP 0 "Non-poor" 1 "Poor", replace
label values poorPPP lpoorPPP

gen pgi= .
mi register passive pgi
mi passive: replace pgi = max(plinePPP - tc_imp,0) / plinePPP
label var pgi "Poverty gap"
gen pgi_rev= .
mi register passive pgi_rev
mi passive: replace pgi_rev = max(plinePPP_rev - tc_imp,0) / plinePPP_rev
label var pgi_rev "Poverty gap"

*Estimate poverty figures 
mi svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
mi xtset, clear
mi estimate: mean poorPPP [pweight=hhweight]
mi estimate: mean poorPPP_rev [pweight=hhweight]
save "${gsdData}/1-CleanTemp/mi-analysis_rev_2.dta", replace


********************************************************************
*Extract the 100 imputations
********************************************************************
use "${gsdData}/1-CleanTemp/mi-analysis_rev_2.dta", clear
forvalues i = 1/`n' {
	use "${gsdData}/1-CleanTemp/mi-analysis_rev_2.dta", clear
	mi extract `i', clear	
	gen mi = `i'
	save "${gsdTemp}/mi_`i'_rev_2.dta", replace
}
*append
clear
forvalues i = 1/`n' {
	append using "${gsdTemp}/mi_`i'_rev_2.dta"
}
save "${gsdTemp}/mi-extract_rev_2.dta", replace


*Analysis on extract dataset
use "${gsdTemp}/mi-extract_rev_2.dta", clear
collapse (mean) tc_* mi_cons_* (mean) poorPPP_prob = poorPPP poorPPP_rev_prob = poorPPP_rev pgi pgi_rev, by(strata ea block hh hhsize weight hhweight plinePPP plinePPP_rev deflator)

merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) keepusing(ind_profile type) nogen
drop if !inlist(ind_profile,4,9)

gen severity=pgi*pgi
gen severity_rev=pgi_rev*pgi_rev
keep strata ea block hh type weight hhsize deflator hhweight plinePPP plinePPP_rev tc_imp poorPPP_prob poorPPP_rev_prob pgi pgi_rev ind_profile severity severity_rev

append using "${gsdData}/1-CleanTemp/hhq-poverty_rev_1.dta"

svyset ea [pweight=hhweight], strata(strata) singleunit(centered)

*FGT from SPVA
svy: mean poorPPP_prob 
svy: mean poorPPP_prob, over(type) 
svy: mean poorPPP_prob, over(ind_profile) 

svy: mean pgi 
svy: mean pgi, over(type) 
svy: mean pgi, over(ind_profile) 

svy: mean severity 
svy: mean severity, over(type) 
svy: mean severity, over(ind_profile) 


*FGT from revised pline
svy: mean poorPPP_rev_prob 
svy: mean poorPPP_rev_prob, over(type) 
svy: mean poorPPP_rev_prob, over(ind_profile) 

svy: mean pgi_rev 
svy: mean pgi_rev, over(type) 
svy: mean pgi_rev, over(ind_profile) 

svy: mean severity_rev 
svy: mean severity_rev, over(type) 
svy: mean severity_rev, over(ind_profile) 

save "${gsdData}/1-CleanTemp/hhq-poverty_rev.dta", replace

