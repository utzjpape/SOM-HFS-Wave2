*Chapter 1 of the Poverty Assessment: Poverty Profile 

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
replace improved_sanitation=0 if share_facility==1
replace improved_sanitation=. if toilet>=.
label values improved_sanitation lyesno
label var improved_sanitation "HH has improved sanitation"
gen improved_water=(inlist(water,1,2,3))
replace improved_water=. if water>=.
label values improved_water lyesno
label var improved_water "HH has improved source of drinking water"
*Drought affected households
gen drought_affected=(shock_1==1 | shock_1==3 | shock_1==4 | shock_1==5 | shock_1==8 | shock_1==9 | shock_2==1 | shock_2==3 | shock_2==4 | shock_2==5 | shock_2==8 | shock_2==9)
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
*Include final regional breakdown
rename ind_profile ind_profile_old
recode ind_profile_old (3=2) (7=2) (9=2) (11=2) (4=3) (5=3) (8=3) (12=3) (6=4) (13=5), gen(ind_profile)
label define lind_profilef 1 "Mogadishu" 2 "Other Urban" 3 "Rural" 4 "IDP Settlements" 5 "Nomadic population"
label values ind_profile lind_profilef
label var ind_profile "Indicator of regional breakdown"
order ind_profile, after(ind_profile_old)
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
egen deprivations=rowtotal(living_standards education wash poorPPP)
label var deprivations "Total number of dimensions household is deprived in"
egen deprivations2=rowtotal(assets living_standards education wash )
label var deprivations2 "Total number of dimensions household is deprived (w/ assets, no poverty)"
egen deprivations3=rowtotal(living_standards education wash )
label var deprivations3 "Total number of dimensions household is deprived in, no poverty"
*Label and save in hh file
local labelling = "improved_sanitation improved_water electricity housing cook mobile_phone tvsat radio computer adult_noed child_noed information transportation assets education living_standards wash"
label val `labelling' lyn
keep strata ea block hh assets living_standards education wash deprivations deprivations2 deprivations3
save "${gsdTemp}/hh_mutltidimensional.dta", replace
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
merge 1:1 strata ea block hh using "${gsdTemp}/hh_mutltidimensional.dta", nogen assert(match) 
gen dep_p_living=(poorPPP==1 & living_standards==1)
label var dep_p_living "HH deprived in poverty and living standards"
label values dep_p_living lyesno
gen dep_p_edu=(poorPPP==1 & education==1)
label var dep_p_edu "HH deprived in poverty and education"
label values dep_p_edu lyesno
gen dep_p_wash=(poorPPP==1 & wash==1)
label var dep_p_wash "HH deprived in poverty and WASH"
label values dep_p_wash lyesno
gen dep_p_living_edu=(poorPPP==1 & living_standards==1 & education==1)
label var dep_p_living_edu "HH deprived in poverty, living standards and education"
label values dep_p_living_edu lyesno
gen dep_p_living_wash=(poorPPP==1 & living_standards==1 & wash==1)
label var dep_p_living_wash "HH deprived in poverty, living standards and WASH" 
label values dep_p_living_wash lyesno
gen dep_p_edu_wash=(poorPPP==1 & education==1 & wash==1)
label var dep_p_edu_wash "HH deprived in poverty, education and WASH"
label values dep_p_edu_wash lyesno
gen dep_p_all=(poorPPP==1 & education==1 & wash==1 & living_standards==1)
label var dep_p_all "HH deprived in poverty and all other dimensions"
label values dep_p_all lyesno
*Include final regional breakdown
rename ind_profile ind_profile_old
recode ind_profile_old (3=2) (7=2) (9=2) (11=2) (4=3) (5=3) (8=3) (12=3) (6=4) (13=5), gen(ind_profile)
label define lind_profilef 1 "Mogadishu" 2 "Other Urban" 3 "Rural" 4 "IDP Settlements" 5 "Nomadic population"
label values ind_profile lind_profilef
label var ind_profile "Indicator of regional breakdown"
order ind_profile, after(ind_profile_old)
save "${gsdTemp}/hh_PA_Poverty_Profile.dta", replace



**************************************************
*   CROSS-COUNTRY COMPARISONS
**************************************************
*Prepare dataset with data from low-income countries in Africa
use "${gsdTemp}/WB_clean_all.dta", clear
merge 1:1 countryname using "${gsdData}/1-CleanInput/Country_comparison.dta", nogen
keep if countryname=="Somalia" | (country_aggr=="AFRICA" & income_cat=="L")

*Include GDP per head for Somali regions (Source: http://www.worldbank.org/en/country/somalia/overview)
replace gdppc_c = 450 if  countryname=="Somalia"
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
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_3.xls", svy sum c(mean poorPPP_prob se ub lb) sebnone f(3) npos(col) h2(Poverty incidence by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_3.xls", svy sum c(mean poorPPP_prob se ub lb) sebnone f(3) npos(col) h2(Poverty incidence by `var') append
}
qui tabout ind_profile_old using "${gsdOutput}/PA_Poverty_Profile_3.xls", svy sum c(mean poorPPP_prob se ub lb) sebnone f(3) npos(col) h2(Poverty incidence by ind_profile old) append
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
clmethod(custom) clnumber(5) clbreaks(0 20 40 60 80 100) ndlabel(Not covered by the SHFS 2017) legstyle(2) legend(position(4)) ///
ndfcolor(gs9) title("Poverty Incidence") subtitle("% of population below US$ 1.9 (PPP) per day")  
spmap poorPPP_prob using "${gsdData}/1-CleanInput/SOM_coord.dta", id(id_map) fcolor(Reds) ///
clmethod(custom) clnumber(5) clbreaks(0 20 40 60 80 100) ndlabel(Not covered by the SHFS 2017) legstyle(2) legend(position(4)) ndfcolor(gs9)  subtitle("% of population")   
graph save Graph "${gsdOutput}/Map_Poverty.gph", replace

*=================================================
*=================================================
import excel "${gsdDataRaw}/Flowminder_Deliverable_v1.xlsx", sheet("Flowminder") firstrow case(lower) clear
rename poverty poorPPP_prob
replace poorPPP_prob=poorPPP_prob*100
merge 1:1 id_map using "${gsdData}/1-CleanInput/SOM_db_2.dta", nogen keepusing(ISO)

spmap poorPPP_prob using "${gsdData}/1-CleanInput/SOM_coord_2.dta", id(id_map) fcolor(YlOrRd) ///
clmethod(custom) clnumber(5) clbreaks(0 20 40 60 80 100) ndlabel(Not covered by the SHFS 2017) legstyle(2) legend(position(4)) ndfcolor(gs9)  subtitle("% of population")   
graph save Graph "${gsdOutput}/Map_Poverty_2.gph", replace

*=================================================
*=================================================
/*
import excel "C:\Users\WB484006\OneDrive - WBG\Code\SOM\Wave 2\Output\Flowminder_Deliverable_v1.xlsx", sheet("Collapsed") firstrow clear
rename poverty poorPPP_prob
replace poorPPP_prob=poorPPP_prob*100
merge 1:1 id_map using "${gsdData}/1-CleanInput/SOM_db.dta", nogen keepusing(ISO)

spmap poorPPP_prob using "${gsdData}/1-CleanInput/SOM_coord.dta", id(id_map) fcolor(YlOrRd) ///
clmethod(custom) clnumber(5) clbreaks(0 20 40 60 80 100) ndlabel(Not covered by the SHFS 2017) legstyle(2) legend(position(4)) ndfcolor(gs9)  subtitle("% of population")   
*/
restore


*=================================================
*=================================================


