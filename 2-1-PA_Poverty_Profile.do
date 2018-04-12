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
save "${gsdTemp}/hh_PA_Poverty_Profile.dta", replace

// Household member level 
use "${gsdData}/1-CleanOutput/hhm.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", assert(match) nogen keepusing(weight ind_profile type poorPPP)
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
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean poorPPP_prob se) sebnone f(3) npos(col) h2(Poverty incidence) replace
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean pgi se) sebnone f(3) npos(col) h2(Poverty gap) append
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean gini se) sebnone f(3) npos(col) h2(GINI coefficient) append
svyset ea [pweight=weight], strata(strata) singleunit(centered)
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean improved_sanitation se) sebnone f(3) npos(col) h2(Improved Sanitation) append
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean improved_water se) sebnone f(3) npos(col) h2(Improved Water) append
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean electricity se) sebnone f(3) npos(col) h2(Access to electricity) append

use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean adult_literacy_rate se) sebnone f(3) npos(col) h2(Adult Literay rate) append
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean enrolled25 se) sebnone f(3) npos(col) h2(Enrolment rate) append
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean attainment_primary  se) sebnone f(3) npos(col) h2(Educational attainment - Primary) append
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean attainment_secondary  se) sebnone f(3) npos(col) h2(Educational attainment - Secondary) append
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean lfp_7d se) sebnone f(3) npos(col) h2(Labor force participation) append
tabout type using "${gsdOutput}/PA_Poverty_Profile_2.xls", svy sum c(mean employment se) sebnone f(3) npos(col) h2(Employment) append



**************************************************
*   MONETARY POVERTY
**************************************************
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)

*Poverty incidence 
tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_3.xls", svy sum c(mean poorPPP_prob se) sebnone f(3) npos(col) h2(Poverty incidence by ind_profile) replace
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
 
*Extreme poverty 
tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_4.xls", svy sum c(mean poorPPP125_prob se) sebnone f(3) npos(col) h2(Extreme poverty incidence by ind_profile) replace
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
tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_5.xls", svy sum c(mean poorPPP_prob_AE se) sebnone f(3) npos(col) h2(Poverty incidence AE by ind_profile) replace
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
tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_6.xls", svy sum c(mean poorPPP_vulnerable_10_prob se) sebnone f(3) npos(col) h2(Vulnerable w/10% shock by ind_profile) replace
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
tabout ind_profile using "${gsdOutput}/PA_Poverty_Profile_7.xls", svy sum c(mean poorPPP_vulnerable_20_prob se) sebnone f(3) npos(col) h2(Vulnerable w/20% shock by ind_profile) replace
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











svyset ea [pweight=weight], strata(strata) singleunit(centered)
child 
youth 



pgi 
pseverity
GINI 

**************************************************
*   POVERTY AND HOUSEHOLD CHARACTERISTICS
**************************************************




**************************************************
*   MULTIDIMENSIONAL DEPRIVATIONS
**************************************************



**************************************************
*   INTEGRATE ALL SHEETS INTO ONE FILE
**************************************************


qui tabout poorPPP remit12m using "${gsdOutput}/Child_Poverty_1.xls" if child==1, svy c(freq se lb ub) sebnone h1(Child poverty - by remittances) append

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





* Household size and age dependency ratio
svyset ea [pweight=weight_cons], strata(strata)

qui foreach var of varlist sub_region region type {	
	tabout `var' poorPPP using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean hhsize se) sebnone cibnone f(2) h2(Household size by `var') append 
	tabout `var' poorPPP using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean age_dependency_ratio se) sebnone cibnone f(2) h2(Household Age Dependency ratio by `var') append 
}
* Household demographic attributes

qui foreach var of varlist sub_region region type {	
	tabout `var' poorPPP using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean no_children se) sebnone cibnone f(2) h2(Number of children by `var') append 
	tabout `var' poorPPP using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean no_adults se) sebnone cibnone f(2) h2(Number of adults by `var') append 
	 tabout `var' poorPPP using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean no_old_age se) sebnone cibnone f(2) h2(Number of old-age people by `var') append 
}

* Proportion of Male household heads
qui tabout sub_region using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean hhh_gender se lb ub) sebnone f(3) h2(Proportion of male-headed households by sub_region) append
qui tabout region using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean hhh_gender se lb ub) sebnone f(3) h2(Proportion of male-headed households by region) append
qui tabout type using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean hhh_gender se lb ub) sebnone f(3) h2(Proportion of male-headed households by type) append

svyset ea [pweight=pweight], strata(strata)

* Female vs. Male household head consumption
qui tabout sub_region using "${gsdOutput}/Monetary_Poverty_source.xls" if hhh_gender==0, svy sum c(mean tc_imp se lb ub) sebnone f(3) h2(Average Consumption of female-headed households by sub_region) append
qui tabout region using "${gsdOutput}/Monetary_Poverty_source.xls" if hhh_gender==0, svy sum c(mean tc_imp se lb ub) sebnone f(3) h2(Average Consumption of female-headed households by region) append
qui tabout type using "${gsdOutput}/Monetary_Poverty_source.xls" if hhh_gender==0, svy sum c(mean tc_imp se lb ub) sebnone f(3) h2(Average Consumption of female-headed households by type) append
qui tabout sub_region using "${gsdOutput}/Monetary_Poverty_source.xls" if hhh_gender==1, svy sum c(mean tc_imp se lb ub) sebnone f(3) h2(Average Consumption of male-headed households by sub_region) append
qui tabout region using "${gsdOutput}/Monetary_Poverty_source.xls" if hhh_gender==1, svy sum c(mean tc_imp se lb ub) sebnone f(3) h2(Average Consumption of male-headed households by region) append
qui tabout type using "${gsdOutput}/Monetary_Poverty_source.xls" if hhh_gender==1, svy sum c(mean tc_imp se lb ub) sebnone f(3) h2(Average Consumption of male-headed households by type) append

