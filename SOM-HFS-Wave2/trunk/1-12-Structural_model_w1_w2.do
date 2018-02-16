*Estimate a structural model to predict poverty in wave 1 and 2

set more off
set seed 23023980 
set sortseed 11065955


*=====================================================================
* WAVE 1: STRUCTURAL MODEL
*=====================================================================
use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear

**************************
* I. Prepare the dataset 
**************************
*Recode some values
recode hhh_edu (missing=0)
recode remit12m (missing=0)
recode hunger (1=0 "Never") (2=1 "Rarely") (3/max=2 "Often") (missing=2), gen(hh_hunger) label(lhh_hunger)
recode treated_water (missing=2)
recode floor_material (1/2=1 "Solid") (3=2 "Mud") (4/max=3 "Wood/other") (missing=3), gen(hh_floor) label(lhh_floor)
recode house_ownership (1=1 "Rent") (2=2 "Own") (3/max=3 "Occupation") (missing=3), gen(hh_ownership) label(lhh_ownership)
recode roof_material (1=1 "Metal Sheets") (3=2 "Harar")  (6=3 "Plastic sheet or cloth") (2=4 "Other") (4=4 "Other") (5=4 "Other") (6/max=4 "Other") (missing=4 "Other"), gen(hh_roof) label(lhh_roof)
*HH age replaced by median for strta and gender of hh head
bysort strata hhh_gender: egen prelim_hhh_age_median= median(hhh_age) 
bysort strata hhh_gender: egen hhh_age_median= max(prelim_hhh_age_median)
replace hhh_age=hhh_age_median if hhh_age>=. & hhh_age_median>0
*Proportion of literacy replaced by median for strata
bysort strata: egen prelim_pliteracy_median= median(pliteracy) 
bysort strata: egen pliteracy_median= max(prelim_pliteracy_median)
replace pliteracy=pliteracy_median if pliteracy>=. 
*Water source replaced by median for strata
bysort strata: egen prelim_water_median= median(water) 
bysort strata: egen water_median= max(prelim_water_median)
replace water=water_median if water>=.
*Cook source replaced by median for strata
bysort strata: egen prelim_cook_median= median(cook) 
bysort strata: egen cook_median= max(prelim_cook_median)
replace cook_median=2 if cook_median==1.5
replace cook=cook_median if cook>=. | cook==1000
*House type replaced by median for strata
bysort strata: egen prelim_house_type_cat_median= median(house_type_cat ) 
bysort strata: egen house_type_cat_median= max(prelim_house_type_cat_median)
replace house_type_cat =house_type_cat_median if house_type_cat >=.
*Toilet type replaced by median for strata
bysort strata: egen prelim_toilet_type_median= median(toilet_type) 
bysort strata: egen toilet_type_median= max(prelim_toilet_type_median)
replace toilet_type =toilet_type_median if toilet_type >=. | toilet_type==1000
*Create dummy for Mogadishu
gen mog_dummy=(ind_profile==1)
*Include real core consumption 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", nogen keep(match) keepusing(tc_core)
*Declare survey structure
gen hhweight=hhsize*weight_cons
svyset ea [pweight=hhweight], strata(strata)


******************************************
* II. MODEL FOR CORE CONSUMPTION DIRECTLY
******************************************
preserve
***Estimate the strutural model for NW and Mogadishu and obtain predicted poverty
*replace tc_core=ln(tc_core)
svy: reg tc_core mog_dummy type hhsize hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.hh_floor i.hh_roof i.hh_ownership remit12m i.hh_hunger if (ind_profile!=2 & ind_profile!=4 & ind_profile!=6), nocons
predict tc_core_imp
*replace tc_core_imp=exp(tc_core_imp)
*replace tc_core=exp(tc_core)
sum tc_imp [weight=hhweight]
gen tc_imp_mean=r(mean)
sum tc_core [weight=hhweight] 
gen tc_core_mean=r(mean)
gen scale_factor=tc_core_mean/tc_imp_mean
gen plinePPP_scaled=plinePPP*scale_factor
gen poorPPP_core = tc_core_imp < plinePPP_scaled if !missing(tc_imp)
*Compare results 
mean poorPPP [pweight=hhweight]
mean poorPPP_core [pweight=hhweight]
mean poorPPP [pweight=hhweight], over(ind_profile)
mean poorPPP_core [pweight=hhweight], over(ind_profile)
restore


