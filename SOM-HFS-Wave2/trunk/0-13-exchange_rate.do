*obtain the average exchange rate per zone to convert consumption into USD 

set more off 
set seed 23080980 
set sortseed 11040955

*Puntland: run the correction code from Altai 
use "${gsdDownloads}/HFS Exchange Rate Survey Puntland.dta", clear
replace today=td("12mar2016")  if key=="uuid:2aaa2e30-fcdd-43a5-8549-9fd4841ff0e1"
replace start_time=clock("12mar2016 03:03:41", "DMYhms") if key=="uuid:2aaa2e30-fcdd-43a5-8549-9fd4841ff0e1"
replace end_time=clock("12mar2016 03:06:43", "DMYhms") if key=="uuid:2aaa2e30-fcdd-43a5-8549-9fd4841ff0e1"
replace today=td("12mar2016")  if key=="uuid:dd9cd1f0-18da-4c83-ba86-1ce7e5362327"
replace start_time=clock("12mar2016 03:08:39", "DMYhms") if key=="uuid:dd9cd1f0-18da-4c83-ba86-1ce7e5362327"
replace end_time=clock("12mar2016 03:09:20", "DMYhms") if key=="uuid:dd9cd1f0-18da-4c83-ba86-1ce7e5362327"
replace today=td("12mar2016")  if key=="uuid:e9af551f-68b6-4aac-9f62-56f4e572276a"
replace start_time=clock("12mar2016 03:07:41", "DMYhms") if key=="uuid:e9af551f-68b6-4aac-9f62-56f4e572276a"
replace end_time=clock("12mar2016 03:08:35", "DMYhms") if key=="uuid:e9af551f-68b6-4aac-9f62-56f4e572276a"
replace today=td("12mar2016")  if key=="uuid:ccf70b52-4990-44cc-bfe5-56dd0fed62a0"
replace start_time=clock("12mar2016 03:06:53", "DMYhms") if key=="uuid:ccf70b52-4990-44cc-bfe5-56dd0fed62a0"
replace end_time=clock("12mar2016 03:07:35", "DMYhms") if key=="uuid:ccf70b52-4990-44cc-bfe5-56dd0fed62a0"
replace today=td("19mar2016")  if key=="uuid:9a18e41a-cedc-4488-93b9-eb44161b4f08"
replace start_time=clock("19mar2016 23:23:45", "DMYhms") if key=="uuid:9a18e41a-cedc-4488-93b9-eb44161b4f08"
replace end_time=clock("19mar2016 23:25:12", "DMYhms") if key=="uuid:9a18e41a-cedc-4488-93b9-eb44161b4f08"
replace today=td("19mar2016")  if key=="uuid:3c3a4391-7a5d-4e4c-9a5f-d4377febd8a9"
replace start_time=clock("19mar2016 23:22:51", "DMYhms") if key=="uuid:3c3a4391-7a5d-4e4c-9a5f-d4377febd8a9"
replace end_time=clock("19mar2016 23:23:39", "DMYhms") if key=="uuid:3c3a4391-7a5d-4e4c-9a5f-d4377febd8a9"
replace today=td("19mar2016")  if key=="uuid:cd6c4a7e-1a17-4300-89fb-f64e5b0441f1"
replace start_time=clock("19mar2016 23:25:16", "DMYhms") if key=="uuid:cd6c4a7e-1a17-4300-89fb-f64e5b0441f1"
replace end_time=clock("19mar2016 23:26:20", "DMYhms") if key=="uuid:cd6c4a7e-1a17-4300-89fb-f64e5b0441f1"
replace today=td("19mar2016")  if key=="uuid:ec4201df-1dba-4916-b1d4-057a3ba766d0"
replace start_time=clock("19mar2016 23:18:17", "DMYhms") if key=="uuid:ec4201df-1dba-4916-b1d4-057a3ba766d0"
replace end_time=clock("19mar2016 23:22:45", "DMYhms") if key=="uuid:ec4201df-1dba-4916-b1d4-057a3ba766d0"
replace today=td("06mar2016")  if key=="uuid:d15b1c67-ae57-4293-8adf-2d7774c6f87f"
replace start_time=clock("06mar2016 18:34:00", "DMYhms") if key=="uuid:d15b1c67-ae57-4293-8adf-2d7774c6f87f"
replace end_time=clock("06mar2016 18:35:50", "DMYhms") if key=="uuid:d15b1c67-ae57-4293-8adf-2d7774c6f87f"
replace today=td("06mar2016")  if key=="uuid:62d66b2c-ad6a-4e7c-baf5-e8f1a6dbf5a6"
replace start_time=clock("06mar2016 18:35:53", "DMYhms") if key=="uuid:62d66b2c-ad6a-4e7c-baf5-e8f1a6dbf5a6"
replace end_time=clock("06mar2016 18:36:18", "DMYhms") if key=="uuid:62d66b2c-ad6a-4e7c-baf5-e8f1a6dbf5a6"
replace today=td("06mar2016")  if key=="uuid:eb739282-b193-4264-b91b-b839c0279fef"
replace start_time=clock("06mar2016 18:36:21", "DMYhms") if key=="uuid:eb739282-b193-4264-b91b-b839c0279fef"
replace end_time=clock("06mar2016 18:36:51", "DMYhms") if key=="uuid:eb739282-b193-4264-b91b-b839c0279fef"
replace today=td("06mar2016")  if key=="uuid:64103357-8820-41bb-8829-acf096b314fc"
replace start_time=clock("06mar2016 18:36:54", "DMYhms") if key=="uuid:64103357-8820-41bb-8829-acf096b314fc"
replace end_time=clock("06mar2016 18:37:38", "DMYhms") if key=="uuid:64103357-8820-41bb-8829-acf096b314fc"