* Sub-regional Gini
levelsof sub_region, local(region) 
foreach i of local region {
	fastgini tc_imp [pweight=pweight] if sub_region==`i'
	return list 
	gen gini_`i'=r(gini)
    qui tabout gini_`i' using "${gsdOutput}/Monetary_Poverty_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient for region `i') append
}

*Average quintile consumption, by region. Consumption Lorenz curve, at 5% distribution intervals, by region.
svyset ea [pweight=pweight], strata(strata) 
forval i=1/4 {
   xtile quintiles_tc_region`i' = tc_imp [pweight=weight_cons*hhsize] if region==`i', n(5) 
   qui tabout quintiles_tc_region`i' if region==`i' using "${gsdOutput}/Monetary_Poverty_source.xls" , svy sum c(mean tc_imp se) sebnone f(3) npos(col) h2(Total imputed consumption by quintiles (distribution within each region) in region `i') append
}
*Average quintile consumption, by type. Consumption Lorenz curve, at 5% distribution intervals, by type.
forval i=1/2 {
   xtile quintiles_tc_type`i' = tc_imp [pweight=weight_cons*hhsize] if type==`i', n(5) 
   qui tabout quintiles_tc_type`i' if type==`i' using "${gsdOutput}/Monetary_Poverty_source.xls" , svy sum c(mean tc_imp se) sebnone f(3) npos(col) h2(Total imputed consumption by quintiles (distribution within each type) in type `i') append
}
xtile quintiles_tc_country = tc_imp [pweight=weight_cons*hhsize], n(5) 
qui tabout quintiles_tc_country using "${gsdOutput}/Monetary_Poverty_source.xls" , svy sum c(mean tc_imp se) sebnone f(3) npos(col) h2(Total imputed consumption by quintiles -national) append


*Average percentile consumption, by region, at 5% distribution interval.
forval i=1/4 {
	xtile percentiles`i' = tc_imp [pweight=weight_cons*hhsize] if region==`i', n(20)
	tabout percentiles`i' if region==`i' using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean tc_imp se ) sebnone f(3) npos(col) h2(Total imputed consumption by quintiles (distribution within each region) in region `i' ) append
} 

insheet using "${gsdOutput}/Monetary_Poverty_source.xls", clear nonames tab
export excel using "${gsdOutput}/Monetary_Poverty_Figures_Final.xlsx", sheetreplace firstrow(variables) sheet("Monetary_Poverty_source")
erase "${gsdOutput}/Monetary_Poverty_source.xls"







**************************LUCA POVERTY 1 

* 1 - Poverty trends
*Poverty headcount ratio: % of Population living on $1.90 PPP per person per day
qui tabout wave urban using "${gsdOutput}/Raw-Data 1.xls" if dataset==2, svy sum c(mean poorPPP_prob se lb ub) npos(col) f(4) replace sebnone h2("poverty HFS")
qui tabout dataset using "${gsdOutput}/Raw-Data 1.xls" if dataset==1, svy sum c(mean poorPPP_prob se lb ub) npos(col) f(4) append sebnone h2("poverty IDP")
*test difference in overall poverty across waves 1 and 3
svy: mean poorPPP_prob if dataset==2 & inlist(wave,1,3) , over(wave)
lincom [poorPPP_prob]Wave1 - [poorPPP_prob]Wave3
*test difference in rural poverty across waves 1 and 3
svy: mean poorPPP_prob if dataset==2, over(wave urban)
lincom [poorPPP_prob]_subpop_1 - [poorPPP_prob]_subpop_4
*test difference in urban poverty across waves 1 and 4
lincom [poorPPP_prob]_subpop_2 - [poorPPP_prob]_subpop_6
*test difference in urban poverty across waves 2 and 4
lincom [poorPPP_prob]_subpop_3 - [poorPPP_prob]_subpop_6
*test difference in urban poverty across waves 3 and 4
lincom [poorPPP_prob]_subpop_5 - [poorPPP_prob]_subpop_6
*test difference in rural/urban poverty in wave 3
lincom [poorPPP_prob]_subpop_4 - [poorPPP_prob]_subpop_5
*means of other poverty lines
svy: mean poor125PPP_prob poor31PPP_prob if dataset==2 & inlist(wave,1,3) , over(wave )
*Poverty gap/depth: mean aggregate income relative to poverty line
gen gap = (plinePPP - tc_imp)/plinePPP if (!missing(tc_imp)) 
replace gap = 0 if (tc_imp>plinePPP & !missing(tc_imp))
qui tabout wave urban using "${gsdOutput}/Raw-Data 1.xls" if dataset==2, svy sum c(mean gap se lb ub) npos(col) f(4) append sebnone h2("gap HFS")
qui tabout dataset using "${gsdOutput}/Raw-Data 1.xls" if dataset==1, svy sum c(mean gap se lb ub) npos(col) f(4) append sebnone h2("gap IDP")
*test difference in overall gap across waves 1 and 3
svy: mean gap if dataset==2 & inlist(wave,1,3) , over(wave )
lincom [gap]Wave1 - [gap]Wave3
*test difference in rural gap across waves 1 and 3
svy: mean gap if dataset==2, over(wave urban)
lincom [gap]_subpop_1 - [gap]_subpop_4
*test difference in urban gap across waves 1 and 4
lincom [gap]_subpop_2 - [gap]_subpop_6
*test difference in urban gap across waves 2 and 4
lincom [gap]_subpop_3 - [gap]_subpop_6
*test difference in urban gap across waves 3 and 4
lincom [gap]_subpop_5 - [gap]_subpop_6
*test difference in rural/urban gap in wave 3
lincom [gap]_subpop_4 - [gap]_subpop_5
*poverty gap between idps and other
svy: mean gap, over(wave dataset)
lincom [gap]_subpop_4-[gap]_subpop_3
*Poverty severity: squared poverty gap 
gen severity = (gap)^2 
qui tabout wave urban using "${gsdOutput}/Raw-Data 1.xls" if dataset==2, svy sum c(mean severity se lb ub) npos(col) f(4) append sebnone h2("severity HFS")
qui tabout dataset using "${gsdOutput}/Raw-Data 1.xls" if dataset==1, svy sum c(mean severity se lb ub) npos(col) f(4) append sebnone h2("severity IDP")
*test difference in overall gap across waves 1 and 3
svy: mean severity if dataset==2 & inlist(wave,1,3) , over(wave )
lincom [severity]Wave1 - [severity]Wave3
*test difference in rural gap across waves 1 and 3
svy: mean severity if dataset==2, over(wave urban)
lincom [severity]_subpop_1 - [severity]_subpop_4
*test difference in urban gap across waves 1 and 4
lincom [severity]_subpop_2 - [severity]_subpop_6
*test difference in urban gap across waves 2 and 4
lincom [severity]_subpop_3 - [severity]_subpop_6
*test difference in urban gap across waves 3 and 4
lincom [severity]_subpop_5 - [severity]_subpop_6
*test difference in rural/urban gap in wave 3
lincom [severity]_subpop_4 - [severity]_subpop_5
*poverty severity between idps and other
svy: mean severity, over(wave dataset)
lincom [severity]_subpop_4-[severity]_subpop_3

