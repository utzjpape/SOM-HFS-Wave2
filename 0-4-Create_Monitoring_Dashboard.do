*-------------------------------------------------------------------
*
*     MONITORING DASHBOARD
*     
*     This do-file updates the monitoring dashboard
*     Daily analysis to check progress and performance of teams
*     and enumerators
*       
*-------------------------------------------------------------------

/*----------------------------------------------------------------------------*/
/*                        IMPORT QUESTIONNAIRE                                */
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

**Region
decode ea_reg, g(ea_reg_str)
drop ea_reg
rename ea_reg_str ea_reg

**Enumerator name and ID
decode enum_id, g(enum_name)
label drop enum_id

*Interviews meeting validity criteria for GPS coordinates
g gps_ok = (gps_coord_y_n == 1 & not_within_EA == 0)

**Behavioural treatment for valid and successful interviews
g beh_treat0= (beh_treat_opt==0) if successful_valid==1
g beh_treat1= (beh_treat_opt==1) if successful_valid==1

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

**Proportion of no/unanswered for consumption of items in the food and non-food consumption modules in the main dataset
*Create dummy variable = 1 if the item was not consumed by the household, for all food and non-food items
foreach var of varlist rf_relevanceyn* rnf_relevanceyn* {
		gen dummy_`var' = (`var' == 0 | `var' == -999999999) if successful == 1
	}
egen ndkn_food = rowmean(dummy_rf_relevanceyn*) if successful == 1
label var ndkn_food "Proportion of food items with no or don't know for consumption answer"
egen ndkn_non_food = rowmean(dummy_rnf_relevanceyn*) if successful == 1
label var ndkn_non_food "Proportion of non-food items with no or don't know for consumption answer"
*Final cleaning
drop dummy*
rename Id ParentId1
save "${gsdTemp}/hh_monitoring_dashboard_temp1", replace

**Proportion of missing/don't know/refused to answer for quantities and prices relating to food items consumed

* 1. Appending all food rosters
*Cereals
use "${gsdData}/0-RawTemp/rf_food_cereals_manual_cleaning.dta", clear
*Keep variables "quantity consumed", "quantity purchased", "price paid for quantity purchased"
keep ParentId1 Id rf_cons_quant1 rf_purc_quant1 rf_pric_total1
rename (rf_cons_quant1 rf_purc_quant1 rf_pric_total1) (rf_cons_quant rf_purc_quant rf_pric_total)
*Append with food roster
append using "${gsdData}/0-RawTemp/rf_food_manual_cleaning.dta"
keep ParentId1 Id rf_cons_quant rf_purc_quant rf_pric_total
save "${gsdTemp}/rf_food_all.dta", replace

*Meat
use "${gsdData}/0-RawTemp/rf_food_meat_manual_cleaning.dta", clear
*Keep variables "quantity consumed", "quantity purchased", "price paid for quantity purchased"
keep ParentId1 Id rf_cons_quant2 rf_purc_quant2 rf_pric_total2
rename (rf_cons_quant2 rf_purc_quant2 rf_pric_total2) (rf_cons_quant rf_purc_quant rf_pric_total)
*Append with food roster
append using "${gsdTemp}/rf_food_all.dta"
save "${gsdTemp}/rf_food_all.dta", replace

*Fruits
use "${gsdData}/0-RawTemp/rf_food_fruit_manual_cleaning.dta", clear
*Keep variables "quantity consumed", "quantity purchased", "price paid for quantity purchased"
keep ParentId1 Id rf_cons_quant3 rf_purc_quant3 rf_pric_total3
rename (rf_cons_quant3 rf_purc_quant3 rf_pric_total3) (rf_cons_quant rf_purc_quant rf_pric_total)
*Append with food roster
append using "${gsdTemp}/rf_food_all.dta"
save "${gsdTemp}/rf_food_all.dta", replace

*Vegetables
use "${gsdData}/0-RawTemp/rf_food_vegetables_manual_cleaning.dta", clear
*Keep variables "quantity consumed", "quantity purchased", "price paid for quantity purchased"
keep ParentId1 Id rf_cons_quant4 rf_purc_quant4 rf_pric_total4
rename (rf_cons_quant4 rf_purc_quant4 rf_pric_total4) (rf_cons_quant rf_purc_quant rf_pric_total)
*Append with food roster
append using "${gsdTemp}/rf_food_all.dta"
sort ParentId1 Id
save "${gsdTemp}/rf_food_all.dta", replace

