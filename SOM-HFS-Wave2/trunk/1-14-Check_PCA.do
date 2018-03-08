* Compare Wave 1 vs. Wave 2 - Urban/Rural and IDPs

set more off
set seed 23081980 
set sortseed 11041955

/*
*Open combined data set
use "${gsdData}/1-CleanTemp/hh_all.dta", clear
gen pweight=weight_adj*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)


*=====================================================================
* Prepare dataset for analysis
*=====================================================================
*Wave 1 
cap drop ind_profile
replace astrata=. if t==1
gen ind_profile="NW-Rural" if astrata==22
replace ind_profile="NE-Rural" if astrata==21
replace ind_profile="NW-Urban" if astrata==14 | astrata==15
replace ind_profile="NE-Urban" if astrata==12 | astrata==13 
replace ind_profile="Mogadishu" if astrata==11
replace ind_profile="IDP" if astrata==3

*Wave 2
assert strata>100 if t==0
replace ind_profile="Mogadishu"  if strata==37
replace ind_profile="NE-Urban" if strata==39 | strata==41 | strata==43
replace ind_profile="NE-Rural" if strata==38 | strata==40 | strata==42 
replace ind_profile="NW-Urban" if strata==45 | strata==49 | strata==51
replace ind_profile="NW-Urban" if type==1 & (strata==46 | strata==47)
replace ind_profile="NW-Rural" if strata==44 | strata==48 |  strata==50
replace ind_profile="NW-Rural" if type==2 & (strata==46 | strata==47)
replace ind_profile="IDP" if inlist(strata,1,2,3,4,5,6,7)
replace ind_profile="Nomad" if inlist(strata,8,9,10,12,13,14)
replace ind_profile="Central-Urban" if strata==26 | strata==28 |  strata==30
replace ind_profile="Central-Rural" if strata==25 | strata==27 |  strata==29
replace ind_profile="Jubbaland-Urban" if strata==31 | strata==33 |  strata==36
replace ind_profile="Jubbaland-Rural" if strata==32 | strata==34 |  strata==35
replace ind_profile="SouthWest-Urban" if strata==52 | strata==54 |  strata==57
replace ind_profile="SouthWest-Rural" if strata==53 | strata==55 |  strata==56
save "${gsdTemp}/hh_w1w2_comparison.dta", replace

**Check the interquartile range for weights in Wave 1 & 2
preserve
drop if type_idp_host==2
egen w1_mog=iqr(weight_adj) if t==0 & ind_profile=="Mogadishu"
egen w1_neu=iqr(weight_adj) if t==0 & ind_profile=="NE-Urban"
egen w1_ner=iqr(weight_adj) if t==0 & ind_profile=="NE-Rural"
egen w1_nwu=iqr(weight_adj) if t==0 & ind_profile=="NW-Urban"
egen w1_nwr=iqr(weight_adj) if t==0 & ind_profile=="NW-Rural"
egen w1_idp=iqr(weight_adj) if t==0 & ind_profile=="IDP"
egen w2_mog=iqr(weight_adj) if t==1 & ind_profile=="Mogadishu"
egen w2_neu=iqr(weight_adj) if t==1 & ind_profile=="NE-Urban"
egen w2_ner=iqr(weight_adj) if t==1 & ind_profile=="NE-Rural"
egen w2_nwu=iqr(weight_adj) if t==1 & ind_profile=="NW-Urban"
egen w2_nwr=iqr(weight_adj) if t==1& ind_profile=="NW-Rural"
egen w2_idp=iqr(weight_adj) if t==1 & ind_profile=="IDP"
gen x=1
collapse (max) w1_* w2_*, by(x)
restore

*=====================================================================
* Additional recode of variables that make sense between W1 and W2
*=====================================================================
*HHM level variables
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
gen child_boy=(gender==1) if age<=14 & !missing(gender) & !missing(age)
gen youth_male=(gender==1) if age>14 & age<=24 & !missing(gender) & !missing(age)
gen adult_male=(gender==1) if age>=25 & !missing(gender) & !missing(age)
collapse (sum) child_boy youth_male adult_male, by(t strata ea block hh)
save "${gsdTemp}/hhm_n_age_gender.dta", replace
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
replace literacy=. if age<30
bys t strata ea block hh: egen n_literate=sum(literacy) if !missing(literacy)
gen dum_iliterate_adult_hh=(n_literate==0) if !missing(n_literate)
gen pliteracy_25=n_literate/hhsize if !missing(literacy)
bys t strata ea block hh: egen n_dependent=sum(dependent)
collapse (max) n_literate dum_iliterate_adult_hh pliteracy_25 n_dependent, by(t strata ea block hh)
label var pliteracy_25 "Literacy HHM 30 years or more"
save "${gsdTemp}/hhm_literacy.dta", replace

*House type
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
gen house_type_comparable=.
replace house_type_comparable=1 if inlist(house_type,2,4)
replace house_type_comparable=2 if house_type==3
replace house_type_comparable=3 if inlist(house_type,1,5,6,1000)
label define lhouse_type_comparable 1 "Shared house/apartment" 2 "Separated house" 3 "Apartment/Buus/Bas/Cariish/Other"
label values house_type_comparable lhouse_type_comparable
label var house_type_comparable "Type of house (Comparable W1 & W2)"
*Tenure 
gen tenure_own_rent=(inlist(tenure,1,2)) if !missing(tenure)
label var tenure_own_rent "HH Own/Rent the dwelling" 
*Water
gen piped_water = water
replace piped_water= 1 if inlist(water,1,2)
replace piped_water=0 if inlist(water,3,4,5,.,.a,.b)
label var piped_water "HH has access to piped water"
*Treate water
gen protected_water=(treated_water==2) if !missing(treated_water)
label var protected_water "HH uses protected source of water"
*Cook wood and gas
gen cook_comparable=.
replace cook_comparable=1 if inlist(cook,1,3)
replace cook_comparable=2 if cook==2
replace cook_comparable=3 if cook_comparable==. & !missing(cook)
label define lcook_comparable 1 "Wood or Gas Stove" 2 "Charcoal Stove" 3 "Other"
label values cook_comparable lcook_comparable
label var cook_comparable "Cooking source (Comparable W1 & W2)"
*Improved sanitation
gen sanitation_comparable=1 if t==0 & toilet_type==2 | toilet_type==1
replace sanitation_comparable=1 if t==1 & inlist(toilet,1,3,6,7,8) 
replace sanitation_comparable=0 if sanitation_comparable==.
replace sanitation_comparable=. if t==0 & toilet_type>=. 
replace sanitation_comparable=. if t==1 & toilet>=.
label var sanitation_comparable "HH toilet Pit Latrine or Flush"

*Floor material
gen floor_comparable=1 if floor_material==1
replace floor_comparable=2 if floor_material==2 | floor_material==3
replace floor_comparable=3 if inlist(floor_material,4,1000)
label var floor_comparable "HH type of floor"
*Roof material
gen roof_metal=(roof_material==1)
label var roof_metal "HH with roof of metal"
*Include hhm level variables created 
merge 1:m t strata ea block hh using "${gsdTemp}/hhm_n_age_gender.dta", assert(match) nogen 
merge 1:m t strata ea block hh using "${gsdTemp}/hhm_literacy.dta", assert(match) nogen 

*Include a measure of households that have always live there
preserve 
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
bys t strata ea block hh: egen n_always=sum(hh_alwayslived)
gen x=1 if hh_alwayslived<.
bys t strata ea block hh: egen n_adult=sum(x)
gen prop_alwayslive=n_always/n_adult
collapse (max) prop_alwayslive, by(t strata ea block hh)
save "${gsdTemp}/hh_w1w2_alwayslive.dta", replace
restore
merge 1:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_alwayslive.dta", assert(match) nogen
save "${gsdTemp}/hh_w1w2_comparison.dta", replace


*=====================================================================
* HARMONISE W/SLHS 2013
*=====================================================================
*Check if the relevant files from the pipeline for SLHS 2013 have been saved in 1-CleanInput from Wave 1 of SHFS 2016
foreach dataset in "hh" "hhm" "food_consumption_clean" "paasche_r" "paasche_u" {
	capture confirm file "${gsdData}/1-CleanInput/SLHS2013/`dataset'.dta"
	if _rc==0 {
		display "No action needed"
    }
	else {
    display as error "Please include the files from SLHS 2013 pipeline first"
	error `dataset'
	}
}
* HH level data
use "${gsdData}/1-CleanInput/SLHS2013/hh.dta", clear
keep if urban==1
* Identify if household is displaced
gen migr_disp=S1_HH_TYPE==3
* Housing type
* - ISSUE: Cannot identify whether shared or not
gen house_type_comparable = 1 if inlist(S13_G01, 2)
replace house_type_comparable = 3 if inlist(S13_G01, 1,3,4,5,6,7)
* Water
gen piped_water = S13_G03A==2 
gen protected_water = inlist(S13_G03B, 1, 2)
* Cooking
gen cook_comparable = 1 if (S13_G04_1==1 | S13_G04_2==1 | S13_G04_3==1)
replace cook_comparable = 2 if S13_G04_5==1 
replace cook_comparable = 3 if mi(cook_comparable) & !mi(S13_G04_99)
* Toilet
gen sanitation_comparable=inlist(S13_G05, 1, 2)
* Floor
gen floor_comparable=1 if S13_G07==1
replace floor_comparable=2 if S13_G07==2 | S13_G07==3
replace floor_comparable=3 if inlist(S13_G07,4,1000)
* Roof 
gen roof_metal=(S13_G09==1)
* Rename critical variables
gen weight_cons = weight
ren (hsize hhid weight cluster) (hhsize hh weight_adj ea)
gen t = -1 
save "${gsdTemp}/hh_comparable_SLHS.dta", replace

*Poverty comparable to 2016
*Implicit scale factor between total consumption and comparable consumption 
use "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty_comparable_2013.dta", clear
keep strata ea block hh weight_cons hhsize hhweight team tc_imp
rename tc_imp tc_imp_comparable
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", nogen keep(match master) keepusing(type tc_imp)
rename tc_imp tc_imp_tot
svyset ea [pweight=hhweight], strata(strata)
*North West
sum tc_imp_tot [aweight=hhweight] if team==1 & (type==1 | type==2), d
gen mean_cons_tot_sld=r(mean)
sum tc_imp_comparable [aweight=hhweight] if team==1 & (type==1 | type==2), d
gen mean_cons_comparable_sld=r(mean)
gen scale_factor_sld=mean_cons_comparable_sld/mean_cons_tot_sld
*Urban
sum tc_imp_tot [aweight=hhweight] if team==1 & type==1, d
gen mean_cons_tot_urban=r(mean)
sum tc_imp_comparable [aweight=hhweight] if team==1 & type==1, d
gen mean_cons_comparable_urban=r(mean)
gen scale_factor_urban=mean_cons_comparable_urban/mean_cons_tot_urban
keep type scale_factor_sld scale_factor_urban 
bys type: keep if _n==1
save "${gsdTemp}/scale_factor_sld_2013vs2016.dta", replace

*Poverty headcount 2013 (comparable consumption and scaled poverty line)
use "${gsdData}/1-CleanInput/SLHS2013/hh.dta", clear
keep if urban==1
gen type=urban 
replace type=2 if type==0 
merge m:1 type using "${gsdTemp}/scale_factor_sld_2013vs2016.dta", nogen keep(match) 
gen hhweight=weight*S1_HHSIZE
svyset cluster [pweight=hhweight], strata(strata)
*Convert consumption to real per capita per day 
gen cons_aggr=(rpce*1000*12)/365
*Define the poverty line 
*in 2011, $1 USD PPP was worth 10,731 Somali Shillings PPP, & general inflation in Somaliland from 2011 to 2013 was 58.4%
*so 16,996.43 Somali Shillings PPP (2013 Somaliland prices) could buy $1 USD PPP (2011)
*thus $1.90 USD PPP 2011 corresponds to 32,293.22 Somali Shillings PPP
*then we convert to USD using an average exchange rate of 20,360.53 Somali Shillings per USD in 2013, that is $1.5861 USD PPP (2013 Somaliland prices)
*to finally convert to Somaliland Shillings using an average exchange rate of 6,733.69 Somaliland Shillings per USD in 2013, which gives us a poverty line of 10,680.11 Somaliland Shillings PPP (2013 Somaliland prices) per person per day, equivalent to $1.90 USD PPP (2011) 
gen plinePPP=10680.1112312
gen scaled_plinePPP=plinePPP*scale_factor_urban if type==1
*Define poor and non-poor households in the same way as 2016
gen poorPPP_prob = cons_aggr < scaled_plinePPP 
rename hhid hh
keep hh poorPPP_prob
save "${gsdTemp}/poverty_comparable_SLHS.dta", replace
*Include poverty in the previous hh dataset 
use "${gsdTemp}/hh_comparable_SLHS.dta", clear
merge 1:1 hh using "${gsdTemp}/poverty_comparable_SLHS.dta", nogen assert(match)
keep t ea poorPPP_prob strata region hh hhsize weight* migr_disp house_type_comparable piped_water protected_water cook_comparable sanitation_comparable floor_comparable roof_metal
save "${gsdTemp}/hh_comparable_SLHS.dta", replace

* HHM level
use "${gsdData}/1-CleanInput/SLHS2013/hhm.dta", clear
keep if urban==1
gen hhh_age = S3_A06_1 if S3_A05==1
gen hhh_gender = S3_A04==1 if S3_A05==1
ren lit_any literacy
gen child_boy=(S3_A04==1) if S3_A06_1<=14 & !missing(S3_A04) & !missing(S3_A06_1)
gen youth_male=(S3_A04==1) if S3_A06_1>14 & S3_A06_1<=24 & !missing(S3_A04) & !missing(S3_A06_1)
gen adult_male=(S3_A04==1) if S3_A06_1>=25 & !missing(S3_A04) & !missing(S3_A06_1)
collapse (sum) child_boy youth_male adult_male (min) hhh_age hhh_gender, by(strata hhid)
ren hhid hh
save "${gsdTemp}/SLSH-hhm_n_age_gender.dta", replace

use "${gsdData}/1-CleanInput/SLHS2013/hhm.dta", clear
keep if urban==1
ren lit_any literacy
ren hsize hhsize
bys strata hhid: egen n_literate=sum(literacy) if !missing(literacy)
gen dum_iliterate_adult_hh=(n_literate==0) if !missing(n_literate)
gen pliteracy_25=n_literate/hhsize if !missing(literacy)
gen dependent = S3_A06_1<15 | S3_A06_1>64
gen working_age = inrange(S3_A06_1, 15, 64)
bys strata hhid: egen n_dependent=sum(dependent)
recode S3_A04 (1=1 "Male") (2=0 "Female"), gen(gender)
gen emp_7d = unemployed==0 & !mi(unemployed) & inrange(S3_A06_1, 15, 55)
ren hhid hh
save "${gsdTemp}/SLSH-hhm_recode.dta", replace
replace literacy=. if S3_A06_1<30
collapse (max) n_literate dum_iliterate_adult_hh pliteracy_25 n_dependent lfp_7d_hh=lfp emp_7d_hh=emp_7d (mean) pgender=gender pworking_age=working_age, by(strata hh)
label var pliteracy_25 "Literacy HHM 30 years or more"
save "${gsdTemp}/SLSH-hhm_literacy.dta", replace

*Include a measure of households that have always live there
use "${gsdData}/1-CleanInput/SLHS2013/hhm.dta", clear
keep if urban==1
bys strata hhid: egen n_always=sum(S3_AB02) if S3_A06_1>=15
gen adult = S3_A06_1>=15
bys strata hhid: egen n_adult=sum(adult)
gen prop_alwayslive=n_always/n_adult
collapse (max) prop_alwayslive, by(strata hhid)
ren hhid hh
save "${gsdTemp}/SLSH-hh_w1w2_alwayslive.dta", replace

* Further HHM-level data
use "${gsdTemp}/SLSH-hhm_recode.dta", clear
ren (S3_AGE_5 S3_A06_1 cluster) (age_cat_narrow age ea)
keep dependent gender age hh ea strata age_cat_narrow literacy
recode age_cat_narrow (19=18)
replace literacy=. if age<6
label drop AGE_5 
gen t = -1
save "${gsdTemp}/SLSH-hhm_comparable.dta", replace

* Merge it all together
use "${gsdTemp}/hh_comparable_SLHS.dta", clear
merge 1:1 strata hh using "${gsdTemp}/SLSH-hhm_literacy.dta", assert(match) nogen
merge 1:1 strata hh using "${gsdTemp}/SLSH-hh_w1w2_alwayslive.dta", assert(match) nogen
merge 1:1 strata hh using "${gsdTemp}/SLSH-hhm_n_age_gender.dta", assert(match) nogen
gen ind_profile="NW-Urban"
save "${gsdTemp}/hh_SLHS_comparison.dta", replace
use "${gsdTemp}/hh_w1w2_comparison.dta", clear
append using "${gsdTemp}/hh_SLHS_comparison.dta"
la def lt -1 "SLHS" 0 "Wave 1" 1 "Wave 2", replace
la val t lt
cap drop pweight

* Prepare variables of interest that aren't yet in the right format
*Housingtype: make wave 2 comparable to wave 1
tab house_type, gen(house_type__)
*Cooking source
drop cooking 
ren cook2 cooking
ta cooking, gen(cooking__)
*Water
ta water, gen(water__)
*Tenure
ta tenure1, gen(tenure__)
*Floor
ta floor_material, gen(floor__)
*Roof
ta roof_material, gen(roof__) 

*Include dummy for categorical variables
ta house_type_comparable, gen(house_type_comparable__)
ta cook_comparable, gen(cook_comparable)
ta floor_comparable, gen(floor_comparable)

* replace in SLHS to show missing
replace tenure_own_rent = -99 if t==-1

*Fix labels
la var hhsize "Household size"
foreach i of varlist cooking__* water__* tenure__* floor__* roof__* house_type_comparable__* cook_comparable* floor_comparable*{
local a : variable label `i'
local a: subinstr local a "==" ": "
label var `i' "`a'"
}
la var n_dependent "No. Dependents"
la var dum_iliterate_adult_hh "All illiterate adults"
la var n_literate "No. Literate"
la var adult_male "No. Adult males"
la var youth_male "No. Youth males"
la var child_boy "No. Child boys"
save "${gsdTemp}/hh_SLHSw1w2_comparison.dta", replace




*=====================================================================
* ANALYSIS FOR URBAN AREAS (WITHOUT PUNTLAND)
*=====================================================================
//CREATE DATASETS FOR EACH OF THE 5 SCENARIOS 
* Step 1: Prepare data sets
//V1 Case: Including IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban") & t>=0
save "${gsdTemp}/hh_comparison_Urban_NoPL_V1.dta", replace

//V2 Case: Excluding IDPs/Migrants / Including Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban") & t>=0
* Exclude IDPs
drop if migr_idp==1
tab t, m
save "${gsdTemp}/hh_comparison_Urban_NoPL_V2.dta", replace

//V3 Case: Excluding IDPs/Migrants + Born Outside / Including  Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban") & t>=0
* Exclude IDPs + Born Outside
drop if migr_idp==1
drop if hhh_outstate==1
tab t, m
save "${gsdTemp}/hh_comparison_Urban_NoPL_V3.dta", replace

//V4 Case: Excluding IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban") & t>=0
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
save "${gsdTemp}/hh_comparison_Urban_NoPL_V4.dta", replace

//V5 Case: Excluding IDPs/Migrants + Born Outside + Not always live there + self-reported drought shock
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban") & t>=0
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH + self-reported drought shock
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
drop if shocks0__1==1
tab t, m
save "${gsdTemp}/hh_comparison_Urban_NoPL_V5.dta", replace


* Implement extraction of statistics
forvalues k = 1/5 {
	use "${gsdTemp}/hh_comparison_Urban_NoPL_V`k'.dta", clear
	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
	local i=1
	svy: mean poorPPP_prob, over(t)
	test _subpop_1 = _subpop_2
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "Poverty"
	putexcel B`i' =`r(p)'

	*Variables of interest
	drop pweight
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
	foreach v of varlist $vars {
		noisily di `v'
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		local i=`i'+1
		putexcel A`i' ="`l'"
		putexcel B`i' =`r(p)'
	}


	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value) 
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
	drop v3 
    gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
	drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_`k'") sheetmodify cell(B3) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
}

*Check average age and age distribution * 
* Append the data first
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
append using "${gsdTemp}/SLSH-hhm_comparable.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
save "${gsdTemp}/hhm_SLw1w2.dta", replace

foreach k in 1 2 3 4 5 {
	use "${gsdTemp}/hh_comparison_Urban_NoPL_V`k'.dta", clear
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow dependent gender)

	* Variables of interest
	cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
	local i=1
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	replace literacy=. if age<30
	global hhmvars age gender dependent literacy
	foreach v of varlist $hhmvars {
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
		local i=`i'+1
		putexcel A`i' = "`l'"
		putexcel B`i' =`r(p)'
	}
	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value)
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
    drop v3
	gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
    drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_`k'_2") sheetreplace first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

	* Age distribution
	use "${gsdTemp}/hh_comparison_Urban_NoPL_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w1") npos(col) replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w2") npos(col) replace ptotal(none) 
	drop if mi(literacy)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls" if t==0, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w1")  replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls" if t==1, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w2")  replace ptotal(none) 
	insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4 
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(D6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(F6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(J7) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(L7) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
}

*Include the average number of each item owned
use "${gsdData}/1-CleanOutput/assets.dta", clear
*Wave 2
gen t=1
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(match) keepusing(ind_profile weight_cons weight_adj hhsize)
*Include owning zero assets 
replace own_n=0 if own==0
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
save "${gsdTemp}/assets_nwurban_w2.dta", replace
*Wave 1 ID zeros
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta"
keep if _merge==2 | (strata==101 & ea==85 & block==11 & hh==4)
keep strata ea block hh itemid own_n
replace itemid=1 if itemid==.
reshape wide own_n, i(strata ea block hh) j(itemid)
reshape long
drop if strata==101 & ea==85 & block==11 & hh==4
replace own_n=0 if own_n==.
save "${gsdTemp}/assets_nwurban_w2_noassets.dta", replace
*Wave 1 
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
keep strata ea block hh itemid own_n
append using "${gsdTemp}/assets_nwurban_w2_noassets.dta"
replace own_n=0 if own_n==.
gen t=0
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(master match) keepusing(ind_profile weight_cons weight_adj hhsize)
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
append using "${gsdTemp}/assets_nwurban_w2.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
*Restrict to the relevant subsample
merge m:1 t strata ea block hh using "${gsdTemp}/hh_comparison_Urban_NoPL_V1.dta", nogen keep(match)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tab itemid, gen(item_)
foreach k of varlist item_* {
local a : variable label `k'
local a : subinstr local a "itemid==" ""
label var `k' "`a'"
}
drop if mi(own_n)
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
preserve
local i=1
levelsof itemid, local(items) 
qui foreach item of local items {
	su own_n
	local l : variable label item_`item'
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if itemid==`item', svy sum c(mean own_n) sebnone f(5) h1("`l'") append ptotal(none)
	svy: mean own_n if itemid==`item', over(t)
	cap test _subpop_1==_subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "`l'"
	cap putexcel B`i' =`r(p)'
	local i=`i'+1
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
gen n=_n
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="t"
gen even = !mod(_n,2)
gen n=_n  
replace n=n-even 
gen n2=(n+1)/2 
drop n even 
rename (n2 v1) (n v1_old) 
gen v1=0 if v1_old=="Wave 1"
replace v1=1 if v1_old=="Wave 2"
drop v1_old 
reshape wide v2, i(n) j(v1)
rename (v20 v21) (v2 v3)
la var v2 "Wave 1"
la var v3 "Wave 2"
merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
drop n
la var v1 "Variable of interest"
order  v1 v2 v3
export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_6") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
restore
*Check median values
levelsof itemid, local(items) 
qui foreach item of local items {
	preserve 
	keep if itemid==`item'
	collapse (median) own_n [aweight=weight_adj], by(t)
	gen itemid=`item'
	reshape wide own_n, i(itemid) j(t)
	save "${gsdTemp}/W1W2-comparison_assets_`item'.dta", replace
	restore
}
use "${gsdTemp}/W1W2-comparison_assets_1.dta", clear
qui forval i=2/37 {
	append using "${gsdTemp}/W1W2-comparison_assets_`i'.dta"
}
export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_7") sheetmodify cell(B3) first(varlabels)

*Include information on assets sold in Wave 2
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Urban_NoPL_V1.dta", clear
gen pweight=weight_adj*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
gen sell_assets=(inlist(cop_sellassets,1,3)) if !missing(cop_sellassets)
tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if t>=0, svy sum c(mean sell_assets) sebnone f(5) h1("`l'") replace ptotal(none)
svy: mean sell_assets if t>=0, over(t)
cap test _subpop_1==_subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", replace
putexcel A1 = "Sell_Assets"
cap putexcel B1 =`r(p)'
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
gen v1="Sell_Assets"
merge m:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
duplicates drop
export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_7_2") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

*Population pyramid
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Urban_NoPL_V1.dta", replace
* merge with hhm data set
merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(gender age literacy age_cat_narrow)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc) f(5) sebnone h1("Age Distribution, w1") npos(col) replace ptotal(none) 
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc) f(5) sebnone h1("Age Distribution, w2") npos(col) replace ptotal(none) 
insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4 
export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_8") sheetmodify cell(b29) first(varlabels)
insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4
export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban-NoPL_v1.xlsx", sheet("Raw_8") sheetmodify cell(b56) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"




*=====================================================================
* ANALYSIS FOR URBAN AREAS (WITH PUNTLAND)
*=====================================================================
//CREATE DATASETS FOR EACH OF THE 5 SCENARIOS 
* Step 1: Prepare data sets
//V1 Case: Including IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NE-Urban") & t>=0
save "${gsdTemp}/hh_comparison_Urban_V1.dta", replace

//V2 Case: Excluding IDPs/Migrants / Including Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NE-Urban") & t>=0
* Exclude IDPs
drop if migr_idp==1
tab t, m
save "${gsdTemp}/hh_comparison_Urban_V2.dta", replace

//V3 Case: Excluding IDPs/Migrants + Born Outside / Including  Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NE-Urban") & t>=0
* Exclude IDPs + Born Outside
drop if migr_idp==1
drop if hhh_outstate==1
tab t, m
save "${gsdTemp}/hh_comparison_Urban_V3.dta", replace

//V4 Case: Excluding IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NE-Urban") & t>=0
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
save "${gsdTemp}/hh_comparison_Urban_V4.dta", replace

//V5 Case: Excluding IDPs/Migrants + Born Outside + Not always live there + self-reported drought shock
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NE-Urban") & t>=0
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH + self-reported drought shock
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
drop if shocks0__1==1
tab t, m
save "${gsdTemp}/hh_comparison_Urban_V5.dta", replace


* Implement extraction of statistics
forvalues k = 1/5 {
	use "${gsdTemp}/hh_comparison_Urban_V`k'.dta", clear
	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
	local i=1
	svy: mean poorPPP_prob, over(t)
	test _subpop_1 = _subpop_2
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "Poverty"
	putexcel B`i' =`r(p)'

	*Variables of interest
	drop pweight
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
	foreach v of varlist $vars {
		noisily di `v'
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		local i=`i'+1
		putexcel A`i' ="`l'"
		putexcel B`i' =`r(p)'
	}


	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value) 
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
	drop v3 
    gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
	drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_`k'") sheetmodify cell(B3) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
}

*Check average age and age distribution * 
* Append the data first
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
append using "${gsdTemp}/SLSH-hhm_comparable.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
save "${gsdTemp}/hhm_SLw1w2.dta", replace

foreach k in 1 2 3 4 5 {
	use "${gsdTemp}/hh_comparison_Urban_V`k'.dta", clear
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow dependent gender)

	* Variables of interest
	cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
	local i=1
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	replace literacy=. if age<30
	global hhmvars age gender dependent literacy
	foreach v of varlist $hhmvars {
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
		local i=`i'+1
		putexcel A`i' = "`l'"
		putexcel B`i' =`r(p)'
	}
	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value)
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
    drop v3
	gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
    drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_`k'_2") sheetreplace first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

	* Age distribution
	use "${gsdTemp}/hh_comparison_Urban_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w1") npos(col) replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w2") npos(col) replace ptotal(none) 
	drop if mi(literacy)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls" if t==0, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w1")  replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls" if t==1, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w2")  replace ptotal(none) 
	insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4 
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(D6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(F6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(J7) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(L7) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
}

*Include the average number of each item owned
use "${gsdData}/1-CleanOutput/assets.dta", clear
*Wave 2
gen t=1
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(match) keepusing(ind_profile weight_cons weight_adj hhsize)
*Include owning zero assets 
replace own_n=0 if own==0
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
save "${gsdTemp}/assets_nwurban_w2.dta", replace
*Wave 1 ID zeros
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta"
keep if _merge==2 | (strata==101 & ea==85 & block==11 & hh==4)
keep strata ea block hh itemid own_n
replace itemid=1 if itemid==.
reshape wide own_n, i(strata ea block hh) j(itemid)
reshape long
drop if strata==101 & ea==85 & block==11 & hh==4
replace own_n=0 if own_n==.
save "${gsdTemp}/assets_nwurban_w2_noassets.dta", replace
*Wave 1 
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
keep strata ea block hh itemid own_n
append using "${gsdTemp}/assets_nwurban_w2_noassets.dta"
replace own_n=0 if own_n==.
gen t=0
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(master match) keepusing(ind_profile weight_cons weight_adj hhsize)
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
append using "${gsdTemp}/assets_nwurban_w2.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
*Restrict to the relevant subsample
merge m:1 t strata ea block hh using "${gsdTemp}/hh_comparison_Urban_V1.dta", nogen keep(match)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tab itemid, gen(item_)
foreach k of varlist item_* {
local a : variable label `k'
local a : subinstr local a "itemid==" ""
label var `k' "`a'"
}
drop if mi(own_n)
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
preserve
local i=1
levelsof itemid, local(items) 
qui foreach item of local items {
	su own_n
	local l : variable label item_`item'
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if itemid==`item', svy sum c(mean own_n) sebnone f(5) h1("`l'") append ptotal(none)
	svy: mean own_n if itemid==`item', over(t)
	cap test _subpop_1==_subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "`l'"
	cap putexcel B`i' =`r(p)'
	local i=`i'+1
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
gen n=_n
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="t"
gen even = !mod(_n,2)
gen n=_n  
replace n=n-even 
gen n2=(n+1)/2 
drop n even 
rename (n2 v1) (n v1_old) 
gen v1=0 if v1_old=="Wave 1"
replace v1=1 if v1_old=="Wave 2"
drop v1_old 
reshape wide v2, i(n) j(v1)
rename (v20 v21) (v2 v3)
la var v2 "Wave 1"
la var v3 "Wave 2"
merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
drop n
la var v1 "Variable of interest"
order  v1 v2 v3
export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_6") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
restore
*Check median values
levelsof itemid, local(items) 
qui foreach item of local items {
	preserve 
	keep if itemid==`item'
	collapse (median) own_n [aweight=weight_adj], by(t)
	gen itemid=`item'
	reshape wide own_n, i(itemid) j(t)
	save "${gsdTemp}/W1W2-comparison_assets_`item'.dta", replace
	restore
}
use "${gsdTemp}/W1W2-comparison_assets_1.dta", clear
qui forval i=2/37 {
	append using "${gsdTemp}/W1W2-comparison_assets_`i'.dta"
}
export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_7") sheetmodify cell(B3) first(varlabels)

*Include information on assets sold in Wave 2
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Urban_V1.dta", clear
gen pweight=weight_adj*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
gen sell_assets=(inlist(cop_sellassets,1,3)) if !missing(cop_sellassets)
tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if t>=0, svy sum c(mean sell_assets) sebnone f(5) h1("`l'") replace ptotal(none)
svy: mean sell_assets if t>=0, over(t)
cap test _subpop_1==_subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", replace
putexcel A1 = "Sell_Assets"
cap putexcel B1 =`r(p)'
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
gen v1="Sell_Assets"
merge m:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
duplicates drop
export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_7_2") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

*Population pyramid
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Urban_V1.dta", replace
* merge with hhm data set
merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(gender age literacy age_cat_narrow)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc) f(5) sebnone h1("Age Distribution, w1") npos(col) replace ptotal(none) 
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc) f(5) sebnone h1("Age Distribution, w2") npos(col) replace ptotal(none) 
insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4 
export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_8") sheetmodify cell(b29) first(varlabels)
insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4
export excel using "${gsdShared}/2-Output/W1W2-comparison_Urban_v1.xlsx", sheet("Raw_8") sheetmodify cell(b56) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"






*=====================================================================
* ANALYSIS FOR RURAL AREAS (WITHOUT PUNTLAND)
*=====================================================================
//CREATE DATASETS FOR EACH OF THE 5 SCENARIOS 
* Step 1: Prepare data sets
//V1 Case: Including IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"NW-Rural") & t>=0
save "${gsdTemp}/hh_comparison_Rural_NoPL_V1.dta", replace

//V2 Case: Excluding IDPs/Migrants / Including Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"NW-Rural") & t>=0
* Exclude IDPs
drop if migr_idp==1
tab t, m
save "${gsdTemp}/hh_comparison_Rural_NoPL_V2.dta", replace

//V3 Case: Excluding IDPs/Migrants + Born Outside / Including  Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"NW-Rural") & t>=0
* Exclude IDPs + Born Outside
drop if migr_idp==1
drop if hhh_outstate==1
tab t, m
save "${gsdTemp}/hh_comparison_Rural_NoPL_V3.dta", replace

//V4 Case: Excluding IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"NW-Rural") & t>=0
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
save "${gsdTemp}/hh_comparison_Rural_NoPL_V4.dta", replace

//V5 Case: Excluding IDPs/Migrants + Born Outside + Not always live there + self-reported drought shock
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"NW-Rural") & t>=0
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH + self-reported drought shock
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
drop if shocks0__1==1
tab t, m
save "${gsdTemp}/hh_comparison_Rural_NoPL_V5.dta", replace


* Implement extraction of statistics
forvalues k = 1/5 {
	use "${gsdTemp}/hh_comparison_Rural_NoPL_V`k'.dta", clear
	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
	local i=1
	svy: mean poorPPP_prob, over(t)
	test _subpop_1 = _subpop_2
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "Poverty"
	putexcel B`i' =`r(p)'

	*Variables of interest
	drop pweight
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
	foreach v of varlist $vars {
		noisily di `v'
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		local i=`i'+1
		putexcel A`i' ="`l'"
		putexcel B`i' =`r(p)'
	}


	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value) 
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
	drop v3 
    gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
	drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_`k'") sheetmodify cell(B3) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
}

*Check average age and age distribution * 
* Append the data first
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
append using "${gsdTemp}/SLSH-hhm_comparable.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
save "${gsdTemp}/hhm_SLw1w2.dta", replace

foreach k in 1 2 3 4 5 {
	use "${gsdTemp}/hh_comparison_Rural_NoPL_V`k'.dta", clear
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow dependent gender)

	* Variables of interest
	cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
	local i=1
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	replace literacy=. if age<30
	global hhmvars age gender dependent literacy
	foreach v of varlist $hhmvars {
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
		local i=`i'+1
		putexcel A`i' = "`l'"
		putexcel B`i' =`r(p)'
	}
	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value)
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
    drop v3
	gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
    drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_`k'_2") sheetreplace first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

	* Age distribution
	use "${gsdTemp}/hh_comparison_Rural_NoPL_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w1") npos(col) replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w2") npos(col) replace ptotal(none) 
	drop if mi(literacy)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls" if t==0, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w1")  replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls" if t==1, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w2")  replace ptotal(none) 
	insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4 
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(D6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(F6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(J7) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(L7) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
}

*Include the average number of each item owned
use "${gsdData}/1-CleanOutput/assets.dta", clear
*Wave 2
gen t=1
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(match) keepusing(ind_profile weight_cons weight_adj hhsize)
*Include owning zero assets 
replace own_n=0 if own==0
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
save "${gsdTemp}/assets_nwurban_w2.dta", replace
*Wave 1 ID zeros
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta"
keep if _merge==2 | (strata==101 & ea==85 & block==11 & hh==4)
keep strata ea block hh itemid own_n
replace itemid=1 if itemid==.
reshape wide own_n, i(strata ea block hh) j(itemid)
reshape long
drop if strata==101 & ea==85 & block==11 & hh==4
replace own_n=0 if own_n==.
save "${gsdTemp}/assets_nwurban_w2_noassets.dta", replace
*Wave 1 
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
keep strata ea block hh itemid own_n
append using "${gsdTemp}/assets_nwurban_w2_noassets.dta"
replace own_n=0 if own_n==.
gen t=0
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(master match) keepusing(ind_profile weight_cons weight_adj hhsize)
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
append using "${gsdTemp}/assets_nwurban_w2.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
*Restrict to the relevant subsample
merge m:1 t strata ea block hh using "${gsdTemp}/hh_comparison_Rural_NoPL_V1.dta", nogen keep(match)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tab itemid, gen(item_)
foreach k of varlist item_* {
local a : variable label `k'
local a : subinstr local a "itemid==" ""
label var `k' "`a'"
}
drop if mi(own_n)
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
preserve
local i=1
levelsof itemid, local(items) 
qui foreach item of local items {
	su own_n
	local l : variable label item_`item'
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if itemid==`item', svy sum c(mean own_n) sebnone f(5) h1("`l'") append ptotal(none)
	svy: mean own_n if itemid==`item', over(t)
	cap test _subpop_1==_subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "`l'"
	cap putexcel B`i' =`r(p)'
	local i=`i'+1
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
gen n=_n
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="t"
gen even = !mod(_n,2)
gen n=_n  
replace n=n-even 
gen n2=(n+1)/2 
drop n even 
rename (n2 v1) (n v1_old) 
gen v1=0 if v1_old=="Wave 1"
replace v1=1 if v1_old=="Wave 2"
drop v1_old 
reshape wide v2, i(n) j(v1)
rename (v20 v21) (v2 v3)
la var v2 "Wave 1"
la var v3 "Wave 2"
merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
drop n
la var v1 "Variable of interest"
order  v1 v2 v3
export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_6") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
restore
*Check median values
levelsof itemid, local(items) 
qui foreach item of local items {
	preserve 
	keep if itemid==`item'
	collapse (median) own_n [aweight=weight_adj], by(t)
	gen itemid=`item'
	reshape wide own_n, i(itemid) j(t)
	save "${gsdTemp}/W1W2-comparison_assets_`item'.dta", replace
	restore
}
use "${gsdTemp}/W1W2-comparison_assets_1.dta", clear
qui forval i=2/37 {
	append using "${gsdTemp}/W1W2-comparison_assets_`i'.dta"
}
export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_7") sheetmodify cell(B3) first(varlabels)

*Include information on assets sold in Wave 2
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Rural_NoPL_V1.dta", clear
gen pweight=weight_adj*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
gen sell_assets=(inlist(cop_sellassets,1,3)) if !missing(cop_sellassets)
tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if t>=0, svy sum c(mean sell_assets) sebnone f(5) h1("`l'") replace ptotal(none)
svy: mean sell_assets if t>=0, over(t)
cap test _subpop_1==_subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", replace
putexcel A1 = "Sell_Assets"
cap putexcel B1 =`r(p)'
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
gen v1="Sell_Assets"
merge m:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
duplicates drop
export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_7_2") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

*Population pyramid
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Rural_NoPL_V1.dta", replace
* merge with hhm data set
merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(gender age literacy age_cat_narrow)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc) f(5) sebnone h1("Age Distribution, w1") npos(col) replace ptotal(none) 
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc) f(5) sebnone h1("Age Distribution, w2") npos(col) replace ptotal(none) 
insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4 
export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_8") sheetmodify cell(b29) first(varlabels)
insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4
export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural-NoPL_v1.xlsx", sheet("Raw_8") sheetmodify cell(b56) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"





*=====================================================================
* ANALYSIS FOR RURAL AREAS (WITH PUNTLAND)
*=====================================================================
//CREATE DATASETS FOR EACH OF THE 5 SCENARIOS 
* Step 1: Prepare data sets
//V1 Case: Including IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"NW-Rural","NE-Rural") & t>=0
save "${gsdTemp}/hh_comparison_Rural_V1.dta", replace

//V2 Case: Excluding IDPs/Migrants / Including Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"NW-Rural","NE-Rural") & t>=0
* Exclude IDPs
drop if migr_idp==1
tab t, m
save "${gsdTemp}/hh_comparison_Rural_V2.dta", replace

//V3 Case: Excluding IDPs/Migrants + Born Outside / Including  Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"NW-Rural","NE-Rural") & t>=0
* Exclude IDPs + Born Outside
drop if migr_idp==1
drop if hhh_outstate==1
tab t, m
save "${gsdTemp}/hh_comparison_Rural_V3.dta", replace

//V4 Case: Excluding IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"NW-Rural","NE-Rural") & t>=0
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
save "${gsdTemp}/hh_comparison_Rural_V4.dta", replace

//V5 Case: Excluding IDPs/Migrants + Born Outside + Not always live there + self-reported drought shock
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"NW-Rural","NE-Rural") & t>=0
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH + self-reported drought shock
drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
drop if shocks0__1==1
tab t, m
save "${gsdTemp}/hh_comparison_Rural_V5.dta", replace


* Implement extraction of statistics
forvalues k = 1/5 {
	use "${gsdTemp}/hh_comparison_Rural_V`k'.dta", clear
	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
	local i=1
	svy: mean poorPPP_prob, over(t)
	test _subpop_1 = _subpop_2
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "Poverty"
	putexcel B`i' =`r(p)'

	*Variables of interest
	drop pweight
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
	foreach v of varlist $vars {
		noisily di `v'
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		local i=`i'+1
		putexcel A`i' ="`l'"
		putexcel B`i' =`r(p)'
	}


	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value) 
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
	drop v3 
    gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
	drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_`k'") sheetmodify cell(B3) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
}

*Check average age and age distribution * 
* Append the data first
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
append using "${gsdTemp}/SLSH-hhm_comparable.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
save "${gsdTemp}/hhm_SLw1w2.dta", replace

foreach k in 1 2 3 4 5 {
	use "${gsdTemp}/hh_comparison_Rural_V`k'.dta", clear
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow dependent gender)

	* Variables of interest
	cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
	local i=1
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	replace literacy=. if age<30
	global hhmvars age gender dependent literacy
	foreach v of varlist $hhmvars {
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
		local i=`i'+1
		putexcel A`i' = "`l'"
		putexcel B`i' =`r(p)'
	}
	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value)
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
    drop v3
	gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
    drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_`k'_2") sheetreplace first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

	* Age distribution
	use "${gsdTemp}/hh_comparison_Rural_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w1") npos(col) replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w2") npos(col) replace ptotal(none) 
	drop if mi(literacy)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls" if t==0, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w1")  replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls" if t==1, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w2")  replace ptotal(none) 
	insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4 
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(D6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(F6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(J7) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(L7) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
}

*Include the average number of each item owned
use "${gsdData}/1-CleanOutput/assets.dta", clear
*Wave 2
gen t=1
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(match) keepusing(ind_profile weight_cons weight_adj hhsize)
*Include owning zero assets 
replace own_n=0 if own==0
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
save "${gsdTemp}/assets_nwurban_w2.dta", replace
*Wave 1 ID zeros
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta"
keep if _merge==2 | (strata==101 & ea==85 & block==11 & hh==4)
keep strata ea block hh itemid own_n
replace itemid=1 if itemid==.
reshape wide own_n, i(strata ea block hh) j(itemid)
reshape long
drop if strata==101 & ea==85 & block==11 & hh==4
replace own_n=0 if own_n==.
save "${gsdTemp}/assets_nwurban_w2_noassets.dta", replace
*Wave 1 
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
keep strata ea block hh itemid own_n
append using "${gsdTemp}/assets_nwurban_w2_noassets.dta"
replace own_n=0 if own_n==.
gen t=0
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(master match) keepusing(ind_profile weight_cons weight_adj hhsize)
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
append using "${gsdTemp}/assets_nwurban_w2.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
*Restrict to the relevant subsample
merge m:1 t strata ea block hh using "${gsdTemp}/hh_comparison_Rural_V1.dta", nogen keep(match)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tab itemid, gen(item_)
foreach k of varlist item_* {
local a : variable label `k'
local a : subinstr local a "itemid==" ""
label var `k' "`a'"
}
drop if mi(own_n)
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
preserve
local i=1
levelsof itemid, local(items) 
qui foreach item of local items {
	su own_n
	local l : variable label item_`item'
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if itemid==`item', svy sum c(mean own_n) sebnone f(5) h1("`l'") append ptotal(none)
	svy: mean own_n if itemid==`item', over(t)
	cap test _subpop_1==_subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "`l'"
	cap putexcel B`i' =`r(p)'
	local i=`i'+1
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
gen n=_n
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="t"
gen even = !mod(_n,2)
gen n=_n  
replace n=n-even 
gen n2=(n+1)/2 
drop n even 
rename (n2 v1) (n v1_old) 
gen v1=0 if v1_old=="Wave 1"
replace v1=1 if v1_old=="Wave 2"
drop v1_old 
reshape wide v2, i(n) j(v1)
rename (v20 v21) (v2 v3)
la var v2 "Wave 1"
la var v3 "Wave 2"
merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
drop n
la var v1 "Variable of interest"
order  v1 v2 v3
export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_6") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
restore
*Check median values
levelsof itemid, local(items) 
qui foreach item of local items {
	preserve 
	keep if itemid==`item'
	collapse (median) own_n [aweight=weight_adj], by(t)
	gen itemid=`item'
	reshape wide own_n, i(itemid) j(t)
	save "${gsdTemp}/W1W2-comparison_assets_`item'.dta", replace
	restore
}
use "${gsdTemp}/W1W2-comparison_assets_1.dta", clear
qui forval i=2/37 {
	append using "${gsdTemp}/W1W2-comparison_assets_`i'.dta"
}
export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_7") sheetmodify cell(B3) first(varlabels)

*Include information on assets sold in Wave 2
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Rural_V1.dta", clear
gen pweight=weight_adj*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
gen sell_assets=(inlist(cop_sellassets,1,3)) if !missing(cop_sellassets)
tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if t>=0, svy sum c(mean sell_assets) sebnone f(5) h1("`l'") replace ptotal(none)
svy: mean sell_assets if t>=0, over(t)
cap test _subpop_1==_subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", replace
putexcel A1 = "Sell_Assets"
cap putexcel B1 =`r(p)'
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
gen v1="Sell_Assets"
merge m:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
duplicates drop
export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_7_2") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

*Population pyramid
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Rural_V1.dta", replace
* merge with hhm data set
merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(gender age literacy age_cat_narrow)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc) f(5) sebnone h1("Age Distribution, w1") npos(col) replace ptotal(none) 
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc) f(5) sebnone h1("Age Distribution, w2") npos(col) replace ptotal(none) 
insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4 
export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_8") sheetmodify cell(b29) first(varlabels)
insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4
export excel using "${gsdShared}/2-Output/W1W2-comparison_Rural_V1.xlsx", sheet("Raw_8") sheetmodify cell(b56) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"







*=====================================================================
* ANALYSIS FOR IDPS (COMPARABLE)
*=====================================================================
//CREATE DATASETS FOR EACH OF THE 5 SCENARIOS 
*Check strata for IDPs in Wave 2
*use "${gsdTemp}/hh_final.dta", clear
* Step 1: Prepare data sets
//V1 Case: Including IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"IDP") & t>=0
drop if t==1 &  !inlist(strata,4,5,6) 
save "${gsdTemp}/hh_comparison_IDP_V1.dta", replace

//V2 Case: Excluding IDPs/Migrants / Including Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"IDP") & t>=0
drop if t==1 &  !inlist(strata,4,5,6) 
* Exclude IDPs
*drop if migr_idp==1
tab t, m
save "${gsdTemp}/hh_comparison_IDP_V2.dta", replace

//V3 Case: Excluding IDPs/Migrants + Born Outside / Including  Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"IDP") & t>=0
drop if t==1 &  !inlist(strata,4,5,6) 
* Exclude IDPs + Born Outside
*drop if migr_idp==1
drop if hhh_outstate==1
tab t, m
save "${gsdTemp}/hh_comparison_IDP_V3.dta", replace

//V4 Case: Excluding IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"IDP") & t>=0
drop if t==1 &  !inlist(strata,4,5,6) 
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH
*drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
save "${gsdTemp}/hh_comparison_IDP_V4.dta", replace

//V5 Case: Excluding IDPs/Migrants + Born Outside + Not always live there + self-reported drought shock
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"IDP") & t>=0
drop if t==1 &  !inlist(strata,4,5,6) 
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH + self-reported drought shock
*drop if migr_idp==1
drop if hhh_outstate==1
keep if prop_alwayslive==1
drop if shocks0__1==1
tab t, m
save "${gsdTemp}/hh_comparison_IDP_V5.dta", replace


* Implement extraction of statistics
forvalues k = 1/5 {
	use "${gsdTemp}/hh_comparison_IDP_V`k'.dta", clear
	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
	local i=1
	svy: mean poorPPP_prob, over(t)
	test _subpop_1 = _subpop_2
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "Poverty"
	putexcel B`i' =`r(p)'

	*Variables of interest
	drop pweight
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
	foreach v of varlist $vars {
		noisily di `v'
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		local i=`i'+1
		putexcel A`i' ="`l'"
		putexcel B`i' =`r(p)'
	}


	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value) 
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
	drop v3 
    gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
	drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_`k'") sheetmodify cell(B3) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
}

*Check average age and age distribution * 
* Append the data first
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
append using "${gsdTemp}/SLSH-hhm_comparable.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
save "${gsdTemp}/hhm_SLw1w2.dta", replace

foreach k in 1 2 3 4 5 {
	use "${gsdTemp}/hh_comparison_IDP_V`k'.dta", clear
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow dependent gender)

	* Variables of interest
	cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
	local i=1
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	replace literacy=. if age<30
	global hhmvars age gender dependent literacy
	foreach v of varlist $hhmvars {
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
		local i=`i'+1
		putexcel A`i' = "`l'"
		putexcel B`i' =`r(p)'
	}
	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value)
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
    drop v3
	gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
    drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_`k'_2") sheetreplace first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

	* Age distribution
	use "${gsdTemp}/hh_comparison_IDP_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w1") npos(col) replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w2") npos(col) replace ptotal(none) 
	drop if mi(literacy)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls" if t==0, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w1")  replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls" if t==1, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w2")  replace ptotal(none) 
	insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4 
	export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(D6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4
	export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(F6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(J7) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(L7) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
}

*Include the average number of each item owned
use "${gsdData}/1-CleanOutput/assets.dta", clear
*Wave 2
gen t=1
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(match) keepusing(ind_profile weight_cons weight_adj hhsize)
*Include owning zero assets 
replace own_n=0 if own==0
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
save "${gsdTemp}/assets_nwurban_w2.dta", replace
*Wave 1 ID zeros
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta"
keep if _merge==2 | (strata==101 & ea==85 & block==11 & hh==4)
keep strata ea block hh itemid own_n
replace itemid=1 if itemid==.
reshape wide own_n, i(strata ea block hh) j(itemid)
reshape long
drop if strata==101 & ea==85 & block==11 & hh==4
replace own_n=0 if own_n==.
save "${gsdTemp}/assets_nwurban_w2_noassets.dta", replace
*Wave 1 
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
keep strata ea block hh itemid own_n
append using "${gsdTemp}/assets_nwurban_w2_noassets.dta"
replace own_n=0 if own_n==.
gen t=0
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(master match) keepusing(ind_profile weight_cons weight_adj hhsize)
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
append using "${gsdTemp}/assets_nwurban_w2.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
*Restrict to the relevant subsample
merge m:1 t strata ea block hh using "${gsdTemp}/hh_comparison_IDP_V1.dta", nogen keep(match)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tab itemid, gen(item_)
foreach k of varlist item_* {
local a : variable label `k'
local a : subinstr local a "itemid==" ""
label var `k' "`a'"
}
drop if mi(own_n)
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
preserve
local i=1
levelsof itemid, local(items) 
qui foreach item of local items {
	su own_n
	local l : variable label item_`item'
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if itemid==`item', svy sum c(mean own_n) sebnone f(5) h1("`l'") append ptotal(none)
	svy: mean own_n if itemid==`item', over(t)
	cap test _subpop_1==_subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "`l'"
	cap putexcel B`i' =`r(p)'
	local i=`i'+1
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
gen n=_n
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="t"
gen even = !mod(_n,2)
gen n=_n  
replace n=n-even 
gen n2=(n+1)/2 
drop n even 
rename (n2 v1) (n v1_old) 
gen v1=0 if v1_old=="Wave 1"
replace v1=1 if v1_old=="Wave 2"
drop v1_old 
reshape wide v2, i(n) j(v1)
rename (v20 v21) (v2 v3)
la var v2 "Wave 1"
la var v3 "Wave 2"
merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
drop n
la var v1 "Variable of interest"
order  v1 v2 v3
export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_6") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
restore
*Check median values
levelsof itemid, local(items) 
qui foreach item of local items {
	preserve 
	keep if itemid==`item'
	collapse (median) own_n [aweight=weight_adj], by(t)
	gen itemid=`item'
	reshape wide own_n, i(itemid) j(t)
	save "${gsdTemp}/W1W2-comparison_assets_`item'.dta", replace
	restore
}
use "${gsdTemp}/W1W2-comparison_assets_1.dta", clear
qui forval i=2/37 {
	append using "${gsdTemp}/W1W2-comparison_assets_`i'.dta"
}
export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_7") sheetmodify cell(B3) first(varlabels)

*Include information on assets sold in Wave 2
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_IDP_V1.dta", clear
gen pweight=weight_adj*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
gen sell_assets=(inlist(cop_sellassets,1,3)) if !missing(cop_sellassets)
tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if t>=0, svy sum c(mean sell_assets) sebnone f(5) h1("`l'") replace ptotal(none)
svy: mean sell_assets if t>=0, over(t)
cap test _subpop_1==_subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", replace
putexcel A1 = "Sell_Assets"
cap putexcel B1 =`r(p)'
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
gen v1="Sell_Assets"
merge m:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
duplicates drop
export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_7_2") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

*Population pyramid
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_IDP_V1.dta", replace
* merge with hhm data set
merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(gender age literacy age_cat_narrow)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc) f(5) sebnone h1("Age Distribution, w1") npos(col) replace ptotal(none) 
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc) f(5) sebnone h1("Age Distribution, w2") npos(col) replace ptotal(none) 
insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4 
export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_8") sheetmodify cell(b29) first(varlabels)
insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4
export excel using "${gsdShared}/2-Output/W1W2-comparison_IDP_V1.xlsx", sheet("Raw_8") sheetmodify cell(b56) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
*/






