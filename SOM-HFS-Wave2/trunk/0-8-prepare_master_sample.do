*creates and cleans the final list of EAs for IPD and non-IDP records

set more off
set seed 23081580 
set sortseed 11041555

*append all EAs
import excel "${gsdDataRaw}\EA-MasterStrata_v13.xlsx", sheet("Master_A") firstrow clear
keep ea zone_name reg_name dist_name sett_name hh_n  curr_filter prob
tostring curr_filter, replace
save "${gsdData}/0-RawTemp/EAs_mog.dta", replace

local locsheet = "B C D"
forv i=1/3 {
	local sheet: word `i' of `locsheet'
    import excel "${gsdDataRaw}\EA-MasterStrata_v13.xlsx", sheet("Master_`sheet'") firstrow clear
	drop if _n==1
	rename (A B C D E F H N Y AA) (ea zone_name reg_name dist_name sett_name curr_filter hh_n prob stratum strata_accgps)
	keep ea zone_name reg_name dist_name sett_name hh_n curr_filter prob stratum strata_accgps
	destring hh_n, replace
	destring prob, replace
	destring stratum, replace
	tostring curr_filter, replace
	save "${gsdData}/0-RawTemp/EAs_`i'.dta", replace
}

*for IDPs
import excel "${gsdDataRaw}\EA_IDP-MasterStrata.xlsx", sheet("Master List_IDP") firstrow clear
drop if zone_name==""
gen ea_code=campname
keep ea_code ea zone_name reg_name dist_name hh_n Selected Replacement Segmentcode curr_filter prob
ren (Selected Replacement Segmentcode ea) (selected replace segment_code ea_idp)
gen stratum=.
replace stratum=105 if zone_name=="South-Central"
replace stratum=205 if zone_name=="Puntland"
replace stratum=305 if zone_name=="Somaliland"
tostring curr_filter, replace
tab stratum selected, m

*integrate one dataset with both IPDs and non-IDPS
append using "${gsdData}/0-RawTemp/EAs_mog.dta"
append using "${gsdData}/0-RawTemp/EAs_1.dta"
append using "${gsdData}/0-RawTemp/EAs_2.dta"
append using "${gsdData}/0-RawTemp/EAs_3.dta"
label var hh_n "PESS from sampling frame"
ren *_name *_l
replace zone_l = trim(zone_l)
egen ea_string=concat(ea), format(%16.02f)
gen ea_final=ea_string if ea_string!="."
replace ea_final=ea_code if ea_final=="" & ea_code!=""

*District spellings
replace dist_l="Boondheere" if dist_l=="Bondhere"
replace dist_l="Bosaso" if dist_l=="Bossaso"
replace dist_l="Daynile" if dist_l=="Dayniile"
replace dist_l="Galkacyo" if dist_l=="Gaalkacyo"
replace dist_l="Kaaraan" if dist_l=="Karan"
replace dist_l="Hargeisa" if dist_l=="Hargeysa"
replace dist_l="Yaaqshiid" if dist_l=="Yaqshid"

*label
label define lstratum 0 "Unclassified"
local listi = "1 2 3 11 12 13"
local listli = "South-Central Puntland Somaliland Sanaag Sool Togdheer"
local listj = "1 2 3 4 5"
local listlj = "capital urban_centre urban_other rural IDP"
local n: word count `listi'
forv ki=1/`n' {
	local i: word `ki' of `listi'
	local li: word `ki' of `listli'
	forv kj=1/`n' {
		local j: word `kj' of `listj'
		local lj: word `kj' of `listlj'
		local ljj = subinstr("`lj'","_"," ",.)
		local ij = real("`i'0`j'")
		label define lstratum `ij' "`li' `ljj'", add
	}
}
label values stratum lstratum

*EA labels
gen ea_l=""
gen idp=mod(stratum,10)==5
*IDP labels
replace ea_l=subinstr(ea_str,"_",", ",1) if idp
*Non-IDP labels 
replace ea_l = substr(ea_str,1,3)+"-"+substr(ea_str,4,3)+"-"+substr(ea_str,7,4) if length(ea_str)==10 & !idp
replace ea_l = substr(ea_str,1,3)+"-"+substr(ea_str,4,4)+"-"+substr(ea_str,8,4) if length(ea_str)==11 & !idp
replace ea_l = substr(ea_str,1,4)+"-"+substr(ea_str,5,4)+"-"+substr(ea_str,9,4) if length(ea_str)==12 & !idp
*for full label
gen full_l = sett_l+", "+ea_l
replace full_l = dist_l+", "+ea_l if idp
order ea_final ea ea_code

*generate EA name consistent with the dataset of valid & successful submissions
split curr_filter, parse(_)
split ea_final, parse(.)
destring ea_final2, replace
tostring ea_idp, replace
gen o_ea=ea_final
replace o_ea=ea_final1 +"_"+ segment_code if _n<=62  & segment_code!="N/A"
replace o_ea=ea_final1 +"_"+ ea_idp + "-1" if _n<=62  & segment_code=="N/A"
replace o_ea=ea_final1 if ea_final2>=0 & ea_final2<.
replace o_ea=curr_filter4 if curr_filter4!=""
*finally some manual corrections are needed
replace o_ea="Ayaha 2_1-1" if o_ea=="Ayaha 2-2_1-1"
replace o_ea="Daami A_3-1" if o_ea=="Daami A -1_3-1"
replace o_ea="16010020018" if o_ea=="6010020018"
replace o_ea="16030460070" if o_ea=="6030460070"
replace o_ea="16040160030" if o_ea=="6040160030"
replace o_ea="16040280088" if o_ea=="6040280088"
replace o_ea="16050070006" if o_ea=="6050070006"
replace o_ea="16060460055" if o_ea=="6060460055"
replace o_ea="18010020004" if o_ea=="8010020004"
replace o_ea="18010020034" if o_ea=="8010020034"
replace o_ea="18020080040" if o_ea=="8020080040"
replace o_ea="18020080054" if o_ea=="8020080054"
replace o_ea="18020150111" if o_ea=="8020150111"
replace o_ea="18020150118" if o_ea=="8020150118"
replace o_ea="18030180051" if o_ea=="8030180051"

*correct the name of stratum for South-Central
replace stratum=101 if stratum>=.
replace stratum=105 if ea_string=="Camp Rajo IDP" | ea_string=="IDP" | ea_string=="IDP Badbaado"

*correct segment code
replace segment_code="" if segment_code=="N/A"

*drop variables not used in the estimation of sampling weights 
drop curr_filter* ea_final* ea_code ea_idp ea_l sett_l ea_string

 
save "${gsdData}\0-RawTemp\master_sample.dta", replace

