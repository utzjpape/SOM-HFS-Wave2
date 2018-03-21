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
*Create ind_profile variable
gen ind_profile=6 if astrata==3
replace ind_profile=5 if astrata==22
replace ind_profile=4 if astrata==21
replace ind_profile=3 if astrata==14 | astrata==15
replace ind_profile=2 if astrata==12 | astrata==13 
replace ind_profile=1 if astrata==11
label define lind_profile 1 "Mogadishu (Urban)" 2 "North-east Urban (Nugaal,Bari,Mudug)" 3 "North-west Urban (Woqooyi G,Awdal,Sanaag,Sool,Togdheer)" 4 "North-east Rural (Bari,Mudug,Nugaal)" 5 "North-west Rural (Awdal,Sanaag,Sool,Togdheer,Woqooyi)" 6 "IDP Settlements"
label values ind_profile lind_profile
label var ind_profile "Indicator: Mogadishu, North-East urban/rural, North-West urban/rural & IDPs"
cap drop if ind_profile==6
levelsof ind_profile, local(ind)
foreach k in `ind' {
	use "${gsdData}/1-CleanTemp/hh.dta", clear
	merge 1:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", keepusing(opt_mod type) nogen assert(match using) keep(match)
	merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_fcons.dta", keepusing(cons*) nogen assert(match using) keep(match)
	merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_nfcons.dta", keepusing(cons*) nogen assert(match using) keep(match)
	merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_durables.dta", keepusing(cons_d) nogen assert(match using) keep(match)
	merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhm-hh.dta", keepusing(pchild psenior hhsex hhempl hhedu hhh_literacy) nogen assert(match using) keep(match)
    *Create ind_profile variable
	gen ind_profile=6 if astrata==3
	replace ind_profile=5 if astrata==22
	replace ind_profile=4 if astrata==21
	replace ind_profile=3 if astrata==14 | astrata==15
	replace ind_profile=2 if astrata==12 | astrata==13 
	replace ind_profile=1 if astrata==11
	label define lind_profile 1 "Mogadishu (Urban)" 2 "North-east Urban (Nugaal,Bari,Mudug)" 3 "North-west Urban (Woqooyi G,Awdal,Sanaag,Sool,Togdheer)" 4 "North-east Rural (Bari,Mudug,Nugaal)" 5 "North-west Rural (Awdal,Sanaag,Sool,Togdheer,Woqooyi)" 6 "IDP Settlements"
	label values ind_profile lind_profile
	label var ind_profile "Indicator: Mogadishu, North-East urban/rural, North-West urban/rural & IDPs"
	cap drop if ind_profile==6
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
	recode house_type (1/2=1 "Apartament") (3/4=2 "House") (5/6=3 "Hut") (7/max=4 "Other") (missing=4), gen(hh_type) label(lhh_type)
	recode drink_water (1/3=1 "Piped") (4=2 "Tap") (5/9=3 "Tap or well") (10/max=4 "Delivered") (missing=4), gen(hh_drinkwater) label(lhh_drinkwater)
	recode floor_material (1/2=1 "Solid") (3=2 "Mud") (4/max=3 "Wood/other") (missing=3), gen(hh_floor) label(lhh_floor)
	recode house_ownership (1=1 "Rent") (2=2 "Own") (3/4=3 "Occupy") (5/max=4 "Other") (missing=4), gen(hh_ownership) label(lhh_ownership)
	recode hunger (1=0 "Never") (2=1 "Rarely") (3/max=2 "Often") (missing=2), gen(hh_hunger) label(lhh_hunger)
	recode remit12m (missing=0)
	*Prepare smaller dataset
	rename (type) (hh_ptype)
	gen region=(ind_profile==2 | ind_profile==4)
	keep region astrata ind_profile strata ea block hh hhsize weight opt_mod pchild psenior hhempl hhsex hhedu hh_type hh_drinkwater hh_floor hh_ownership hh_hunger remit12m cons_f? cons_nf? cons_d hh_ptype
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
		gen mi_cons_f`i' = cons_f`i' if !inlist(ind_profile,`k')
		gen mi_cons_nf`i' = cons_nf`i' if !inlist(ind_profile,`k')
		label var mi_cons_f`i' "Imputed food consumption mod `i' pc pd curr USD"
		label var mi_cons_nf`i'  "Imputed non-food consumption mod `i' pc pd curr USD"
	}
	replace cons_d = cons_d / hhsize / 7
	gen mi_cons_d = cons_d if !inlist(ind_profile,`k')
	label var cons_d "Consumption flow of durables pc pd curr USD"
	label var mi_cons_d "Imputed consumption flow of durables pc pd curr USD"
	*Create some aggregates
	egen cons_f =  rowtotal(mi_cons_f?)
	egen cons_nf =  rowtotal(mi_cons_nf?)
	label var cons_f "Collected food consumption pc pd curr USD"
	label var cons_nf "Collected non-food consumption pc pd curr USD"
	* How to deal with these aggregates? 
	xtile pmi_cons_f0 = mi_cons_f0 [pweight=weight], nquantiles(4)
	xtile pmi_cons_nf0 = mi_cons_nf0 [pweight=weight], nquantiles(4)
	xtile pmi_cons_d = mi_cons_d [pweight=weight], nquantiles(4)
	xtile pmi_cons_f0_ex`k' = cons_f0 [pweight=weight] if inlist(ind_profile,`k'), nquantiles(4)
	xtile pmi_cons_nf0_ex`k' = cons_nf0 [pweight=weight] if inlist(ind_profile,`k'), nquantiles(4)
	xtile pmi_cons_d_ex`k' = cons_d [pweight=weight] if inlist(ind_profile,`k'), nquantiles(4)
	foreach v in pmi_cons_nf0 pmi_cons_f0 pmi_cons_d {
		replace `v' = `v'_ex`k' if mi(`v')
	}
	********************************************************************
	*Build the model and run the imputation
	********************************************************************
	local model = "hhsize pchild psenior i.hhsex i.hhempl hhedu i.hh_type i.hh_drinkwater i.hh_floor i.hh_ownership i.hh_hunger i.region i.hh_ptype i.remit12m"
	local model = "i.pmi_cons_f0 i.pmi_cons_nf0 i.pmi_cons_d `model'"
	*Create core consumption for comparison
	save "${gsdData}/1-CleanTemp/mi-pre_`k'.dta", replace
	*Run imputation
	use "${gsdData}/1-CleanTemp/mi-pre_`k'.dta", clear
	mi set wide
	mi register imputed mi_cons_f1 mi_cons_f2 mi_cons_f3 mi_cons_f4 mi_cons_nf1 mi_cons_nf2 mi_cons_nf3 mi_cons_nf4 mi_cons_f0 mi_cons_nf0 mi_cons_d
	mi register regular hh* 
	*Multi-variate normal imputation using MCMC 
	set seed 23081985 
	mi impute mvn mi_cons_f1 mi_cons_f2 mi_cons_f3 mi_cons_f4 mi_cons_nf1 mi_cons_nf2 mi_cons_nf3 mi_cons_nf4 mi_cons_f0 mi_cons_nf0 mi_cons_d = `model', add(`n') burnin(1000)
	save "${gsdTemp}/mi_`k'.dta", replace


	********************************************************************
	*Scale to per day and per capita and create sub-aggregates
	********************************************************************
	use "${gsdTemp}/mi_`k'.dta", clear
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
	gen zone = 3
	merge m:1 zone using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(global_er) assert(match using) keep(match)
	merge m:1 zone using "${gsdData}/1-CleanTemp/inflation.dta", nogen keepusing(gg) assert(match using) keep(match)
	drop zone
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
	save "${gsdData}/1-CleanTemp/mi-analysis_`k'.dta", replace


	********************************************************************
	*Extract the 100 imputations
	********************************************************************
	use "${gsdData}/1-CleanTemp/mi-analysis_`k'.dta", clear
	forvalues i = 1/`n' {
		use "${gsdData}/1-CleanTemp/mi-analysis_`k'.dta", clear
		mi extract `i', clear	
		gen mi = `i'
		save "${gsdTemp}/mi_`i'_`k'.dta", replace
	}
	*append
	clear
	forvalues i = 1/`n' {
		append using "${gsdTemp}/mi_`i'_`k'.dta"
	}
	save "${gsdTemp}/mi-extract_`k'.dta", replace
	*Analysis on extract dataset
	use "${gsdTemp}/mi-extract_`k'.dta", clear
	fastgini tc_imp [pweight=hhweight]
	collapse (mean) tc_* mi_cons_f? mi_cons_nf? mi_cons_d (mean) poorPPP_prob_`k' = poorPPP poorPPP125_prob = poorPPP125 poorPPP_vulnerable_10_prob = poorPPP_vulnerable_10 poorPPP_vulnerable_20_prob = poorPPP_vulnerable_20, by(strata ea block hh hhsize weight hhweight opt_mod plinePPP plinePPP125)
	svyset ea [pweight=hhweight], strata(strata)
	mean poorPPP_prob_`k' [pweight=hhweight]
	mean poorPPP_vulnerable_10_prob [pweight=hhweight]
	mean poorPPP_vulnerable_20_prob [pweight=hhweight]
	gen poorPPP_`k' = poorPPP_prob_`k' > .55
	mean poorPPP_`k' [pweight=hhweight]
	label var tc_core "Total real Dec 2017 consumption based on core pc pd curr USD"
	label var tc_summ "Total real Dec 2017 consumption based on summing pc pd curr USD"
	label var tc_imp "Total real Dec 2017 consumption based on imputation pc pd curr USD"
	label var poorPPP_prob_`k' "Probability being below 2011 PPP poverty line"
	label var poorPPP125_prob "Probability being below 2011 PPP extreme poverty line"
	label var poorPPP_`k' "Being below 2011 PPP poverty line"
	label var poorPPP_vulnerable_10_prob "Probability of being below 2011 PPP poverty line increased by 10%, equivalent to 9.1% shock to consumption"
	label var poorPPP_vulnerable_20_prob "Probability of being below 2011 PPP poverty line increased by 20%, equivalent to 16.7% shock to consumption"
	forvalues i = 0/4 {
		label var mi_cons_f`i' "Food module `i' consumption pc pd curr USD"
		label var mi_cons_nf`i' "Non-Food module `i' consumption pc pd curr USD"
	}
	label var mi_cons_d "Durable consumption pc pd curr USD"
	save "${gsdData}/1-CleanTemp/hhq-poverty_`k'.dta", replace
	cap erase "${gsdTemp}/mi_*"
}

