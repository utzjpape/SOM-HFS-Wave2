*Wave 2 IDP analysis -- Comparison groups.

*Prepare HHM variables for merging to HHQ
use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear
collapse age_dependency_ratio, by(strata ea block hh)
save "${gsdTemp}/collapsedhhmdepratio.dta", replace

*Setup data
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear 
*Dropping strata with single sampling unit to allow for CI calculation
*replace strata =. if inlist(strata, 42, 48, 54)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

********************************************************
*Make comparison groups in HHQ.
********************************************************

*1. IDPs and host communities.
gen comparisonidp = . 
la def lcomparisonidp 1 "Non-Camp IDP" 2 "Camp IDP 2016" 3 "Camp IDP" 4 "Host" 5 "Non-host Urban" 
*Non-camp IDPs of W2
replace comparisonidp = 1 if  migr_idp ==1 & t ==1 & ind_profile != 6
*Camp IDPs W1
replace comparisonidp =  2 if t ==0 & ind_profile ==6
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

gen national = t
*Remove IDPs and nomads
replace national = . if migr_idp ==1 | ind_profile ==13
lab def lnational 0 "Wave 1" 1 "National" 
la val national lnational
la var national "National W2, excluding nomads and IDPs"
ta national
*This adds up. The variable has about 1500 obs missing, which are IDPs, and another 500, which are nomads.

*3. W2 Camp IDP disaggregations
*HHH gender
gen genidp = hhh_gender
*Set to missing for anyone not a camp IDP of w2.
replace genidp =. if !(migr_idp ==1 & t ==1 & ind_profile == 6)
la var genidp "HHH Gender of W2 Camp IDP"
la def lgenidp 0 "Woman headed" 1 "Man headed"
la val genidp lgenidp
*Consumption quintiles
xtile quintileidp = tc_imp [pweight=weight_cons*hhsize] if (migr_idp ==1 & t ==1 & ind_profile == 6), nquantiles(5)
la var quintileidp "Quintiles for imputed consumption of W2 Camp IDP"
la val quintileidp lquintiles_tc
la def lquintiles_tc 1 "Poorest quintile" 5 "Richest quintile", modify

*4. Drought and conflict IDPs (for now, this has only camp idps of 2017)
recode disp_from (11 21 = 1 "Same district") (12 22 = 2 "Same region different district") (13 14 23 =3 "Different region/federated member state") (15 24 = 4 "Outside country") (nonmiss =.), gen(disp_from_new) la(ldisp_from_new)
*Clean reason for displacement
label define disp_reason 1 "Armed conflict in village" 2 "Armed conflict other village" 3 "Increased violence" 4 "Discrimination" 5 "Drought / famine / flood" 6 "Low access to home / land" 7 "Low water access for livestock" 8 "Low education / health access " 9 "Low employment opportunities" 10 "Death in family" 11 "IDP relocation program" 12 "Eviction" 1000 "Other" , modify
tab disp_reason
*clean displacement reason to remove less important categories
recode disp_reason (1=1 "Armed conflict in village") (2=2 "Armed conflict in other village") (3=3 "Increased violence but not conflict") (4=4 "Discrimination") (5=5 "Drought / famine / flood") (6/1000 = 6 "Other"), gen(disp_reason_concise) label(disp_reason_concise)
tab disp_reason_concise
*Conflict and drought idps comparison groups
gen reasonidp = 1 if inlist(disp_reason_concise, 1, 2, 3) & comparisonidp==3
replace reasonidp = 2 if inlist(disp_reason_concise, 5) & comparisonidp==3
la def lreasonidp 1 "Conflict or violence" 2 "Drought, famine or flood" 
la val reasonidp lreasonidp
la var reasonidp "Reasons for displacement: W2 camp IDPs"

*5. IDPs displaced once and many times.
*Clean variable of times displaced
recode disp_site (1=1 "Once") (2=2 "Twice") (3=3 "Thrice") (4/10 = 4 "4 or more times"), gen(disp_times) lab(ldisp_times)
gen timesidp = disp_times
replace timesidp = 2 if inlist(disp_times, 2, 3, 4) 
*Remove nomads
replace timesidp =. if inlist(ind_profile, 13)
lab def ltimesidp 1 "Once" 2 "Multiple"
lab val timesidp ltimesidp

