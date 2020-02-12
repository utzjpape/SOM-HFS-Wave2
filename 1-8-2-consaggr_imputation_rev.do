*Impute complete consumption

set more off
set seed 23081985 
set sortseed 11041985


********************************************************************
*Set parameters
********************************************************************
*Number of imputations 
local nmi = 100

*Mata helper functions
cap mata mata drop vselect_best()
mata :
void vselect_best(string scalar m,string scalar ret) 
{
    X = st_matrix(m)
	k = .
	x = .
    for(i=1; i<=rows(X); i++){
        x = min((x,X[i,2]))
		if (x==X[i,2]) {
			k = X[i,1]
		}
    }
	st_local(ret,strofreal(k))
}
end



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

*Create regional-by-population type disaggregation 
recode ind_profile (4=2) (9=11), gen(ind_profile_impute)
gen rural = hh_ptype==2

*Rename variables in line with the new RCM 
renpfix mi_cons_f xfcons 
renpfix mi_cons_nf xnfcons 
rename cons_d xdcons
drop mi_cons_*

foreach var of varlist pchild psenior {
	rename `var' mcon_`var'
}
foreach var of varlist hhsex hhempl hh_type hhedu hh_drinkwater hh_floor hh_ownership hh_hunger remit12m  {
	rename `var' mcat_`var'
}  

