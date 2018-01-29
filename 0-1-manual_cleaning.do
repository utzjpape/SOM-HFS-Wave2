*-------------------------------------------------------------------
*
*     MANUAL CORRECTIONS 
*     
*     This file records manual corrections 
*     (e.g. corrections on dates) after import
*                         
*-------------------------------------------------------------------

***** PART 1: URBAN/RURAL/IDPs

*** Importing questionnaire
** Version 1
use "${gsdDownloads}/Somali High Frequency Survey - Wave 2 - Fieldwork", clear
tostring ea_barcode, replace
tostring *_spec, replace
tostring *_sp, replace
tostring toilet_ot, replace
tostring land_use_disp_s, replace
tostring rl_other, replace
tostring *_specify, replace
tostring  housingtype_disp_s, replace
save "${gsdTemp}/hh_append_v1", replace

** Version 2
use "${gsdDownloads}/v2/Somali High Frequency Survey - Wave 2 - Fieldwork", clear
tostring *_spec, replace
tostring *_sp, replace
tostring *_specify, replace
tostring loc_retry__Timestamp, replace
tostring loc_barcode__Timestamp, replace
tostring loc_hhid_seg1ret1__Timestamp, replace
tostring housingtype_disp_s, replace
tostring ea_barcode, replace
tostring hh_list_separated__*, replace
tostring housingtype_s, replace
tostring toilet_ot, replace
tostring land_use_disp_s, replace
tostring rl_other, replace
tostring land_unit_spec_disp, replace
tostring disp_date, replace
tostring disp_arrive_date, replace
tostring phone_number, g(phone_number2)
drop phone_number
rename phone_number2 phone_number
save "${gsdTemp}/hh_append_v2", replace

*Version 4
use "${gsdDownloads}/v4/Somali High Frequency Survey - Wave 2 - Fieldwork", clear
tostring *_spec, replace
tostring *_sp, replace
tostring *_specify, replace
tostring loc_retry__Timestamp, replace
tostring loc_barcode__Timestamp, replace
tostring loc_hhid_seg1ret1__Timestamp, replace
tostring  housingtype_disp_s, replace
tostring ea_barcode, replace
tostring hh_list_separated__*, replace
tostring housingtype_s, replace
tostring toilet_ot, replace
tostring land_use_disp_s, replace
tostring rl_other, replace
tostring land_unit_spec_disp, replace
tostring disp_date, replace
tostring disp_arrive_date, replace
tostring phone_number, g(phone_number2)
drop phone_number
rename phone_number2 phone_number
save "${gsdTemp}/hh_append_v4", replace

*Version 6
use "${gsdDownloads}/v6/Somali High Frequency Survey - Wave 2 - Fieldwork", clear
tostring loc_barcode__Timestamp, replace
tostring loc_hhid_seg1ret1__Timestamp, replace
tostring hh_list_separated__*, replace
tostring *_spec, replace
tostring *_sp, replace
tostring *_specify, replace
tostring toilet_ot, replace
tostring housingtype_disp_s, replace
tostring land_use_disp_s, replace
tostring land_unit_spec_disp, replace
tostring rl_other, replace
save "${gsdTemp}/hh_append_v6", replace

*Version 9
use "${gsdDownloads}/v9/Somali High Frequency Survey - Wave 2 - Fieldwork", clear
tostring ea_barcode, replace
tostring loc_barcode__Timestamp, replace
tostring loc_hhid_seg1ret1__Timestamp, replace
tostring hh_list_separated__*, replace
tostring housingtype_s, replace
tostring *_spec, replace
tostring *_sp, replace
tostring toilet_ot, replace
tostring  housingtype_disp_s, replace
tostring land_use_disp_s, replace
tostring land_unit_spec_disp, replace
tostring rl_other, replace
tostring *_specify, replace
tostring phone_number, g(phone_number2)
drop phone_number
rename phone_number2 phone_number
tostring loc_retry__Timestamp, replace
save "${gsdTemp}/hh_append_v9", replace

*Version 10
use "${gsdDownloads}/v10/Somali High Frequency Survey - Wave 2 - Fieldwork", clear
tostring ea_barcode, replace
tostring loc_barcode__Timestamp, replace
tostring loc_hhid_seg1ret1__Timestamp, replace
tostring hh_list_separated__*, replace
tostring housingtype_s, replace
tostring *_spec, replace
tostring *_sp, replace
tostring toilet_ot, replace
tostring  housingtype_disp_s, replace
tostring land_use_disp_s, replace
tostring land_unit_spec_disp, replace
tostring rl_other, replace
tostring *_specify, replace
tostring phone_number, g(phone_number2)
drop phone_number
rename phone_number2 phone_number
tostring loc_retry__Timestamp, replace
save "${gsdTemp}/hh_append_v10", replace

*Version 11
use "${gsdDownloads}/v11/Somali High Frequency Survey - Wave 2 - Fieldwork", clear
tostring ea_barcode, replace
tostring loc_barcode__Timestamp, replace
tostring loc_hhid_seg1ret1__Timestamp, replace
tostring hh_list_separated__*, replace
tostring housingtype_s, replace
tostring *_spec, replace
tostring *_sp, replace
tostring toilet_ot, replace
tostring  housingtype_disp_s, replace
tostring land_use_disp_s, replace
tostring land_unit_spec_disp, replace
tostring rl_other, replace
tostring *_specify, replace
tostring disp_date, replace
tostring disp_arrive_date, replace
tostring phone_number, g(phone_number2)
drop phone_number
rename phone_number2 phone_number
tostring loc_retry__Timestamp, replace
save "${gsdTemp}/hh_append_v11", replace


** Append all versions
* Main dataset
use "${gsdTemp}/hh_append_v1", clear
append using "${gsdTemp}/hh_append_v2"
append using "${gsdTemp}/hh_append_v4"
append using "${gsdTemp}/hh_append_v6"
append using "${gsdTemp}/hh_append_v9"
append using "${gsdTemp}/hh_append_v10"
append using "${gsdTemp}/hh_append_v11"
save "${gsdTemp}/hh_append", replace

*Rosters
local files hh_roster_separated hhroster_age motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
foreach file in `files' {
	use "${gsdDownloads}/`file'", clear
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring ra_namelp_prev, replace
	capture: tostring rl_give_reason_o, replace
	capture: tostring hhm_relation_sep_s, replace
	capture: tostring rl_lose_reason_o, replace
	save "${gsdTemp}/`file'_append_v1", replace
	
	use "${gsdDownloads}/v2/`file'", clear
	tostring interview__id, replace
	tostring interview__key, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring hhm_edu_level_other, replace
	capture: tostring hhm_relation_sep_s, replace
	capture: tostring rl_lose_reason_o, replace
	capture: tostring hh_list_separated, replace
	capture: tostring hhm_relation_other, replace
	capture: tostring ra_namelp_prev, replace
	capture: tostring rl_give_reason_o, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring rnf_free_other, replace
	save "${gsdTemp}/`file'_append_v2", replace
	
	use "${gsdDownloads}/v4/`file'", clear
	tostring interview__id, replace
	tostring interview__key, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring hhm_edu_level_other, replace
	capture: tostring hhm_relation_sep_s, replace
	capture: tostring rl_lose_reason_o, replace
	capture: tostring hh_list_separated, replace
	capture: tostring hhm_relation_other, replace
	capture: tostring ra_namelp_prev, replace
	capture: tostring rl_give_reason_o, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring rnf_free_other, replace
	save "${gsdTemp}/`file'_append_v4", replace
	
	use "${gsdDownloads}/v6/`file'", clear
	tostring interview__id, replace
	tostring interview__key, replace
	capture: tostring hh_list_separated, replace
	capture: tostring hhm_relation_sep_s, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring rl_give_reason_o, replace
	capture: tostring rl_lose_reason_o, replace
	capture: tostring rnf_free_other, replace
	save "${gsdTemp}/`file'_append_v6", replace
	
	use "${gsdDownloads}/v9/`file'", clear
	tostring interview__id, replace
	tostring interview__key, replace
	capture: tostring hh_list_separated, replace
	capture: tostring hhm_relation_sep_s, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring hhm_relation_other, replace
	capture: tostring hhm_edu_level_other, replace
	capture: tostring rl_give_reason_o, replace
	capture: tostring rl_lose_reason_o, replace
	capture: tostring rnf_free_other, replace
	save "${gsdTemp}/`file'_append_v9", replace
	
	use "${gsdDownloads}/v10/`file'", clear
	tostring interview__id, replace
	tostring interview__key, replace
	capture: tostring hh_list_separated, replace
	capture: tostring hhm_relation_sep_s, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring hhm_relation_other, replace
	capture: tostring hhm_edu_level_other, replace
	capture: tostring rl_give_reason_o, replace
	capture: tostring rl_lose_reason_o, replace
	capture: tostring rnf_free_other, replace
	save "${gsdTemp}/`file'_append_v10", replace
	
	use "${gsdDownloads}/v11/`file'", clear
	tostring interview__id, replace
	tostring interview__key, replace
	capture: tostring hh_list_separated, replace
	capture: tostring hhm_relation_sep_s, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring hhm_relation_other, replace
	capture: tostring hhm_edu_level_other, replace
	capture: tostring rl_give_reason_o, replace
	capture: tostring rl_lose_reason_o, replace
	capture: tostring rnf_free_other, replace
	capture: tostring ra_namelp_prev, replace
	save "${gsdTemp}/`file'_append_v11", replace
	
	use "${gsdTemp}/`file'_append_v1", clear
	append using "${gsdTemp}/`file'_append_v2"
	append using "${gsdTemp}/`file'_append_v4"
	append using "${gsdTemp}/`file'_append_v6"
	append using "${gsdTemp}/`file'_append_v9"
	append using "${gsdTemp}/`file'_append_v10"
	append using "${gsdTemp}/`file'_append_v11"
	save "${gsdTemp}/`file'_append", replace
}

use "${gsdTemp}/hh_append", clear

**** Dropping empty observations in all datasets (main + rosters)
* Main dataset
drop if interview__id=="42755ff8b2324f27b13fb6c19b58c914"
drop if interview__id=="5098f72447fe4d4fa031cc3376c71c4c"
drop if interview__id=="c59c6ad28b2d4365a54874c7e86a4790"
drop if interview__id=="38a4e9aef58840f8a344415df12b6ccd"
drop if interview__id=="c2a6f03a61234ddd847fb0c8c61a9b17"
drop if interview__id=="86e4611c536d4e3fa16d949a72f1a9d5"
drop if interview__id=="09f70b5b4e6e4e30af881b1fbe944610"
drop if interview__id=="eecea7f1818e432eae713fdbbd6d0318"
drop if interview__id=="8f2c20d012a4411c8fbe4d1eb550b222"
drop if interview__id=="d3532e5005f7482d81f0b8f0614abf59"
save "${gsdTemp}/hh_without_empty_obs", replace