*Puntland: run checks from Altai 
*Criteria 1: Proportion of non-missing exchange rates
*Create dummy =1 if currency exchange rate is not empty 
gen bp_somsh_yes=(bp_somsh_n!="")
gen sp_somsh_yes=(sp_somsh_n!="")
gen cers_pr_yes_prop=(bp_somsh_yes+sp_somsh_yes)/2
bysort market today: egen cers_pr_yes_prop_today=mean(cers_pr_yes_prop)
*Criteria 2: GPS coordinates recorded
*Create dummy=1 if GPS is recorded  
gen GPS_coord=(loclatitude!=. & loclongitude!=. &  locaccuracy!=.)
label var GPS_coord "Whether the GPS coordinates were recorded"
bysort market today: egen GPS_coord_today=mean(GPS_coord)
*Criteria 3: 3 forms per market for the three types of vendors
bysort market today: egen market_count=count(market)
gen cers_valid=1 if market_count>=3
*To identify the enumerators
*Extracting enumerator id from qr_id
gen enum_id_bis=""
gen position=strpos(qr_id, "MS")
replace enum_id_bis=substr(qr_id, position+2, 1)
drop position
*Case where the enumerators don't/cannot scan the barcode
replace enum_id_bis=enum_name if qr_id==""
label var enum_id_bis "Interviewer's ID"
*Create a new variable for enumerator name 
gen enum_name_bis=""
replace enum_name_bis="Liban Mohamoud Said" if enum_id_bis=="3"
replace enum_name_bis="Maryam Mohamed Nur" if enum_id_bis=="2"
replace enum_name_bis="Nafisa Abdullahi Adem" if enum_id_bis=="1"
replace enum_name_bis="Nasteho Muse Gelle" if enum_id_bis=="4"
replace enum_name_bis=enum_name if  qr_id==""

*keep the dates of valid & successful interviews in Puntland (17th/February to 17th/March)
rename z zone
keep if today<=td(17Mar2016) & today>=td(17Feb2016)
keep if cers_valid==1
gen average_er=(bp_somsh + sp_somsh)/2
keep zone average_er
collapse (mean) average_er, by(zone)
save "${gsdTemp}/HFS Exchange Rate Survey Puntland.dta", replace