*=====================================================================
* ANALYSIS FOR ALL AREAS (WITHOUT PUNTLAND + COMPARABLE IDPs)
*=====================================================================
//CREATE DATASETS FOR EACH OF THE 5 SCENARIOS 
*Check strata for IDPs in Wave 2
*use "${gsdTemp}/hh_final.dta", clear
* Step 1: Prepare data sets
//V1 Case: Including IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NW-Rural","IDP") & t>=0
drop if ind_profile=="IDP" & t==1 &  !inlist(strata,4,5,6) 
save "${gsdTemp}/hh_comparison_Overall-NoPL_V1.dta", replace

//V2 Case: Excluding IDPs/Migrants / Including Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NW-Rural","IDP") & t>=0
drop if ind_profile=="IDP" & t==1 &  !inlist(strata,4,5,6) 
* Exclude IDPs
drop if migr_idp==1
drop if t==0 & ind_profile=="IDP"
tab t, m
save "${gsdTemp}/hh_comparison_Overall-NoPL_V2.dta", replace

//V3 Case: Excluding IDPs/Migrants + Born Outside / Including  Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NW-Rural","IDP") & t>=0
drop if ind_profile=="IDP" & t==1 &  !inlist(strata,4,5,6) 
* Exclude IDPs + Born Outside
drop if migr_idp==1
drop if t==0 & ind_profile=="IDP"
drop if hhh_outstate==1
tab t, m
save "${gsdTemp}/hh_comparison_Overall-NoPL_V3.dta", replace