* Rosters
local files hh_roster_separated hhroster_age motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
foreach file in `files' {
	use "${gsdTemp}/`file'_append", clear
	drop if interview__id=="42755ff8b2324f27b13fb6c19b58c914" 
	drop if interview__id=="5098f72447fe4d4fa031cc3376c71c4c"
	drop if interview__id=="c59c6ad28b2d4365a54874c7e86a4790"
	drop if interview__id=="38a4e9aef58840f8a344415df12b6ccd"
	drop if interview__id=="c2a6f03a61234ddd847fb0c8c61a9b17"
	drop if interview__id=="86e4611c536d4e3fa16d949a72f1a9d5"
	drop if interview__id=="09f70b5b4e6e4e30af881b1fbe944610"
	drop if interview__id=="eecea7f1818e432eae713fdbbd6d0318"
	drop if interview__id=="8f2c20d012a4411c8fbe4d1eb550b222"
	drop if interview__id=="d3532e5005f7482d81f0b8f0614abf59"
	save "${gsdData}/0-RawTemp/`file'_manual_cleaning.dta", replace
}

* Cleaning duplicates in the non-food roster
use "${gsdData}/0-RawTemp/rnf_nonfood_manual_cleaning.dta", clear
drop if interview__id =="d887f734686c421d8621563041c069f5" & rnf_nonfood__id==1088 & rnf_item_recall=="##N/A##"
drop if interview__id =="d887f734686c421d8621563041c069f5" & rnf_nonfood__id==1089 & rnf_item_recall=="##N/A##"
drop if interview__id =="d887f734686c421d8621563041c069f5" & rnf_nonfood__id==1090 & rnf_item_recall=="##N/A##"
drop if interview__id =="252fa757d26644fdb3571cd6f3838f17" & rnf_nonfood__id==1089 & rnf_item_recall=="##N/A##"
drop if interview__id =="252fa757d26644fdb3571cd6f3838f17" & rnf_nonfood__id==1090 & rnf_item_recall=="##N/A##"
drop if interview__id =="af1411b68c6d40fe904b58a558310dca" & rnf_nonfood__id==1088 & rnf_item_recall=="##N/A##"
drop if interview__id =="af1411b68c6d40fe904b58a558310dca" & rnf_nonfood__id==1089 & rnf_item_recall=="##N/A##"
drop if interview__id =="af1411b68c6d40fe904b58a558310dca" & rnf_nonfood__id==1090 & rnf_item_recall=="##N/A##"
drop if interview__id =="7a365578819d4d47b11ff60bbff02385" & rnf_nonfood__id==1086 & rnf_item_recall=="##N/A##"
drop if interview__id =="7a365578819d4d47b11ff60bbff02385" & rnf_nonfood__id==1087 & rnf_item_recall=="##N/A##"
drop if interview__id =="7a365578819d4d47b11ff60bbff02385" & rnf_nonfood__id==1088 & rnf_item_recall=="##N/A##"
drop if interview__id =="7a365578819d4d47b11ff60bbff02385" & rnf_nonfood__id==1089 & rnf_item_recall=="##N/A##"
drop if interview__id =="7a365578819d4d47b11ff60bbff02385" & rnf_nonfood__id==1090 & rnf_item_recall=="##N/A##"
drop if interview__id =="66d695dfd0be441e9f84af790596be89" & rnf_nonfood__id==1090 & rnf_item_recall=="##N/A##"
drop if interview__id =="c9344caa731f45d3a63aaedffc2caa36" & rnf_nonfood__id==1088 & rnf_item_recall=="##N/A##"
drop if interview__id =="c9344caa731f45d3a63aaedffc2caa36" & rnf_nonfood__id==1089 & rnf_item_recall=="##N/A##"
drop if interview__id =="c9344caa731f45d3a63aaedffc2caa36" & rnf_nonfood__id==1090 & rnf_item_recall=="##N/A##"
drop if interview__id =="47fc633273954f448ecf9f4419406caf" & rnf_nonfood__id==1090 & rnf_item_recall=="##N/A##"
drop if interview__id =="d8d68289846346d9a3bf8519a605a88d" & rnf_nonfood__id==1090 & rnf_item_recall=="##N/A##"
drop if interview__id =="2d9388e30e6f4033a9cf11c76d90a112" & rnf_nonfood__id==1090 & rnf_item_recall=="##N/A##"
save "${gsdData}/0-RawTemp/rnf_nonfood_manual_cleaning.dta", replace

*** Importing questionnaire
use "${gsdTemp}/hh_without_empty_obs", clear

*** Team cleaning
replace team_id = 38 if interview__id=="4b7adf58ea5140488f667bf97fb4e8a9"

*** Enumerator name cleaning
replace enum_id = 3105 if interview__id=="ab0e6a8b5df34626b3f17a8ee5182ef0"
replace enum_id = 3206 if interview__id=="568d421b53b1407ca17d51362e22c68c"
replace enum_id = 2204 if interview__id=="aa65b9856f6c4437b9397f8b9444549e"
replace enum_id = 203 if interview__id=="d5abc9e7adb24ff28d98998b4039e273"
replace enum_id = 4102 if interview__id=="43ef97e987c544bd989605c7f63e3470"
replace enum_id = 4102 if interview__id=="25ec98ab9da34bc49f0480f72683bbf3"
replace enum_id = 4104 if interview__id=="16138275434f433cb1ab9adba989d71d"
replace enum_id = 3801 if interview__id=="4b7adf58ea5140488f667bf97fb4e8a9"
replace enum_id = 4301 if interview__id=="91eb31696b394d6d999000caf6821804"
replace enum_id = 4301 if interview__id=="6e56a88db03a44f9ba55030541500b8c"
replace enum_id = 4301 if interview__id=="fd9806fc89574d1b854250ffeb3e800e"

label define enum_id ///
	3602 "Mohamed Isak Mohamed" ///
	3603 "Fadumo Mohamed Jilal" ///
	3604 "Farhiya Abass Mohamed" ///
	3701 "Team Leader (Team 37)" ///
	3702 "Abdirahman Khalif Abdi" ///
	3703 "Hashim Abdi Weheliye" ///
	3704 "Abshir Abdule Noor" ///
	3801 "Team Leader (Team 38)" ///
	3802 "Abdullahi Ibrahim Abdi" ///
	3803 "Hassan Mohamed Abdi" ///
	3804 "Jeylani Mohamed Dhere" ///
	3902 "Fuad Aden Yussuf" ///
	3903 "Fatuma Aden Issack" ///
	3904 "Hussein Madey Mohamed" ///
	4001 "Team Leader (Team 40)" ///
	4002 "Ali Farah Adow" ///
	4003 "Jama Ali Sheikh" ///
	4004 "Hassan Muhumad Rashiid" ///
	4101 "Abdiaziz Rage Ahmed" ///
	4102 "Abdiaziz Rage Ahmed" ///
	4103 "Amina Hilowle Isak" ///
	4104 "Najmo Omar Kalinle" ///
	4202 "Arab Mohamed Jamac" ///
	4203 "Ahmed Hashi Ahmed" ///
	4204 "Osman Hire Sabtow" ///
	4301 "Ahmed Shacban Hassan" ///
	4302 "Mohamed Adan Mohamed" ///
	4303 "Mohamed Adan Hassan" ///
	4304 "Mohamed Sheik Abdullahi", modify	
*tab enum_id

*** Pre-war region cleaning
*04/12/2017
replace ea_reg=5 if interview__id=="568d421b53b1407ca17d51362e22c68c"
replace ea_reg=5 if interview__id=="92950f08645d485a8261144204ab4e5c"
*05/12/2017
replace ea_reg=18 if interview__id=="cb6f2d926ba548d796e0816b29c7d183"
*08/12/2017
replace ea_reg=14 if interview__id=="42755ff8b2324f27b13fb6c19b58c914"
*10/12/2017
replace ea_reg=18 if interview__id=="5e7488837e1e4798baa4dea9a8e92930"
*13/12/2017
replace ea_reg=3 if interview__id=="2f4a50488d6c43769cbea7764b9c853c"
replace ea_reg=5 if interview__id=="2f54487868994e87b194740416f6fd98"
*15/12/2017
replace ea_reg=11 if interview__id=="9dd0b0a2adeb41a1940795bb1c705e3b"
*18/12/2017
replace ea_reg=3 if interview__id=="fb892e464ec546d39440f3a45bd6bfcc"
*20/12/2017
replace ea_reg=2 if interview__id=="d508f9bcc52b43ba89238a484efc519c"
*tab ea_reg
*tab ea_reg ea if substr(today,1,10)=="2018-01-16"

*** Strata cleaning
replace strata=32 if interview__id=="9a2230c16d0c498aa06def1704517029"
*tab strata

*** EA number cleaning
*08/12/2017
replace ea=6116000 if interview__id=="5c40caffe54044deb59ed86dc5610e85"
*25/12/2017
replace ea=198760 if interview__id=="89fd6810cc534326ac279a8fb63e5456"
*01/01/2018
replace ea=82297 if interview__id=="9a2230c16d0c498aa06def1704517029"
*tab ea
*tab ea team_id if substr(today,1,10)=="2018-01-16"