* 2. Creating dummy variables: whether the quantities and prices for food items are missing/unknown/refused to answer
g dummy_rf_cons_quant = (rf_cons_quant == . | rf_cons_quant == -999999999)
g dummy_rf_purc_quant = (rf_purc_quant == . | rf_purc_quant == -999999999)
g dummy_rf_pric_total = (rf_pric_total == . | rf_pric_total == -999999999)
drop rf_cons_quant rf_purc_quant rf_pric_total

* 3. Reshaping to get one row per interview with all items and whether the quantities/prices for those items are known in columns
reshape wide dummy_rf_cons_quant dummy_rf_purc_quant dummy_rf_pric_total, i(ParentId1) j(Id)

* 4. At the interview level, aggregating proportion of quantities and prices for which answer is missing/unknown/refused to answer among all food items
egen ndkn_food_quant = rowmean(dummy*)
label var ndkn_food_quant "Proportion of missing or don't know or refused to answer for quantities and prices in the food consumption module"
keep ParentId1 ndkn_food_quant

* 5. Merging with main dataset
merge 1:1 ParentId1 using "${gsdTemp}/hh_monitoring_dashboard_temp1" 
order ndkn_food_quant, last
save "${gsdTemp}/hh_monitoring_dashboard_temp2", replace


**Proportion of missing/don't know/refused to answer for prices relating to non-food items consumed

* 1. Importing non-food roster and merging with main dataset
use "${gsdData}/0-RawTemp/rnf_nonfood_manual_cleaning.dta", clear
sort ParentId1 Id
*Dropping one item (water supply) which does not appear in the list of items in the main dataset
drop if Id == 1071
*Keeping interview Id, item Id, and variable "price paid for the amount of item that was purchased"
keep ParentId1 Id rnf_pric_total
*Reshaping to get one row per interview with all items and their price in column
reshape wide rnf_pric_total, i(ParentId1) j(Id)
*Merge with main dataset
merge 1:1 ParentId1 using "${gsdTemp}/hh_monitoring_dashboard_temp2", nogenerate
order rnf_pric_total*, last

