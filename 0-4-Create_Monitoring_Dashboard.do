*-------------------------------------------------------------------
*
*     MONITORING DASHBOARD
*     
*     This do-file updates the monitoring dashboard
*     Daily analysis to check progress and performance of teams
*     and enumerators
*       
*-------------------------------------------------------------------

***** PART 1: URBAN/RURAL/IDPs

/*----------------------------------------------------------------------------*/
/*     IMPORT QUESTIONNAIRE AND GENERATE USEFUL VARIABLES FOR DASHBOARD       */
/*----------------------------------------------------------------------------*/

use "${gsdData}/0-RawTemp/hh_valid_keys_and_EAs.dta", clear

***Generating useful variables

**State (as per the distribution of Teams)
g state = "Somaliland" if team_id >= 1 & team_id <= 6
replace state = "Puntland" if team_id >= 7 & team_id <= 11
replace state = "Benadir" if (team_id >= 12 & team_id <= 16) | team_id==45
replace state = "Galmudug" if (team_id >= 17 & team_id <= 21) | team_id==44
replace state = "Hirshabelle" if team_id >= 22 & team_id <= 27
replace state = "South West" if team_id >= 28 & team_id <= 35
replace state = "Jubaland" if team_id >= 36 & team_id <= 43
label var state "State as per the distribution of Teams"

**Region
decode ea_reg, g(ea_reg_str)
drop ea_reg
rename ea_reg_str ea_reg

**Enumerator name and ID
decode enum_id, g(enum_name)
label drop enum_id

**Interviews meeting validity criteria for GPS coordinates
g gps_ok = (gps_coord_y_n == 1 & not_within_EA == 0)
label var gps_ok "Whether the interview is meeting validity criteria for GPS coordinates"

**Behavioural treatment for valid and successful interviews
g beh_treat0= (beh_treat_opt==0) if successful_valid==1
g beh_treat1= (beh_treat_opt==1) if successful_valid==1
label var beh_treat0 "Behavioural nudges not activated"
label var beh_treat1 "Behavioural nudges activated"

**Dummy variable to identify interviews where the fisheries module was activated
g fisheries = (fishing_yn == 1) if successful_valid == 1
label var fisheries "Whether the fisheries module was activated an valid and successful interviews"

/*----------------------------------------------------------------------------*/
/*       INDICATORS RELATED TO FOOD AND NON-FOOD CONSUMPTION MODULES          */
/*----------------------------------------------------------------------------*/

*** 1. Cleaning of the main dataset
*Replace consumption of food items to missing when the item was not included in the optional module activated for this interview
*Module 1
foreach var of varlist rf_relevanceyn1__3	rf_relevanceyn1__6	rf_relevanceyn1__8	rf_relevanceyn1__10	rf_relevanceyn1__12	rf_relevanceyn1__15	rf_relevanceyn2__21	rf_relevanceyn2__23	rf_relevanceyn2__24	rf_relevanceyn2__25	rf_relevanceyn2__28	rf_relevanceyn2__29	rf_relevanceyn2__30	rf_relevanceyn3__32	rf_relevanceyn3__34	rf_relevanceyn3__37	rf_relevanceyn3__38	rf_relevanceyn3__39	rf_relevanceyn3__41	rf_relevanceyn4__46	rf_relevanceyn4__49	rf_relevanceyn4__56	rf_relevanceyn4__58	rf_relevanceyn4__60	rf_relevanceyn4__61	rf_relevanceyn4__63	rf_relevanceyn4__65	rf_relevanceyn4__66	rf_relevanceyn4__67	rf_relevanceyn4__68	rf_relevanceyn4__69	rf_relevanceyn__70	rf_relevanceyn__71	rf_relevanceyn__72	rf_relevanceyn__73	rf_relevanceyn__77	rf_relevanceyn__78	rf_relevanceyn__79	rf_relevanceyn__87	rf_relevanceyn__88	rf_relevanceyn__89	rf_relevanceyn__91	rf_relevanceyn__93	rf_relevanceyn__94	rf_relevanceyn__95	rf_relevanceyn__96	rf_relevanceyn__97	rf_relevanceyn__98	rf_relevanceyn__99	rf_relevanceyn__101	rf_relevanceyn__102	rf_relevanceyn__104	rf_relevanceyn__106	rf_relevanceyn__113	rf_relevanceyn__114	rnf_relevanceyn1__1002	rnf_relevanceyn1__1003	rnf_relevanceyn1__1006	rnf_relevanceyn2__1004	rnf_relevanceyn2__1011	rnf_relevanceyn2__1012	rnf_relevanceyn2__1014	rnf_relevanceyn2__1021	rnf_relevanceyn2__1025	rnf_relevanceyn2__1029	rnf_relevanceyn2__1030	rnf_relevanceyn2__1031	rnf_relevanceyn2__1034	rnf_relevanceyn3__1037	rnf_relevanceyn3__1038	rnf_relevanceyn3__1041	rnf_relevanceyn3__1042	rnf_relevanceyn3__1043	rnf_relevanceyn3__1044	rnf_relevanceyn3__1045	rnf_relevanceyn3__1047	rnf_relevanceyn3__1048	rnf_relevanceyn3__1049	rnf_relevanceyn3__1050	rnf_relevanceyn3__1051	rnf_relevanceyn3__1052	rnf_relevanceyn3__1053	rnf_relevanceyn3__1054	rnf_relevanceyn3__1056	rnf_relevanceyn3__1057	rnf_relevanceyn3__1058	rnf_relevanceyn3__1059	rnf_relevanceyn3__1060	rnf_relevanceyn3__1061	rnf_relevanceyn3__1062	rnf_relevanceyn3__1063	rnf_relevanceyn3__1065	rnf_relevanceyn3__1066	rnf_relevanceyn4__1072	rnf_relevanceyn4__1073	rnf_relevanceyn4__1074	rnf_relevanceyn4__1075	rnf_relevanceyn4__1081	rnf_relevanceyn4__1088	rnf_relevanceyn4__1089	rnf_relevanceyn4__1090 {
	replace `var' = . if mod_opt == 1
}
*Module 2
foreach var of varlist rf_relevanceyn1__3	rf_relevanceyn1__4	rf_relevanceyn1__8	rf_relevanceyn1__11	rf_relevanceyn1__12	rf_relevanceyn1__15	rf_relevanceyn1__16	rf_relevanceyn2__21	rf_relevanceyn2__22	rf_relevanceyn2__23	rf_relevanceyn2__24	rf_relevanceyn2__25	rf_relevanceyn2__27	rf_relevanceyn2__30	rf_relevanceyn3__34	rf_relevanceyn3__35	rf_relevanceyn3__36	rf_relevanceyn3__37	rf_relevanceyn3__38	rf_relevanceyn3__39	rf_relevanceyn3__40	rf_relevanceyn3__42	rf_relevanceyn3__43	rf_relevanceyn4__46	rf_relevanceyn4__49	rf_relevanceyn4__55	rf_relevanceyn4__58	rf_relevanceyn4__60	rf_relevanceyn4__61	rf_relevanceyn4__62	rf_relevanceyn4__64	rf_relevanceyn4__66	rf_relevanceyn4__67	rf_relevanceyn4__68	rf_relevanceyn4__69	rf_relevanceyn__70	rf_relevanceyn__72	rf_relevanceyn__73	rf_relevanceyn__77	rf_relevanceyn__79	rf_relevanceyn__83	rf_relevanceyn__84	rf_relevanceyn__86	rf_relevanceyn__87	rf_relevanceyn__88	rf_relevanceyn__89	rf_relevanceyn__91	rf_relevanceyn__92	rf_relevanceyn__93	rf_relevanceyn__99	rf_relevanceyn__100	rf_relevanceyn__101	rf_relevanceyn__102	rf_relevanceyn__104	rf_relevanceyn__105	rf_relevanceyn__107	rf_relevanceyn__112	rf_relevanceyn__113	rnf_relevanceyn1__1003	rnf_relevanceyn2__1004	rnf_relevanceyn2__1011	rnf_relevanceyn2__1012	rnf_relevanceyn2__1015	rnf_relevanceyn2__1016	rnf_relevanceyn2__1020	rnf_relevanceyn2__1021	rnf_relevanceyn2__1022	rnf_relevanceyn2__1025	rnf_relevanceyn2__1029	rnf_relevanceyn2__1030	rnf_relevanceyn2__1031	rnf_relevanceyn2__1032	rnf_relevanceyn2__1034	rnf_relevanceyn3__1036	rnf_relevanceyn3__1037	rnf_relevanceyn3__1039	rnf_relevanceyn3__1040	rnf_relevanceyn3__1041	rnf_relevanceyn3__1043	rnf_relevanceyn3__1044	rnf_relevanceyn3__1046	rnf_relevanceyn3__1047	rnf_relevanceyn3__1048	rnf_relevanceyn3__1050	rnf_relevanceyn3__1052	rnf_relevanceyn3__1054	rnf_relevanceyn3__1055	rnf_relevanceyn3__1056	rnf_relevanceyn3__1057	rnf_relevanceyn3__1058	rnf_relevanceyn3__1061	rnf_relevanceyn3__1062	rnf_relevanceyn3__1063	rnf_relevanceyn3__1064	rnf_relevanceyn3__1065	rnf_relevanceyn3__1066	rnf_relevanceyn4__1072	rnf_relevanceyn4__1074	rnf_relevanceyn4__1076	rnf_relevanceyn4__1077	rnf_relevanceyn4__1081	rnf_relevanceyn4__1087	rnf_relevanceyn4__1090 {
	replace `var' = . if mod_opt == 2
}
*Module 3
foreach var of varlist rf_relevanceyn1__4	rf_relevanceyn1__6	rf_relevanceyn1__10	rf_relevanceyn1__11	rf_relevanceyn1__15	rf_relevanceyn1__16	rf_relevanceyn2__21	rf_relevanceyn2__22	rf_relevanceyn2__23	rf_relevanceyn2__27	rf_relevanceyn2__28	rf_relevanceyn2__29	rf_relevanceyn2__30	rf_relevanceyn3__32	rf_relevanceyn3__35	rf_relevanceyn3__36	rf_relevanceyn3__37	rf_relevanceyn3__38	rf_relevanceyn3__39	rf_relevanceyn3__40	rf_relevanceyn3__41	rf_relevanceyn3__42	rf_relevanceyn3__43	rf_relevanceyn4__49	rf_relevanceyn4__55	rf_relevanceyn4__56	rf_relevanceyn4__58	rf_relevanceyn4__60	rf_relevanceyn4__62	rf_relevanceyn4__63	rf_relevanceyn4__64	rf_relevanceyn4__65	rf_relevanceyn4__68	rf_relevanceyn__71	rf_relevanceyn__73	rf_relevanceyn__78	rf_relevanceyn__83	rf_relevanceyn__84	rf_relevanceyn__86	rf_relevanceyn__87	rf_relevanceyn__88	rf_relevanceyn__89	rf_relevanceyn__92	rf_relevanceyn__94	rf_relevanceyn__95	rf_relevanceyn__96	rf_relevanceyn__97	rf_relevanceyn__98	rf_relevanceyn__99	rf_relevanceyn__100	rf_relevanceyn__102	rf_relevanceyn__105	rf_relevanceyn__106	rf_relevanceyn__107	rf_relevanceyn__112	rf_relevanceyn__113	rf_relevanceyn__114	rnf_relevanceyn1__1002	rnf_relevanceyn1__1006	rnf_relevanceyn2__1004	rnf_relevanceyn2__1012	rnf_relevanceyn2__1014	rnf_relevanceyn2__1015	rnf_relevanceyn2__1016	rnf_relevanceyn2__1020	rnf_relevanceyn2__1021	rnf_relevanceyn2__1022	rnf_relevanceyn2__1032	rnf_relevanceyn2__1034	rnf_relevanceyn3__1036	rnf_relevanceyn3__1038	rnf_relevanceyn3__1039	rnf_relevanceyn3__1040	rnf_relevanceyn3__1042	rnf_relevanceyn3__1044	rnf_relevanceyn3__1045	rnf_relevanceyn3__1046	rnf_relevanceyn3__1049	rnf_relevanceyn3__1051	rnf_relevanceyn3__1052	rnf_relevanceyn3__1053	rnf_relevanceyn3__1055	rnf_relevanceyn3__1056	rnf_relevanceyn3__1057	rnf_relevanceyn3__1058	rnf_relevanceyn3__1059	rnf_relevanceyn3__1060	rnf_relevanceyn3__1063	rnf_relevanceyn3__1064	rnf_relevanceyn3__1065	rnf_relevanceyn3__1066	rnf_relevanceyn4__1072	rnf_relevanceyn4__1073	rnf_relevanceyn4__1075	rnf_relevanceyn4__1076	rnf_relevanceyn4__1077	rnf_relevanceyn4__1081	rnf_relevanceyn4__1087	rnf_relevanceyn4__1088	rnf_relevanceyn4__1089	rnf_relevanceyn4__1090 {
	replace `var' = . if mod_opt == 3
}
*Module 4
foreach var of varlist  rf_relevanceyn1__3	rf_relevanceyn1__4	rf_relevanceyn1__6	rf_relevanceyn1__8	rf_relevanceyn1__10	rf_relevanceyn1__11	rf_relevanceyn1__12	rf_relevanceyn1__16	rf_relevanceyn2__22	rf_relevanceyn2__24	rf_relevanceyn2__25	rf_relevanceyn2__27	rf_relevanceyn2__28	rf_relevanceyn2__29	rf_relevanceyn3__32	rf_relevanceyn3__34	rf_relevanceyn3__35	rf_relevanceyn3__36	rf_relevanceyn3__40	rf_relevanceyn3__41	rf_relevanceyn3__42	rf_relevanceyn3__43	rf_relevanceyn4__46	rf_relevanceyn4__55	rf_relevanceyn4__56	rf_relevanceyn4__61	rf_relevanceyn4__62	rf_relevanceyn4__63	rf_relevanceyn4__64	rf_relevanceyn4__65	rf_relevanceyn4__66	rf_relevanceyn4__67	rf_relevanceyn4__69	rf_relevanceyn__70	rf_relevanceyn__71	rf_relevanceyn__72	rf_relevanceyn__77	rf_relevanceyn__78	rf_relevanceyn__79	rf_relevanceyn__83	rf_relevanceyn__84	rf_relevanceyn__86	rf_relevanceyn__91	rf_relevanceyn__92	rf_relevanceyn__93	rf_relevanceyn__94	rf_relevanceyn__95	rf_relevanceyn__96	rf_relevanceyn__97	rf_relevanceyn__98	rf_relevanceyn__100	rf_relevanceyn__101	rf_relevanceyn__104	rf_relevanceyn__105	rf_relevanceyn__106	rf_relevanceyn__107	rf_relevanceyn__112	rf_relevanceyn__114	rnf_relevanceyn1__1002	rnf_relevanceyn1__1003	rnf_relevanceyn1__1006	rnf_relevanceyn2__1011	rnf_relevanceyn2__1014	rnf_relevanceyn2__1015	rnf_relevanceyn2__1016	rnf_relevanceyn2__1020	rnf_relevanceyn2__1022	rnf_relevanceyn2__1025	rnf_relevanceyn2__1029	rnf_relevanceyn2__1030	rnf_relevanceyn2__1031	rnf_relevanceyn2__1032	rnf_relevanceyn3__1036	rnf_relevanceyn3__1037	rnf_relevanceyn3__1038	rnf_relevanceyn3__1039	rnf_relevanceyn3__1040	rnf_relevanceyn3__1041	rnf_relevanceyn3__1042	rnf_relevanceyn3__1043	rnf_relevanceyn3__1045	rnf_relevanceyn3__1046	rnf_relevanceyn3__1047	rnf_relevanceyn3__1048	rnf_relevanceyn3__1049	rnf_relevanceyn3__1050	rnf_relevanceyn3__1051	rnf_relevanceyn3__1053	rnf_relevanceyn3__1054	rnf_relevanceyn3__1055	rnf_relevanceyn3__1059	rnf_relevanceyn3__1060	rnf_relevanceyn3__1061	rnf_relevanceyn3__1062	rnf_relevanceyn3__1064	rnf_relevanceyn4__1073	rnf_relevanceyn4__1074	rnf_relevanceyn4__1075	rnf_relevanceyn4__1076	rnf_relevanceyn4__1077	rnf_relevanceyn4__1087	rnf_relevanceyn4__1088	rnf_relevanceyn4__1089 {
	replace `var' = . if mod_opt == 4
}

*** 2. Proportion of no/unanswered for consumption of items in the food and non-food consumption modules in the main dataset
*Create dummy variable = 1 if the item was not consumed by the household, for all food and non-food items
*Create dummy variable = 1 if the item was consumed by the household, for all food and non-food items
foreach var of varlist rf_relevanceyn* rnf_relevanceyn* {
		gen not_cons_`var' = (`var' == 0 | `var' == -999999999) if successful == 1
		gen cons_`var' = (`var' == 1) if successful == 1
	}
*Number of food items consumed
egen nb_cons_food = rowtotal(cons_rf_relevanceyn*) if successful == 1
g flag_food_empty = (nb_cons_food==0) if successful == 1
label var nb_cons_food "Numer of food items said to be consumed"
label var flag_food_empty "Whether no food item was said to be consumed"
*Number of non-food items consumed
egen nb_cons_non_food = rowtotal(cons_rnf_relevanceyn*) if successful == 1
g flag_non_food_empty = (nb_cons_non_food==0) if successful == 1
label var nb_cons_non_food "Numer of non-food items said to be consumed"
label var flag_non_food_empty "Whether no non-food item was said to be consumed"
*Proportion of no/don't know for food items
egen ndkn_food = rowmean(not_cons_rf_relevanceyn*) if successful == 1
label var ndkn_food "Proportion of food items with no or don't know for consumption answer"
*Proportion of no/don't know for non-food items
egen ndkn_non_food = rowmean(not_cons_rnf_relevanceyn*) if successful == 1
label var ndkn_non_food "Proportion of non-food items with no or don't know for consumption answer"
*Final cleaning
drop not_cons_* cons_*
save "${gsdTemp}/hh_monitoring_dashboard_temp1", replace

*** 3. Proportion of missing/don't know/refused to answer for quantities and prices relating to food items consumed

**Appending all food rosters
local files rf_food_cereals rf_food_meat rf_food_fruit rf_food_vegetables
local i 1
use "${gsdData}/0-RawTemp/rf_food_manual_cleaning.dta", clear
keep interview__id rf_food__id rf_cons_quant rf_purc_quant rf_pric_total
rename rf_food__id Id
save "${gsdTemp}/rf_food_all.dta", replace

foreach file in `files' {
	use "${gsdData}/0-RawTemp/`file'_manual_cleaning.dta", clear
	*Keep variables "quantity consumed", "quantity purchased", "price paid for quantity purchased"
	keep interview__id `file'__id rf_cons_quant`i' rf_purc_quant`i' rf_pric_total`i'
	rename (`file'__id rf_cons_quant`i' rf_purc_quant`i' rf_pric_total`i') (Id rf_cons_quant rf_purc_quant rf_pric_total)
	*Append with food roster
	append using "${gsdTemp}/rf_food_all.dta"
	save "${gsdTemp}/rf_food_all.dta", replace
	local i = `i'+1
}

**Creating dummy variables: whether the quantities and prices for food items are missing/unknown/refused to answer
g dummy_rf_cons_quant = (rf_cons_quant == . | rf_cons_quant == -999999999)
g dummy_rf_purc_quant = (rf_purc_quant == . | rf_purc_quant == -999999999)
g dummy_rf_pric_total = (rf_pric_total == . | rf_pric_total == -999999999)
drop rf_cons_quant rf_purc_quant rf_pric_total

**Reshaping to get one row per interview with all items and whether the quantities/prices for those items are known in columns
reshape wide dummy_rf_cons_quant dummy_rf_purc_quant dummy_rf_pric_total, i(interview__id) j(Id)

**At the interview level, aggregating proportion of quantities and prices for which answer is missing/unknown/refused to answer among all food items
egen ndkn_food_quant = rowmean(dummy*)
label var ndkn_food_quant "Proportion of missing or don't know or refused to answer for quantities and prices in the food consumption module"
keep interview__id ndkn_food_quant

**Merging with main dataset
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp1", nogenerate
order ndkn_food_quant, last
save "${gsdTemp}/hh_monitoring_dashboard_temp2", replace

*** 4. Proportion of missing/don't know/refused to answer for prices relating to non-food items consumed

**Importing non-food roster and merging with main dataset
use "${gsdData}/0-RawTemp/rnf_nonfood_manual_cleaning.dta", clear
sort interview__id rnf_nonfood__id
*Dropping one item (water supply) which does not appear in the list of items in the main dataset
drop if rnf_nonfood__id == 1071
*Keeping interview Id, item Id, and variable "price paid for the amount of item that was purchased"
keep interview__id rnf_nonfood__id rnf_pric_total
*Reshaping to get one row per interview with all items and their price in columns
reshape wide rnf_pric_total, i(interview__id) j(rnf_nonfood__id)
*Merging with main dataset
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp2", nogenerate
order rnf_pric_total*, last

**Proportion of non-food items consumed by the household for which price was missing/unknown/refused to answer
*Renaming variables in order to match the price of each item with the variables indicating whether the item was consumed or not
foreach var of varlist rnf_relevanceyn* {
   	local itemID = substr("`var'", -2, .)
   	g rnf_relevanceyn_`itemID' = `var'
}
foreach var of varlist rnf_pric_total* {
   	local itemID = substr("`var'", -2, .)
   	g rnf_pric_total_`itemID' = `var'
}