//V4 Case: Excluding IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NW-Rural","IDP") & t>=0
drop if ind_profile=="IDP" & t==1 &  !inlist(strata,4,5,6) 
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH
drop if migr_idp==1
drop if t==0 & ind_profile=="IDP"
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
save "${gsdTemp}/hh_comparison_Overall-NoPL_V4.dta", replace

//V5 Case: Excluding IDPs/Migrants + Born Outside + Not always live there + self-reported drought shock
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NW-Rural","IDP") & t>=0
drop if ind_profile=="IDP" & t==1 &  !inlist(strata,4,5,6) 
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH + self-reported drought shock
drop if migr_idp==1
drop if t==0 & ind_profile=="IDP"
drop if hhh_outstate==1
keep if prop_alwayslive==1
drop if shocks0__1==1
tab t, m
save "${gsdTemp}/hh_comparison_Overall-NoPL_V5.dta", replace


* Implement extraction of statistics
forvalues k = 1/5 {
	use "${gsdTemp}/hh_comparison_Overall-NoPL_V`k'.dta", clear
	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
	local i=1
	svy: mean poorPPP_prob, over(t)
	test _subpop_1 = _subpop_2
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "Poverty"
	putexcel B`i' =`r(p)'

	*Variables of interest
	drop pweight
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
	foreach v of varlist $vars {
		noisily di `v'
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		local i=`i'+1
		putexcel A`i' ="`l'"
		putexcel B`i' =`r(p)'
	}


	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value) 
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
	drop v3 
    gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
	drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_`k'") sheetmodify cell(B3) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
}

*Check average age and age distribution * 
* Append the data first
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
append using "${gsdTemp}/SLSH-hhm_comparable.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
save "${gsdTemp}/hhm_SLw1w2.dta", replace

foreach k in 1 2 3 4 5 {
	use "${gsdTemp}/hh_comparison_Overall-NoPL_V`k'.dta", clear
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow dependent gender)

	* Variables of interest
	cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
	local i=1
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	replace literacy=. if age<30
	global hhmvars age gender dependent literacy
	foreach v of varlist $hhmvars {
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
		local i=`i'+1
		putexcel A`i' = "`l'"
		putexcel B`i' =`r(p)'
	}
	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value)
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
    drop v3
	gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
    drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_`k'_2") sheetreplace first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

	* Age distribution
	use "${gsdTemp}/hh_comparison_Overall-NoPL_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w1") npos(col) replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w2") npos(col) replace ptotal(none) 
	drop if mi(literacy)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls" if t==0, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w1")  replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls" if t==1, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w2")  replace ptotal(none) 
	insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4 
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(D6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(F6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(J7) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(L7) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
}

*Include the average number of each item owned
use "${gsdData}/1-CleanOutput/assets.dta", clear
*Wave 2
gen t=1
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(match) keepusing(ind_profile weight_cons weight_adj hhsize)
*Include owning zero assets 
replace own_n=0 if own==0
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
save "${gsdTemp}/assets_nwurban_w2.dta", replace
*Wave 1 ID zeros
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta"
keep if _merge==2 | (strata==101 & ea==85 & block==11 & hh==4)
keep strata ea block hh itemid own_n
replace itemid=1 if itemid==.
reshape wide own_n, i(strata ea block hh) j(itemid)
reshape long
drop if strata==101 & ea==85 & block==11 & hh==4
replace own_n=0 if own_n==.
save "${gsdTemp}/assets_nwurban_w2_noassets.dta", replace
*Wave 1 
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
keep strata ea block hh itemid own_n
append using "${gsdTemp}/assets_nwurban_w2_noassets.dta"
replace own_n=0 if own_n==.
gen t=0
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(master match) keepusing(ind_profile weight_cons weight_adj hhsize)
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
append using "${gsdTemp}/assets_nwurban_w2.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
*Restrict to the relevant subsample
merge m:1 t strata ea block hh using "${gsdTemp}/hh_comparison_Overall-NoPL_V1.dta", nogen keep(match)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tab itemid, gen(item_)
foreach k of varlist item_* {
local a : variable label `k'
local a : subinstr local a "itemid==" ""
label var `k' "`a'"
}
drop if mi(own_n)
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
preserve
local i=1
levelsof itemid, local(items) 
qui foreach item of local items {
	su own_n
	local l : variable label item_`item'
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if itemid==`item', svy sum c(mean own_n) sebnone f(5) h1("`l'") append ptotal(none)
	svy: mean own_n if itemid==`item', over(t)
	cap test _subpop_1==_subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "`l'"
	cap putexcel B`i' =`r(p)'
	local i=`i'+1
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
gen n=_n
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="t"
gen even = !mod(_n,2)
gen n=_n  
replace n=n-even 
gen n2=(n+1)/2 
drop n even 
rename (n2 v1) (n v1_old) 
gen v1=0 if v1_old=="Wave 1"
replace v1=1 if v1_old=="Wave 2"
drop v1_old 
reshape wide v2, i(n) j(v1)
rename (v20 v21) (v2 v3)
la var v2 "Wave 1"
la var v3 "Wave 2"
merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
drop n
la var v1 "Variable of interest"
order  v1 v2 v3
export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_6") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
restore
*Check median values
levelsof itemid, local(items) 
qui foreach item of local items {
	preserve 
	keep if itemid==`item'
	collapse (median) own_n [aweight=weight_adj], by(t)
	gen itemid=`item'
	reshape wide own_n, i(itemid) j(t)
	save "${gsdTemp}/W1W2-comparison_assets_`item'.dta", replace
	restore
}
use "${gsdTemp}/W1W2-comparison_assets_1.dta", clear
qui forval i=2/37 {
	append using "${gsdTemp}/W1W2-comparison_assets_`i'.dta"
}
export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_7") sheetmodify cell(B3) first(varlabels)