*Somaliland: run the correction code from Altai 
use "${gsdDownloads}/HFS Exchange Rate Survey Somaliland.dta", clear
*the enumerator (Nuraadiin) recorded several times the same forms (problem with GPS the first time)
drop if key=="uuid:78037c80-0aa6-4f78-a5ca-9d4cc7c03b97"
drop if key=="uuid:9e67ffed-e8de-4248-bf78-ff70dc28b854"
drop if key=="uuid:fa3769b2-62b5-44f7-aaf9-85dbcb8a566b"
*he also took all the information on the 22nd but recorded the GPS on the 23rd for two forms
replace today=td("22feb2016")  if key=="uuid:252e7f1e-1367-4560-8f15-071c0f39fd98"
replace start_time=clock("22feb2016 09:44:04", "DMYhms") if key=="uuid:252e7f1e-1367-4560-8f15-071c0f39fd98"
replace end_time=clock("22feb2016 09:56:44", "DMYhms") if key=="uuid:252e7f1e-1367-4560-8f15-071c0f39fd98"
replace today=td("22feb2016")  if key=="uuid:5bfa0663-dafc-4f87-9afe-32c60cb18bc0"
replace start_time=clock("22feb2016 09:29:37", "DMYhms") if key=="uuid:5bfa0663-dafc-4f87-9afe-32c60cb18bc0"
replace end_time=clock("22feb2016 09:57:26", "DMYhms") if key=="uuid:5bfa0663-dafc-4f87-9afe-32c60cb18bc0"
*amina recorded the information on a form that she started the week before (just her barcode) - but then the questionnaire was wrongly attributed to the 20th while it was on the 27th
replace today=td("27feb2016")  if key=="uuid:0de4f80b-4ba5-4ca7-9ba4-ba9365323a27"
replace start_time=clock("27feb2016 12:49:31", "DMYhms") if key=="uuid:0de4f80b-4ba5-4ca7-9ba4-ba9365323a27"
*A date does not correspond
replace today=td("05mar2016")  if key=="uuid:8fee0a4d-6bfa-417f-95a1-e597113e7121"
replace start_time=clock("05mar2016 10:39:36", "DMYhms") if key=="uuid:8fee0a4d-6bfa-417f-95a1-e597113e7121"
*drop some interviews that were sent to the server during the refresher training for the enumerators
drop if key=="uuid:825f8cc7-f676-4e72-a0b2-95fb793fb43a"
drop if key=="uuid:f9ce7985-5c82-4388-820a-847a3431f511"

*Somaliland: run checks from Altai 
*Criteria 1: Proportion of non-missing exchange rates
*Create dummy =1 if currency exchange rate is not empty 
gen bp_sldsh_yes=(bp_sldsh_n!="")
gen sp_sldsh_yes=(sp_sldsh_n!="")
gen cers_pr_yes_prop=(bp_sldsh_yes+sp_sldsh_yes)/2
bysort market today: egen cers_pr_yes_prop_today=mean(cers_pr_yes_prop)
*Criteria 2: GPS coordinates recorded
*Create dummy=1 if GPS is recorded  
gen GPS_coord=(loclatitude!=. & loclongitude!=. &  locaccuracy!=.)
label var GPS_coord "Whether the GPS coordinates were recorded"
bysort market today: egen GPS_coord_today=mean(GPS_coord)
*Criteria 3: 3 forms per market for the three types of vendors
bysort market today: egen market_count=count(market)
gen cers_valid=1 if market_count>=3
*To identify the enumerators
*Extracting enumerator id from qr_id
gen enum_id_bis=""
gen position=strpos(qr_id, ".")
replace enum_id_bis=substr(qr_id, position-1, 4)
replace enum_id_bis=substr(enum_id_bis, 1, 3) if (substr(enum_id_bis, 4, 1)!="0" & substr(enum_id_bis, 4, 1)!="1" & substr(enum_id_bis, 4, 1)!="2" & substr(enum_id_bis, 4, 1)!="3" & substr(enum_id_bis, 4, 1)!="4" & substr(enum_id_bis, 4, 1)!="5" & substr(enum_id_bis, 4, 1)!="6" & substr(enum_id_bis, 4, 1)!="7" & substr(enum_id_bis, 4, 1)!="8" & substr(enum_id_bis, 4, 1)!="9")
drop position
tab enum_id_bis
*Create a new variable for enumerator name 
gen enum_name_bis="Khaalid Mohamed Abdilahi" if enum_id_bis=="3.96"
replace enum_name_bis="Sa'ed Mohamed Hussein" if enum_id_bis=="3.98"
replace enum_name_bis="Nuradiin Ahmed Mohamed" if enum_id_bis=="3.95"
replace enum_name_bis="Amina Mohamed Mose" if enum_id_bis=="3.97"
replace enum_name_bis="A/rahman Ahmed Aden" if enum_id_bis=="3.99"
replace enum_name_bis=enum_name if  qr_id==""
replace enum_name_bis=enum_name if enum_name!=""