*Dummy variables for each non-food item: if the item was consumed by the household, whether its price was missing/unknown/refused to answer
foreach var of varlist rnf_pric_total_* {
   	local itemID = substr("`var'", -2, .)
	g ndkn_non_food_quant_`itemID' = (rnf_pric_total_`itemID' == . | rnf_pric_total_`itemID' == -1000000000 | rnf_pric_total_`itemID' == -999999999) if rnf_relevanceyn_`itemID' == 1
}
*Proportion of non-food items consumed by the household for which price was missing/unknown/refused to answer
egen ndkn_non_food_quant = rowmean(ndkn_non_food_quant_*)
label var ndkn_non_food_quant "Proportion of missing/unknown/refused to answer prices in the non-food consumption module"
drop ndkn_non_food_quant_* rnf_relevanceyn_* rnf_pric_total*

/*----------------------------------------------------------------------------*/
/*      	INDICATORS RELATED TO COMPLETENESS OF ANSWERS		              */
/*----------------------------------------------------------------------------*/

*** 1. Proportion of missing answers in the main dataset
*Dummy variables: whether each variable of the interview is missing or not
ds athome-share_phone_agencies , has(type string)
local string0 `r(varlist)'
ds hh_list__0-hh_list_separated__9
local omit1 `r(varlist)'
local string : list string0 - omit1

ds athome-share_phone_agencies, has(type numeric)
local numeric `r(varlist)'

foreach var of local string {
	gen mi_`var' = (`var' == "##N/A##") if `var' != ""
}
foreach var of local numeric {
	gen mi_`var' = (`var'== -999999999 | `var'== -1000000000) if `var' != .
}
*Proportion of missing answers
egen missing_prop_main = rowmean(mi_*) if successful == 1
drop mi_*
label var missing_prop_main "Proportion of missing answers in the main dataset" 
save "${gsdTemp}/hh_monitoring_dashboard_temp3", replace

*** 2. Proportion of missing answers for each roster
local files hh_roster_separated hhroster_age motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
foreach file in `files' {
more
	use "${gsdData}/0-RawTemp/`file'_manual_cleaning.dta", clear
	*Dummy variables: whether each variable is missing or not
	ds *, has(type string)
	local str_all_`file' `r(varlist)'
	local str_omit_`file' interview__id
	local str_`file' : list str_all_`file' - str_omit_`file'
	
	ds *, has(type numeric)
	local num_all_`file' `r(varlist)'
	local num_omit_`file' `file'__id
	local num_`file' : list num_all_`file' - num_omit_`file'
	
	foreach var of local str_`file' {
		gen mi_`var' = (`var' == "##N/A##") if `var' != ""
	}
	foreach var of local num_`file' {
		gen mi_`var' = (`var'== -999999999 | `var'== -1000000000) if `var' != .
	}
	*Proportion of missing answers
	egen missing_prop_`file' = rowmean(mi_*)
	*Collapse per interview
	collapse (mean) missing_prop_`file', by(interview__id)
	*Merging with main dataset
	merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp3", nogenerate
	label var missing_prop_`file' "Proportion of missing answers in roster `file'" 
	order missing_prop_`file', last
	more
	save "${gsdTemp}/hh_monitoring_dashboard_temp3", replace
}

*** 3. Key question: Remittances
**Dummy variable: whether answer to the question on receipt of remittances (from abroad) is missing/don't know/refused to answer
g ndkn_remittances_ext = (remit12m_yn == -98 | remit12m_yn == -99 | remit12m_yn == -999999999 | remit12m_yn == -1000000000) if successful == 1
label var ndkn_remittances_ext "Whether answer to the question on receipt of remittances (from abroad) is missing/don't know/refused to answer"
**Dummy variable: whether answer to the question on receipt of remittances (from within the country) is missing/don't know/refused to answer
g ndkn_remittances_int = (intremit12m_yn == -98 | intremit12m_yn == -99 | intremit12m_yn == -999999999 | intremit12m_yn == -1000000000) if successful == 1
label var ndkn_remittances_int "Whether answer to the question on receipt of remittances (from within the country) is missing/don't know/refused to answer"
** Flag if info on remittances is missing (eithe domestic or international remittances)
g flag_remit = (ndkn_remittances_ext ==1 | ndkn_remittances_int ==1) if successful == 1
label var flag_remit "Whether answers to the question on receipt of remittances - domestic or international - are missing"

*** 4. Key question: IDP status
**Dummy variable: whether answer to the question on forced displacement is missing
g ndkn_IDP_status = (migr_disp == -999999999 | migr_disp == -1000000000) if successful == 1
label var ndkn_IDP_status "Whether answer to the question on forced displacement is missing"
save "${gsdTemp}/hh_monitoring_dashboard_temp4", replace

*** 5. Key questions: Employment
**Proportion of missing/don't know/refused to answer to the question on being inside the labour force
*Dummy variable: whether answer is missing, unknown or refused to answer for ALL kinds of activities for this household member
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning.dta", clear
g ndkn_labour = ((emp_7d_paid == -98 | emp_7d_paid == -99 | emp_7d_paid == . | emp_7d_paid == -999999999 | emp_7d_paid == -1000000000) & ///
				 (emp_7d_busi == -98 | emp_7d_busi == -99 | emp_7d_busi == . | emp_7d_busi == -999999999 | emp_7d_busi == -1000000000) & ///
				 (emp_7d_help == -98 | emp_7d_help == -99 | emp_7d_help == . | emp_7d_help == -999999999 | emp_7d_help == -1000000000) & ///
				 (emp_7d_farm == -98 | emp_7d_farm == -99 | emp_7d_farm == . | emp_7d_farm == -999999999 | emp_7d_farm == -1000000000) & ///
				 (emp_7d_appr == -98 | emp_7d_appr == -99 | emp_7d_appr == . | emp_7d_appr == -999999999 | emp_7d_appr == -1000000000)) if hhm_age > 14
*Proportion of don't know/refused to answer by interview (average on all household members) 
collapse (mean) ndkn_labour, by(interview__id)
g flag_ndkn_labour = (ndkn_labour >0)
keep interview__id ndkn_labour flag_ndkn_labour
*Merge with main dataset
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp4", nogenerate 
order ndkn_labour flag_ndkn_labour, last
label var ndkn_labour "Proportion of missing/don't know/refused to answer to the question on being inside the labour force"
label var flag_ndkn_labour "Whether the answer to the question on being inside the labour force is missing/don't know/refused to answer for at least one household members"
save "${gsdTemp}/hh_monitoring_dashboard_temp5", replace

*** 6. Key questions: Education
*Dummy variable: whether answer is missing, unknown or refused to answer for ALL key education variables for this household member
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning.dta", clear
g flag_ndkn_edu = ((hhm_read == -98 | hhm_read == -99 | hhm_read == . | hhm_read == -999999999 | hhm_read == -1000000000) & ///
				 (hhm_write == -98 | hhm_write == -99 | hhm_write == . | hhm_write == -999999999 | hhm_write == -1000000000) & ///
				 (hhm_edu_ever == -98 | hhm_edu_ever == -99 | hhm_edu_ever == . | hhm_edu_ever == -999999999 | hhm_edu_ever == -1000000000) & ///
				 (hhm_edu_years == -98 | hhm_edu_years == -99 | hhm_edu_years == . | hhm_edu_years == -999999999 | hhm_edu_years == -1000000000) & ///
				 (hhm_edu_level == -98 | hhm_edu_level == -99 | hhm_edu_level == . | hhm_edu_level == -999999999 | hhm_edu_level == -1000000000)) if hhm_age > 5
*Dummy variable at the interview level: whether ALL key variables on education are missing for at least one household member
collapse (max) flag_ndkn_edu, by(interview__id)
keep interview__id flag_ndkn_edu   
*Merge with main dataset
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp5", nogenerate 
order flag_ndkn_edu, last
label var flag_ndkn_edu "Whether all key variables on education are missing for at least one household member"

*** 7. Key questions: Housing conditions
*Dummy variable: whether answer is missing, unknown or refused to answer for ALL key housing variables
g flag_ndkn_house = ((housingtype == -98 | housingtype == -99 | housingtype == . | housingtype == -999999999 | housingtype == -1000000000) & ///
				 (cook == -98 | cook == -99 | cook == . | cook == -999999999 | cook == -1000000000) & ///
				 (toilet == -98 | toilet == -99 | toilet == . | toilet == -999999999 | toilet == -1000000000) & ///
				 (roof_material == -98 | roof_material == -99 | roof_material == . | roof_material == -999999999 | roof_material == -1000000000)) if successful == 1
label var flag_ndkn_house "Whether all key variables on housing conditions are missing"

/*----------------------------------------------------------------------------*/
/*      		     INDICATORS RELATED TO SKIP PATTERNS                      */
/*----------------------------------------------------------------------------*/

**Number of skip patterns on successful interviews
*Important skip patterns relate to livestock, durable goods, shocks, displacements, fishing, leavers' roster, remittances (24 possible skip patterns)
foreach var of varlist shocks0__1-shocks0__18 migr_disp migr_disp_past fishing_yn hhm_separated intremit12m_yn remit12m_yn{
	capture: gen skip_`var' = 1 if (`var' == 0 | `var' == -999999999 | `var' == -1000000000 |`var' == -98 | `var' == -99) & successful == 1
}
save "${gsdTemp}/hh_monitoring_dashboard_temp6", replace

*Another important skip pattern relate to employment
*Import household roster
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning.dta", clear
*Skip pattern = + 1 for each no/don't know/refused to answer to questions on employment status per member of the household
g skip_employment = (inlist(emp_7d_paid,0,-98,-99,.,-999999999, -1000000000) & inlist(emp_7d_busi,0,-98,-99,.,-999999999,-1000000000) & inlist(emp_7d_help,0,-98,-99,.,-999999999, -1000000000) & ///
					inlist(emp_7d_farm,0,-98,-99,.,-999999999, -1000000000) & inlist(emp_7d_appr,0,-98,-99,.,-999999999, -1000000000)) if hhm_age > 14
*Total number of skip patterns per interview on employment(collapse on household members)
collapse (sum) skip_employment, by(interview__id)
*Merge with main dataset
keep interview__id skip_employment 
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp6", nogenerate 
order skip_employment, last

*Total number of skip patterns on successful interviews
egen nb_skip_patterns = rowtotal(skip*) if successful == 1
label var nb_skip_patterns "Number of important skip patterns activated in the interview"
*Proportion of skip patterns out of total number of skip patterns
g prop_skip_patterns = nb_skip_patterns/(24+nadults) 
label var prop_skip_patterns "Proportion of important skip patterns activated in the interview"
drop skip*
save "${gsdTemp}/hh_monitoring_dashboard_temp7", replace


/*----------------------------------------------------------------------------*/
/*      		     INDICATORS RELATED TO SOFT CONSTRAINTS                   */
/*----------------------------------------------------------------------------*/

/*Soft constraints:
	1) one of the household members must be 16 or above (cf. minimum age of the respondent)
	2) the number of years of education must be realistic
The variables are equal to 1 if the soft constraint is not respected and 0 otherwise */

**Import household members roster 
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning.dta", clear

**Dummy variables at the household member level
*Household member is not an adult if he/she is not above 16
g not_adult = (hhm_age < 16) if missing(hhm_age)==0 & hhm_age != -999999999 & hhm_age != -1000000000
*Household member has an unrealistic number of years of education if it exceeds 30 years or if it exceeds the age of the household member
g edu_not_realistic = (hhm_edu_years >= 30 | hhm_edu_years > hhm_age) if missing(hhm_age) == 0 & hhm_age != -999999999 & hhm_age != -1000000000 & missing(hhm_edu_years) == 0

**Add soft constraints dummies into main dataset
keep interview__id not_adult edu_not_realistic
*Collapse to have one row per household and whether the soft constraints 1 and 2 are respected or not
collapse (min) soft_const_adult=not_adult (max) soft_const_edu=edu_not_realistic, by(interview__id)
*Merge with main dataset
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp7", nogenerate 

order soft*, last
label var soft_const_adult "Whether soft constraint on age is not respected"
label var soft_const_edu "Whether soft constraint on education is not respected"


/*----------------------------------------------------------------------------*/
/*      				    OTHER INDICATORS    				              */
/*----------------------------------------------------------------------------*/

**Non-response rate broken down in the various reasons (no one home, no adult, no consent)
g no_response = 1-consent
g nobody_home = 0 if no_response != .
replace nobody_home = 1 if athome == 0
g no_adult = 0 if no_response != .
replace no_adult = 1 if athome == 1 & adult == 0
g no_consent = 0 if no_response != .
replace no_consent = 1 if athome == 1 & adult == 1 & maycontinue == 0

**Number of household members for successful interviews
g nhhm_succ = nhhm if successful == 1

**Number of assets owned
foreach var of varlist ra_own* {
		gen own_`var' = (`var' == 1) if successful == 1
	}
egen nb_own_assets = rowtotal(own_*) if successful == 1
drop own_*
*Flag if no asset is owned
g flag_assets_empty = (nb_own_assets == 0) if successful == 1
label var flag_assets_empty "Whether no asset is said to be owned by the household"

**Number of shocks faced during the last 12 months
foreach var of varlist shocks0__* {
		gen faced_`var' = (`var' == 1) if successful == 1
	}
egen nb_shocks = rowtotal(faced_*) if successful == 1
drop faced_*
*Flag if no shock was faced
g flag_shocks_empty = (nb_shocks == 0) if successful == 1
label var flag_shocks_empty "Whether no shock is said to be faced by the household"

**Whether the household was displaced
g disp = (migr_disp == 1) if successful == 1
*Flag if the EA is an IDP camp but the household was said not to be displaced
g flag_idp = (migr_disp == 0) if idp_ea_yn == 1
label var flag_idp "Whether the EA is an IDP camp but the household was said not to be displaced"

save "${gsdTemp}/hh_monitoring_dashboard_temp8", replace

**Number of people in employment/inside the labour force
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning.dta", clear
replace emp_7d_active = . if emp_7d_active == -999999999 | emp_7d_active == -1000000000
collapse (sum) emp_7d_active, by(interview__id)
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp8", nogenerate

save "${gsdTemp}/hh_monitoring_dashboard_temp9", replace


/*----------------------------------------------------------------------------*/
/*                   MONITORING DASHBOARD: MAIN OUTPUT                        */
/*----------------------------------------------------------------------------*/

preserve

*Collapse by state/region/strata/team/ea/enumerator/date
collapse (sum) nb_itw=index itw_valid successful successful_valid val_succ1-val_succ4 beh_treat0 beh_treat1 gps_ok ///
	(mean) missing_prop_* ///
	(mean) nb_cons_food nb_cons_non_food ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ///
	(mean) ndkn_IDP_status ndkn_remittances_ext ndkn_labour ///
	(mean) nb_skip_patterns prop_skip_patterns soft_const_adult soft_const_edu ///
	(mean) no_response nobody_home no_adult no_consent ///
	(median) duration_med = duration_itw_min (mean) duration_mean = duration_itw_min ///
	(min) duration_min = duration_itw_min (max) duration_max = duration_itw_min ///
	(mean) nhhm_succ nb_own_assets nb_shocks ///
	(sum) fisheries disp ///
	(mean) emp_7d_active target_itw_ea , ///
	by(state ea_reg strata_id strata_name id_ea team_id enum_id enum_name date_stata)

*Proportion of interviews meeting validity criteria for GPS coordinates
g gps_prop = gps_ok/nb_itw
*Proportion of valid interviews (on total number of interviews)
g valid_prop = itw_valid/nb_itw
*Flag if too few valid interviews
g issue = 3
replace issue = 1 if valid_prop < 0.5
replace issue = 2 if valid_prop >= 0.5 & valid_prop < 0.8

*Final cleaning and labelling
label var state "State"
label var ea_reg "Region"
label var strata_id "Strata ID"
label var strata_name "Strata name"
label var id_ea "EA"
label var team_id "Team ID"
label var enum_id "Enumerator ID"
label var enum_name "Enumerator name"
label var date_stata "Day of data collection"
label var nb_itw "Total number of interviews"
label var itw_valid "Number of valid interviews"
label var successful "Number of successful interviews"
label var successful_valid "Number of valid and successful interviews"
label var val_succ1 "Number of valid and successful interviews with Treat=1"
label var val_succ2 "Number of valid and successful interviews with Treat=2"
label var val_succ3 "Number of valid and successful interviews with Treat=3"
label var val_succ4 "Number of valid and successful interviews with Treat=4"
label var beh_treat0 "Number of valid and successful interviews with behavioural treatment equal to 0"
label var beh_treat1 "Number of valid and successful interviews with behavioural treatment equal to 1"
label var gps_ok "Number of interviews meeting validity criteria for GPS coordinates"
label var gps_prop "Proportion of interviews meeting validity criteria for GPS coordinates"
label var valid_prop "Proportion of valid interviews"
label var no_response "Non-response rate"
label var nobody_home "Proportion of non-response due to the fact that there was no one at home"
label var no_adult "Proportion of non-response due to the absence of a knowledgeable adult at home"
label var no_consent "Proportion of non-response due to the the fact that no consent was given"
label var missing_prop_main "Proportion of missing answers on successful interviews - Main dataset"
label var missing_prop_hh_roster_separated "Proportion of missing answers on successful interviews - Separated roster"
label var missing_prop_hhroster_age "Proportion of missing answers on successful interviews - Household roster"
label var missing_prop_motor "Proportion of missing answers on successful interviews - Motor roster"
label var missing_prop_ra_assets "Proportion of missing answers on successful interviews - Assets roster"
label var missing_prop_ra_assets_prev "Proportion of missing answers on successful interviews - Assets roster, before displacement"
label var missing_prop_rf_food "Proportion of missing answers on successful interviews - Main food roster"
label var missing_prop_rf_food_cereals "Proportion of missing answers on successful interviews - Cereals roster"
label var missing_prop_rf_food_fruit "Proportion of missing answers on successful interviews - Fruits roster"
label var missing_prop_rf_food_meat "Proportion of missing answers on successful interviews - Meat roster"
label var missing_prop_rf_food_vegetables "Proportion of missing answers on successful interviews - Vegetables roster"
label var missing_prop_rl_livestock "Proportion of missing answers on successful interviews - Livestock roster"
label var missing_prop_rl_livestock_pre "Proportion of missing answers on successful interviews - Livestock roster, before displacement"
label var missing_prop_rnf_nonfood "Proportion of missing answers on successful interviews - Non-food roster"
label var missing_prop_shocks "Proportion of missing answers on successful interviews - Shocks roster"
label var nb_cons_food "Average number of food items said to be consumed per household"
label var nb_cons_non_food "Average number of non-food items said to be consumed per household"
label var ndkn_food "Average proportion of food items with no or don't know for consumption answer"
label var ndkn_food_quant "Average proportion of missing, unknown or refused to answer quantities and prices for consumed or purchased items in the food consumption module"
label var ndkn_non_food "Average proportion of non-food items with no or don't know for consumption answer"
label var ndkn_non_food_quant "Average proportion of missing, unknown or refused to answer prices for consumed or purchased items in the non-food consumption module"
label var ndkn_IDP_status "Proportion of missing, unknown or refused to answer to the question on IDP status"
label var ndkn_remittances_ext "Proportion of missing, unknown or refused to answer to the question on receipt of remittances"
label var ndkn_labour "Average proportion of missing, unknown or refused to answer to the question on being in the labour force"
label var nb_skip_patterns "Average number of skip patterns on successful interviews"	
label var prop_skip_patterns "Average proportion of skip patterns on successful interviews"	
label var soft_const_adult "Average proportion of interviews not respecting the soft constraint: at least one household member above 16"
label var soft_const_edu "Average proportion of interviews not respecting the soft constraint: realistic number of years of education"
label var duration_med "Median duration of successful interviews - minutes"
label var duration_mean "Mean duration of successful interviews - minutes"
label var duration_min "Min duration of successful interviews - minutes"
label var duration_max "Max duration of successful interviews - minutes"
label var nhhm_succ "Average number of household members for successful interviews"
label var nb_own_assets "Average number of assets owned by the household"
label var nb_shocks "Average number of shocks"
label var emp_7d_active "Average number of people in employment/inside the labour force"
label var fisheries "Number of valid and successful inteviews for which the fisheries module was activated"
label var disp "Total number of displaced households"
label var issue "Issue?"
label var target_itw_ea "Target number of valid and successful interviews per EA"

