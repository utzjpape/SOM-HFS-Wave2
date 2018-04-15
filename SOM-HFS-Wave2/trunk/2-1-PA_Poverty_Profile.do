*Chapter 1 of the Poverty Assessment: Poverty Profile & Trends

set more off
set seed 23081980 
set sortseed 11041955



**************************************************
*   PREPARE DATASETS 
**************************************************
// Household level 
use "${gsdData}/1-CleanOutput/hh.dta", clear
gen hhweight=weight*hhsize
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
*Poverty measures
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", nogen assert(master match) keepusing(poorPPP125_prob)
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty_ae.dta", nogen assert(master match) keepusing(poorPPP_prob_AE)
*GINI
fastgini tc_imp [pweight=hhweight]
return list 
gen gini=r(gini)
label var gini "GINI Coefficient from tc_imp"
*WASH indicators
gen improved_sanitation=(inlist(toilet,1,2,3,6,7,9)) 
replace improved_sanitation=. if toilet>=.
label values improved_sanitation lyesno
label var improved_sanitation "HH has improved sanitation"
gen improved_water=(inlist(water,1,2,3))
replace improved_water=. if water>=.
label values improved_water lyesno
label var improved_water "HH has improved source of drinking water"
*Drought affected households
gen drought_affected=(shock_1==1 | shock_2==1)
label values drought_affected lyesno
la var drought_affected "HH reported to be affected by the drought"
*Education of HH head
recode hhh_edu (1/2=1) (4=2) (5=3) (6=.), gen(hhh_edu_level)
label define lhhh_edu_level 0 "No Education" 1 "Incomplete Primary to Incomplete Secondary" 2 "Complete Secondary" 3 "University" 
label values hhh_edu_level lhhh_edu_level
gen hhh_edu_dum=(hhh_edu>0) if !missing(hhh_edu)
save "${gsdTemp}/hh_PA_Poverty_Profile.dta", replace


// Household member level 
use "${gsdData}/1-CleanOutput/hhm.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", assert(match) nogen keepusing(weight ind_profile type poorPPP_prob poorPPP hhh_gender remit12m migr_idp)
merge m:1 strata ea block hh using "${gsdTemp}/hh_PA_Poverty_Profile.dta", nogen assert(match) keepusing(drought_affected)
svyset ea [pweight=weight], strata(strata) singleunit(centered)
*Education variables
gen adult_literacy_rate=literacy if age>=15
label values adult_literacy_rate lliteracy
label var adult_literacy_rate "Adult (15+) literacy rate"
gen attainment_primary =(hhm_edu_level>=8) 
replace attainment_primary=. if  hhm_edu_level>=. | age<25
replace attainment_primary=0 if  hhm_edu_level==.z
label values attainment_primary lyesno
label var attainment_primary "Completed primary (aged 25+)"
gen attainment_secondary=(hhm_edu_level>=12) 
replace attainment_secondary=. if  hhm_edu_level>=. | age<25
replace attainment_secondary=0 if  hhm_edu_level==.z
label values attainment_secondary  lyesno
label var attainment_secondary  "Completed secondary (aged 25+)"
*Labor indicators
gen employment=(active_12m_imp==1)
replace employment=. if lfp_7d==0
replace employment=. if age<15
label values employment lyesno
label var employment "HHM employed (aged 15+)"
*Child and youth 
gen child=1 if age<=14 & !missing(age)
replace child=0 if child==. & !missing(age)
gen youth=1 if age<=24 & age>=15 & !missing(age)
replace youth=0 if youth==. & !missing(age)
*Age Dependency ratio (World Bank Definition)
bys strata ea block hh: egen no_dep= count(age_cat_broad) if inlist(age_cat_broad,1,2,4)
bys strata ea block hh: egen no_dependent = mean(no_dep)
bys strata ea block hh: egen no_w_age = count(age_cat_broad) if inlist(age_cat_broad,3)
bys strata ea block hh: egen no_working_age = mean(no_w_age)
replace no_dependent=0 if no_dependent==.
replace no_working_age=0 if no_working_age==.
gen age_dependency_ratio=no_dependent/no_working_age
drop no_dep no_dependent no_w_age no_working_age
save "${gsdTemp}/hhm_PA_Poverty_Profile.dta", replace



**************************************************
*   CROSS-COUNTRY COMPARISONS
**************************************************
*Prepare dataset with data from low-income countries in Africa
use "${gsdTemp}/WB_clean_all.dta", clear
merge 1:1 countryname using "${gsdData}/1-CleanInput/Country_comparison.dta", nogen
keep if countryname=="Somalia" | (country_aggr=="AFRICA" & income_cat=="L")

