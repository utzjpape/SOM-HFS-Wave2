*introduce manual corrections and generate dta files with valid submissions

set more off
set seed 23081920 
set sortseed 11041925

*prepare file from list of EAs included in the final sample 
use "${gsdDataRaw}/EAs_sample.dta", clear
*drop an EA that was a replacement that was never executed
drop if ea=="16010010644" 
*run consistency checks 
run "${gsdDo}\consistency_EAs_final_sample.do"
keep if sample_final==1
save "${gsdData}\0-RawTemp\EAs_sample_clean.dta", replace

*prepare file from list of EBs included in the final sample 
use "${gsdDataRaw}/EBs_sample.dta", clear
*run consistency checks 
run "${gsdDo}\consistency_EBs_final_sample.do"
*separate EA name and block for the merge with hh dataset
split eb, parse(-)
rename eb eb_full
rename eb1 ea_mog
rename eb2 ea_block
destring ea_block, replace
destring ea_mog, replace
*correct the strata for IDPs in Mogadishu
replace strata=105 if ea_mog==999000050 | ea_mog==999000047  | ea_mog==999000045  | ea_mog==999000046  | ea_mog==999000049  | ea_mog==999000041  | ea_mog==999000040  | ea_mog==999000038  | ea_mog==999000036  | ea_mog==999000035  | ea_mog==999000034  | ea_mog==999000032  | ea_mog==999000031  | ea_mog==999000029  | ea_mog==999000027  | ea_mog==999000025  | ea_mog==999000024
save "${gsdData}\0-RawTemp\EBs_sample_clean.dta", replace

*parent file: keep only valid submissions and introduce corrections from Altai on parent files
use "${gsdDataRaw}/hh.dta", clear
run "${gsdDo}\manualcorrections_mog.do"
run "${gsdDo}\manualcorrections_pld.do"
run "${gsdDo}\manualcorrections_sld.do"
merge m:1 key using "${gsdData}/0-RawTemp/valid_keys.dta", keep(match) nogen
keep if successful_valid==1
drop successful_valid
save "${gsdData}/0-RawTemp/hh_valid_listing.dta", replace

*keep only those submissions from EAs included in the final sample 
merge m:1 full_l using "${gsdData}/0-RawTemp/EAs_sample_clean.dta", force nogen keep(match)
renam (sample_initial sample_final r_seq r_reason valid_interviews) (sample_initial_ea sample_final_ea r_seq_ea r_reason_ea valid_interviews_ea)

*keep only those submissions from EBs included in the final sample 
*obtain IDs of EAs according to the format of the final sample file 
split full_l, parse(,)
split full_l3
split full_l2, p(`=char(1)')
gen ea_idp_final= full_l21+ "_" + full_l31 
egen ea_final=concat(ea), format(%16.0g)
replace ea_final=ea_idp_final if idp_ea_yn==1
rename ea ea_original
rename ea_final ea
gen ea_mog=ea if ea_zone==4
*standarize the name of EAs
replace ea_mog="999000050" if full_l=="Boondheere, Safaaradda Talyaaniga, 1-1"
replace ea_mog="999000047" if full_l=="Daynile, Beelo, 4-1"
replace ea_mog="999000045" if full_l=="Daynile, Kulmis, 6-1"
replace ea_mog="999000046" if full_l=="Daynile, Qiyaad, 5-1"
replace ea_mog="999000049" if full_l=="Daynile, Saban Saban 3, 2-1"
replace ea_mog="999000041" if full_l=="Dharkenley, Badbaado2, 10-1"
replace ea_mog="999000040" if full_l=="Dharkenley, Beer Gadiid C, 11-1"
replace ea_mog="999000038" if full_l=="Dharkenley, Dalada Ramla, 13-1"
replace ea_mog="999000036" if full_l=="Dharkenley, Hosweyne, 15-1"
replace ea_mog="999000035" if full_l=="Dharkenley, Nunow, 16-1"
replace ea_mog="999000034" if full_l=="Dharkenley, Samafale, 17-1"
replace ea_mog="999000032" if full_l=="Hodan, Balcad, 19-1"
replace ea_mog="999000031" if full_l=="Hodan, Darasalam, 20-1"
replace ea_mog="999000029" if full_l=="Hodan, Labsame, 22-1"
replace ea_mog="999000027" if full_l=="Hodan, Unlay, 24-1"
replace ea_mog="999000025" if full_l=="Kaaraan, Atowbal 1, 26-1"
replace ea_mog="999000024" if full_l=="Wadajir, Rajo A, 27-1"
destring ea_mog, replace
merge m:1 ea_mog ea_block using "${gsdData}\0-RawTemp\EBs_sample_clean.dta", force keep(master match) 
drop if sample_final==0 & _merge==3 & strata==101
renam (sample_initial sample_final r_seq r_reason valid_interviews) (sample_initial_eb sample_final_eb r_seq_eb r_reason_eb valid_interviews_eb)
drop _merge
save "${gsdData}/0-RawTemp/hh_valid.dta", replace
*valid keys for child files
keep key 
save "${gsdTemp}/valid_keys_child_files.dta", replace
	
*child files: keep only valid submissions 
foreach suff in "hhm_c_illnesses" "hhm" "hhm_c_names" "hh_e_food" "hh_f_nfood" "hh_g_livestock" "hh_h_assets" "hh_k_fsecurity" "hh_l_incomesources" "hh_m_enterprises" "hh_n_shocks" {
	use "${gsdDataRaw}/`suff'.dta", clear
    ren key child_key 
	rename parent_key key
    replace key=substr(key,1,41)
    merge m:1 key using "${gsdTemp}/valid_keys_child_files.dta", keep(match) nogen
	save "${gsdData}/0-RawTemp/`suff'_valid.dta", replace
}