order state ea_reg strata_id strata_name id_ea team_id enum_id enum_name date_stata nb_itw itw_valid successful successful_valid ///
	val_succ1-val_succ4 beh_treat0 beh_treat1 gps_ok gps_prop valid_prop no_response nobody_home no_adult no_consent missing_prop* ///
	nb_cons_food nb_cons_non_food ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ndkn_IDP_status ndkn_remittances_ext ndkn_labour ///
	nb_skip_patterns prop_skip_patterns soft_const_adult soft_const_edu ///
	duration_med duration_mean duration_min duration_max ///
	nhhm_succ nb_own_assets nb_shocks emp_7d_active fisheries disp issue target_itw_ea
	
sort team_id enum_id date_stata

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Main Output") cell(B5) sheetmodify
restore


/*----------------------------------------------------------------------------*/
/*                     MONITORING DASHBOARD: TEAM OUTPUT                      */
/*----------------------------------------------------------------------------*/

preserve

*Averge proportion of valid interviews - across all interviews, all dates
egen tot_valid = total(itw_valid)
egen tot_itw = total(index)
g avg_valid_prop = tot_valid/tot_itw
drop tot_valid tot_itw

*Collapse by team
collapse (sum) nb_itw=index itw_valid successful successful_valid gps_ok (first) avg_valid_prop ///
	(mean) no_response nobody_home no_adult no_consent ///
	(median) duration_med = duration_itw_min (mean) duration_mean = duration_itw_min ///
	(min) duration_min = duration_itw_min (max) duration_max = duration_itw_min, by(state team_id date_stata)

*Number of successful interviews - Cumulative by date
sort team_id date_stata
by team_id: gen successful_valid_cum = sum(successful_valid)
*Proportion of interviews meeting validity criteria for GPS coordinates (on total number of interviews)
g gps_prop = gps_ok/nb_itw
*Proportion of valid interviews (on total number of interviews)
g valid_prop = itw_valid/nb_itw
*Median duration - across all Teams
sum duration_med, d
global duration_med_all_team = `r(p50)'
g duration_med_all_team = $duration_med_all_team

*Final cleaning and labelling
label var state "State"
label var team_id "Team"
label var date_stata "Day of data collection"
label var nb_itw "Total number of interviews"
label var itw_valid "Number of valid interviews"
label var successful "Number of successful interviews"
label var successful_valid "Number of valid and successful interviews"
label var successful_valid_cum "Number of valid and successful interviews - Cumulative"
label var gps_ok "Nb of interviews meeting validity criteria for GPS coordinates"
label var gps_prop "Proportion of interviews meeting validity criteria for GPS coordinates"
label var valid_prop "Proportion of valid interviews"
label var no_response "Non-response rate"
label var nobody_home "Proportion of non-response due to the fact that there was no one at home"
label var no_adult "Proportion of non-response due to the absence of a knowlegeable adult at home"
label var no_consent "Proportion of non-response due to the the fact that no consent was given"
label var duration_med "Median duration of interviews - minutes"
label var duration_mean "Mean duration of interviews - minutes"
label var duration_min "Min duration of interviews - minutes"
label var duration_max "Max duration of interviews - minutes"
label var avg_valid_prop "Average proportion of valid interviews across all teams and all data collection"
label var duration_med_all_team "Median duration of successful interviews - minutes - across all teams"

order state team_id date_stata nb_itw itw_valid successful successful_valid successful_valid_cum gps_ok gps_prop valid_prop ///
	no_response nobody_home no_adult no_consent duration_med duration_mean duration_min duration_max avg_valid_prop duration_med_all_team
	
sort team_id date_stata

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Teams") cell(B7) sheetmodify
restore

/*----------------------------------------------------------------------------*/
/*                 MONITORING DASHBOARD: ENUMERATOR OUTPUT                    */
/*----------------------------------------------------------------------------*/

preserve

g nb_cons_food_low = (nb_cons_food <= 10)
g nb_cons_non_food_low = (nb_cons_non_food <= 5)
g nb_own_assets_low = (nb_own_assets <= 5)

*Collapse by enumerator and date
collapse (sum) nb_itw=index itw_valid successful successful_valid gps_ok ///
	(mean) missing_prop_* ///
	(mean) nb_cons_food nb_cons_non_food ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ///
	(mean) ndkn_IDP_status ndkn_remittances_ext ndkn_remittances_int ndkn_labour ///
	(mean) nb_skip_patterns prop_skip_patterns soft_const_adult soft_const_edu ///
	(mean) no_response nobody_home no_adult no_consent ///
	(median) duration_med = duration_itw_min (mean) duration_mean = duration_itw_min ///
	(min) duration_min = duration_itw_min (max) duration_max = duration_itw_min ///
	(mean) nhhm_succ nb_own_assets nb_shocks ///
	(sum) fisheries disp ///
	(mean) emp_7d_active ///
	(max) flag_food_empty flag_non_food_empty flag_assets_empty flag_ndkn_edu flag_ndkn_house flag_ndkn_labour flag_remit flag_idp ///
	(min) flag_shocks_empty ///
	(sum) nb_cons_food_low nb_cons_non_food_low nb_own_assets_low, ///
	by(state team_id enum_id enum_name date_stata)

*Number of valid and successful interviews - Cumulative by date
sort enum_id date_stata
by enum_id : gen successful_valid_cum = sum(successful_valid)
*Proportion of interviews meeting validity criteria for GPS coordinates (on all interviews)
g gps_prop = gps_ok/nb_itw
*Proportion of valid interviews (on all interviews)
g valid_prop = itw_valid/nb_itw
*Decile of number of skip patterns
sum prop_skip_patterns, d
global threshold_skip_patterns = `r(p90)'
*Median duration - across all Enumerators
sum duration_med, d
global duration_med_all = `r(p50)'
g duration_med_all = $duration_med_all
*Average proportion of 'no'/'don't know' in the food and non-food consumption module - across all Enumerators"	
sum ndkn_food, d
global ndkn_food_ave = `r(mean)'
sum ndkn_non_food
global ndkn_non_food_ave = `r(mean)'
g ndkn_food_non_food_ave = ($ndkn_food_ave + $ndkn_non_food_ave)/2
*Average number of household memebrs - across all Enumerators
sum nhhm_succ, d
global nhhm_succ_ave = `r(mean)'
g nhhm_succ_ave = $nhhm_succ_ave

/*List of flags
1	- Shorter duration of interviews than other enumerators
2	- Lower number of household members on average than other enumerators/and what is expected in the state
3.1	- Higher proportion of missing answers than other enumerators in the main dataset
3.2	- Higher proportion of missing answers than other enumerators in the separated roster
3.3	- Higher proportion of missing answers than other enumerators in the household roster
3.4	- Higher proportion of missing answers than other enumerators in the motor roster
3.5	- Higher proportion of missing answers than other enumerators in the assets roster
3.6	- Higher proportion of missing answers than other enumerators in the assets roster before displacement
3.7	- Higher proportion of missing answers than other enumerators in the main food roster
3.8	- Higher proportion of missing answers than other enumerators in the cereals roster
3.9	- Higher proportion of missing answers than other enumerators in the fruits roster
3.10 - Higher proportion of missing answers than other enumerators in the meat roster
3.11 - Higher proportion of missing answers than other enumerators in the vegetables roster
3.12 - Higher proportion of missing answers than other enumerators in the livestock roster
3.13 - Higher proportion of missing answers than other enumerators in the livestock roster before displacement
3.14 - Higher proportion of missing answers than other enumerators in the non-food roster
3.15 - Higher proportion of missing answers than other enumerators in the shocks roster
4	- Higher proportion of items said not to be consumed than other enumerators
5	- Too high proportion of missing quantities and prices for food and non-food items consumed
6	- Higher number of key questions skipped
7	- Answers on questions on remittances missing
8	- Answers on questions on IDP status missing
9	- Answers on key questions on employment missing
10	- Answers on key questions on education missing
11	- Answers on housing conditions missing
12	- Number of years of education not realistic
13  - No food item said to be consumed for at least one interview
14  - No non-food item said to be consumed for at least one interview
15  - No asset said to be owned for at least one interview
16  - Low number of food items said to be consumed on average
17  - Low number of non-food items said to be consumed on average
18  - Low number of assets said to be owned on average
19  - No shocks faced for all interviews
20  - Household was said not to be displaced whereas the EA is an IDP camp
21  - Number of years of education not realistic
*/

g flag_duration = (duration_med < 80 & missing(duration_med) == 0)
g flag_hhm = (nhhm_succ <= 3.5)
g flag_missing_main = (missing_prop_main > 0.05)
g flag_roster_separated = (missing_prop_hh_roster_separated > 0.3 & missing(missing_prop_hh_roster_separated) == 0)
g flag_roster_hh = (missing_prop_hhroster_age > 0.1 & missing(missing_prop_hhroster_age) == 0)
g flag_roster_motor = (missing_prop_motor > 0.3 & missing(missing_prop_motor) == 0)
g flag_roster_assets = (missing_prop_ra_assets > 0.1 & missing(missing_prop_ra_assets) == 0)
g flag_roster_assets_prev = (missing_prop_ra_assets_prev > 0.3 & missing(missing_prop_ra_assets_prev) == 0)
g flag_roster_food = (missing_prop_rf_food > 0.05 & missing(missing_prop_rf_food) == 0)
g flag_roster_cereals = (missing_prop_rf_food_cereals > 0.1 & missing(missing_prop_rf_food_cereals) == 0)
g flag_roster_fruits = (missing_prop_rf_food_fruit > 0.1 & missing(missing_prop_rf_food_fruit) == 0)
g flag_roster_meat = (missing_prop_rf_food_meat > 0.1 & missing(missing_prop_rf_food_meat) == 0)
g flag_roster_vegetables = (missing_prop_rf_food_vegetables > 0.1 & missing(missing_prop_rf_food_vegetables) == 0)
g flag_roster_livestock = (missing_prop_rl_livestock > 0.1 & missing(missing_prop_rl_livestock) == 0)
g flag_roster_livestock_pre = (missing_prop_rl_livestock_pre > 0.3 & missing(missing_prop_rl_livestock_pre) == 0)
g flag_roster_non_food = (missing_prop_rnf_nonfood > 0.05 & missing(missing_prop_rnf_nonfood) == 0)
g flag_roster_shocks = (missing_prop_shocks > 0.1 & missing(missing_prop_shocks) == 0)
g flag_ndkn_food_non_food = ((ndkn_food + ndkn_non_food)/2 > 0.47)
g flag_prices_quant_food_non_food = ((ndkn_food_quant != . & ndkn_non_food_quant != . & (ndkn_food_quant + ndkn_non_food_quant)/2 > 0.3) | ///
	(ndkn_food_quant != . & ndkn_non_food_quant == . & ndkn_food_quant > 0.3) | ///
	(ndkn_food_quant == . & ndkn_non_food_quant != . & ndkn_non_food_quant > 0.3))
g flag_skip = (prop_skip_patterns > $threshold_skip_patterns)
*flag_remit
g flag_missing_idp = (ndkn_IDP_status > 0)
*flag_ndkn_labour
*flag_ndkn_edu
*flag_ndkn_house
*flag_food_empty
*flag_non_food_empty
*flag_assets_empty
g flag_nb_cons_food_low = (nb_cons_food_low >= 1)
g flag_nb_cons_non_food_low = (nb_cons_non_food_low >= 1)
g flag_nb_own_assets_low = (nb_own_assets_low >= 2)
*flag_shocks_empty
replace flag_idp = 0 if missing(flag_idp)
g flag_edu_not_realistic = (soft_const_edu > 0 & missing(soft_const_edu) == 0)

g flag = ""
replace flag = flag + "/" + "Shorter duration of interviews than other enumerators" if flag_duration == 1
replace flag = flag + "/" + "Lower number of household members on average than other enumerators and what is expected in the state" if flag_hhm == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in main dataset" if flag_missing_main == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in separated roster" if flag_roster_separated == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in household roster" if flag_roster_hh == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in motor roster" if flag_roster_motor == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in durable goods roster" if flag_roster_assets == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in durable goods roster before displacement" if flag_roster_assets_prev == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in main food roster" if flag_roster_food == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in cereals roster" if flag_roster_cereals == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in fruits roster" if flag_roster_fruits == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in meat roster" if flag_roster_meat == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in vegetables roster" if flag_roster_vegetables == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in livestock roster" if flag_roster_livestock == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in livestock roster before displacement" if flag_roster_livestock_pre == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in non-food roster" if flag_roster_non_food == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in shocks roster" if flag_roster_shocks == 1
replace flag = flag + "/" + "Higher proportion of items said not to be consumed than other enumerators" if flag_ndkn_food_non_food == 1
replace flag = flag + "/" + "Too high proportion of missing quantities and prices for items consumed" if flag_prices_quant_food_non_food == 1
replace flag = flag + "/" + "Higher number of key questions skipped" if flag_skip == 1
replace flag = flag + "/" + "Answers on questions on remittances missing" if flag_remit == 1
replace flag = flag + "/" + "Answers on questions on IDP status missing" if flag_missing_idp == 1
replace flag = flag + "/" + "Answers on key questions on employment missing" if flag_ndkn_labour == 1
replace flag = flag + "/" + "Answers on key questions on education missing" if flag_ndkn_edu == 1
replace flag = flag + "/" + "Answers on housing conditions missing" if flag_ndkn_house == 1
replace flag = flag + "/" + "No food item said to be consumed" if flag_food_empty == 1
replace flag = flag + "/" + "No non-food item said to be consumed" if flag_non_food_empty == 1
replace flag = flag + "/" + "No durable good said to be owned" if flag_assets_empty == 1
replace flag = flag + "/" + "Low number of food items said to be consumed" if flag_nb_cons_food_low == 1
replace flag = flag + "/" + "Low number of non-food items said to be consumed" if flag_nb_cons_non_food_low == 1
replace flag = flag + "/" + "Low number of durable goods said to be owned" if flag_nb_own_assets_low == 1
replace flag = flag + "/" + "No shocks for any of the interviews" if flag_shocks_empty == 1
replace flag = flag + "/" + "Household was said not to be displaced whereas the EA is an IDP camp" if flag_idp == 1
replace flag = flag + "/" + "Number of years of education not realistic" if flag_edu_not_realistic == 1
replace flag = substr(flag,2,.)

*Final cleaning and labelling
label var state "State"
label var team_id "Team"
label var enum_id "Enumerator ID"
label var enum_name "Enumerator name"
label var date_stata "Day of data collection"
label var nb_itw "Total number of interviews"
label var itw_valid "Number of valid interviews"
label var successful "Number of successful interviews"
label var successful_valid "Number of valid and successful interviews"
label var successful_valid_cum "Number of valid and successful interviews - Cumulative"
label var gps_ok "Number of interviews meeting validity criteria for GPS coordinates"
label var gps_prop "Proportion of interviews meeting validity criteria for GPS coordinates"
label var valid_prop "Proportion of valid interviews"
label var no_response "Non-response rate"
label var nobody_home "Proportion of non-response due to the fact that there was no one at home"
label var no_adult "Proportion of non-response due to the absence of a knowlegeable adult at home"
label var no_consent "Proportion of non-response due to the the fact that no consent was given"
label var missing_prop_main "Proportion of missing answers on successful interviews - Main dataset"
label var missing_prop_hh_roster_separated "Proportion of missing answers on successful interviews - Separated roster"
label var missing_prop_hhroster_age "Proportion of missing answers on successful interviews - Household roster"
label var missing_prop_motor "Proportion of missing answers on successful interviews - Motor roster"
label var missing_prop_ra_assets "Proportion of missing answers on successful interviews - Assets roster"
label var missing_prop_ra_assets_prev "Proportion of missing answers on successful interviews - Assets roster, before displacement"
label var missing_prop_rf_food "Proportion of missing answers on successful interviews - Main food roster"
label var missing_prop_rf_food_cereals "Proportion of missing answers on successful interviews - Cereals roster"
label var missing_prop_rf_food_fruit "Proportion of missing answers on successful interviews - Fruits roster"
label var missing_prop_rf_food_meat "Proportion of missing answers on successful interviews - Meat roster"
label var missing_prop_rf_food_vegetables "Proportion of missing answers on successful interviews - Vegetables roster"
label var missing_prop_rl_livestock "Proportion of missing answers on successful interviews - Livestock roster"
label var missing_prop_rl_livestock_pre "Proportion of missing answers on successful interviews - Livestock roster, before displacement"
label var missing_prop_rnf_nonfood "Proportion of missing answers on successful interviews - Non-food roster"
label var missing_prop_shocks "Proportion of missing answers on successful interviews - Shocks roster"
label var nb_cons_food "Average number of food items said to be consumed per household"
label var nb_cons_non_food "Average number of non-food items said to be consumed per household"
label var ndkn_food "Average proportion of food items with no or don't know for consumption answer"
label var ndkn_food_quant "Average proportion of missing, unknown or refused to answer quantities and prices for consumed or purchased items in the food consumption module"
label var ndkn_non_food "Average proportion of non-food items with no or don't know for consumption answer"
label var ndkn_non_food_quant "Average proportion of missing, unknown or refused to answer prices for consumed or purchased items in the non-food consumption module"
label var ndkn_IDP_status "Proportion of missing, unknown or refused to answer to the question on IDP status"
label var ndkn_remittances_ext "Proportion of missing, unknown or refused to answer to the question on receipt of remittances"
label var ndkn_labour "Average proportion of missing, unknown or refused to answer to the question on being in the labour force"
label var nb_skip_patterns "Average number of skip patterns on successful interviews"	
label var prop_skip_patterns "Average proportion of skip patterns on successful interviews"	
label var soft_const_adult "Average proportion of interviews not respecting the soft constraint: at least one household member above 16"
label var soft_const_edu "Average proportion of interviews not respecting the soft constraint: realistic number of years of education"
label var duration_med "Median duration of interviews - minutes"
label var duration_mean "Mean duration of interviews - minutes"
label var duration_min "Min duration of interviews - minutes"
label var duration_max "Max duration of interviews - minutes"
label var nhhm_succ "Average number of household members for successful interviews"
label var nb_own_assets "Average number of assets owned by the household"
label var nb_shocks "Average number of shocks"
label var emp_7d_active "Average number of people in employment/inside the labour force"
label var fisheries "Number of valid and successful inteviews for which the fisheries module was activated"
label var disp "Total number of displaced households"
label var flag "Flag data quality control"
label var duration_med_all "Median duration of successful interviews - across all Enumerators"
label var ndkn_food_non_food_ave "Average proportion of 'no'/'don't know' in the food and non-food consumption module - across all Enumerators"	
label var nhhm_succ_ave "Average number of household members - across all Enumerators"