*Gini Index
*Overall waves 1 and 3
fastgini tc_imp [pw=pweight] if wave==1, jk
gen gini_mean_o=`r(gini)' if wave==1
gen gini_sd_o=`r(se)' if wave==1
fastgini tc_imp [pw=pweight] if wave==3, jk
replace gini_mean_o=`r(gini)' if wave==3
replace gini_sd_o=`r(se)' if wave==3
*Urban
fastgini tc_imp [pw=pweight] if wave==1 & urban==1, jk
gen gini_mean_u=`r(gini)' if wave==1 & urban==1
gen gini_sd_u=`r(se)' if wave==1 & urban==1
fastgini tc_imp [pw=pweight] if wave==2 & urban==1, jk
replace gini_mean_u=`r(gini)' if wave==2 & urban==1
replace gini_sd_u=`r(se)' if wave==2 & urban==1
fastgini tc_imp [pw=pweight] if wave==3 & urban==1, jk
replace gini_mean_u=`r(gini)' if wave==3 & urban==1
replace gini_sd_u=`r(se)' if wave==3 & urban==1
fastgini tc_imp [pw=pweight] if wave==4 & urban==1, jk
replace gini_mean_u=`r(gini)' if wave==4 & urban==1
replace gini_sd_u=`r(se)' if wave==4 & urban==1
*Rural
fastgini tc_imp [pw=pweight] if wave==1 & urban==0, jk
replace gini_mean_u=`r(gini)' if wave==1 & urban==0
replace gini_sd_u=`r(se)' if wave==1 & urban==0
fastgini tc_imp [pw=pweight] if wave==3 & urban==0, jk
replace gini_mean_u=`r(gini)' if wave==3 & urban==0
replace gini_sd_u=`r(se)' if wave==3 & urban==0
*IDP
fastgini tc_imp [pw=pweight] if dataset==1, jk
gen gini_mean_d=`r(gini)' if dataset==1
gen gini_sd_d=`r(se)' if dataset==1
replace gini_mean_d=0 if dataset==2
replace gini_sd_d=0 if dataset==2
qui tabout wave using "${gsdOutput}/Raw-Data 1.xls" if inlist(wave,1,3), svy sum c(mean gini_mean_o) npos(col) f(4) append sebnone h2("Gini HFS overall - mean")
qui tabout wave urban using "${gsdOutput}/Raw-Data 1.xls" if dataset==2, svy sum c(mean gini_mean_u) npos(col) f(4) append sebnone h2("Gini HFS urban - mean")
qui tabout dataset using "${gsdOutput}/Raw-Data 1.xls" , svy sum c(mean gini_mean_d) npos(col) f(4) append sebnone h2("Gini HFS overall - mean")

*poverty under the 3.1 and 1.25 lines
*Poverty headcount ratio 3.1 USD PPP
qui tabout wave urban using "${gsdOutput}/Raw-Data 1.xls" if dataset==2, svy sum c(mean poor31PPP_prob se lb ub) npos(col) f(4) append sebnone h2("poverty 31 HFS")
qui tabout dataset using "${gsdOutput}/Raw-Data 1.xls" if dataset==1, svy sum c(mean poor31PPP_prob se lb ub) npos(col) f(4) append sebnone h2("poverty 31 IDP")
*Poverty headcount ratio 1.25 USD PPP
qui tabout wave urban using "${gsdOutput}/Raw-Data 1.xls" if dataset==2, svy sum c(mean poor125PPP_prob se lb ub) npos(col) f(4) append sebnone h2("poverty 125 HFS")
qui tabout dataset using "${gsdOutput}/Raw-Data 1.xls" if dataset==1, svy sum c(mean poor125PPP_prob se lb ub) npos(col) f(4) append sebnone h2("poverty 125 IDP")