*Include GDP per head for Somali regions (Source: http://www.worldbank.org/en/country/somalia/overview)
replace gdppc_c = 450 if  countryname=="Somalia"
export excel using "${gsdOutput}/PA_Poverty_Profile_1.xlsx", replace firstrow(variables)

*Prepare the respective data for Somali regions
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean poorPPP_prob se) sebnone f(3) npos(col) h2(Poverty incidence) replace
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean pgi se) sebnone f(3) npos(col) h2(Poverty gap) append
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean gini se) sebnone f(3) npos(col) h2(GINI coefficient) append
svyset ea [pweight=weight], strata(strata) singleunit(centered)
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean improved_sanitation se) sebnone f(3) npos(col) h2(Improved Sanitation) append
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean improved_water se) sebnone f(3) npos(col) h2(Improved Water) append
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean electricity se) sebnone f(3) npos(col) h2(Access to electricity) append

use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean adult_literacy_rate se) sebnone f(3) npos(col) h2(Adult Literay rate) append
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean enrolled25 se) sebnone f(3) npos(col) h2(Enrolment rate) append
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean attainment_primary  se) sebnone f(3) npos(col) h2(Educational attainment - Primary) append
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean attainment_secondary  se) sebnone f(3) npos(col) h2(Educational attainment - Secondary) append
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean lfp_7d se) sebnone f(3) npos(col) h2(Labor force participation) append
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean employment se) sebnone f(3) npos(col) h2(Employment) append



**************************************************
*   POVERTY INCIDENCE
**************************************************
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)

*Poverty incidence 
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_3.xls", svy sum c(mean poorPPP_prob se) sebnone f(3) npos(col) h2(Poverty incidence by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_3.xls", svy sum c(mean poorPPP_prob se) sebnone f(3) npos(col) h2(Poverty incidence by `var') append
}
svy: mean poorPPP_prob, over(hhh_gender)
test [poorPPP_prob]Female = [poorPPP_prob]Male
svy: mean poorPPP_prob, over(remit12m)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob, over(migr_idp)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob, over(drought_affected)
test [poorPPP_prob]Yes = [poorPPP_prob]No

*Map of poverty incidence (with IDPs)
preserve
gen id_map=reg_pess
collapse (mean) poorPPP_prob [pw=hhweight], by(id_map)
replace poorPPP_prob=poorPPP_prob*100
merge 1:1 id_map using "${gsdData}/1-CleanInput/SOM_db.dta", nogen keepusing(ISO)
spmap poorPPP_prob using "${gsdData}/1-CleanInput/SOM_coord.dta", id(id_map) fcolor(Reds) ///
clmethod(custom) clnumber(5) clbreaks(20 40 60 80 100) ndlabel(Not covered by the SHFS 2017) legstyle(2) legend(position(4)) ///
ndfcolor(gs9) title("Poverty Incidence") subtitle("% of population below US$ 1.9 (PPP) per day")  
spmap poorPPP_prob using "${gsdData}/1-CleanInput/SOM_coord.dta", id(id_map) fcolor(Reds) ///
clmethod(custom) clnumber(5) clbreaks(20 40 60 80 100) ndlabel(Not covered by the SHFS 2017) legstyle(2) legend(position(4)) ndfcolor(gs9)  
graph save Graph "${gsdOutput}/Map_Poverty.gph", replace
restore

*Extreme poverty 
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_4.xls", svy sum c(mean poorPPP125_prob se) sebnone f(3) npos(col) h2(Extreme poverty incidence by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_4.xls", svy sum c(mean poorPPP125_prob se) sebnone f(3) npos(col) h2(Extreme poverty incidence by `var') append
}
svy: mean poorPPP125_prob, over(hhh_gender)
test [poorPPP125_prob]Female = [poorPPP125_prob]Male
svy: mean poorPPP125_prob, over(remit12m)
test [poorPPP125_prob]Yes = [poorPPP125_prob]No
svy: mean poorPPP125_prob, over(migr_idp)
test [poorPPP125_prob]Yes = [poorPPP125_prob]No
svy: mean poorPPP125_prob, over(drought_affected)
test [poorPPP125_prob]Yes = [poorPPP125_prob]No