save "${gsdTemp}/hh_monitoring_dashboard_temp10", replace

keep state team_id enum_id enum_name date_stata ///
	nb_itw itw_valid successful successful_valid successful_valid_cum ///
	gps_ok gps_prop valid_prop no_response nobody_home no_adult no_consent ///
	missing_prop* nb_cons_food nb_cons_non_food ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ///
	ndkn_IDP_status ndkn_remittances_ext ndkn_labour ///
	nb_skip_patterns prop_skip_patterns soft_const_adult soft_const_edu ///
	duration_med duration_mean duration_min duration_max nhhm_succ nb_own_assets nb_shocks emp_7d_active fisheries disp flag ///
	duration_med_all ndkn_food_non_food_ave nhhm_succ_ave

order state team_id enum_id enum_name date_stata ///
	nb_itw itw_valid successful successful_valid successful_valid_cum ///
	gps_ok gps_prop valid_prop no_response nobody_home no_adult no_consent ///
	missing_prop* nb_cons_food nb_cons_non_food ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ///
	ndkn_IDP_status ndkn_remittances_ext ndkn_labour ///
	nb_skip_patterns prop_skip_patterns soft_const_adult soft_const_edu ///
	duration_med duration_mean duration_min duration_max nhhm_succ nb_own_assets nb_shocks emp_7d_active fisheries disp flag ///
	duration_med_all ndkn_food_non_food_ave nhhm_succ_ave

sort team_id enum_id date_stata

*Export	
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Enumerators") cell(B7) sheetmodify

restore

/*----------------------------------------------------------------------------*/
/*               MONITORING DASHBOARD: DATE OUTPUT                            */
/*----------------------------------------------------------------------------*/

preserve

*** Number of EAs originally sampled or active replacements used per date
*Originally sampled or active replacements
bysort date_stata id_ea: g nb_eas_sampled = 1 if _n == 1 & (sample_final_uri == 1 | sample_final_h == 1)
*Neither originally sampled nor active replacements
bysort date_stata id_ea: g nb_eas_not_sampled = 1 if _n == 1 & (sample_final_uri == 0 & sample_final_h == 0)

*Collapse by date
collapse (sum) nb_eas_sampled nb_eas_not_sampled ///
	nb_itw=index itw_valid successful successful_valid val_succ1-val_succ4 gps_ok ///
	(median) duration_med = duration_itw_min (mean) duration_mean = duration_itw_min ///
	(min) duration_min = duration_itw_min (max) duration_max = duration_itw_min, by(date_stata)

*Cumulative number of interviews by date
sort date_stata
g successful_valid_cum = sum(successful_valid)
*Target number of interviews, total Urban/Rural/IDPs + host communities
g target = 5856
*Proportion of interviews meeting validity criteria for GPS coordinates
g gps_prop = gps_ok/nb_itw
*Proportion of valid interviews
g valid_prop = itw_valid/nb_itw

*Final cleaning and labelling
label var date_stata "Day of data collection"
label var nb_eas_sampled "Number of EAs originally sampled or active replacements and used"
label var nb_eas_not_sampled "Number of EAs neither sampled nor active replacements but used"
label var nb_itw "Total number of interviews"
label var itw_valid "Number of valid interviews"
label var successful "Number of successful interviews"
label var successful_valid "Number of valid and successful interviews"
label var successful_valid_cum "Number of valid and successful interviews - Cumulative"
label var target "Target number of valid and successful interviews"
label var val_succ1 "Number of valid and successful interviews with Treat=1"
label var val_succ2 "Number of valid and successful interviews with Treat=2"
label var val_succ3 "Number of valid and successful interviews with Treat=3"
label var val_succ4 "Number of valid and successful interviews with Treat=4"
label var gps_ok "Number of interviews meeting validity criteria for GPS coordinates"
label var gps_prop "Proportion of interviews meeting validity criteria for GPS coordinates"
label var valid_prop "Proportion of valid interviews"
label var duration_med "Median duration of successful interviews - minutes"
label var duration_mean "Mean duration of successful interviews - minutes"
label var duration_min "Minimum duration of successful interviews - minutes"
label var duration_max "Maximum duration of successful interviews - minutes"

order date_stata nb_eas_sampled nb_eas_not_sampled ///
	nb_itw itw_valid successful successful_valid successful_valid_cum target ///
	val_succ1-val_succ4 gps_ok gps_prop valid_prop ///
	duration_med duration_mean duration_min duration_max

sort date_stata

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Date") cell(B6) sheetmodify
restore


/*----------------------------------------------------------------------------*/
/*                  MONITORING DASHBOARD: EA OUTPUT                           */
/*----------------------------------------------------------------------------*/

preserve

*List of valid and successful interviews per EA
gsort id_ea -int_no
decode int_no, g(int_no_str)
g list_val_succ = ","+int_no_str if successful_valid == 1
replace list_val_succ = list_val_succ + list_val_succ[_n-1] if id_ea == id_ea[_n-1]
replace list_val_succ = substr(list_val_succ,2,.)
bysort id_ea: g list_val_succ_ea = list_val_succ[_N] 

*Collapse by region/strata/EA
collapse (sum) nb_itw=index itw_valid successful successful_valid val_succ1 val_succ2 val_succ3 val_succ4 ///
		(mean) target_itw_ea (first) list_val_succ_ea ea_status ea_valid, by(ea_reg strata_id strata_name id_ea type_pop final_main_uri final_main_h tot_block) ///

*Target number of interviews for the Urban/Rural/IDP sample
g target_itw_ea_uri = 12*final_main_uri
*Target number of interviews for the host communities sample
g target_itw_ea_h = 12*final_main_h
*Number of valid and successful interviews conducted in the EA for the host communities sample
g successful_valid_h = min(successful_valid, target_itw_ea_h) if type_pop == "Urban/Rural and Host" | type_pop == "Host Only"
replace successful_valid_h = successful_valid if type_pop == "Host Only" & target_itw_ea_h == 0
*Number of valid and successful interviews conducted in the EA for the Urban/Rural/IDP sample
g successful_valid_uri = max(0, successful_valid - target_itw_ea_h) if type_pop != "Host Only"

save "${gsdTemp}/output_EA.dta", replace

*Final cleaning and labelling
label values ea_status ea_status_label
label var ea_reg "Region"
label var strata_id "Strata ID"
label var strata_name "Strata name"
label var type_pop "Type of population"
label var id_ea "EA"
label var nb_itw "Total number of interviews per EA"
label var itw_valid "Number of valid interviews per EA"
label var successful "Number of successful interviews per EA"
label var successful_valid "Number of valid and successful interviews per EA - All types of population"
label var successful_valid_uri "Number of valid and successful interviews per EA - Urban rural and IDPs"
label var successful_valid_h "Number of valid and successful interviews per EA - Host communities"	
label var target_itw_ea "Target valid and successful interviews - All types of population"	
label var target_itw_ea_uri "Target valid and successful interviews - Urban/Rural and IDPs"	
label var target_itw_ea_h "Target valid and successful interviews - Host communities"
label var val_succ1 "Number of valid and successful interviews of Treat=1 per EA"
label var val_succ2 "Number of valid and successful interviews of Treat=2 per EA"	
label var val_succ3 "Number of valid and successful interviews of Treat=3 per EA"	
label var val_succ4 "Number of valid and successful interviews of Treat=4 per EA"
label var ea_status "Status of the EA"
label var ea_valid "Whether EA is valid"
label var list_val_succ_ea "List of valid and successful interviews in the EA"

keep ea_reg strata_id strata_name id_ea type_pop nb_itw itw_valid successful successful_valid successful_valid_uri successful_valid_h ///
 target_itw_ea target_itw_ea_uri target_itw_ea_h val_succ1-val_succ4 ea_status ea_valid list_val_succ_ea
 
order ea_reg strata_id strata_name id_ea type_pop nb_itw itw_valid successful successful_valid successful_valid_uri successful_valid_h ///
 target_itw_ea target_itw_ea_uri target_itw_ea_h val_succ1-val_succ4 ea_status ea_valid list_val_succ_ea
	
sort strata_id id_ea

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - EA") cell(B6) sheetmodify
restore


/*----------------------------------------------------------------------------*/
/*                 MONITORING DASHBOARD: STRATA OUTPUT                        */
/*----------------------------------------------------------------------------*/

*** Target number of interviews per strata
preserve
import excel "${gsdDataRaw}/Inputs EAs.xls", sheet("Summary")clear
rename (A B C) (strata_name target_itw_strata_uri target_itw_strata_host)
drop target_itw_strata_host
drop if _n <= 4
destring target_itw_strata_uri, replace
save "${gsdTemp}/strata_target_itw.dta", replace
restore

preserve

*** Number of interviews urban/rural/IDP versus host communities per EA
merge m:1 id_ea using "${gsdTemp}/output_EA.dta", keepusing(successful_valid_uri successful_valid_h) nogenerate
*Keep the number of interviews per EA for the first observation of each EA only
bysort strata_id id_ea: g tokeep = (_n==1)
replace successful_valid_uri = tokeep*successful_valid_uri
replace successful_valid_h = tokeep*successful_valid_h

*** Number of EAs originally sampled or active replacements used per strata
*Originally sampled or active replacements
bysort strata_id id_ea: g nb_eas_sampled = 1 if _n == 1 & (sample_final_uri == 1 | sample_final_h == 1)
*Neither originally sampled nor active replacements
bysort strata_id id_ea: g nb_eas_not_sampled = 1 if _n == 1 & (sample_final_uri == 0 & sample_final_h == 0)

*Collapse by strata
collapse (sum) nb_eas_sampled nb_eas_not_sampled ///
	nb_itw=index itw_valid successful successful_valid successful_valid_uri successful_valid_h val_succ1-val_succ4 ///
	(mean) no_response nobody_home no_adult no_consent, by(strata_id strata_name)
	
*Target number of interviews per strata	
merge 1:1 strata_name using  "${gsdTemp}/strata_target_itw.dta", keep(match master) nogenerate
*Percentage of target reached in termes of number of valid and successful interviews
g perc_target = successful_valid_uri/target_itw_strata_uri
*Proportion of valid interviews (on all interviews)
g valid_prop = itw_valid/nb_itw

*Final cleaning and labelling
label var strata_id "Strata ID"
label var strata_name "Strata name"
label var nb_eas_sampled "Number of EAs originally sampled or active replacements and used"
label var nb_eas_not_sampled "Number of EAs neither sampled nor active replacements but used"
label var nb_itw "Total number of interviews"
label var itw_valid "Number of valid interviews"
label var successful "Number of successful interviews"
label var successful_valid "Number of valid and successful interviews"
label var successful_valid_uri "Number of valid and successful interviews: urban/rural/IDPs"
label var successful_valid_h "Number of valid and successful interviews: host communitites"
label var target_itw_strata "Target number of valid and successful interviews: urban/rural/IDPs"
label var perc_target "Percentage of target reached: urban/rural/IDPs"
label var val_succ1 "Number of valid and successful interviews with Treat=1"
label var val_succ2 "Number of valid and successful interviews with Treat=2"
label var val_succ3 "Number of valid and successful interviews with Treat=3"
label var val_succ4 "Number of valid and successful interviews with Treat=4"
label var valid_prop "Proportion of valid interviews"
label var no_response "Non-response rate"
label var nobody_home "Proportion of non-response due to the fact that there was no one at home"
label var no_adult "Proportion of non-response due to the absence of a knowlegeable adult at home"
label var no_consent "Proportion of non-response due to the the fact that no consent was given"

order strata_id strata_name nb_eas_sampled nb_eas_not_sampled ///
	nb_itw itw_valid successful successful_valid successful_valid_uri successful_valid_h target_itw_strata perc_target ///
	val_succ1-val_succ4 valid_prop no_response nobody_home no_adult no_consent

sort strata_id

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Strata") cell(B6) sheetmodify
restore

/*----------------------------------------------------------------------------*/
/*            MONITORING DASHBOARD: INVALID INTERVIEW OUTPUT                  */
/*----------------------------------------------------------------------------*/

preserve

*Keep only invalid interviews
keep if itw_valid == 0
*Keep only relevant variables
keep state strata_id strata_name team_id enum_id enum_name id_ea int_no date_stata itw_invalid_reason successful interview__id

*Generate dummy variables for each invalidity reason
g short_duration = (itw_invalid_reason==1)
g no_gps = (itw_invalid_reason==2)
g not_within_EA = (itw_invalid_reason==3)
g no_original_itw = (itw_invalid_reason==4)
g invalid_original_itw = (itw_invalid_reason==5)
g no_first_itw = (itw_invalid_reason==6)
g invalid_first_itw = (itw_invalid_reason==7)
g gps_no_match = (itw_invalid_reason==8)

*Final cleaning and labelling
label var date_stata "Day of data collection"
label var state "State"
label var strata_id "Strata ID"
label var strata_name "Strata name"
label var team_id "Team"
label var enum_id "Enumerator ID"
label var enum_name "Enumerator name"
label var id_ea "EA"
label var int_no "Interview number"
label var itw_invalid_reason "Reason for invalid interview"
label var short_duration "Duration does not exceed threshold"
label var no_gps "No GPS coordinates" 
label var not_within_EA "GPS coordinates do not fall within EA boundaries" 
label var no_original_itw "No record for the original household while it is a replacement household"
label var invalid_original_itw "Record for the original household is not valid while it is a replacement household"
label var no_first_itw "No previous record while it is not a first visit to the household" 
label var invalid_first_itw "Record for previous visit is not valid while it is a second or third visit" 
label var gps_no_match "The GPS coordinates do not match with the previous visit" 
label var successful "Whether the interview is successful"
label var interview__id "Key"

order date_stata state strata_id strata_name team_id enum_id enum_name id_ea int_no itw_invalid_reason ///
	short_duration no_gps not_within_EA no_original_itw invalid_original_itw no_first_itw invalid_first_itw gps_no_match successful interview__id 

gsort -date_stata team_id enum_id int_no itw_invalid_reason

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Invalid interviews") cell(B9) sheetmodify
restore

/*----------------------------------------------------------------------------*/
/*               MONITORING DASHBOARD: OUTPUT FLAGS                           */
/*----------------------------------------------------------------------------*/

preserve

use "${gsdTemp}/hh_monitoring_dashboard_temp10", clear

keep state team_id enum_id enum_name date_stata flag_*
order state team_id enum_id enum_name date_stata flag_duration flag_hhm ///
	flag_missing_main flag_roster_separated flag_roster_hh flag_roster_motor flag_roster_assets flag_roster_assets_prev flag_roster_food flag_roster_cereals flag_roster_fruits  flag_roster_meat flag_roster_vegetables flag_roster_livestock flag_roster_livestock_pre flag_roster_non_food flag_roster_shocks ///
	flag_ndkn_food_non_food flag_prices_quant_food_non_food flag_skip flag_remit flag_missing_idp flag_ndkn_labour flag_ndkn_edu flag_ndkn_house ///
	flag_food_empty flag_non_food_empty flag_assets_empty flag_nb_cons_food_low flag_nb_cons_non_food_low flag_nb_own_assets_low flag_shocks_empty flag_idp flag_edu_not_realistic
*Export	
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Flags") cell(B6) sheetmodify

restore


***** PART 2: NOMADS

*A separate monitoring dashboard is constructed for nomads

/*----------------------------------------------------------------------------*/
/*     IMPORT QUESTIONNAIRE AND GENERATE USEFUL VARIABLES FOR DASHBOARD       */
/*----------------------------------------------------------------------------*/

use "${gsdData}/0-RawTemp/hh_valid_keys_and_WPs.dta", clear

***Generating useful variables

**State (as per the distribution of Teams)
g state = "Somaliland" if team_id >= 1 & team_id <= 6
replace state = "Puntland" if team_id >= 7 & team_id <= 11
replace state = "Benadir" if (team_id >= 12 & team_id <= 16) | team_id==45
replace state = "Galmudug" if (team_id >= 17 & team_id <= 21) | team_id==44
replace state = "Hirshabelle" if team_id >= 22 & team_id <= 27
replace state = "South West" if team_id >= 28 & team_id <= 35
replace state = "Jubaland" if team_id >= 36 & team_id <= 43
label var state "State as per the distribution of Teams"

**Region
decode ea_reg, g(ea_reg_str)
drop ea_reg
rename ea_reg_str ea_reg

**Interviews meeting validity criteria for GPS coordinates
g gps_ok = (gps_coord_y_n == 1 & not_within_WP == 0)
label var gps_ok "Whether the interview is meeting validity criteria for GPS coordinates"

**Behavioural treatment for valid and successful interviews
g beh_treat0= (beh_treat_opt==0) if successful_valid==1
g beh_treat1= (beh_treat_opt==1) if successful_valid==1
label var beh_treat0 "Behavioural nudges not activated"
label var beh_treat1 "Behavioural nudges activated"

**Dummy variable to identify interviews where the fisheries module was activated
g fisheries = (fishing_yn == 1) if successful_valid == 1
label var fisheries "Whether the fisheries module was activated an valid and successful interviews"

/*----------------------------------------------------------------------------*/
/*       INDICATORS RELATED TO FOOD AND NON-FOOD CONSUMPTION MODULES          */
/*----------------------------------------------------------------------------*/