*Include information on assets sold in Wave 2
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Overall-NoPL_V1.dta", clear
gen pweight=weight_adj*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
gen sell_assets=(inlist(cop_sellassets,1,3)) if !missing(cop_sellassets)
tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if t>=0, svy sum c(mean sell_assets) sebnone f(5) h1("`l'") replace ptotal(none)
svy: mean sell_assets if t>=0, over(t)
cap test _subpop_1==_subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", replace
putexcel A1 = "Sell_Assets"
cap putexcel B1 =`r(p)'
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
gen v1="Sell_Assets"
merge m:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
duplicates drop
export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_7_2") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

*Population pyramid
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Overall-NoPL_V1.dta", replace
* merge with hhm data set
merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(gender age literacy age_cat_narrow)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc) f(5) sebnone h1("Age Distribution, w1") npos(col) replace ptotal(none) 
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc) f(5) sebnone h1("Age Distribution, w2") npos(col) replace ptotal(none) 
insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4 
export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_8") sheetmodify cell(b29) first(varlabels)
insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4
export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall-NoPL_V1.xlsx", sheet("Raw_8") sheetmodify cell(b56) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"





*=====================================================================
* ANALYSIS FOR ALL AREAS (WITH PUNTLAND + COMPARABLE IDPs)
*=====================================================================
//CREATE DATASETS FOR EACH OF THE 5 SCENARIOS 
*Check strata for IDPs in Wave 2
*use "${gsdTemp}/hh_final.dta", clear
* Step 1: Prepare data sets
//V1 Case: Including IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NW-Rural","NE-Urban","NE-Rural","IDP") & t>=0
drop if ind_profile=="IDP" & t==1 &  !inlist(strata,4,5,6) 
save "${gsdTemp}/hh_comparison_Overall_V1.dta", replace

//V2 Case: Excluding IDPs/Migrants / Including Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NW-Rural","NE-Urban","NE-Rural","IDP") & t>=0
drop if ind_profile=="IDP" & t==1 &  !inlist(strata,4,5,6) 
* Exclude IDPs
drop if migr_idp==1
drop if t==0 & ind_profile=="IDP"
tab t, m
save "${gsdTemp}/hh_comparison_Overall_V2.dta", replace

//V3 Case: Excluding IDPs/Migrants + Born Outside / Including  Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NW-Rural","NE-Urban","NE-Rural","IDP") & t>=0
drop if ind_profile=="IDP" & t==1 &  !inlist(strata,4,5,6) 
* Exclude IDPs + Born Outside
drop if migr_idp==1
drop if t==0 & ind_profile=="IDP"
drop if hhh_outstate==1
tab t, m
save "${gsdTemp}/hh_comparison_Overall_V3.dta", replace

//V4 Case: Excluding IDPs/Migrants + Born Outside + Not always live there / Weights 
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NW-Rural","NE-Urban","NE-Rural","IDP") & t>=0
drop if ind_profile=="IDP" & t==1 &  !inlist(strata,4,5,6) 
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH
drop if migr_idp==1
drop if t==0 & ind_profile=="IDP"
drop if hhh_outstate==1
keep if prop_alwayslive==1
tab t, m
save "${gsdTemp}/hh_comparison_Overall_V4.dta", replace

//V5 Case: Excluding IDPs/Migrants + Born Outside + Not always live there + self-reported drought shock
use "${gsdTemp}/hh_SLHSw1w2_comparison.dta", clear
keep if inlist(ind_profile,"Mogadishu","NW-Urban","NW-Rural","NE-Urban","NE-Rural","IDP") & t>=0
drop if ind_profile=="IDP" & t==1 &  !inlist(strata,4,5,6) 
* Excluding IDPs/Migrants + Born Outside + Not always lived in current HH + self-reported drought shock
drop if migr_idp==1
drop if t==0 & ind_profile=="IDP"
drop if hhh_outstate==1
keep if prop_alwayslive==1
drop if shocks0__1==1
tab t, m
save "${gsdTemp}/hh_comparison_Overall_V5.dta", replace


* Implement extraction of statistics
forvalues k = 1/5 {
	use "${gsdTemp}/hh_comparison_Overall_V`k'.dta", clear
	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean poorPPP_prob ) sebnone f(3) h1("Poverty") npos(col) replace ptotal(none) 
	local i=1
	svy: mean poorPPP_prob, over(t)
	test _subpop_1 = _subpop_2
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "Poverty"
	putexcel B`i' =`r(p)'

	*Variables of interest
	drop pweight
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	global vars hhsize pgender hhh_age hhh_gender adult_male youth_male child_boy pworking_age n_dependent pliteracy_25 n_literate dum_iliterate_adult_hh lfp_7d_hh emp_7d_hh house_type_comparable__* tenure_own_rent floor_comparable* roof_metal  cook_comparable1 cook_comparable2 cook_comparable3 piped_water  protected_water sanitation_comparable
	foreach v of varlist $vars {
		noisily di `v'
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		local i=`i'+1
		putexcel A`i' ="`l'"
		putexcel B`i' =`r(p)'
	}


	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value) 
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
	drop v3 
    gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
	drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_`k'") sheetmodify cell(B3) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
}

*Check average age and age distribution * 
* Append the data first
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear
append using "${gsdTemp}/SLSH-hhm_comparable.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
save "${gsdTemp}/hhm_SLw1w2.dta", replace

foreach k in 1 2 3 4 5 {
	use "${gsdTemp}/hh_comparison_Overall_V`k'.dta", clear
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow dependent gender)

	* Variables of interest
	cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw4_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	cap erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
	local i=1
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	replace literacy=. if age<30
	global hhmvars age gender dependent literacy
	foreach v of varlist $hhmvars {
		local l : variable label `v'
		tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", svy sum c(mean `v') sebnone f(3) h1("`l'") npos(col) append ptotal(none) 
		svy: mean `v', over(t)
		test _subpop_1 = _subpop_2
		putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
		local i=`i'+1
		putexcel A`i' = "`l'"
		putexcel B`i' =`r(p)'
	}
	import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
	ren A v1
	ren (B) (p_value)
	gen n=_n
	save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
	insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
	drop if v1=="t"
    drop v3
	gen even = !mod(_n,2)
    gen n=_n  
	replace n=n-even 
    gen n2=(n+1)/2 
    drop n even 
	rename (n2 v1) (n v1_old) 
	gen v1=0 if v1_old=="Wave 1"
	replace v1=1 if v1_old=="Wave 2"
	drop v1_old 
 	reshape wide v2, i(n) j(v1)
	rename (v20 v21) (v2 v3)
	la var v2 "Wave 1"
	la var v3 "Wave 2"
	merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
    drop n
	la var v1 "Variable of interest"
	order  v1 v2 v3
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_`k'_2") sheetreplace first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

	* Age distribution
	use "${gsdTemp}/hh_comparison_Overall_V`k'.dta", replace
	* merge with hhm data set
	merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(age literacy age_cat_narrow)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w1") npos(col) replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc lb) f(5) sebnone h2("Age Distribution, w2") npos(col) replace ptotal(none) 
	drop if mi(literacy)
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls" if t==0, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w1")  replace ptotal(none) 
	tabout age_cat_narrow using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls" if t==1, svy sum c(mean literacy lb) f(5) sebnone h2("Literacy X Age, w2")  replace ptotal(none) 
	insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4 
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(D6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1 v4
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(F6) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(J7) first(varlabels)
	insheet using "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls", clear nonames tab
	replace v2 = v1 if v2==""
	cap drop v1
	export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_`k'_2") sheetmodify cell(L7) first(varlabels)
	erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw5_NW-Urban.xls"
	erase "${gsdOutput}/W1W2-comparison_raw6_NW-Urban.xls"
}

*Include the average number of each item owned
use "${gsdData}/1-CleanOutput/assets.dta", clear
*Wave 2
gen t=1
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(match) keepusing(ind_profile weight_cons weight_adj hhsize)
*Include owning zero assets 
replace own_n=0 if own==0
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
save "${gsdTemp}/assets_nwurban_w2.dta", replace
*Wave 1 ID zeros
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta"
keep if _merge==2 | (strata==101 & ea==85 & block==11 & hh==4)
keep strata ea block hh itemid own_n
replace itemid=1 if itemid==.
reshape wide own_n, i(strata ea block hh) j(itemid)
reshape long
drop if strata==101 & ea==85 & block==11 & hh==4
replace own_n=0 if own_n==.
save "${gsdTemp}/assets_nwurban_w2_noassets.dta", replace
*Wave 1 
use "${gsdData}/1-CleanInput/SHFS2016/assets.dta", clear
keep strata ea block hh itemid own_n
append using "${gsdTemp}/assets_nwurban_w2_noassets.dta"
replace own_n=0 if own_n==.
gen t=0
merge m:1 t strata ea block hh using "${gsdTemp}/hh_w1w2_comparison.dta", nogen keep(master match) keepusing(ind_profile weight_cons weight_adj hhsize)
keep t strata ea block hh weight_cons hhsize itemid own_n weight_adj ind_profile
append using "${gsdTemp}/assets_nwurban_w2.dta"
la def lt 0 "Wave 1" 1 "Wave 2", replace
la val t lt
*Restrict to the relevant subsample
merge m:1 t strata ea block hh using "${gsdTemp}/hh_comparison_Overall_V1.dta", nogen keep(match)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tab itemid, gen(item_)
foreach k of varlist item_* {
local a : variable label `k'
local a : subinstr local a "itemid==" ""
label var `k' "`a'"
}
drop if mi(own_n)
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
preserve
local i=1
levelsof itemid, local(items) 
qui foreach item of local items {
	su own_n
	local l : variable label item_`item'
	tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if itemid==`item', svy sum c(mean own_n) sebnone f(5) h1("`l'") append ptotal(none)
	svy: mean own_n if itemid==`item', over(t)
	cap test _subpop_1==_subpop_2
	putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", modify
	putexcel A`i' = "`l'"
	cap putexcel B`i' =`r(p)'
	local i=`i'+1
}
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
gen n=_n
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
drop if v1=="t"
gen even = !mod(_n,2)
gen n=_n  
replace n=n-even 
gen n2=(n+1)/2 
drop n even 
rename (n2 v1) (n v1_old) 
gen v1=0 if v1_old=="Wave 1"
replace v1=1 if v1_old=="Wave 2"
drop v1_old 
reshape wide v2, i(n) j(v1)
rename (v20 v21) (v2 v3)
la var v2 "Wave 1"
la var v3 "Wave 2"
merge 1:1 n using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
drop n
la var v1 "Variable of interest"
order  v1 v2 v3
export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_6") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
restore
*Check median values
levelsof itemid, local(items) 
qui foreach item of local items {
	preserve 
	keep if itemid==`item'
	collapse (median) own_n [aweight=weight_adj], by(t)
	gen itemid=`item'
	reshape wide own_n, i(itemid) j(t)
	save "${gsdTemp}/W1W2-comparison_assets_`item'.dta", replace
	restore
}
use "${gsdTemp}/W1W2-comparison_assets_1.dta", clear
qui forval i=2/37 {
	append using "${gsdTemp}/W1W2-comparison_assets_`i'.dta"
}
export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_7") sheetmodify cell(B3) first(varlabels)