* 2. Proportion of non-food items consumed by the household for which price was missing/unknown/refused to answer
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
	g ndkn_non_food_quant_`itemID' = 0 if rnf_relevanceyn_`itemID' == 1
   	replace ndkn_non_food_quant_`itemID' = 1 if rnf_relevanceyn_`itemID' == 1 & (rnf_pric_total_`itemID' == . | rnf_pric_total_`itemID' == -1000000000)
}
*Proportion of non-food items consumed by the household for which price was missing/unknown/refused to answer
egen ndkn_non_food_quant = rowmean(ndkn_non_food_quant_*)
replace ndkn_non_food_quant = 1 if missing(ndkn_non_food_quant)
label var ndkn_non_food_quant "Proportion of missing/unknown/refused to answer prices in the non-food consumption module"
drop ndkn_non_food_quant_* rnf_relevanceyn_* rnf_pric_total*
save "${gsdTemp}/hh_monitoring_dashboard_temp3", replace


**Proportion of missing/don't know/refused to answer to the question on being inside the labour force
*Dummy variable: whether answer is missing, unknown or refused to answer for ALL kinds of activities for this household member
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning.dta", clear
g ndkn_labour = ((emp_7d_paid == -98 | emp_7d_paid == -99 | emp_7d_paid == . | emp_7d_paid == -999999999) & ///
				 (emp_7d_busi == -98 | emp_7d_busi == -99 | emp_7d_busi == . | emp_7d_busi == -999999999) & ///
				 (emp_7d_help == -98 | emp_7d_help == -99 | emp_7d_help == . | emp_7d_help == -999999999) & ///
				 (emp_7d_farm == -98 | emp_7d_farm == -99 | emp_7d_farm == . | emp_7d_farm == -999999999) & ///
				 (emp_7d_appr == -98 | emp_7d_appr == -99 | emp_7d_appr == . | emp_7d_appr == -999999999)) 
*Proportion of don't know/refused to answer by interview (average on all household members)
collapse (mean) ndkn_labour, by(ParentId1)
keep ParentId1 ndkn_labour  
*Merge with main dataset
merge 1:1 ParentId1 using "${gsdTemp}/hh_monitoring_dashboard_temp3", nogenerate 
order ndkn_labour, last
rename ParentId1 Id
label var ndkn_labour "Proportion of missing/don't know/refused to answer to the question on being inside the labour force"

**Dummy variable: whether answer to the question on forced displacement is missing
g ndkn_IDP_status = (migr_disp == -999999999) if successful == 1
label var ndkn_IDP_status "Whether answer to the question on forced displacement is missing"

**Dummy variable: whether answer to the question on receipt of remittances (from abroad) is missing/don't know/refused to answer
g ndkn_remittances = (remit12m_yn == -98 | remit12m_yn == -99 | remit12m_yn == -999999999) if successful == 1
label var ndkn_remittances "Whether answer to the question on receipt of remittances (from abroad) is missing/don't know/refused to answer"

**Non-response rate broken down in the various reasons (no one home, no adult, no consent)
g no_response = 1-consent
g nobody_home = 0 if no_response != .
replace nobody_home = 1 if athome == 0
g no_adult = 0 if no_response != .
replace no_adult = 1 if athome == 1 & adult == 0
g no_consent = 0 if no_response != .
replace no_consent = 1 if athome == 1 & adult == 1 & maycontinue == 0

**Number of skip patterns on successful interviews
*Important skip patterns relate to livestock, durable goods, shocks, displacements, fishing, leavers' roster, remittances
foreach var of varlist shocks0__1-shocks0__18 migr_disp migr_disp_past fishing_yn hhm_separated intremit12m_yn remit12m_yn{
	capture: gen skip_`var' = 1 if (`var' == 0 | `var' == -999999999 | `var' == -98 | `var' == -99) & successful == 1
}
save "${gsdTemp}/hh_monitoring_dashboard_temp4", replace

*Another important skip pattern relate to employment
*Import household roster
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning.dta", clear
*Skip pattern = + 1 for each no/don't know/refused to answer to questions on employment status per member of the household
g skip_employment = (inlist(emp_7d_paid,0,-98,-99,.,-999999999)) + ///
					(inlist(emp_7d_busi,0,-98,-99,.,-999999999)) + ///
					(inlist(emp_7d_help,0,-98,-99,.,-999999999)) + ///
					(inlist(emp_7d_farm,0,-98,-99,.,-999999999)) + ///
					(inlist(emp_7d_appr,0,-98,-99,.,-999999999))
*Total number of skip patterns per interview on employment(collapse on household members)
collapse (sum) skip_employment, by(ParentId1)
*Merge with main dataset
rename ParentId1 Id
keep Id skip_employment  
merge 1:1 Id using "${gsdTemp}/hh_monitoring_dashboard_temp4", nogenerate 
order skip_employment, last

*Total number of skip patterns on successful interviews
egen nb_skip_patterns = rowtotal(skip*) if successful == 1
label var nb_skip_patterns "Number of important skip patterns activated in the interview"
drop skip*

**Completeness of successful interviews
*Dummy variables: whether each variable of the interview is missing or not
ds Id-interview__key, has(type string)
local string `r(varlist)'
ds Id-interview__key, has(type numeric)
local numeric `r(varlist)'
foreach var of local string {
	gen mi_`var' = (`var' == "##N/A##")
}
foreach var of local numeric {
	gen mi_`var' = (`var'== -999999999)
}
*Proportion of missing answers
egen missing_prop = rowmean(mi_*) if successful == 1
drop mi_*
label var missing_pro "Proportion of missing answers" 

save "${gsdTemp}/hh_monitoring_dashboard_temp5", replace

**Soft constraints not respected
/*Soft constraints:
	1) one of the household members must be 16 or above (cf. minimum age of the respondent)
	2) the number of years of education must be realistic
The variables are equal to 1 if the soft constraint is not respected and 0 otherwise */

**Import household members roster 
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning.dta", clear