*** Team number cleaning
*15/12/2017
replace team_id=25 if interview__id=="b5c05ad294c54541bf5935af4af9f143"
replace team_id=25 if interview__id=="895ca6bc2ea2462eb1aec1d4f0181d9c"
replace team_id=25 if interview__id=="6887628dd19e4cd896addeb9c60b3d8e"
replace team_id=26 if interview__id=="6a68e5a0d113442baf111bdb1e9e5e6a"
replace team_id=26 if interview__id=="ddb22faac8a043a4821cb7c20a577029"
replace team_id=26 if interview__id=="9c2e66e34803410886193b96c428d566"
replace team_id=26 if interview__id=="c2df02cdf67e4ae9a207080edf01bb28"
replace team_id=26 if interview__id=="567bfe7c36ad4f71b01edc91af10ad80"
*16/12/2017
replace team_id=25 if interview__id=="46469c99777b43cdb08c9bc7d6fbac43"
replace team_id=25 if interview__id=="45ec02b4a6eb4f92b82a84b5257782ae"
replace team_id=25 if interview__id=="db79c5fbde0f4fcb89baaa49d4fe2481"
replace team_id=26 if interview__id=="7efe096ecf414c1eaf2f4349053419d0"
*17/12/2017
replace team_id=25 if interview__id=="9a4d3daeef0e4a7d81a5ffa748472347"
replace team_id=25 if interview__id=="702823a58f2640a19eef9c08c1c7d43f"
replace team_id=25 if interview__id=="a6c495964269458eadb51ec2061e2889"
replace team_id=27 if interview__id=="b34df01d78b447188888163a461d9b3f"
replace team_id=27 if interview__id=="db42ad2e2999498d83d530a4163c72e1"
replace team_id=27 if interview__id=="e1481985c9814935b8a97130192c87cf"
*18/12/2017
replace team_id=27 if interview__id=="6309fe996c1d42d5967a6be6f19cd06f"
replace team_id=27 if interview__id=="9ba2275830554fd1b2b05eeaf45462d9"
replace team_id=25 if interview__id=="269c449042254ace8c12abe422ac418e"
replace team_id=25 if interview__id=="ea9cd729dc704a1fa35d0e4422916072"
replace team_id=25 if interview__id=="f8a0015a20f1441b98eeeeb3c3620e63"
*19/12/2017
replace team_id=25 if interview__id=="85b3b6e5682347d4bb7751f5c520252e"
replace team_id=26 if interview__id=="713a583312b643308f3d2a758e94f99a"
replace team_id=26 if interview__id=="6870f8e69a3f4b82a07bd770b295c211"
replace team_id=25 if interview__id=="81bdd1f953334adba49790ed13a80af7"
replace team_id=26 if interview__id=="49a5add477ab456fb22378e4ba87dce6"
replace team_id=25 if interview__id=="fc9d911b257c4964a9027af38be7fde2"
replace team_id=27 if interview__id=="08258508606a4a998f9743b6a9ede70d"
replace team_id=27 if interview__id=="383583d2073d40a6a8940587096e1fdf"
replace team_id=27 if interview__id=="87afffad86f74490a478823cff2e6c17"
replace team_id=27 if interview__id=="cc226b1e6de246308a3023d9d3e29cac"
*20/12/2017
replace team_id=27 if interview__id=="5ea10760cafa4d98864185187830d2ec"
replace team_id=27 if interview__id=="5cb8900289b34810b26d37a037ad559a"
replace team_id=27 if interview__id=="ec5f5488c1cf4b4d8a09b188ae6b21a6"
replace team_id=26 if interview__id=="29a7208d909c45d18a72361634d90775"
replace team_id=26 if interview__id=="87eef2b0b89b488ab0d79624373abcec"
replace team_id=26 if interview__id=="3f7f990f5dd545e1b7884008d62023f4"
*21/12/2017
replace team_id=26 if interview__id=="67a95e23d5014b76952b484cffdc3a19"
replace team_id=26 if interview__id=="68b3133d99a545519d1530270076f14d"
replace team_id=26 if interview__id=="6c01e956db09458188e97f651ad46d95"
*22/12/2017
replace team_id=26 if interview__id=="dc8dd3385c634e7686fbcb95ff23557f"
*23/12/2017
replace team_id=27 if interview__id=="2d686225ca144dffb33c9d4b7737fdb9"
replace team_id=27 if interview__id=="88894f72e874474586b937cb36def923"
replace team_id=27 if interview__id=="d42a0bdf2e8e41489c9aa4200153c6e6"
*tab team_id

