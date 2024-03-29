* Compare Wave 1 vs. Wave 2

set more off
set seed 23081980 
set sortseed 11041955


*=====================================================================
* POVERTY EXCLUDING DURABLES W2
*=====================================================================
local n = 100

*Scale to per day and per capita and create sub-aggregates
use "${gsdTemp}/mi.dta", clear
*prepare variables to merge
merge m:1 astrata using "${gsdData}/1-CleanTemp/food-deflator.dta", nogen assert(match) keep(match)
gen hhweight = weight * hhsize
*iterate over modules
foreach cat in f nf {
	forvalues i=1/4 {
		*need to take floor to make sure rounding does not result in negative averages
		egen double xtag`cat'`i' = rowtotal(_*_mi_cons_`cat'`i')
		forvalues j=1/`n' {
			*scale up to get average being zero (without losing the variance)
			replace _`j'_mi_cons_`cat'`i' = _`j'_mi_cons_`cat'`i' - floor(xtag`cat'`i' /`n'*10^5)/10^5 if xtag`cat'`i'<0
		}
	}
}
drop xtag*
mi passive: egen mi_cons_f = rowtotal(mi_cons_f?)
mi passive: egen mi_cons_nf = rowtotal(mi_cons_nf?)
label var mi_cons_f "Imputed food consumption pc pd curr USD"
label var mi_cons_nf "Imputed non-food consumption pc pd curr USD"
*Exclude durables
gen tc_core = (cons_f0 + cons_nf0)/deflator 
egen pre_tc_summ =rowtotal(cons_f0 cons_f1 cons_f2 cons_f3 cons_f4 cons_nf0 cons_nf1 cons_nf2 cons_nf3 cons_nf4) 
gen tc_summ=pre_tc_summ / deflator 
mi passive: gen tc_imp = (mi_cons_f + mi_cons_nf) / deflator 
label var tc_core "Total real Dec 2017 consumption based on core pc pd curr USD"
label var tc_summ "Total real Dec 2017 consumption based on summing pc pd curr USD"
label var tc_imp "Total real Dec 2017 consumption based on imputation pc pd curr USD"


*Include the poverty line and obtain the poverty status
*Add exchange rate
gen team=1 
merge m:1 team using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(global_er) assert(match using) keep(match)
merge m:1 team using "${gsdData}/1-CleanTemp/inflation.dta", nogen keepusing(gg) assert(match using) keep(match)
drop team
*Poverty line 1.90 USD in USD PPP (2011) using private consumption PPP conversion factor
*in 2011: 1 PPP USD was worth 10,731 SSh PPP
*Inflation from 2011 to Dec 2017: 1.684297
*10,731 * 1.684297 = 18,074.19 SSh (2016) could buy 1 PPP 2011 USD
*1.90 PPP 2011 USD = 18,074.19 * 1.90 = 34,340.96 SSh (2017)
*In current (2017) USD: 34,340.96 / global_er
gen plinePPP = 10731 * gg * 1.9 / global_er
label var plinePPP "2011 PPP 1.90 USD Poverty Line in 2017 USD Somalia"
gen scale_id=1

*Rescale using the share of durables relative to total consumption (Wave 1)
preserve 
use "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", clear
sum tc_imp [weight=hhweight]
gen tc_imp_mean=r(mean)
sum mi_cons_d [weight=hhweight]
gen mi_cons_d_mean=r(mean)
gen scale_factor=1 - (mi_cons_d_mean/tc_imp_mean)
gen scale_id=1
keep scale_id scale_factor
duplicates drop
save "${gsdTemp}/scale_factor_w1_assets.dta", replace
restore
merge m:1 scale_id using "${gsdTemp}/scale_factor_w1_assets.dta", assert(match) nogen 
drop scale_id
replace plinePPP=plinePPP*scale_factor

