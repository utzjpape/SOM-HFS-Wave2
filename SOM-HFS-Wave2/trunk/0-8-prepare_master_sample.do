*creates and cleans the final list of EAs for IPD and non-IDP records

set more off
set seed 23081580 
set sortseed 11041555


********************************************************************
*Sampling frame for urban and rural areas
********************************************************************
forval i=25/34 {
	import excel "${gsdDataRaw}\SampleDesign_Master_v4.xlsx", sheet("`i'") firstrow case(lower) clear
	drop if strata_id==.
	keep strata_id strata psu_id to_sec_pop psu_pop probabilit
	save "${gsdTemp}\master_psu_`i'.dta", replace
}
forval i=37/57 {
	import excel "${gsdDataRaw}\SampleDesign_Master_v4.xlsx", sheet("`i'") firstrow case(lower) clear
	drop if strata_id==.
	keep strata_id strata psu_id to_sec_pop psu_pop probabilit
	save "${gsdTemp}\master_psu_`i'.dta", replace
}
use "${gsdTemp}\master_psu_25.dta", replace
forval i=26/34 {
	append using "${gsdTemp}\master_psu_`i'.dta"
}
forval i=37/57 {
	append using "${gsdTemp}\master_psu_`i'.dta"
}
rename probabilit prob 
label var prob "Probability of selection for EA"
label var strata "Strata Name"
rename strata strata_name
label var to_sec_pop "Total population in Strata"
rename to_sec_pop tot_pop_strata
label var psu_pop "Total population in EA"
rename psu_pop tot_pop_psu
*Include household count by strata from PESS 
gen tot_hhs_strata=27092 if strata_id==25	
replace tot_hhs_strata=13254 if strata_id==26
replace tot_hhs_strata=50099 if strata_id==27
replace tot_hhs_strata=13446 if strata_id==28
replace tot_hhs_strata=7855 if strata_id==29
replace tot_hhs_strata=29745 if strata_id==30
replace tot_hhs_strata=30520 if strata_id==31
replace tot_hhs_strata=30522 if strata_id==32
replace tot_hhs_strata=16881 if strata_id==33
replace tot_hhs_strata=30324 if strata_id==34
replace tot_hhs_strata=187246 if strata_id==37
replace tot_hhs_strata=11209 if strata_id==38
replace tot_hhs_strata=77838 if strata_id==39
replace tot_hhs_strata=11817 if strata_id==40
replace tot_hhs_strata=62496 if strata_id==41
replace tot_hhs_strata=4658 if strata_id==42
replace tot_hhs_strata=23110 if strata_id==43
replace tot_hhs_strata=20384 if strata_id==44
replace tot_hhs_strata=33747 if strata_id==45
replace tot_hhs_strata=4278 if strata_id==46
replace tot_hhs_strata=21274 if strata_id==46
replace tot_hhs_strata=2140 if strata_id==47
replace tot_hhs_strata=21018 if strata_id==47
replace tot_hhs_strata=9384 if strata_id==48
replace tot_hhs_strata=82240 if strata_id==49
replace tot_hhs_strata=24900 if strata_id==50
replace tot_hhs_strata=123390 if strata_id==51
replace tot_hhs_strata=19527 if strata_id==52
replace tot_hhs_strata=20597 if strata_id==53
replace tot_hhs_strata=9417 if strata_id==54
replace tot_hhs_strata=88847 if strata_id==55
replace tot_hhs_strata=97619 if strata_id==56
replace tot_hhs_strata=31439 if strata_id==57
*Use no. of hhs from PESS and share of population to derive hhs per EA 
gen tot_hhs_psu=(prob)*tot_hhs_strata 
save "${gsdTemp}\master_urban_rural.dta", replace