*Poverty and gender
*poverty headcount
forvalues i=0/1 {
	if `i'==0 {
		local g="Male"
	}
	if `i'==1 {
		local g="Female"
	}
	qui tabout wave urban using "${gsdOutput}/Raw-Data 1.xls" if dataset==2 & hhh_gender==`i' , svy sum c(mean poorPPP_prob se lb ub) npos(col) f(4) append sebnone h2("`g' head poverty HFS")
	qui tabout dataset using "${gsdOutput}/Raw-Data 1.xls" if dataset==1  & hhh_gender==`i'  , svy sum c(mean poorPPP_prob se lb ub) npos(col) f(4) append sebnone h2("`g' head poverty IDP")
}
*poverty gap
forvalues i=0/1 {
	if `i'==0 {
		local g="Male"
	}
	if `i'==1 {
		local g="Female"
	}
	qui tabout wave urban using "${gsdOutput}/Raw-Data 1.xls" if dataset==2 & hhh_gender==`i' , svy sum c(mean gap se lb ub) npos(col) f(4) append sebnone h2("`g' head gap HFS")
	qui tabout dataset using "${gsdOutput}/Raw-Data 1.xls" if dataset==1  & hhh_gender==`i'  , svy sum c(mean gap se lb ub) npos(col) f(4) append sebnone h2("`g' head gap IDP")
}
*extreme poverty headcount 
forvalues i=0/1 {
	if `i'==0 {
		local g="Male"
	}
	if `i'==1 {
		local g="Female"
	}
	qui tabout wave urban using "${gsdOutput}/Raw-Data 1.xls" if dataset==2 & hhh_gender==`i' , svy sum c(mean poor125PPP_prob se lb ub) npos(col) f(4) append sebnone h2("`g' head poverty HFS")
	qui tabout dataset using "${gsdOutput}/Raw-Data 1.xls" if dataset==1  & hhh_gender==`i'  , svy sum c(mean poor125PPP_prob se lb ub) npos(col) f(4) append sebnone h2("`g' head poverty IDP")
}



















*********************************LUCA POVERTY 2 