*** Missing date cleaning at the beginning and at the end of the interview
*Correcting when missing date using dates and times in metadata
*04/12/2017
replace today = "2017-12-04T05:14:36-05:00" if interview__id=="02166905804d4506b48e76266a0e2515"
replace today_end = "2017-12-04T07:38:44-05:00" if interview__id=="02166905804d4506b48e76266a0e2515"
replace today = "2017-12-04T13:56:36-05:00" if interview__id=="1dc5f61235e34b24b3eda74d784371cf"
replace today_end = "2017-12-04T15:08:01-05:00" if interview__id=="1dc5f61235e34b24b3eda74d784371cf"
replace today = "2017-12-04T14:16:26-05:00" if interview__id=="a4ed7427b619480cbb176320bb052ede"
replace today_end = "2017-12-04T15:59:46-05:00" if interview__id=="a4ed7427b619480cbb176320bb052ede"
*05/12/2017
replace today = "2017-12-05T12:12:15-05:00" if interview__id=="568d421b53b1407ca17d51362e22c68c"
replace today_end = "2017-12-05T13:29:48-05:00" if interview__id=="568d421b53b1407ca17d51362e22c68c"
replace today = "2017-12-05T13:13:17-05:00" if interview__id=="ada0265902e040e3bafe5148a4939ce5"
replace today_end = "2017-12-05T15:30:10-05:00" if interview__id=="ada0265902e040e3bafe5148a4939ce5"
replace today = "2017-12-05T06:13:16-05:00" if interview__id=="ab0e6a8b5df34626b3f17a8ee5182ef0"
replace today_end = "2017-12-05T07:12:59-05:00" if interview__id=="ab0e6a8b5df34626b3f17a8ee5182ef0"
replace today = "2017-12-05T05:03:40-05:00" if interview__id=="97d4b04cf43e4979acda113452d89292"
replace today_end = "2017-12-05T06:48:28-05:00" if interview__id=="97d4b04cf43e4979acda113452d89292"
replace today = "2017-12-05T05:40:52-05:00" if interview__id=="07d72a3e85fa4bae962a6b974d48cc5f"
replace today_end = "2017-12-05T07:22:32-05:00" if interview__id=="07d72a3e85fa4bae962a6b974d48cc5f"
*06/12/2017
replace today = "2017-12-06T06:51:15-05:00" if interview__id=="48f83438c2734f2d89a7a300bd6327d4"
replace today_end = "2017-12-06T08:52:38-05:00" if interview__id=="48f83438c2734f2d89a7a300bd6327d4"
replace today = "2017-12-06T11:30:41-05:00" if interview__id=="ed320347e5c24d47b06cd550fcdba98f"
replace today_end = "2017-12-06T12:39:52-05:00" if interview__id=="ed320347e5c24d47b06cd550fcdba98f"
replace today = "2017-12-06T04:57:20-05:00" if interview__id=="5ea29fb31e11444c9d8b12376cc23dd6"
replace today_end = "2017-12-06T06:49:28-05:00" if interview__id=="5ea29fb31e11444c9d8b12376cc23dd6"
replace today = "2017-12-06T04:57:54-05:00" if interview__id=="19f4630686bb44eba7f76142b9d65bd6"
replace today_end = "2017-12-06T07:13:01-05:00" if interview__id=="19f4630686bb44eba7f76142b9d65bd6"
*07/12/2017
replace today = "2017-12-07T06:16:54-05:00" if interview__id=="6f74437bea1d4a25a14b38fb752411dd"
replace today_end = "2017-12-07T08:05:10-05:00" if interview__id=="6f74437bea1d4a25a14b38fb752411dd"
replace today = "2017-12-07T07:33:40-05:00" if interview__id=="edffaf89a7d644cf98c06c96f439e938"
replace today_end = "2017-12-07T09:04:26-05:00" if interview__id=="edffaf89a7d644cf98c06c96f439e938"
replace today = "2017-12-07T08:50:39-05:00" if interview__id=="a802ff2f01e343ecaa1f6aaf0bfe6432"
replace today_end = "2017-12-07T11:02:17-05:00" if interview__id=="a802ff2f01e343ecaa1f6aaf0bfe6432"
*08/12/2017
replace today= "2017-12-08T10:30:06-05:00" if interview__id=="74344c9b4c404d6b89efa6562a198f7b"
replace today_end= "2017-12-08T12:59:06-05:00" if interview__id=="74344c9b4c404d6b89efa6562a198f7b"
*09/12/2017
replace today= "2017-12-09T07:21:15-05:00" if interview__id=="52459c10d842407cb2cd93467678f253"
replace today_end= "2017-12-09T10:08:29-05:00" if interview__id=="52459c10d842407cb2cd93467678f253"
replace today= "2017-12-09T05:42:55-05:00" if interview__id=="7cf1488a1d0a44569192779d5bf874fb"
replace today_end= "2017-12-09T07:56:14-05:00" if interview__id=="7cf1488a1d0a44569192779d5bf874fb"
replace today= "2017-12-09T08:32:31-05:00" if interview__id=="81a9b5db494548099bd88f21e8ba09e1"
replace today_end= "2017-12-09T09:23:34-05:00" if interview__id=="81a9b5db494548099bd88f21e8ba09e1"
replace today= "2017-12-09T10:24:32-05:00" if interview__id=="f5f59289fdd044b18a148332132ba3f8"
replace today_end= "2017-12-09T12:36:03-05:00" if interview__id=="f5f59289fdd044b18a148332132ba3f8"
replace today= "2017-12-09T07:04:08-05:00" if interview__id=="0040b8bcedaa4b7ebe566dbdfbaad6a9"
replace today_end= "2017-12-09T09:01:56-05:00" if interview__id=="0040b8bcedaa4b7ebe566dbdfbaad6a9"
replace today= "2017-12-09T08:05:27-05:00" if interview__id=="fcfa1148a1564d8ba787103b55b0a006"
replace today_end= "2017-12-09T16:18:29-05:00" if interview__id=="fcfa1148a1564d8ba787103b55b0a006"
replace today= "2017-12-09T08:05:31-05:00" if interview__id=="f06de7d9133a43b6b2de3255315a921d"
replace today_end= "2017-12-09T10:44:43-05:00" if interview__id=="f06de7d9133a43b6b2de3255315a921d"
*10/12/2017
replace today_end="2017-12-10T09:54:46-05:00" if interview__id=="51f00f30a7804a66839b2dd22f5a425e"
replace today_end="2017-12-10T11:16:30-05:00" if interview__id=="4fcdc7f4f5434502a01fc9ae23fbcaf4"
replace today_end="2017-12-10T14:32:25-05:00" if interview__id=="7c751e8842b8484c96c277e8b4daccc4"
replace today_end="2017-12-10T09:39:03-05:00" if interview__id=="c59c6ad28b2d4365a54874c7e86a4790"
*11/12/2017
replace today="2017-12-11T11:25:08-05:00" if interview__id=="4fb4c741aa8446dca5b22f0e98551cdc"
replace today_end="2017-12-11T13:30:34-05:00" if interview__id=="4fb4c741aa8446dca5b22f0e98551cdc"
replace today="2017-12-11T10:34:36-05:00" if interview__id=="1902ae429c6a42898216501a6a9bfb8c"
replace today_end="2017-12-11T12:49:55-05:00" if interview__id=="1902ae429c6a42898216501a6a9bfb8c"
*12/12/2017
replace today="2017-12-12T07:11:53-05:00" if interview__id=="c032ecd174b545c195b0ebeab70ed519"
replace today_end="2017-12-12T09:22:45-05:00" if interview__id=="c032ecd174b545c195b0ebeab70ed519"
replace today="2017-12-12T07:02:49-05:00" if interview__id=="e09a8707a112473984a43827310872a8"
replace today_end="2017-12-12T08:49:07-05:00" if interview__id=="e09a8707a112473984a43827310872a8"
replace today="2017-12-12T13:23:41-05:00" if interview__id=="a285a77c94db45c79aec91e4fd401b53"
replace today_end="2017-12-12T15:07:46-05:00" if interview__id=="a285a77c94db45c79aec91e4fd401b53"
*13/12/2017
replace today="2017-12-13T05:20:39-05:00" if interview__id=="4436e1131267443da1ade7c95eb8e12d"
replace today_end="2017-12-13T07:16:26-05:00" if interview__id=="4436e1131267443da1ade7c95eb8e12d"
replace today="2017-12-13T07:32:27-05:00" if interview__id=="6bd4d93f229241d3a142fc3d8ac51c1b"
replace today_end="2017-12-13T15:24:05-05:00" if interview__id=="6bd4d93f229241d3a142fc3d8ac51c1b"
replace today="2017-12-13T05:02:39-05:00" if interview__id=="cde1b78c1eca4334a40d1487f4be68c2"
replace today_end="2017-12-13T07:40:11-05:00" if interview__id=="cde1b78c1eca4334a40d1487f4be68c2"
*14/12/2017
replace today="2017-12-14T10:28:05-05:00" if interview__id=="9d6f1610a8934bbf94278d5d223ae0a8"
replace today_end="2017-12-14T14:41:17-05:00" if interview__id=="9d6f1610a8934bbf94278d5d223ae0a8"
replace today="2017-12-14T04:34:47-05:00" if interview__id=="df701fbdcded45c793b27b7b7e6c3ded"
replace today_end="2017-12-14T09:49:51-05:00" if interview__id=="df701fbdcded45c793b27b7b7e6c3ded"
replace today="2017-12-14T07:33:38-05:00" if interview__id=="763cee868daf498a8336ea76b41a449f"
replace today_end="2017-12-14T10:03:08-05:00" if interview__id=="763cee868daf498a8336ea76b41a449f"
replace today="2017-12-14T00:35:19-05:00" if interview__id=="958089fc40d248a8b99953f6b11bf4b2"
replace today_end="2017-12-14T03:06:43-05:00" if interview__id=="958089fc40d248a8b99953f6b11bf4b2"
replace today="2017-12-14T05:17:10-05:00" if interview__id=="eeb56606929c4d67926496469a113859"
replace today_end="2017-12-14T07:33:04-05:00" if interview__id=="eeb56606929c4d67926496469a113859"
*15/12/2017
replace today="2017-12-15T15:33:05-05:00" if interview__id=="38a4e9aef58840f8a344415df12b6ccd"
replace today_end="2017-12-15T16:04:04-05:00" if interview__id=="38a4e9aef58840f8a344415df12b6ccd"
replace today="2017-12-15T11:13:05-05:00" if interview__id=="2221ddd0e64c4333ad0d4db696bd6ce2"
replace today_end="2017-12-15T18:41:04-05:00" if interview__id=="2221ddd0e64c4333ad0d4db696bd6ce2"
replace today="2017-12-15T08:35:05-05:00" if interview__id=="d1b9464013274672870cc13cf2a620ef"
replace today_end="2017-12-15T10:32:04-05:00" if interview__id=="d1b9464013274672870cc13cf2a620ef"
replace today="2017-12-15T09:40:05-05:00" if interview__id=="9dd0b0a2adeb41a1940795bb1c705e3b"
replace today_end="2017-12-15T13:54:04-05:00" if interview__id=="9dd0b0a2adeb41a1940795bb1c705e3b"
replace today="2017-12-15T03:32:04-05:00" if interview__id=="95881491c988497ea0d7d7fda60353c3"
replace today_end="2017-12-15T06:03:11-05:00" if interview__id=="95881491c988497ea0d7d7fda60353c3"
replace today="2017-12-15T07:44:37-05:00" if interview__id=="16f9ebcc15b34c65b9dc2e67ba97cefa"
replace today_end="2017-12-15T10:04:17-05:00" if interview__id=="16f9ebcc15b34c65b9dc2e67ba97cefa"
*16/12/2017
replace today="2017-12-16T07:56:05-05:00" if interview__id=="7d807d821717481aab99fe0c4720b64f"
replace today_end="2017-12-16T10:23:04-05:00" if interview__id=="7d807d821717481aab99fe0c4720b64f"
replace today="2017-12-16T08:08:05-05:00" if interview__id=="6eaaa22803364de493484798b5035e70"
replace today_end="2017-12-16T10:28:05-05:00" if interview__id=="6eaaa22803364de493484798b5035e70"
replace today="2017-12-16T08:13:45-05:00" if interview__id=="714c226694074d4f957c945dbe8fad8f"
replace today_end="2017-12-16T10:02:05-05:00" if interview__id=="714c226694074d4f957c945dbe8fad8f"
replace today="2017-12-16T00:57:23-05:00" if interview__id=="d4d229d0f04249709a488d125963cfa0"
replace today_end="2017-12-16T03:06:31-05:00" if interview__id=="d4d229d0f04249709a488d125963cfa0"
replace today="2017-12-16T04:17:55-05:00" if interview__id=="5e2abc1c33724f0c805acddefe1dcb08"
replace today_end="2017-12-16T06:23:33-05:00" if interview__id=="5e2abc1c33724f0c805acddefe1dcb08"
*17/12/2017
replace today="2017-12-17T14:10:55-05:00" if interview__id=="886a67c353834d11998284b407f2801a"
replace today_end="2017-12-17T15:39:33-05:00" if interview__id=="886a67c353834d11998284b407f2801a"
*18/12/2017
replace today="2017-12-18T13:57:55-05:00" if interview__id=="bab81ba3231d4c5a901df93a8340bc5c"
replace today_end="2017-12-18T17:50:33-05:00" if interview__id=="bab81ba3231d4c5a901df93a8340bc5c"
*20/12/2017
replace today="2017-12-20T22:33:32-05:00" if interview__id=="6732c86d57ef4e40b67c1e9f1c23aead"
replace today_end="2017-12-20T01:31:20-05:00" if interview__id=="6732c86d57ef4e40b67c1e9f1c23aead"
replace today="2017-12-20T03:42:57-05:00" if interview__id=="0482dc3de21e4531bad43105b84b4c50"
replace today_end="2017-12-20T07:57:14-05:00" if interview__id=="0482dc3de21e4531bad43105b84b4c50"
replace today="2017-12-20T22:38:44-05:00" if interview__id=="35054f64a9a04b1d9db73a9f175f717f"
replace today_end="2017-12-20T00:18:41-05:00" if interview__id=="35054f64a9a04b1d9db73a9f175f717f"
*21/12/2017
replace today="2017-12-21T09:05:32-05:00" if interview__id=="aa313e61b1c74c6ba6d185e54ebd490f"
replace today_end="2017-12-21T12:51:20-05:00" if interview__id=="aa313e61b1c74c6ba6d185e54ebd490f"
replace today="2017-12-21T09:08:57-05:00" if interview__id=="b8b4c1da5dd94b20ae37cd6c1e1a21f9"
replace today_end="2017-12-21T15:00:46-05:00" if interview__id=="b8b4c1da5dd94b20ae37cd6c1e1a21f9"
replace today="2017-12-21T06:08:30-05:00" if interview__id=="3f691b0166c44a879fa9c169d88f25db"
replace today_end="2017-12-21T15:20:10-05:00" if interview__id=="3f691b0166c44a879fa9c169d88f25db"
*23/12/2017
replace today="2017-12-23T09:35:00-05:00" if interview__id=="fe812af74e7a43e1a7a0d6c69efe0bb1"
replace today_end="2017-12-23T11:38:00-05:00" if interview__id=="fe812af74e7a43e1a7a0d6c69efe0bb1"
*01/01/2017
replace today="2018-01-01T06:45:00-05:00" if interview__id=="4b1c3a66583e4b15a34861c0055d0320"
replace today_end="2018-01-01T11:58:00-05:00" if interview__id=="4b1c3a66583e4b15a34861c0055d0320"
replace today="2018-01-01T05:36:00-05:00" if interview__id=="b11eccc4400946fa894cc5b1399b2450"
replace today_end="2018-01-01T15:12:00-05:00" if interview__id=="b11eccc4400946fa894cc5b1399b2450"
replace today="2018-01-01T01:31:00-05:00" if interview__id=="6aef634b8f6e4cada636d40aa9913618"
replace today_end="2018-01-01T08:00:00-05:00" if interview__id=="6aef634b8f6e4cada636d40aa9913618"
replace today="2018-01-01T02:02:00-05:00" if interview__id=="6ade7c566cf74faebf0645e6f256c931"
replace today_end="2018-01-01T11:24:00-05:00" if interview__id=="6ade7c566cf74faebf0645e6f256c931"
replace today="2018-01-01T15:05:00-05:00" if interview__id=="55f95866bd9a4f0e92af41cfaf9df781"
replace today_end="2018-01-01T23:01:00-05:00" if interview__id=="55f95866bd9a4f0e92af41cfaf9df781"
replace today="2018-01-01T01:30:00-05:00" if interview__id=="b1b12de8427d4c17b8de80f9a2e893e5"
replace today_end="2018-01-01T10:31:00-05:00" if interview__id=="b1b12de8427d4c17b8de80f9a2e893e5"
replace today="2018-01-01T02:10:00-05:00" if interview__id=="cf7d796d2b254b7a95fa595350683f82"
replace today_end="2018-01-01T05:58:00-05:00" if interview__id=="cf7d796d2b254b7a95fa595350683f82"
replace today="2018-01-01T02:11:00-05:00" if interview__id=="2bb341a976c84a0e9ef1dc3d3b4e5a08"
replace today_end="2018-01-01T06:48:00-05:00" if interview__id=="2bb341a976c84a0e9ef1dc3d3b4e5a08"

*Identify observations with missing dates
*br if today == "##N/A##"
*br if today_end=="##N/A##" & consent==1

