*Preparation of household access and perceptions variables for presentation, asssembles hh-level aggregates  

set more off
set seed 23081920 
set sortseed 11041925


*********************************************************
* Clean access to and quality of services and amenities
*********************************************************
use "${gsdData}/1-CleanTemp/hh.dta", clear
*House type
recode tenure (1=1 "Apartment") (2 4 = 2 "Shared house/apartment") (3=3 "House") (5/7 1000 = 4 "Hut and other"), gen(house_type_cat)
la var house_type_cat "House categories"

*Drinking water
recode drink_water (1/2=1 "Piped water") (3=2 "Public tap") (4 5 7 9=3 "Borehole,protected well/spring, rainwater collection") (12 10=4 "Tanker-truck, bottled water") (6 8 9 11 13 1000 =5 "Unprotected well/spring, others" )  , gen(water)
recode treat_water (1=0 "No treated water") (2/7 1000 = 1 "Treated water"), gen(treated_water)
replace treated_water = 2 if water!=3
label define treated_water 0 "No treated water" 1 "Treated Water" 2 "Protected water source", replace
la var treated_water "Water treatment among households with unprocted drinking water"
la var water "Drinking water source of household"

*Cooking
rename cook cooking
recode cooking (1=1 "Wood Stove") (2=2 "Charcoal Stove") (3 4 =3 "Gas Stove") (5 6 = 4 "Electric Stove"), gen(cook)
la var cook "Cooking Source"


*********************************************************
*Labelling for Tables/Figures 
*********************************************************
la var health_satisfaction "Satisfaction with Health Access/Clinic"
recode school_satisfaction (0=.)
la var school_satisfaction "Satisfaction with Chilrens's Primary School"
la var employment_opportunities "Employment Opportunities compared to 6 months ago"
la var standard_living "Standard of living prospects"
la var floor_material "Floor material"
la var trust_people "Trust in people"
la var police_competence "Confidence in police protection"
*la var safe_walking "Safety walking in neighborhood"
*la var travel_other_districts "Safe travelling to other districts"
la var improve_community "Means to improve security"
la var agent_of_change "Agent to improve security"
*la var community_disputes "Reason for community disputes"
la var hunger "Hunger in past 4 weeks" 
la var floor_material "Floor material in dwelling"


*********************************************************
*Merge in aggregates from child files 
*********************************************************
* add in household member aggregates
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_hhm.dta", nogen assert(match) keepusing(penrol penrol_p penrol_s pgender pworking_age no_children no_adults no_old_age pliteracy hhh_gender hhh_age hhh_edu lfp_7d_hh emp_7d_hh hhh_outstate)

* add in food consumption aggregates
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_fcons.dta", nogen assert(master match) keepusing(cons_f0 cons_f1 cons_f2 cons_f3 cons_f4)
order cons_f0 cons_f1 cons_f2 cons_f3 cons_f4, after(hhsize) 
* add in nonfood consumption aggregates
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_nfcons.dta", nogen assert(master match) keepusing(cons_nf0 cons_nf1 cons_nf2 cons_nf3 cons_nf4)
order cons_nf0 cons_nf1 cons_nf2 cons_nf3 cons_nf4, after(cons_f4)
* add in durables aggregates
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_durables.dta", nogen assert(master match) keepusing(cons_d)
order cons_d, after(cons_nf4)
* add in imputed consumption and poverty figures
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", assert(match master) keep(match master) nogen keepusing(poorPPP poorPPP_prob poorPPP_vulnerable_10_prob poorPPP_vulnerable_20_prob tc_imp plinePPP)
order tc_imp poorPPP_prob poorPPP_vulnerable_10_prob poorPPP_vulnerable_20_prob poorPPP, after(weight)
label define lpoorPPP 0 "Non-Poor" 1 "Poor", replace
label values poorPPP lpoorPPP
* add enumeration team
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(team)
ren team enum_team