**Dummy variables at the household member level
*Household member is not an adult if he/she is not above 16
g not_adult = (hhm_age < 16) if missing(hhm_age)==0
*Household member has an unrealistic number of years of education if it exceeds 30 years or if it exceeds the age of the household member
g edu_not_realistic = (hhm_edu_years >= 30 | hhm_edu_years > hhm_age) if missing(hhm_age) == 0 & missing(hhm_edu_years) == 0

**Check whether soft constraints are respected at the household level
*At least one member of the household is above 16
bysort ParentId: egen soft_const_adult = min(not_adult)
*All members of the household have a realistic number of years of education
bysort ParentId: egen soft_const_edu = max(edu_not_realistic)

**Add soft constraints dummies into main dataset
keep ParentId soft_const_adult soft_const_edu
rename ParentId Id
*Collapse to have one row per household and whether the soft constraints 1 and 2 are respected or not
collapse (first) soft_const_adult soft_const_edu, by(Id)
*Merge with main dataset
merge 1:1 Id using "${gsdTemp}/hh_monitoring_dashboard_temp5", nogenerate 

order soft*, last
label var soft_const_adult "Whether soft constraint on age is not respected"
label var soft_const_edu "Whether soft constraint on education is not respected"

**Dummy variable to identify interviews where the fisheries module was activated
g fisheries = (fishing_yn == 1) if successful_valid == 1

**Number of household members for successful interviews
g nhhm_succ = nhhm if successful == 1

save "${gsdTemp}/hh_monitoring_dashboard_temp6", replace


/*----------------------------------------------------------------------------*/
/*                   MONITORING DASHBOARD: MAIN OUTPUT                        */
/*----------------------------------------------------------------------------*/

preserve

*Collapse by state/region/strata/team/ea/enumerator/date
collapse (sum) nb_itw=index itw_valid successful successful_valid val_succ1-val_succ4 gps_ok beh_treat0 beh_treat1 fisheries ///
	(mean) ndkn_food ndkn_non_food ndkn_food_quant ndkn_non_food_quant ndkn_IDP_status ndkn_remittances ndkn_labour ///
	(mean) nb_skip_patterns missing_prop soft_const_adult soft_const_edu ///
	(mean) no_response nobody_home no_adult no_consent ///
	(median) duration_med = duration_itw_min (mean) duration_mean = duration_itw_min ///
	(min) duration_min = duration_itw_min (max) duration_max = duration_itw_min ///
	(mean) nhhm_succ target_itw_ea, ///
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
label var ndkn_food "Average proportion of food items with no or don't know for consumption answer"
label var ndkn_food_quant "Average proportion of missing, unknown or refused to answer quantities and prices for consumed or purchased items in the food consumption module"
label var ndkn_non_food "Average proportion of non-food items with no or don't know for consumption answer"
label var ndkn_non_food_quant "Average proportion of missing, unknown or refused to answer prices for consumed or purchased items in the non-food consumption module"
label var ndkn_IDP_status "Proportion of missing, unknown or refused to answer to the question on IDP status"
label var ndkn_remittances "Proportion of missing, unknown or refused to answer to the question on receipt of remittances"
label var ndkn_labour "Average proportion of missing, unknown or refused to answer to the question on being in the labour force"
label var nb_skip_patterns "Average number of skip patterns on successful interviews"	
label var missing_prop "Average proportion of missing answers on successful interviews"
label var soft_const_adult "Average proportion of interviews not respecting the soft constraint: at least one household member above 16"
label var soft_const_edu "Average proportion of interviews not respecting the soft constraint: realistic number of years of education"
label var duration_med "Median duration of successful interviews - minutes"
label var duration_mean "Mean duration of successful interviews - minutes"
label var duration_min "Min duration of successful interviews - minutes"
label var duration_max "Max duration of successful interviews - minutes"
label var nhhm_succ "Average number of household members for successful interviews"
label var fisheries "Number of valid and successful inteviews for which the fisheries module was activated"
label var issue "Issue?"
label var target_itw_ea "Target number of valid and successful interviews per EA"

