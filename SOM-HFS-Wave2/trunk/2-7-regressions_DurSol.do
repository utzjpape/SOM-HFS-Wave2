*Regression analysis for the durable solutions report


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
*   REGRESSION ANALYSIS
**************************************************
use "${gsdTemp}/hhm_PA_Poverty_Profile.dta", clear
replace hhm_edu_current=. if age>29
collapse (max) age_dependency_ratio (sum) hhm_edu_current, by(strata ea block hh)
rename hhm_edu_current hhm_edu_current_sum
save "${gsdTemp}/hh_dependency_ratio.dta", replace
use "${gsdTemp}/hh_PA_Poverty_Profile.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", nogen assert(match) 

*Obtain poorPPP from core consumption and a rescaled poverty line 
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

*Add additional variables 
merge 1:1 strata ea block hh using "${gsdTemp}/hh_dependency_ratio.dta", nogen assert(match) keepusing(age_dependency_ratio hhm_edu_current)
gen hhh_edu_some=(hhh_edu>0) if !missing(hhh_edu)
gen pchild=no_children/hhsize
keep if type_idp_host<.
recode type_idp_host (2=0)
recode lhood (8=1 "Agriculture") (1=2 "Wage, Salary & own business") (2=3 "Aid, Remittances & Other") (3/6=3) (7=2) (9/10=2) (11/.=3), gen (lhood_dum)
replace lhood_dum=3 if lhood_dum>=.

*Regression analysis for poor vs. non-poor 
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
svy: logit poorPPP_core type_idp_host i.astrata 
outreg2 using "${gsdOutput}/Regression_Poor.xls", bdec(3) tdec(3) rdec(3) nolabel replace
svy: logit poorPPP_core type_idp_host hhsize age_dependency_ratio pgender pchild pliteracy i.astrata 
outreg2 using "${gsdOutput}/Regression_Poor.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core type_idp_host hhsize age_dependency_ratio pgender pchild pliteracy hhh_gender hhh_age hhh_lit i.astrata 
outreg2 using "${gsdOutput}/Regression_Poor.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core type_idp_host hhsize age_dependency_ratio pgender pchild pliteracy hhh_gender hhh_age hhh_lit improved_water improved_sanitation electricity i.astrata 
outreg2 using "${gsdOutput}/Regression_Poor.xls", bdec(3) tdec(3) rdec(3) nolabel append
svy: logit poorPPP_core type_idp_host hhsize age_dependency_ratio pgender pchild pliteracy hhh_gender hhh_age hhh_lit improved_water improved_sanitation electricity i.lhood_dum i.astrata 
outreg2 using "${gsdOutput}/Regression_Poor.xls", bdec(3) tdec(3) rdec(3) nolabel append
erase "${gsdOutput}/Regression_Poor.txt"


XXXX
*Regression analysis for Refugees vs. Host 
svyset ea [pweight=weight], strata(strata) singleunit(centered)
svy: logit Refugee hhsize depend_share pfemale pchild pliterate hhh_gender hhh_age hhh_literacy watersource sanitation electricity i.lhood 
outreg2 using "${gsdOutput}/Regression_Refugee.xls", bdec(3) tdec(3) rdec(3) nolabel append
erase "${gsdOutput}/Regression_Refugee.txt"


*Regression analysis for return intention 
svyset ea [pweight=weight], strata(strata) singleunit(centered)
svy: logit I_21_move_want_yn i.host_refugee_country hhsize depend_share pfemale pchild pliterate hhh_gender hhh_age hhh_literacy watersource sanitation electricity i.lhood poorPPP_core
outreg2 using "${gsdOutput}/Regression_Return.xls", bdec(3) tdec(3) rdec(3) nolabel append
erase "${gsdOutput}/Regression_Return.txt"








*==========================================================
*==========================================================
*==========================================================


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