*** 1. Cleaning of the main dataset
*Replace consumption of food items to missing when the item was not included in the optional module activated for this interview
*Module 1
foreach var of varlist rf_relevanceyn1__3	rf_relevanceyn1__6	rf_relevanceyn1__8	rf_relevanceyn1__10	rf_relevanceyn1__12	rf_relevanceyn1__15	rf_relevanceyn2__21	rf_relevanceyn2__23	rf_relevanceyn2__24	rf_relevanceyn2__25	rf_relevanceyn2__28	rf_relevanceyn2__29	rf_relevanceyn2__30	rf_relevanceyn3__32	rf_relevanceyn3__34	rf_relevanceyn3__37	rf_relevanceyn3__38	rf_relevanceyn3__39	rf_relevanceyn3__41	rf_relevanceyn4__46	rf_relevanceyn4__49	rf_relevanceyn4__56	rf_relevanceyn4__58	rf_relevanceyn4__60	rf_relevanceyn4__61	rf_relevanceyn4__63	rf_relevanceyn4__65	rf_relevanceyn4__66	rf_relevanceyn4__67	rf_relevanceyn4__68	rf_relevanceyn4__69	rf_relevanceyn__70	rf_relevanceyn__71	rf_relevanceyn__72	rf_relevanceyn__73	rf_relevanceyn__77	rf_relevanceyn__78	rf_relevanceyn__79	rf_relevanceyn__87	rf_relevanceyn__88	rf_relevanceyn__89	rf_relevanceyn__91	rf_relevanceyn__93	rf_relevanceyn__94	rf_relevanceyn__95	rf_relevanceyn__96	rf_relevanceyn__97	rf_relevanceyn__98	rf_relevanceyn__99	rf_relevanceyn__101	rf_relevanceyn__102	rf_relevanceyn__104	rf_relevanceyn__106	rf_relevanceyn__113	rf_relevanceyn__114	rnf_relevanceyn1__1002	rnf_relevanceyn1__1003	rnf_relevanceyn1__1006	rnf_relevanceyn2__1004	rnf_relevanceyn2__1011	rnf_relevanceyn2__1012	rnf_relevanceyn2__1014	rnf_relevanceyn2__1021	rnf_relevanceyn2__1025	rnf_relevanceyn2__1029	rnf_relevanceyn2__1030	rnf_relevanceyn2__1031	rnf_relevanceyn2__1034	rnf_relevanceyn3__1037	rnf_relevanceyn3__1038	rnf_relevanceyn3__1041	rnf_relevanceyn3__1042	rnf_relevanceyn3__1043	rnf_relevanceyn3__1044	rnf_relevanceyn3__1045	rnf_relevanceyn3__1047	rnf_relevanceyn3__1048	rnf_relevanceyn3__1049	rnf_relevanceyn3__1050	rnf_relevanceyn3__1051	rnf_relevanceyn3__1052	rnf_relevanceyn3__1053	rnf_relevanceyn3__1054	rnf_relevanceyn3__1056	rnf_relevanceyn3__1057	rnf_relevanceyn3__1058	rnf_relevanceyn3__1059	rnf_relevanceyn3__1060	rnf_relevanceyn3__1061	rnf_relevanceyn3__1062	rnf_relevanceyn3__1063	rnf_relevanceyn3__1065	rnf_relevanceyn3__1066	rnf_relevanceyn4__1072	rnf_relevanceyn4__1073	rnf_relevanceyn4__1074	rnf_relevanceyn4__1075	rnf_relevanceyn4__1081	rnf_relevanceyn4__1088	rnf_relevanceyn4__1089	rnf_relevanceyn4__1090 {
	replace `var' = . if mod_opt == 1
}
*Module 2
foreach var of varlist rf_relevanceyn1__3	rf_relevanceyn1__4	rf_relevanceyn1__8	rf_relevanceyn1__11	rf_relevanceyn1__12	rf_relevanceyn1__15	rf_relevanceyn1__16	rf_relevanceyn2__21	rf_relevanceyn2__22	rf_relevanceyn2__23	rf_relevanceyn2__24	rf_relevanceyn2__25	rf_relevanceyn2__27	rf_relevanceyn2__30	rf_relevanceyn3__34	rf_relevanceyn3__35	rf_relevanceyn3__36	rf_relevanceyn3__37	rf_relevanceyn3__38	rf_relevanceyn3__39	rf_relevanceyn3__40	rf_relevanceyn3__42	rf_relevanceyn3__43	rf_relevanceyn4__46	rf_relevanceyn4__49	rf_relevanceyn4__55	rf_relevanceyn4__58	rf_relevanceyn4__60	rf_relevanceyn4__61	rf_relevanceyn4__62	rf_relevanceyn4__64	rf_relevanceyn4__66	rf_relevanceyn4__67	rf_relevanceyn4__68	rf_relevanceyn4__69	rf_relevanceyn__70	rf_relevanceyn__72	rf_relevanceyn__73	rf_relevanceyn__77	rf_relevanceyn__79	rf_relevanceyn__83	rf_relevanceyn__84	rf_relevanceyn__86	rf_relevanceyn__87	rf_relevanceyn__88	rf_relevanceyn__89	rf_relevanceyn__91	rf_relevanceyn__92	rf_relevanceyn__93	rf_relevanceyn__99	rf_relevanceyn__100	rf_relevanceyn__101	rf_relevanceyn__102	rf_relevanceyn__104	rf_relevanceyn__105	rf_relevanceyn__107	rf_relevanceyn__112	rf_relevanceyn__113	rnf_relevanceyn1__1003	rnf_relevanceyn2__1004	rnf_relevanceyn2__1011	rnf_relevanceyn2__1012	rnf_relevanceyn2__1015	rnf_relevanceyn2__1016	rnf_relevanceyn2__1020	rnf_relevanceyn2__1021	rnf_relevanceyn2__1022	rnf_relevanceyn2__1025	rnf_relevanceyn2__1029	rnf_relevanceyn2__1030	rnf_relevanceyn2__1031	rnf_relevanceyn2__1032	rnf_relevanceyn2__1034	rnf_relevanceyn3__1036	rnf_relevanceyn3__1037	rnf_relevanceyn3__1039	rnf_relevanceyn3__1040	rnf_relevanceyn3__1041	rnf_relevanceyn3__1043	rnf_relevanceyn3__1044	rnf_relevanceyn3__1046	rnf_relevanceyn3__1047	rnf_relevanceyn3__1048	rnf_relevanceyn3__1050	rnf_relevanceyn3__1052	rnf_relevanceyn3__1054	rnf_relevanceyn3__1055	rnf_relevanceyn3__1056	rnf_relevanceyn3__1057	rnf_relevanceyn3__1058	rnf_relevanceyn3__1061	rnf_relevanceyn3__1062	rnf_relevanceyn3__1063	rnf_relevanceyn3__1064	rnf_relevanceyn3__1065	rnf_relevanceyn3__1066	rnf_relevanceyn4__1072	rnf_relevanceyn4__1074	rnf_relevanceyn4__1076	rnf_relevanceyn4__1077	rnf_relevanceyn4__1081	rnf_relevanceyn4__1087	rnf_relevanceyn4__1090 {
	replace `var' = . if mod_opt == 2
}
*Module 3
foreach var of varlist rf_relevanceyn1__4	rf_relevanceyn1__6	rf_relevanceyn1__10	rf_relevanceyn1__11	rf_relevanceyn1__15	rf_relevanceyn1__16	rf_relevanceyn2__21	rf_relevanceyn2__22	rf_relevanceyn2__23	rf_relevanceyn2__27	rf_relevanceyn2__28	rf_relevanceyn2__29	rf_relevanceyn2__30	rf_relevanceyn3__32	rf_relevanceyn3__35	rf_relevanceyn3__36	rf_relevanceyn3__37	rf_relevanceyn3__38	rf_relevanceyn3__39	rf_relevanceyn3__40	rf_relevanceyn3__41	rf_relevanceyn3__42	rf_relevanceyn3__43	rf_relevanceyn4__49	rf_relevanceyn4__55	rf_relevanceyn4__56	rf_relevanceyn4__58	rf_relevanceyn4__60	rf_relevanceyn4__62	rf_relevanceyn4__63	rf_relevanceyn4__64	rf_relevanceyn4__65	rf_relevanceyn4__68	rf_relevanceyn__71	rf_relevanceyn__73	rf_relevanceyn__78	rf_relevanceyn__83	rf_relevanceyn__84	rf_relevanceyn__86	rf_relevanceyn__87	rf_relevanceyn__88	rf_relevanceyn__89	rf_relevanceyn__92	rf_relevanceyn__94	rf_relevanceyn__95	rf_relevanceyn__96	rf_relevanceyn__97	rf_relevanceyn__98	rf_relevanceyn__99	rf_relevanceyn__100	rf_relevanceyn__102	rf_relevanceyn__105	rf_relevanceyn__106	rf_relevanceyn__107	rf_relevanceyn__112	rf_relevanceyn__113	rf_relevanceyn__114	rnf_relevanceyn1__1002	rnf_relevanceyn1__1006	rnf_relevanceyn2__1004	rnf_relevanceyn2__1012	rnf_relevanceyn2__1014	rnf_relevanceyn2__1015	rnf_relevanceyn2__1016	rnf_relevanceyn2__1020	rnf_relevanceyn2__1021	rnf_relevanceyn2__1022	rnf_relevanceyn2__1032	rnf_relevanceyn2__1034	rnf_relevanceyn3__1036	rnf_relevanceyn3__1038	rnf_relevanceyn3__1039	rnf_relevanceyn3__1040	rnf_relevanceyn3__1042	rnf_relevanceyn3__1044	rnf_relevanceyn3__1045	rnf_relevanceyn3__1046	rnf_relevanceyn3__1049	rnf_relevanceyn3__1051	rnf_relevanceyn3__1052	rnf_relevanceyn3__1053	rnf_relevanceyn3__1055	rnf_relevanceyn3__1056	rnf_relevanceyn3__1057	rnf_relevanceyn3__1058	rnf_relevanceyn3__1059	rnf_relevanceyn3__1060	rnf_relevanceyn3__1063	rnf_relevanceyn3__1064	rnf_relevanceyn3__1065	rnf_relevanceyn3__1066	rnf_relevanceyn4__1072	rnf_relevanceyn4__1073	rnf_relevanceyn4__1075	rnf_relevanceyn4__1076	rnf_relevanceyn4__1077	rnf_relevanceyn4__1081	rnf_relevanceyn4__1087	rnf_relevanceyn4__1088	rnf_relevanceyn4__1089	rnf_relevanceyn4__1090 {
	replace `var' = . if mod_opt == 3
}
*Module 4
foreach var of varlist  rf_relevanceyn1__3	rf_relevanceyn1__4	rf_relevanceyn1__6	rf_relevanceyn1__8	rf_relevanceyn1__10	rf_relevanceyn1__11	rf_relevanceyn1__12	rf_relevanceyn1__16	rf_relevanceyn2__22	rf_relevanceyn2__24	rf_relevanceyn2__25	rf_relevanceyn2__27	rf_relevanceyn2__28	rf_relevanceyn2__29	rf_relevanceyn3__32	rf_relevanceyn3__34	rf_relevanceyn3__35	rf_relevanceyn3__36	rf_relevanceyn3__40	rf_relevanceyn3__41	rf_relevanceyn3__42	rf_relevanceyn3__43	rf_relevanceyn4__46	rf_relevanceyn4__55	rf_relevanceyn4__56	rf_relevanceyn4__61	rf_relevanceyn4__62	rf_relevanceyn4__63	rf_relevanceyn4__64	rf_relevanceyn4__65	rf_relevanceyn4__66	rf_relevanceyn4__67	rf_relevanceyn4__69	rf_relevanceyn__70	rf_relevanceyn__71	rf_relevanceyn__72	rf_relevanceyn__77	rf_relevanceyn__78	rf_relevanceyn__79	rf_relevanceyn__83	rf_relevanceyn__84	rf_relevanceyn__86	rf_relevanceyn__91	rf_relevanceyn__92	rf_relevanceyn__93	rf_relevanceyn__94	rf_relevanceyn__95	rf_relevanceyn__96	rf_relevanceyn__97	rf_relevanceyn__98	rf_relevanceyn__100	rf_relevanceyn__101	rf_relevanceyn__104	rf_relevanceyn__105	rf_relevanceyn__106	rf_relevanceyn__107	rf_relevanceyn__112	rf_relevanceyn__114	rnf_relevanceyn1__1002	rnf_relevanceyn1__1003	rnf_relevanceyn1__1006	rnf_relevanceyn2__1011	rnf_relevanceyn2__1014	rnf_relevanceyn2__1015	rnf_relevanceyn2__1016	rnf_relevanceyn2__1020	rnf_relevanceyn2__1022	rnf_relevanceyn2__1025	rnf_relevanceyn2__1029	rnf_relevanceyn2__1030	rnf_relevanceyn2__1031	rnf_relevanceyn2__1032	rnf_relevanceyn3__1036	rnf_relevanceyn3__1037	rnf_relevanceyn3__1038	rnf_relevanceyn3__1039	rnf_relevanceyn3__1040	rnf_relevanceyn3__1041	rnf_relevanceyn3__1042	rnf_relevanceyn3__1043	rnf_relevanceyn3__1045	rnf_relevanceyn3__1046	rnf_relevanceyn3__1047	rnf_relevanceyn3__1048	rnf_relevanceyn3__1049	rnf_relevanceyn3__1050	rnf_relevanceyn3__1051	rnf_relevanceyn3__1053	rnf_relevanceyn3__1054	rnf_relevanceyn3__1055	rnf_relevanceyn3__1059	rnf_relevanceyn3__1060	rnf_relevanceyn3__1061	rnf_relevanceyn3__1062	rnf_relevanceyn3__1064	rnf_relevanceyn4__1073	rnf_relevanceyn4__1074	rnf_relevanceyn4__1075	rnf_relevanceyn4__1076	rnf_relevanceyn4__1077	rnf_relevanceyn4__1087	rnf_relevanceyn4__1088	rnf_relevanceyn4__1089 {
	replace `var' = . if mod_opt == 4
}

*** 2. Proportion of no/unanswered for consumption of items in the food and non-food consumption modules in the main dataset
*Create dummy variable = 1 if the item was not consumed by the household, for all food and non-food items
*Create dummy variable = 1 if the item was consumed by the household, for all food and non-food items
foreach var of varlist rf_relevanceyn* rnf_relevanceyn* {
		gen not_cons_`var' = (`var' == 0 | `var' == -999999999) if successful == 1
		gen cons_`var' = (`var' == 1) if successful == 1
	}
*Number of food items consumed
egen nb_cons_food = rowtotal(cons_rf_relevanceyn*) if successful == 1
g flag_food_empty = (nb_cons_food==0) if successful == 1
label var nb_cons_food "Numer of food items said to be consumed"
label var flag_food_empty "Whether no food item was said to be consumed"
*Number of non-food items consumed
egen nb_cons_non_food = rowtotal(cons_rnf_relevanceyn*) if successful == 1
g flag_non_food_empty = (nb_cons_non_food==0) if successful == 1
label var nb_cons_non_food "Numer of non-food items said to be consumed"
label var flag_non_food_empty "Whether no non-food item was said to be consumed"
*Proportion of no/don't know for food items
egen ndkn_food = rowmean(not_cons_rf_relevanceyn*) if successful == 1
label var ndkn_food "Proportion of food items with no or don't know for consumption answer"
*Proportion of no/don't know for non-food items
egen ndkn_non_food = rowmean(not_cons_rnf_relevanceyn*) if successful == 1
label var ndkn_non_food "Proportion of non-food items with no or don't know for consumption answer"
*Final cleaning
drop not_cons_* cons_*
save "${gsdTemp}/hh_monitoring_dashboard_temp1_nomads", replace

*** 3. Proportion of missing/don't know/refused to answer for quantities and prices relating to food items consumed

**Appending all food rosters
local files rf_food_cereals rf_food_meat rf_food_fruit rf_food_vegetables
local i 1
use "${gsdData}/0-RawTemp/rf_food_manual_cleaning_nomads.dta", clear
keep interview__id rf_food__id rf_cons_quant rf_purc_quant rf_pric_total
rename rf_food__id Id
save "${gsdTemp}/rf_food_all_nomads.dta", replace

foreach file in `files' {
	use "${gsdData}/0-RawTemp/`file'_manual_cleaning_nomads.dta", clear
	*Keep variables "quantity consumed", "quantity purchased", "price paid for quantity purchased"
	keep interview__id `file'__id rf_cons_quant`i' rf_purc_quant`i' rf_pric_total`i'
	rename (`file'__id rf_cons_quant`i' rf_purc_quant`i' rf_pric_total`i') (Id rf_cons_quant rf_purc_quant rf_pric_total)
	*Append with food roster
	append using "${gsdTemp}/rf_food_all_nomads.dta"
	save "${gsdTemp}/rf_food_all_nomads.dta", replace
	local i = `i'+1
}

**Creating dummy variables: whether the quantities and prices for food items are missing/unknown/refused to answer
g dummy_rf_cons_quant = (rf_cons_quant == . | rf_cons_quant == -999999999)
g dummy_rf_purc_quant = (rf_purc_quant == . | rf_purc_quant == -999999999)
g dummy_rf_pric_total = (rf_pric_total == . | rf_pric_total == -999999999)
drop rf_cons_quant rf_purc_quant rf_pric_total

**Reshaping to get one row per interview with all items and whether the quantities/prices for those items are known in columns
reshape wide dummy_rf_cons_quant dummy_rf_purc_quant dummy_rf_pric_total, i(interview__id) j(Id)

**At the interview level, aggregating proportion of quantities and prices for which answer is missing/unknown/refused to answer among all food items
egen ndkn_food_quant = rowmean(dummy*)
label var ndkn_food_quant "Proportion of missing or don't know or refused to answer for quantities and prices in the food consumption module"
keep interview__id ndkn_food_quant

**Merging with main dataset
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp1_nomads", nogenerate
order ndkn_food_quant, last
save "${gsdTemp}/hh_monitoring_dashboard_temp2_nomads", replace

*** 4. Proportion of missing/don't know/refused to answer for prices relating to non-food items consumed

**Importing non-food roster and merging with main dataset
use "${gsdData}/0-RawTemp/rnf_nonfood_manual_cleaning_nomads.dta", clear
sort interview__id rnf_nonfood__id
*Dropping one item (water supply) which does not appear in the list of items in the main dataset
drop if rnf_nonfood__id == 1071
*Keeping interview Id, item Id, and variable "price paid for the amount of item that was purchased"
keep interview__id rnf_nonfood__id rnf_pric_total
*Reshaping to get one row per interview with all items and their price in columns
reshape wide rnf_pric_total, i(interview__id) j(rnf_nonfood__id)
*Merging with main dataset
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp2_nomads", nogenerate
order rnf_pric_total*, last

**Proportion of non-food items consumed by the household for which price was missing/unknown/refused to answer
*Renaming variables in order to match the price of each item with the variables indicating whether the item was consumed or not
foreach var of varlist rnf_relevanceyn* {
   	local itemID = substr("`var'", -2, .)
   	g rnf_relevanceyn_`itemID' = `var'
}
foreach var of varlist rnf_pric_total* {
   	local itemID = substr("`var'", -2, .)
   	g rnf_pric_total_`itemID' = `var'
}

*Dummy variables for each non-food item: if the item was consumed by the household, whether its price was missing/unknown/refused to answer
foreach var of varlist rnf_pric_total_* {
   	local itemID = substr("`var'", -2, .)
	g ndkn_non_food_quant_`itemID' = (rnf_pric_total_`itemID' == . | rnf_pric_total_`itemID' == -1000000000 | rnf_pric_total_`itemID' == -999999999) if rnf_relevanceyn_`itemID' == 1
}
*Proportion of non-food items consumed by the household for which price was missing/unknown/refused to answer
egen ndkn_non_food_quant = rowmean(ndkn_non_food_quant_*)
label var ndkn_non_food_quant "Proportion of missing/unknown/refused to answer prices in the non-food consumption module"
drop ndkn_non_food_quant_* rnf_relevanceyn_* rnf_pric_total*

/*----------------------------------------------------------------------------*/
/*      	INDICATORS RELATED TO COMPLETENESS OF ANSWERS		              */
/*----------------------------------------------------------------------------*/

*** 1. Proportion of missing answers in the main dataset
*Dummy variables: whether each variable of the interview is missing or not
ds athome-share_phone_agencies , has(type string)
local string0 `r(varlist)'
ds hh_list__0-hh_list_separated__9
local omit1 `r(varlist)'
local string : list string0 - omit1

ds athome-share_phone_agencies, has(type numeric)
local numeric `r(varlist)'

foreach var of local string {
	gen mi_`var' = (`var' == "##N/A##") if `var' != ""
}
foreach var of local numeric {
	gen mi_`var' = (`var'== -999999999 | `var'== -1000000000) if `var' != .
}
*Proportion of missing answers
egen missing_prop_main = rowmean(mi_*) if successful == 1
drop mi_*
label var missing_prop_main "Proportion of missing answers in the main dataset" 
save "${gsdTemp}/hh_monitoring_dashboard_temp3_nomads", replace

