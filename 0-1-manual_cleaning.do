*-------------------------------------------------------------------
*
*     MANUAL CORRECTIONS 
*     
*     This file records manual corrections 
*     (e.g. corrections on dates) after import
*                         
*-------------------------------------------------------------------

*** Importing questionnaire
use "${gsdDownloads}/Somali High Frequency Survey - Wave 2 - Fieldwork", clear

**** Dropping empty observations in all datasets (main + rosters)
* Main dataset
drop if interview__id=="42755ff8b2324f27b13fb6c19b58c914"
drop if interview__id=="5098f72447fe4d4fa031cc3376c71c4c"
drop if interview__id=="c59c6ad28b2d4365a54874c7e86a4790"
save "${gsdTemp}/hh_without_empty_obs", replace

* Rosters
local files hh_roster_separated hhroster_age motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
foreach file in `files' {
	use "${gsdDownloads}/`file'.dta", clear
	drop if interview__id=="42755ff8b2324f27b13fb6c19b58c914" 
	drop if interview__id=="5098f72447fe4d4fa031cc3376c71c4c"
	drop if interview__id=="c59c6ad28b2d4365a54874c7e86a4790"
	save "${gsdData}/0-RawTemp/`file'_manual_cleaning.dta", replace
}

* Cleaning duplicates in the non-food roster
use "${gsdData}/0-RawTemp/rnf_nonfood_manual_cleaning.dta", clear
drop if interview__id =="d887f734686c421d8621563041c069f5" & rnf_nonfood__id==1088 & rnf_item_recall=="##N/A##"
drop if interview__id =="d887f734686c421d8621563041c069f5" & rnf_nonfood__id==1089 & rnf_item_recall=="##N/A##"
drop if interview__id =="d887f734686c421d8621563041c069f5" & rnf_nonfood__id==1090 & rnf_item_recall=="##N/A##"
save "${gsdData}/0-RawTemp/rnf_nonfood_manual_cleaning.dta", replace

*** Importing questionnaire
use "${gsdTemp}/hh_without_empty_obs", clear

*** Enumerator name cleaning
replace enum_id = 3105 if interview__id=="ab0e6a8b5df34626b3f17a8ee5182ef0"
replace enum_id = 3206 if interview__id=="568d421b53b1407ca17d51362e22c68c"
replace enum_id = 2204 if interview__id=="aa65b9856f6c4437b9397f8b9444549e"
replace enum_id = 203 if interview__id=="d5abc9e7adb24ff28d98998b4039e273"
*tab enum_id

*** Pre-war region cleaning
*04/12/2017
replace ea_reg=5 if interview__id=="568d421b53b1407ca17d51362e22c68c"
replace ea_reg=5 if interview__id=="92950f08645d485a8261144204ab4e5c"
*08/12/2017
replace ea_reg=14 if interview__id=="42755ff8b2324f27b13fb6c19b58c914"
*tab ea_reg

*** EA number cleaning
*08/12/2017
replace ea=6116000 if interview__id=="5c40caffe54044deb59ed86dc5610e85"
*tab ea

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
