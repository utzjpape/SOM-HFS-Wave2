*-------------------------------------------------------------------
*
*     MANUAL CORRECTIONS 
*     
*     This file records manual corrections 
*     (e.g. corrections on dates) after import
*                         
*-------------------------------------------------------------------

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

** Append all versions
* Main dataset
use "${gsdTemp}/hh_append_v1", clear
append using "${gsdTemp}/hh_append_v2"
append using "${gsdTemp}/hh_append_v4"
append using "${gsdTemp}/hh_append_v6"
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
	
	use "${gsdTemp}/`file'_append_v1", clear
	append using "${gsdTemp}/`file'_append_v2"
	append using "${gsdTemp}/`file'_append_v4"
	append using "${gsdTemp}/`file'_append_v6"
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
save "${gsdData}/0-RawTemp/rnf_nonfood_manual_cleaning.dta", replace

*** Importing questionnaire
use "${gsdTemp}/hh_without_empty_obs", clear

*** Enumerator name cleaning
replace enum_id = 3105 if interview__id=="ab0e6a8b5df34626b3f17a8ee5182ef0"
replace enum_id = 3206 if interview__id=="568d421b53b1407ca17d51362e22c68c"
replace enum_id = 2204 if interview__id=="aa65b9856f6c4437b9397f8b9444549e"
replace enum_id = 203 if interview__id=="d5abc9e7adb24ff28d98998b4039e273"

label define enum_id 3602 "Mohamed Isak Mohamed" ///
	3603 "Fadumo Mohamed Jilal" ///
	3604 "Farhiya Abass Mohamed" ///
	3802 "Abdullahi Ibrahim Abdi" ///
	3803 "Hassan Mohamed Abdi" ///
	3804 "Jeylani Mohamed Dhere" ///
	3902 "Fuad Aden Yussuf" ///
	3903 "Fatuma Aden Issack" ///
	3904 "Hussein Madey Mohamed" ///
	4002 "Ali Farah Adow" ///
	4003 "Jama Ali Sheikh" ///
	4004 "Hassan Muhumad Rashiid", modify
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
*tab ea_reg ea if substr(today,1,10)=="2017-12-27"

*** EA number cleaning
*08/12/2017
replace ea=6116000 if interview__id=="5c40caffe54044deb59ed86dc5610e85"
*25/12/2017
replace ea=198760 if interview__id=="89fd6810cc534326ac279a8fb63e5456"

*tab ea
*tab ea team_id if substr(today,1,10)=="2017-12-27"

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