*Create quartiles for consumption
foreach v of var cons_all_f0 cons_all_nf0 cons_all_d {
	xtile p`v' = `v' [pweight=weight] , n(4)
	label var p`v' "Quartiles for `: var label `v''"
}
ren (pcons_all_f0 pcons_all_nf0 pcons_all_d) (pxfcons0 pxnfcons0 pxdcons)



*************************************************************
* Find best model in log space of all collected consumption *
*************************************************************
*Calculate all collected consumption in log space
egen tcons = rowtotal(xfcons* xnfcons* xdcons)
gen ltcons = log(tcons)
replace ltcons = log(.01) if missing(ltcons)

*Prepare variable lists
unab mcon : mcon_*
fvunab mcat : i.mcat_*

*Estimate and select best model
xi: vselect ltcons hhsize rural `mcon' `mcat' [pweight=weight], best fix(i.opt_mod i.ind_profile_impute)
matrix A = r(info)
matrix B = A[1...,colnumb("A","k")],A[1...,colnumb("A","AICC")]
mata vselect_best("B","k")
local model = "`r(best`k')'"

*Output regression
reg ltcons `model' i.opt_mod [pweight=weight]

*Add quartiles from core consumption to model
local model = "`model' i.pxfcons0 i.pxnfcons0 i.pxdcons"
drop tcons ltcons
drop region cons_all_* cons_f0 cons_f1 cons_f2 cons_f3 cons_f4 cons_nf0 cons_nf1 cons_nf2 cons_nf3 cons_nf4 cons_all_d
save "${gsdTemp}/`fh'.dta", replace


*****************************************************************
* Prepare dataset for estimation with two-step log estimation   *
*****************************************************************
use "${gsdTemp}/`fh'.dta", clear
ren (xfcons0 xnfcons0) (fcore nfcore)
ren (xfcons? xnfcons?) (y1? y0?)
qui reshape long y0 y1, i(strata ea block hh) j(imod)
qui reshape long y, i(strata ea block hh imod) j(food)

*Remember 0 consumption
gen y_0 = y==0 if !missing(y)

*Log and regularize for zero consumption
replace y = .01 if y<=0
replace y = log(y)

*Conditional step in estimation skipped if almost all hh have module consumption >0
bysort food imod: egen ny_0 = mean(y_0)
replace y_0 = 0 if ny_0 < 0.01
drop ny_0


****************************************************************************
* Run estimation with two-step log estimation with multiple imputations    *
****************************************************************************
mi set wide
mi register imputed y y_0 xdcons
mi register regular imod food
mi register regular hh* strata ea block rural ind_profile_impute mcon* _I* pxfcons0 pxnfcons0 pxdcons
mi impute chained (logit, augment) y_0 (reg, cond(if y_0==0)) y = `model', add(`nmi') by(imod food) 

*Transform into household-level dataset and out of log-space
keep astrata strata ea block hh rural ind_profile ind_profile_impute hhsize weight y y_0 _* imod food fcore nfcore xdcons
mi xeq: replace y = exp(y)

*Reshape back to the hh-level
mi xeq: replace y = 0 if y_0==1
drop y_0
mi reshape wide y, i(strata ea block hh imod) j(food)
mi rename y0 xnfcons
mi rename y1 xfcons
mi reshape wide xfcons xnfcons xdcons, i(strata ea block hh) j(imod)
mi ren fcore xfcons0
mi ren nfcore xnfcons0 
save "${gsdTemp}/mi_est.dta", replace


********************************************************************
*Include the poverty line and obtain the poverty status
********************************************************************
use "${gsdTemp}/mi_est.dta", clear

*Include deflator 
merge m:1 astrata using "${gsdData}/1-CleanTemp/food-deflator.dta", nogen assert(match) keep(match)
gen hhweight = weight * hhsize

*Create aggregates
mi passive: egen mi_cons_f =rowtotal(xfcons0 xfcons1 xfcons2 xfcons3 xfcons4) 
mi passive: egen mi_cons_nf = rowtotal(xnfcons0 xnfcons1 xnfcons2 xnfcons3 xnfcons4)
label var mi_cons_f "Imputed food consumption pc pd curr USD"
label var mi_cons_nf "Imputed non-food consumption pc pd curr USD"

mi passive: egen mi_cons_d=rowtotal(xdcons1)

mi passive: egen pre_tc_core = rowtotal(xfcons0 xnfcons0)
mi passive: gen tc_core = (pre_tc_core )/deflator + mi_cons_d

egen pre_tc_summ =rowtotal(xfcons0 xnfcons0 xnfcons1 xfcons1 xnfcons2 xfcons2 xnfcons3 xfcons3 xnfcons4 xfcons4) 
mi passive: gen tc_summ = (pre_tc_summ )/deflator + mi_cons_d

mi passive: gen tc_imp = (mi_cons_f + mi_cons_nf) / deflator + mi_cons_d
label var tc_core "Total real Dec 2017 consumption based on core pc pd curr USD"
label var tc_summ "Total real Dec 2017 consumption based on summing pc pd curr USD"
label var tc_imp "Total real Dec 2017 consumption based on imputation pc pd curr USD"

mi register imputed mi_cons_f  mi_cons_nf  tc_imp 
mi update

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

*Shortcut to avoid mi collapse
egen poorPPP_i = rowmean(_*_poorPPP)
egen poorPPP_rev_i = rowmean(_*_poorPPP_rev)

*Estimate poverty figures 
mi svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
mi xtset, clear
mi estimate: mean poorPPP [pweight=hhweight]
mi estimate: mean poorPPP_rev [pweight=hhweight]
save "${gsdData}/1-CleanTemp/mi-analysis_rev.dta", replace


************************************
* Extract imputations              *
************************************

*Extract the N imputations
use "${gsdData}/1-CleanTemp/mi-analysis_rev.dta", clear
forvalues i = 1/`nmi' {
	use "${gsdData}/1-CleanTemp/mi-analysis_rev.dta", clear
	mi extract `i', clear	
	gen mi = `i'
	save "${gsdTemp}/mi_`i'_rev.dta", replace
}
*append
clear
forvalues i = 1/`nmi' {
	append using "${gsdTemp}/mi_`i'_rev.dta"
}
save "${gsdTemp}/mi-extract_rev.dta", replace


*Analysis on extract dataset
use "${gsdTemp}/mi-extract_rev.dta", clear
collapse (mean) tc_* mi_cons_* (mean) poorPPP_prob = poorPPP poorPPP_rev_prob = poorPPP_rev pgi pgi_rev, by(strata ea block hh hhsize weight hhweight plinePPP plinePPP_rev deflator)
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) keepusing(ind_profile type) nogen
gen severity=pgi*pgi
gen severity_rev=pgi_rev*pgi_rev
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