*Food poverty 
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_4.xls", svy sum c(mean poorPPPFood_prob se ub lb) sebnone f(3) npos(col) h2(Food poverty incidence by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_4.xls", svy sum c(mean poorPPPFood_prob se ub lb) sebnone f(3) npos(col) h2(Food poverty incidence by `var') append
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
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_5.xls", svy sum c(mean poorPPP_prob_AE se ub lb) sebnone f(3) npos(col) h2(Poverty incidence AE by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_5.xls", svy sum c(mean poorPPP_prob_AE se ub lb) sebnone f(3) npos(col) h2(Poverty incidence AE by `var') append
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
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_6.xls", svy sum c(mean poorPPP_vulnerable_10_prob se ub lb) sebnone f(3) npos(col) h2(Vulnerable w/10% shock by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_6.xls", svy sum c(mean poorPPP_vulnerable_10_prob se ub lb) sebnone f(3) npos(col) h2(Vulnerable w/10% shocok by `var') append
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
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_7.xls", svy sum c(mean poorPPP_vulnerable_20_prob se ub lb) sebnone f(3) npos(col) h2(Vulnerable w/20% shock by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_7.xls", svy sum c(mean poorPPP_vulnerable_20_prob se ub lb) sebnone f(3) npos(col) h2(Vulnerable w/20% shocok by `var') append
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
qui tabout ind_profile gender using "${gsdOutput}/PA_Poverty_Profile_8.xls" if child==1, svy sum c(mean poorPPP_prob se ub lb) sebnone f(3) npos(col) h1(Child poverty by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' gender using "${gsdOutput}/PA_Poverty_Profile_8.xls" if child==1, svy sum c(mean poorPPP_prob se ub lb) sebnone f(3) npos(col) h1(Child poverty incidence by `var') append
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
use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
tabout ind_profile gender using "${gsdOutput}/PA_Poverty_Profile_9.xls" if youth==1, svy sum c(mean poorPPP_prob se ub lb) sebnone f(3) npos(col) h1(Youth poverty by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' gender using "${gsdOutput}/PA_Poverty_Profile_9.xls" if youth==1, svy sum c(mean poorPPP_prob se ub lb) sebnone f(3) npos(col) h1(Youth poverty incidence by `var') append
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
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_10.xls", svy sum c(mean pgi se ub lb) sebnone f(3) npos(col) h2(Poverty gap by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_10.xls", svy sum c(mean pgi se ub lb) sebnone f(3) npos(col) h2(Poverty gap by `var') append
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
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_11.xls", svy sum c(mean pseverity se ub lb) sebnone f(3) npos(col) h2(Poverty severity by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_11.xls", svy sum c(mean pseverity se ub lb) sebnone f(3) npos(col) h2(Poverty severity by `var') append
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
	fastgini tc_imp [pweight=hhweight] if ind_profile==`i', jk
	return list 
	gen gini_`i'=r(gini)
	gen gini_se_`i'=r(se)
    qui tabout gini_`i' using "${gsdOutput}/PA_Poverty_Profile_12.xls", svy c(freq) sebnone f(3) npos(col) h2(GINI coefficient for ind_profile `i') append
    qui tabout gini_se_`i' using "${gsdOutput}/PA_Poverty_Profile_12.xls", svy c(freq) sebnone f(3) npos(col) h2(S.E of GINI coefficient for ind_profile `i') append
    drop gini_`i' gini_se_`i'
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
levelsof ind_profile_old, local(region) 
qui foreach i of local region {
	fastgini tc_imp [pweight=hhweight] if ind_profile_old==`i'
	return list 
	gen gini_`i'=r(gini)
    qui tabout gini_`i' using "${gsdOutput}/PA_Poverty_Profile_12.xls", svy c(freq) sebnone f(3) npos(col) h2(GINI coefficient for ind_profile old `i') append
    drop gini_`i'
}

*Average total imputed consumption by quintile 
qui tabout quintiles_tc using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by quintile - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if ind_profile==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by quintile - region `i' ) append
	drop quintiles_tc_`i' 
}
levelsof type, local(population) 
qui foreach i of local population {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if type==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by quintile - type `i' ) append
	drop quintiles_tc_`i' 
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if hhh_gender==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by quintile - hhh_gender `i' ) append
	drop quintiles_tc_`i' 
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if remit12m==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by quintile - remit12m `i' ) append
	drop quintiles_tc_`i' 
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if migr_idp==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by quintile - migr_idp `i' ) append
	drop quintiles_tc_`i' 
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if drought_affected==`i', n(5) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by quintile - drought_affected `i' ) append
	drop quintiles_tc_`i' 
}


*Average total imputed consumption by top 60% vs. bottom 40%
gen top_bottom=(quintiles_tc>=1 & quintiles_tc<=2)
qui tabout top_bottom using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by bottom 40/top 60 - overall ) append
levelsof ind_profile, local(region) 
qui foreach i of local region {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if ind_profile==`i', n(5) 
	gen top_bottom_`i'=(quintiles_tc_`i'>=1 & quintiles_tc_`i'<=2) if ind_profile==`i'
	qui tabout top_bottom_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by bottom 40/top 60 - region `i' ) append
	drop quintiles_tc_`i' top_bottom_`i'
}
levelsof type, local(population) 
qui foreach i of local population {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if type==`i', n(5) 
	gen top_bottom_`i'=(quintiles_tc_`i'>=1 & quintiles_tc_`i'<=2) if type==`i'
	qui tabout top_bottom_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by bottom 40/top 60 - type `i' ) append
	drop quintiles_tc_`i' top_bottom_`i'
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if hhh_gender==`i', n(5) 
	gen top_bottom_`i'=(quintiles_tc_`i'>=1 & quintiles_tc_`i'<=2) if hhh_gender==`i'
	qui tabout top_bottom_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by bottom 40/top 60 - hhh_gender `i' ) append
	drop quintiles_tc_`i' top_bottom_`i'
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if remit12m==`i', n(5) 
	gen top_bottom_`i'=(quintiles_tc_`i'>=1 & quintiles_tc_`i'<=2) if remit12m==`i'
	qui tabout top_bottom_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by bottom 40/top 60 - remit12m `i' ) append
	drop quintiles_tc_`i' top_bottom_`i'
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if migr_idp==`i', n(5) 
	gen top_bottom_`i'=(quintiles_tc_`i'>=1 & quintiles_tc_`i'<=2) if migr_idp==`i'
	qui tabout top_bottom_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by bottom 40/top 60 - migr_idp `i' ) append
	drop quintiles_tc_`i' top_bottom_`i'
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if drought_affected==`i', n(5) 
	gen top_bottom_`i'=(quintiles_tc_`i'>=1 & quintiles_tc_`i'<=2) if drought_affected==`i'
	qui tabout top_bottom_`i' using "${gsdOutput}/PA_Poverty_Profile_13.xls", svy sum c(mean tc_imp se ub lb) sebnone f(3) npos(col) h2(Avg. consumption by bottom 40/top 60 - drought_affected `i' ) append
	drop quintiles_tc_`i' top_bottom_`i'
}


*Distribution of average total consumption
xtile quintiles_tc_all = tc_imp [pweight=hhweight] , n(100) 
qui tabout quintiles_tc_all using "${gsdOutput}/PA_Poverty_Profile_14.xls", svy sum c(mean tc_imp ub lb) sebnone f(3) npos(col) h2(Avg. consumption by 100 quintile - overall) replace
drop quintiles_tc_all
levelsof type, local(population) 
qui foreach i of local population {
	xtile quintiles_tc_`i' = tc_imp [pweight=hhweight] if type==`i', n(100) 
	qui tabout quintiles_tc_`i' using "${gsdOutput}/PA_Poverty_Profile_14.xls", svy sum c(mean tc_imp ub lb) sebnone f(3) npos(col) h2(Avg. consumption by 100 quintile - type `i' ) append
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
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_15.xls" if type==`i', svy sum c(mean hhsize) sebnone f(3) npos(col) h2(HH size for type `i' ) append
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
svy: mean hhsize, over(poorPPP) 
test [hhsize]_subpop_1 = [hhsize]Poor
levelsof ind_profile, local(region) 
foreach i of local region {
	svy: mean hhsize if ind_profile==`i', over(poorPPP) 
	test [hhsize]_subpop_1 = [hhsize]Poor
}
levelsof type, local(population) 
foreach i of local population {
	svy: mean hhsize if type==`i', over(poorPPP)
	test [hhsize]_subpop_1 = [hhsize]Poor
}
levelsof hhh_gender, local(gender) 
foreach i of local gender {
	svy: mean hhsize if hhh_gender==`i', over(poorPPP)
	test [hhsize]_subpop_1 = [hhsize]Poor
}
levelsof remit12m, local(remittances) 
foreach i of local remittances {
	svy: mean hhsize if remit12m==`i', over(poorPPP)
	test [hhsize]_subpop_1 = [hhsize]Poor
}
levelsof migr_idp, local(displacement) 
foreach i of local displacement {
	svy: mean hhsize if migr_idp==`i', over(poorPPP)
	test [hhsize]_subpop_1 = [hhsize]Poor
}
levelsof drought_affected, local(drought) 
foreach i of local drought {
	svy: mean hhsize if drought_affected==`i', over(poorPPP)
	test [hhsize]_subpop_1 = [hhsize]Poor
}


*Male headed households 
qui tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls", svy sum c(mean hhh_gender lb ub) sebnone f(3) npos(col) h2(Share of male headed HHs - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if ind_profile==`i', svy sum c(mean hhh_gender lb ub) sebnone f(3) npos(col) h2(Share of male headed HHs for ind_profile `i' ) append
}
levelsof type, local(population) 
qui foreach i of local population {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if type==`i', svy sum c(mean hhh_gender lb ub) sebnone f(3) npos(col) h2(Share of male headed HHs for type `i' ) append
}
levelsof hhh_gender, local(gender) 
qui foreach i of local gender {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if hhh_gender==`i', svy sum c(mean hhh_gender lb ub) sebnone f(3) npos(col) h2(Share of male headed HHs for hhh_gender `i' ) append
}
levelsof remit12m, local(remittances) 
qui foreach i of local remittances {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if remit12m==`i', svy sum c(mean hhh_gender lb ub) sebnone f(3) npos(col) h2(Share of male headed HHs for remit12m `i' ) append
}
levelsof migr_idp, local(displacement) 
qui foreach i of local displacement {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if migr_idp==`i', svy sum c(mean hhh_gender lb ub) sebnone f(3) npos(col) h2(Share of male headed HHs for migr_idp `i' ) append
}
levelsof drought_affected, local(drought) 
qui foreach i of local drought {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_16.xls" if drought_affected==`i', svy sum c(mean hhh_gender lb ub) sebnone f(3) npos(col) h2(Share of male headed HHs for drought_affected `i' ) append
}

svy: mean hhh_gender, over(remit12m)
test [hhh_gender]Yes = [hhh_gender]No
svy: mean hhh_gender, over(migr_idp)
test [hhh_gender]Yes = [hhh_gender]No
svy: mean hhh_gender, over(drought_affected)
test [hhh_gender]Yes = [hhh_gender]No