*** 2. Proportion of missing answers for each roster
local files hh_roster_separated hhroster_age motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
foreach file in `files' {
more
more
more
	use "${gsdData}/0-RawTemp/`file'_manual_cleaning_nomads.dta", clear
	*Dummy variables: whether each variable is missing or not
	ds *, has(type string)
	local str_all_`file' `r(varlist)'
	local str_omit_`file' interview__id
	local str_`file' : list str_all_`file' - str_omit_`file'
	
	ds *, has(type numeric)
	local num_all_`file' `r(varlist)'
	local num_omit_`file' `file'__id
	local num_`file' : list num_all_`file' - num_omit_`file'
	
	foreach var of local str_`file' {
		gen mi_`var' = (`var' == "##N/A##") if `var' != ""
	}
	foreach var of local num_`file' {
		gen mi_`var' = (`var'== -999999999 | `var'== -1000000000) if `var' != .
	}
	*Proportion of missing answers
	capture: egen missing_prop_`file' = rowmean(mi_*)
	*Collapse per interview
	capture: collapse (mean) missing_prop_`file', by(interview__id)
	*If roster is empty, tostring ID variables for merge
	if _rc != 0 {
		tostring interview__id, replace
		tostring interview__key, replace
	}
	*Merging with main dataset
	merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp3_nomads", nogenerate
	label var missing_prop_`file' "Proportion of missing answers in roster `file'" 
	order missing_prop_`file', last
	more
	more
	more
	save "${gsdTemp}/hh_monitoring_dashboard_temp3_nomads", replace
}

*Set proportion of missing answers in the non-food dataset to 0 when the interview was not successful
replace missing_prop_rnf_nonfood = . if successful == 0

*** 3. Key question: Remittances
**Dummy variable: whether answer to the question on receipt of remittances (from abroad) is missing/don't know/refused to answer
g ndkn_remittances_ext = (remit12m_yn == -98 | remit12m_yn == -99 | remit12m_yn == -999999999 | remit12m_yn == -1000000000) if successful == 1
label var ndkn_remittances_ext "Whether answer to the question on receipt of remittances (from abroad) is missing/don't know/refused to answer"
**Dummy variable: whether answer to the question on receipt of remittances (from within the country) is missing/don't know/refused to answer
g ndkn_remittances_int = (intremit12m_yn == -98 | intremit12m_yn == -99 | intremit12m_yn == -999999999 | intremit12m_yn == -1000000000) if successful == 1
label var ndkn_remittances_int "Whether answer to the question on receipt of remittances (from within the country) is missing/don't know/refused to answer"
** Flag if info on remittances is missing (eithe domestic or international remittances)
g flag_remit = (ndkn_remittances_ext ==1 | ndkn_remittances_int ==1) if successful == 1
label var flag_remit "Whether answers to the question on receipt of remittances - domestic or international - are missing"

*** 4. Key question: IDP status
**Dummy variable: whether answer to the question on forced displacement is missing
g ndkn_IDP_status = (migr_disp == -999999999 | migr_disp == -1000000000) if successful == 1
label var ndkn_IDP_status "Whether answer to the question on forced displacement is missing"
save "${gsdTemp}/hh_monitoring_dashboard_temp4_nomads", replace

*** 5. Key questions: Employment
**Proportion of missing/don't know/refused to answer to the question on being inside the labour force
*Dummy variable: whether answer is missing, unknown or refused to answer for ALL kinds of activities for this household member
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning_nomads.dta", clear
g ndkn_labour = ((emp_7d_paid == -98 | emp_7d_paid == -99 | emp_7d_paid == . | emp_7d_paid == -999999999 | emp_7d_paid == -1000000000) & ///
				 (emp_7d_busi == -98 | emp_7d_busi == -99 | emp_7d_busi == . | emp_7d_busi == -999999999 | emp_7d_busi == -1000000000) & ///
				 (emp_7d_help == -98 | emp_7d_help == -99 | emp_7d_help == . | emp_7d_help == -999999999 | emp_7d_help == -1000000000) & ///
				 (emp_7d_farm == -98 | emp_7d_farm == -99 | emp_7d_farm == . | emp_7d_farm == -999999999 | emp_7d_farm == -1000000000) & ///
				 (emp_7d_appr == -98 | emp_7d_appr == -99 | emp_7d_appr == . | emp_7d_appr == -999999999 | emp_7d_appr == -1000000000)) if hhm_age > 14
*Proportion of don't know/refused to answer by interview (average on all household members) 
collapse (mean) ndkn_labour, by(interview__id)
g flag_ndkn_labour = (ndkn_labour >0)
keep interview__id ndkn_labour flag_ndkn_labour
*Merge with main dataset
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp4_nomads", nogenerate 
order ndkn_labour flag_ndkn_labour, last
label var ndkn_labour "Proportion of missing/don't know/refused to answer to the question on being inside the labour force"
label var flag_ndkn_labour "Whether the answer to the question on being inside the labour force is missing/don't know/refused to answer for at least one household members"
save "${gsdTemp}/hh_monitoring_dashboard_temp5_nomads", replace

*** 6. Key questions: Education
*Dummy variable: whether answer is missing, unknown or refused to answer for ALL key education variables for this household member
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning_nomads.dta", clear
g flag_ndkn_edu = ((hhm_read == -98 | hhm_read == -99 | hhm_read == . | hhm_read == -999999999 | hhm_read == -1000000000) & ///
				 (hhm_write == -98 | hhm_write == -99 | hhm_write == . | hhm_write == -999999999 | hhm_write == -1000000000) & ///
				 (hhm_edu_ever == -98 | hhm_edu_ever == -99 | hhm_edu_ever == . | hhm_edu_ever == -999999999 | hhm_edu_ever == -1000000000) & ///
				 (hhm_edu_years == -98 | hhm_edu_years == -99 | hhm_edu_years == . | hhm_edu_years == -999999999 | hhm_edu_years == -1000000000) & ///
				 (hhm_edu_level == -98 | hhm_edu_level == -99 | hhm_edu_level == . | hhm_edu_level == -999999999 | hhm_edu_level == -1000000000)) if hhm_age > 5
*Dummy variable at the interview level: whether ALL key variables on education are missing for at least one household member
collapse (max) flag_ndkn_edu, by(interview__id)
keep interview__id flag_ndkn_edu   
*Merge with main dataset
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp5_nomads", nogenerate 
order flag_ndkn_edu, last
label var flag_ndkn_edu "Whether all key variables on education are missing for at least one household member"

*** 7. Key questions: Housing conditions
*Dummy variable: whether answer is missing, unknown or refused to answer for ALL key housing variables
g flag_ndkn_house = ((housingtype == -98 | housingtype == -99 | housingtype == . | housingtype == -999999999 | housingtype == -1000000000) & ///
				 (cook == -98 | cook == -99 | cook == . | cook == -999999999 | cook == -1000000000) & ///
				 (toilet == -98 | toilet == -99 | toilet == . | toilet == -999999999 | toilet == -1000000000) & ///
				 (roof_material == -98 | roof_material == -99 | roof_material == . | roof_material == -999999999 | roof_material == -1000000000)) if successful == 1
label var flag_ndkn_house "Whether all key variables on housing conditions are missing"

/*----------------------------------------------------------------------------*/
/*      		     INDICATORS RELATED TO SKIP PATTERNS                      */
/*----------------------------------------------------------------------------*/

**Number of skip patterns on successful interviews
*Important skip patterns relate to livestock, durable goods, shocks, displacements, fishing, leavers' roster, remittances (14 possible skip patterns)
foreach var of varlist rl_raise__1-rl_raise__1000 migr_disp migr_disp_past fishing_yn hhm_separated intremit12m_yn remit12m_yn{
	capture: gen skip_`var' = 1 if (`var' == 0 | `var' == -999999999 | `var' == -1000000000 |`var' == -98 | `var' == -99) & successful == 1
}

save "${gsdTemp}/hh_monitoring_dashboard_temp6_nomads", replace

*Another important skip pattern relate to employment in farming/livestock raising
*Import household roster
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning_nomads.dta", clear
*Skip pattern = + 1 for each no/don't know/refused to answer to questions on farming/livestock raising per member of the household
g skip_employment = (inlist(emp_7d_farm,0,-98,-99,.,-999999999, -1000000000)) if hhm_age > 14
*Total number of skip patterns per interview on employment(collapse on household members)
collapse (sum) skip_employment, by(interview__id)
*Merge with main dataset
keep interview__id skip_employment 
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp6_nomads", nogenerate 
order skip_employment, last

*Total number of skip patterns on successful interviews
egen nb_skip_patterns = rowtotal(skip*) if successful == 1
label var nb_skip_patterns "Number of important skip patterns activated in the interview"
*Proportion of skip patterns out of total number of skip patterns
g prop_skip_patterns = nb_skip_patterns/(14+nadults)
label var prop_skip_patterns "Proportion of important skip patterns activated in the interview"
drop skip*
save "${gsdTemp}/hh_monitoring_dashboard_temp7_nomads", replace


/*----------------------------------------------------------------------------*/
/*      		     INDICATORS RELATED TO SOFT CONSTRAINTS                   */
/*----------------------------------------------------------------------------*/

/*Soft constraints:
	1) one of the household members must be 16 or above (cf. minimum age of the respondent)
	2) the number of years of education must be realistic
The variables are equal to 1 if the soft constraint is not respected and 0 otherwise */

**Import household members roster 
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning_nomads.dta", clear

**Dummy variables at the household member level
*Household member is not an adult if he/she is not above 16
g not_adult = (hhm_age < 16) if missing(hhm_age)==0 & hhm_age != -999999999 & hhm_age != -1000000000
*Household member has an unrealistic number of years of education if it exceeds 30 years or if it exceeds the age of the household member
g edu_not_realistic = (hhm_edu_years >= 30 | hhm_edu_years > hhm_age) if missing(hhm_age) == 0 & hhm_age != -999999999 & hhm_age != -1000000000 & missing(hhm_edu_years) == 0

**Add soft constraints dummies into main dataset
keep interview__id not_adult edu_not_realistic
*Collapse to have one row per household and whether the soft constraints 1 and 2 are respected or not
collapse (min) soft_const_adult=not_adult (max) soft_const_edu=edu_not_realistic, by(interview__id)
*Merge with main dataset
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp7_nomads", nogenerate 
order soft*, last
label var soft_const_adult "Whether soft constraint on age is not respected"
label var soft_const_edu "Whether soft constraint on education is not respected"

/*----------------------------------------------------------------------------*/
/*      		    INDICATORS RELATED TO LIVESTOCK   			              */
/*----------------------------------------------------------------------------*/

**Number of different types of livestock raised
g nb_types_livestock = 0 if successful == 1
foreach var of varlist rl_raise__* {
	replace nb_types_livestock = nb_types_livestock + 1 if `var' == 1 & successful == 1
}
*Flag if no livestock raised
g flag_no_livestock = (nb_types_livestock == 0) if successful_valid == 1
*Indicator 1: Proportion of households raising livestock
sum flag_no_livestock
putexcel BF7=(1-r(mean)) using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master_Nomads.xlsm", sheet("Master dashboard") modify

**Whether farming/livestock raising is the main source of livelihood for the household
g livelihood_farming = (lhood == 8) if successful == 1

**Whether the household has experienced drought during the last 12 months
g drought = (shocks0__1 == 1) if successful == 1

save "${gsdTemp}/hh_monitoring_dashboard_temp8_nomads", replace

**Average proportion of missing quantities of livestock raised/owned, currently and before displacement
*Currently
use "${gsdData}/0-RawTemp/rl_livestock_manual_cleaning_nomads.dta"
g mi_rl_own_n = (rl_own_n== -999999999 | rl_own_n== -1000000000 | rl_own_n == .)
g mi_rl_own_r_n = (rl_own_r_n== -999999999 | rl_own_r_n== -1000000000 | rl_own_r_n == .)
g mi_prop_quant_livestock = (mi_rl_own_n+mi_rl_own_r_n)/2
collapse (mean) mi_prop_quant_livestock, by(interview__id)
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp8_nomads"
order mi_prop_quant_livestock, last
save "${gsdTemp}/hh_monitoring_dashboard_temp9_nomads", replace
*Before displacement
use "${gsdData}/0-RawTemp/rl_livestock_pre_manual_cleaning_nomads.dta"
g mi_rl_own_pre = (rl_own_pre== -999999999 | rl_own_pre== -1000000000 | rl_own_pre == .)
g mi_rl_own_pre_r_n = (rl_own_pre_r_n== -999999999 | rl_own_pre_r_n== -1000000000 | rl_own_pre_r_n == .)
g mi_prop_quant_livestock_pre = (mi_rl_own_pre+mi_rl_own_pre_r_n)/2
collapse (mean) mi_prop_quant_livestock_pre, by(interview__id)
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp9_nomads", nogenerate
order mi_prop_quant_livestock_pre, last
save "${gsdTemp}/hh_monitoring_dashboard_temp10_nomads", replace

**Total number of animals raised (check for outliers)
use "${gsdData}/0-RawTemp/rl_livestock_manual_cleaning_nomads.dta", clear
replace rl_own_n = . if rl_own_n == -999999999
collapse (sum) total_animals_raised=rl_own_n (min) min_animals_raised=rl_own_n, by(interview__id)
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp10_nomads", nogenerate
order total_animals_raised min_animals_raised, last
*Flag if high number of livestock raised
g flag_high_nb_livestock = (total_animals_raised > 350) if total_animals_raised != .
*Flag if quantity of livestock raised is equal to 0 while the respondent said to raise this type of livestock
g flag_incorrect_nb_livestock = (min_animals_raised == 0) if min_animals_raised != .
drop min_animals_raised
save "${gsdTemp}/hh_monitoring_dashboard_temp11_nomads", replace

**Whether farming is a source of employment for the household
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning_nomads.dta", clear
replace emp_7d_farm = . if emp_7d_farm == -999999999 | emp_7d_farm == -1000000000
collapse (max) employed_farming = emp_7d_farm, by(interview__id)
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp11_nomads", nogenerate
order employed_farming, last
*Indicator 2: Proportion of households raising livestock
sum employed_farming if successful_valid==1
putexcel BF8=(r(mean)) using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master_Nomads.xlsm", sheet("Master dashboard") modify
save "${gsdTemp}/hh_monitoring_dashboard_temp12_nomads", replace

**Check for prices outliers
use "${gsdData}/0-RawTemp/rl_livestock_manual_cleaning_nomads.dta", clear
*Flag if the price is too high or too low compared to the median price of each type of livestock
g flag_livestock_price = 0
*USD
replace flag_livestock_price = 1 if rl_price_today_curr == 5 & rl_livestock__id == 1 & (rl_price_today >= 700 | rl_price_today <= 20) & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_price = 1 if rl_price_today_curr == 5 & rl_livestock__id == 2 & (rl_price_today >= 150 | rl_price_today <= 10) & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_price = 1 if rl_price_today_curr == 5 & rl_livestock__id == 3 & (rl_price_today >= 150 | rl_price_today <= 10) & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_price = 1 if rl_price_today_curr == 5 & rl_livestock__id == 4 & (rl_price_today >= 2000 | rl_price_today <= 200) & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_price = 1 if rl_price_today_curr == 5 & rl_livestock__id == 5 & (rl_price_today >= 10 | rl_price_today <= 0) & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_price = 1 if rl_price_today_curr == 5 & rl_livestock__id == 6 & (rl_price_today >= 500 | rl_price_today <= 50) & rl_price_today != . & rl_price_today != -999999999
*Somali shillings
replace flag_livestock_price = 1 if rl_price_today_curr == 2 & rl_livestock__id == 1 & (rl_price_today >= 10000 | rl_price_today <= 500) & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_price = 1 if rl_price_today_curr == 2 & rl_livestock__id == 2 & (rl_price_today >= 2000 | rl_price_today <= 100) & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_price = 1 if rl_price_today_curr == 2 & rl_livestock__id == 3 & (rl_price_today >= 2000 | rl_price_today <= 100) & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_price = 1 if rl_price_today_curr == 2 & rl_livestock__id == 4 & (rl_price_today >= 30000 | rl_price_today <= 3000) & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_price = 1 if rl_price_today_curr == 2 & rl_livestock__id == 5 & (rl_price_today >= 200 | rl_price_today <= 40) & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_price = 1 if rl_price_today_curr == 2 & rl_livestock__id == 6 & (rl_price_today >= 8000 | rl_price_today <= 500) & rl_price_today != . & rl_price_today != -999999999
*Flag if the price seems to be in Somali shillings instead of thousands of Somali shillings
g flag_livestock_unit = 0
replace flag_livestock_unit = 1 if rl_price_today_curr == 2 & rl_livestock__id == 1 & rl_price_today >= 1000000 & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_unit = 1 if rl_price_today_curr == 2 & rl_livestock__id == 2 & rl_price_today >= 10000 & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_unit = 1 if rl_price_today_curr == 2 & rl_livestock__id == 3 & rl_price_today >= 10000 & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_unit = 1 if rl_price_today_curr == 2 & rl_livestock__id == 4 & rl_price_today >= 1000000 & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_unit = 1 if rl_price_today_curr == 2 & rl_livestock__id == 5 & rl_price_today >= 1000 & rl_price_today != . & rl_price_today != -999999999
replace flag_livestock_unit = 1 if rl_price_today_curr == 2 & rl_livestock__id == 6 & rl_price_today >= 1000000 & rl_price_today != . & rl_price_today != -999999999
*Whether price or unit seems incorrect for at least one type of livestock
collapse (max) flag_livestock_price flag_livestock_unit, by(interview__id)
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp12_nomads", nogenerate
order flag_livestock_price flag_livestock_unit, last


/*----------------------------------------------------------------------------*/
/*      				    OTHER INDICATORS    				              */
/*----------------------------------------------------------------------------*/

**Non-response rate broken down in the various reasons (no one available to be interviewed, no adult, no consent)
g no_response = 1-consent
g nobody_home = 0 if no_response != .
replace nobody_home = 1 if athome == 0
g no_adult = 0 if no_response != .
replace no_adult = 1 if athome == 1 & adult == 0
g no_consent = 0 if no_response != .
replace no_consent = 1 if athome == 1 & adult == 1 & maycontinue == 0

**Number of household members for successful interviews
g nhhm_succ = nhhm if successful == 1

**Number of assets owned
foreach var of varlist ra_own* {
		gen own_`var' = (`var' == 1) if successful == 1
	}
egen nb_own_assets = rowtotal(own_*) if successful == 1
drop own_*
*Flag if no asset is owned
g flag_assets_empty = (nb_own_assets == 0) if successful == 1
label var flag_assets_empty "Whether no asset is said to be owned by the household"

**Number of shocks faced during the last 12 months
foreach var of varlist shocks0__* {
		gen faced_`var' = (`var' == 1) if successful == 1
	}
egen nb_shocks = rowtotal(faced_*) if successful == 1
drop faced_*
*Flag if no shock was faced
g flag_shocks_empty = (nb_shocks == 0) if successful == 1
label var flag_shocks_empty "Whether no shock is said to be faced by the household"

**Whether the household was displaced
g disp = (migr_disp == 1) if successful == 1
*Flag if the EA is an IDP camp but the household was said not to be displaced
g flag_idp = 0 if successful == 1
label var flag_idp "Whether the EA is an IDP camp but the household was said not to be displaced"

save "${gsdTemp}/hh_monitoring_dashboard_temp13_nomads", replace

**Number of people in employment/inside the labour force
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning_nomads.dta", clear
replace emp_7d_active = . if emp_7d_active == -999999999 | emp_7d_active == -1000000000
collapse (sum) emp_7d_active, by(interview__id)
merge 1:1 interview__id using "${gsdTemp}/hh_monitoring_dashboard_temp13_nomads", nogenerate

save "${gsdTemp}/hh_monitoring_dashboard_temp14_nomads", replace


/*----------------------------------------------------------------------------*/
/*                   MONITORING DASHBOARD: MAIN OUTPUT                        */
/*----------------------------------------------------------------------------*/

preserve

*Collapse by state/region/strata/team/ea/enumerator/date
collapse (sum) nb_itw=index itw_valid successful successful_valid val_succ1-val_succ4 beh_treat0 beh_treat1 gps_ok ///
	(mean) missing_prop_* ///
	(mean) nb_cons_food nb_cons_non_food ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ///
	(mean) ndkn_IDP_status ndkn_remittances_ext ndkn_labour ///
	(mean) nb_skip_patterns prop_skip_patterns soft_const_adult soft_const_edu ///
	(mean) no_response nobody_home no_adult no_consent ///
	(median) duration_med = duration_itw_min (mean) duration_mean = duration_itw_min ///
	(min) duration_min = duration_itw_min (max) duration_max = duration_itw_min ///
	(mean) nhhm_succ nb_own_assets nb_shocks ///
	(sum) fisheries disp ///
	(mean) emp_7d_active ///
	(mean) total_animals_raised nb_types_livestock mi_prop_quant_livestock mi_prop_quant_livestock_pre employed_farming livelihood_farming target_itw_wp , ///
	by(state ea_reg strata_id strata_name id_wp team_id enum_id enum_name date_stata)

*Proportion of interviews meeting validity criteria for GPS coordinates
g gps_prop = gps_ok/nb_itw
*Proportion of valid interviews (on total number of interviews)
g valid_prop = itw_valid/nb_itw
*Flag if too few valid interviews
g issue = 3
replace issue = 1 if valid_prop < 0.5
replace issue = 2 if valid_prop >= 0.5 & valid_prop < 0.8