************************************************
* III. MODEL FOR POVERTY STATUS (FROM CORE CONS)
************************************************
*Obtain poverty from core consumption
sum tc_imp [weight=hhweight]
gen tc_imp_mean=r(mean)
sum tc_core [weight=hhweight] 
gen tc_core_mean=r(mean)
gen scale_factor=tc_core_mean/tc_imp_mean
gen plinePPP_scaled=plinePPP*scale_factor
gen poorPPP_core =(tc_core< plinePPP_scaled) if !missing(tc_imp)
*Compare results 
mean poorPPP [pweight=hhweight]
mean poorPPP_core [pweight=hhweight]
mean poorPPP [pweight=hhweight], over(ind_profile)
mean poorPPP_core [pweight=hhweight], over(ind_profile)
*Estimate the strutural model and obtain the prob of being poor
svy: reg poorPPP_core mog_dummy type hhsize hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.hh_floor i.hh_roof i.hh_ownership remit12m i.hh_hunger if (ind_profile!=2 & ind_profile!=4 & ind_profile!=6), nocons
svy: logit poorPPP_core mog_dummy type hhsize hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.hh_floor i.hh_roof i.hh_ownership remit12m i.hh_hunger if (ind_profile!=2 & ind_profile!=4 & ind_profile!=6), nocons
predict poorPPP_prob_imp
*Compare results
mean poorPPP_prob [pweight=hhweight]
mean poorPPP_prob_imp [pweight=hhweight]
mean poorPPP_prob [pweight=hhweight], over(ind_profile)
mean poorPPP_prob_imp [pweight=hhweight], over(ind_profile)
save "${gsdTemp}/poor_structural_w1_analysis.dta", replace

*Create all the set of poverty indicators
gen poorPPP_imp = poorPPP_prob_imp > .55

poorPPP_prob 
poorPPP_vulnerable_10_prob poorPPP_vulnerable_20_prob quintiles_tc tc_imp tc_imp_f tc_imp_nf tc_imp_d pgi pseverity
poorPPP_vulnerable_10_prob poorPPP_vulnerable_20_prob quintiles_tc 
tc_imp tc_imp_f tc_imp_nf tc_imp_d pgi pseverity cons_f0_org cons_f1_org cons_f2_org cons_f3_org cons_f4_org cons_nf0_org cons_nf1_org cons_nf2_org cons_nf3_org cons_nf4_org cons_d_org

*Save results 
keep strata ea block hh ind_profile poorPPP_prob_imp
save "${gsdTemp}/poor_structural_w1_results.dta", replace


************************************************
* IV. ROBUST CHECKS
************************************************
*A) Estimate the model without cleaned data
use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", nogen keep(match) keepusing(tc_core)
gen mog_dummy=(ind_profile==1)
gen hhweight=hhsize*weight_cons
svyset ea [pweight=hhweight], strata(strata)
*Obtain poverty from core consumption
sum tc_imp [weight=hhweight]
gen tc_imp_mean=r(mean)
sum tc_core [weight=hhweight] 
gen tc_core_mean=r(mean)
gen scale_factor=tc_core_mean/tc_imp_mean
gen plinePPP_scaled=plinePPP*scale_factor
gen poorPPP_core =(tc_core< plinePPP_scaled) if !missing(tc_imp)
*Estimate the strutural model and obtain the prob of being poor
svy: reg poorPPP_core mog_dummy type hhsize hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.floor_material i.roof_material i.house_ownership remit12m i.hunger if (ind_profile!=2 & ind_profile!=4 & ind_profile!=6), nocons
svy: logit poorPPP_core mog_dummy type hhsize hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.floor_material i.roof_material i.house_ownership remit12m i.hunger if (ind_profile!=2 & ind_profile!=4 & ind_profile!=6), nocons
predict poorPPP_prob_imp
*Compare results
mean poorPPP_prob [pweight=hhweight]
mean poorPPP_prob_imp [pweight=hhweight]
mean poorPPP_prob [pweight=hhweight], over(ind_profile)
mean poorPPP_prob_imp [pweight=hhweight], over(ind_profile)

