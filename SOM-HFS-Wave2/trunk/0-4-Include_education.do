* Education phone survey: prepare data


*-------------------------------------------------------------------
*
*     CREATE LIST OF PHONE NUMBERS
*     
*     This file creates the list of phone numbers for the Phone Survey
*                         
*-------------------------------------------------------------------

/*--------------------------------------------------
	Create database at the household member level
----------------------------------------------------*/

**Urban, Rural, IDPs
*Importing datasets from urban, rural, IDPs data collection
use "${gsdData}/0-RawTemp/hh_valid_keys_and_EAs.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning"

*Keeping list of relevant phone numbers
keep if successful_valid==1 & follow_up_yn==1 & migr_idp!=1 & hhm_edu_current!=1 & hhm_age>5 
drop if phone_number=="0" | phone_number=="061" | phone_number=="61" | phone_number=="0615" | phone_number=="l was see suscefully" | phone_number=="this people are very poor" | phone_number=="yujis"
drop _merge 

*Comparison with Gonzalo's file
merge 1:1 interview__id hhroster_age__id using "${gsdDataRaw}/hhm_missing_educ.dta", force
tab interview__id if _merge==1
/*Interview_id that we have in our final list but not in Gonzalo's list:
Unmatched interview__id:
13bfa5fca6614c9cbca14b373ca19136 - deleted manually (not complete submission)
56fb0c95efb5431e8db18efe6c70f8af
6c2ff0305288435aa5f237287d63bd4b
72354cc7c1384764b0c5d992ecaa2b22 - deleted manually (not complete submission)
852c6a6662ff44c48d5afcafc9425340
da31cbabb226489698bb69d9840fc9e7
f1dbe126cabe405a8ad1bd154435de67 - deleted because in an EA that was discarded
*/

**Adding the 4 missing interviews to Gonzalo's file
use "${gsdData}/0-RawTemp/hh_valid_keys_and_EAs.dta", clear
rename (ea_reg nhhm) (region hhsize)
keep region strata ea block type hhsize hhh_name interview__id hhr_id phone_number follow_up_yn
merge 1:m interview__id using "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning", keepusing(hhroster_age__id hh_list hhm_age hhm_gender hhm_relation hhm_read hhm_write hhm_edu_current) keep(match) nogenerate
sort interview__id hhroster_age__id
*Keeping the 4 missing interviews
keep if inlist(interview__id, "56fb0c95efb5431e8db18efe6c70f8af","6c2ff0305288435aa5f237287d63bd4b","852c6a6662ff44c48d5afcafc9425340","da31cbabb226489698bb69d9840fc9e7")
keep if hhm_edu_current!=1 & hhm_age>5 
drop hhm_edu_current
*Adding name of respondent
g resp_name = hhh_name
*Adding missing strata and type
replace strata = 52 if interview__id=="6c2ff0305288435aa5f237287d63bd4b"
replace type=1
order region strata ea block hhroster_age__id type hhsize resp_name hhr_id hh_list hhh_name interview__id hhm_age hhm_gender hhm_relation hhm_read hhm_write phone_number follow_up_yn
*Appending with Gonzalo's file
append using "${gsdDataRaw}/hhm_missing_educ.dta"
*Adding respondent name when missing
replace resp_name="Ganuun Adan Keer" if interview__id=="a285a77c94db45c79aec91e4fd401b53"
replace hhh_name="Ganuun Adan Keer" if interview__id=="a285a77c94db45c79aec91e4fd401b53"
*Creating nomad dummy variable
g nomad = 0
distinct interview__id
save "${gsdTemp}/hhm_missing_educ_clean.dta", replace

**Nomads
*Importing datasets from nomads data collection
use "${gsdData}/0-RawTemp/hh_valid_keys_nomads.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning_nomads", nogenerate
*Removing Version 4 of the questionnaire, for which we already have the education data
merge 1:1 interview__id hhroster_age__id using "${gsdDownloads}/Nomads - v4/hhroster_age.dta", keep(master) nogenerate

*Keeping list of relevant phone numbers
keep if successful_valid==1 & follow_up_yn==1 & migr_idp!=1 & hhm_edu_current!=1 & hhm_age>5 
replace phone_number = tracking_phone if missing(phone_number)
drop if phone_number>=. & tracking_phone == .

*Comparison with Gonzalo's file
merge 1:1 hhroster_age__id interview__id using "${gsdDataRaw}/hhm_missing_educ_nomads.dta", force
tab interview__id if _merge == 2
/*Interview_id that are in Gonzalo's list but not in our list:
2dcc1bcf28a04b11bb7d68a66d31ab67 - invalid interview
d08fedde4c7241c387310d8c7ab295e0 - invalid interview
fd7fc8ae9f524526aef5d7eb75581f3c - invalid interview
*/
distinct interview__id if _merge == 1
*57 interview_id are in our list but not in Gonzalo's list - interviews for which the phone number was recorded in tracking_phone and not in phone_number
keep if _merge==1
duplicates drop interview__id, force
keep interview__id
save "${gsdTemp}/hhm_missing_educ_nomads_nomatch.dta", replace

**Adding the 57 missing interviews to Gonzalo's file
use "${gsdData}/0-RawTemp/hh_valid_keys_and_WPs.dta", clear
drop strata
rename strata_id strata
keep ea_reg strata water_point type nhhm hhh_name interview__id hhr_id tracking_phone follow_up_yn
merge 1:m interview__id using "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning_nomads", keepusing(hhroster_age__id hh_list hhm_age hhm_gender hhm_relation hhm_read hhm_write hhm_edu_current) keep(match) nogenerate
sort interview__id hhroster_age__id
*Selecting the 57 missing interviews
merge m:1 interview__id using "${gsdTemp}/hhm_missing_educ_nomads_nomatch.dta", keep(match) nogenerate
keep if hhm_edu_current!=1 & hhm_age>5 
drop hhm_edu_current
*Replacing phone number
tostring tracking_phone, g(phone_number)
drop tracking_phone
*Adding name of respondent
replace hhh_name = "hasan yare hasan" if interview__id=="b150ef8dee184a4399e5e608e39b2d76"
g resp_name = hhh_name
*Setting type to missing
replace type=.
*Appending with Gonzalo's file
append using "${gsdDataRaw}/hhm_missing_educ_nomads.dta"