*** Incorrect duration cleaning (cases of incorrect date and time records)
*Correcting when incorrect duration using dates and times in metadata
*04/12/2017
replace today="2017-12-04T04:59:24-05:00" if interview__id=="7a11a820379040bd88ce2a0d95290e36"
replace today_end="2017-12-04T07:29:43-05:00" if interview__id=="7a11a820379040bd88ce2a0d95290e36"
replace today="2017-12-04T06:41:17-05:00" if interview__id=="cd8ffe5ee7c443e1890017e0b484c7a2"
replace today_end="2017-12-04T08:18:23-05:00" if interview__id=="cd8ffe5ee7c443e1890017e0b484c7a2"
*07/12/2017
replace today="2017-12-07T06:00:33-05:00" if interview__id=="0007fa06851e40d7b95e88aba3b4bbae"
replace today_end="2017-12-07T12:57:13-05:00" if interview__id=="0007fa06851e40d7b95e88aba3b4bbae"
*08/12/2017
replace today="2017-12-07T08:33:33-05:00" if interview__id=="bc4db104c42c47e6a9900bb077434b64"
replace today_end="2017-12-07T11:40:13-05:00" if interview__id=="bc4db104c42c47e6a9900bb077434b64"
*09/12/2017
replace today= "2017-12-09T07:04:08-05:00" if interview__id=="0040b8bcedaa4b7ebe566dbdfbaad6a9"
replace today_end= "2017-12-09T09:01:56-05:00" if interview__id=="0040b8bcedaa4b7ebe566dbdfbaad6a9"
replace today= "2017-12-09T08:05:27-05:00" if interview__id=="fcfa1148a1564d8ba787103b55b0a006"
replace today_end= "2017-12-09T16:18:29-05:00" if interview__id=="fcfa1148a1564d8ba787103b55b0a006"
replace today= "2017-12-09T08:05:31-05:00" if interview__id=="f06de7d9133a43b6b2de3255315a921d"
replace today_end= "2017-12-09T10:44:43-05:00" if interview__id=="f06de7d9133a43b6b2de3255315a921d"
*10/12/2017
replace today= "2017-12-10T06:21:31-05:00" if interview__id=="a71bf037b464456bab307410b71c3329"
replace today_end= "2017-12-10T09:09:25-05:00" if interview__id=="a71bf037b464456bab307410b71c3329"
*11/12/2017
replace today= "2017-12-11T07:32:44-05:00" if interview__id=="738f3c5acfc24deb832eec22b4212862"
replace today_end= "2017-12-11T09:07:02-05:00" if interview__id=="738f3c5acfc24deb832eec22b4212862"
*12/12/2017
replace today="2017-12-12T06:26:20-05:00" if interview__id=="17ca0b073b3542e88ed06ff9ba76654d"
replace today_end="2017-12-12T08:49:41-05:00" if interview__id=="17ca0b073b3542e88ed06ff9ba76654d"
*13/12/2017
replace today="2017-12-13T08:48:41-05:00" if interview__id=="8b6af7e522d04aa9b5c6248ecc704f41"
replace today_end="2017-12-13T11:05:58-05:00" if interview__id=="8b6af7e522d04aa9b5c6248ecc704f41"
*15/12/2017
replace today="2017-12-15T09:04:41-05:00" if interview__id=="7612a0d81d9143e9a6ffbd14a4c0665b"
replace today_end="2017-12-15T12:10:58-05:00" if interview__id=="7612a0d81d9143e9a6ffbd14a4c0665b"
*19/12/2017
replace today="2017-12-19T09:54:00-05:00" if interview__id=="c582db0537c54ba888bdfa355a561be1"
replace today_end="2017-12-19T12:23:00-05:00" if interview__id=="c582db0537c54ba888bdfa355a561be1"
*20/12/2017
replace today="2017-12-20T04:24:00-05:00" if interview__id=="6732c86d57ef4e40b67c1e9f1c23aead"
replace today_end="2017-12-20T08:24:00-05:00" if interview__id=="6732c86d57ef4e40b67c1e9f1c23aead"
replace today="2017-12-20T03:38:44-05:00" if interview__id=="35054f64a9a04b1d9db73a9f175f717f"
replace today_end="2017-12-20T07:34:18-05:00" if interview__id=="35054f64a9a04b1d9db73a9f175f717f"
*25/12/2017
replace today="2017-12-25T07:06:44-05:00" if interview__id=="ef2484b1cdf84e01843d36f9ded1e360"
replace today_end="2017-12-25T08:57:18-05:00" if interview__id=="ef2484b1cdf84e01843d36f9ded1e360"
*31/12/2017
replace today="2017-12-31T10:10:44-05:00" if interview__id=="6c3df683a9a245bd90d99fe26707cec6"
replace today_end="2017-12-31T15:11:18-05:00" if interview__id=="6c3df683a9a245bd90d99fe26707cec6"
*01/01/2018
replace today="2018-01-01T06:30:00-05:00" if interview__id=="23324ca301c641688995b14acdb44e62"
replace today_end="2018-01-01T08:34:00-05:00" if interview__id=="23324ca301c641688995b14acdb44e62"
*02/01/2018
replace today="2018-01-02T09:00:00-05:00" if interview__id=="476ec0acbaf242508419d335a8253bf9"
replace today_end="2018-01-02T17:05:00-05:00" if interview__id=="476ec0acbaf242508419d335a8253bf9"
replace today="2018-01-02T04:30:00-05:00" if interview__id=="cc4d0f173def439d8db9a5be123ca293"
replace today_end="2018-01-02T06:41:00-05:00" if interview__id=="cc4d0f173def439d8db9a5be123ca293"
replace today="2018-01-02T05:51:00-05:00" if interview__id=="f1b682bfb3f3413d8a76fbd77d660513"
replace today_end="2018-01-02T07:46:00-05:00" if interview__id=="f1b682bfb3f3413d8a76fbd77d660513"
replace today="2018-01-02T01:30:00-05:00" if interview__id=="e76fca3e794a483ca01d794e3fceae93"
replace today_end="2018-01-02T08:45:00-05:00" if interview__id=="e76fca3e794a483ca01d794e3fceae93"
replace today="2018-01-02T09:54:00-05:00" if interview__id=="8c26d5f23c1942b584201b7d654c376e"
replace today_end="2018-01-02T12:22:00-05:00" if interview__id=="8c26d5f23c1942b584201b7d654c376e"
replace today="2018-01-02T01:35:00-05:00" if interview__id=="c70d82af781142778c4e424063a4014f"
replace today_end="2018-01-02T04:15:00-05:00" if interview__id=="c70d82af781142778c4e424063a4014f"
replace today="2018-01-02T06:26:00-05:00" if interview__id=="2221db66006144f8b8292b223a795bb9"
replace today_end="2018-01-02T08:45:00-05:00" if interview__id=="2221db66006144f8b8292b223a795bb9"
replace today="2018-01-02T06:47:00-05:00" if interview__id=="6d99d0fc90184f8297059b537fe36898"
replace today_end="2018-01-02T08:23:00-05:00" if interview__id=="6d99d0fc90184f8297059b537fe36898"
replace today="2018-01-02T01:40:00-05:00" if interview__id=="47664c2f16d0430aa9f9099b46b4fc11"
replace today_end="2018-01-02T04:06:00-05:00" if interview__id=="47664c2f16d0430aa9f9099b46b4fc11"
replace today="2018-01-02T01:38:00-05:00" if interview__id=="b5183bb96f9a401f90531d1d48fb6aa4"
replace today_end="2018-01-02T04:08:00-05:00" if interview__id=="b5183bb96f9a401f90531d1d48fb6aa4"
*03/01/2018
replace today="2018-01-03T05:52:00-05:00" if interview__id=="d47baaf87f90474e8278253d9a04f478"
replace today_end="2018-01-03T07:54:00-05:00" if interview__id=="d47baaf87f90474e8278253d9a04f478"
replace today="2018-01-03T07:25:00-05:00" if interview__id=="73f1638c6c4e44bb87ac5f1731b4cb46"
replace today_end="2018-01-03T10:20:00-05:00" if interview__id=="73f1638c6c4e44bb87ac5f1731b4cb46"
replace today="2018-01-03T05:30:00-05:00" if interview__id=="adc3ebf4586f4a8a90fe88da858b5b83"
replace today_end="2018-01-03T11:03:00-05:00" if interview__id=="adc3ebf4586f4a8a90fe88da858b5b83"
replace today="2018-01-03T03:00:00-05:00" if interview__id=="a484de3859fb4d968892fe7e9a3eea32"
replace today_end="2018-01-03T05:05:00-05:00" if interview__id=="a484de3859fb4d968892fe7e9a3eea32"
replace today="2018-01-03T00:00:00-05:00" if interview__id=="8fbca5832f93480c93736bef22c5e1c5"
replace today_end="2018-01-03T03:00:00-05:00" if interview__id=="8fbca5832f93480c93736bef22c5e1c5"
replace today="2018-01-03T07:50:00-05:00" if interview__id=="b54c2182a0e34164a8cf6a6f757e2669"
replace today_end="2018-01-03T10:31:00-05:00" if interview__id=="b54c2182a0e34164a8cf6a6f757e2669"
replace today="2018-01-03T06:16:00-05:00" if interview__id=="8a47780306ae405185e1ac9d897b089b"
replace today_end="2018-01-03T08:46:00-05:00" if interview__id=="8a47780306ae405185e1ac9d897b089b"
replace today="2018-01-03T09:20:00-05:00" if interview__id=="719c42eec93947c7ab2e047c769b8909"
replace today_end="2018-01-03T12:03:00-05:00" if interview__id=="719c42eec93947c7ab2e047c769b8909"
replace today="2018-01-03T07:44:00-05:00" if interview__id=="ffedf5dc45b84afbb5bb8b2dc6e7d268"
replace today_end="2018-01-03T09:46:00-05:00" if interview__id=="ffedf5dc45b84afbb5bb8b2dc6e7d268"
*04/01/2018
replace today="2018-01-04T05:57:00-05:00" if interview__id=="0752f71a4e58494597a3258d3a24d916"
replace today_end="2018-01-04T07:59:00-05:00" if interview__id=="0752f71a4e58494597a3258d3a24d916"
replace today="2018-01-04T07:30:00-05:00" if interview__id=="001fee1a316e496d9bd0f7552d3a95ff"
replace today_end="2018-01-04T09:29:00-05:00" if interview__id=="001fee1a316e496d9bd0f7552d3a95ff"
replace today="2018-01-04T07:00:00-05:00" if interview__id=="69d5667ba52e403aa225b4dc8d02aa6a"
replace today_end="2018-01-04T09:13:00-05:00" if interview__id=="69d5667ba52e403aa225b4dc8d02aa6a"
replace today="2018-01-04T06:53:00-05:00" if interview__id=="826603590bbd441f949050dafa651670"
replace today_end="2018-01-04T08:55:00-05:00" if interview__id=="826603590bbd441f949050dafa651670"
replace today="2018-01-04T02:27:00-05:00" if interview__id=="d970d09dad184ac8adf8ff3cf2c9d87a"
replace today_end="2018-01-04T04:30:00-05:00" if interview__id=="d970d09dad184ac8adf8ff3cf2c9d87a"
replace today="2018-01-04T07:47:00-05:00" if interview__id=="c1d3bbaed3194aada04d2afdc44e96df"
replace today_end="2018-01-04T09:19:00-05:00" if interview__id=="c1d3bbaed3194aada04d2afdc44e96df"
replace today="2018-01-04T02:05:00-05:00" if interview__id=="05e44ab2faeb4dd6843ea9d1c54d6cdf"
replace today_end="2018-01-04T04:49:00-05:00" if interview__id=="05e44ab2faeb4dd6843ea9d1c54d6cdf"
replace today="2018-01-04T07:36:00-05:00" if interview__id=="53d2c386f8484819b7a5132c2dde1347"
replace today_end="2018-01-04T09:20:00-05:00" if interview__id=="53d2c386f8484819b7a5132c2dde1347"
replace today="2018-01-04T06:56:00-05:00" if interview__id=="24aa5a458f1f401d8c55b916944d88df"
replace today_end="2018-01-04T08:51:00-05:00" if interview__id=="24aa5a458f1f401d8c55b916944d88df"
replace today="2018-01-04T13:30:00-05:00" if interview__id=="56c7e195e98a4e05b0ebda323fb54718"
replace today_end="2018-01-04T15:42:00-05:00" if interview__id=="56c7e195e98a4e05b0ebda323fb54718"
replace today="2018-01-04T11:06:00-05:00" if interview__id=="94886f73b7e5471a97c05ae90433dc7d"
replace today_end="2018-01-04T15:39:00-05:00" if interview__id=="94886f73b7e5471a97c05ae90433dc7d"
replace today="2018-01-04T13:05:00-05:00" if interview__id=="ec5041fb8abf4e139015a21f257edf7f"
replace today_end="2018-01-04T15:27:00-05:00" if interview__id=="ec5041fb8abf4e139015a21f257edf7f"
replace today="2018-01-04T14:06:00-05:00" if interview__id=="5ca56f36738b4d3b9a7c21816a53a833"
replace today_end="2018-01-04T15:38:00-05:00" if interview__id=="5ca56f36738b4d3b9a7c21816a53a833"
replace today="2018-01-04T09:14:00-05:00" if interview__id=="7e828b8f766e47559ff738e706d88190"
replace today_end="2018-01-04T11:25:00-05:00" if interview__id=="7e828b8f766e47559ff738e706d88190"
*05/01/2018
replace today="2018-01-05T05:30:00-05:00" if interview__id=="8375fd01346142589fae3a34bc21607b"
replace today_end="2018-01-05T08:06:00-05:00" if interview__id=="8375fd01346142589fae3a34bc21607b"
replace today="2018-01-05T07:46:00-05:00" if interview__id=="24a1f952aa6f40f48035987385406179"
replace today_end="2018-01-05T09:11:00-05:00" if interview__id=="24a1f952aa6f40f48035987385406179"
replace today="2018-01-05T05:30:00-05:00" if interview__id=="9878cbc70ac144c8835d406799803846"
replace today_end="2018-01-05T08:06:00-05:00" if interview__id=="9878cbc70ac144c8835d406799803846"
replace today="2018-01-05T05:44:00-05:00" if interview__id=="ce0db1a30d3d41b18eb9986a6bedee1e"
replace today_end="2018-01-05T08:07:00-05:00" if interview__id=="ce0db1a30d3d41b18eb9986a6bedee1e"
replace today="2018-01-05T05:47:00-05:00" if interview__id=="7f573a27880847dabd22c6ce543a9427"
replace today_end="2018-01-05T08:19:00-05:00" if interview__id=="7f573a27880847dabd22c6ce543a9427"
replace today="2018-01-05T05:30:00-05:00" if interview__id=="698f5d6678db4a76a0010c3c9cd227ff"
replace today_end="2018-01-05T14:20:00-05:00" if interview__id=="698f5d6678db4a76a0010c3c9cd227ff"
replace today="2018-01-05T05:30:00-05:00" if interview__id=="9b5658dc2ea846f9997e98770930fdfe"
replace today_end="2018-01-05T09:22:00-05:00" if interview__id=="9b5658dc2ea846f9997e98770930fdfe"
replace today="2018-01-05T08:27:00-05:00" if interview__id=="85588fceefdf42a7b42bd3158d4446ad"
replace today_end="2018-01-05T10:34:00-05:00" if interview__id=="85588fceefdf42a7b42bd3158d4446ad"
replace today="2018-01-05T06:41:00-05:00" if interview__id=="c12e1940af7b45a9bb82cf67bdc68366"
replace today_end="2018-01-05T11:09:00-05:00" if interview__id=="c12e1940af7b45a9bb82cf67bdc68366"
*06/01/2018
replace today="2018-01-06T05:45:00-05:00" if interview__id=="65cf420aac3a41a4bb1148dbac13e796"
replace today_end="2018-01-06T08:18:00-05:00" if interview__id=="65cf420aac3a41a4bb1148dbac13e796"
replace today="2018-01-06T05:42:00-05:00" if interview__id=="442b34d2030a4b77bcbd6aee97109b71"
replace today_end="2018-01-06T07:48:00-05:00" if interview__id=="442b34d2030a4b77bcbd6aee97109b71"
replace today="2018-01-06T06:15:00-05:00" if interview__id=="3b896cce9e4d4b088a097277ed9188bd"
replace today_end="2018-01-06T08:19:00-05:00" if interview__id=="3b896cce9e4d4b088a097277ed9188bd"
replace today="2018-01-06T05:49:00-05:00" if interview__id=="f86aac8ca70e4fbf917189e4259470b5"
replace today_end="2018-01-06T12:06:00-05:00" if interview__id=="f86aac8ca70e4fbf917189e4259470b5"
replace today="2018-01-06T06:22:00-05:00" if interview__id=="ecbbfb6063b74270a84b519bf813c26c"
replace today_end="2018-01-06T09:05:00-05:00" if interview__id=="ecbbfb6063b74270a84b519bf813c26c"
replace today="2018-01-06T01:00:00-05:00" if interview__id=="88704877071b42ef9083c14d3e38ee53"
replace today_end="2018-01-06T03:10:00-05:00" if interview__id=="88704877071b42ef9083c14d3e38ee53"
replace today="2018-01-06T08:05:00-05:00" if interview__id=="2025f2024c3e4f0fa08027a5190daddd"
replace today_end="2018-01-06T10:10:00-05:00" if interview__id=="2025f2024c3e4f0fa08027a5190daddd"
replace today="2018-01-06T05:24:00-05:00" if interview__id=="51f035f7afca4fd4bbbd1c1bb35a4896"
replace today_end="2018-01-06T08:38:00-05:00" if interview__id=="51f035f7afca4fd4bbbd1c1bb35a4896"
replace today="2018-01-06T05:34:00-05:00" if interview__id=="85a04f50a64e419a850efcc180535e58"
replace today_end="2018-01-06T08:04:00-05:00" if interview__id=="85a04f50a64e419a850efcc180535e58"
replace today="2018-01-06T08:52:00-05:00" if interview__id=="b4fa4bf2047140b7b76e9f3fc830ab7c"
replace today_end="2018-01-06T11:00:00-05:00" if interview__id=="b4fa4bf2047140b7b76e9f3fc830ab7c"
replace today="2018-01-06T05:32:00-05:00" if interview__id=="5797622920474f37b879a5ae982917c1"
replace today_end="2018-01-06T08:01:00-05:00" if interview__id=="5797622920474f37b879a5ae982917c1"
replace today="2018-01-06T05:43:00-05:00" if interview__id=="f696f715b4b341659a3e63d24160b0fa"
replace today_end="2018-01-06T15:02:00-05:00" if interview__id=="f696f715b4b341659a3e63d24160b0fa"
replace today="2018-01-06T02:04:00-05:00" if interview__id=="f96912013eb2486783ac32187fef1e2a"
replace today_end="2018-01-06T04:21:00-05:00" if interview__id=="f96912013eb2486783ac32187fef1e2a"
replace today="2018-01-06T02:56:00-05:00" if interview__id=="f6b4414fef5e4d6baae3762859f8c1a2"
replace today_end="2018-01-06T07:45:00-05:00" if interview__id=="f6b4414fef5e4d6baae3762859f8c1a2"
replace today="2018-01-06T10:04:00-05:00" if interview__id=="66abaeedc77740c5815043c8c2bfc525"
replace today_end="2018-01-06T12:10:00-05:00" if interview__id=="66abaeedc77740c5815043c8c2bfc525"
replace today="2018-01-06T07:25:00-05:00" if interview__id=="52fab39f840e49c29e98c7a7126286b1"
replace today_end="2018-01-06T09:20:00-05:00" if interview__id=="52fab39f840e49c29e98c7a7126286b1"
replace today="2018-01-06T08:52:00-05:00" if interview__id=="b4fa4bf2047140b7b76e9f3fc830ab7c"
replace today_end="2018-01-06T10:50:00-05:00" if interview__id=="b4fa4bf2047140b7b76e9f3fc830ab7c"
*07/01/2018
replace today="2018-01-07T05:41:00-05:00" if interview__id=="2afc031133ff45d28d3b242f85d0d652"
replace today_end="2018-01-07T07:52:00-05:00" if interview__id=="2afc031133ff45d28d3b242f85d0d652"
replace today="2018-01-07T05:52:00-05:00" if interview__id=="6e5abf9fd4c04f62932bbeca2ab206f1"
replace today_end="2018-01-07T07:53:00-05:00" if interview__id=="6e5abf9fd4c04f62932bbeca2ab206f1"
replace today="2018-01-07T07:53:00-05:00" if interview__id=="939d0e9ce34b4484bca1e2b49c94bca5"
replace today_end="2018-01-07T13:02:00-05:00" if interview__id=="939d0e9ce34b4484bca1e2b49c94bca5"
replace today="2018-01-07T05:25:00-05:00" if interview__id=="1f75e5308af748e9bce5adf39a10179b"
replace today_end="2018-01-07T07:51:00-05:00" if interview__id=="1f75e5308af748e9bce5adf39a10179b"
replace today="2018-01-07T06:15:00-05:00" if interview__id=="622155b3321f4f4397f863a5f3bb59ed"
replace today_end="2018-01-07T09:25:00-05:00" if interview__id=="622155b3321f4f4397f863a5f3bb59ed"
replace today="2018-01-07T18:16:00-05:00" if interview__id=="15b13f600f714a828a392ae1f2b17781"
replace today_end="2018-01-07T20:25:00-05:00" if interview__id=="15b13f600f714a828a392ae1f2b17781"
replace today="2018-01-07T01:23:00-05:00" if interview__id=="baf034edf82a4d4690450c3ad42a8596"
replace today_end="2018-01-07T03:30:00-05:00" if interview__id=="baf034edf82a4d4690450c3ad42a8596"
replace today="2018-01-07T05:41:00-05:00" if interview__id=="2198b9e6e9e84c58b2645fdf409f2ce9"
replace today_end="2018-01-07T07:58:00-05:00" if interview__id=="2198b9e6e9e84c58b2645fdf409f2ce9"
replace today="2018-01-07T05:55:00-05:00" if interview__id=="325c7e27b5a449fd96defe7a2c039ed3"
replace today_end="2018-01-07T08:01:00-05:00" if interview__id=="325c7e27b5a449fd96defe7a2c039ed3"
replace today="2018-01-07T02:02:00-05:00" if interview__id=="be7401a804774c9990c7a3c631658bac"
replace today_end="2018-01-07T04:04:00-05:00" if interview__id=="be7401a804774c9990c7a3c631658bac"
replace today="2018-01-07T06:45:00-05:00" if interview__id=="fe3b81362084492db86876ce6760d06e"
replace today_end="2018-01-07T08:20:00-05:00" if interview__id=="fe3b81362084492db86876ce6760d06e"
replace today="2018-01-07T07:55:00-05:00" if interview__id=="3d1bfdf9c0cc43aaafb1eb4726fd7a3f"
replace today_end="2018-01-07T10:30:00-05:00" if interview__id=="3d1bfdf9c0cc43aaafb1eb4726fd7a3f"
replace today="2018-01-07T00:00:00-05:00" if interview__id=="16b5160a0d444b3ead7cc63ecb84460c"
replace today_end="2018-01-07T02:11:00-05:00" if interview__id=="16b5160a0d444b3ead7cc63ecb84460c"
replace today="2018-01-07T12:13:00-05:00" if interview__id=="e3b5635882194490ba728fed08bd1b3b"
replace today_end="2018-01-07T14:20:00-05:00" if interview__id=="e3b5635882194490ba728fed08bd1b3b"
replace today="2018-01-07T05:30:00-05:00" if interview__id=="4220853f0457418bb4d934b3ef6d798b"
replace today_end="2018-01-07T07:45:00-05:00" if interview__id=="4220853f0457418bb4d934b3ef6d798b"
replace today="2018-01-07T13:23:00-05:00" if interview__id=="7c3471d05d2b41f587844a8a57720203"
replace today_end="2018-01-07T16:19:00-05:00" if interview__id=="7c3471d05d2b41f587844a8a57720203"
*08/01/2018
replace today="2018-01-08T14:20:00-05:00" if interview__id=="8de29082cc934b339a6feb7f74ebd44f"
replace today_end="2018-01-08T16:19:00-05:00" if interview__id=="8de29082cc934b339a6feb7f74ebd44f"
replace today="2018-01-08T02:00:00-05:00" if interview__id=="7227c62e2512444bbc18449fe634a15e"
replace today_end="2018-01-08T04:30:00-05:00" if interview__id=="7227c62e2512444bbc18449fe634a15e"
replace today="2018-01-08T10:30:00-05:00" if interview__id=="33e126701e154a7e840177304d35fabb"
replace today_end="2018-01-08T12:30:00-05:00" if interview__id=="33e126701e154a7e840177304d35fabb"
replace today="2018-01-08T02:13:00-05:00" if interview__id=="eaa06e99b0b9495190f1a563d2e3e54f"
replace today_end="2018-01-08T04:31:00-05:00" if interview__id=="eaa06e99b0b9495190f1a563d2e3e54f"
replace today="2018-01-08T09:49:00-05:00" if interview__id=="3d756a8798164acfbb0faf08d61ff3f2"
replace today_end="2018-01-08T11:51:00-05:00" if interview__id=="3d756a8798164acfbb0faf08d61ff3f2"
*09/01/2018
replace today="2018-01-09T05:31:00-05:00" if interview__id=="1962e1b730344a97acf2c4e975577c92"
replace today_end="2018-01-09T12:33:00-05:00" if interview__id=="1962e1b730344a97acf2c4e975577c92"
replace today="2018-01-09T07:01:00-05:00" if interview__id=="7f308aca79a24534ab6305a8397ac835"
replace today_end="2018-01-09T08:22:00-05:00" if interview__id=="7f308aca79a24534ab6305a8397ac835"
replace today="2018-01-09T20:08:00-05:00" if interview__id=="4d8019e436394ad8a6bb68bec7136616"
replace today_end="2018-01-09T22:16:00-05:00" if interview__id=="4d8019e436394ad8a6bb68bec7136616"
replace today="2018-01-09T01:00:00-05:00" if interview__id=="bb0aeb256bcb46aa928f8fc8619973b9"
replace today_end="2018-01-09T04:00:00-05:00" if interview__id=="bb0aeb256bcb46aa928f8fc8619973b9"
replace today="2018-01-09T06:48:00-05:00" if interview__id=="1946e34f4075457e8276a1f2461d98ed"
replace today_end="2018-01-09T08:09:00-05:00" if interview__id=="1946e34f4075457e8276a1f2461d98ed"
replace today="2018-01-09T06:45:00-05:00" if interview__id=="281e7a1891d043618f78778f527a4417"
replace today_end="2018-01-09T08:00:00-05:00" if interview__id=="281e7a1891d043618f78778f527a4417"
replace today="2018-01-09T16:01:00-05:00" if interview__id=="9eb99b0ad5554299b71b55337ff91caa"
replace today_end="2018-01-09T17:08:00-05:00" if interview__id=="9eb99b0ad5554299b71b55337ff91caa"
replace today="2018-01-09T07:17:00-05:00" if interview__id=="41d3491546cd430c8d29519d1a5b5e11"
replace today_end="2018-01-09T09:00:00-05:00" if interview__id=="41d3491546cd430c8d29519d1a5b5e11"
replace today="2018-01-09T16:14:00-05:00" if interview__id=="435fd0e0c2f3437f9b06a7d78c0d2681"
replace today_end="2018-01-09T17:49:00-05:00" if interview__id=="435fd0e0c2f3437f9b06a7d78c0d2681"
replace today="2018-01-09T10:30:00-05:00" if interview__id=="a6fed9266e7e4230be6e51075866baf0"
replace today_end="2018-01-09T12:19:00-05:00" if interview__id=="a6fed9266e7e4230be6e51075866baf0"
replace today="2018-01-09T02:10:00-05:00" if interview__id=="8747b09031444363ad92ed80c2773417"
replace today_end="2018-01-09T04:25:00-05:00" if interview__id=="8747b09031444363ad92ed80c2773417"
*10/01/2018
replace today="2018-01-10T16:10:00-05:00" if interview__id=="c4e7e3a4ee90418a92aa8c9d2bd23aee"
replace today_end="2018-01-10T18:25:00-05:00" if interview__id=="c4e7e3a4ee90418a92aa8c9d2bd23aee"
*11/01/2018
replace today="2018-01-11T08:10:00-05:00" if interview__id=="bd095a7336024ff09f40881703b99212"
replace today_end="2018-01-11T10:20:00-05:00" if interview__id=="bd095a7336024ff09f40881703b99212"
replace today="2018-01-11T10:10:00-05:00" if interview__id=="acda2da1a2d149f0bc5f13764e111510"
replace today_end="2018-01-11T12:25:00-05:00" if interview__id=="acda2da1a2d149f0bc5f13764e111510"
replace today="2018-01-11T09:10:00-05:00" if interview__id=="f877a6667fa84cb9ab3ce3e8d41e8a63"
replace today_end="2018-01-11T11:20:00-05:00" if interview__id=="f877a6667fa84cb9ab3ce3e8d41e8a63"
replace today="2018-01-11T12:30:00-05:00" if interview__id=="f647ed100055470981099832ce86abc8"
replace today_end="2018-01-11T14:30:00-05:00" if interview__id=="f647ed100055470981099832ce86abc8"
replace today="2018-01-11T14:45:00-05:00" if interview__id=="84c3db7bb3704ff4b639b0ab46cd3dfb"
replace today_end="2018-01-11T16:55:00-05:00" if interview__id=="84c3db7bb3704ff4b639b0ab46cd3dfb"
replace today="2018-01-11T15:14:00-05:00" if interview__id=="a4fda1d304a94304ba042380dd7d6fef"
replace today_end="2018-01-11T17:16:00-05:00" if interview__id=="a4fda1d304a94304ba042380dd7d6fef"
*12/01/2018
replace today="2018-01-12T08:30:08-05:00" if interview__id=="cfbe07bb35c447cd8f5d083a5ddf38c7"
replace today_end="2018-01-12T11:10:00-05:00" if interview__id=="cfbe07bb35c447cd8f5d083a5ddf38c7"
replace today="2018-01-12T08:15:39-05:00" if interview__id=="142a5e63bb9e479788d87216ca2b3ae0"
replace today_end="2018-01-12T10:25:00-05:00" if interview__id=="142a5e63bb9e479788d87216ca2b3ae0"
replace today="2018-01-12T08:10:00-05:00" if interview__id=="4e48a5fda5c84ca398ca537fae2f3a8f"
replace today_end="2018-01-12T10:50:00-05:00" if interview__id=="4e48a5fda5c84ca398ca537fae2f3a8f"
replace today="2018-01-12T08:40:00-05:00" if interview__id=="5dac6d7dfb6a40d591ba8926a1b05301"
replace today_end="2018-01-12T10:55:00-05:00" if interview__id=="5dac6d7dfb6a40d591ba8926a1b05301"
replace today="2018-01-12T08:10:00-05:00" if interview__id=="6a8a63fddd0f4209bc67f151a2589438"
replace today_end="2018-01-12T10:25:00-05:00" if interview__id=="6a8a63fddd0f4209bc67f151a2589438"
*16/01/2018
replace today="2018-01-16T08:35:08-05:00" if interview__id=="ba41d1ba40c942ccbfff8f4c5af35c14"
replace today_end="2018-01-16T10:35:00-05:00" if interview__id=="ba41d1ba40c942ccbfff8f4c5af35c14"