order state ea_reg strata_id strata_name id_ea team_id enum_id enum_name date_stata nb_itw itw_valid successful successful_valid ///
	val_succ1-val_succ4 beh_treat0 beh_treat1 gps_ok gps_prop valid_prop no_response nobody_home no_adult no_consent ///
	ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ndkn_IDP_status ndkn_remittances ndkn_labour ///
	nb_skip_patterns missing_prop soft_const_adult soft_const_edu ///
	duration_med duration_mean duration_min duration_max nhhm_succ fisheries issue target_itw_ea
	
sort team_id enum_id date_stata

*Export
export excel using "${gsdOutput}/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Main Output") cell(B5) sheetmodify
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

order state team_id date_stata nb_itw itw_valid successful successful_valid successful_valid_cum gps_ok gps_prop valid_prop ///
	no_response nobody_home no_adult no_consent duration_med duration_mean duration_min duration_max avg_valid_prop
	
sort team_id date_stata

*Export
export excel using "${gsdOutput}/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Teams") cell(B7) sheetmodify
restore

/*----------------------------------------------------------------------------*/
/*                 MONITORING DASHBOARD: ENUMERATOR OUTPUT                    */
/*----------------------------------------------------------------------------*/

preserve

*Collapse by enumerator and date
collapse (sum) nb_itw=index itw_valid successful successful_valid gps_ok ///
	(mean) ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ndkn_IDP_status ndkn_remittances ndkn_labour ///
	(mean) nb_skip_patterns missing_prop soft_const_adult soft_const_edu ///
	(mean) no_response nobody_home no_adult no_consent nhhm_succ ///
	(median) duration_med = duration_itw_min (mean) duration_mean = duration_itw_min ///
	(min) duration_min = duration_itw_min (max) duration_max = duration_itw_min, ///
	by(state team_id enum_id enum_name date_stata)

*Number of valid and successful interviews - Cumulative by date
sort enum_id date_stata
by enum_id : gen successful_valid_cum = sum(successful_valid)
*Proportion of interviews meeting validity criteria for GPS coordinates (on all interviews)
g gps_prop = gps_ok/nb_itw
*Proportion of valid interviews (on all interviews)
g valid_prop = itw_valid/nb_itw

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
label var ndkn_food "Average proportion of food items with no or don't know for consumption answer"
label var ndkn_food_quant "Average proportion of missing, unknown or refused to answer quantities and prices for consumed or purchased items in the food consumption module"
label var ndkn_non_food "Average proportion of non-food items with no or don't know for consumption answer"
label var ndkn_non_food_quant "Average proportion of missing, unknown or refused to answer prices for consumed or purchased items in the non-food consumption module"
label var ndkn_IDP_status "Proportion of missing, unknown or refused to answer to the question on IDP status"
label var ndkn_remittances "Proportion of missing, unknown or refused to answer to the question on receipt of remittances"
label var ndkn_labour "Average proportion of missing, unknown or refused to answer to the question on being in the labour force"
label var nb_skip_patterns "Average number of skip patterns on successful interviews"	
label var missing_prop "Average proportion of missing answers on successful interviews"
label var soft_const_adult "Average proportion of interviews not respecting the soft constraint: at least one household member above 16"
label var soft_const_edu "Average proportion of interviews not respecting the soft constraint: realistic number of years of education"
label var duration_med "Median duration of interviews - minutes"
label var duration_mean "Mean duration of interviews - minutes"
label var duration_min "Min duration of interviews - minutes"
label var duration_max "Max duration of interviews - minutes"
label var nhhm_succ "Average number of household members for successful interviews"

order state team_id enum_id enum_name date_stata ///
	nb_itw itw_valid successful successful_valid successful_valid_cum ///
	gps_ok gps_prop valid_prop no_response nobody_home no_adult no_consent ///
	ndkn_food ndkn_food_quant ndkn_non_food ndkn_non_food_quant ///
	ndkn_IDP_status ndkn_remittances ndkn_labour ///
	nb_skip_patterns missing_prop soft_const_adult soft_const_edu ///
	duration_med duration_mean duration_min duration_max nhhm_succ

sort team_id enum_id date_stata

*Export	
export excel using "${gsdOutput}/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Enumerators") cell(B7) sheetmodify

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
export excel using "${gsdOutput}/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Date") cell(B6) sheetmodify
restore