*B) Estimate the model using other methods
use "${gsdTemp}/poor_structural_w1_analysis.dta", clear
drop poorPPP_prob_imp
preserve 
svy: reg poorPPP_core mog_dummy type hhsize hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.hh_floor i.hh_roof i.hh_ownership remit12m i.hh_hunger if (ind_profile!=2 & ind_profile!=4 & ind_profile!=6), nocons
predict poorPPP_prob_imp
mean poorPPP_prob_imp [pweight=hhweight]
mean poorPPP_prob_imp [pweight=hhweight], over(ind_profile)
restore
preserve 
svy: probit poorPPP_core mog_dummy type hhsize hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.hh_floor i.hh_roof i.hh_ownership remit12m i.hh_hunger if (ind_profile!=2 & ind_profile!=4 & ind_profile!=6), nocons
predict poorPPP_prob_imp
mean poorPPP_prob_imp [pweight=hhweight]
mean poorPPP_prob_imp [pweight=hhweight], over(ind_profile)
restore

*C) Estimate the model using all the sample 
use "${gsdTemp}/poor_structural_w1_analysis.dta", clear
drop poorPPP_prob_imp
*Estimate the strutural model and obtain the prob of being poor
svy: reg poorPPP_core mog_dummy type hhsize hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.hh_floor i.hh_roof i.hh_ownership remit12m i.hh_hunger, nocons
svy: logit poorPPP_core mog_dummy type hhsize hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.hh_floor i.hh_roof i.hh_ownership remit12m i.hh_hunger, nocons
predict poorPPP_prob_imp
*Compare results
mean poorPPP_prob [pweight=hhweight]
mean poorPPP_prob_imp [pweight=hhweight]
mean poorPPP_prob [pweight=hhweight], over(ind_profile)
mean poorPPP_prob_imp [pweight=hhweight], over(ind_profile)

*D) Exclude 20% and 25% of the sample and make an out of the sample forecast
*Leave out 20% of the sample
qui forval i=1/1000 {
	use "${gsdTemp}/poor_structural_w1_analysis.dta", clear

	bys ind_profile: gen rand=runiform() if (ind_profile!=2 & ind_profile!=4 & ind_profile!=6)
	sort ind_profile rand
	bys ind_profile: gen x=_n
	svy: logit poorPPP_core mog_dummy hhsize type hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.hh_floor i.hh_roof i.hh_ownership remit12m i.hh_hunger if  (ind_profile==1 & x>160) | (ind_profile==3 & x>280) | (ind_profile==5 & x>133), nocons
	predict poorPPP_imp
	keep if (ind_profile==1 & x<=160) | (ind_profile==3 & x<=280) | (ind_profile==5 & x<=133)
	collapse (mean) poorPPP_imp [pw=hhweight], by(ind_profile)
	gen x=`i'

	save "${gsdTemp}/w1_20p_bootstrap_`i'.dta", replace
}
use "${gsdTemp}/w1_20p_bootstrap_1.dta", clear
qui forval i=2/1000 {
	append using "${gsdTemp}/w1_20p_bootstrap_`i'.dta"
}
reshape wide poorPPP_imp, i(x) j(ind_profile)
tabstat poorPPP_imp1 poorPPP_imp3 poorPPP_imp5 