*Dependency ratio
qui tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_17.xls", svy sum c(mean age_dependency_ratio) sebnone f(3) npos(col) h2(Age dependency ratio - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_17.xls" if ind_profile==`i', svy sum c(mean age_dependency_ratio) sebnone f(3) npos(col) h2(Age dependency ratio for ind_profile `i' ) append
}
levelsof type, local(population) 
qui foreach i of local population {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_17.xls" if type==`i', svy sum c(mean age_dependency_ratio) sebnone f(3) npos(col) h2(Age dependency ratio for type `i' ) append
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
qui tabout quintiles_tc using "${gsdOutput}/PA_Poverty_Profile_17.xls", svy sum c(mean age_dependency_ratio se) sebnone f(3) npos(col) h2(Age dependency ratio - by quintile) append

svy: mean age_dependency_ratio, over(poorPPP) 
test [age_dependency_ratio]_subpop_1 = [age_dependency_ratio]Poor
levelsof ind_profile, local(region) 
foreach i of local region {
	svy: mean age_dependency_ratio if ind_profile==`i', over(poorPPP) 
	test [age_dependency_ratio]_subpop_1 = [age_dependency_ratio]Poor
}
levelsof type, local(population) 
foreach i of local population {
	svy: mean age_dependency_ratio if type==`i', over(poorPPP)
	test [age_dependency_ratio]_subpop_1 = [age_dependency_ratio]Poor
}
levelsof hhh_gender, local(gender) 
foreach i of local gender {
	svy: mean age_dependency_ratio if hhh_gender==`i', over(poorPPP)
	test [age_dependency_ratio]_subpop_1 = [age_dependency_ratio]Poor
}
levelsof remit12m, local(remittances) 
foreach i of local remittances {
	svy: mean age_dependency_ratio if remit12m==`i', over(poorPPP)
	test [age_dependency_ratio]_subpop_1 = [age_dependency_ratio]Poor
}
levelsof migr_idp, local(displacement) 
foreach i of local displacement {
	svy: mean age_dependency_ratio if migr_idp==`i', over(poorPPP)
	test [age_dependency_ratio]_subpop_1 = [age_dependency_ratio]Poor
}
levelsof drought_affected, local(drought) 
foreach i of local drought {
	svy: mean age_dependency_ratio if drought_affected==`i', over(poorPPP)
	test [age_dependency_ratio]_subpop_1 = [age_dependency_ratio]Poor
}


*Number of children
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
merge 1:m strata ea block hh using "${gsdTemp}/hhm_PA_Poverty_Profile.dta", nogen assert(match) keepusing(age_dependency_ratio)
svyset ea [pweight=weight], strata(strata) singleunit(centered)

qui tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_18.xls", svy sum c(mean no_children) sebnone f(3) npos(col) h2(Number of children - overall ) replace
levelsof ind_profile, local(region) 
qui foreach i of local region {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_18.xls" if ind_profile==`i', svy sum c(mean no_children) sebnone f(3) npos(col) h2(Number of children for ind_profile `i' ) append
}
levelsof type, local(population) 
qui foreach i of local population {
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_18.xls" if type==`i', svy sum c(mean no_children) sebnone f(3) npos(col) h2(Number of children for type `i' ) append
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
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_19.xls" if type==`i', svy sum c(mean no_adults) sebnone f(3) npos(col) h2(Number of adults for type `i' ) append
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
	tabout poorPPP using "${gsdOutput}/PA_Poverty_Profile_20.xls" if type==`i', svy sum c(mean no_old_age) sebnone f(3) npos(col) h2(Number of elderly for type `i' ) append
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
svyset ea [pweight=weight], strata(strata) singleunit(centered)
qui tabout ind_profile poorPPP using "${gsdOutput}/PA_Poverty_Profile_21.xls", svy sum c(mean hhh_edu_dum lb ub) sebnone f(3) npos(col) h1(HH head edu level by poor status and ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' poorPPP using "${gsdOutput}/PA_Poverty_Profile_21.xls", svy sum c(mean hhh_edu_dum lb ub) sebnone f(3) npos(col) h1(HH head edu level by poor status and `var') append
}
levelsof ind_profile, local(region) 
foreach i of local region {
	svy: mean hhh_edu_dum if ind_profile==`i', over(poorPPP)
	test [hhh_edu_dum]_subpop_1 = [hhh_edu_dum]Poor
}
levelsof type, local(population) 
foreach i of local population {
	svy: mean hhh_edu_dum if type==`i', over(poorPPP)
	test [hhh_edu_dum]_subpop_1 = [hhh_edu_dum]Poor
}
levelsof hhh_gender, local(gender) 
foreach i of local gender {
	svy: mean hhh_edu_dum if hhh_gender==`i', over(poorPPP)
	test [hhh_edu_dum]_subpop_1 = [hhh_edu_dum]Poor
}
levelsof remit12m, local(remittances) 
foreach i of local remittances {
	svy: mean hhh_edu_dum if remit12m==`i', over(poorPPP)
	test [hhh_edu_dum]_subpop_1 = [hhh_edu_dum]Poor
}
levelsof migr_idp, local(displacement) 
foreach i of local displacement {
	svy: mean hhh_edu_dum if migr_idp==`i', over(poorPPP)
	test [hhh_edu_dum]_subpop_1 = [hhh_edu_dum]Poor
}
levelsof drought_affected, local(drought) 
foreach i of local drought {
	svy: mean hhh_edu_dum if drought_affected==`i', over(poorPPP)
	test [hhh_edu_dum]_subpop_1 = [hhh_edu_dum]Poor
}



**************************************************
*   MULTIDIMENSIONAL DIMENSIONS
**************************************************
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)

*Dwelling characteristics 
qui tabout house_type_cat ind_profile  using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(House type by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected  {
	tabout house_type_cat `var' using "${gsdOutput}/PA_Poverty_Profile_22.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(House type (poor) by `var') append
	tabout house_type_cat `var' using "${gsdOutput}/PA_Poverty_Profile_22.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(House type (non-poor) by `var') append
}
qui tabout floor_material ind_profile using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(Floor material by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected  {
	tabout floor_material `var' using "${gsdOutput}/PA_Poverty_Profile_22.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Floor material (poor) by `var') append
	tabout floor_material `var' using "${gsdOutput}/PA_Poverty_Profile_22.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Floor material (non-poor) by `var') append
}
qui tabout roof_material ind_profile using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(Roof material by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected  {
	tabout roof_material `var' using "${gsdOutput}/PA_Poverty_Profile_22.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Roof material (poor) by `var') append
	tabout roof_material `var' using "${gsdOutput}/PA_Poverty_Profile_22.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Roof material (non-poor) by `var') append
}
qui tabout house_type_cat type using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(House type by type) append
qui tabout house_type_cat poorPPP using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(House type by poverty status) append
qui tabout floor_material type using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(House type by type) append
qui tabout floor_material poorPPP using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(House type by poverty status) append
qui tabout roof_material type using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(House type by type) append
qui tabout roof_material poorPPP using "${gsdOutput}/PA_Poverty_Profile_22.xls", svy c(col) perc sebnone f(3) npos(col) h1(House type by poverty status) append


*Access to services 
qui tabout improved_sanitation ind_profile  using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Improved sanitation by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected   {
	tabout improved_sanitation `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Improved sanitation (poor) by `var') append
	tabout improved_sanitation `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Improved sanitation (non-poor) by `var') append
}
qui tabout improved_water ind_profile using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Improved water by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected  {
	tabout improved_water `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Improved water (poor) by `var') append
	tabout improved_water `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Improved water (non-poor) by `var') append
}
qui tabout electricity ind_profile using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Access to electricity by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout electricity `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Access to electricity (poor) by `var') append
	tabout electricity `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Access to electricity (non-poor) by `var') append
}
qui tabout cook ind_profile using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Cooking source by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected   {
	tabout cook `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Cooking source (poor) by `var') append
	tabout cook `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Cooking source (non-poor) by `var') append
}
qui tabout sewage ind_profile using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Sewage by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout sewage `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Sewage (poor) by `var') append
	tabout sewage `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Sewage (non-poor) by `var') append
}
qui tabout waste ind_profile using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Waste by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout waste `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Waste (poor) by `var') append
	tabout waste `var' using "${gsdOutput}/PA_Poverty_Profile_23.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Waste (non-poor) by `var') append
}
qui tabout improved_sanitation type using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Improved sanitation by type) append
qui tabout improved_water type using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Improved water by type) append
qui tabout electricity type using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Access to electricity by type) append
qui tabout cook type using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Cooking source by type) append
qui tabout cook poorPPP using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy c(col) perc sebnone f(3) npos(col) h1(Cooking source by poverty) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy sum c(mean improved_sanitation lb ub) sebnone f(3) npos(col) h1(Ind_profile w/s.e. for improved sanitation) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy sum c(mean improved_water lb ub) sebnone f(3) npos(col) h1(Ind_profile w/s.e. for improved_water) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy sum c(mean electricity lb ub) sebnone f(3) npos(col) h1(Ind_profile w/s.e. for electricity) append
qui tabout ind_profile poorPPP using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy sum c(mean improved_sanitation lb ub) sebnone f(3) npos(col) h1(Ind_profile w/s.e. for improved sanitation) append
qui tabout ind_profile poorPPP using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy sum c(mean improved_water lb ub) sebnone f(3) npos(col) h1(Ind_profile w/s.e. for improved_water) append
qui tabout ind_profile poorPPP using "${gsdOutput}/PA_Poverty_Profile_23.xls", svy sum c(mean electricity lb ub) sebnone f(3) npos(col) h1(Ind_profile w/s.e. for electricity) append



*Distance to different services
qui tabout water_time ind_profile using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to water by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout water_time `var' using "${gsdOutput}/PA_Poverty_Profile_24.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to water (poor) by `var') append
	tabout water_time `var' using "${gsdOutput}/PA_Poverty_Profile_24.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to water (non-poor) by `var') append
}
qui tabout tmarket ind_profile using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to market by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout tmarket `var' using "${gsdOutput}/PA_Poverty_Profile_24.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to market (poor) by `var') append
	tabout tmarket `var' using "${gsdOutput}/PA_Poverty_Profile_24.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to market (non-poor) by `var') append
}
qui tabout thealth ind_profile using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to health clinic by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout thealth `var' using "${gsdOutput}/PA_Poverty_Profile_24.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to health clinic (poor) by `var') append
	tabout thealth `var' using "${gsdOutput}/PA_Poverty_Profile_24.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to health clinic (non-poor) by `var') append
}
qui tabout water_time type using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to water by type) append
qui tabout tmarket type using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to market by type) append
qui tabout thealth type using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy c(col) perc sebnone f(3) npos(col) h1(Time/Distance to health clinic by type) append
gen more_30_water=(water_time>=4) if !missing(water_time)
gen more_30_market=(tmarket>=4) if !missing(tmarket)
gen more_30_health=(thealth>=4) if !missing(thealth)
gen more_30_edu=(tedu>=4) if !missing(tedu) 
qui tabout ind_profile poorPPP using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy sum c(mean more_30_water lb ub) sebnone f(3) npos(col) h1(Ind_profile and poor w/s.e. for water_time) append
qui tabout ind_profile poorPPP using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy sum c(mean more_30_market lb ub) sebnone f(3) npos(col) h1(Ind_profile and poor w/s.e. for tmarket) append
qui tabout ind_profile poorPPP using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy sum c(mean more_30_health lb ub) sebnone f(3) npos(col) h1(Ind_profile and poor w/s.e. for thealth) append
qui tabout ind_profile poorPPP using "${gsdOutput}/PA_Poverty_Profile_24.xls", svy sum c(mean more_30_edu lb ub) sebnone f(3) npos(col) h1(Ind_profile and poor w/s.e. for school) append