/*----------------------------------------------------------------------------*/
/*                 MONITORING DASHBOARD: STRATA OUTPUT                        */
/*----------------------------------------------------------------------------*/

*** Target number of interviews per strata
preserve
import excel "${gsdDataRaw}/Inputs EAs.xls", sheet("Summary")clear
rename (A B C) (strata_name target_itw_strata_uri target_itw_strata_host)
drop if _n <= 4
destring target_itw_strata_uri target_itw_strata_host, replace
g target_itw_strata = target_itw_strata_uri + target_itw_strata_host
drop target_itw_strata_uri target_itw_strata_host
save "${gsdTemp}/strata_target_itw.dta", replace
restore

preserve

*** Number of EAs originally sampled or active replacements used per strata
*Originally sampled or active replacements
bysort strata_id id_ea: g nb_eas_sampled = 1 if _n == 1 & (sample_final_uri == 1 | sample_final_h == 1)
*Neither originally sampled nor active replacements
bysort strata_id id_ea: g nb_eas_not_sampled = 1 if _n == 1 & (sample_final_uri == 0 & sample_final_h == 0)

*Collapse by strata
collapse (sum) nb_eas_sampled nb_eas_not_sampled ///
	nb_itw=index itw_valid successful successful_valid val_succ1-val_succ4 ///
	(mean) no_response nobody_home no_adult no_consent, by(strata_id strata_name)
	
*Target number of interviews per strata	
merge 1:1 strata_name using  "${gsdTemp}/strata_target_itw.dta", keep(match master) nogenerate
*Percentage of target reached in termes of number of valid and successful interviews
g perc_target = successful_valid/target_itw_strata
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
label var target_itw_strata "Target number of valid and successful interviews per strata"
label var perc_target "Percentage of target reached"
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
	nb_itw itw_valid successful successful_valid target_itw_strata perc_target ///
	val_succ1-val_succ4 valid_prop no_response nobody_home no_adult no_consent

sort strata_id

*Export
export excel using "${gsdOutput}/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Strata") cell(B6) sheetmodify
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
*Number of valid and successful interviews conducted in the EA for the Urban/Rural/IDP sample
g successful_valid_uri = max(successful_valid, target_itw_ea_uri)
*Number of valid and successful interviews conducted in the EA for the host communities sample
g successful_valid_h = max(0, successful_valid - target_itw_ea_uri)

*Final cleaning and labelling
label values ea_status ea_status_label
label var ea_reg "Region"
label var strata_id "Strata ID"
label var strata_name "Strata name"
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

keep ea_reg strata_id strata_name id_ea nb_itw itw_valid successful successful_valid successful_valid_uri successful_valid_h ///
 target_itw_ea target_itw_ea_uri target_itw_ea_h val_succ1-val_succ4 ea_status ea_valid list_val_succ_ea
order ea_reg strata_id strata_name id_ea nb_itw itw_valid successful successful_valid successful_valid_uri successful_valid_h ///
 target_itw_ea target_itw_ea_uri target_itw_ea_h val_succ1-val_succ4 ea_status ea_valid list_val_succ_ea
	
sort strata_id id_ea

*Export
export excel using "${gsdOutput}/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - EA") cell(B6) sheetmodify
restore

/*----------------------------------------------------------------------------*/
/*            MONITORING DASHBOARD: INVALID INTERVIEW OUTPUT                  */
/*----------------------------------------------------------------------------*/

preserve

*Keep only invalid interviews
keep if itw_valid == 0
*Keep only relevant variables
keep state strata_id strata_name team_id enum_id enum_name id_ea int_no date_stata itw_invalid_reason successful Id

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
label var Id "Key"

order date_stata state strata_id strata_name team_id enum_id enum_name id_ea int_no itw_invalid_reason ///
	short_duration no_gps not_within_EA no_original_itw invalid_original_itw no_first_itw invalid_first_itw gps_no_match successful Id 

gsort -date_stata team_id enum_id int_no itw_invalid_reason

*Export
export excel using "${gsdOutput}/SHFS2_Monitoring_Dashboard_Master.xlsm", sheet("Output - Invalid interviews") cell(B9) sheetmodify
restore