*********************************************************
* Generate Poverty Statistics 
*********************************************************
*Poverty Gap Index
gen pgi = (plinePPP - tc_imp)/plinePPP if !mi(tc_imp) & tc_imp < plinePPP
replace pgi = 0 if tc_imp>plinePPP & !mi(tc_imp)
la var pgi "Poverty Gap Index"

* Poverty Severity
gen pseverity = pgi^2
la var pseverity "Poverty Severity/Squared Poverty Gap"
order tc_imp plinePPP  poorPPP pgi pseverity, after(hhsize)


*********************************************************
* Create Quintiles 
*********************************************************
* Based on total consumption (Imputed)
xtile quintiles_tc = tc_imp [pweight=weight*hhsize], n(5) 
label define lquintiles_tc 1 "Q1 (bottom 20)"	2 "Q2"	3 "Q3"	4 "Q4"	5 "Q5 (top 20)"
label values quintiles_tc lquintiles_tc
label var quintiles_tc "Consumption Quintiles per capita based on total imputed consumption"
order quintiles_tc, after(pseverity)
save "${gsdTemp}/hh_pre_final.dta", replace


*********************************************************
*  Arrange other sections 
*********************************************************
use "${gsdData}/1-CleanInput/assets_prev.dta", clear
merge m:1  strata ea block hh using "${gsdTemp}/hh_pre_final.dta", nogen keep(match) keepusing(weight) 
order region strata ea block hh enum weight astrata
drop team
save "${gsdData}/1-CleanOutput/assets_prev.dta", replace

use "${gsdData}/1-CleanInput/hhm_separated.dta", clear
merge m:1  strata ea block hh using "${gsdTemp}/hh_pre_final.dta", nogen keep(match) keepusing(weight) 
order region strata ea block hh enum weight 
drop team
save "${gsdData}/1-CleanOutput/hhm_separated.dta", replace

use "${gsdData}/1-CleanInput/livestock.dta", clear
merge m:1  strata ea block hh using "${gsdTemp}/hh_pre_final.dta", nogen keep(match) keepusing(weight) 
order region strata ea block hh enum weight astrata
drop team
save "${gsdData}/1-CleanOutput/livestock.dta", replace

use "${gsdData}/1-CleanInput/livestock_pre.dta", clear
merge m:1  strata ea block hh using "${gsdTemp}/hh_pre_final.dta", nogen keep(match) keepusing(weight) 
order region strata ea block hh enum weight astrata
drop team
save "${gsdData}/1-CleanOutput/livestock_pre.dta", replace

use "${gsdData}/1-CleanInput/motor.dta", clear
merge m:1  strata ea block hh using "${gsdTemp}/hh_pre_final.dta", nogen keep(match) keepusing(weight) 
order region strata ea block hh enum weight astrata
drop team
save "${gsdData}/1-CleanOutput/motor.dta", replace

use "${gsdData}/1-CleanInput/shocks.dta", clear
merge m:1  strata ea block hh using "${gsdTemp}/hh_pre_final.dta", nogen keep(match) keepusing(weight) 
order region strata ea block hh enum weight astrata
drop team
save "${gsdData}/1-CleanOutput/shocks.dta", replace

use "${gsdData}/1-CleanTemp/assets.dta", clear
order cons_d cf_median cons_flow drate drate_median own_median, after(itemid)
save "${gsdData}/1-CleanOutput/assets.dta", replace