*Poverty incidence for an adult equivalent measure
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_5.xls", svy sum c(mean poorPPP_prob_AE se) sebnone f(3) npos(col) h2(Poverty incidence AE by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_5.xls", svy sum c(mean poorPPP_prob_AE se) sebnone f(3) npos(col) h2(Poverty incidence AE by `var') append
}
svy: mean poorPPP_prob_AE, over(hhh_gender)
test [poorPPP_prob_AE]Female = [poorPPP_prob_AE]Male
svy: mean poorPPP_prob_AE, over(remit12m)
test [poorPPP_prob_AE]Yes = [poorPPP_prob_AE]No
svy: mean poorPPP_prob_AE, over(migr_idp)
test [poorPPP_prob_AE]Yes = [poorPPP_prob_AE]No
svy: mean poorPPP_prob_AE, over(drought_affected)
test [poorPPP_prob_AE]Yes = [poorPPP_prob_AE]No
 
*Vulnerable by a 10% shock
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_6.xls", svy sum c(mean poorPPP_vulnerable_10_prob se) sebnone f(3) npos(col) h2(Vulnerable w/10% shock by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_6.xls", svy sum c(mean poorPPP_vulnerable_10_prob se) sebnone f(3) npos(col) h2(Vulnerable w/10% shocok by `var') append
}
svy: mean poorPPP_vulnerable_10_prob, over(hhh_gender)
test [poorPPP_vulnerable_10_prob]Female = [poorPPP_vulnerable_10_prob]Male
svy: mean poorPPP_vulnerable_10_prob, over(remit12m)
test [poorPPP_vulnerable_10_prob]Yes = [poorPPP_vulnerable_10_prob]No
svy: mean poorPPP_vulnerable_10_prob, over(migr_idp)
test [poorPPP_vulnerable_10_prob]Yes = [poorPPP_vulnerable_10_prob]No
svy: mean poorPPP_vulnerable_10_prob, over(drought_affected)
test [poorPPP_vulnerable_10_prob]Yes = [poorPPP_vulnerable_10_prob]No

*Vulnerable by a 20% shock
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_7.xls", svy sum c(mean poorPPP_vulnerable_20_prob se) sebnone f(3) npos(col) h2(Vulnerable w/20% shock by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_7.xls", svy sum c(mean poorPPP_vulnerable_20_prob se) sebnone f(3) npos(col) h2(Vulnerable w/20% shocok by `var') append
}
svy: mean poorPPP_vulnerable_20_prob, over(hhh_gender)
test [poorPPP_vulnerable_20_prob]Female = [poorPPP_vulnerable_20_prob]Male
svy: mean poorPPP_vulnerable_20_prob, over(remit12m)
test [poorPPP_vulnerable_20_prob]Yes = [poorPPP_vulnerable_20_prob]No
svy: mean poorPPP_vulnerable_20_prob, over(migr_idp)
test [poorPPP_vulnerable_20_prob]Yes = [poorPPP_vulnerable_20_prob]No
svy: mean poorPPP_vulnerable_20_prob, over(drought_affected)
test [poorPPP_vulnerable_20_prob]Yes = [poorPPP_vulnerable_20_prob]No

*Child poverty 
use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
qui tabout ind_profile gender using "${gsdOutput}/PA_Poverty_Profile_8.xls" if child==1, svy sum c(mean poorPPP_prob se) sebnone f(3) npos(col) h2(Child poverty by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' gender using "${gsdOutput}/PA_Poverty_Profile_8.xls" if child==1, svy sum c(mean poorPPP_prob se) sebnone f(3) npos(col) h2(Child poverty incidence by `var') append
}
svy: mean poorPPP_prob if child==1, over(hhh_gender)
test [poorPPP_prob]Female = [poorPPP_prob]Male
svy: mean poorPPP_prob if child==1 & gender==1, over(hhh_gender)
test [poorPPP_prob]Female = [poorPPP_prob]Male
svy: mean poorPPP_prob if child==1 & gender==0, over(hhh_gender)
test [poorPPP_prob]Female = [poorPPP_prob]Male
svy: mean poorPPP_prob if child==1, over(remit12m)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if child==1 & gender==1, over(remit12m)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if child==1 & gender==0, over(remit12m)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if child==1, over(migr_idp)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if child==1 & gender==1, over(migr_idp)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if child==1 & gender==0, over(migr_idp)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if child==1, over(drought_affected)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if child==1 & gender==1, over(drought_affected)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if child==1 & gender==0, over(drought_affected)
test [poorPPP_prob]Yes = [poorPPP_prob]No