*Leave out 25% of the sample
qui forval i=1/1000 {
	use "${gsdTemp}/poor_structural_w1_analysis.dta", clear

	bys ind_profile: gen rand=runiform() if (ind_profile!=2 & ind_profile!=4 & ind_profile!=6)
	sort ind_profile rand
	bys ind_profile: gen x=_n
	svy: logit poorPPP_core mog_dummy hhsize type hhh_gender hhh_age i.hhh_edu pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet_type i.hh_floor i.hh_roof i.hh_ownership remit12m i.hh_hunger if  (ind_profile==1 & x>200) | (ind_profile==3 & x>350) | (ind_profile==5 & x>166), nocons
	predict poorPPP_imp
	keep if (ind_profile==1 & x<=200) | (ind_profile==3 & x<=350) | (ind_profile==5 & x<=166)
	collapse (mean) poorPPP_imp [pw=hhweight], by(ind_profile)
	gen x=`i'

	save "${gsdTemp}/w1_25p_bootstrap_`i'.dta", replace
}
use "${gsdTemp}/w1_25p_bootstrap_1.dta", clear
qui forval i=2/1000 {
	append using "${gsdTemp}/w1_25p_bootstrap_`i'.dta"
}
reshape wide poorPPP_imp, i(x) j(ind_profile)
tabstat poorPPP_imp1 poorPPP_imp3 poorPPP_imp5 




*=====================================================================
* Wave 2: STRUCTURAL MODEL
*=====================================================================
use "${gsdData}/1-CleanOutput/hh.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhm-hh.dta", keepusing(pchild psenior hhsex hhempl hhedu hhh_literacy) nogen assert(match)

**************************
* I. Prepare the dataset 
**************************
*Include dependency  
gen pdependent=(no_old_age+no_children)/ (no_old_age+no_children+no_adults)
*Recode some values
recode migr_disp (missing=0)
recode lfp_7d_hh (missing=0)
recode emp_7d_hh (missing=0)
recode treated_water (missing=2)
recode remit12m (missing=0)
recode floor_material (1/2=1 "Solid") (3=2 "Mud") (4/max=3 "Wood/other") (missing=3), gen(hh_floor) label(lhh_floor)
recode roof_material (1=1 "Metal Sheets") (3=2 "Harar")  (6=3 "Plastic sheet or cloth") (2=4 "Other") (4=4 "Other") (5=4 "Other") (6/max=4 "Other") (missing=4 "Other"), gen(hh_roof) label(lhh_roof)
recode tenure (1=1 "Rent") (2=2 "Own") (3/5=3 "Provided") (6/max=4 "Occupation") (missing=4), gen(hh_ownership) label(lhh_ownership)
recode hunger (1=0 "Never") (2=1 "Rarely") (3/max=2 "Often") (missing=2), gen(hh_hunger) label(lhh_hunger)
recode cook (1=1 "Wood Stove") (2=2 "Charcoal Stove") (3=3 "Gas Stove") (4=4 "Electric Stove") (5/max=5 "Other") (missing=5), gen(hh_cook) label(lhh_cook)
recode toilet (1/5=1 "Flush") (6/8=2 "Pit Latrine") (12=3 "Open") (9/11=4 "Other") (1000=4 "Other") (missing=4), gen(hh_toilet) label(lhh_toilet)
*HH age replaced by median for strta and gender of hh head
bysort strata hhh_gender: egen prelim_hhh_age_median= median(hhh_age) 
bysort strata hhh_gender: egen hhh_age_median= max(prelim_hhh_age_median)
replace hhh_age=hhh_age_median if hhh_age>=. & hhh_age_median>0
*Proportion of literacy replaced by median for strata
bysort strata: egen prelim_pliteracy_median= median(pliteracy) 
bysort strata: egen pliteracy_median= max(prelim_pliteracy_median)
replace pliteracy=pliteracy_median if pliteracy>=. 
*Water source replaced by median for strata
bysort strata: egen prelim_water_median= median(water) 
bysort strata: egen water_median= max(prelim_water_median)
replace water=water_median if water>=.
*House type replaced by median for strata
replace house_type_cat=. if house_type_cat==8
bysort strata: egen prelim_house_type_cat_median= median(house_type_cat ) 
bysort strata: egen house_type_cat_median= max(prelim_house_type_cat_median)
replace house_type_cat =house_type_cat_median if house_type_cat >=.
*Dummy for Mogadishu/SW/Central
gen dummy_region=1 if ind_profile==1
replace dummy_region=2 if ind_profile==3 | ind_profile==5
replace dummy_region=3 if ind_profile==7 | ind_profile==8
replace dummy_region=4 if dummy_region==.
gen host=(type_idp_host==2)
*Include real core consumption 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", nogen assert(match) keepusing(tc_core)
*Declare survey structure
gen hhweight=hhsize*weight
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)