*Hunger
qui tabout hunger ind_profile  using "${gsdOutput}/PA_Poverty_Profile_25.xls", svy c(col) perc sebnone f(3) npos(col) h1(Hunger by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout hunger `var' using "${gsdOutput}/PA_Poverty_Profile_25.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Hunger (poor) by `var') append
	tabout hunger `var' using "${gsdOutput}/PA_Poverty_Profile_25.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Hunger (non-poor) by `var') append
}
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout hunger `var' using "${gsdOutput}/PA_Poverty_Profile_25.xls", svy c(col) perc sebnone f(3) npos(col) h1(Hunger (all) by `var') append
}
gen hunger_dum=(hunger>1) if !missing(hunger)
label values hunger_dum lyesno
qui tabout ind_profile poorPPP using "${gsdOutput}/PA_Poverty_Profile_25.xls", svy sum c(mean hunger_dum lb ub) sebnone f(3) npos(col) h1(Ind_profile and poor w/s.e. for hunger_dum) append
qui foreach var of varlist hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_25.xls", svy sum c(mean hunger_dum lb ub) sebnone f(3) npos(col) h1(`var' w/s.e. for hunger_dum) append
}

svy: mean hunger_dum, over(poorPPP)
test [hunger_dum]Poor = [hunger_dum]_subpop_1
svy: mean hunger_dum, over(hhh_gender)
test [hunger_dum]Female = [hunger_dum]Male
svy: mean hunger_dum, over(remit12m)
test [hunger_dum]No = [hunger_dum]Yes
svy: mean hunger_dum, over(migr_idp)
test [hunger_dum]No = [hunger_dum]Yes
svy: mean hunger_dum, over(drought_affected)
test [hunger_dum]No = [hunger_dum]Yes
levelsof hhh_gender, local(gender) 
foreach i of local gender {
	svy: mean hunger_dum if hhh_gender==`i', over(poorPPP)
	test [hunger_dum]Poor = [hunger_dum]_subpop_1
}
levelsof remit12m, local(remittances) 
foreach i of local remittances {
	svy: mean hunger_dum if remit12m==`i', over(poorPPP)
	test [hunger_dum]Poor = [hunger_dum]_subpop_1
}
levelsof migr_idp, local(displacement) 
foreach i of local displacement {
	svy: mean hunger_dum if migr_idp==`i', over(poorPPP)
	test [hunger_dum]Poor = [hunger_dum]_subpop_1
}
levelsof drought_affected, local(drought) 
foreach i of local drought {
	svy: mean hunger_dum if drought_affected==`i', over(poorPPP)
	test [hunger_dum]Poor = [hunger_dum]_subpop_1
}



**************************************************
*   EDUCATION AND LABOR MARKET
**************************************************
use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
merge m:1 strata ea block hh using "${gsdTemp}/hh_PA_Poverty_Profile.dta", assert(match) nogen keepusing(hhh_edu_dum pliteracy hhsize)
svyset ea [pweight=weight], strata(strata) singleunit(centered)

qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean enrolled se) sebnone f(3) npos(col) h2(Enrolled by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls" if poorPPP==1, svy sum c(mean enrolled se) sebnone f(3) npos(col) h2(Enrolled (poor) by `var') append
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls" if poorPPP==0, svy sum c(mean enrolled se) sebnone f(3) npos(col) h2(Enrolled (non-poor) by `var') append
}
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_26.xls" if age>=15, svy sum c(mean literacy se) sebnone f(3) npos(col) h2(Literacy by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls" if poorPPP==1 & age>=15, svy sum c(mean literacy se) sebnone f(3) npos(col) h2(Literacy (poor) by `var') append
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls" if poorPPP==0 & age>=15, svy sum c(mean literacy se) sebnone f(3) npos(col) h2(Literacy (non-poor) by `var') append
}
qui tabout edu_level_broad ind_profile using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy c(col) perc sebnone f(3) npos(col) h1(Educational level by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout edu_level_broad `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls" if poorPPP==1, svy c(col) perc sebnone f(3) npos(col) h1(Educational level (poor) by `var') append
	tabout edu_level_broad `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls" if poorPPP==0, svy c(col) perc sebnone f(3) npos(col) h1(Educational level (non-poor) by `var') append
}
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean enrolled se) sebnone f(3) npos(col) h2(Enrolled (all) by `var') append
}
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls" if age>=15, svy sum c(mean literacy se) sebnone f(3) npos(col) h2(Literacy (all) by `var') append
}
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout edu_level_broad `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy c(col) perc sebnone f(3) npos(col) h1(Educational level (all) by `var') append
}
gen no_educ=(edu_level_broad==0) if !missing(edu_level_broad)
qui tabout ind_profile poorPPP using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean no_educ lb ub) sebnone f(3) npos(col) h1(Ind_profile and poor w/s.e. for no edu) append
qui tabout hhh_gender using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean no_educ lb ub) sebnone f(3) npos(col) h1(Ind_profile and poor w/s.e. for no edu) append
qui tabout remit12m using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean no_educ lb ub) sebnone f(3) npos(col) h1(Ind_profile and poor w/s.e. for no edu) append
qui tabout migr_idp using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean no_educ lb ub) sebnone f(3) npos(col) h1(Ind_profile and poor w/s.e. for no edu) append
qui tabout drought_affected using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean no_educ lb ub) sebnone f(3) npos(col) h1(Ind_profile and poor w/s.e. for no edu) append
svy: mean enrolled, over(hhh_edu_dum)
test [enrolled]Yes = [enrolled]No
svy: mean enrolled if hhh_gender==0, over(hhh_edu_dum)
test [enrolled]Yes = [enrolled]No
svy: mean enrolled if hhh_gender==1, over(hhh_edu_dum)
test [enrolled]Yes = [enrolled]No

*Primary & secondary enrolment by gender and region/characteristic
qui foreach var of varlist ind_profile hhh_gender poorPPP {
	tabout `var' gender using "${gsdOutput}/PA_Poverty_Profile_26.xls" if pschool_age==1, svy sum c(mean enrolled se) sebnone f(3) npos(col) h1(Primary enrolled by gender and `var') append
}
qui foreach var of varlist ind_profile hhh_gender poorPPP {
	tabout `var' gender using "${gsdOutput}/PA_Poverty_Profile_26.xls" if sschool_age==1, svy sum c(mean enrolled se) sebnone f(3) npos(col) h1(Secondary enrolled by gender and `var') append
}

*Enrolment by age 
qui tabout age gender using "${gsdOutput}/PA_Poverty_Profile_26.xls" if (pschool_age==1 | sschool_age==1), svy sum c(mean enrolled se) sebnone f(3) npos(col) h1(Enrolment by age and gender) append
gen age_edu=age if age>=6 & age<=17
qui tabout age_edu if hhm_edu_reason==1 using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy percent c(col) sebnone f(3) h1(Age for reason to young for school) append

*Reasons for not attending school 
recode hhm_edu_reason (1=1) (2=8) (3=3) (4=8) (5=3) (6/8=2) (9=4) (10/11=8) (12/14=5) (15=6) (16/19=7) (1000=8), gen(reason_not_edu)
label define lreason_not_edu 1 "Too young" 2 "Work/help at home" 3 "Ill, sick or disabled" 4 "Lack of money" 5 "Poor quality of school" 6 "No schools nearby" 7 "Insecurity" 8 "Other"
label values reason_not_edu lreason_not_edu

qui foreach var of varlist ind_profile hhh_gender poorPPP {
	tabout reason_not_edu `var' if pschool_age==1 & gender==0 using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy percent c(col) sebnone f(3) h1(Resons for not attending primary school for girls by `var') append
}
qui foreach var of varlist ind_profile hhh_gender poorPPP {
	tabout reason_not_edu `var' if pschool_age==1 & gender==1 using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy percent c(col) sebnone f(3) h1(Resons for not attending primary school for boys by `var') append
}
qui foreach var of varlist ind_profile hhh_gender poorPPP {
	tabout reason_not_edu `var' if sschool_age==1 & gender==0 using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy percent c(col) sebnone f(3) h1(Resons for not attending secondary school for girls by `var') append
}
qui foreach var of varlist ind_profile hhh_gender poorPPP {
	tabout reason_not_edu `var' if sschool_age==1 & gender==1 using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy percent c(col) sebnone f(3) h1(Resons for not attending secondary for boys by `var') append
}