*Youth poverty 
qui use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
tabout ind_profile gender using "${gsdOutput}/PA_Poverty_Profile_9.xls" if youth==1, svy sum c(mean poorPPP_prob se) sebnone f(3) npos(col) h2(Child poverty by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' gender using "${gsdOutput}/PA_Poverty_Profile_9.xls" if youth==1, svy sum c(mean poorPPP_prob se) sebnone f(3) npos(col) h2(Child poverty incidence by `var') append
}
svy: mean poorPPP_prob if youth==1, over(hhh_gender)
test [poorPPP_prob]Female = [poorPPP_prob]Male
svy: mean poorPPP_prob if youth==1 & gender==1, over(hhh_gender)
test [poorPPP_prob]Female = [poorPPP_prob]Male
svy: mean poorPPP_prob if youth==1 & gender==0, over(hhh_gender)
test [poorPPP_prob]Female = [poorPPP_prob]Male
svy: mean poorPPP_prob if youth==1, over(remit12m)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if youth==1 & gender==1, over(remit12m)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if youth==1 & gender==0, over(remit12m)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if youth==1, over(migr_idp)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if youth==1 & gender==1, over(migr_idp)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if youth==1 & gender==0, over(migr_idp)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if youth==1, over(drought_affected)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if youth==1 & gender==1, over(drought_affected)
test [poorPPP_prob]Yes = [poorPPP_prob]No
svy: mean poorPPP_prob if youth==1 & gender==0, over(drought_affected)
test [poorPPP_prob]Yes = [poorPPP_prob]No



**************************************************
*   OTHER MONETARY INDICATORS
**************************************************
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)

*Poverty gap
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_10.xls", svy sum c(mean pgi se) sebnone f(3) npos(col) h2(Poverty gap by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_10.xls", svy sum c(mean pgi se) sebnone f(3) npos(col) h2(Poverty gap by `var') append
}
svy: mean pgi, over(hhh_gender)
test [pgi]Female = [pgi]Male
svy: mean pgi, over(remit12m)
test [pgi]Yes = [pgi]No
svy: mean pgi, over(migr_idp)
test [pgi]Yes = [pgi]No
svy: mean pgi, over(drought_affected)
test [pgi]Yes = [pgi]No

*Poverty severity
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_11.xls", svy sum c(mean pseverity se) sebnone f(3) npos(col) h2(Poverty severity by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_11.xls", svy sum c(mean pseverity se) sebnone f(3) npos(col) h2(Poverty severity by `var') append
}
svy: mean pseverity, over(hhh_gender)
test [pseverity]Female = [pseverity]Male
svy: mean pseverity, over(remit12m)
test [pseverity]Yes = [pseverity]No
svy: mean pseverity, over(migr_idp)
test [pseverity]Yes = [pseverity]No
svy: mean pseverity, over(drought_affected)
test [pseverity]Yes = [pseverity]No