******************************************
* II. MODEL FOR CORE CONSUMPTION DIRECTLY
******************************************
preserve
***Estimate the strutural model for NW and Mogadishu and obtain predicted poverty
*replace tc_core=ln(tc_core)
svy: reg tc_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.hh_cook i.hh_toilet i.hh_floor i.hh_roof i.hh_ownership i.hh_hunger remit12m migr_disp if !inlist(ind_profile,2,4,6,9,10,13), nocons
predict tc_core_imp
*replace tc_core_imp=exp(tc_core_imp)
*replace tc_core=exp(tc_core)
sum tc_imp [weight=hhweight]
gen tc_imp_mean=r(mean)
sum tc_core [weight=hhweight] 
gen tc_core_mean=r(mean)
gen scale_factor=tc_core_mean/tc_imp_mean
gen plinePPP_scaled=plinePPP*scale_factor
gen poorPPP_core = tc_core_imp < plinePPP_scaled if !missing(tc_imp)
*Compare results 
mean poorPPP [pweight=hhweight]
mean poorPPP_core [pweight=hhweight]
mean poorPPP [pweight=hhweight], over(ind_profile)
mean poorPPP_core [pweight=hhweight], over(ind_profile)
restore


************************************************
* III. MODEL FOR POVERTY STATUS (FROM CORE CONS)
************************************************
*Obtain poverty from core consumption
sum tc_imp [weight=hhweight]
gen tc_imp_mean=r(mean)
sum tc_core [weight=hhweight] 
gen tc_core_mean=r(mean)
gen scale_factor=tc_core_mean/tc_imp_mean
gen plinePPP_scaled=plinePPP*scale_factor
gen poorPPP_core =(tc_core< plinePPP_scaled) if !missing(tc_imp)
*Compare results 
mean poorPPP [pweight=hhweight]
mean poorPPP_core [pweight=hhweight]
mean poorPPP [pweight=hhweight], over(ind_profile)
mean poorPPP_core [pweight=hhweight], over(ind_profile)
*Estimate the strutural model and obtain the prob of being poor
svy: reg poorPPP_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.hh_cook i.hh_toilet i.hh_floor i.hh_roof i.hh_ownership i.hh_hunger remit12m migr_disp if !inlist(ind_profile,2,4,6,9,10,13), nocons
svy: logit poorPPP_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.hh_cook i.hh_toilet i.hh_floor i.hh_roof i.hh_ownership i.hh_hunger remit12m migr_disp if !inlist(ind_profile,2,4,6,9,10,13), nocons
predict poorPPP_prob_imp
*Compare results
mean poorPPP_prob [pweight=hhweight]
mean poorPPP_prob_imp [pweight=hhweight]
mean poorPPP_prob [pweight=hhweight], over(ind_profile)
mean poorPPP_prob_imp [pweight=hhweight], over(ind_profile)
save "${gsdTemp}/poor_structural_w2_analysis.dta", replace

*Create all the set of poverty indicators
*gen poorPPP_imp = poorPPP_prob_imp > .55
*poorPPP_vulnerable_10_prob poorPPP_vulnerable_20_prob quintiles_tc tc_imp tc_imp_f tc_imp_nf tc_imp_d pgi pseverity