********************************************************************
*Sampling frame for IDPs
********************************************************************
foreach x in "1_Buloburto EA" "1_Jowhar EA" "1_Maxaas EA" "3_Luuq EA" "3_Afmadow EA" "3_Kismayo EA" "4_Mogadishu EA" "5_Qardho EA" "5_Galkaacyo_North EA" "5_Galkaacyo_South EA" "6_Burao EA" "6_Hargeisa EA" "7_Baidoa EA" "7_Marca EA" {
	import excel "${gsdDataRaw}\IDPMasterStrata_v15.xlsx", sheet("`x'") firstrow case(lower) clear
	drop if strata_id>=.
	rename (idp_camp ea_id prop_sel no_blocks) (strata_name psu_id prob no_blocks_ea)
	keep strata_id strata_name psu_id prob no_blocks_ea
	duplicates drop 
	destring psu_id, replace
	save "${gsdTemp}\master_psu_`x'.dta", replace
}
use "${gsdTemp}\master_psu_1_Buloburto EA.dta", clear
foreach x in "1_Jowhar EA" "1_Maxaas EA" "3_Luuq EA" "3_Afmadow EA" "3_Kismayo EA" "4_Mogadishu EA" "5_Qardho EA" "5_Galkaacyo_North EA" "5_Galkaacyo_South EA" "6_Burao EA" "6_Hargeisa EA" "7_Baidoa EA" "7_Marca EA" {
	append using "${gsdTemp}\master_psu_`x'.dta"
}
*Include household count from PESS
gen hhs_pess=1749 if strata_name=="Buloburto"
replace hhs_pess=14731 if strata_name=="Jowhar"
replace hhs_pess=12472 if strata_name=="Afmadow, Diff and Dhobley"
replace hhs_pess=5400 if strata_name=="Baidoa"
replace hhs_pess=6688 if strata_name=="Burao"
replace hhs_pess=20057 if strata_name=="Gaalkacyo North"
replace hhs_pess=15970 if strata_name=="Gaalkacyo South"
replace hhs_pess=12995 if strata_name=="Hargeisa"
replace hhs_pess=12104 if strata_name=="Kismayo"
replace hhs_pess=23001 if strata_name=="Luuq"
replace hhs_pess=8000 if strata_name=="Marca"
replace hhs_pess=1353 if strata_name=="Maxaas"
replace hhs_pess=115775 if strata_name=="Mogadishu"
replace hhs_pess=27068 if strata_name=="Qardho"
gen tot_hhs_psu=prob*hhs_pess
drop hhs_pess
gen tot_hhs_strata=19640 if strata_id==1
replace tot_hhs_strata=47577 if strata_id==3
replace tot_hhs_strata=115775 if strata_id==4
replace tot_hhs_strata=64895 if strata_id==5
replace tot_hhs_strata=19683 if strata_id==6
replace tot_hhs_strata=13400 if strata_id==7
bys strata_id: egen tot_hhs_sel_camp_strata=sum(tot_hhs_psu) 
drop no_blocks_ea
order strata_id strata_name psu_id tot_hhs_strata tot_hhs_sel_camp_strata tot_hhs_psu prob
save "${gsdTemp}\master_idps.dta", replace


********************************************************************
*Sampling frame for host communitites
********************************************************************
import excel "${gsdDataRaw}\HostCommunities-SampleMaster_v1.xlsx", sheet("Sampling") firstrow case(lower) clear
rename (strata probselection ) (strata_name prob)
keep strata_id strata_name psu_id prob 
gen host_ea=1
*Include population count 
merge 1:1 psu_id using "${gsdTemp}\master_urban_rural.dta", nogen keep(match) keepusing(tot_hhs_psu)
bys strata_id: egen tot_hhs_strata=sum(tot_hhs_psu)
order strata_id strata_name psu_id tot_hhs_strata tot_hhs_psu prob
save "${gsdTemp}\master_host.dta", replace


********************************************************************
*Integrate a full master sample
********************************************************************
use "${gsdTemp}\master_urban_rural.dta", clear
append using "${gsdTemp}\master_idps.dta"
append using "${gsdTemp}\master_host.dta"
drop tot_pop_strata tot_pop_psu
label var tot_hhs_strata "Total no. HHs in Strata"
label var tot_hhs_psu "Total no. HHs in EA"
label var host_ea "Host EA: Yes or No"
save "${gsdData}\0-RawTemp\master_sample.dta", replace