*6. IDPs displaced for less than 5 years or more.
*Clean date of first displacement
gen year = substr(disp_date,1,4) if !strpos(disp_date, ".z")
gen month = substr(disp_date,6,2) if !strpos(disp_date, ".z")
gen day = substr(disp_date,9,2)
egen displacementdate = concat (year month) if !strpos(disp_date, ".z") & !missing(month) & !missing(year), p(-) 
label var displacementdate "Date of displacement (month wise)"
*Duration of displacement
*Survey date - use Jan 2018 as approx survey date (Survey ran Nov - Dec 2017,with last few obs in Jan 2018.)
gen month2 = "01"
gen year2 = 2018
egen surveydate = concat(year2 month2), p(-)
*HRF to SIF
gen sdate = monthly(surveydate, "YM")
gen ddate = monthly(displacementdate, "YM")
*Duration
gen dduration = sdate - ddate
*remove outliers
*hist dduration
replace dduration =. if dduration > 120
*put in year format
gen durationyear = dduration/12
*drop unnecessary variables
drop year month day

*Do the same for date when you arrived at the current location
gen year = substr(disp_arrive_date,1,4) if !strpos(disp_arrive_date, ".z")
gen month = substr(disp_arrive_date,6,2) if !strpos(disp_arrive_date, ".z")
gen day = substr(disp_arrive_date,9,2)
egen displacement_arrive_date = concat (year month) if !strpos(disp_arrive_date, ".z") & !missing(month) & !missing(year), p(-)
ta displacement_arrive_date
label var displacement_arrive_date "Date of arriving at current location (month wise)"
*Duration of displacement
*HRF to SIF
gen s_arrive_date = monthly(surveydate, "YM")
gen d_arrive_date = monthly(displacement_arrive_date, "YM")
*Duration
gen d_arrive_duration = s_arrive_date - d_arrive_date
*remove outliers
replace d_arrive_duration =. if d_arrive_duration > 60
*one observation gives a negative duration since survey and displacement happened in 2017-07 but we approximate survey date as 2017-06.
replace d_arrive_duration = . if d_arrive_duration <0
*put in year format
gen duration_arrive_year = d_arrive_duration/12
*Check that durations are not negative (some are since date of displ is in Dec. 2017 or Jan.2018.)
assert duration_arrive_year >= 0 if inlist(comparisonidp, 1, 2, 3)
assert durationyear >= 0 if inlist(comparisonidp, 1, 2, 3)

*Get the comparison group for protracted
gen durationidp = 1 if durationyear <5
replace durationidp =2 if durationyear >= 5
replace durationidp =. if missing(durationyear)
lab def ldurationidp 1 "Not protracted" 2 "Protracted"
lab val durationidp ldurationidp
*Check that nomads are not included
count if !(missing(disp_date) | disp_date == ".z") & inlist(comparisonidp, 1, 3)
ta ind_profile if !(missing(disp_date) | disp_date == ".z")

*6.1 Check: Could protracted IDPs be the same as the multiple displaced ones?
ta durationidp timesidp

*7. Comparison groups for significance testings
*Get a comparison group for Camp, Noncamp, National for sig tests
gen sigdt = comparisonidp if inlist(comparisonidp , 1, 3)
replace sigdt = 4 if (national==1 & comparisonidp != 1 & comparisonidp !=3)
tab sigdt ind_profile, miss
lab def sigdt 1 "noncamp" 3 "camp" 4 "national"
lab val sigdt sigdt

gen sighh = hhh_gender
lab val sighh hhm_gender

gen sigidp = comparisonidp
lab def sigidp 1 "noncamp" 2 "camp2016" 3 "camp" 4 "host" 5 "nonhost"
lab val sigidp sigidp

*5. Merge in essential variables from hhm. 
cap drop age_dependency_ratio
*No longer assert(match), since 3 single-EA strata were dropped.
merge 1:1 strata ea block hh using "${gsdTemp}/collapsedhhmdepratio.dta", nogen keepusing(age_dependency_ratio)
save "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", replace 

********************************************************
*Merge comparison groups to HHM
********************************************************
use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
*Removing assert(match), since 3 single-EA strata were dropped.
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", nogen keepusing(sigidp sighh sigdt comparisonidp urbanrural genidp quintileidp migr_idp reasonidp national)

*Prepare variables
recode age (0/14 = 1 "Under 15 years") ( 15/24 = 2 "15-24 years") (25/64 = 3 "25-64 years") (65/120 =4 "Above 64 years"), gen(age_g_idp) label(lage_g_idp)
*working age 
gen age_3_idp = age_g_idp
replace age_3_idp = age_3_idp -1 if inlist(age_3_idp, 3, 4)
lab def age3 1 "Below15" 2 "From15to64" 3 "Above64"
lab val age_3_idp age3

save "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", replace