*GINI coefficient
qui tabout gini using "${gsdOutput}/PA_Poverty_Profile_12.xls", svy c(freq) sebnone f(3) npos(col) h2(GINI coefficient overall) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	fastgini tc_imp [pweight=hhweight] if ind_profile==`i'
	return list 
	gen gini_`i'=r(gini)
    qui tabout gini_`i' using "${gsdOutput}/PA_Poverty_Profile_12.xls", svy c(freq) sebnone f(3) npos(col) h2(GINI coefficient for ind_profile `i') append
    drop gini_`i'
}
levelsof type, local(population) 
qui foreach i of local population {
	fastgini tc_imp [pweight=hhweight] if type==`i'
	return list 
	gen gini_`i'=r(gini)
    qui tabout gini_`i' using "${gsdOutput}/PA_Poverty_Profile_12.xls", svy c(freq) sebnone f(3) npos(col) h2(GINI coefficient for type `i') append
    drop gini_`i'
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	fastgini tc_imp [pweight=hhweight] if hhh_gender==`i'
	return list 
	gen gini_`i'=r(gini)
    qui tabout gini_`i' using "${gsdOutput}/PA_Poverty_Profile_12.xls", svy c(freq) sebnone f(3) npos(col) h2(GINI coefficient for hhh_gender `i') append
    drop gini_`i'
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	fastgini tc_imp [pweight=hhweight] if remit12m==`i'
	return list 
	gen gini_`i'=r(gini)
    qui tabout gini_`i' using "${gsdOutput}/PA_Poverty_Profile_12.xls", svy c(freq) sebnone f(3) npos(col) h2(GINI coefficient for remit12m `i') append
    drop gini_`i'
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	fastgini tc_imp [pweight=hhweight] if migr_idp==`i'
	return list 
	gen gini_`i'=r(gini)
    qui tabout gini_`i' using "${gsdOutput}/PA_Poverty_Profile_12.xls", svy c(freq) sebnone f(3) npos(col) h2(GINI coefficient for migr_idp `i') append
    drop gini_`i'
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	fastgini tc_imp [pweight=hhweight] if drought_affected==`i'
	return list 
	gen gini_`i'=r(gini)
    qui tabout gini_`i' using "${gsdOutput}/PA_Poverty_Profile_12.xls", svy c(freq) sebnone f(3) npos(col) h2(GINI coefficient for drought_affected `i') append
    drop gini_`i'
}


*Average total imputed consumption by quintile 
qui tabout quintiles_tc using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se) sebnone f(3) npos(col) h2(Avg. consumption by quintile - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if ind_profile==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se) sebnone f(3) npos(col) h2(Avg. consumption by quintile - region `i' ) append
	drop quintiles_tc_`i'
}
levelsof type, local(population) 
qui foreach i of local population {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if type==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se) sebnone f(3) npos(col) h2(Avg. consumption by quintile - type `i' ) append
	drop quintiles_tc_`i'
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if hhh_gender==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se) sebnone f(3) npos(col) h2(Avg. consumption by quintile - hhh_gender `i' ) append
	drop quintiles_tc_`i'
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if remit12m==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se) sebnone f(3) npos(col) h2(Avg. consumption by quintile - remit12m `i' ) append
	drop quintiles_tc_`i'
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if migr_idp==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se) sebnone f(3) npos(col) h2(Avg. consumption by quintile - migr_idp `i' ) append
	drop quintiles_tc_`i'
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if drought_affected==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se) sebnone f(3) npos(col) h2(Avg. consumption by quintile - drought_affected `i' ) append
	drop quintiles_tc_`i'
}


*Distribution of average total consumption
xtile quintiles_tc_all = tc_imp [pweight=hhweight] , n(100) 
qui tabout quintiles_tc_all using "${gsdOutput}/PA_Poverty_Profile_14.xls", svy sum c(mean tc_imp) sebnone f(3) npos(col) h2(Avg. consumption by 100 quintile - overall) replace
drop quintiles_tc_all
levelsof type, local(population) 
qui foreach i of local population {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if type==`i', n(100) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_14.xls", svy sum c(mean tc_imp) sebnone f(3) npos(col) h2(Avg. consumption by 100 quintile - type `i' ) append
	drop quintiles_tc_`i'
}



**************************************************
*   POVERTY AND HOUSEHOLD CHARACTERISTICS
**************************************************
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
merge 1:m strata ea block hh using "${gsdTemp}/hhm_PA_Poverty_Profile.dta", nogen assert(match) keepusing(age_dependency_ratio)
svyset ea [pweight=weight], strata(strata) singleunit(centered)

*Household size
qui tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_15.xls", svy sum c(mean hhsize) sebnone f(3) npos(col) h2(HH size - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_15.xls" if ind_profile==`i', svy sum c(mean hhsize) sebnone f(3) npos(col) h2(HH size for ind_profile `i' ) append
}
levelsof type, local(population) 
qui foreach i of local population {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_15.xls" if type==`i', svy sum c(mean hhsize) sebnone f(3) npos(col) h2(HH size for ind_profile `i' ) append
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_15.xls" if hhh_gender==`i', svy sum c(mean hhsize) sebnone f(3) npos(col) h2(HH size for hhh_gender `i' ) append
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_15.xls" if remit12m==`i', svy sum c(mean hhsize) sebnone f(3) npos(col) h2(HH size for remit12m `i' ) append
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_15.xls" if migr_idp==`i', svy sum c(mean hhsize) sebnone f(3) npos(col) h2(HH size for migr_idp `i' ) append
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_15.xls" if drought_affected==`i', svy sum c(mean hhsize) sebnone f(3) npos(col) h2(HH size for drought_affected `i' ) append
}