use "${gsdData}/1-CleanOutput/hh.dta", clear
gen ind_profile=6 if astrata==3
replace ind_profile=5 if astrata==22
replace ind_profile=4 if astrata==21
replace ind_profile=3 if astrata==14 | astrata==15
replace ind_profile=2 if astrata==12 | astrata==13 
replace ind_profile=1 if astrata==11
label define lind_profile 1 "Mogadishu (Urban)" 2 "North-east Urban (Nugaal,Bari,Mudug)" 3 "North-west Urban (Woqooyi G,Awdal,Sanaag,Sool,Togdheer)" 4 "North-east Rural (Bari,Mudug,Nugaal)" 5 "North-west Rural (Awdal,Sanaag,Sool,Togdheer,Woqooyi)" 6 "IDP Settlements"
label values ind_profile lind_profile
label var ind_profile "Indicator: Mogadishu, North-East urban/rural, North-West urban/rural & IDPs"
cap drop if ind_profile==6
levelsof ind_profile, local(ind)
foreach k in `ind' {
	merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty_`k'.dta", keepusing(poorPPP_`k' poorPPP_prob_`k') nogen keep(match)
}
ren poorPPP_prob poorPPP_prob_0
gen pweight = weight*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
foreach k of numlist 0/5 {
	tabout ind_profile using "${gsdOutput}/Test_Imputation_raw`k'.xls", svy sum c(mean poorPPP_prob_`k' se) f(3) sebnone h2("Poverty, imputing region `k'") replace
	
}
foreach k of numlist 0/5 {
	insheet using "${gsdOutput}/Test_Imputation_raw`k'.xls", clear nonames tab
	replace v1=v2 if v2==""
	ren v2 p_`k'
	gen n = _n
	sort n
	save "${gsdTemp}/Test_Imputation_raw`k'.dta", replace
	erase "${gsdOutput}/Test_Imputation_raw`k'.xls"
}
use "${gsdTemp}/Test_Imputation_raw0.dta"
sort n
foreach k of numlist 0/5 {
	merge 1:1 v1 using "${gsdTemp}/Test_Imputation_raw`k'.dta", nogen assert(match) keepusing(p_`k')
	
}
sort n
drop n 
drop if v1==""
export excel using "C:\Users\WB484006\OneDrive - WBG\Code\SOM\Wave 2\Output/Impute_outliers_v1.xlsx", sheetreplace sheet("Raw_Impute_Test") firstrow(variables)