*Creating duration variable
*Start time 
g start_time_temp = ""
replace start_time_temp = subinstr(today,"T"," ",.)
replace start_time_temp = subinstr(start_time_temp,"-05:00","",.)
gen double start_time = clock(start_time_temp, "YMDhms")
format start_time %tc
label var start_time "Date and time at which the interview started"

*End time
g end_time_temp = ""
replace end_time_temp = subinstr(today_end,"T"," ",.)
replace end_time_temp = subinstr(end_time_temp,"-05:00","",.)
gen double end_time = clock(end_time_temp, "YMDhms")
format end_time %tc
label var end_time "Date and time at which the interview ended"
drop start_time_temp end_time_temp

*Computing duration only only for successful interviews, and if the interview was conducted without breaks
g duration_itw_min = minutes(end_time - start_time) if int_break == 1
label var duration_itw_min "Duration of interview (minutes)" 

*Identify observations with incorrect duration
*br if duration_itw_min < 30

*** Saving dataset with manual corrections
save "${gsdData}/0-RawTemp/hh_manual_cleaning.dta", replace


***** PART 2: NOMADS

*** Importing questionnaire
** Version 1
use "${gsdDownloads}/Nomads - v1/Somali High Frequency Survey - Wave 2 - Nomads - Fieldwork", clear
decode enum_id, g(enum_name)
label drop enum_id
tostring *_spec, replace
tostring *_sp, replace
tostring toilet_ot, replace
tostring land_use_disp_s, replace
tostring rl_other, replace
tostring *_specify, replace
tostring housingtype_s, replace
tostring  housingtype_disp_s, replace
tostring land_unit_spec_disp, replace
save "${gsdTemp}/hh_append_v1_nomads", replace