*create growth incidence curve data
*create HFS datasets
forvalues n=1/4 {
	use  "${gsdData}/1-CleanTemp/hhq_analysis.dta", clear
	keep if dataset==2 & wave==`n'
	svyset ea [pw=pweight], strata(stratum)
	keep stratum wave state urban ea hh pweight tc_imp plinePPP
	save "${gsdTemp}/gicw`n'.dta", replace
}
*2009 overall
use "${gsdNBHS}/NBHS_HH.dta", clear
keep if state>81
egen stratum=group(state urban)
gen pweight=hhweight*hhsize
svyset cluster [pw=pweight], strata(stratum)
replace urban=0 if urban==2
label define lurban 0 "Rural" 1 "Urban", modify
label val urban lurban
*Poverty line 1.90 USD in USD PPP (2011)
* The 2009 PPP for SSD is 1/1.0858328
* Thus, to convert May 2009 SDG into July 2009 SSP we:
* do not convert since SSPs were introduced at par with SSPs when the currency was first introduced
* multiply by the SSD PPP conversion factor, and adjust for inflation
* CPI July 2017: 3355.756; May 2009
* = pcexpm/30 * 1.08 / 72.583*239.906
*gen tc_imp=pcexpm/30*1.08/72.583*239.906
gen tc_imp=pcexpm/30 * 1 /72.583*3355.756
keep stratum state cluster urban hhid pweight tc_imp
save "${gsdTemp}/gic2009.dta", replace
*create curves
local default_dir `c(pwd)'
cd "${gsdTemp}"
*2009-Wave3
use "${gsdTemp}/gic2009.dta", clear
gicurve using "${gsdTemp}/gicw3.dta" [aw=pweight], var1(tc_imp) var2(tc_imp) nograph np(100) ci(100) nograph out("gic2009w3.dta")  bands(50)
*2009-Wave1
use "${gsdTemp}/gic2009.dta", clear
*gicurve using "${gsdTemp}/gicw1.dta" [aw=pweight], var1(tc_imp) var2(tc_imp)  np(100) ci(100) nograph out("gic2009w1.dta") minmax bands(50)
*Wave1-Wave3 
use "${gsdTemp}/gicw1.dta", clear
gicurve using "${gsdTemp}/gicw3.dta" [aw=pweight], var1(tc_imp) var2(tc_imp)  np(100) ci(100) nograph out("gicw1w3.dta")  bands(50)
*urban 2009 wave 3
use "${gsdTemp}/gic2009.dta", clear
gicurve using "${gsdTemp}/gicw3.dta" [aw=pweight] if urban==1, var1(tc_imp) var2(tc_imp)  np(100) ci(100) nograph out("$gic2009w3_u.dta")  bands(50)




*growth rate of consumption between waves 1 and 3
quietly svy: mean tc_imp, over(wave urban)
lincom [tc_imp]_subpop_2 - [tc_imp]_subpop_6
display "average income change between 2009 and 2015 in urban areas:  " ([tc_imp]_subpop_1 - [tc_imp]_subpop_3)/[tc_imp]_subpop_1
lincom [tc_imp]_subpop_1 - [tc_imp]_subpop_5
display "average income change between 2009 and 2015 in rural areas:  " ([tc_imp]_subpop_2 - [tc_imp]_subpop_4)/[tc_imp]_subpop_2
lincom [tc_imp]_subpop_2 - [tc_imp]_subpop_6
display "average income change between 2015 and 2016 in urban areas:  " ([tc_imp]_subpop_3 - [tc_imp]_subpop_5)/[tc_imp]_subpop_3
lincom [tc_imp]_subpop_1 - [tc_imp]_subpop_5
display "average income change between 2015 and 2016 in rural areas:  " ([tc_imp]_subpop_4 - [tc_imp]_subpop_6)/[tc_imp]_subpop_4
*growth rate of consumption CAGR
quietly svy: mean tc_imp, over(wave)
display "CAGR of consumption between 2009 and wave 1:  " ([tc_imp]Wave1/[tc_imp]NBHS)^(1/6)-1
display "CAGR of consumption between 2009 and wave 3:  " ([tc_imp]Wave3/[tc_imp]NBHS)^(1/7)-1
quietly svy: mean tc_imp, over(wave urban)
display "CAGR of consumption between 2009 and wave 1 urban:  " ([tc_imp]_subpop_4/[tc_imp]_subpop_2)^(1/6)-1
display "CAGR of consumption between 2009 and wave 1 rural:  " ([tc_imp]_subpop_3/[tc_imp]_subpop_1)^(1/6)-1

*consumption distributions
kdensity tc_imp if wave==0 & tc_imp<1000  [aw=pweight] , nograph gen(x distr2009 )
kdensity tc_imp if wave==1 & tc_imp<1000  [aw=pweight]  , nograph at(x) gen(distr2015 )
kdensity tc_imp if wave==3 & tc_imp<1000  [aw=pweight]  , nograph at(x) gen(distr2016 )
label var distr2009 "2009"
label var distr2015 "2015"
label var distr2016 "2016"
export excel x distr* using "${gsdOutput}/Figures.xlsx", sheetmodify sheet("Distributions-2") first(varl) cell(A1)


twoway (kdensity tc_imp if wave==0) (kdensity tc_imp if wave==1) (kdensity tc_imp if wave==3) if tc_imp<450 & urban==1 , legend(order(1 "2009" 2 "2015" 3 "2016"))
twoway (kdensity tc_imp if wave==0) (kdensity tc_imp if wave==1) (kdensity tc_imp if wave==3) if tc_imp<450 & urban==0 , legend(order(1 "2009" 2 "2015" 3 "2016"))







*Create dataset with consumption expenditure distribution curves overall and by strata
*create overall percentiles
use  "${gsdData}/1-CleanTemp/hhq_analysis.dta", clear
keep if dataset==2
svyset ea [pw=pweight], strata(stratum)
drop if missing(tc_imp)
keep dataset wave stratum urban state ea hh pweight tc_imp 
gen pctile=.
forvalues i=1(2)3 {
	xtile pctile_w`i'=tc_imp [aw=pweight]  if wave==`i', nq(100)
	replace pctile=pctile_w`i' if wave==`i'
	gen tc_imp_w`i'=tc_imp if wave==`i'
}
drop if missing(pctile)
collapse tc_imp_w* , by(pctile)
save "${gsdTemp}/pctiles_overall.dta", replace
*create urban percentiles
use  "${gsdData}/1-CleanTemp/hhq_analysis.dta", clear
keep if dataset==2
svyset ea [pw=pweight], strata(stratum)
drop if missing(tc_imp)
keep dataset wave stratum urban state ea hh pweight tc_imp 
gen pctile=.
forvalues i=1/4 {
	xtile pctile_w`i'_u=tc_imp [aw=pweight]  if wave==`i' & urban==1, nq(100)
	replace pctile=pctile_w`i'_u if wave==`i'  & urban==1
	gen tc_imp_w`i'_u=tc_imp if wave==`i'  & urban==1
}
drop if missing(pctile)
collapse tc_imp_w* , by(pctile)
save "${gsdTemp}/pctiles_urban.dta", replace
*create rural percentiles
use  "${gsdData}/1-CleanTemp/hhq_analysis.dta", clear
svyset ea [pw=pweight], strata(stratum)
drop if missing(tc_imp)
keep dataset wave stratum urban state ea hh pweight tc_imp 
gen pctile=.
forvalues i=1(2)3 {
	xtile pctile_w`i'_r=tc_imp [aw=pweight]  if wave==`i' & urban==0, nq(100)
	replace pctile=pctile_w`i'_r if wave==`i'  & urban==0
	gen tc_imp_w`i'_r=tc_imp if wave==`i'  & urban==0
}
drop if missing(pctile)
collapse tc_imp_w* , by(pctile)
save "${gsdTemp}/pctiles_rural.dta", replace
*prepare 2009 data
use "${gsdNBHS}/NBHS_HH.dta", clear
*keep only surveyed states, drop Warrap
keep if state>81
egen stratum=group(state urban)
gen pweight=hhweight*hhsize
svyset cluster [pw=pweight], strata(stratum)
replace urban=0 if urban==2
gen tc_imp=pcexpm/30*1.08/72.583*3355.756
*create overall percentiles
xtile pctile = tc_imp [aw=pweight], nq(100)
drop if missing(pctile)
collapse tc_imp_nbhs=tc_imp , by(pctile)
save "${gsdTemp}/pctiles_overall_nbhs.dta", replace
*Rural
use "${gsdTemp}/gic2009.dta", clear
svyset cluster [pw=pweight], strata(stratum)
keep if urban==0
xtile pctile = tc_imp [aw=pweight], nq(100)
drop if missing(pctile)
collapse tc_imp_nbhs_r=tc_imp , by(pctile)
save "${gsdTemp}/pctiles_rural_nbhs.dta", replace
*Urban
use "${gsdTemp}/gic2009.dta", clear
svyset cluster [pw=pweight], strata(stratum)
keep if urban==1
xtile pctile = tc_imp [aw=pweight], nq(100)
drop if missing(pctile)
collapse tc_imp_nbhs_u=tc_imp , by(pctile)
save "${gsdTemp}/pctiles_urban_nbhs.dta", replace
*create percentiles after consumption shock of 15%
use "${gsdTemp}/gicw3.dta", clear
gen tc_shock=tc_imp*0.85
xtile pctile = tc_shock [aw=pweight], nq(100)
drop if missing(pctile)
collapse tc_shock_w3=tc_shock , by(pctile)
save "${gsdTemp}/pctiles_shock.dta", replace 
*create distribution of consumption
use "${gsdTemp}/gicw3.dta", clear
gen tc_shock=tc_imp*0.7
kdensity tc_imp if tc_imp<450, nograph gen(x tc_dens_w3)
kdensity tc_shock  if tc_imp<450, nograph gen(tc_dens_shock_w3) at(x)
gen pctile=_n
keep if pctile<51	
order pctile x tc_dens_w3 tc_dens_shock_w3
keep pctile x tc_dens_w3 tc_dens_shock_w3
save "${gsdTemp}/distribution_shock.dta", replace  
*merge the data
use "${gsdTemp}/pctiles_overall.dta", clear
merge 1:1 pctile using "${gsdTemp}/pctiles_urban.dta", nogen assert(match)
merge 1:1 pctile using "${gsdTemp}/pctiles_rural.dta", nogen assert(match)
merge 1:1 pctile using  "${gsdTemp}/pctiles_overall_nbhs.dta", nogen assert(match)
merge 1:1 pctile using  "${gsdTemp}/pctiles_rural_nbhs.dta", nogen assert(match)
merge 1:1 pctile using  "${gsdTemp}/pctiles_urban_nbhs.dta", nogen assert(match)
merge 1:1 pctile using  "${gsdTemp}/pctiles_shock.dta", nogen assert(match)
merge 1:1 pctile using  "${gsdTemp}/distribution_shock.dta", nogen assert(match master)
save "${gsdData}/1-CleanTemp/distributions.dta", replace
export excel using "${gsdOutput}/Figures.xlsx", sheetreplace sheet("Raw-Data 2-1") first(variables)



