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
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", nogen assert(master match) keepusing(poorPPP125_prob poorPPP_vulnerable_10_prob poorPPP_vulnerable_20_prob)
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
label values hhh_edu_dum lyesno
label var hhh_edu_dum "HH head has some education"
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


// Multidimensional deprivation 
*Education
use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
gen adult_noedu=(edu_level==0) if inrange(age,15,110)
gen child_noed=(hhm_edu_current==0) if inrange(age,6,14)
collapse (sum) adult_noedu (max) child_noed (count) adult_num=adult_noed , by(strata ea block hh)
gen adult_noed=(adult_noedu==adult_num)
drop adult_noedu adult_num
replace child_noed=0 if missing(child_noed)
label var child_noed "At least one child is not attending school, ages 6-14"
label var adult_noed "All adults have no education, ages 15+"
save "${gsdTemp}/hhm_deprivatons.dta", replace
*Information & transportation
use "${gsdData}/1-CleanOutput/assets.dta", clear
gen tvsat=(own==1) if inlist(itemid,28,31)
label var tvsat  "Household owns at least one TV/Satellite dish"
gen radio=(own==1) if inlist(itemid,26)
label var radio "Household owns at least one Radio"
gen mobile_phone=(own==1) if inlist(itemid,24)
label var mobile_phone "Household owns at least one Mobile phone"
gen computer=(own==1) if inlist(itemid,30)
label var mobile_phone "Household owns at least one computer"
gen transportation=(own==1) if inlist(itemid,34,35,36,37)
collapse (max) tvsat radio mobile_phone computer transportation, by(strata ea block hh)
save "${gsdTemp}/assets_deprivatons.dta", replace
*Dwelling characteristics
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
gen housing=inlist(housingtype,1,2,3,4) 
label var housing "Household lives in improved housing"
drop cook
gen cook=inlist(cook,6,8,10,11,12,13,14,15,19,1000)
label var cook "Household cooks with dung/wood/charcoal or grass"
order electricity, after(cook)
*Include education and assets data
merge 1:1 strata ea block hh using "${gsdTemp}/hhm_deprivatons.dta", assert(match) nogen
merge 1:1 strata ea block hh using "${gsdTemp}/assets_deprivatons.dta", keep(match master) nogen
qui foreach var of varlist tvsat radio mobile_phone computer transportation {
	replace `var'=0 if `var'==.
}
*Create dimensional indices
gen information=(mobile_phone==0 & tvsat==0 & radio==0 & computer==0)
label var information "Household deprived in dimension: information"
label var transportation "Household deprived in dimension: transportation"
gen assets=(information==1 | transportation==1)
label var assets "Household deprived in dimension: assets"
gen living_standards=(housing==0 | electricity==0 | cook==1)
label var living_standards "Household deprived in dimension: living standards"
gen education=(child_noed==1 | adult_noed==1)
label var education "Household deprived in dimension: education"
gen wash=(improved_sanitation==0 | improved_water==0)
label var wash "Household deprived in dimension: WASH"
egen deprivations=rowtotal(assets living_standards education wash poorPPP)
label var deprivations "Total number of dimensions household is deprived in"
egen deprivations2=rowtotal(assets living_standards education wash )
label var deprivations2 "Total number of dimensions household is deprived in, no poverty"
*Label and save in hh file
local labelling = "improved_sanitation improved_water electricity housing cook mobile_phone tvsat radio computer adult_noed child_noed information transportation assets education living_standards wash"
label val `labelling' lyn
keep strata ea block hh assets living_standards education wash deprivations deprivations2
save "${gsdTemp}/hh_mutltidimensional.dta", replace
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
merge 1:1 strata ea block hh using "${gsdTemp}/hh_mutltidimensional.dta", nogen assert(match) 
save "${gsdTemp}/hh_PA_Poverty_Profile.dta", replace



**************************************************
*   CROSS-COUNTRY COMPARISONS
**************************************************
*Prepare dataset with data from low-income countries in Africa
use "${gsdTemp}/WB_clean_all.dta", clear
merge 1:1 countryname using "${gsdData}/1-CleanInput/Country_comparison.dta", nogen
keep if countryname=="Somalia" | (country_aggr=="AFRICA" & income_cat=="L")

*Include GDP per head for Somali regions (Source: http://macropovertyoutlook.worldbank.org/mpo_widget/mpo_ssa.html)
replace gdppc_c = 535 if  countryname=="Somalia"
export excel using "${gsdOutput}/PA_Poverty_Profile_1.xls", replace firstrow(variables)

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

*Food poverty 
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_4.xls", svy sum c(mean poorPPPFood_prob se) sebnone f(3) npos(col) h2(Food poverty incidence by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_4.xls", svy sum c(mean poorPPPFood_prob se) sebnone f(3) npos(col) h2(Food poverty incidence by `var') append
}
svy: mean poorPPPFood_prob, over(hhh_gender)
test [poorPPPFood_prob]Female = [poorPPPFood_prob]Male
svy: mean poorPPPFood_prob, over(remit12m)
test [poorPPPFood_prob]Yes = [poorPPPFood_prob]No
svy: mean poorPPPFood_prob, over(migr_idp)
test [poorPPPFood_prob]Yes = [poorPPPFood_prob]No
svy: mean poorPPPFood_prob, over(drought_affected)
test [poorPPPFood_prob]Yes = [poorPPPFood_prob]No

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
qui tabout ind_profile hhh_edu_dum using "${gsdOutput}/PA_Poverty_Profile_21.xls", svy sum c(mean poorPPP_prob) sebnone f(3) npos(col) h1(Poverty incidence by HH head edu level) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' hhh_edu_dum using "${gsdOutput}/PA_Poverty_Profile_21.xls", svy sum c(mean poorPPP_prob) sebnone f(3) npos(col) h1(Poverty incidence & HH head edu level by `var') append
}
levelsof ind_profile, local(region) 
foreach i of local region {
	svy: mean poorPPP_prob if ind_profile==`i', over(hhh_edu_dum)
	test [poorPPP_prob]Yes = [poorPPP_prob]No
}
levelsof type, local(population) 
foreach i of local population {
	svy: mean poorPPP_prob if type==`i', over(hhh_edu_dum)
	test [poorPPP_prob]Yes = [poorPPP_prob]No
}
levelsof hhh_gender, local(gender) 
foreach i of local gender {
	svy: mean poorPPP_prob if hhh_gender==`i', over(hhh_edu_dum)
	test [poorPPP_prob]Yes = [poorPPP_prob]No
}
levelsof remit12m, local(remittances) 
foreach i of local remittances {
	svy: mean poorPPP_prob if remit12m==`i', over(hhh_edu_dum)
	test [poorPPP_prob]Yes = [poorPPP_prob]No
}
levelsof migr_idp, local(displacement) 
foreach i of local displacement {
	svy: mean poorPPP_prob if migr_idp==`i', over(hhh_edu_dum)
	test [poorPPP_prob]Yes = [poorPPP_prob]No
}
levelsof drought_affected, local(drought) 
foreach i of local drought {
	svy: mean poorPPP_prob if drought_affected==`i', over(hhh_edu_dum)
	test [poorPPP_prob]Yes = [poorPPP_prob]No
}