** Version 2
use "${gsdDownloads}/Nomads - v2/Somali High Frequency Survey - Wave 2 - Nomads - Fieldwork", clear
decode enum_id, g(enum_name)
label drop enum_id
tostring *_spec, replace
tostring *_sp, replace
tostring *_specify, replace
tostring loc_retry__Timestamp, replace
tostring housingtype_disp_s, replace
tostring hh_list_separated__*, replace
tostring toilet_ot, replace
tostring land_use_disp_s, replace
tostring rl_other, replace
tostring disp_date, replace
tostring disp_arrive_date, replace
tostring land_unit_spec_disp, replace
save "${gsdTemp}/hh_append_v2_nomads", replace

** Version 4
use "${gsdDownloads}/Nomads - v4/Somali High Frequency Survey - Wave 2 - Nomads - Fieldwork", clear
decode enum_id, g(enum_name)
label drop enum_id
tostring *_spec, replace
tostring *_sp, replace
tostring *_specify, replace
tostring loc_retry__Timestamp, replace
tostring housingtype_disp_s, replace
tostring hh_list_separated__*, replace
tostring toilet_ot, replace
tostring land_use_disp_s, replace
tostring rl_other, replace
tostring disp_date, replace
tostring disp_arrive_date, replace
save "${gsdTemp}/hh_append_v4_nomads", replace