*Carry out the poverty decomposition analysis
*growth inequality decomposition
*2009-Wave3
use "${gsdTemp}/gic2009.dta", clear	
gen pline=72.94/30 * 1 /72.583*3355.756
gidecomposition using "${gsdTemp}/gicw3.dta" [aw=pweight], var1(tc_imp) var2(tc_imp)  pline1(pline) pline2(plinePPP)
gidecomposition using "${gsdTemp}/gicw3.dta" [aw=pweight] if urban==1, var1(tc_imp) var2(tc_imp)  pline1(pline) pline2(plinePPP)
gidecomposition using "${gsdTemp}/gicw3.dta" [aw=pweight] if urban==0, var1(tc_imp) var2(tc_imp)  pline1(pline) pline2(plinePPP)
*2009-Wave1
use "${gsdTemp}/gic2009.dta", clear	
gen pline=72.94/30 * 1 /72.583*3355.756
gidecomposition using "${gsdTemp}/gicw1.dta" [aw=pweight], var1(tc_imp) var2(tc_imp)  pline1(pline) pline2(plinePPP)
gidecomposition using "${gsdTemp}/gicw1.dta" [aw=pweight] if urban==1, var1(tc_imp) var2(tc_imp)  pline1(pline) pline2(plinePPP)
gidecomposition using "${gsdTemp}/gicw1.dta" [aw=pweight] if urban==0, var1(tc_imp) var2(tc_imp)  pline1(pline) pline2(plinePPP)
*Wave1-Wave3
use "${gsdTemp}/gicw1.dta", clear
gidecomposition using "${gsdTemp}/gicw3.dta" [aw=pweight], var1(tc_imp) var2(tc_imp)  pline1(plinePPP) pline2(plinePPP)
gidecomposition using "${gsdTemp}/gicw3.dta" [aw=pweight] if urban==1, var1(tc_imp) var2(tc_imp)  pline1(plinePPP) pline2(plinePPP)
gidecomposition using "${gsdTemp}/gicw3.dta" [aw=pweight] if urban==0, var1(tc_imp) var2(tc_imp)  pline1(plinePPP) pline2(plinePPP)


*Sectoral decomposition
*prepare 2009
use "${gsdTemp}/gic2009.dta", clear
gen plinePPP=8.67*3355.756/239.93
save  "${gsdTemp}/gic2009_secdec.dta", replace 
*prepare W1
use "${gsdTemp}/gicw1.dta", clear
merge 1:m wave state ea hh using "${gsdData}/1-CleanTemp/hhm_analysis.dta", nogen assert(match using) keep(match) 
recode emp_sector_5 (1 = 1 "Agriculture") (2 4 5 =2  "Services") (3= 3 "Manufacturing"), gen(emp_sector_3)
bys state ea hh: egen emp_sector=mode(emp_sector_3), minmode
keep if ishead==1
merge 1:1 wave state ea hh using "${gsdData}/1-CleanTemp/hhq_analysis.dta", nogen assert(match using) keep(match) 
recode lhood (1 2 3 = 1 "Agriculture") (4 = 4 "Wages and salaries") (5 = 5 "Own business") (6 7 9 8 = 7 "Remittances/Aid/Other") (nonmissing=.) , gen(livelihood)
keep stratum wave state urban ea hh pweight tc_imp plinePPP livelihood emp_sector
save  "${gsdTemp}/gicw1_secdec.dta", replace
*prepare W3
use "${gsdTemp}/gicw3.dta", clear
merge 1:m wave state ea hh using "${gsdData}/1-CleanTemp/hhm_analysis.dta", nogen assert(match using) keep(match) 
recode emp_sector_5 (1 = 1 "Agriculture") (2 4 5 =2  "Services") (3= 3 "Manufacturing"), gen(emp_sector_3)
bys state ea hh: egen emp_sector=mode(emp_sector_3), minmode
keep if ishead==1
merge 1:1 wave state ea hh using "${gsdData}/1-CleanTemp/hhq_analysis.dta", nogen assert(match using) keep(match) 
recode lhood (1 2 3 = 1 "Agriculture") (4 = 4 "Wages and salaries") (5 = 5 "Own business") (6 7 9 8 = 7 "Remittances/Aid/Other") (nonmissing=.) , gen(livelihood)
keep stratum wave state urban ea hh pweight tc_imp plinePPP livelihood emp_sector
save  "${gsdTemp}/gicw3_secdec.dta", replace
*decomposition overall
use "${gsdTemp}/gic2009_secdec.dta", clear
sedecomposition using "${gsdTemp}/gicw3_secdec.dta" [aw=pweight], sector(urban) var1(tc_imp) var2(tc_imp)  pline1(plinePPP) pline2(plinePPP)
*2009-wave1
use "${gsdTemp}/gic2009_secdec.dta", clear
sedecomposition using "${gsdTemp}/gicw1_secdec.dta" [aw=pweight], sector(urban) var1(tc_imp) var2(tc_imp)  pline1(plinePPP) pline2(plinePPP)
*wave1-wave3
use "${gsdTemp}/gicw1_secdec.dta", clear
sedecomposition using "${gsdTemp}/gicw3_secdec.dta" [aw=pweight], sector(urban) var1(tc_imp) var2(tc_imp)  pline1(plinePPP) pline2(plinePPP)


