*Male headed households 
qui tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls", svy sum c(mean hhh_gender) sebnone f(3) npos(col) h2(Share of male headed HHs - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if ind_profile==`i', svy sum c(mean hhh_gender) sebnone f(3) npos(col) h2(Share of male headed HHs for ind_profile `i' ) append
}
levelsof type, local(population) 
qui foreach i of local population {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if type==`i', svy sum c(mean hhh_gender) sebnone f(3) npos(col) h2(Share of male headed HHs for ind_profile `i' ) append
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if hhh_gender==`i', svy sum c(mean hhh_gender) sebnone f(3) npos(col) h2(Share of male headed HHs for hhh_gender `i' ) append
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if remit12m==`i', svy sum c(mean hhh_gender) sebnone f(3) npos(col) h2(Share of male headed HHs for remit12m `i' ) append
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if migr_idp==`i', svy sum c(mean hhh_gender) sebnone f(3) npos(col) h2(Share of male headed HHs for migr_idp `i' ) append
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if drought_affected==`i', svy sum c(mean hhh_gender) sebnone f(3) npos(col) h2(Share of male headed HHs for drought_affected `i' ) append
}

*Dependency ratio
qui tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_17.xls", svy sum c(mean age_dependency_ratio) sebnone f(3) npos(col) h2(Age dependency ratio - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_17.xls" if ind_profile==`i', svy sum c(mean age_dependency_ratio) sebnone f(3) npos(col) h2(Age dependency ratio for ind_profile `i' ) append
}
levelsof type, local(population) 
qui foreach i of local population {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_17.xls" if type==`i', svy sum c(mean age_dependency_ratio) sebnone f(3) npos(col) h2(Age dependency ratio for ind_profile `i' ) append
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_17.xls" if hhh_gender==`i', svy sum c(mean age_dependency_ratio) sebnone f(3) npos(col) h2(Age dependency ratio for hhh_gender `i' ) append
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_17.xls" if remit12m==`i', svy sum c(mean age_dependency_ratio) sebnone f(3) npos(col) h2(Age dependency ratio for remit12m `i' ) append
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_17.xls" if migr_idp==`i', svy sum c(mean age_dependency_ratio) sebnone f(3) npos(col) h2(Age dependency ratio for migr_idp `i' ) append
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_17.xls" if drought_affected==`i', svy sum c(mean age_dependency_ratio) sebnone f(3) npos(col) h2(Age dependency ratio for drought_affected `i' ) append
}

*Number of children
qui tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_18.xls", svy sum c(mean no_children) sebnone f(3) npos(col) h2(Number of children - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_18.xls" if ind_profile==`i', svy sum c(mean no_children) sebnone f(3) npos(col) h2(Number of children for ind_profile `i' ) append
}
levelsof type, local(population) 
qui foreach i of local population {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_18.xls" if type==`i', svy sum c(mean no_children) sebnone f(3) npos(col) h2(Number of children for ind_profile `i' ) append
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_18.xls" if hhh_gender==`i', svy sum c(mean no_children) sebnone f(3) npos(col) h2(Number of children for hhh_gender `i' ) append
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_18.xls" if remit12m==`i', svy sum c(mean no_children) sebnone f(3) npos(col) h2(Number of children for remit12m `i' ) append
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_18.xls" if migr_idp==`i', svy sum c(mean no_children) sebnone f(3) npos(col) h2(Number of children for migr_idp `i' ) append
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_18.xls" if drought_affected==`i', svy sum c(mean no_children) sebnone f(3) npos(col) h2(Number of children for drought_affected `i' ) append
}

*Number of adults
qui tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_19.xls", svy sum c(mean no_adults) sebnone f(3) npos(col) h2(Number of adults - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_19.xls" if ind_profile==`i', svy sum c(mean no_adults) sebnone f(3) npos(col) h2(Number of adults for ind_profile `i' ) append
}
levelsof type, local(population) 
qui foreach i of local population {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_19.xls" if type==`i', svy sum c(mean no_adults) sebnone f(3) npos(col) h2(Number of adults for ind_profile `i' ) append
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_19.xls" if hhh_gender==`i', svy sum c(mean no_adults) sebnone f(3) npos(col) h2(Number of adults for hhh_gender `i' ) append
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_19.xls" if remit12m==`i', svy sum c(mean no_adults) sebnone f(3) npos(col) h2(Number of adults for remit12m `i' ) append
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_19.xls" if migr_idp==`i', svy sum c(mean no_adults) sebnone f(3) npos(col) h2(Number of adults for migr_idp `i' ) append
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_19.xls" if drought_affected==`i', svy sum c(mean no_adults) sebnone f(3) npos(col) h2(Number of adults for drought_affected `i' ) append
}