*Educational expenditures (avg. annual expenditure per enrolled hhm)
preserve 
use "${gsdData}/1-CleanOutput/hhm.dta", clear
collapse (sum) enrolled25, by(strata ea block hh)
save "${gsdTemp}/hh_enrolled.dta", replace
use "${gsdData}/1-CleanOutput/nonfood.dta", clear
keep if itemid==1082 | itemid==1083
collapse (sum) purc_usd_imp, by(strata ea block hh weight hhsize)
replace purc_usd_imp=purc_usd_imp*52
merge 1:1 strata ea hh block using "${gsdTemp}/hh_enrolled.dta", nogen keep(match)
gen edu_exp_pc=purc_usd_imp/ enrolled25
merge 1:1 strata ea hh block using "${gsdTemp}/hh_PA_Poverty_Profile.dta", nogen keep(match)
qui foreach var of varlist ind_profile hhh_gender poorPPP {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy sum c(mean edu_exp_pc se) sebnone f(3) npos(col) h1(Avg. annual expenditure on education per enrolled hhm by `var') append
}
restore
qui tabout reason_not_edu ind_profile if pschool_age==1 using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy percent c(col) sebnone f(3) h1(Resons for not attending primary school (all) by ind_profile) append
qui tabout reason_not_edu ind_profile if sschool_age==1 using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy percent c(col) sebnone f(3) h1(Resons for not attending secondary school (all) by ind_profile) append
qui tabout ind_profile gender using "${gsdOutput}/PA_Poverty_Profile_26.xls" if age>=15, svy sum c(mean literacy se) sebnone f(3) npos(col) h1(Literacy by gender & region) append
qui tabout reason_not_edu poorPPP if pschool_age==1 using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy percent c(col) sebnone f(3) h1(Resons for not attending primary school for poor status) append
qui tabout reason_not_edu poorPPP if sschool_age==1 using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy percent c(col) sebnone f(3) h1(Resons for not attending secondary school for poor status) append
qui tabout age gender using "${gsdOutput}/PA_Poverty_Profile_26.xls" if age<26 & age>5, svy sum c(mean enrolled25 se) sebnone f(3) npos(col) h1(Enrolment by age and gender) append
qui tabout age_cat_narrow gender using "${gsdOutput}/PA_Poverty_Profile_26.xls", svy pop c(per) f(5) sebnone npos(col) ptotal(none) h1(Population and gender groups) append
recode age_cat_narrow (13/18=12)
qui tabout age_cat_narrow gender using "${gsdOutput}/PA_Poverty_Profile_26.xls" if age_cat_narrow>=2, svy sum c(mean literacy se) sebnone f(3) npos(col) h1(Literacy by age and gender) append
qui tabout age_cat_narrow poorPPP using "${gsdOutput}/PA_Poverty_Profile_26.xls" if age_cat_narrow>2, svy sum c(mean no_educ se) sebnone f(3) npos(col) h1(No education by age group and poor status) append
qui tabout age_cat_narrow gender using "${gsdOutput}/PA_Poverty_Profile_26.xls" if age_cat_narrow>2, svy sum c(mean no_educ se) sebnone f(3) npos(col) h1(No education by age group and gender) append
*Educational level by age 
gen edu_level=1 if hhm_edu_level<=8 & !missing(hhm_edu_level)
replace edu_level=2 if hhm_edu_level>8 & hhm_edu_level<=12 & !missing(hhm_edu_level)
preserve
drop if age>25
qui tabout age edu_level  using "${gsdOutput}/PA_Poverty_Profile_26.xls" if hhm_edu_current==1 & age<=25, svy c(col) perc sebnone f(3) npos(col) h1(Age of attendance for educational levels) append
restore



*Labor and employment 
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_27.xls", svy sum c(mean working_age se) sebnone f(3) npos(col) h2(Working age by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected  {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_27.xls" if poorPPP==1, svy sum c(mean working_age se) sebnone f(3) npos(col) h2(Working age (poor) by `var') append
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_27.xls" if poorPPP==0, svy sum c(mean working_age se) sebnone f(3) npos(col) h2(Working age (non-poor) by `var') append
}
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_27.xls", svy sum c(mean lfp_7d se) sebnone f(3) npos(col) h2(Labor force participation by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected gender {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_27.xls" if poorPPP==1, svy sum c(mean lfp_7d se) sebnone f(3) npos(col) h2(Labor force participation (poor) by `var') append
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_27.xls" if poorPPP==0, svy sum c(mean lfp_7d se) sebnone f(3) npos(col) h2(Labor force participation (non-poor) by `var') append
}
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_27.xls", svy sum c(mean emp_7d se) sebnone f(3) npos(col) h2(Employment by ind_profile) append
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected {
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_27.xls" if poorPPP==1, svy sum c(mean emp_7d se) sebnone f(3) npos(col) h2(Employment (poor) by `var') append
	tabout `var' using "${gsdOutput}/PA_Poverty_Profile_27.xls" if poorPPP==0, svy sum c(mean emp_7d se) sebnone f(3) npos(col) h2(Employment (non-poor) by `var') append
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
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_28.xls", svy sum c(mean living_standards se) sebnone f(3) npos(col) h2(Deprivation living_standards by type) append
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_28.xls", svy sum c(mean education se) sebnone f(3) npos(col) h2(Deprivation education by type) append
qui tabout type using "${gsdOutput}/PA_Poverty_Profile_28.xls", svy sum c(mean wash se) sebnone f(3) npos(col) h2(Deprivation wash by type) append
foreach x in "living_standards" "education" "wash" "assets" {
	svy: mean `x', over(poorPPP)
	test [`x']_subpop_1 = [`x']Poor
	svy: mean `x', over(hhh_gender)
	test [`x']Female = [`x']Male
	foreach var of varlist remit12m migr_idp drought_affected {
		svy: mean `x', over(`var')
		test [`x']Yes = [`x']No
}
}
 
*Multidimensional deprivation index
qui tabout deprivations ind_profile using "${gsdOutput}/PA_Poverty_Profile_29.xls", svy c(col) perc sebnone f(3) npos(col) h1(Deprivations by ind_profile) replace
qui foreach var of varlist type hhh_gender remit12m migr_idp drought_affected poorPPP {
	tabout deprivations `var' using "${gsdOutput}/PA_Poverty_Profile_29.xls", svy c(col) perc sebnone f(3) npos(col) h1(Deprivations by `var') append
}
qui foreach var of varlist ind_profile type hhh_gender remit12m migr_idp drought_affected poorPPP {
	tabout deprivations2 `var' using "${gsdOutput}/PA_Poverty_Profile_29.xls", svy c(col) perc sebnone f(3) npos(col) h1(Deprivations (w/o Poverty) by `var') append
}
qui forval i=1/4 {
	gen depr_al`i' = deprivations>=`i' 
	tabout depr_al`i' type using "${gsdOutput}/PA_Poverty_Profile_29.xls", svy percent c(col) sebnone f(3) h1(Deprivation in `i' dimension) append
	tabout depr_al`i' poorPPP using "${gsdOutput}/PA_Poverty_Profile_29.xls", svy percent c(col) sebnone f(3) h1(Deprivation in `i' dimension) append
}
qui foreach var of varlist dep_p_living dep_p_edu dep_p_wash dep_p_living_edu dep_p_living_wash dep_p_edu_wash dep_p_all {
	tabout `var' type using "${gsdOutput}/PA_Poverty_Profile_29.xls", svy c(col) perc sebnone f(3) npos(col) h1(Deprivations in poverty and other dimension `var') append
}
qui foreach var of varlist ind_profile type  {
	tabout deprivations3 `var' using "${gsdOutput}/PA_Poverty_Profile_29.xls", svy c(col) perc sebnone f(3) npos(col) h1(Deprivations (w/o Poverty w/o assets) by `var') append
}



**************************************************
*   LIVESTOCK AND FOCUS ON NOMADS
**************************************************
use "${gsdData}/1-CleanInput/livestock.dta", clear
drop if livestockid>=7
set sortseed 11041965
qui forval i=1/6 {
	cumul own_n if livestockid==`i', gen (own_n_distribution_`i') equal
    replace own_n=. if livestockid==`i' & own_n_distribution_`i'>=0.99 & !missing(own_n_distribution_`i')
}
*Obtain a full dataset with all households and livestock
merge m:1 strata ea block hh using "${gsdTemp}/hh_PA_Poverty_Profile.dta", nogen keep(match using)
keep strata ea block hh livestockid own own_n
replace livestockid=1 if livestockid>=.
reshape wide own own_n, i(strata ea block hh) j( livestockid)
reshape long
replace own=0 if own>=.
replace own_n=0 if own==0
*Impute missing values and exclude outliers in the top of the distribution
merge m:1 strata ea block hh using "${gsdTemp}/hh_PA_Poverty_Profile.dta", nogen assert(match) keepusing(weight poorPPP ind_profile type poorPPP_prob)
levelsof livestockid, local(items)
qui foreach item of local items {
	   gen own_mean_`item'=. 
	   sum own_n [aw= weight] if livestockid==`item', detail
	   replace own_mean_`item'=r(mean) if livestockid==`item'  
}
qui forval i=1/6 {
	replace own_n=own_mean_`i' if (own_n>=. & livestockid==`i') | (own_n==0 & own==1 & livestockid==`i') 
}
drop own_mean_*
*Extract key data
svyset ea [pweight=weight], strata(strata) singleunit(centered)
qui tabout livestockid ind_profile using "${gsdOutput}/PA_Poverty_Profile_30.xls", svy sum c(mean own se) sebnone f(3) npos(col) h1(Ownership of livestock by type) replace
preserve 
drop if own==0
qui tabout livestockid ind_profile using "${gsdOutput}/PA_Poverty_Profile_30.xls", svy sum c(mean own_n se) sebnone f(3) npos(col) h1(No. of livestock owned by type) append
restore 
collapse (sum) own, by(strata ea block hh ind_profile weight poorPPP poorPPP_prob type)
gen d_own=(own>=1)
svy: mean poorPPP_prob if d_own==1, over(ind_profile) 
svy: mean poorPPP_prob if d_own==0, over(ind_profile) 



**************************************************
*   ASSETS AND POVERTY
**************************************************
use "${gsdData}/1-CleanOutput/assets.dta", clear
*keep if inlist(itemid,1,2,3,6,10,16,18,24,26,28,30,31,34,35,36,37)

preserve
keep if itemid==1 | itemid==2
collapse (max) own, by(strata ea block hh)
gen asset="Mattress/Bed"
save "${gsdTemp}/hh_PA_Assets_1.dta", replace
restore

preserve
keep if itemid==3 | itemid==6
collapse (max) own, by(strata ea block hh)
gen asset="Chair/Table"
save "${gsdTemp}/hh_PA_Assets_2.dta", replace
restore

preserve
keep if itemid==10
collapse (max) own, by(strata ea block hh)
gen asset="Mortar/pestle"
save "${gsdTemp}/hh_PA_Assets_3.dta", replace
restore

