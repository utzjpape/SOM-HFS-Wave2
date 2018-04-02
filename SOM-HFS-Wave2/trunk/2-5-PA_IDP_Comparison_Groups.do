*Wave 2 IDP analysis -- Comparison groups.

*Prepare HHM variables for merging to HHQ
use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear
collapse age_dependency_ratio, by(strata ea block hh)
save "${gsdTemp}/collapsedhhmdepratio.dta", replace

*Setup data
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

********************************************************
*Make comparison groups in HHQ.
********************************************************

*1. IDPs and host communities.
gen comparisonidp = . 
la def lcomparisonidp 1 "Non-Camp IDP" 2 "Camp IDP 2016" 3 "Camp IDP" 4 "Host" 5 "Non-host Urban" 
*Non-camp IDPs of W2
replace comparisonidp = 1 if  migr_idp ==1 & t ==1 & ind_profile != 6
*Camp IDPs W1
replace comparisonidp = 2 if t ==0 & ind_profile ==6
*Camp IDPs W2
replace comparisonidp = 3 if migr_idp ==1 & t ==1 & ind_profile == 6
*Host community W2
replace comparisonidp = 4 if type_idp_host == 2 & t==1 & migr_idp !=1
*Non-host community among urban, W2
replace comparisonidp = 5 if type ==1 & type_idp_host !=2 & t==1 & migr_idp !=1
la val comparisonidp lcomparisonidp
la var comparisonidp "IDPs and Host Community types"

*2. Urban, Rural, National (to get national, tabout over t.), excluding noncamp IDPs
gen urbanrural = type
replace urbanrural = . if migr_idp ==1
replace urbanrural = . if t ==0
replace urbanrural =. if !inlist(type, 1,2)
la val urbanrural ltype
la var urbanrural "Urban or rural (excludes IDPs and Nomads)"

*3. W2 Camp IDP disaggregations
*HHH gender
gen genidp = hhh_gender
replace genidp =. if !(migr_idp ==1 & t ==1 & ind_profile == 6)
la var genidp "HHH Gender of W2 Camp IDP"
la def lgenidp 0 "Woman headed" 1 "Man headed"
la val genidp lgenidp
*Consumption quintiles
xtile quintileidp = tc_imp [pweight=weight_cons*hhsize] if (migr_idp ==1 & t ==1 & ind_profile == 6), nquantiles(5)
la var quintileidp "Quintiles for imputed consumption of W2 Camp IDP"
la val quintileidp lquintiles_tc
la def lquintiles_tc 1 "Poorest quintile" 5 "Richest quintile", modify

*4. Drought and conflict IDPs (for now, this pools camp and noncamp idps of 2017)
recode disp_from (11 21 = 1 "Same district") (12 22 = 2 "Same region different district") (13 14 23 =3 "Different region/federated member state") (15 24 = 4 "Outside country") (nonmiss =.), gen(disp_from_new) la(ldisp_from_new)
*Clean reason for displacement
label define disp_reason 1 "Armed conflict in village" 2 "Armed conflict other village" 3 "Increased violence" 4 "Discrimination" 5 "Drought / famine / flood" 6 "Low access to home / land" 7 "Low water access for livestock" 8 "Low education / health access " 9 "Low employment opportunities" 10 "Death in family" 11 "IDP relocation program" 12 "Eviction" 1000 "Other" , modify
tab disp_reason
*clean displacement reason to remove less important categories
recode disp_reason (1=1 "Armed conflict in village") (2=2 "Armed conflict in other village") (3=3 "Increased violence but not conflict") (4=4 "Discrimination") (5=5 "Drought / famine / flood") (6/1000 = 6 "Other"), gen(disp_reason_concise) label(disp_reason_concise)
tab disp_reason_concise
*Conflict and drought idps comparison groups
gen reasonidp = 1 if inlist(disp_reason_concise, 1, 2, 3, 4) & !missing(comparisonidp)
replace reasonidp = 2 if inlist(disp_reason_concise, 5) & !missing(comparisonidp)
la def lreasonidp 1 "Conflict, violence or discrimination" 2 "Drought, famine or flood" 
la val reasonidp lreasonidp
la var reasonidp "Reasons for displacement: W2 camp and noncamp IDPs"

*4. Merge in essential variables from hhm. 
cap drop age_dependency_ratio
merge 1:1 strata ea block hh using "${gsdTemp}/collapsedhhmdepratio.dta", nogen assert(match) keepusing(age_dependency_ratio)
save "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", replace 

********************************************************
*Merge comparison groups to HHM
********************************************************
use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", assert(match) nogen keepusing( comparisonidp urbanrural genidp quintileidp migr_idp)

*Prepare variables
recode age (0/14 = 1 "Under 15 years") ( 15/24 = 2 "15-24 years") (25/64 = 3 "25-64 years") (65/120 =4 "Above 64 years"), gen(age_g_idp) label(lage_g_idp)
*working age 
gen age_3_idp = age_g_idp
replace age_3_idp = age_3_idp -1 if inlist(age_3_idp, 3, 4)
lab def age3 1 "Below15" 2 "From15to64" 3 "Above64"
lab val age_3_idp age3

save "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", replace