*********************************************************
*Integrate imputed consumption values into the household dataset 
*********************************************************
*first collapse food and non-food at the hh level
use "${gsdData}/1-CleanOutput/food.dta", clear
collapse (sum) cons_usd_imp, by(strata ea block hh mod_opt mod_item)
reshape wide cons_usd, i(strata ea block hh mod_opt) j(mod_item)
save "${gsdData}/1-CleanTemp/imputed_food_byhh.dta", replace
use "${gsdData}/1-CleanOutput/nonfood.dta", clear
collapse (sum) purc_usd_imp, by(strata ea block hh mod_opt mod_item)
reshape wide purc_usd, i(strata ea block hh mod_opt) j(mod_item)
save "${gsdData}/1-CleanTemp/imputed_nonfood_byhh.dta", replace
*then retrive the hh dataset, rename variables and include imputed consumption
use "${gsdTemp}/hh_pre_final.dta", clear
forvalues i = 0/4 {
 label var cons_f`i' "Food consumption in curr USD (Mod:`i'): 7d"
 rename cons_f`i' cons_f`i'_org
 label var cons_nf`i' "Non-Food consumption in curr USD (Mod:`i'): 7d"
 rename cons_nf`i' cons_nf`i'_org
}
*include food consumption
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/imputed_food_byhh.dta", assert(match master) nogen 	
ren (cons_usd_imp?) (cons_f?_imp)
forvalues i = 0/4 {
 label var cons_f`i'_imp "Food consumption (imputed) in curr USD (Mod:`i'): 7d"
}
*include non-food consumption 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/imputed_nonfood_byhh.dta", assert(match master) nogen 	
rename (purc_usd_imp?) (cons_nf?_imp)
forvalues i = 0/4 {
 label var cons_nf`i'_imp "Non-Food cons (imputed) in curr USD (Mod:`i'): 7d"
}
*organize the dataset 
order cons_f?_imp cons_nf?_imp, after (cons_d)
order poorPPP_prob poorPPP_vulnerable_10_prob poorPPP_vulnerable_20_prob poorPPP plinePPP quintiles_tc, after (weight)
*finally, include imputed consumption of durables 
merge 1:1 strata ea block hh using  "${gsdData}/1-CleanTemp/hhq-poverty.dta", assert(match master) nogen keepusing(mi_cons_d)	
rename mi_cons_d cons_d_imp
order cons_d_imp, after (cons_nf4_imp)
rename cons_d cons_d_org
label var cons_d_org "Consumption flow of durables in curr USD: 7d" 
label var cons_d_imp "Consumption flow of durables (imputed) in curr USD: 7d" 
*order the variables and final arrangements 
drop cons_f0_org-cons_d_org
egen tc_imp_f=rowtotal(cons_f?_imp)
label var tc_imp_f "Total Food cons (imputed) in current USD: 7d"
egen tc_imp_nf=rowtotal(cons_nf?_imp)
label var tc_imp_nf "Total Non-Food cons (imputed) in current USD: 7d"
gen tc_imp_d=cons_d_imp
label var tc_imp_d "Consumption flow of durables (imputed) in current USD: 7d"
order tc_imp_f tc_imp_nf tc_imp_d, after(tc_imp)
order beh_treat_opt, after( nadults)
drop cons_f0_imp-cons_d_imp
order ind_profile, after(type)
order hhsize mod_opt, after(ind_profile)
order house_type_cat, after(tenure)
order water, after(drink_water) 
order treated_water, after(treat_water) 
order cook, after(cooking)
order hhh_gender hhh_age hhh_edu, after(hhh_id)
order penrol_p penrol_s pgender pworking_age   pliteracy lfp_7d_hh emp_7d_hh, after(hhh_edu)
order penrol, after(penrol_s)
label var no_children "No of Children in Households" 
label var no_adults "No of Adults in Households" 
label var no_old_age "No of Elderly in Households"
drop nadults 
order region strata ea block hh enum beh_treat_opt type type_idp_host ind_profile mod_opt weight poorPPP_prob poorPPP plinePPP poorPPP_vulnerable_10_prob poorPPP_vulnerable_20_prob quintiles_tc tc_imp tc_imp_f tc_imp_nf tc_imp_d pgi pseverity hhsize no_children no_adults no_old_age hhh_gender hhh_age pgender hhh_edu penrol_p penrol_s penrol pworking_age pliteracy lfp_7d_hh emp_7d_hh 
ren region reg_pess 
la var reg_pess "Region (PESS)"

*********************************************************
*Declare survey & save 
*********************************************************
svyset ea [pweight=weight], strata(strata)
save "${gsdData}/1-CleanOutput/hh.dta", replace