**Dropping unnecessary observations (identified in the comparison with Gonzalo's file
drop if interview__id=="2dcc1bcf28a04b11bb7d68a66d31ab67"
drop if interview__id=="d08fedde4c7241c387310d8c7ab295e0"
drop if interview__id=="fd7fc8ae9f524526aef5d7eb75581f3c"

*Renaming variables
rename (ea_reg nhhm) (region hhsize)
*Generating nomad dummy variable
g nomad = 1
*Modifying ea variable
g ea = water_point*1000 if nomad==1 
*Changing format of phone number
tostring phone_number, replace

keep region strata ea hhroster_age__id type hhsize resp_name hhr_id hh_list hhh_name interview__id hhm_age hhm_gender hhm_relation hhm_read hhm_write phone_number follow_up_yn nomad
order region strata ea hhroster_age__id type hhsize resp_name hhr_id hh_list hhh_name interview__id hhm_age hhm_gender hhm_relation hhm_read hhm_write phone_number follow_up_yn nomad
distinct interview__id
save "${gsdTemp}/hhm_missing_educ_nomads_clean.dta", replace

/*--------------------------------------------------
	Clean phone numbers
----------------------------------------------------*/

use "${gsdTemp}/hhm_missing_educ_clean.dta", clear
append using "${gsdTemp}/hhm_missing_educ_nomads_clean.dta"

*This cleaning completes Gonzalo's first wave of cleaning:
drop if phone_number=="0" | phone_number=="061" | phone_number=="61" | phone_number=="0615" | phone_number=="l was see suscefully" | phone_number=="this people are very poor" | phone_number=="yujis"

*Cleaning for instances where several phone numbers were indicated
replace phone_number="0907727957 / 0634023767" if interview__id=="5ea0e14dfa804a94ab1d287d7d71d3ca"
replace phone_number="0907295929 / 0633055934" if interview__id=="e58460a3242e49678c6aa36ffd83e9ce"
replace phone_number="0615342011 / 0615719018" if interview__id=="89ab476b976b4d789d3a598fa4d91b99"

*Cleaning for instances with "multiply" sign at the beginning
replace phone_number="0617156332" if interview__id=="941af52ecb1546239c5cf3f9ad02195a"
replace phone_number="0615789072" if interview__id=="12c9bfe2bf434dc0a2d1858d8cfe9ebf"
replace phone_number="0615688220" if interview__id=="3eb80ebcd31e4e3c9fad6a709479f13b"
replace phone_number="0615679315" if interview__id=="bba0ade4847341d8a9aa98f0e8d899dc"
replace phone_number="0616340173" if interview__id=="ebf05311ed1d40ecadd0a4fbfaba9957"
replace phone_number="0618516151" if interview__id=="e76fca3e794a483ca01d794e3fceae93"

*Cleaning for one instance starting with 90 instead of 09
replace phone_number="0977614798" if interview__id=="8130170bd4c046b6a1b05657147bc086"

*Automatic cleaning for most common mistakes/different number formats
replace phone_number=subinstr(phone_number,"+252","0",.) 
replace phone_number=subinstr(phone_number,"+251","0",.)
replace phone_number=subinstr(phone_number,"x252","0",.)
replace phone_number=subinstr(phone_number,"252 ","0",1) if substr(phone_number,1,4)=="252 "
replace phone_number=subinstr(phone_number,"00252","0",1) if substr(phone_number,1,5)=="00252"
replace phone_number=subinstr(phone_number,"00252 ","0",1) if substr(phone_number,1,6)=="00252 "
replace phone_number=subinstr(phone_number," Golis","",.)
replace phone_number=subinstr(phone_number,"1252","0",1) if substr(phone_number,1,4)=="1252"
replace phone_number=subinstr(phone_number,"252","0",1) if substr(phone_number,1,3)=="252"
replace phone_number=subinstr(phone_number," ","",.)
replace phone_number=subinstr(phone_number,"o","0",.)
replace phone_number=subinstr(phone_number,"x","",.)
replace phone_number=subinstr(phone_number,"000","0",1) if substr(phone_number,1,3)=="000"
replace phone_number=subinstr(phone_number,"07","06",1) if substr(phone_number,1,2)=="07" & (region==15 | region==3 | region==6 | region==7 | region==11 | region==17 | region==18 | region==1)
replace phone_number=subinstr(phone_number,"07","09",1) if substr(phone_number,1,2)=="07" & (region==4 | region==12 | region==13 | region==16)
 
*Generating string length of phone numbers
gen nb_length=strlen(phone_number)

*Adding 0s at the beginning of 9 digits numbers
replace phone_number= "0" + phone_number if nb_length==9

*Adding 061 at the beginning of 7 digit numbers from South Central
replace phone_number= "061" + phone_number if nb_length==7 & (region==15 | region==3 | region==6 | region==7 | region==11)

*Adding 063 at the beginning of 7 digit numbers from Somaliland
replace phone_number= "063" + phone_number if nb_length==7 & (region==17 | region==18 | region==1)

*Adding 090 at the beginning of 7 digit numbers from Puntland
replace phone_number= "090" + phone_number if nb_length==7 & (region==4 | region==12 | region==13 | region==16)

*Generating updated string lenght
gen nb_length2=strlen(phone_number)
tab nb_length2
drop if nb_length2==5 | nb_length2==6 | nb_length2==8 | nb_length2==11

*Cleaning for 10 digit phone_numbers with mistakes on the 2 first digits
gen begin=substr(phone_number,1,2)
drop if begin=="00" & nb_length2==10
drop if begin=="61" & nb_length2==10
drop nb_length nb_length2 begin

*Dropping duplicates (keeping those which were checked)
bysort interview__id: gen nb_res = _N
sort interview__id hh_list
by interview__id: gen hhm_id = _n
gen hh_list_id = hhm_id - 1

gen phone_number2=phone_number
replace phone_number2="" if hhm_id!=1

duplicates tag phone_number2, gen(tag)
bysort interview__id: egen min_tag = min(tag)				

replace min_tag=0 if interview__id=="dfeeab8a06f0482e8929d0ab1cacc0d9"
replace min_tag=0 if interview__id=="8690ef6daf8d445c902a31726a53d040"
replace min_tag=0 if interview__id=="a8be0980381b492ca7934faa28a834d4"
replace min_tag=0 if interview__id=="c4f753a0be454a4db151be6acf52d641"
replace min_tag=0 if interview__id=="13cf1f968c274526ba5fc419c6637377"
replace min_tag=0 if interview__id=="3a611f974d5e406f8b338420fc0e6d71"
replace min_tag=0 if interview__id=="d61c988c5d7c49aea740a4dcb6cd1af7"
replace min_tag=0 if interview__id=="def9fa73df1244c2aab138eab468acc0"
replace min_tag=0 if interview__id=="d848bfd0e5054c2ba224f3261daa6f59"
replace min_tag=0 if interview__id=="2e4c55f55268422d96360150835f05ad"
replace min_tag=0 if interview__id=="017a135289fb426182982129bdf3e6b6"
replace min_tag=0 if interview__id=="20d1118c7d084af78eec1b834b5f7e73"
replace min_tag=0 if interview__id=="d1e2a33d2ac14807b230cde104cd7665"
replace min_tag=0 if interview__id=="afed049a5d024a7cada2742907c2d70c"
replace min_tag=0 if interview__id=="1206d6d73ff6450da562a333df88d5ae"
replace min_tag=0 if interview__id=="31ff5761124148dbb394645a87a84db0"
replace min_tag=0 if interview__id=="8747b09031444363ad92ed80c2773417"
replace min_tag=0 if interview__id=="a50d769597224104bbbb80809273ee43"
replace min_tag=0 if interview__id=="8d067d7e225c4e779aa12d4656b742b3"
replace min_tag=0 if interview__id=="29db44086eb74b20b1ad0d869e4273fb"
replace min_tag=0 if interview__id=="f647ed100055470981099832ce86abc8"
replace min_tag=0 if interview__id=="721169bf75c04148b51da3989ad41d35"
replace min_tag=0 if interview__id=="2a081a8e3c2f4fc3b7c645a3c52442f0"
replace min_tag=0 if interview__id=="fcfd98f55edb4e1a9e3eb9270d5a8b2f"
replace min_tag=0 if interview__id=="2353d3f4565647b3b76a37172be7ae54"
replace min_tag=0 if interview__id=="9319fd0cf4a94e729aa62a62c71ff8a6"
replace min_tag=0 if interview__id=="39e5c55d4f4d40679eb641c1e75ee8c2"
replace min_tag=0 if interview__id=="f1008094b36c4410b5ec721aeee947d6"
replace min_tag=0 if interview__id=="0fdc711e3a1c46c59a3a3b7309572ee3"
replace min_tag=0 if interview__id=="6e5883fcd95a450fbaca2e72ba58ec4d"
replace min_tag=0 if interview__id=="bcbea22e84094c298115c860b09d87e6"
replace min_tag=0 if interview__id=="10d082c67d5843d1970e117a98a3be2d"
replace min_tag=0 if interview__id=="29adb6e2bfaf4fb69fe97510ffd10211"
replace min_tag=0 if interview__id=="8280f614679d4be19956dd0dae45741d"
replace min_tag=0 if interview__id=="39cf365b457945ec9f66f17fb1be2690"
replace min_tag=0 if interview__id=="726364c10146456094cc59d703731c5e"
replace min_tag=0 if interview__id=="e446b79ea53d4692b5114f3cc9989918"
replace min_tag=0 if interview__id=="b6d9cb7ef5794d18805cf7e01c1c680c"
replace min_tag=0 if interview__id=="17c1f1c3e4c94d71b967e86b8928a81f"
replace min_tag=0 if interview__id=="258b23975c124f5e887f7cbd0e3ba82e"
replace min_tag=0 if interview__id=="cee3d79d90ef4f27935f5ffa1eec5cdc"
replace min_tag=0 if interview__id=="241106a6970c4943b0f0de92bbe9bdaf"
replace min_tag=0 if interview__id=="6071ed6a50f349fdac850c1ffc91d9b4"
replace min_tag=0 if interview__id=="90856ba4984248e29561b5c5d58f81b4"
replace min_tag=0 if interview__id=="2b403f3510d3444389a634a3171e68d1"
replace min_tag=0 if interview__id=="254a99a22b364dbc924815dacc35081a"
replace min_tag=0 if interview__id=="9ce0846351df4c7da7e0d35e807f962e"
replace min_tag=0 if interview__id=="769f951613124c88a39a40d6fd905541"
replace min_tag=0 if interview__id=="28d83dc95eda488a9526fbd5af3df280"
replace min_tag=0 if interview__id=="4c1565b9a0a545a4a79ca3cbd8e0f6d7"
replace min_tag=0 if interview__id=="dd0fcf0fb6eb4db08f2de246893c744f"
replace min_tag=0 if interview__id=="3938817eb53643ac921920af60379677"
replace min_tag=0 if interview__id=="6887628dd19e4cd896addeb9c60b3d8e"
replace min_tag=0 if interview__id=="db79c5fbde0f4fcb89baaa49d4fe2481"
replace min_tag=0 if interview__id=="fc9d911b257c4964a9027af38be7fde2"
replace min_tag=0 if interview__id=="52a21af29935435da1779c230e70928f"
replace min_tag=0 if interview__id=="c28b3f4f27cb4e4eba55ae43dce6c1f5"
replace min_tag=0 if interview__id=="68b3133d99a545519d1530270076f14d"
replace min_tag=0 if interview__id=="67a95e23d5014b76952b484cffdc3a19"
replace min_tag=0 if interview__id=="5155414f7b2d47bc8fe316cd95a89b42"
replace min_tag=0 if interview__id=="583a60fae82e4c15a0a6ff56b7e06ba6"
replace min_tag=0 if interview__id=="51d92dc86fea408fbcc31f75a2a9ae38"
replace min_tag=0 if interview__id=="d321a5ea22e44e83a49ef3d377e9df71"
replace min_tag=0 if interview__id=="35e7ed7c1d664ce5bc0608f421c40052"
replace min_tag=0 if interview__id=="953b588d63ab41c2be01e6997beb24c7"
replace min_tag=0 if interview__id=="db42ad2e2999498d83d530a4163c72e1"
replace min_tag=0 if interview__id=="c157908b14cd4316875fc87a4ba0eb7b"
replace min_tag=0 if interview__id=="f5f59289fdd044b18a148332132ba3f8"
replace min_tag=0 if interview__id=="88dc414063bf46e5ba1582a63ef1f483"
replace min_tag=0 if interview__id=="823917c41fcf4d54884423f6eb8e1dc0"
replace min_tag=0 if interview__id=="9a97ae600c6f4ed782e2f29dafdadd0b"
replace min_tag=0 if interview__id=="6368457ec3134d02b13e840aae6f69d2"
replace min_tag=0 if interview__id=="d1e2a33d2ac14807b230cde104cd7665"
replace min_tag=0 if interview__id=="83510784c70e4c05bd694c604818935d"
replace min_tag=0 if interview__id=="3d9b6f1bde1c487da2ba3afc2d6edac9"
replace min_tag=0 if interview__id=="53f980215ad44180a305209d432231a5"
replace min_tag=0 if interview__id=="001fee1a316e496d9bd0f7552d3a95ff"
replace min_tag=0 if interview__id=="3a611f974d5e406f8b338420fc0e6d71"
replace min_tag=0 if interview__id=="06332ad1c13b43e59b0ded645f485b99"
replace min_tag=0 if interview__id=="6ea5fe519caf4c1da751fe4731c9b3cc"
replace min_tag=0 if interview__id=="d848bfd0e5054c2ba224f3261daa6f59"
replace min_tag=0 if interview__id=="8747b09031444363ad92ed80c2773417"
replace min_tag=0 if interview__id=="1566ab395d644937acb6ff2c782d1a06"
replace min_tag=0 if interview__id=="20e24e3b70684cf8b0fd26c318f20b9d"
replace min_tag=0 if interview__id=="0d36822aaa50418b861cd58899ecc112"
replace min_tag=0 if interview__id=="2a37c951a1ac4ed7bc14b0376c94f6c4"
replace min_tag=0 if interview__id=="22f40c97ea3243d4a58fb179ec702f26"
replace min_tag=0 if interview__id=="66996423d7af464c9278192a1a27ad49"
replace min_tag=0 if interview__id=="1172cf63713c4a97882fdfa3f7e389b8"
replace min_tag=0 if interview__id=="522c9288d1f34ce18d1466f59934b28d"
replace min_tag=0 if interview__id=="f647ed100055470981099832ce86abc8"
replace min_tag=0 if interview__id=="3d756a8798164acfbb0faf08d61ff3f2"
replace min_tag=0 if interview__id=="0a34ae938e9e4b83b5cbbc77c0f4211b"
replace min_tag=0 if interview__id=="20d1118c7d084af78eec1b834b5f7e73"
replace min_tag=0 if interview__id=="e078ec9ac7974f809c456e2cf1b3caff"
replace min_tag=0 if interview__id=="751d6c6631e44580ad010478f91b2ba5"
replace min_tag=0 if interview__id=="a8be0980381b492ca7934faa28a834d4"
replace min_tag=0 if interview__id=="5ec06340917e45ccaf5e5a25322b965f"
replace min_tag=0 if interview__id=="843437bca12344e1962acbdc1be20fee"
replace min_tag=0 if interview__id=="1f81cd5575b0483f83a73196e4a3e8ac"
replace min_tag=0 if interview__id=="c0fb647e9b25420992c66d7f5d54f4ef"
replace min_tag=0 if interview__id=="c4f753a0be454a4db151be6acf52d641"
replace min_tag=0 if interview__id=="45982316b2a849a88d36d8fed250f18d"
replace min_tag=0 if interview__id=="a8f0a5652dd4421680adc4af589f1674"
replace min_tag=0 if interview__id=="13cf1f968c274526ba5fc419c6637377"
replace min_tag=0 if interview__id=="820fe37acae046f5870815d0a5d1348c"
replace min_tag=0 if interview__id=="216c4d4195354768ba847e81ce6361a1"
replace min_tag=0 if interview__id=="7ae185f91f6d4c10938b7ba99c68570b"
replace min_tag=0 if interview__id=="8375fd01346142589fae3a34bc21607b"
replace min_tag=0 if interview__id=="08258508606a4a998f9743b6a9ede70d"
replace min_tag=0 if interview__id=="d8f3d416f91d4563a7ac51167c6ace6e"
replace min_tag=0 if interview__id=="31fe346f727c451dacde2598089fa92b"
replace min_tag=0 if interview__id=="72d435487ada497c8e1e13c1dde5bfe6"
replace min_tag=0 if interview__id=="32462bcaf29d49f39ef223beb857a1b3"
replace min_tag=0 if interview__id=="83ee31ed7b4143448f6d1325db39c9ed"
replace min_tag=0 if interview__id=="29fa618ce25444b3879f79caeb55284e"
replace min_tag=0 if interview__id=="efc6231a23f14dbb850a3e2d73049519"
replace min_tag=0 if interview__id=="49aef72ffaa149f58fb7efdb52b8201c"
replace min_tag=0 if interview__id=="edd57bbad5264638a6731bc80271e1cf"
replace min_tag=0 if interview__id=="5058b341082942d69bfb9e11412dddc1"
replace min_tag=0 if interview__id=="882e697aeb7e441f8bd362195f78d041"
replace min_tag=0 if interview__id=="e608d6e5ec684f5d885ec6117d0f7737"
replace min_tag=0 if interview__id=="356a1f255eb54c40bd21293844e9acff"
replace min_tag=0 if interview__id=="8690ef6daf8d445c902a31726a53d040"
replace min_tag=0 if interview__id=="0a93887fd6804ae59826288040cda0d9"
replace min_tag=0 if interview__id=="66de972231064fba89face162c839ba5"
			
drop if min_tag==1 | min_tag==2
drop tag min_tag phone_number2

save "${gsdData}/0-RawTemp/hhm_list_phone_numbers_final.dta", replace

/*------------------------------------------------------------------------------
	Create database at the household level
	Collapse by phone number x respondent name 
------------------------------------------------------------------------------*/

collapse (first) region strata ea hhh_name hhr_id interview__id, by(phone_number resp_name)
save "${gsdData}/0-RawTemp/hh_list_phone_numbers_final.dta", replace


*-------------------------------------------------------------------
*
*     MANUAL CORRECTIONS 
*     
*     This do-file records manual corrections after import
*     It also enables to check daily submissions, and to identify 
*     phone numbers x respondent name for which we have a successful
*     and complete submission
*                             
*-------------------------------------------------------------------

*PART 1: MANUAL CLEANING

*** Importing questionnaire
** Version 5
use "${gsdDownloads}/Phone survey - v5/Education Phone Survey", clear
decode enum_id, g(enum_name)
label drop enum_id
g start_time="2018-02-05T00:00:00"
save "${gsdTemp}/hh_append_v5_educ", replace

** Version 6
use "${gsdDownloads}/Phone survey - v6/Education Phone Survey", clear
decode enum_id, g(enum_name)
label drop enum_id
save "${gsdTemp}/hh_append_v6_educ", replace

** Appending all versions
* Main dataset
use "${gsdTemp}/hh_append_v5_educ", clear
append using "${gsdTemp}/hh_append_v6_educ"
save "${gsdTemp}/hh_append_educ", replace

* Rosters
use "${gsdDownloads}/Phone survey - v5/hhroster", clear
append using "${gsdDownloads}/Phone survey - v6/hhroster"
save "${gsdTemp}/hhroster_append_educ", replace

use "${gsdDownloads}/Phone survey - v5/interview__errors", clear
append using "${gsdDownloads}/Phone survey - v6/interview__errors"
save "${gsdData}/0-RawTemp/interview__errors_manual_cleaning_educ.dta", replace

*** Dropping test observations in all datasets (main + rosters)
* Main dataset
use "${gsdTemp}/hh_append_educ", clear
drop if interview__id=="469227d94cc747349a5f8dda32e7ba27"
drop if interview__id=="dc1048bd876748f38877c2de6a76f0d8"
drop if interview__id=="ba3c6243d3f24e2faf2375126c547ff3"
save "${gsdTemp}/hh_without_empty_obs_educ", replace

* Rosters
use "${gsdTemp}/hhroster_append_educ", clear
drop if interview__id=="469227d94cc747349a5f8dda32e7ba27"
drop if interview__id=="dc1048bd876748f38877c2de6a76f0d8"
drop if interview__id=="ba3c6243d3f24e2faf2375126c547ff3"
save "${gsdTemp}/hhroster_without_empty_obs_educ", replace

use "${gsdTemp}/hh_without_empty_obs_educ", clear

***Manual cleaning on Enumerator name
replace enum_id=308 if interview__id=="08b83cf7aaf641a08923c2b86aefe3bd"
replace enum_name="Abdullahi Mohamed Moumin" if interview__id=="08b83cf7aaf641a08923c2b86aefe3bd"
replace enum_id=305 if interview__id=="d5c0c65150e34b3f80ec4a06d4e16d8d"
replace enum_name="Aden Ahmed Abdalle" if interview__id=="d5c0c65150e34b3f80ec4a06d4e16d8d"
replace enum_id=305 if interview__id=="d47902fc78394e739c9d598ff9087adc"
replace enum_name="Aden Ahmed Abdalle" if interview__id=="d47902fc78394e739c9d598ff9087adc"
replace enum_id=305 if interview__id=="9e65d3d4d07740d8b19cf4fde9fd8bf8"
replace enum_name="Aden Ahmed Abdalle" if interview__id=="9e65d3d4d07740d8b19cf4fde9fd8bf8"

*** Manual cleaning on dates and times
*06/02/2018
replace start_time="2018-02-06T00:00:00" if interview__id=="83bf5d2ae5544c048608a61d6cbbc31f"
replace start_time="2018-02-06T00:00:00" if interview__id=="80aa0529e13b4ffc8f2fee7b57e16b14"
replace start_time="2018-02-06T00:00:00" if interview__id=="537fd3b6b0644e2fb719157363abfadb"
replace start_time="2018-02-06T00:00:00" if interview__id=="53007bf64fbb43f4a8c0eac63f8d7706"
replace start_time="2018-02-06T00:00:00" if interview__id=="2c9086eac1d04410865342e2112f42c7"
replace start_time="2018-02-06T00:00:00" if interview__id=="22b55be2717b4f17bea117b384962372"
replace start_time="2018-02-06T00:00:00" if interview__id=="193bc873efcd4eec82d4b4efe10d90f0"
replace start_time="2018-02-06T00:00:00" if interview__id=="0bd003114d6444a9ad946d610345cd2b"
replace start_time="2018-02-06T00:00:00" if interview__id=="8d854e2795604bafae57a02a93e4ff7c"
replace start_time="2018-02-06T00:00:00" if interview__id=="6b53c99339b5436c828f889ad5b369ca"
replace start_time="2018-02-06T00:00:00" if interview__id=="588af1ec57334d86b44945e595ec20a3"
replace start_time="2018-02-06T00:00:00" if interview__id=="43729ec18f714ea98b7f11561d2eed47"
replace start_time="2018-02-06T00:00:00" if interview__id=="2a0ee9c68be342a4bad35c31034c7ef4"
replace start_time="2018-02-06T00:00:00" if interview__id=="1a00d9b1590c43a8822b972d652528cc"
replace start_time="2018-02-06T00:00:00" if interview__id=="154d5a4c1a3c4a0b84097767f9269027"
replace start_time="2018-02-06T00:00:00" if interview__id=="16cbd96f42ab441298dbd27c50c604b6"
replace start_time="2018-02-06T00:00:00" if interview__id=="13d49c88e4374ab386c830bd5896c37b"
replace start_time="2018-02-06T00:00:00" if interview__id=="088f746758244d4e9f7272a6faac49b2"
replace start_time="2018-02-06T00:00:00" if interview__id=="06ce0f7b1a5e4c4cab8fe9d91f922d5d"
replace start_time="2018-02-06T00:00:00" if interview__id=="067e304f1ea64d3caec5dd3a887bcf90"
replace start_time="2018-02-06T00:00:00" if interview__id=="4f76efae44b84bba90ee7b3c77b3638f"
replace start_time="2018-02-06T00:00:00" if interview__id=="3ff86818c02049aba87a7cc3f6066834"
replace start_time="2018-02-06T00:00:00" if interview__id=="3113f4e8a63244049d0176afd9904f0d"
replace start_time="2018-02-06T00:00:00" if interview__id=="2f805331ce924b78a45d1dcefd6aa0b5"
replace start_time="2018-02-06T00:00:00" if interview__id=="2861c1038c0b4a9a94942cec27097c73"
replace start_time="2018-02-06T00:00:00" if interview__id=="12b065d1ff914970a73cb1da7d851db3"
replace start_time="2018-02-06T00:00:00" if interview__id=="982663d0f5a94c42810870c41abd6450"
replace start_time="2018-02-06T00:00:00" if interview__id=="97a2578b2e9842d7a6e500e35f5aece5"
replace start_time="2018-02-06T00:00:00" if interview__id=="90b41dc449e043f5b53e8ab5eb9a6bd0"
replace start_time="2018-02-06T00:00:00" if interview__id=="90882b4d6e0442bd9760a5a1bf358fca"
replace start_time="2018-02-06T00:00:00" if interview__id=="73902c9d54d64a048672f891773f15fe"
replace start_time="2018-02-06T00:00:00" if interview__id=="5cc728942b8d412aaf847b9cc941ba60"
replace start_time="2018-02-06T00:00:00" if interview__id=="4a426f5d07ec44c5a7bbe44c0a4d759d"
replace start_time="2018-02-06T00:00:00" if interview__id=="49f65eb4368c4938b6563ab4a3fadb28"
replace start_time="2018-02-06T00:00:00" if interview__id=="49a87ef81fbd418a9ea81239b01484d1"
replace start_time="2018-02-06T00:00:00" if interview__id=="3a489b18979e4c6d911d3eecbd6a17e3"
replace start_time="2018-02-06T00:00:00" if interview__id=="2db95e42dd8148cdb5bebce9a86e7ac3"
replace start_time="2018-02-06T00:00:00" if interview__id=="71a94b4af3ad4c2e9283b33557d434df"
replace start_time="2018-02-06T00:00:00" if interview__id=="e2423de37d3a4ed896473941cb3f542c"
replace start_time="2018-02-06T00:00:00" if interview__id=="c05888a4321140d99d152c4bee7a0ffc"
replace start_time="2018-02-06T00:00:00" if interview__id=="b648043e19574dde86bced41abeacef9"
replace start_time="2018-02-06T00:00:00" if interview__id=="b09d52eccdfb4cf4a3b2089a5f7d26ad"
replace start_time="2018-02-06T00:00:00" if interview__id=="cc2a90a957844181a9f0708b39a94950"
replace start_time="2018-02-06T00:00:00" if interview__id=="fe656c7457244de2954219f769188e31"
replace start_time="2018-02-06T00:00:00" if interview__id=="d9d77840950c4005822a5783fb326a46"
replace start_time="2018-02-06T00:00:00" if interview__id=="cef83f14ffec4001b4e5f80b2e495041"
replace start_time="2018-02-06T00:00:00" if interview__id=="b4c2e384cc08428c8ef11f4a2abe7dc5"
*07/02/2018
replace start_time="2018-02-07T10:01:00" if interview__id=="0790b7d4468a40cb920533cc8c6df9af"
replace start_time="2018-02-07T10:06:00" if interview__id=="7711a1e501824f3abf84b711b2b8545b"
replace start_time="2018-02-07T03:44:00" if interview__id=="d2c14ac243f84a52849fe9c7a1865dce"
replace start_time="2018-02-07T13:32:00" if interview__id=="aeadb96eb91547069fb986b260d2b8df"
replace start_time="2018-02-07T13:39:00" if interview__id=="db31691f832d430e9ecd6c88ad12ca75"
replace start_time="2018-02-07T13:43:00" if interview__id=="fef6b7ef452f4f05948b28c8716a3670"
replace start_time="2018-02-07T13:57:00" if interview__id=="9abc646d15df41b79bee0bec8277a8f3"
replace start_time="2018-02-07T14:11:00" if interview__id=="6ef737d7e65d4e0bbf1f7fd3eefeff4f"
replace start_time="2018-02-07T14:27:00" if interview__id=="c3e8c5b9d7d445749204c3d9a7e841f6"
replace start_time="2018-02-07T14:43:00" if interview__id=="8a0f6a9592db48229772ee288a537c54"
replace start_time="2018-02-07T15:27:00" if interview__id=="f8b5071b9e3e4210be4d597f60a1b0cf"
replace start_time="2018-02-07T15:36:00" if interview__id=="e73b63f1d77a43f784656ac6fdfe91aa"
replace start_time="2018-02-07T15:45:00" if interview__id=="90e76119d1a04ac89cad8fd97e13d805"
replace start_time="2018-02-07T15:51:00" if interview__id=="b886d3aaee954f2586e61324d557247f"
replace start_time="2018-02-07T18:10:00" if interview__id=="7a58c975f62e41caa806e51e2e919b5f"
replace start_time="2018-02-07T18:27:00" if interview__id=="0741025ef0fd45faafdccf0f44fe536b"
replace start_time="2018-02-07T18:30:00" if interview__id=="02e1d74f11494ab4ae061ecaf5995e3f"
replace start_time="2018-02-07T18:42:00" if interview__id=="f538d03431774fd3ad03309b8bd23946"
replace start_time="2018-02-07T19:04:00" if interview__id=="f461b3fabee04bfca8086f0a856451b2"
replace start_time="2018-02-07T19:19:00" if interview__id=="fe10bd1bccdb47d2ae1e2b3e0684ef7c"
replace start_time="2018-02-07T19:25:00" if interview__id=="c69d76d3de2945f0a4227b508153d506"
replace start_time="2018-02-07T19:29:00" if interview__id=="e8d7fd25fad944d68cf3cd7d0c209308"
replace start_time="2018-02-07T19:40:00" if interview__id=="3b271ac01e4147a896d1b2b711a41b9c"
replace start_time="2018-02-07T19:44:00" if interview__id=="4dee86016499481bad61667025d92cbd"
replace start_time="2018-02-07T19:46:00" if interview__id=="0b64253855314aadae5acca8c38f71a1"
*08/02/2018
replace start_time="2018-02-07T16:44:00" if interview__id=="08b83cf7aaf641a08923c2b86aefe3bd"

*br if start_time == "##N/A##"
*tab enum_name if start_time == "##N/A##"

***Cleaning on no_reach_reason
replace noreach_reason=1 if interview__id=="ae5cd1cbfeff47b99f728a0757020eaf"
replace noreach_reason=1 if interview__id=="ff2304467f7c4bd9a7f2f56992807ddc"
replace noreach_reason=1 if interview__id=="4d5900f5b1ff40f1b3bbebf2c8046e71"
replace noreach_reason=1 if interview__id=="6d7d67f217eb46c1a463217b3647a793"
replace noreach_reason=1 if interview__id=="c8b0bb71a6e94daabd5a0416f7efd598"
replace noreach_reason=1 if interview__id=="7613ce608f0240a68b49bd18e12c76fc"
replace noreach_reason=1 if interview__id=="3aec8fb6c26f40ff8fec11512193924f"
replace noreach_reason=1 if interview__id=="22dc8b6470b649e391a02be789d2c5e1"
replace noreach_reason=1 if interview__id=="620bd6c6cedf44da858ce3da093bf830"
replace noreach_reason=1 if interview__id=="a50341b6d8964b19bfe7196adcd913ab"
replace noreach_reason=1 if interview__id=="08cae6c201004bd4bfab964e7fe796e2"

***Cleaning of a respondent name 
replace hh_list__2="maxamed cali raage" if interview__id=="c009f7f544a049e4945404c5f2b9fd7b"
save "${gsdTemp}/hh_manual_cleaning_educ", replace

use "${gsdTemp}/hhroster_without_empty_obs_educ", clear
replace hh_list="maxamed cali raage" if interview__id=="c009f7f544a049e4945404c5f2b9fd7b" & hhroster__id==3
save "${gsdData}/0-RawTemp/hhroster_manual_cleaning_educ.dta", replace

***Creating status of phone number x respondent name
use "${gsdTemp}/hh_manual_cleaning_educ", clear

***Generating useful variables
*Date
g date = substr(start_time,1,10)

*Indicators for phone numbers that need to be discarded
g phone_not_exist = (noreach_reason==4)
g no_consent = (agree==0)

*Index to count the number of attempts
g index = 1

*Successfulness of interviews
g successful = (proceed==1)

*Validity of interviews
g valid = 1
save "${gsdTemp}/hh_manual_cleaning_educ_temp1", replace

*Completeness of interviews
use "${gsdData}/0-RawTemp/hhroster_manual_cleaning_educ.dta", clear
foreach var of varlist hhm_edu_ever hhm_edu_years hhm_edu_level {
	gen mi_`var' = (`var'== -999999999 | `var'== -1000000000 | `var'== .a) if `var' != .
}
egen missing_prop = rowmean(mi_*)
collapse (mean) missing_prop, by(interview__id)
merge m:1 interview__id using "${gsdTemp}/hh_manual_cleaning_educ_temp1", nogenerate
g complete = (missing_prop==0) if successful==1
replace valid=0 if complete==0
save "${gsdTemp}/hh_manual_cleaning_educ_temp2", replace

*Problem with Survey Solutions interviewer app, when no question was diplayed after "have you ever attended school", even if the answer was positive
use "${gsdData}/0-RawTemp/hhroster_manual_cleaning_educ.dta", clear
g pb_SS = 0
replace pb_SS = 1 if hhm_edu_ever==1 & hhm_edu_years==. & hhm_edu_years_kdk==.
collapse (max) pb_SS, by(interview__id)
merge m:1 interview__id using "${gsdTemp}/hh_manual_cleaning_educ_temp2", nogenerate
replace valid=0 if pb_SS==1

**Identifying phone numbers x respondent name for which we have more than 1 complete and successful interview
g succ_complete = (complete == 1) 
bysort phone_number resp_name: egen nb_succ_complete = sum(succ_complete)
*br if nb_succ_complete > 1 & proceed == 1 & complete == 1
sort phone_number resp_name
distinct phone_number if nb_succ_complete > 1

**Cleaning duplicates due to the problem of the Survey Solutions app
* Due to an error owing to the version of the Interviewer app on the first days, the Enumerators had to call back the respondents - only the final submissions contain all the answers and can be considered valid
gsort -succ_complete -valid phone_number resp_name start_time
g temp=1
replace temp=0 if (phone_number == phone_number[_n-1] & resp_name == resp_name[_n-1])
replace valid=0 if temp==0 & nb_succ_complete > 1 & succ_complete == 1

*Checking remaining duplicates
g successful_valid = (succ_complete == 1 & valid == 1)
bysort phone_number resp_name: egen nb_succ_complete_after_cleaning = sum(successful_valid)
distinct phone_number if nb_succ_complete_after_cleaning > 1
*br if nb_succ_complete_after_cleaning > 1 & proceed==1 & complete==1
*order enum_name start_time, after(attempt)
*order enum_id missing_prop, last

save "${gsdData}/0-RawTemp/hh_manual_cleaning_educ.dta", replace

***Aggregating at the phone number x respondent name level
collapse (max) valid successful successful_valid complete phone_not_exist no_consent max_attempts=attempt pb_SS (sum) nb_attempts=index, by(phone_number resp_name)

*Creating status of phone number x respondent name
g to_be_continued = (nb_attempts<5 & successful==0 & phone_not_exist!=1 & no_consent!=1) /*corresponds to phone number x respondent name for which we have less than five unsuccessful attempts*/
g discard = (successful_valid==1 | phone_not_exist==1 | no_consent==1 | nb_attempts>=5) /*corresponds to phone number x respondent name that do not need to be called again - either successful valid interview, or phone number does not exist, or no consent*/
g to_be_redone = ((pb_SS==1 | complete==0) & discard!=1) /*corresponds to phone number x respondent names for which a call- back is necessary - either problem with Survey Solutions app or incomplete interview*/

*Checking that the status are mutually exclusive
g test = discard + to_be_continued + to_be_redone
tab test
tab successful_valid
tab to_be_continued
tab to_be_redone
save "${gsdTemp}/hh_status_collapse_educ", replace

*-------------------------------------------------------------------
*
*     FINAL MERGE WITH DATABASE
*     
*     This do-file merges the database from the phone survey with
*     the database from the main data collection
*                             
*-------------------------------------------------------------------

*Importing phone survey database at the household level
use "${gsdData}/0-RawTemp/hh_manual_cleaning_educ.dta", clear
*Keeping only valid and successful submissions
keep if successful_valid==1
*Merging with education roster of the phone survey
merge 1:m interview__id using "${gsdData}/0-RawTemp/hhroster_manual_cleaning_educ.dta"
*Keeping only valid and successful submissions
drop if _merge == 2
keep phone_number resp_name hh_list hhm_age hhm_edu_ever hhm_edu_years hhm_edu_years_kdk hhm_edu_level hhm_edu_level_other
rename (hhm_edu_ever hhm_edu_years hhm_edu_years_kdk hhm_edu_level hhm_edu_level_other) (hhm_edu_ever_1 hhm_edu_years_1 hhm_edu_years_kdk_1 hhm_edu_level_1 hhm_edu_level_other_1)

*Merging with list of phone numbers to retrieve the interview__id of the original database
merge m:1 phone_number resp_name using "${gsdData}/0-RawTemp/hh_list_phone_numbers_final.dta", keepusing(interview__id) keep(match) nogenerate
drop phone_number resp_name
save "${gsdTemp}/hh_manual_cleaning_educ_for_merge.dta", replace

*Adding education information from phone survey in urban, rural, IDPs database
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning.dta", clear
merge m:1 interview__id hh_list hhm_age using "${gsdTemp}/hh_manual_cleaning_educ_for_merge.dta"
drop if _merge==2
foreach var of varlist hhm_edu_ever hhm_edu_years hhm_edu_years_kdk hhm_edu_level hhm_edu_level_other {
	replace `var' = `var'_1 if _merge == 3
	drop `var'_1
}
drop _merge
save "${gsdData}/0-RawTemp/hhroster_age_after_phone_survey.dta", replace
 
*Adding education information from phone survey in nomads database
use "${gsdData}/0-RawTemp/hhroster_age_manual_cleaning_nomads.dta", clear
merge m:1 interview__id hh_list hhm_age using "${gsdTemp}/hh_manual_cleaning_educ_for_merge.dta"
drop if _merge==2 /*urban/rural/IDPs*/
foreach var of varlist hhm_edu_ever hhm_edu_years hhm_edu_years_kdk hhm_edu_level hhm_edu_level_other {
	replace `var' = `var'_1 if _merge == 3
	drop `var'_1
}
drop _merge
save "${gsdData}/0-RawTemp/hhroster_age_nomads_after_phone_survey.dta", replace