*multidimensional deprivation index
*Deprivation in 2009
use "${gsdData}/1-CleanTemp/NBHS_hhm.dta", clear
*education
rename (c1 c2 c3) (literacy edu_ever edu_current)
*generate dummy if adult had no education ever
gen adult_noedu=(edu_ever==2) if inrange(age,15,120)
*generate dummy for child not attending school
gen child_noed=(edu_current==2 | edu_ever==2) if inrange(age,6,14)
*create household level data
collapse (max) child_noed (sum) adult_noedu (count) adult_num=adult_noedu , by(state ea hh)
gen adult_noed=adult_noedu==adult_num
drop adult_noedu adult_num
replace child_noed=0 if missing(child_noed)
label var child_noed "At least one child is not attending school, ages 6-14"
label var adult_noed "All adults have no education, ages 15+"
save "${gsdTemp}/multidimensional_educ_NBHS.dta", replace
*WASH
use "${gsdData}/1-CleanTemp/NBHS.dta", clear
*improved sanitation
gen improved_sanitation=inlist(h9,1,2)
label var improved_sanitation "Household has access to improved sanitation"
*improved water source
gen improved_watersource=inlist(h5,1,2,3,4,5,12) 
label var improved_watersource "Household has access to improved water source"
*housing type
gen housing=inlist(h1,5,6,8,9,10)
label var housing "Household lives in improved housing"
*electricity
gen electricity=(inlist(h7,1,2,9,10))
label var electricity "Household has access to electricity" 
*sleeping room density (two missing cases set to mean)
quietly su h3, meanonly
replace h3=r(mean) if h3<0 | missing(h3)
gen crowding=(hhsize/h3)>2.5
label var crowding "Household lives in overcrowded household"
*cooking 
gen cook=(inlist(h8,1,6,7))
label var cook "Household cooks with grass, dung, or firewood"
*information
gen mobile_phone=i33_1==1
label var mobile_phone "Household owns at least one Mobile phone"
gen tvsat=(i31_1==1 )
label var tvsat "Household owns at least one TV/Satellite dish"
gen radio=i32_1==1
label var radio "Household owns at least one radio"
gen computer=i34_1==1
label var computer "Household owns at least one computer"
*transportation
gen cartruck=i21_1==1
label var cartruck "Household owns at least one car/truck"
gen motorcycleshaw=i22_1==1
label var motorcycleshaw "Household owns at least one motorcycle/rickshaw"
gen bicycle=i23_1==1
label var bicycle "Household owns at least one bicycle"
*merge with education data
merge 1:1 state ea hh using "${gsdTemp}/multidimensional_educ_NBHS.dta", nogen assert(match)
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
gen hhh_gender=head_sex-1
rename (quintile ) (quintiles_tc ) 
local tokeep = "poor quintiles_tc hhh_gender deprivations deprivations2  improved_sanitation improved_watersource electricity housing cook crowding mobile_phone tvsat radio computer cartruck motorcycleshaw bicycle adult_noed child_noed information transportation assets education living_standards wash"
label define lyn 0 "No" 1 "Yes"
local labelling = "improved_sanitation improved_watersource electricity housing cook crowding mobile_phone tvsat radio computer cartruck motorcycleshaw bicycle adult_noed child_noed information transportation assets education living_standards wash"
label val `labelling' lyn
gen dataset=3
keep dataset wave state ea hh urban weight pweight hhsize `tokeep'
order dataset wave state ea hh urban weight pweight hhsize `tokeep'
save  "${gsdTemp}/multidimensional_deprivation_NBHS.dta", replace


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

*append the two datasets
use "${gsdTemp}/multidimensional_deprivation_HFS.dta", clear
append using "${gsdTemp}/multidimensional_deprivation_NBHS.dta"
egen stratum=group(state urban)
order stratum, before(urban)
label define lwave 0 "NBHS", modify
label define dataset 3 "NBHS", modify
save  "${gsdTemp}/multidimensional_deprivation.dta", replace


*create table
use "${gsdTemp}/multidimensional_deprivation.dta", clear
svyset ea [pw=pweight], strata(stratum)
*tabulate mean number of deprivations 
qui tabout deprivations if wave==3 & dataset==2 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) replace h1("deprivations overall") f(4)
qui tabout deprivations urban if wave==3 & dataset==2 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations urban") f(4)
qui tabout deprivations hhh_gender if wave==3 & dataset==2 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations hhh gender") f(4)
*tabulate mean number of deprivations per quintile, without poverty
qui tabout deprivations2 quintiles_tc if wave==3 & dataset==2 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations quintiles") f(4)
*each deprivation individually 
foreach v of varlist assets living_standards education wash {
	qui tabout `v' if wave==3 & dataset==2 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' overall") f(4)
	qui tabout `v' urban if wave==3 & dataset==2 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' urban") f(4)
	qui tabout `v' quintiles_tc if wave==3 & dataset==2 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' quintiles") f(4)
	qui tabout `v' hhh_gender if wave==3 & dataset==2 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' hhh gender") f(4)
}
*2009 figures
*tabulate mean number of deprivations  
qui tabout deprivations if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations overall 2009") f(4)
qui tabout deprivations urban if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations urban 2009") f(4)
qui tabout deprivations hhh_gender if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations hhh gender 2009") f(4)
*tabulate mean number of deprivations 
qui tabout deprivations2 quintiles_tc using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations quintiles 2009") f(4)
*each deprivation individually 
foreach v of varlist assets living_standards education wash {
	qui tabout `v' if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' overall 2009") f(4)
	qui tabout `v' urban if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' urban 2009") f(4)
	qui tabout `v' quintiles_tc if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' quintiles 2009") f(4)
	qui tabout `v' hhh_gender if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' hhh gender 2009") f(4)
}
*Add IDP variables
qui tabout deprivations if dataset==1 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations IDP") f(4)
*IDPS are 100 percent deprived of living standards
foreach v of varlist assets education wash {
	qui tabout `v' if dataset==1 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' IDP") f(4) 
}
*deprivations along four dimensions
qui tabout deprivations2 urban if wave==3 & dataset==2 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations overall") f(4)
qui tabout deprivations2 quintiles_tc if wave==3 & dataset==2 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations urban") f(4)
qui tabout deprivations2 urban if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations overall 2009") f(4)
qui tabout deprivations2 quintiles_tc if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("deprivations urban 2009") f(4)
*each sub-indicator individually 
foreach v of varlist housing crowding electricity improved_sanitation improved_watersource adult_noed child_noed cook information transportation {
	qui tabout `v' if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' overall 2009") f(4)
	qui tabout `v' if wave==3 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' overall 2016") f(4)
	qui tabout `v' urban if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' urban 2009") f(4)
	qui tabout `v' urban if wave==3 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' urban 2016") f(4)
	qui tabout `v' quintiles_tc if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' quintiles 2009") f(4)
	qui tabout `v' quintiles_tc if wave==3 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' quintiles 2016") f(4)
	qui tabout `v' hhh_gender if wave==0 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' hhh gender 2009") f(4)
	qui tabout `v' hhh_gender if wave==3 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' hhh gender 2016") f(4)
}
foreach v of varlist housing crowding electricity cook improved_sanitation improved_watersource adult_noed child_noed information transportation {
	qui tabout `v' if dataset==1 using "${gsdOutput}/Raw-Data 16.xls", svy c(col lb ub) npos(col) append h1("`v' IDP") f(4)
}
*place raw data into the excel figures file
insheet using "${gsdOutput}/Raw-Data 16.xls", clear nonames
export excel using "${gsdOutput}/Figures.xlsx", sheetreplace sheet("Raw-Data 16") 
rm "${gsdOutput}/Raw-Data 16.xls"