** Append all versions
* Main dataset
use "${gsdTemp}/hh_append_v1_nomads", clear
append using "${gsdTemp}/hh_append_v2_nomads"
append using "${gsdTemp}/hh_append_v4_nomads"
save "${gsdTemp}/hh_append_nomads", replace

*Rosters
local files hh_roster_separated hhroster_age motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
foreach file in `files' {
	use "${gsdDownloads}/Nomads - v1/`file'", clear
	tostring interview__id, replace
	tostring interview__key, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring ra_namelp_prev, replace
	capture: tostring rl_give_reason_o, replace
	capture: tostring hhm_relation_sep_s, replace
	capture: tostring rl_lose_reason_o, replace
	capture: tostring rnf_free_other, replace
	save "${gsdTemp}/`file'_append_v1_nomads", replace
	
	use "${gsdDownloads}/Nomads - v2/`file'", clear
	tostring interview__id, replace
	tostring interview__key, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring hhm_edu_level_other, replace
	capture: tostring hhm_relation_sep_s, replace
	capture: tostring rl_lose_reason_o, replace
	capture: tostring hh_list_separated, replace
	capture: tostring hhm_relation_other, replace
	capture: tostring ra_namelp_prev, replace
	capture: tostring rl_give_reason_o, replace
	capture: tostring hh_list, replace
	capture: tostring ra_namelp, replace
	capture: tostring ra_ynew, replace
	capture: tostring rnf_item_recall, replace
	capture: tostring rnf_free_other, replace
	save "${gsdTemp}/`file'_append_v2_nomads", replace
	
	use "${gsdDownloads}/Nomads - v4/`file'", clear
	tostring interview__id, replace
	tostring interview__key, replace
	capture: tostring *_spec, replace
	capture: tostring *_sp, replace
	capture: tostring *_specify, replace
	capture: tostring hhm_edu_level_other, replace
	capture: tostring hhm_relation_sep_s, replace
	capture: tostring rl_lose_reason_o, replace
	capture: tostring hh_list_separated, replace
	capture: tostring hhm_relation_other, replace
	capture: tostring ra_namelp_prev, replace
	capture: tostring rl_give_reason_o, replace
	capture: tostring hh_list, replace
	capture: tostring ra_namelp, replace
	capture: tostring ra_ynew, replace
	capture: tostring rnf_item_recall, replace
	save "${gsdTemp}/`file'_append_v4_nomads", replace
	
	use "${gsdTemp}/`file'_append_v1_nomads", clear
	append using "${gsdTemp}/`file'_append_v2_nomads"
	append using "${gsdTemp}/`file'_append_v4_nomads"
	save "${gsdTemp}/`file'_append_nomads", replace
}

use "${gsdTemp}/hh_append_nomads", clear

**** Dropping empty observations in all datasets (main + rosters)
* Main dataset
drop if interview__id=="f14c77213f0642ff825041f4923143f2"
save "${gsdTemp}/hh_without_empty_obs_nomads", replace

* Rosters
local files hh_roster_separated hhroster_age motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
foreach file in `files' {
	use "${gsdTemp}/`file'_append_nomads", clear
	tostring interview__id, replace
	drop if interview__id=="f14c77213f0642ff825041f4923143f2"
	save "${gsdData}/0-RawTemp/`file'_manual_cleaning_nomads.dta", replace
}

*** Importing questionnaire
use "${gsdTemp}/hh_without_empty_obs_nomads", clear

*** Enumerator name cleaning
replace enum_id = 4302 if interview__id=="d961d542f6154f3289da43e32b4af331"
replace enum_id = 4303 if interview__id=="5fc9409d2b284429b91cffc1aa3d7438"
replace enum_id = 4303 if interview__id=="edca1855b16441d8946e9cbc483c4fc2"
replace enum_id = 4303 if interview__id=="9597ad13cdb646f3b5d7101a05e9fe44"
replace enum_id = 4302 if interview__id=="3c4e364c44834bdba26a08fce0bf506f"

replace enum_name = "Mohamed Sheik Abdullahi" if interview__id=="d961d542f6154f3289da43e32b4af331"
replace enum_name = "Mohamed Adan Hassan" if interview__id=="5fc9409d2b284429b91cffc1aa3d7438"
replace enum_name = "Mohamed Adan Hassan" if interview__id=="edca1855b16441d8946e9cbc483c4fc2"
replace enum_name = "Mohamed Adan Hassan" if interview__id=="9597ad13cdb646f3b5d7101a05e9fe44"
replace enum_name = "Mohamed Sheik Abdullahi" if interview__id=="3c4e364c44834bdba26a08fce0bf506f"
*tab enum_id

*** Team cleaning
*tab team_id

*** Pre-war region cleaning
*tab ea_reg
*tab ea_reg water_point if substr(today,1,10)=="2018-01-28"

*** Generating strata variable to be able to run the pipeline without errors
g strata = .

*** Water point number cleaning
*tab water_point
*tab water_point team_id if substr(today,1,10)=="2018-01-28"

*** Cleaning consent tracking devices
*21/01/2018
replace consent_tracking = 0 if interview__id=="05ffa1152ec44bcfba36eea2ee5f5fff"
replace barcode_tracking = . if interview__id=="05ffa1152ec44bcfba36eea2ee5f5fff"
replace tracking_phone_yn = . if interview__id=="05ffa1152ec44bcfba36eea2ee5f5fff"
replace tracking_phone = . if interview__id=="05ffa1152ec44bcfba36eea2ee5f5fff"
*22/01/2018
replace barcode_tracking = 169583 if interview__id=="2094ebaefe4e4273885ef62d9483fd27"
replace consent_tracking = 0 if interview__id=="7153776b33fc4db9b9df5aa5bfe1fdb2"
replace barcode_tracking = . if interview__id=="7153776b33fc4db9b9df5aa5bfe1fdb2"
replace tracking_phone_yn = . if interview__id=="7153776b33fc4db9b9df5aa5bfe1fdb2"
replace tracking_phone = . if interview__id=="7153776b33fc4db9b9df5aa5bfe1fdb2"
replace consent_tracking = 0 if interview__id=="dd473d064cd2431f864c8c699e04f285"
replace barcode_tracking = . if interview__id=="dd473d064cd2431f864c8c699e04f285"
replace tracking_phone_yn = . if interview__id=="dd473d064cd2431f864c8c699e04f285"
replace tracking_phone = . if interview__id=="dd473d064cd2431f864c8c699e04f285"
*26/01/2018
replace consent_tracking = 1 if interview__id=="f3c55e5de7f94b5a9e41602762aa5c19"
replace barcode_tracking = 169566 if interview__id=="f3c55e5de7f94b5a9e41602762aa5c19"
replace tracking_phone_yn = 1 if interview__id=="f3c55e5de7f94b5a9e41602762aa5c19"
replace tracking_phone = 0634378404 if interview__id=="f3c55e5de7f94b5a9e41602762aa5c19"

*** Missing date cleaning at the beginning and at the end of the interview
*Correcting when missing date using dates and times in metadata
*25/01/2018
replace today = "2018-01-25T12:26:00" if interview__id=="3c77c86f107544c4a4ed8d507d1bc006"
replace today_end = "2018-01-25T14:40:00" if interview__id=="3c77c86f107544c4a4ed8d507d1bc006"

*Identify observations with missing dates
*br if today == "##N/A##"
*br if today_end=="##N/A##" & consent==1

*** Incorrect duration cleaning (cases of incorrect date and time records)
*Correcting when incorrect duration using dates and times in metadata
*20/01/2018
replace today = "2018-01-20T07:57:00" if interview__id=="5ce9b3fd41e4407eb729230b62c3391d"
replace today_end = "2018-01-20T11:16:00" if interview__id=="5ce9b3fd41e4407eb729230b62c3391d"
*23/01/2018
replace today = "2018-01-23T12:26:00" if interview__id=="6f6b300910964a118d85074e0115cf79"
replace today_end = "2018-01-23T14:20:00" if interview__id=="6f6b300910964a118d85074e0115cf79"
*24/01/2018
replace today = "2018-01-24T10:17:00" if interview__id=="eed2c7b52f5242abbfbdb947e2de1661"
replace today_end = "2018-01-24T12:15:00" if interview__id=="eed2c7b52f5242abbfbdb947e2de1661"

*Creating duration variable
*Start time 
g start_time_temp = ""
replace start_time_temp = subinstr(today,"T"," ",.)
replace start_time_temp = subinstr(start_time_temp,"-05:00","",.)
gen double start_time = clock(start_time_temp, "YMDhms")
format start_time %tc
label var start_time "Date and time at which the interview started"

*End time
g end_time_temp = ""
replace end_time_temp = subinstr(today_end,"T"," ",.)
replace end_time_temp = subinstr(end_time_temp,"-05:00","",.)
gen double end_time = clock(end_time_temp, "YMDhms")
format end_time %tc
label var end_time "Date and time at which the interview ended"
drop start_time_temp end_time_temp

*Computing duration only only for successful interviews, and if the interview was conducted without breaks
g duration_itw_min = minutes(end_time - start_time) if int_break == 1
label var duration_itw_min "Duration of interview (minutes)" 

*Identify observations with incorrect duration
*br if duration_itw_min < 30
*br

*** Saving dataset with manual corrections
save "${gsdData}/0-RawTemp/hh_manual_cleaning_nomads.dta", replace