*Final cleaning and labelling
label var state "State"
label var ea_reg "Region"
label var strata_id "Strata ID"
label var strata_name "Strata name"
label var id_wp "Waterpoint"
label var team_id "Team ID"
label var enum_id "Enumerator ID"
label var enum_name "Enumerator name"
label var date_stata "Day of data collection"
label var nb_itw "Total number of interviews"
label var itw_valid "Number of valid interviews"
label var successful "Number of successful interviews"
label var successful_valid "Number of valid and successful interviews"
label var val_succ1 "Number of valid and successful interviews with Treat=1"
label var val_succ2 "Number of valid and successful interviews with Treat=2"
label var val_succ3 "Number of valid and successful interviews with Treat=3"
label var val_succ4 "Number of valid and successful interviews with Treat=4"
label var beh_treat0 "Number of valid and successful interviews with behavioural treatment equal to 0"
label var beh_treat1 "Number of valid and successful interviews with behavioural treatment equal to 1"
label var gps_ok "Number of interviews meeting validity criteria for GPS coordinates"
label var gps_prop "Proportion of interviews meeting validity criteria for GPS coordinates"
label var valid_prop "Proportion of valid interviews"
label var no_response "Non-response rate"
label var nobody_home "Proportion of non-response due to the fact that there was no one available to be interviewed"
label var no_adult "Proportion of non-response due to the absence of a knowledgeable adult at home"
label var no_consent "Proportion of non-response due to the the fact that no consent was given"
label var missing_prop_main "Proportion of missing answers on successful interviews - Main dataset"
label var missing_prop_hh_roster_separated "Proportion of missing answers on successful interviews - Separated roster"
label var missing_prop_hhroster_age "Proportion of missing answers on successful interviews - Household roster"
label var missing_prop_motor "Proportion of missing answers on successful interviews - Motor roster"
label var missing_prop_ra_assets "Proportion of missing answers on successful interviews - Assets roster"
label var missing_prop_ra_assets_prev "Proportion of missing answers on successful interviews - Assets roster, before displacement"
label var missing_prop_rf_food "Proportion of missing answers on successful interviews - Main food roster"
label var missing_prop_rf_food_cereals "Proportion of missing answers on successful interviews - Cereals roster"
label var missing_prop_rf_food_fruit "Proportion of missing answers on successful interviews - Fruits roster"
label var missing_prop_rf_food_meat "Proportion of missing answers on successful interviews - Meat roster"
label var missing_prop_rf_food_vegetables "Proportion of missing answers on successful interviews - Vegetables roster"
label var missing_prop_rl_livestock "Proportion of missing answers on successful interviews - Livestock roster"
label var missing_prop_rl_livestock_pre "Proportion of missing answers on successful interviews - Livestock roster, before displacement"
label var missing_prop_rnf_nonfood "Proportion of missing answers on successful interviews - Non-food roster"
label var missing_prop_shocks "Proportion of missing answers on successful interviews - Shocks roster"
label var nb_cons_food "Average number of food items said to be consumed per household"
label var nb_cons_non_food "Average number of non-food items said to be consumed per household"
label var ndkn_food "Average proportion of food items with no or don't know for consumption answer"
label var ndkn_food_quant "Average proportion of missing, unknown or refused to answer quantities and prices for consumed or purchased items in the food consumption module"
label var ndkn_non_food "Average proportion of non-food items with no or don't know for consumption answer"
label var ndkn_non_food_quant "Average proportion of missing, unknown or refused to answer prices for consumed or purchased items in the non-food consumption module"
label var ndkn_IDP_status "Proportion of missing, unknown or refused to answer to the question on IDP status"
label var ndkn_remittances_ext "Proportion of missing, unknown or refused to answer to the question on receipt of remittances"
label var ndkn_labour "Average proportion of missing, unknown or refused to answer to the question on being in the labour force"
label var nb_skip_patterns "Average number of skip patterns on successful interviews"	
label var prop_skip_patterns "Average proportion of skip patterns on successful interviews"	
label var soft_const_adult "Average proportion of interviews not respecting the soft constraint: at least one household member above 16"
label var soft_const_edu "Average proportion of interviews not respecting the soft constraint: realistic number of years of education"
label var duration_med "Median duration of successful interviews - minutes"
label var duration_mean "Mean duration of successful interviews - minutes"
label var duration_min "Min duration of successful interviews - minutes"
label var duration_max "Max duration of successful interviews - minutes"
label var nhhm_succ "Average number of household members for successful interviews"
label var nb_own_assets "Average number of assets owned by the household"
label var nb_shocks "Average number of shocks"
label var emp_7d_active "Average number of people in employment/inside the labour force"
label var fisheries "Number of valid and successful inteviews for which the fisheries module was activated"
label var disp "Total number of displaced households"
label var total_animals_raised "Average number of animals raised"
label var nb_types_livestock "Average number of different types of livestock raised"
label var mi_prop_quant_livestock "Average proportion of missing quantities of livestock raised/owned currently"
label var mi_prop_quant_livestock_pre "Average proportion of missing quantities of livestock raised/owned, before displacement"
label var employed_farming "Average proportion of households for which farming is a source of employment"
label var livelihood_farming "Average proportion of households having farming as their main source of livelihood"
label var issue "Issue?"
label var target_itw_wp "Target number of valid and successful interviews per waterpoint"

order state ea_reg strata_id strata_name id_wp team_id enum_id enum_name date_stata nb_itw itw_valid successful successful_valid ///
	val_succ1-val_succ4 beh_treat0 beh_treat1 gps_ok gps_prop valid_prop no_response nobody_home no_adult no_consent missing_prop* ///
	nb_cons_food nb_cons_non_food ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ndkn_IDP_status ndkn_remittances_ext ndkn_labour ///
	nb_skip_patterns prop_skip_patterns soft_const_adult soft_const_edu ///
	duration_med duration_mean duration_min duration_max ///
	nhhm_succ nb_own_assets nb_shocks emp_7d_active fisheries disp ///
	total_animals_raised nb_types_livestock mi_prop_quant_livestock mi_prop_quant_livestock_pre employed_farming livelihood_farming issue target_itw_wp
	
sort team_id enum_id date_stata

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master_Nomads.xlsm", sheet("Main Output") cell(B5) sheetmodify
restore


/*----------------------------------------------------------------------------*/
/*                     MONITORING DASHBOARD: TEAM OUTPUT                      */
/*----------------------------------------------------------------------------*/

preserve

*Averge proportion of valid interviews - across all interviews, all dates
egen tot_valid = total(itw_valid)
egen tot_itw = total(index)
g avg_valid_prop = tot_valid/tot_itw
drop tot_valid tot_itw

*Collapse by team
collapse (sum) nb_itw=index itw_valid successful successful_valid gps_ok (first) avg_valid_prop ///
	(mean) no_response nobody_home no_adult no_consent ///
	(median) duration_med = duration_itw_min (mean) duration_mean = duration_itw_min ///
	(min) duration_min = duration_itw_min (max) duration_max = duration_itw_min, by(state team_id date_stata)

*Number of successful interviews - Cumulative by date
sort team_id date_stata
by team_id: gen successful_valid_cum = sum(successful_valid)
*Proportion of interviews meeting validity criteria for GPS coordinates (on total number of interviews)
g gps_prop = gps_ok/nb_itw
*Proportion of valid interviews (on total number of interviews)
g valid_prop = itw_valid/nb_itw
*Median duration - across all Teams
sum duration_med, d
global duration_med_all_team = `r(p50)'
g duration_med_all_team = $duration_med_all_team

*Final cleaning and labelling
label var state "State"
label var team_id "Team"
label var date_stata "Day of data collection"
label var nb_itw "Total number of interviews"
label var itw_valid "Number of valid interviews"
label var successful "Number of successful interviews"
label var successful_valid "Number of valid and successful interviews"
label var successful_valid_cum "Number of valid and successful interviews - Cumulative"
label var gps_ok "Nb of interviews meeting validity criteria for GPS coordinates"
label var gps_prop "Proportion of interviews meeting validity criteria for GPS coordinates"
label var valid_prop "Proportion of valid interviews"
label var no_response "Non-response rate"
label var nobody_home "Proportion of non-response due to the fact that there was no one available to be interviewed"
label var no_adult "Proportion of non-response due to the absence of a knowlegeable adult"
label var no_consent "Proportion of non-response due to the the fact that no consent was given"
label var duration_med "Median duration of interviews - minutes"
label var duration_mean "Mean duration of interviews - minutes"
label var duration_min "Min duration of interviews - minutes"
label var duration_max "Max duration of interviews - minutes"
label var avg_valid_prop "Average proportion of valid interviews across all teams and all data collection"
label var duration_med_all_team "Median duration of successful interviews - minutes - across all teams"

order state team_id date_stata nb_itw itw_valid successful successful_valid successful_valid_cum gps_ok gps_prop valid_prop ///
	no_response nobody_home no_adult no_consent duration_med duration_mean duration_min duration_max avg_valid_prop duration_med_all_team
	
sort team_id date_stata

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master_Nomads.xlsm", sheet("Output - Teams") cell(B7) sheetmodify
restore

/*----------------------------------------------------------------------------*/
/*                 MONITORING DASHBOARD: ENUMERATOR OUTPUT                    */
/*----------------------------------------------------------------------------*/

preserve

g nb_cons_food_low = (nb_cons_food <= 5)
g nb_cons_non_food_low = (nb_cons_non_food <= 2)
g nb_own_assets_low = (nb_own_assets <= 1)

*Collapse by enumerator and date
collapse (sum) nb_itw=index itw_valid successful successful_valid gps_ok ///
	(mean) missing_prop_* ///
	(mean) nb_cons_food nb_cons_non_food ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ///
	(mean) ndkn_IDP_status ndkn_remittances_ext ndkn_remittances_int ndkn_labour ///
	(mean) nb_skip_patterns prop_skip_patterns soft_const_adult soft_const_edu ///
	(mean) no_response nobody_home no_adult no_consent ///
	(median) duration_med = duration_itw_min (mean) duration_mean = duration_itw_min ///
	(min) duration_min = duration_itw_min (max) duration_max = duration_itw_min ///
	(mean) nhhm_succ nb_own_assets nb_shocks ///
	(sum) fisheries disp ///
	(mean) emp_7d_active ///
	(max) flag_food_empty flag_non_food_empty flag_assets_empty flag_ndkn_edu flag_ndkn_house flag_ndkn_labour flag_remit flag_idp flag_no_livestock flag_high_nb_livestock flag_incorrect_nb_livestock drought flag_livestock_price flag_livestock_unit ///
	(min) flag_shocks_empty ///
	(sum) nb_cons_food_low nb_cons_non_food_low nb_own_assets_low ///
	(mean) total_animals_raised nb_types_livestock mi_prop_quant_livestock mi_prop_quant_livestock_pre employed_farming livelihood_farming, ///
	by(state team_id enum_id enum_name date_stata)

*Number of valid and successful interviews - Cumulative by date
sort enum_id date_stata
by enum_id : gen successful_valid_cum = sum(successful_valid)
*Proportion of interviews meeting validity criteria for GPS coordinates (on all interviews)
g gps_prop = gps_ok/nb_itw
*Proportion of valid interviews (on all interviews)
g valid_prop = itw_valid/nb_itw
*Decile of number of skip patterns
sum prop_skip_patterns, d
global threshold_skip_patterns = `r(p90)'
*Median duration - across all Enumerators
sum duration_med, d
global duration_med_all = `r(p50)'
g duration_med_all = $duration_med_all
*Average proportion of 'no'/'don't know' in the food and non-food consumption module - across all Enumerators"	
sum ndkn_food, d
global ndkn_food_ave = `r(mean)'
sum ndkn_non_food
global ndkn_non_food_ave = `r(mean)'
g ndkn_food_non_food_ave = ($ndkn_food_ave + $ndkn_non_food_ave)/2
*Average number of household memebrs - across all Enumerators
sum nhhm_succ, d
global nhhm_succ_ave = `r(mean)'
g nhhm_succ_ave = $nhhm_succ_ave
*Set number fo fishermen and displaced households equal to zero when no interview was successful
replace fisheries = . if successful == 0
replace disp = . if successful == 0

/*List of flags
1	- Shorter duration of interviews than other enumerators
2	- Lower number of household members on average than other enumerators/and what is expected in the state
3.1	- Higher proportion of missing answers than other enumerators in the main dataset
3.2	- Higher proportion of missing answers than other enumerators in the separated roster
3.3	- Higher proportion of missing answers than other enumerators in the household roster
3.4	- Higher proportion of missing answers than other enumerators in the motor roster
3.5	- Higher proportion of missing answers than other enumerators in the assets roster
3.6	- Higher proportion of missing answers than other enumerators in the assets roster before displacement
3.7	- Higher proportion of missing answers than other enumerators in the main food roster
3.8	- Higher proportion of missing answers than other enumerators in the cereals roster
3.9	- Higher proportion of missing answers than other enumerators in the fruits roster
3.10 - Higher proportion of missing answers than other enumerators in the meat roster
3.11 - Higher proportion of missing answers than other enumerators in the vegetables roster
3.12 - Higher proportion of missing answers than other enumerators in the livestock roster
3.13 - Higher proportion of missing answers than other enumerators in the livestock roster before displacement
3.14 - Higher proportion of missing answers than other enumerators in the non-food roster
3.15 - Higher proportion of missing answers than other enumerators in the shocks roster
4	- Higher proportion of items said not to be consumed than other enumerators
5	- Too high proportion of missing quantities and prices for food and non-food items consumed
6	- Higher number of key questions skipped
7	- Answers on questions on remittances missing
8	- Answers on questions on IDP status missing
9	- Answers on key questions on employment missing
10	- Answers on key questions on education missing
11	- Answers on housing conditions missing
12	- Number of years of education not realistic
13  - No food item said to be consumed for at least one interview
14  - No non-food item said to be consumed for at least one interview
15  - No asset said to be owned for at least one interview
16  - Low number of food items said to be consumed on average
17  - Low number of non-food items said to be consumed on average
18  - Low number of assets said to be owned on average
19  - No shocks faced for all interviews
20  - Household was said not to be displaced whereas the EA is an IDP camp
21  - Number of years of education not realistic
22  - No livestock raised
23  - High number of livestock raised
24  - Quantity of livestock raised equal to 0 while the respondent said to raise this type of livestock
25  - High proportion of missing quantities of livestock raised currently
26  - High proportion of missing quantities of livestock raised before displacement
27  - Nomadic household but no farming or livestock raising as employment
28  - No drought for any of the interviews
29  - Livestock price too high or too low 
30  - Incorrect unit for livestock price
*/

g flag_duration = (duration_med < 80 & missing(duration_med) == 0)
g flag_hhm = (nhhm_succ <= 3.5)
g flag_missing_main = (missing_prop_main > 0.05 & missing(missing_prop_main) == 0)
g flag_roster_separated = (missing_prop_hh_roster_separated > 0.3 & missing(missing_prop_hh_roster_separated) == 0)
g flag_roster_hh = (missing_prop_hhroster_age > 0.1 & missing(missing_prop_hhroster_age) == 0)
g flag_roster_motor = (missing_prop_motor > 0.3 & missing(missing_prop_motor) == 0)
g flag_roster_assets = (missing_prop_ra_assets > 0.1 & missing(missing_prop_ra_assets) == 0)
g flag_roster_assets_prev = (missing_prop_ra_assets_prev > 0.3 & missing(missing_prop_ra_assets_prev) == 0)
g flag_roster_food = (missing_prop_rf_food > 0.05 & missing(missing_prop_rf_food) == 0)
g flag_roster_cereals = (missing_prop_rf_food_cereals > 0.1 & missing(missing_prop_rf_food_cereals) == 0)
g flag_roster_fruits = (missing_prop_rf_food_fruit > 0.1 & missing(missing_prop_rf_food_fruit) == 0)
g flag_roster_meat = (missing_prop_rf_food_meat > 0.1 & missing(missing_prop_rf_food_meat) == 0)
g flag_roster_vegetables = (missing_prop_rf_food_vegetables > 0.1 & missing(missing_prop_rf_food_vegetables) == 0)
g flag_roster_livestock = (missing_prop_rl_livestock > 0.05 & missing(missing_prop_rl_livestock) == 0)
g flag_roster_livestock_pre = (missing_prop_rl_livestock_pre > 0.1 & missing(missing_prop_rl_livestock_pre) == 0)
g flag_roster_non_food = (missing_prop_rnf_nonfood > 0.05 & missing(missing_prop_rnf_nonfood) == 0)
g flag_roster_shocks = (missing_prop_shocks > 0.1 & missing(missing_prop_shocks) == 0)
g flag_ndkn_food_non_food = ((ndkn_food + ndkn_non_food)/2 > 0.47 & (ndkn_food != . | ndkn_non_food != .))
g flag_prices_quant_food_non_food = ((ndkn_food_quant != . & ndkn_non_food_quant != . & (ndkn_food_quant + ndkn_non_food_quant)/2 > 0.3) | ///
	(ndkn_food_quant != . & ndkn_non_food_quant == . & ndkn_food_quant > 0.3) | ///
	(ndkn_food_quant == . & ndkn_non_food_quant != . & ndkn_non_food_quant > 0.3))
g flag_skip = (prop_skip_patterns > $threshold_skip_patterns & prop_skip_patterns != .)
*flag_remit
g flag_missing_idp = (ndkn_IDP_status > 0 & missing(ndkn_IDP_status) == 0)
*flag_ndkn_labour
*flag_ndkn_edu
*flag_ndkn_house
*flag_food_empty
*flag_non_food_empty
*flag_assets_empty
g flag_nb_cons_food_low = (nb_cons_food_low >= 1)
g flag_nb_cons_non_food_low = (nb_cons_non_food_low >= 1)
g flag_nb_own_assets_low = (nb_own_assets_low >= 2)
*flag_shocks_empty
replace flag_idp = 0 if missing(flag_idp) == 1 & successful > 0
g flag_edu_not_realistic = (soft_const_edu > 0 & missing(soft_const_edu) == 0)
*flag_no_livestock
*flag_high_nb_livestock
*flag_incorrect_nb_livestock
g flag_mi_quant_livestock = (mi_prop_quant_livestock > 0.05 & missing(mi_prop_quant_livestock) == 0)
g flag_mi_quant_livestock_pre = (mi_prop_quant_livestock_pre > 0.05 & missing(mi_prop_quant_livestock_pre) == 0)
g flag_no_farming = (employed_farming < 1) if missing(employed_farming) == 0
g flag_no_drought = (drought == 0) if missing(drought) == 0
*flag_livestock_price
*flag_livestock_unit

g flag = ""
replace flag = flag + "/" + "Shorter duration of interviews than other enumerators" if flag_duration == 1
replace flag = flag + "/" + "Lower number of household members on average than other enumerators and what is expected in the state" if flag_hhm == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in main dataset" if flag_missing_main == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in separated roster" if flag_roster_separated == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in household roster" if flag_roster_hh == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in motor roster" if flag_roster_motor == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in durable goods roster" if flag_roster_assets == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in durable goods roster before displacement" if flag_roster_assets_prev == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in main food roster" if flag_roster_food == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in cereals roster" if flag_roster_cereals == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in fruits roster" if flag_roster_fruits == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in meat roster" if flag_roster_meat == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in vegetables roster" if flag_roster_vegetables == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in livestock roster" if flag_roster_livestock == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in livestock roster before displacement" if flag_roster_livestock_pre == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in non-food roster" if flag_roster_non_food == 1
replace flag = flag + "/" + "Higher proportion of missing answers than other enumerators in shocks roster" if flag_roster_shocks == 1
replace flag = flag + "/" + "Higher proportion of items said not to be consumed than other enumerators" if flag_ndkn_food_non_food == 1
replace flag = flag + "/" + "Too high proportion of missing quantities and prices for items consumed" if flag_prices_quant_food_non_food == 1
replace flag = flag + "/" + "Higher number of key questions skipped" if flag_skip == 1
replace flag = flag + "/" + "Answers on questions on remittances missing" if flag_remit == 1
replace flag = flag + "/" + "Answers on questions on IDP status missing" if flag_missing_idp == 1
replace flag = flag + "/" + "Answers on key questions on employment missing" if flag_ndkn_labour == 1
replace flag = flag + "/" + "Answers on key questions on education missing" if flag_ndkn_edu == 1
replace flag = flag + "/" + "Answers on housing conditions missing" if flag_ndkn_house == 1
replace flag = flag + "/" + "No food item said to be consumed" if flag_food_empty == 1
replace flag = flag + "/" + "No non-food item said to be consumed" if flag_non_food_empty == 1
replace flag = flag + "/" + "No durable good said to be owned" if flag_assets_empty == 1
replace flag = flag + "/" + "Low number of food items said to be consumed" if flag_nb_cons_food_low == 1
replace flag = flag + "/" + "Low number of non-food items said to be consumed" if flag_nb_cons_non_food_low == 1
replace flag = flag + "/" + "Low number of durable goods said to be owned" if flag_nb_own_assets_low == 1
replace flag = flag + "/" + "No shocks for any of the interviews" if flag_shocks_empty == 1
replace flag = flag + "/" + "Household was said not to be displaced whereas the EA is an IDP camp" if flag_idp == 1
replace flag = flag + "/" + "Number of years of education not realistic" if flag_edu_not_realistic == 1
replace flag = flag + "/" + "No livestock raised" if flag_no_livestock == 1
replace flag = flag + "/" + "High number of livestock raised" if flag_high_nb_livestock == 1
replace flag = flag + "/" + "Quantity of livestock raised equal to 0 while the respondent said to raise this type of livestock" if flag_incorrect_nb_livestock == 1
replace flag = flag + "/" + "High proportion of missing quantities of livestock raised currently" if flag_mi_quant_livestock == 1
replace flag = flag + "/" + "High proportion of missing quantities of livestock raised before displacement" if flag_mi_quant_livestock_pre == 1
replace flag = flag + "/" + "Nomadic household but no farming or livestock raising as employment" if flag_no_farming == 1
replace flag = flag + "/" + "No drought for any of the interviews" if flag_no_drought == 1
replace flag = flag + "/" + "Livestock price too high or too low" if flag_livestock_price == 1
replace flag = flag + "/" + "Incorrect unit for livestock price" if flag_livestock_unit == 1
replace flag = substr(flag,2,.)