*Save results 
keep strata ea block hh ind_profile poorPPP_prob_imp
save "${gsdTemp}/poor_structural_w2_results.dta", replace


************************************************
* IV. ROBUST CHECKS
************************************************
*A) Estimate the model without cleaned data
use "${gsdData}/1-CleanOutput/hh.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhm-hh.dta", keepusing(pchild psenior hhsex hhempl hhedu hhh_literacy) nogen assert(match)
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", nogen assert(match) keepusing(tc_core)
gen pdependent=(no_old_age+no_children)/ (no_old_age+no_children+no_adults)
gen dummy_region=1 if ind_profile==1
replace dummy_region=2 if ind_profile==3 | ind_profile==5
replace dummy_region=3 if ind_profile==7 | ind_profile==8
replace dummy_region=4 if dummy_region==.
gen host=(type_idp_host==2)
gen hhweight=hhsize*weight
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
*Obtain poverty from core consumption
sum tc_imp [weight=hhweight]
gen tc_imp_mean=r(mean)
sum tc_core [weight=hhweight] 
gen tc_core_mean=r(mean)
gen scale_factor=tc_core_mean/tc_imp_mean
gen plinePPP_scaled=plinePPP*scale_factor
gen poorPPP_core =(tc_core< plinePPP_scaled) if !missing(tc_imp)
*Estimate the strutural model and obtain the prob of being poor
svy: reg poorPPP_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet i.floor_material i.roof_material i.tenure i.hunger remit12m migr_disp if !inlist(ind_profile,2,4,6,9,10,13), nocons
svy: logit poorPPP_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.cook i.toilet i.floor_material i.roof_material i.tenure i.hunger remit12m migr_disp if !inlist(ind_profile,2,4,6,9,10,13), nocons
predict poorPPP_prob_imp
*Compare results
mean poorPPP_prob [pweight=hhweight]
mean poorPPP_prob_imp [pweight=hhweight]
mean poorPPP_prob [pweight=hhweight], over(ind_profile)
mean poorPPP_prob_imp [pweight=hhweight], over(ind_profile)

*B) Estimate the model using other methods
use "${gsdTemp}/poor_structural_w2_analysis.dta", clear
drop poorPPP_prob_imp
preserve 
svy: reg poorPPP_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.hh_cook i.hh_toilet i.hh_floor i.hh_roof i.hh_ownership i.hh_hunger remit12m migr_disp if !inlist(ind_profile,2,4,6,9,10,13), nocons
predict poorPPP_prob_imp
mean poorPPP_prob_imp [pweight=hhweight]
mean poorPPP_prob_imp [pweight=hhweight], over(ind_profile)
restore
preserve 
svy: probit poorPPP_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.hh_cook i.hh_toilet i.hh_floor i.hh_roof i.hh_ownership i.hh_hunger remit12m migr_disp if !inlist(ind_profile,2,4,6,9,10,13), nocons
predict poorPPP_prob_imp
mean poorPPP_prob_imp [pweight=hhweight]
mean poorPPP_prob_imp [pweight=hhweight], over(ind_profile)
restore

*C) Estimate the model using all the sample 
use "${gsdTemp}/poor_structural_w2_analysis.dta", clear
drop poorPPP_prob_imp
*Estimate the strutural model and obtain the prob of being poor
svy: reg poorPPP_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.hh_cook i.hh_toilet i.hh_floor i.hh_roof i.hh_ownership i.hh_hunger remit12m migr_disp, nocons
svy: logit poorPPP_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.hh_cook i.hh_toilet i.hh_floor i.hh_roof i.hh_ownership i.hh_hunger remit12m migr_disp, nocons
predict poorPPP_prob_imp
*Compare results
mean poorPPP_prob [pweight=hhweight]
mean poorPPP_prob_imp [pweight=hhweight]
mean poorPPP_prob [pweight=hhweight], over(ind_profile)
mean poorPPP_prob_imp [pweight=hhweight], over(ind_profile)