*Include information on assets sold in Wave 2
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Overall_V1.dta", clear
gen pweight=weight_adj*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
gen sell_assets=(inlist(cop_sellassets,1,3)) if !missing(cop_sellassets)
tabout t using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls" if t>=0, svy sum c(mean sell_assets) sebnone f(5) h1("`l'") replace ptotal(none)
svy: mean sell_assets if t>=0, over(t)
cap test _subpop_1==_subpop_2
putexcel set "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", replace
putexcel A1 = "Sell_Assets"
cap putexcel B1 =`r(p)'
import excel using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear 
ren A v1
ren B p_value
sort v1
save "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", replace
insheet using "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls", clear 
gen v1="Sell_Assets"
merge m:1 v1 using "${gsdTemp}/W1W2-comparison_raw2_NW-Urban.dta", nogen
duplicates drop
export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_7_2") sheetmodify cell(B3) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"

*Population pyramid
cap erase "${gsdOutput}/W1W2-comparison_raw1_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
cap erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"
use "${gsdTemp}/hh_comparison_Overall_V1.dta", replace
* merge with hhm data set
merge 1:m strata ea block hh using "${gsdTemp}/hhm_SLw1w2.dta", nogen assert(match using) keep(match) keepusing(gender age literacy age_cat_narrow)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls" if t==0, svy pop c(perc) f(5) sebnone h1("Age Distribution, w1") npos(col) replace ptotal(none) 
tabout age_cat_narrow gender using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls" if t==1, svy pop c(perc) f(5) sebnone h1("Age Distribution, w2") npos(col) replace ptotal(none) 
insheet using "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4 
export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_8") sheetmodify cell(b29) first(varlabels)
insheet using "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls", clear nonames tab
replace v2 = v1 if v2==""
cap drop v1 v4
export excel using "${gsdShared}/2-Output/W1W2-comparison_Overall_V1.xlsx", sheet("Raw_8") sheetmodify cell(b56) first(varlabels)
erase "${gsdOutput}/W1W2-comparison_raw2_NW-Urban.xls"
erase "${gsdOutput}/W1W2-comparison_raw3_NW-Urban.xls"