**************************************************
*   MULTIDIMENSIONAL DIMENSIONS
**************************************************
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)

*Dwelling characteristics 
qui tabout house_type_cat ind_profile  using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(House type by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected poorPPP {
	tabout house_type_cat `var' using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(House type by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout floor_material `var' using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(Floor material by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout roof_material `var' using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(Roof material by `var') append
}


*Access to services 
qui tabout improved_sanitation ind_profile  using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Improved sanitation by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout improved_sanitation `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Improved sanitation by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout improved_water `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Improved water by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout electricity `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Access to electricity by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout cook `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Cooking source by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout sewage `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Sewage by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout waste `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Waste by `var') append
}


*Distance to different services
qui tabout water_time ind_profile  using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to water by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout water_time `var' using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to water by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout tmarket `var' using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to market by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP {
	tabout thealth `var' using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to health clinic by `var') append
}


*Hunger
qui tabout hunger ind_profile  using "${gsdOutput}/PA_Poverty_Profile_25.xls", svy c(col) perc sebnone f(3) npos(col) h1(Hunger by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected poorPPP {
	tabout hunger `var' using "${gsdOutput}/PA_Poverty_Profile_25.xls", svy c(col) perc sebnone f(3) npos(col) h1(Hunger by `var') append
}


*Education and literacy 
use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean enrolled se) sebnone f(3) npos(col) h2(Enrolled by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean enrolled se) sebnone f(3) npos(col) h2(Enrolled by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean literacy se) sebnone f(3) npos(col) h2(Literacy by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout edu_level_broad `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy c(col) perc sebnone f(3) npos(col) h1(Educational level by `var') append
}


*Labor and employment 
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_27.xls", svy sum c(mean working_age se) sebnone f(3) npos(col) h2(Working age by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_27.xls", svy sum c(mean working_age se) sebnone f(3) npos(col) h2(Working age by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_27.xls", svy sum c(mean lfp_7d se) sebnone f(3) npos(col) h2(Labor force participation by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_27.xls", svy sum c(mean emp_7d se) sebnone f(3) npos(col) h2(Employment by `var') append
}



**************************************************
*   MULTIDIMENSIONAL DEPRIVATIONS AND INDEX
**************************************************
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)

*Multidimensional deprivations
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_28.xls", svy sum c(mean living_standards se) sebnone f(3) npos(col) h2(Deprivation living_standards by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_28.xls", svy sum c(mean living_standards se) sebnone f(3) npos(col) h2(Deprivation living_standards by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_28.xls", svy sum c(mean education se) sebnone f(3) npos(col) h2(Deprivation education by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_28.xls", svy sum c(mean wash se) sebnone f(3) npos(col) h2(Deprivation wash by `var') append
} 
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP  {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_28.xls", svy sum c(mean assets se) sebnone f(3) npos(col) h2(Deprivation assets by `var') append
} 

 
*Multidimensional deprivation index
qui tabout deprivations ind_profile using "${gsdOutput}/PA_Poverty_Profile_29.xls", svy c(col) perc sebnone f(3) npos(col) h1(Deprivations by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected poorPPP {
	tabout deprivations `var' using "${gsdOutput}/PA_Poverty_Profile_29.xls", svy c(col) perc sebnone f(3) npos(col) h1(Deprivations by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP {
	tabout deprivations2 `var' using "${gsdOutput}/PA_Poverty_Profile_29.xls", svy c(col) perc sebnone f(3) npos(col) h1(Deprivations (w/o Poverty) by `var') append
}



**************************************************
*   INTEGRATE ALL SHEETS INTO THE FINAL FILES
**************************************************

*Monetary poverty
import excel "${gsdOutput}/PA_Poverty_Profile_1.xls", sheet("Sheet1") firstrow case(lower) clear
export excel using "${gsdOutput}/PA_Poverty_Profile_1_v1.xls", sheetreplace sheet("Raw_Data_1") firstrow(variables)
erase "${gsdOutput}/PA_Poverty_Profile_1.xls"
foreach i of numlist 2/14 {
	insheet using "${gsdOutput}/PA_Poverty_Profile_`i'.xls", clear nonames tab
	export excel using "${gsdOutput}/PA_Poverty_Profile_1_v1.xls", sheetreplace sheet("Raw_Data_`i'") 
	erase "${gsdOutput}/PA_Poverty_Profile_`i'.xls"
}
*Poverty and indicators
foreach i of numlist 15/21 {
	insheet using "${gsdOutput}/PA_Poverty_Profile_`i'.xls", clear nonames tab
	export excel using "${gsdOutput}/PA_Poverty_Profile_2_v1.xls", sheetreplace sheet("Raw_Data_`i'") 
	erase "${gsdOutput}/PA_Poverty_Profile_`i'.xls"
}
*Multidimensional poverty 
foreach i of numlist 22/29 {
	insheet using "${gsdOutput}/PA_Poverty_Profile_`i'.xls", clear nonames tab
	export excel using "${gsdOutput}/PA_Poverty_Profile_3_v1.xls", sheetreplace sheet("Raw_Data_`i'") 
	erase "${gsdOutput}/PA_Poverty_Profile_`i'.xls"
}