preserve
keep if itemid==16
collapse (max) own, by(strata ea block hh)
gen asset="Refrigerator"
save "${gsdTemp}/hh_PA_Assets_4.dta", replace
restore

preserve
keep if itemid==18
collapse (max) own, by(strata ea block hh)
gen asset="Stove for charcol"
save "${gsdTemp}/hh_PA_Assets_5.dta", replace
restore

preserve
keep if itemid==24
collapse (max) own, by(strata ea block hh)
gen asset="Cellphone"
save "${gsdTemp}/hh_PA_Assets_6.dta", replace
restore

preserve
keep if itemid==26
collapse (max) own, by(strata ea block hh)
gen asset="Radio"
save "${gsdTemp}/hh_PA_Assets_7.dta", replace
restore

preserve
keep if itemid==28 | itemid==31
collapse (max) own, by(strata ea block hh)
gen asset="TV/Satellite dish"
save "${gsdTemp}/hh_PA_Assets_8.dta", replace
restore

preserve
keep if itemid==30
collapse (max) own, by(strata ea block hh)
gen asset="Computer & equipment"
save "${gsdTemp}/hh_PA_Assets_9.dta", replace
restore

preserve
keep if itemid==34 | itemid==35 | itemid==36 | itemid==37
collapse (max) own, by(strata ea block hh)
gen asset="Motorcycle/Car/Bus/Lorry"
save "${gsdTemp}/hh_PA_Assets_10.dta", replace
restore

use "${gsdTemp}/hh_PA_Assets_1.dta", clear
forval i=2/10 {
	append using "${gsdTemp}/hh_PA_Assets_`i'.dta"
}
merge m:1 strata ea block hh using "${gsdTemp}/hh_PA_Poverty_Profile.dta", nogen keep(match)
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
save "${gsdTemp}/hh_PA_Assets_All.dta", replace


*Include poor from food and non-food 
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", nogen keep(match) 
egen cons_f_nf=rowtotal( mi_cons_f0 mi_cons_f1 mi_cons_f2 mi_cons_f3 mi_cons_f4 mi_cons_nf0 mi_cons_nf1 mi_cons_nf2 mi_cons_nf3 mi_cons_nf4)
replace cons_f_nf=cons_f_nf/deflator
gen share=cons_f_nf/tc_imp
svy: mean share, over(ind_profile_old)
gen new_pline=plinePPP*.9693647 if ind_profile_old==1
replace new_pline=plinePPP*.9584866 if ind_profile_old==2
replace new_pline=plinePPP*.9607523 if ind_profile_old==3
replace new_pline=plinePPP*.6842178 if ind_profile_old==4
replace new_pline=plinePPP*.9887102 if ind_profile_old==5
replace new_pline=plinePPP*.9813133 if ind_profile_old==6
replace new_pline=plinePPP*.9801565 if ind_profile_old==7
replace new_pline=plinePPP*.9918614 if ind_profile_old==8
replace new_pline=plinePPP*.9844103 if ind_profile_old==9
replace new_pline=plinePPP*.9809613 if ind_profile_old==11
replace new_pline=plinePPP*.9800027 if ind_profile_old==12
replace new_pline=plinePPP*.9903947 if ind_profile_old==13
gen poorPPP_f_nf=(cons_f_nf<new_pline) if !missing(cons_f_nf)
label values poorPPP_f_nf lpoorPPP
*Check new poverty status 
svy: mean poorPPP
svy: mean poorPPP_f_nf
merge 1:m strata ea block hh using "${gsdTemp}/hh_PA_Assets_All.dta", nogen keep(match)
*Export relevant information
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Cellphone", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Cellphone by type) replace
qui tabout poorPPP_f_nf using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Cellphone", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Cellphone by poorPPP_f_nf) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Chair/Table", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Chair/Table by type) append
qui tabout poorPPP_f_nf using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Chair/Table", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Chair/Table by poorPPP_f_nf) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Computer & equipment", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Computer & equipment by type) append
qui tabout poorPPP_f_nf using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Computer & equipment", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Computer & equipment by poorPPP_f_nf) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Mattress/Bed", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Mattress/Bed by type) append
qui tabout poorPPP_f_nf using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Mattress/Bed", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Mattress/Bed by poorPPP_f_nf) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Mortar/pestle", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Mortar/pestle by type) append
qui tabout poorPPP_f_nf using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Mortar/pestle", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Mortar/pestle by poorPPP_f_nf) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Motorcycle/Car/Bus/Lorry", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Motorcycle/Car/Bus/Lorry by type) append
qui tabout poorPPP_f_nf using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Motorcycle/Car/Bus/Lorry", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Motorcycle/Car/Bus/Lorry by poorPPP_f_nf) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Radio", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Radio by type) append
qui tabout poorPPP_f_nf using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Radio", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Radio by poorPPP_f_nf) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Refrigerator", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Refrigerator by type) append
qui tabout poorPPP_f_nf using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Refrigerator", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Refrigerator by poorPPP_f_nf) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Stove for charcol", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Stove for charcol by type) append
qui tabout poorPPP_f_nf using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="Stove for charcol", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of Stove for charcol by poorPPP_f_nf) append
qui tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="TV/Satellite dish", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of TV/Satellite dish by type) append
qui tabout poorPPP_f_nf using "${gsdOutput}/PA_Poverty_Profile_31.xls" if asset=="TV/Satellite dish", svy sum c(mean own se) sebnone f(3) npos(col) h2(Ownership of TV/Satellite dish by poorPPP_f_nf) append



**************************************************
*   PERCEPTIONS AND OTHER
**************************************************
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
gen emp_past_better=(employment_opportunities<=2) if !missing(employment_opportunities)
gen emp_future_better=(standard_living<=2) if !missing(standard_living)

foreach var of varlist ind_profile poorPPP hhh_gender migr_idp drought_affected remit12m {
	qui tabout `var' using "${gsdOutput}/PA_Poverty_Profile_31.xls", svy sum c(mean emp_future_better se) sebnone f(3) npos(col) h2(Future living conditions by `var') append
}
svy: mean emp_future_better, over(poorPPP)
test [emp_future_better]_subpop_1 = [emp_future_better]Poor
svy: mean emp_future_better, over(hhh_gender)
test [emp_future_better]Female = [emp_future_better]Male
svy: mean emp_future_better, over(remit12m)
test [emp_future_better]Yes = [emp_future_better]No
svy: mean emp_future_better, over(migr_idp)
test [emp_future_better]Yes = [emp_future_better]No
svy: mean emp_future_better, over(drought_affected)
test [emp_future_better]Yes = [emp_future_better]No


*Access to markets greater in Mogadishu 
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
gen close_market=(tmarket<=2) if !missing(tmarket) 
svy: mean water_home if inlist(ind_profile,1,2), over(ind_profile)
test [water_home]Mogadishu = [water_home]_subpop_2
svy: mean electricity if inlist(ind_profile,1,2), over(ind_profile)
test [electricity]Mogadishu = [electricity]_subpop_2
svy: mean improved_water if inlist(ind_profile,1,4), over(ind_profile)
test [improved_water]Mogadishu = [improved_water]_subpop_2
svy: mean acc_bank2 if inlist(ind_profile,1,2), over(ind_profile)
test [acc_bank2]Mogadishu = [acc_bank2]_subpop_2
svy: mean acc_bank2 if inlist(ind_profile,1,2), over(ind_profile)
test [acc_bank2]Mogadishu = [acc_bank2]_subpop_2
svy: mean close_market if inlist(ind_profile,1,2), over(ind_profile)
test [close_market]Mogadishu = [close_market]_subpop_2


*Labor market 
use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
lab def lempstatus 1 "Employed" 2 "Unemployed" 3 "Enrolled" 4 "Not enrolled"
gen empstatus = 1 if emp_7d ==1
replace empstatus =2 if emp_7d ==0
replace empstatus = 3 if lfp_7d == 0 & edu_status == 1
replace empstatus =4 if lfp_7d == 0 & edu_status != 1
replace empstatus = . if working_age != 1
la val empstatus lempstatus
ta hhm_job_search_no
la list hhm_job_search_no
recode hhm_job_search_no (1 2 =5 "Ill / Disabled") (3=2 "In school") (4 5 = 3 "Too young / old") (6 = 1 "Family and household care") (7 8 9 10 11 12 14 = 4 "Waiting for busy season / on leave") (nonmiss =.), gen(reason_inactive)
ta reason_inactive
replace reason_inactive = . if empstatus != 4
ta reason_inactive
recode emp_7d_prim (1=1 "Salaried labor") (2=2 "Own business") (3=3 "Help in business") (4=4 "Own account agriculture") (5=5 "Apprenticeship"), gen(empactivity)
*Labor force participation (population 15-64)
qui tabout empstatus ind_profile using "${gsdOutput}/PA_Poverty_Profile_32.xls", svy c(col) perc sebnone f(3) npos(col) h1(empstatus by ind_profile) replace
qui tabout empstatus gender using "${gsdOutput}/PA_Poverty_Profile_32.xls", svy c(col) perc sebnone f(3) npos(col) h1(empstatus by gender) append
qui tabout empstatus poorPPP using "${gsdOutput}/PA_Poverty_Profile_32.xls", svy c(col) perc sebnone f(3) npos(col) h1(empstatus by poor) append
*Reasons for inactivity 
qui tabout reason_inactive ind_profile using "${gsdOutput}/PA_Poverty_Profile_32.xls", svy c(col) perc sebnone f(3) npos(col) h1(reason_inactive by ind_profile) append
qui tabout reason_inactive gender using "${gsdOutput}/PA_Poverty_Profile_32.xls", svy c(col) perc sebnone f(3) npos(col) h1(reason_inactive by gender) append
qui tabout reason_inactive poorPPP using "${gsdOutput}/PA_Poverty_Profile_32.xls", svy c(col) perc sebnone f(3) npos(col) h1(reason_inactive by poor) append
*Main employment activity 
qui tabout emp_7d_prim ind_profile using "${gsdOutput}/PA_Poverty_Profile_32.xls", svy c(col) perc sebnone f(3) npos(col) h1(emp_7d_prim by ind_profile) append
qui tabout emp_7d_prim gender using "${gsdOutput}/PA_Poverty_Profile_32.xls", svy c(col) perc sebnone f(3) npos(col) h1(emp_7d_prim by gender) append
qui tabout emp_7d_prim poorPPP using "${gsdOutput}/PA_Poverty_Profile_32.xls", svy c(col) perc sebnone f(3) npos(col) h1(emp_7d_prim by poor) append