*Calculate poverty
mi passive: gen poorPPP = tc_imp < plinePPP if !missing(tc_imp)
mi svyset ea [pweight=hhweight], strata(strata)
label var poorPPP "Below 2011 PPP poverty line"
label define lpoorPPP 0 "Non-poor" 1 "Poor", replace
label values poorPPP lpoorPPP
drop global_er gg
*Estimate poverty figures 
mi xtset, clear
mi svyset ea [pweight=hhweight], strata(strata)
mi estimate: mean poorPPP [pweight=hhweight]
merge 1:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen assert(match) keepusing(ind_profile)
mi estimate: mean poorPPP [pweight=hhweight], over(ind_profile)
save "${gsdTemp}/mi-analysis_w2_case1.dta", replace


*=====================================================================
* POVERTY IN W2 INCLUDING +1 AND +2 HOUSEHOLD MEMBERS
*=====================================================================
local n = 100

*Loop over +1 AND + 2 HHM
forval z=1/2 {
	 
	*Prepare household dataset
	use "${gsdData}/1-CleanTemp/hh.dta", clear
	merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_fcons.dta", keepusing(cons*) nogen assert(match) keep(match)
	merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_nfcons.dta", keepusing(cons*) nogen assert(match) keep(match)
	merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_durables.dta", keepusing(cons_d) nogen assert(match)
	merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhm-hh.dta", keepusing(pchild psenior hhsex hhempl hhedu hhh_literacy) nogen assert(match)
	*Ensure core food consumption
	assert cons_f0 > 0 | missing(cons_f0) 
	foreach v of var cons_f1 cons_f2 cons_f3 cons_f4 cons_nf? cons_d {
		replace `v' = .c if cons_f0 == 0
	}
	*Require positive food core consumption (otherwise, we assume data is missing)
	drop if missing(cons_f0)
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
	recode type (4=1)
	recode remit12m (missing=0)
	*Prepare smaller dataset
	rename (mod_opt type) (opt_mod hh_ptype)
	keep region astrata strata ea block hh hhsize weight opt_mod pchild psenior hhempl hhsex hhedu hh_type hh_drinkwater hh_floor hh_ownership hh_hunger remit12m cons_f? cons_nf? cons_d hh_ptype
	drop if weight>=.

	*Include additional household size 
	replace hhsize=hhsize+`z'

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
		gen mi_cons_f`i' = cons_f`i'
		gen mi_cons_nf`i' = cons_nf`i'
		label var mi_cons_f`i' "Imputed food consumption mod `i' pc pd curr USD"
		label var mi_cons_nf`i' "Imputed non-food consumption mod `i' pc pd curr USD"
	}
	replace cons_d = cons_d / hhsize / 7
	gen mi_cons_d = cons_d
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


	********************************************************************
	*Build the model and run the imputation
	********************************************************************
	local model = "hhsize pchild psenior i.hhsex i.hhempl hhedu i.hh_type i.hh_drinkwater i.hh_floor i.hh_ownership i.hh_hunger i.region i.hh_ptype i.remit12m"
	local model = "i.pmi_cons_f0 i.pmi_cons_nf0 i.pmi_cons_d `model'"
	*Create core consumption for comparison
	save "${gsdTemp}/mi-pre_w2_case2_`z'.dta", replace
	*Run imputation
	use "${gsdTemp}/mi-pre_w2_case2_`z'.dta", clear
	xtset, clear
	mi set wide
	mi register imputed mi_cons_f1 mi_cons_f2 mi_cons_f3 mi_cons_f4 mi_cons_nf1 mi_cons_nf2 mi_cons_nf3 mi_cons_nf4
	mi register regular hh* mi_cons_f0 mi_cons_nf0 mi_cons_d
	*Multi-variate normal imputation using MCMC 
	set seed 23081985 
	mi impute mvn mi_cons_f1 mi_cons_f2 mi_cons_f3 mi_cons_f4 mi_cons_nf1 mi_cons_nf2 mi_cons_nf3 mi_cons_nf4 = `model', add(`n') burnin(1000)
	save "${gsdTemp}/mi_w2_case2_`z'.dta", replace


	********************************************************************
	*Scale to per day and per capita and create sub-aggregates
	********************************************************************
	use "${gsdTemp}/mi_w2_case2_`z'.dta", clear
	*prepare variables to merge
	merge m:1 astrata using "${gsdData}/1-CleanTemp/food-deflator.dta", nogen assert(match) keep(match)
	gen hhweight = weight * hhsize
	*iterate over modules
	foreach cat in f nf {
		forvalues i=1/4 {
			*need to take floor to make sure rounding does not result in negative averages
			egen double xtag`cat'`i' = rowtotal(_*_mi_cons_`cat'`i')
			forvalues j=1/`n' {
				*scale up to get average being zero (without losing the variance)
				replace _`j'_mi_cons_`cat'`i' = _`j'_mi_cons_`cat'`i' - floor(xtag`cat'`i' /`n'*10^5)/10^5 if xtag`cat'`i'<0
			}
		}
	}
	drop xtag*
	mi passive: egen mi_cons_f = rowtotal(mi_cons_f?)
	mi passive: egen mi_cons_nf = rowtotal(mi_cons_nf?)
	label var mi_cons_f "Imputed food consumption pc pd curr USD"
	label var mi_cons_nf "Imputed non-food consumption pc pd curr USD"
	gen tc_core = (cons_f0 + cons_nf0)/deflator + cons_d
	egen pre_tc_summ =rowtotal(cons_f0 cons_f1 cons_f2 cons_f3 cons_f4 cons_nf0 cons_nf1 cons_nf2 cons_nf3 cons_nf4) 
	gen tc_summ=pre_tc_summ / deflator + cons_d
	mi passive: gen tc_imp = (mi_cons_f + mi_cons_nf) / deflator + mi_cons_d
	label var tc_core "Total real Dec 2017 consumption based on core pc pd curr USD"
	label var tc_summ "Total real Dec 2017 consumption based on summing pc pd curr USD"
	label var tc_imp "Total real Dec 2017 consumption based on imputation pc pd curr USD"


	********************************************************************
	*Include the poverty line and obtain the poverty status
	********************************************************************
	*Add exchange rate
	gen team=1 
	merge m:1 team using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(global_er) assert(match using) keep(match)
	merge m:1 team using "${gsdData}/1-CleanTemp/inflation.dta", nogen keepusing(gg) assert(match using) keep(match)
	drop team
	*Poverty line 1.90 USD in USD PPP (2011) using private consumption PPP conversion factor
	*in 2011: 1 PPP USD was worth 10,731 SSh PPP
	*Inflation from 2011 to Dec 2017: 1.684297
	*10,731 * 1.684297 = 18,074.19 SSh (2016) could buy 1 PPP 2011 USD
	*1.90 PPP 2011 USD = 18,074.19 * 1.90 = 34,340.96 SSh (2017)
	*In current (2017) USD: 34,340.96 / global_er
	gen plinePPP = 10731 * gg * 1.9 / global_er
	gen plinePPP125 = 10731 * gg * 1.25 / global_er
	gen plinePPP_vulnerable_10 =plinePPP*1.1 
	gen plinePPP_vulnerable_20 =plinePPP*1.2
	label var plinePPP "2011 PPP 1.90 USD Poverty Line in 2017 USD Somalia"
	label var plinePPP125 "2011 PPP 1.25 USD Poverty Line in 2017 USD Somalia"
	label var plinePPP_vulnerable_10 "Poverty Line corresponding to shock to consumption equal to (1-1/1.1)"
	label var plinePPP_vulnerable_20 "Poverty Line corresponding to shock to consumption equal to (1-1/1.2)"
	*Calculate poverty
	mi passive: gen poorPPP = tc_imp < plinePPP if !missing(tc_imp)
	mi passive: gen poorPPP125 = tc_imp < plinePPP125 if !missing(tc_imp)
	mi passive: gen poorPPP_vulnerable_10 = tc_imp < plinePPP_vulnerable_10 if !missing(tc_imp)
	mi passive: gen poorPPP_vulnerable_20 = tc_imp < plinePPP_vulnerable_20 if !missing(tc_imp)
	mi svyset ea [pweight=hhweight], strata(strata)
	label var poorPPP "Below 2011 PPP poverty line"
	label define lpoorPPP 0 "Non-poor" 1 "Poor", replace
	label values poorPPP lpoorPPP
	label var poorPPP_vulnerable_10 "Below 2011 PPP poverty line - Vulnerable, consumption shock 10"
	label define lpoorPPP_vulnerable_10 0 "Non-poor" 1 "Poor"
	label values poorPPP_vulnerable_10 lpoorPPPlpoorPPP_vulnerable_10
	label var poorPPP_vulnerable_20 "Below 2011 PPP poverty line - Vulnerable, consumption shock 20"
	label define lpoorPPP_vulnerable_20 0 "Non-poor" 1 "Poor"
	label values poorPPP_vulnerable_20 lpoorPPP_vulnerable_20
	drop global_er gg
	*Estimate poverty figures 
	mi xtset, clear
	mi svyset ea [pweight=hhweight], strata(strata)
	mi estimate: mean poorPPP [pweight=hhweight]
	mi estimate: mean poorPPP125 [pweight=hhweight]
	mi estimate: mean poorPPP_vulnerable_10 [pweight=hhweight]
	mi estimate: mean poorPPP_vulnerable_20 [pweight=hhweight]
	save "${gsdTemp}/mi-analysis_w2_case2_`z'.dta", replace


	********************************************************************
	*Extract the 100 imputations
	********************************************************************
	use "${gsdTemp}/mi-analysis_w2_case2_`z'.dta", clear
	forvalues i = 1/`n' {
		use "${gsdTemp}/mi-analysis_w2_case2_`z'.dta", clear
		mi extract `i', clear	
		gen mi = `i'
		save "${gsdTemp}/mi_`i'_w2_case2_`z'.dta", replace
	}
	*append
	clear
	forvalues i = 1/`n' {
		append using "${gsdTemp}/mi_`i'_w2_case2_`z'.dta"
	}
	save "${gsdTemp}/mi-extract_w2_case2_`z'.dta", replace
	*Analysis on extract dataset
	use "${gsdTemp}/mi-extract_w2_case2_`z'.dta", clear
	fastgini tc_imp [pweight=hhweight]
	collapse (mean) tc_* mi_cons_f? mi_cons_nf? mi_cons_d (mean) poorPPP_prob = poorPPP poorPPP125_prob = poorPPP125 poorPPP_vulnerable_10_prob = poorPPP_vulnerable_10 poorPPP_vulnerable_20_prob = poorPPP_vulnerable_20, by(strata ea block hh hhsize weight hhweight opt_mod plinePPP plinePPP125)
	svyset ea [pweight=hhweight], strata(strata)
	mean poorPPP_prob [pweight=hhweight]
	mean poorPPP_vulnerable_10_prob [pweight=hhweight]
	mean poorPPP_vulnerable_20_prob [pweight=hhweight]
	gen poorPPP = poorPPP_prob > .55
	mean poorPPP [pweight=hhweight]
	label var tc_core "Total real Dec 2017 consumption based on core pc pd curr USD"
	label var tc_summ "Total real Dec 2017 consumption based on summing pc pd curr USD"
	label var tc_imp "Total real Dec 2017 consumption based on imputation pc pd curr USD"
	label var poorPPP_prob "Probability being below 2011 PPP poverty line"
	label var poorPPP125_prob "Probability being below 2011 PPP extreme poverty line"
	label var poorPPP "Being below 2011 PPP poverty line"
	label var poorPPP_vulnerable_10_prob "Probability of being below 2011 PPP poverty line increased by 10%, equivalent to 9.1% shock to consumption"
	label var poorPPP_vulnerable_20_prob "Probability of being below 2011 PPP poverty line increased by 20%, equivalent to 16.7% shock to consumption"
	forvalues i = 0/4 {
		label var mi_cons_f`i' "Food module `i' consumption pc pd curr USD"
		label var mi_cons_nf`i' "Non-Food module `i' consumption pc pd curr USD"
	}
	label var mi_cons_d "Durable consumption pc pd curr USD"
	save "${gsdTemp}/mi-analysis_w2_case2_`z'.dta", replace


}
