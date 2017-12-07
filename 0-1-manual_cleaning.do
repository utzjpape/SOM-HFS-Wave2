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
drop if Id==""
save "${gsdTemp}/hh_without_empty_obs", replace

* Rosters
local files hh_roster_separated hhroster_age motor ra_assets ra_assets_prev rf_food ///
	rf_food_cereals rf_food_fruit rf_food_meat rf_food_vegetables rl_livestock rl_livestock_pre ///
	rnf_nonfood shocks
foreach file in `files' {
	use "${gsdDownloads}/`file'.dta", clear
	tostring ParentId1, replace
	drop if ParentId1=="" 
	save "${gsdData}/0-RawTemp/`file'_manual_cleaning.dta", replace
}

*** Importing questionnaire
use "${gsdTemp}/hh_without_empty_obs", clear

*** Enumerator name cleaning
replace enum_id = 3105 if Id=="ab0e6a8b5df34626b3f17a8ee5182ef0"
replace enum_id = 3206 if Id=="568d421b53b1407ca17d51362e22c68c"
*tab enum_id

*** Pre-war region cleaning
replace ea_reg=5 if Id=="568d421b53b1407ca17d51362e22c68c"
replace ea_reg=5 if Id=="92950f08645d485a8261144204ab4e5c"
*tab ea_reg

*** EA number cleaning
*tab ea

*** Missing date cleaning at the beginning and at the end of the interview
*Correcting when missing date using dates and times in metadata
*04/12/2017
replace today = "2017-12-04T05:14:36-05:00" if Id=="02166905804d4506b48e76266a0e2515"
replace today_end = "2017-12-04T07:38:44-05:00" if Id=="02166905804d4506b48e76266a0e2515"
replace today = "2017-12-04T13:56:36-05:00" if Id=="1dc5f61235e34b24b3eda74d784371cf"
replace today_end = "2017-12-04T15:08:01-05:00" if Id=="1dc5f61235e34b24b3eda74d784371cf"
replace today = "2017-12-04T14:16:26-05:00" if Id=="a4ed7427b619480cbb176320bb052ede"
replace today_end = "2017-12-04T15:59:46-05:00" if Id=="a4ed7427b619480cbb176320bb052ede"
*05/12/2017
replace today = "2017-12-05T12:12:15-05:00" if Id=="568d421b53b1407ca17d51362e22c68c"
replace today_end = "2017-12-05T13:29:48-05:00" if Id=="568d421b53b1407ca17d51362e22c68c"
replace today = "2017-12-05T13:13:17-05:00" if Id=="ada0265902e040e3bafe5148a4939ce5"
replace today_end = "2017-12-05T15:30:10-05:00" if Id=="ada0265902e040e3bafe5148a4939ce5"
replace today = "2017-12-05T06:13:16-05:00" if Id=="ab0e6a8b5df34626b3f17a8ee5182ef0"
replace today_end = "2017-12-05T07:12:59-05:00" if Id=="ab0e6a8b5df34626b3f17a8ee5182ef0"
replace today = "2017-12-05T05:03:40-05:00" if Id=="97d4b04cf43e4979acda113452d89292"
replace today_end = "2017-12-05T06:48:28-05:00" if Id=="97d4b04cf43e4979acda113452d89292"
replace today = "2017-12-05T05:40:52-05:00" if Id=="07d72a3e85fa4bae962a6b974d48cc5f"
replace today_end = "2017-12-05T07:22:32-05:00" if Id=="07d72a3e85fa4bae962a6b974d48cc5f"
*06/12/2017
replace today = "2017-12-06T06:51:15-05:00" if Id=="48f83438c2734f2d89a7a300bd6327d4"
replace today_end = "2017-12-06T08:52:38-05:00" if Id=="48f83438c2734f2d89a7a300bd6327d4"
replace today = "2017-12-06T11:30:41-05:00" if Id=="ed320347e5c24d47b06cd550fcdba98f"
replace today_end = "2017-12-06T12:39:52-05:00" if Id=="ed320347e5c24d47b06cd550fcdba98f"
replace today = "2017-12-06T04:57:20-05:00" if Id=="5ea29fb31e11444c9d8b12376cc23dd6"
replace today_end = "2017-12-06T06:49:28-05:00" if Id=="5ea29fb31e11444c9d8b12376cc23dd6"
replace today = "2017-12-06T04:57:54-05:00" if Id=="19f4630686bb44eba7f76142b9d65bd6"
replace today_end = "2017-12-06T07:13:01-05:00" if Id=="19f4630686bb44eba7f76142b9d65bd6"

*Identify observations with missing dates
*br if today == "##N/A##"
*br if today_end=="##N/A##" & consent==1

*** Incorrect duration cleaning (cases of incorrect date and time records)
*Correcting when incorrect duration using dates and times in metadata
*04/12/2017
replace today="2017-12-04T04:59:24-05:00" if Id=="7a11a820379040bd88ce2a0d95290e36"
replace today_end="2017-12-04T07:29:43-05:00" if Id=="7a11a820379040bd88ce2a0d95290e36"
replace today="2017-12-04T06:41:17-05:00" if Id=="cd8ffe5ee7c443e1890017e0b484c7a2"
replace today_end="2017-12-04T08:18:23-05:00" if Id=="cd8ffe5ee7c443e1890017e0b484c7a2"

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