**************************************************
*   REGRESSION ANALYSIS
**************************************************
use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
replace hhm_edu_current=. if age>29
collapse (max) age_dependency_ratio (sum) hhm_edu_current, by(strata ea block hh)
rename hhm_edu_current hhm_edu_current_sum
save "${gsdTemp}/hh_dependency_ratio.dta", replace
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", nogen assert(match) 
gen share=tc_core/tc_imp
svy: mean share, over(ind_profile_old)
gen new_pline=plinePPP*.76949 if ind_profile_old==1
replace new_pline=plinePPP*.8102825 if ind_profile_old==2
replace new_pline=plinePPP*.8287334 if ind_profile_old==3
replace new_pline=plinePPP*.3157929 if ind_profile_old==4
replace new_pline=plinePPP*.7943094 if ind_profile_old==5
replace new_pline=plinePPP*.7173309 if ind_profile_old==6
replace new_pline=plinePPP*.7315971 if ind_profile_old==7
replace new_pline=plinePPP*.5755567 if ind_profile_old==8
replace new_pline=plinePPP*.7733893 if ind_profile_old==9
replace new_pline=plinePPP*.7586972 if ind_profile_old==11
replace new_pline=plinePPP*.6948547 if ind_profile_old==12
replace new_pline=plinePPP*.6859144 if ind_profile_old==13
gen poorPPP_core=(tc_core<new_pline) if !missing(tc_core)
label values poorPPP_core lpoorPPP
svy: mean poorPPP
svy: mean poorPPP_core
merge 1:1 strata ea block hh using "${gsdTemp}/hh_dependency_ratio.dta", nogen assert(match) keepusing(age_dependency_ratio hhm_edu_current)
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
gen hhh_edu_some=(hhh_edu>0) if !missing(hhh_edu)


*Checks for poverty and key groups
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
svy: logit poorPPP hhh_gender 
outreg2 using "${gsdOutput}/Regression_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel replace
svy: logit poorPPP hhh_gender i.astrata
outreg2 using "${gsdOutput}/Regression_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP remit12m 
outreg2 using "${gsdOutput}/Regression_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP remit12m i.astrata
outreg2 using "${gsdOutput}/Regression_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP migr_idp 
outreg2 using "${gsdOutput}/Regression_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP migr_idp i.astrata
outreg2 using "${gsdOutput}/Regression_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP drought_affected 
outreg2 using "${gsdOutput}/Regression_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP drought_affected i.astrata
outreg2 using "${gsdOutput}/Regression_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP remit12m hhh_gender migr_idp drought_affected  
outreg2 using "${gsdOutput}/Regression_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP remit12m hhh_gender migr_idp drought_affected  i.astrata
outreg2 using "${gsdOutput}/Regression_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

*Checks for poverty and education of HH head (Same results for hhh_edu)
svy: logit poorPPP_core hhh_edu_some 
outreg2 using "${gsdOutput}/Regression_Poverty_Edu_HHH.xls", bdec(3) tdec(3) rdec(3) nolabel replace
svy: logit poorPPP_core hhh_edu_some hhh_gender
outreg2 using "${gsdOutput}/Regression_Poverty_Edu_HHH.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core hhh_edu_some hhh_gender hhh_age
outreg2 using "${gsdOutput}/Regression_Poverty_Edu_HHH.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core hhh_edu_some hhh_gender hhh_age i.astrata
outreg2 using "${gsdOutput}/Regression_Poverty_Edu_HHH.xls", bdec(3) tdec(3) rdec(3) nolabel append


*Poverty gap
svy: reg pgi hhh_gender i.astrata
svy: reg pgi remit12m i.astrata
svy: reg pgi migr_idp i.astrata
svy: reg pgi drought_affected i.astrata
svy: reg pgi hhh_gender remit12m migr_idp drought_affected  i.astrata

*Hunger 
gen exp_hung=(hunger>1) if !missing(hunger)
svy: logit exp_hung hhh_gender i.astrata poorPPP
svy: logit exp_hung remit12m i.astrata poorPPP
svy: logit exp_hung migr_idp i.astrata poorPPP
svy: logit exp_hung drought_affected i.astrata poorPPP
svy: logit exp_hung hhh_gender remit12m migr_idp drought_affected  i.astrata poorPPP

*HH head 
svy: logit hhh_gender poorPPP i.astrata poorPPP
svy: logit hhh_gender remit12m i.astrata poorPPP
svy: logit hhh_gender migr_idp i.astrata poorPPP
svy: logit hhh_gender drought_affected i.astrata poorPPP
svy: logit hhh_gender poorPPP remit12m migr_idp drought_affected  i.astrata poorPPP

*Education of HHH
svyset ea [pweight=weight], strata(strata) singleunit(centered)
svy: logit hhh_edu_dum hhh_gender hhh_age i.astrata poorPPP
svy: logit hhh_edu_dum hhh_gender hhh_age remit12m i.astrata poorPPP
svy: logit hhh_edu_dum hhh_gender hhh_age migr_idp i.astrata poorPPP
svy: logit hhh_edu_dum hhh_gender hhh_age drought_affected i.astrata poorPPP
svy: logit hhh_edu_dum hhh_gender hhh_age remit12m migr_idp drought_affected  i.astrata poorPPP


*Regression of HH characteristics 
gen lhood_cat=1 if lhood==1
replace lhood_cat=2 if lhood==7
replace lhood_cat=3 if lhood==8
replace lhood_cat=4 if lhood==2 | lhood==5
replace lhood_cat=5 if lhood_cat==.
label define llhood_cat 1 "Salaried Labor" 2 "Small family business"  3 "Agriculture, fishing, hunting etc." 4 "Remittances" 5 "Other"
label values lhood_cat llhood_cat
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhm-hh.dta", keepusing(hhh_literacy) nogen assert(match)

svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
svy: logit poorPPP_core hhsize age_dependency_ratio no_children pgender hhh_gender hhh_age hhh_literacy pliteracy improved_water improved_sanitation electricity i.lhood_cat i.astrata
outreg2 using "${gsdOutput}/Regression_HH_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel replace

svy: logit poorPPP_core hhsize age_dependency_ratio no_children pgender hhh_gender hhh_age hhh_literacy pliteracy improved_water improved_sanitation electricity i.lhood_cat i.astrata if ind_profile==1
outreg2 using "${gsdOutput}/Regression_HH_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core hhsize age_dependency_ratio no_children pgender hhh_gender hhh_age hhh_literacy pliteracy improved_water improved_sanitation electricity i.lhood_cat i.astrata if ind_profile==2
outreg2 using "${gsdOutput}/Regression_HH_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core hhsize age_dependency_ratio no_children pgender hhh_gender hhh_age hhh_literacy pliteracy improved_water improved_sanitation electricity i.lhood_cat i.astrata if ind_profile==3
outreg2 using "${gsdOutput}/Regression_HH_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core hhsize age_dependency_ratio no_children pgender hhh_gender hhh_age hhh_literacy pliteracy improved_water improved_sanitation electricity i.lhood_cat i.astrata if ind_profile==4
outreg2 using "${gsdOutput}/Regression_HH_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core hhsize age_dependency_ratio no_children pgender hhh_gender hhh_age hhh_literacy pliteracy improved_water improved_sanitation electricity i.lhood_cat i.astrata if ind_profile==5
outreg2 using "${gsdOutput}/Regression_HH_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append


*Deprivations 
svyset ea [pweight=weight], strata(strata) singleunit(centered)
svy: logit living_standards hhsize age_dependency_ratio hhh_gender hhh_age hhh_literacy i.astrata
outreg2 using "${gsdOutput}/Regression_Multiple_Deprivations.xls", bdec(3) tdec(3) rdec(3) nolabel replace
svy: logit education hhsize age_dependency_ratio hhh_gender hhh_age hhh_literacy i.astrata
outreg2 using "${gsdOutput}/Regression_Multiple_Deprivations.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit wash hhsize age_dependency_ratio hhh_gender hhh_age hhh_literacy i.astrata
outreg2 using "${gsdOutput}/Regression_Multiple_Deprivations.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: ologit deprivations3 hhsize age_dependency_ratio hhh_gender hhh_age hhh_literacy i.astrata
outreg2 using "${gsdOutput}/Regression_Multiple_Deprivations.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: ologit deprivations hhsize age_dependency_ratio hhh_gender hhh_age hhh_literacy i.astrata
outreg2 using "${gsdOutput}/Regression_Multiple_Deprivations.xls", bdec(3) tdec(3) rdec(3) nolabel append



*Education
merge 1:m strata ea block hh using  "${gsdTemp}/hhm_PA_Poverty_Profile.dta", nogen
gen edu_no=(edu_level_broad==0) if !missing(edu_level_broad) 
gen school_more30=(tedu>=4) if !missing(tedu)
preserve 
use "${gsdData}/1-CleanOutput/hhm.dta", clear
collapse (sum) enrolled25, by(strata ea block hh)
save "${gsdTemp}/hh_enrolled.dta", replace
use "${gsdData}/1-CleanOutput/nonfood.dta", clear
keep if itemid==1082 | itemid==1083
collapse (sum) purc_usd_imp, by(strata ea block hh weight hhsize)
replace purc_usd_imp=purc_usd_imp*52
merge 1:1 strata ea hh block using "${gsdTemp}/hh_enrolled.dta", nogen keep(match)
gen edu_exp_pc=purc_usd_imp/ enrolled25
save "${gsdTemp}/edu_exp.dta", replace
restore
merge m:1 strata ea hh block using "${gsdTemp}/edu_exp.dta", nogen keep(match master)
replace edu_exp_pc=0 if edu_exp_pc==.
replace hhm_edu_current=. if age>29