*Assets analysis
*Asset ownership?
use "${gsdTemp}/multidimensional_deprivation.dta", clear
svyset ea [pw=pweight], strata(stratum)
*prepare HFS asset ownership
merge 1:1 wave state ea hh using "${gsdData}/1-CleanTemp/assets_analysis_wide.dta", nogen assert(match master using) keep(match master) keepusing(Canoe_boat Plough Refrigerator Fan Air_cooler_air_conditioner Mattress_or_bed Mosquito_net Hoe_spade_axe)
local assets = "Canoe_boat Plough Refrigerator Fan Air_cooler_air_conditioner Mattress_or_bed Mosquito_net Hoe_spade_axe"
foreach v of local assets {
	quietly replace `v'=!missing(`v')
}
rename (Canoe_boat Plough Refrigerator Fan Air_cooler_air_conditioner Mattress_or_bed Mosquito_net Hoe_spade_axe) (canoe plough refrigerator fan aircon mattress_bed mosquito_net hoe_spade_axe)
*prepare NBHS assets
merge 1:1 wave state ea hh using "${gsdData}/1-CleanTemp/NBHS.dta", nogen assert(match master using) keep(match master) keepusing(i24_1 i35_1 i36_1 i37_1 i310_1)
foreach v of varlist i24_1 i35_1 i36_1 i37_1 i310_1 {
	replace `v'=`v'==1 
}
replace canoe=i24_1 if wave==0
replace refrigerator=i35_1 if wave==0
replace fan=i36_1 if wave==0
replace aircon=i37_1 if wave==0
replace mosquito_net=i310_1 if wave==0
drop  i24_1 i35_1 i36_1 i37_1 i310_1 
order tvsat radio mobile_phone computer cartruck motorcycleshaw bicycle canoe plough refrigerator fan aircon mattress_bed mosquito_net hoe_spade_axe, last
local assets = "tvsat radio mobile_phone computer cartruck motorcycleshaw bicycle canoe refrigerator fan aircon mosquito_net plough mattress_bed hoe_spade_axe"
foreach v of local assets {
	qui tabout `v' wave if dataset!=1 using "${gsdOutput}/Raw-Data 17.xls", svy c(col lb ub) npos(col) append h1("`v' ownership") f(4)
	qui tabout `v' if dataset==1 using "${gsdOutput}/Raw-Data 17.xls", svy c(col lb ub) npos(col) append h1("`v' ownership IDP") f(4)	
	display "`v'"
}
*ownership of selected assets by quintile
merge 1:1 wave state ea hh using "${gsdData}/1-CleanTemp/hhq_analysis.dta", nogen assert(match master) keepusing(mi_cons_f mi_cons_nf)
egen tc_fnf=rowtotal(mi_cons_f mi_cons_nf)
xtile quintiles_fnf=tc_fnf [aw=pweight] if wave==3, nq(5)
label val quintiles_fnf lquintiles_tc
local assets = "tvsat radio mobile_phone computer cartruck motorcycleshaw bicycle canoe  refrigerator fan  mosquito_net plough mattress_bed hoe_spade_axe"
foreach v of local assets {
	qui tabout `v' quintiles_fnf if dataset==2 & wave==3 using "${gsdOutput}/Raw-Data 17.xls", svy c(col lb ub) npos(col) append h1("`v' ownership") f(4)
		display "`v'"
}
*Assets by urban rural
local assets = "tvsat radio mobile_phone computer cartruck motorcycleshaw bicycle canoe  refrigerator fan  mosquito_net plough mattress_bed hoe_spade_axe"
foreach v of local assets {
	qui tabout `v' urban if dataset==2 & wave==3 using "${gsdOutput}/Raw-Data 17.xls", svy c(col lb ub) npos(col) append h1("`v' ownership urban/rural") f(4)
	display "`v'"
}
*place raw data into the excel figures file
insheet using "${gsdOutput}/Raw-Data 17.xls", clear nonames
export excel using "${gsdOutput}/Figures.xlsx", sheetreplace sheet("Raw-Data 17") 
rm "${gsdOutput}/Raw-Data 17.xls"



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
