*Final cleaning and labelling
label var state "State"
label var team_id "Team"
label var enum_id "Enumerator ID"
label var enum_name "Enumerator name"
label var date_stata "Day of data collection"
label var nb_itw "Total number of interviews"
label var itw_valid "Number of valid interviews"
label var successful "Number of successful interviews"
label var successful_valid "Number of valid and successful interviews"
label var successful_valid_cum "Number of valid and successful interviews - Cumulative"
label var gps_ok "Number of interviews meeting validity criteria for GPS coordinates"
label var gps_prop "Proportion of interviews meeting validity criteria for GPS coordinates"
label var valid_prop "Proportion of valid interviews"
label var no_response "Non-response rate"
label var nobody_home "Proportion of non-response due to the fact that there was no one available to be interviewed"
label var no_adult "Proportion of non-response due to the absence of a knowlegeable adult"
label var no_consent "Proportion of non-response due to the the fact that no consent was given"
label var missing_prop_main "Proportion of missing answers on successful interviews - Main dataset"
label var missing_prop_hh_roster_separated "Proportion of missing answers on successful interviews - Separated roster"
label var missing_prop_hhroster_age "Proportion of missing answers on successful interviews - Household roster"
label var missing_prop_motor "Proportion of missing answers on successful interviews - Motor roster"
label var missing_prop_ra_assets "Proportion of missing answers on successful interviews - Assets roster"
label var missing_prop_ra_assets_prev "Proportion of missing answers on successful interviews - Assets roster, before displacement"
label var missing_prop_rf_food "Proportion of missing answers on successful interviews - Main food roster"
label var missing_prop_rf_food_cereals "Proportion of missing answers on successful interviews - Cereals roster"
label var missing_prop_rf_food_fruit "Proportion of missing answers on successful interviews - Fruits roster"
label var missing_prop_rf_food_meat "Proportion of missing answers on successful interviews - Meat roster"
label var missing_prop_rf_food_vegetables "Proportion of missing answers on successful interviews - Vegetables roster"
label var missing_prop_rl_livestock "Proportion of missing answers on successful interviews - Livestock roster"
label var missing_prop_rl_livestock_pre "Proportion of missing answers on successful interviews - Livestock roster, before displacement"
label var missing_prop_rnf_nonfood "Proportion of missing answers on successful interviews - Non-food roster"
label var missing_prop_shocks "Proportion of missing answers on successful interviews - Shocks roster"
label var nb_cons_food "Average number of food items said to be consumed per household"
label var nb_cons_non_food "Average number of non-food items said to be consumed per household"
label var ndkn_food "Average proportion of food items with no or don't know for consumption answer"
label var ndkn_food_quant "Average proportion of missing, unknown or refused to answer quantities and prices for consumed or purchased items in the food consumption module"
label var ndkn_non_food "Average proportion of non-food items with no or don't know for consumption answer"
label var ndkn_non_food_quant "Average proportion of missing, unknown or refused to answer prices for consumed or purchased items in the non-food consumption module"
label var ndkn_IDP_status "Proportion of missing, unknown or refused to answer to the question on IDP status"
label var ndkn_remittances_ext "Proportion of missing, unknown or refused to answer to the question on receipt of remittances"
label var ndkn_labour "Average proportion of missing, unknown or refused to answer to the question on being in the labour force"
label var nb_skip_patterns "Average number of skip patterns on successful interviews"	
label var prop_skip_patterns "Average proportion of skip patterns on successful interviews"	
label var soft_const_adult "Average proportion of interviews not respecting the soft constraint: at least one household member above 16"
label var soft_const_edu "Average proportion of interviews not respecting the soft constraint: realistic number of years of education"
label var duration_med "Median duration of interviews - minutes"
label var duration_mean "Mean duration of interviews - minutes"
label var duration_min "Min duration of interviews - minutes"
label var duration_max "Max duration of interviews - minutes"
label var nhhm_succ "Average number of household members for successful interviews"
label var nb_own_assets "Average number of assets owned by the household"
label var nb_shocks "Average number of shocks"
label var emp_7d_active "Average number of people in employment/inside the labour force"
label var fisheries "Number of valid and successful inteviews for which the fisheries module was activated"
label var disp "Total number of displaced households"
label var total_animals_raised "Average number of animals raised"
label var nb_types_livestock "Average number of different types of livestock raised"
label var mi_prop_quant_livestock "Average proportion of missing quantities of livestock raised/owned currently"
label var mi_prop_quant_livestock_pre "Average proportion of missing quantities of livestock raised/owned, before displacement"
label var employed_farming "Average proportion of households for which farming is a source of employment"
label var livelihood_farming "Average proportion of households having farming as their main source of livelihood"
label var flag "Flag data quality control"
label var duration_med_all "Median duration of successful interviews - across all Enumerators"
label var ndkn_food_non_food_ave "Average proportion of 'no'/'don't know' in the food and non-food consumption module - across all Enumerators"	
label var nhhm_succ_ave "Average number of household members - across all Enumerators"

save "${gsdTemp}/hh_monitoring_dashboard_temp15_nomads", replace

keep state team_id enum_id enum_name date_stata ///
	nb_itw itw_valid successful successful_valid successful_valid_cum ///
	gps_ok gps_prop valid_prop no_response nobody_home no_adult no_consent ///
	missing_prop* nb_cons_food nb_cons_non_food ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ///
	ndkn_IDP_status ndkn_remittances_ext ndkn_labour ///
	nb_skip_patterns prop_skip_patterns soft_const_adult soft_const_edu ///
	duration_med duration_mean duration_min duration_max nhhm_succ nb_own_assets nb_shocks emp_7d_active fisheries disp ///
	total_animals_raised nb_types_livestock mi_prop_quant_livestock mi_prop_quant_livestock_pre employed_farming livelihood_farming flag ///
	duration_med_all ndkn_food_non_food_ave nhhm_succ_ave

order state team_id enum_id enum_name date_stata ///
	nb_itw itw_valid successful successful_valid successful_valid_cum ///
	gps_ok gps_prop valid_prop no_response nobody_home no_adult no_consent ///
	missing_prop* nb_cons_food nb_cons_non_food ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ///
	ndkn_IDP_status ndkn_remittances_ext ndkn_labour ///
	nb_skip_patterns prop_skip_patterns soft_const_adult soft_const_edu ///
	duration_med duration_mean duration_min duration_max nhhm_succ nb_own_assets nb_shocks emp_7d_active fisheries disp ///
	total_animals_raised nb_types_livestock mi_prop_quant_livestock mi_prop_quant_livestock_pre employed_farming livelihood_farming flag ///
	duration_med_all ndkn_food_non_food_ave nhhm_succ_ave
	
sort team_id enum_id date_stata

*Export	
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master_Nomads.xlsm", sheet("Output - Enumerators") cell(B7) sheetmodify

restore

/*----------------------------------------------------------------------------*/
/*               MONITORING DASHBOARD: DATE OUTPUT                            */
/*----------------------------------------------------------------------------*/

preserve

*** Number of waterpoints originally sampled or active replacements used per date
*Originally sampled or active replacements
bysort date_stata id_wp: g nb_wps_sampled = 1 if _n == 1 & sample_final_wp == 1
*Neither originally sampled nor active replacements
bysort date_stata id_wp: g nb_wps_not_sampled = 1 if _n == 1 & sample_final_wp == 0

*Collapse by date
collapse (sum) nb_wps_sampled nb_wps_not_sampled ///
	nb_itw=index itw_valid successful successful_valid val_succ1-val_succ4 gps_ok ///
	(median) duration_med = duration_itw_min (mean) duration_mean = duration_itw_min ///
	(min) duration_min = duration_itw_min (max) duration_max = duration_itw_min, by(date_stata)

*Cumulative number of interviews by date
sort date_stata
g successful_valid_cum = sum(successful_valid)
*Target number of interviews, total Urban/Rural/IDPs + host communities
g target = 504
*Proportion of interviews meeting validity criteria for GPS coordinates
g gps_prop = gps_ok/nb_itw
*Proportion of valid interviews
g valid_prop = itw_valid/nb_itw

*Final cleaning and labelling
label var date_stata "Day of data collection"
label var nb_wps_sampled "Number of WPs originally sampled or active replacements and used"
label var nb_wps_not_sampled "Number of WPs neither sampled nor active replacements but used"
label var nb_itw "Total number of interviews"
label var itw_valid "Number of valid interviews"
label var successful "Number of successful interviews"
label var successful_valid "Number of valid and successful interviews"
label var successful_valid_cum "Number of valid and successful interviews - Cumulative"
label var target "Target number of valid and successful interviews"
label var val_succ1 "Number of valid and successful interviews with Treat=1"
label var val_succ2 "Number of valid and successful interviews with Treat=2"
label var val_succ3 "Number of valid and successful interviews with Treat=3"
label var val_succ4 "Number of valid and successful interviews with Treat=4"
label var gps_ok "Number of interviews meeting validity criteria for GPS coordinates"
label var gps_prop "Proportion of interviews meeting validity criteria for GPS coordinates"
label var valid_prop "Proportion of valid interviews"
label var duration_med "Median duration of successful interviews - minutes"
label var duration_mean "Mean duration of successful interviews - minutes"
label var duration_min "Minimum duration of successful interviews - minutes"
label var duration_max "Maximum duration of successful interviews - minutes"

order date_stata nb_wps_sampled nb_wps_not_sampled ///
	nb_itw itw_valid successful successful_valid successful_valid_cum target ///
	val_succ1-val_succ4 gps_ok gps_prop valid_prop ///
	duration_med duration_mean duration_min duration_max

sort date_stata

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master_Nomads.xlsm", sheet("Output - Date") cell(B6) sheetmodify
restore


/*----------------------------------------------------------------------------*/
/*                MONITORING DASHBOARD: WATERPOINT OUTPUT                     */
/*----------------------------------------------------------------------------*/

preserve

*List of valid and successful interviews per waterpoint
gsort id_wp -int_no
tostring int_no, g(int_no_str)
g list_val_succ = ","+int_no_str if successful_valid == 1
replace list_val_succ = list_val_succ + list_val_succ[_n-1] if id_wp == id_wp[_n-1]
replace list_val_succ = substr(list_val_succ,2,.)
bysort id_wp: g list_val_succ_wp = list_val_succ[_N] 

*Collapse by region/strata/waterpoint
collapse (sum) nb_itw=index itw_valid successful successful_valid val_succ1 val_succ2 val_succ3 val_succ4 ///
		(mean) target_itw_wp (first) list_val_succ_wp wp_status wp_valid, by(ea_reg strata_id strata_name id_wp type_pop final_main_wp)

*Target number of interviews at the waterpoint
*g target_itw_wp = 12*final_main_wp

*Final cleaning and labelling
label values wp_status wp_status_label
label var ea_reg "Region"
label var strata_id "Strata ID"
label var strata_name "Strata name"
label var type_pop "Type of population"
label var id_wp "Waterpoint"
label var nb_itw "Total number of interviews per WP"
label var itw_valid "Number of valid interviews per WP"
label var successful "Number of successful interviews per WP"
label var successful_valid "Number of valid and successful interviews per WP"
label var target_itw_wp "Target valid and successful interviews"	
label var val_succ1 "Number of valid and successful interviews of Treat=1 per WP"
label var val_succ2 "Number of valid and successful interviews of Treat=2 per WP"	
label var val_succ3 "Number of valid and successful interviews of Treat=3 per WP"	
label var val_succ4 "Number of valid and successful interviews of Treat=4 per WP"
label var wp_status "Status of the WP"
label var wp_valid "Whether WP is valid"
label var list_val_succ_wp "List of valid and successful interviews in the WP"

keep ea_reg strata_id strata_name id_wp type_pop nb_itw itw_valid successful successful_valid ///
 target_itw_wp val_succ1-val_succ4 wp_status wp_valid list_val_succ_wp
 
order ea_reg strata_id strata_name id_wp type_pop nb_itw itw_valid successful successful_valid ///
 target_itw_wp val_succ1-val_succ4 wp_status wp_valid list_val_succ_wp
 
sort strata_id id_wp

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master_Nomads.xlsm", sheet("Output - Waterpoint") cell(B6) sheetmodify
restore


/*----------------------------------------------------------------------------*/
/*                 MONITORING DASHBOARD: STRATA OUTPUT                        */
/*----------------------------------------------------------------------------*/

*** Target number of interviews per strata
preserve
import excel "${gsdDataRaw}/Inputs Waterpoints.xls", sheet("Summary")clear
rename (A B) (strata_name target_itw_strata_wp)
drop if _n <= 4
destring target_itw_strata_wp, replace
save "${gsdTemp}/strata_target_itw_nomads.dta", replace
restore

preserve

*** Number of waterpoints originally sampled or active replacements used per strata
*Originally sampled or active replacements
bysort date_stata id_wp: g nb_wps_sampled = 1 if _n == 1 & sample_final_wp == 1
*Neither originally sampled nor active replacements
bysort date_stata id_wp: g nb_wps_not_sampled = 1 if _n == 1 & sample_final_wp == 0

*Collapse by strata
collapse (sum) nb_wps_sampled nb_wps_not_sampled ///
	nb_itw=index itw_valid successful successful_valid val_succ1-val_succ4 ///
	(mean) no_response nobody_home no_adult no_consent, by(strata_id strata_name)
	
*Target number of interviews per strata	
merge 1:1 strata_name using  "${gsdTemp}/strata_target_itw_nomads.dta", keep(match master) nogenerate
*Percentage of target reached in termes of number of valid and successful interviews
g perc_target = successful_valid/target_itw_strata_wp
*Proportion of valid interviews (on all interviews)
g valid_prop = itw_valid/nb_itw

*Final cleaning and labelling
label var strata_id "Strata ID"
label var strata_name "Strata name"
label var nb_wps_sampled "Number of WPs originally sampled or active replacements and used"
label var nb_wps_not_sampled "Number of WPs neither sampled nor active replacements but used"
label var nb_itw "Total number of interviews"
label var itw_valid "Number of valid interviews"
label var successful "Number of successful interviews"
label var successful_valid "Number of valid and successful interviews"
label var target_itw_strata "Target number of valid and successful interviews"
label var perc_target "Percentage of target reached"
label var val_succ1 "Number of valid and successful interviews with Treat=1"
label var val_succ2 "Number of valid and successful interviews with Treat=2"
label var val_succ3 "Number of valid and successful interviews with Treat=3"
label var val_succ4 "Number of valid and successful interviews with Treat=4"
label var valid_prop "Proportion of valid interviews"
label var no_response "Non-response rate"
label var nobody_home "Proportion of non-response due to the fact that there was no one available to be interviewed"
label var no_adult "Proportion of non-response due to the absence of a knowlegeable adult"
label var no_consent "Proportion of non-response due to the the fact that no consent was given"

order strata_id strata_name nb_wps_sampled nb_wps_not_sampled ///
	nb_itw itw_valid successful successful_valid successful_valid target_itw_strata_wp perc_target ///
	val_succ1-val_succ4 valid_prop no_response nobody_home no_adult no_consent

sort strata_id

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master_Nomads.xlsm", sheet("Output - Strata") cell(B6) sheetmodify
restore

/*----------------------------------------------------------------------------*/
/*            MONITORING DASHBOARD: INVALID INTERVIEW OUTPUT                  */
/*----------------------------------------------------------------------------*/

preserve

*Keep only invalid interviews
keep if itw_valid == 0
*Keep only relevant variables
keep state strata_id strata_name team_id enum_id enum_name id_wp int_no date_stata itw_invalid_reason successful interview__id

*Generate dummy variables for each invalidity reason
g short_duration = (itw_invalid_reason==1)
g no_gps = (itw_invalid_reason==2)
g not_within_WP = (itw_invalid_reason==3)
g no_original_itw = (itw_invalid_reason==4)
g invalid_original_itw = (itw_invalid_reason==5)
g no_livestock = (itw_invalid_reason==6)

*Final cleaning and labelling
label var date_stata "Day of data collection"
label var state "State"
label var strata_id "Strata ID"
label var strata_name "Strata name"
label var team_id "Team"
label var enum_id "Enumerator ID"
label var enum_name "Enumerator name"
label var id_wp "Waterpoint"
label var int_no "Interview number"
label var itw_invalid_reason "Reason for invalid interview"
label var short_duration "Duration does not exceed threshold"
label var no_gps "No GPS coordinates" 
label var not_within_WP "GPS coordinates do not fall within a radius of 50m around the waterpoint" 
label var no_original_itw "No record for the original household while it is a replacement household"
label var invalid_original_itw "Record for the original household is not valid while it is a replacement household"
label var no_livestock "No livestock"
label var successful "Whether the interview is successful"
label var interview__id "Key"

order date_stata state strata_id strata_name team_id enum_id enum_name id_wp int_no itw_invalid_reason ///
	short_duration no_gps not_within_WP no_original_itw invalid_original_itw no_livestock successful interview__id 

gsort -date_stata team_id enum_id int_no itw_invalid_reason

*Export
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master_Nomads.xlsm", sheet("Output - Invalid interviews") cell(B9) sheetmodify
restore

/*----------------------------------------------------------------------------*/
/*               MONITORING DASHBOARD: OUTPUT FLAGS                           */
/*----------------------------------------------------------------------------*/

preserve

use "${gsdTemp}/hh_monitoring_dashboard_temp15_nomads", clear

keep state team_id enum_id enum_name date_stata flag_*
order state team_id enum_id enum_name date_stata flag_duration flag_hhm ///
	flag_missing_main flag_roster_separated flag_roster_hh flag_roster_motor flag_roster_assets flag_roster_assets_prev flag_roster_food flag_roster_cereals flag_roster_fruits  flag_roster_meat flag_roster_vegetables flag_roster_livestock flag_roster_livestock_pre flag_roster_non_food flag_roster_shocks ///
	flag_ndkn_food_non_food flag_prices_quant_food_non_food flag_skip flag_remit flag_missing_idp flag_ndkn_labour flag_ndkn_edu flag_ndkn_house ///
	flag_food_empty flag_non_food_empty flag_assets_empty flag_nb_cons_food_low flag_nb_cons_non_food_low flag_nb_own_assets_low flag_shocks_empty flag_idp flag_edu_not_realistic ///
	flag_no_livestock flag_high_nb_livestock flag_incorrect_nb_livestock flag_mi_quant_livestock flag_mi_quant_livestock_pre flag_no_farming flag_no_drought flag_livestock_price flag_livestock_unit

*Export	
export excel using "${gsdShared}/2-Output/SHFS2_Monitoring_Dashboard_Master_Nomads.xlsm", sheet("Output - Flags") cell(B6) sheetmodify

restore