gen age_cat=1 if age>=6 & age<=13 
replace age_cat=2 if age>=14 & age<=17 
replace age_cat=3 if age>=18 & age<=25 
replace age_cat=4 if age>=26 & age<.
label define lage_cat 1 "6-13" 2 "14-17"  3 "18-25" 4 "26+"
label values age_cat lage_cat

*Scholl attendance 
svyset ea [pweight=weight], strata(strata) singleunit(centered)
svy: logit enrolled25 poorPPP_core age gender hhh_gender hhh_literacy remit12m school_more30 edu_exp_pc i.astrata
outreg2 using "${gsdOutput}/Regression_School_Attendance.xls", bdec(3) tdec(3) rdec(3) nolabel replace
svy: logit enrolled25 poorPPP_core gender hhh_gender hhh_literacy remit12m school_more30 edu_exp_pc i.age_cat i.astrata
outreg2 using "${gsdOutput}/Regression_School_Attendance.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit enrolled25 poorPPP_core age gender hhh_gender hhh_literacy remit12m school_more30 edu_exp_pc i.astrata if pschool_age==1
outreg2 using "${gsdOutput}/Regression_School_Attendance.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit enrolled25 poorPPP_core age gender hhh_gender hhh_literacy remit12m school_more30 edu_exp_pc i.astrata if sschool_age==1
outreg2 using "${gsdOutput}/Regression_School_Attendance.xls", bdec(3) tdec(3) rdec(3) nolabel append


*No education
svy: logit edu_no poorPPP_core age gender i.astrata
outreg2 using "${gsdOutput}/Regression_School_Attendance.xls", bdec(3) tdec(3) rdec(3) nolabel append



*Checks for child/youth poverty 
svyset ea [pweight=weight], strata(strata) singleunit(centered)
svy: logit poorPPP_core hhh_gender if child==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel replace
svy: logit poorPPP_core hhh_gender i.astrata if child==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP_core remit12m if child==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core remit12m i.astrata if child==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP_core migr_idp if child==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core migr_idp i.astrata if child==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP_core drought_affected if child==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core drought_affected i.astrata if child==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP_core hhh_gender remit12m migr_idp drought_affected i.astrata if child==1


svy: logit poorPPP_core hhh_gender if youth==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core hhh_gender i.astrata if youth==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP_core remit12m if youth==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core remit12m i.astrata if youth==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP_core migr_idp if youth==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core migr_idp i.astrata if youth==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP_core drought_affected if youth==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core drought_affected i.astrata if youth==1
outreg2 using "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls", bdec(3) tdec(3) rdec(3) nolabel append

svy: logit poorPPP_core hhh_gender remit12m migr_idp drought_affected i.astrata if youth==1


*Literacy rate
svyset ea [pweight=weight], strata(strata) singleunit(centered)
svy: logit adult_literacy_rate hhh_gender hhh_age i.astrata poorPPP
svy: logit adult_literacy_rate hhh_gender hhh_age remit12m i.astrata poorPPP
svy: logit adult_literacy_rate hhh_gender hhh_age migr_idp i.astrata poorPPP
svy: logit adult_literacy_rate hhh_gender hhh_age drought_affected i.astrata poorPPP
svy: logit adult_literacy_rate hhh_gender hhh_age remit12m migr_idp drought_affected  i.astrata poorPPP

*No education
gen dum_no_edu=(edu_level_broad>0) if !missing(edu_level_broad)
svyset ea [pweight=weight], strata(strata) singleunit(centered)
svy: logit dum_no_edu age gender i.astrata poorPPP
svy: logit dum_no_edu age gender remit12m i.astrata poorPPP
svy: logit dum_no_edu age gender migr_idp i.astrata poorPPP
svy: logit dum_no_edu age gender drought_affected i.astrata poorPPP
svy: logit dum_no_edu age gender remit12m migr_idp drought_affected  i.astrata poorPPP



*Inequality decomposition (GE 1 - Theil Index)
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
ineqdeco tc_imp [aweight=hhweight], bygroup(ind_profile)
ineqdeco tc_imp [aweight=hhweight], bygroup(type)
recode ind_profile_old (1=1) (2=2) (3=3) (4=2) (5=3) (6=4) (7=5) (8=5) (9=6) (11=7) (12=7) (13=8), gen (region)
ineqdeco tc_imp [aweight=hhweight], bygroup(region)


*Poverty gap in monetary value 
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
*Obtain gap in USD 
gen monetary_gap_hh=pgi*plinePPP
*Convert to population & annual value
gen monetary_gap_pop=monetary_gap_hh*hhsize*365
*Scale weights to total population in Somalia (Total from PESS 12,316,895)
egen tot_wave2=sum(weight)
gen scale_factor=2076677/1939610
replace weight=scale_factor*weight
*Obtain representative value for areas covered 
gen monetary_gap_rep=monetary_gap_pop*weight
egen monetary_gap_som=sum(monetary_gap_rep)
replace monetary_gap_som=monetary_gap_som/1000000
label var monetary_gap_som "Monetary gap in million US per year"


*Differences between poor children and non-poor ones
use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
merge m:1 strata ea block hh using "${gsdTemp}/hh_PA_Poverty_Profile.dta", keepusing(hhh_edu_dum hunger electricity improved_sanitation improved_water living_standards education wash hhsize roof_material floor_material thealth tedu dep_p_living dep_p_edu dep_p_wash)
svyset ea [pweight=weight], strata(strata) singleunit(centered)
foreach var of varlist hhh_edu_dum hunger electricity improved_sanitation improved_water living_standards education wash {
	svy: mean `var' if child==1, over(poorPPP)
	test [`var']Poor = [`var']_subpop_1
}

svy: mean hhsize if child==1, over(poorPPP)
test [hhsize]Poor = [hhsize]_subpop_1


**************************************************
*   INTEGRATE ALL SHEETS INTO THE FINAL FILE
**************************************************

*Monetary poverty
import excel "${gsdOutput}/PA_Poverty_Profile_1.xls", sheet("Sheet1") firstrow case(lower) clear
export excel using "${gsdOutput}/PA_Poverty_Profile_A_v3.xlsx", sheetreplace sheet("Raw_Data_1") firstrow(variables)
erase "${gsdOutput}/PA_Poverty_Profile_1.xls"
foreach i of numlist 2/14 {
	insheet using "${gsdOutput}/PA_Poverty_Profile_`i'.xls", clear nonames tab
	export excel using "${gsdOutput}/PA_Poverty_Profile_A_v3.xlsx", sheetreplace sheet("Raw_Data_`i'") 
	erase "${gsdOutput}/PA_Poverty_Profile_`i'.xls"
}
*Poverty and indicators
foreach i of numlist 15/21 {
	insheet using "${gsdOutput}/PA_Poverty_Profile_`i'.xls", clear nonames tab
	export excel using "${gsdOutput}/PA_Poverty_Profile_B_v3.xlsx", sheetreplace sheet("Raw_Data_`i'") 
	erase "${gsdOutput}/PA_Poverty_Profile_`i'.xls"
}
*Multidimensional poverty 
foreach i of numlist 22/32 {
	insheet using "${gsdOutput}/PA_Poverty_Profile_`i'.xls", clear nonames tab
	export excel using "${gsdOutput}/PA_Poverty_Profile_C_v3.xlsx", sheetreplace sheet("Raw_Data_`i'") 
	erase "${gsdOutput}/PA_Poverty_Profile_`i'.xls"
}
*Regression tables
import delimited "${gsdOutput}/Regression_Poverty_Characteristics.txt", clear 
export excel using "${gsdOutput}/PA_Poverty_Profile_D_v3.xlsx", sheetreplace sheet("Raw_1")
erase "${gsdOutput}/Regression_Poverty_Characteristics.txt"
erase "${gsdOutput}/Regression_Poverty_Characteristics.xls"
import delimited "${gsdOutput}/Regression_Poverty_Edu_HHH.txt", clear 
export excel using "${gsdOutput}/PA_Poverty_Profile_D_v3.xlsx", sheetreplace sheet("Raw_2")
erase "${gsdOutput}/Regression_Poverty_Edu_HHH.txt"
erase "${gsdOutput}/Regression_Poverty_Edu_HHH.xls"
import delimited "${gsdOutput}/Regression_HH_Characteristics.txt", clear 
export excel using "${gsdOutput}/PA_Poverty_Profile_D_v3.xlsx", sheetreplace sheet("Raw_3")
erase "${gsdOutput}/Regression_HH_Characteristics.txt"
erase "${gsdOutput}/Regression_HH_Characteristics.xls"
import delimited "${gsdOutput}/Regression_Multiple_Deprivations.txt", clear 
export excel using "${gsdOutput}/PA_Poverty_Profile_D_v3.xlsx", sheetreplace sheet("Raw_4")
erase "${gsdOutput}/Regression_Multiple_Deprivations.txt"
erase "${gsdOutput}/Regression_Multiple_Deprivations.xls"
import delimited "${gsdOutput}/Regression_School_Attendance.txt", clear 
export excel using "${gsdOutput}/PA_Poverty_Profile_D_v3.xlsx", sheetreplace sheet("Raw_5")
erase "${gsdOutput}/Regression_School_Attendance.txt"
erase "${gsdOutput}/Regression_School_Attendance.xls"
import delimited "${gsdOutput}/Regression_Child_Poverty_Characteristics.txt", clear 
export excel using "${gsdOutput}/PA_Poverty_Profile_D_v3.xlsx", sheetreplace sheet("Raw_6")
erase "${gsdOutput}/Regression_Child_Poverty_Characteristics.txt"
erase "${gsdOutput}/Regression_Child_Poverty_Characteristics.xls"