*D) Exclude 20% and 25% of the sample and make an out of the sample forecast
*Leave out 20% of the sample
qui forval i=1/1000 {
	use "${gsdTemp}/poor_structural_w2_analysis.dta", clear

	bys ind_profile: gen rand=runiform() if !inlist(ind_profile,2,4,6,9,10,13)
	sort ind_profile rand
	bys ind_profile: gen x=_n
	svy: logit poorPPP_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.hh_cook i.hh_toilet i.hh_floor i.hh_roof i.hh_ownership i.hh_hunger remit12m migr_disp if  (ind_profile==1 & x>177) | (ind_profile==3 & x>95) | (ind_profile==5 & x>14) | (ind_profile==7 & x>116) | (ind_profile==8 & x>110) | (ind_profile==11 & x>143) | (ind_profile==12 & x>81), nocons
	predict poorPPP_imp
	keep if (ind_profile==1 & x<=177) | (ind_profile==3 & x<=95) | (ind_profile==5 & x<=14) | (ind_profile==7 & x<=116) | (ind_profile==8 & x<=110) | (ind_profile==11 & x<=143) | (ind_profile==12 & x<=81)
	collapse (mean) poorPPP_imp [pw=hhweight], by(ind_profile)
	gen x=`i'

	save "${gsdTemp}/w2_20p_bootstrap_`i'.dta", replace
}
use "${gsdTemp}/w2_20p_bootstrap_1.dta", clear
qui forval i=2/1000 {
	append using "${gsdTemp}/w2_20p_bootstrap_`i'.dta"
}
reshape wide poorPPP_imp, i(x) j(ind_profile)
tabstat poorPPP_imp1 poorPPP_imp3 poorPPP_imp5 poorPPP_imp7 poorPPP_imp8 poorPPP_imp11 poorPPP_imp12

*Leave out 25% of the sample
qui forval i=1/1000 {
	use "${gsdTemp}/poor_structural_w2_analysis.dta", clear

	bys ind_profile: gen rand=runiform() if !inlist(ind_profile,2,4,6,9,10,13)
	sort ind_profile rand
	bys ind_profile: gen x=_n
	svy: logit poorPPP_core i.dummy_region i.type host hhsize hhh_gender hhh_age hhh_literacy pgender pworking_age pdependent pliteracy lfp_7d_hh emp_7d_hh i.house_type_cat i.water i.treated_water i.hh_cook i.hh_toilet i.hh_floor i.hh_roof i.hh_ownership i.hh_hunger remit12m migr_disp if  (ind_profile==1 & x>222) | (ind_profile==3 & x>119) | (ind_profile==5 & x>18) | (ind_profile==7 & x>145) | (ind_profile==8 & x>138) | (ind_profile==11 & x>179) | (ind_profile==12 & x>101), nocons
	predict poorPPP_imp
	keep if (ind_profile==1 & x<=222) | (ind_profile==3 & x<=119) | (ind_profile==5 & x<=18) | (ind_profile==7 & x<=145) | (ind_profile==8 & x<=138) | (ind_profile==11 & x<=179) | (ind_profile==12 & x<=101)
	collapse (mean) poorPPP_imp [pw=hhweight], by(ind_profile)
	gen x=`i'

	save "${gsdTemp}/w2_25p_bootstrap_`i'.dta", replace
}
use "${gsdTemp}/w2_25p_bootstrap_1.dta", clear
qui forval i=2/1000 {
	append using "${gsdTemp}/w2_25p_bootstrap_`i'.dta"
}
reshape wide poorPPP_imp, i(x) j(ind_profile)
tabstat poorPPP_imp1 poorPPP_imp3 poorPPP_imp5 poorPPP_imp7 poorPPP_imp8 poorPPP_imp11 poorPPP_imp12