*Number of elderly 
qui tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_20.xls", svy sum c(mean no_old_age) sebnone f(3) npos(col) h2(Number of elderly - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_20.xls" if ind_profile==`i', svy sum c(mean no_old_age) sebnone f(3) npos(col) h2(Number of elderly for ind_profile `i' ) append
}
levelsof type, local(population) 
qui foreach i of local population {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_20.xls" if type==`i', svy sum c(mean no_old_age) sebnone f(3) npos(col) h2(Number of elderly for ind_profile `i' ) append
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_20.xls" if hhh_gender==`i', svy sum c(mean no_old_age) sebnone f(3) npos(col) h2(Number of elderly for hhh_gender `i' ) append
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_20.xls" if remit12m==`i', svy sum c(mean no_old_age) sebnone f(3) npos(col) h2(Number of elderly for remit12m `i' ) append
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_20.xls" if migr_idp==`i', svy sum c(mean no_old_age) sebnone f(3) npos(col) h2(Number of elderly for migr_idp `i' ) append
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_20.xls" if drought_affected==`i', svy sum c(mean no_old_age) sebnone f(3) npos(col) h2(Number of elderly for drought_affected `i' ) append
}


*Poverty and education
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)



*ADD NO EDUC VS. SOME EDUC 


qui tabout ind_profile hhh_edu_dum using "${gsdOutput}/PA_Poverty_Profile_21.xls", svy sum c(mean poorPPP_prob) sebnone f(3) npos(col) h1(Poverty incidence by HH edu level) replace







**************************************************
*   MULTIDIMENSIONAL DEPRIVATIONS
**************************************************



**************************************************
*   INTEGRATE ALL SHEETS INTO ONE FILE
**************************************************



* Put all created sheets into one excel document
foreach i of numlist 1/9 {
	insheet using "${gsdOutput}/Child_Poverty_`i'.xls", clear nonames tab
	export excel using "${gsdOutput}/Child_Poverty_Figures_Final.xlsx", sheetreplace sheet("Raw_Data_`i'") 
	erase "${gsdOutput}/Child_Poverty_`i'.xls"
}





save "${gsdTemp}/WB_clean_all.dta", replace 



**************************************************
*   END
**************************************************









*********************************LUCA POVERTY 2 




*multidimensional deprivation index


*Deprivation in the HFS
*Education
use  "${gsdData}/1-CleanTemp/hhm_analysis.dta", clear
*generate dummy if adult had no education ever
gen adult_noedu=(edu_level_g==1) if inrange(age,15,120)
*generate dummy for child not attending school
gen child_noed=(edu_current==0) if inrange(age,6,14)
*create household level data
collapse (sum) adult_noedu (max) child_noed (count) adult_num=adult_noed , by(wave state ea hh)
gen adult_noed=adult_noedu==adult_num
drop adult_noedu adult_num
replace child_noed=0 if missing(child_noed)
label var child_noed "At least one child is not attending school, ages 6-14"
label var adult_noed "All adults have no education, ages 15+"
save "${gsdTemp}/multidimensional_educ_HFS.dta", replace
*WASH
use  "${gsdData}/1-CleanTemp/hhq_analysis.dta", clear
*improved sanitation
gen improved_sanitation=inlist(toilet_type,1,3,5) if  inrange(wave,1,3)
gen x=inlist(toilet,1,2,3,6,7,9)
replace improved_sanitation=x if missing(improved_sanitation) & !missing(x) &  wave==4
drop x
label var improved_sanitation "Household has access to improved sanitation"
*improved drinking source
gen improved_watersource=inlist(drink_source,1,2,3,4,5,10) if  inrange(wave,1,3)
gen x=inlist(water_source,1,2,3,4,5,7,9) 
replace improved_watersource=x if missing(improved_watersource) & !missing(x) & wave==4
drop x
label var improved_watersource "Household has access to improved watersource"
*housing type
gen housing=inlist(housingtype,5,6,8,9,10) 
label var housing "Household lives in improved housing"
*cooking
gen cook=inlist(cooking,2,3)
label var cook "Household cooks with grass, dung, or firewood"
*sleeping room density
quietly su slrooms_n, meanonly
replace slrooms_n=r(mean) if missing(slrooms_n)
gen crowding=(hhsize/slrooms_n)>2.5
label var crowding "Household lives in overcrowded household"
label val crowding lyn
*electricity
gen electricity=(inlist(lighting,5,6)) & !missing(lighting)
label var electricity "Household has access to electricity" 
*merge with assets
merge 1:1 wave state ea hh using "${gsdData}/1-CleanTemp/assets_analysis_wide.dta", nogen assert(match master using) keep(match master)  
*information
gen tvsat=(!missing(Television) | !missing(Satellite_dish) )
label var tvsat  "Household owns at least one TV/Satellite dish"
gen radio=!missing(Radio_transistor)
label var radio "Household owns at least one Radio"
gen mobile_phone=!missing(Mobile_phone)
label var mobile_phone "Household owns at least one Mobile phone"
gen computer=!missing(Computer_laptop)
label var mobile_phone "Household owns at least one computer"
*transportation
gen cartruck=(!missing(Trucks) | !missing(Cars))
label var cartruck "Household owns at least one car/truck"
 gen motorcycleshaw=(!missing(Motorcycle_motor) | !missing(Rickshaw))