*keep the dates of valid & successful interviews in Somaliland (15th/February to 9th/March)
rename z zone
keep if today<=td(09Mar2016) & today>=td(15Feb2016)
keep if cers_valid==1
gen average_er=(bp_sldsh + sp_sldsh)/2
keep zone average_er
collapse (mean) average_er, by(zone)
save "${gsdTemp}/HFS Exchange Rate Survey Somaliland.dta", replace


*South-Central: no corrections from Altai 
use "${gsdDownloads}/HFS Exchange Rate Survey South-Central.dta", clear

*South-Central: run checks from Altai 
*Criteria 1: Proportion of non-missing exchange rates
*Create dummy =1 if currency exchange rate is not empty 
gen bp_somsh_yes=(bp_somsh_n!="")
gen sp_somsh_yes=(sp_somsh_n!="")
gen cers_pr_yes_prop=(bp_somsh_yes+sp_somsh_yes)/2
bysort market today: egen cers_pr_yes_prop_today=mean(cers_pr_yes_prop)
*Criteria 2: GPS coordinates recorded
*Create dummy=1 if GPS is recorded  
gen GPS_coord=(loclatitude!=. & loclongitude!=. &  locaccuracy!=.)
label var GPS_coord "Whether the GPS coordinates were recorded"
bysort market today: egen GPS_coord_today=mean(GPS_coord)
*Criteria 3: 3 forms per market for the three types of vendors
bysort market today: egen market_count=count(market)
gen cers_valid=1 if market_count>=3
*To identify the enumerators
*Extracting enumerator id from qr_id
gen enum_id_bis=""
gen position=strpos(qr_id, ".")
replace enum_id_bis=substr(qr_id, position-1, 4)
replace enum_id_bis=substr(enum_id_bis, 1, 3) if (substr(enum_id_bis, 4, 1)!="0" & substr(enum_id_bis, 4, 1)!="1" & substr(enum_id_bis, 4, 1)!="2" & substr(enum_id_bis, 4, 1)!="3" & substr(enum_id_bis, 4, 1)!="4" & substr(enum_id_bis, 4, 1)!="5" & substr(enum_id_bis, 4, 1)!="6" & substr(enum_id_bis, 4, 1)!="7" & substr(enum_id_bis, 4, 1)!="8" & substr(enum_id_bis, 4, 1)!="9")
drop position
*Case where the enumerators don't/cannot scan the barcode
replace enum_id_bis=enum_name if qr_id==""
label var enum_id_bis "Interviewer's ID"
*Create a new variable for enumerator name 
gen enum_name_bis=""
replace enum_name_bis="Mohommad Hassan Abdi" if enum_id_bis=="1.38"
replace enum_name_bis="Aisha Osman Abdi" if enum_id_bis=="1.39"
replace enum_name_bis=enum_name if  qr_id==""

*keep the dates of valid & successful interviews in South-Central (9th/February to 13th/March)
rename z zone
keep if today<=td(13Mar2016) & today>=td(09Feb2016)
keep if cers_valid==1
gen average_er=(bp_somsh + sp_somsh)/2
keep zone average_er
collapse (mean) average_er, by(zone)
replace zone="4" if zone=="1"
save "${gsdTemp}/HFS Exchange Rate Survey South-Central.dta", replace


*append all files and save the output file to be used in cleaning food consumption
use "${gsdTemp}/HFS Exchange Rate Survey Puntland.dta", clear
append using "${gsdTemp}/HFS Exchange Rate Survey South-Central.dta"
append using "${gsdTemp}/HFS Exchange Rate Survey Somaliland.dta"
destring zone, replace
egen x = mean(average_er) if zone!=3
egen global_er = max(x)
label var average_er "Local currency exchange rate to 1 USD"
label var global_er "Exchange Rate 1 USD in SSh"
drop x
save "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", replace