label var motorcycleshaw "Household owns at least one motorcycle/rickshaw"
gen bicycle=!missing(Bicycle)
label var bicycle "Household owns at least one bicycle"
*merge with education data
merge 1:1 wave state ea hh using "${gsdTemp}/multidimensional_educ_HFS.dta", nogen assert(match)
*create dimensional indices
gen information=(mobile_phone==0 & tvsat==0 & radio==0 & computer==0)
label var information "Household deprived in dimension: information"
gen transportation=(cartruck==0 & motorcycleshaw==0 & bicycle==0)
label var transportation "Household deprived in dimension: transportation"
gen assets=(information==1 | transportation==1)
label var assets "Household deprived in dimension: assets"
gen living_standards=(housing==0 | electricity==0 | crowding==1 | cook==1)
label var living_standards "Household deprived in dimension: living standards"
gen education=(child_noed==1 | adult_noed==1)
label var education "Household deprived in dimension: education"
gen wash=(improved_sanitation==0 | improved_watersource==0)
label var wash "Household deprived in dimension: WASH"
egen deprivations=rowtotal(assets living_standards education wash poor)
label var deprivations "Total number of dimensions household is deprived in"
egen deprivations2=rowtotal(assets living_standards education wash )
label var deprivations2 "Total number of dimensions household is deprived in, no poverty"
*clean up and save
local tokeep = "poor quintiles_tc hhh_gender deprivations deprivations2  improved_sanitation improved_watersource electricity housing cook crowding mobile_phone tvsat radio computer cartruck motorcycleshaw bicycle adult_noed child_noed information transportation assets education living_standards wash"
local labelling = "improved_sanitation improved_watersource electricity housing cook crowding mobile_phone tvsat radio computer cartruck motorcycleshaw bicycle adult_noed child_noed information transportation assets education living_standards wash"
label val `labelling' lyn
keep dataset wave state ea hh urban weight pweight hhsize `tokeep'
save  "${gsdTemp}/multidimensional_deprivation_HFS.dta", replace




*ANALYSIS
use "${gsdTemp}/multidimensional_deprivation.dta", clear
svyset ea [pw=pweight], strata(stratum)
*test deprivations between quintiles
gen isq5=quintiles_tc==5
*gender of head
svy: prop deprivations , over(wave hhh_gender)
lincom [_prop_6]_subpop_5-[_prop_6]_subpop_6
*between 2009 and 2016
svy: prop deprivations , over(wave )
lincom [_prop_6]NBHS-[_prop_6]Wave3
lincom [_prop_4]NBHS-[_prop_4]Wave3
lincom [_prop_5]NBHS-[_prop_5]Wave3
***AMENITIES
*electricity
svy: mean electricity, over(wave )
svy: mean electricity, over(wave urban)
lincom [electricity]_subpop_6-[electricity]_subpop_7
*housing
svy: mean housing, over(wave )
svy: mean housing, over(wave urban)
lincom [housing]_subpop_6-[housing]_subpop_7
*crowding
svy: mean crowding, over(wave )
svy: mean crowding, over(wave urban)
lincom [crowding]_subpop_6-[crowding]_subpop_7
svy: mean crowding, over(dataset )
*** WASH
svy: mean wash, over(dataset wave )
lincom [wash]_subpop_6-[wash]_subpop_4
svy: mean improved_watersource improved_sanitation, over(dataset wave)
svy: mean improved_watersource, over(dataset wave urban)



use "${gsdTemp}/multidimensional_deprivation.dta", clear
svyset ea [pw=weight], strata(stratum)
*household size
svy: mean hhsize , over(dataset wave)
*number of children
use "${gsdData}/1-CleanTemp/hhm_analysis.dta", clear
gen child=inrange(age,0,18)
gen hhsize=1
collapse (sum) child hhsize, by(dataset wave state ea hh weight )
mean child hhsize [pw=weight], over(dataset wave)
























