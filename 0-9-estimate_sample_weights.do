*calculate sample weights considering all households and excluding the ones with missing values in consumption

set more off
set seed 23061980 
set sortseed 11021955

*All households: for Somaliland and Puntland

*obtain the number of EAs selected for each strata
use "${gsdData}\0-RawTemp\hh_valid.dta", clear
*include the changes made to have a dataset with complete submissions
drop if key=="uuid:0c00c974-ad66-4ed8-8a95-826d44f3c1f7" | key=="uuid:a66cb5aa-67ae-4c4e-abc5-2afba4c5ea7c" | key=="uuid:b99dfaca-9f00-4280-9e79-ac70b8913ce4" | key=="uuid:f0e2441a-b30f-4a4a-9924-99897bebc5ba"
collapse (first) strata, by(ea)
gen d=1 
bys strata: egen n_ea_select_strata=total(d)
label var n_ea_select_strata "No of EAs selected by strata"
drop d
save "${gsdTemp}\n_ea_select_strata.dta", replace

*use the valid dataset to construct the template for the estimation of sample weights
use "${gsdData}\0-RawTemp\hh_valid.dta", clear
*include the changes made to have a dataset with complete submissions
drop if key=="uuid:0c00c974-ad66-4ed8-8a95-826d44f3c1f7" | key=="uuid:a66cb5aa-67ae-4c4e-abc5-2afba4c5ea7c" | key=="uuid:b99dfaca-9f00-4280-9e79-ac70b8913ce4" | key=="uuid:f0e2441a-b30f-4a4a-9924-99897bebc5ba"
keep key strata o_ea ea full_l
order key strata full_l ea o_ea
destring strata,replace
merge m:1 ea strata using "${gsdTemp}\n_ea_select_strata.dta", assert(match) nogen
*include the name of the EA in o_ea for those that were not replaced
replace o_ea=ea if o_ea==""

*obtain the size of the original EA
merge m:1 o_ea using "${gsdData}\0-RawTemp\master_sample.dta", nogen keep(match master) keepusing(hh_n prob)
rename hh_n size_o_ea
label var size_o_ea "size of original EA"
rename prob prob_frame
replace ea="18020080054" if ea=="8020080054"
replace ea="6060420042" if ea=="16060420042"
replace ea="6060420045" if ea=="16060420045"
replace ea="8020150110" if ea=="18020150110"
replace ea="8030480096" if ea=="18030480096"
replace ea="8020030005" if ea=="18020030005"
replace ea="6040220054" if ea=="16040220054"
save "${gsdTemp}\weights_listing.dta", replace

*total number of households in strata 
use "${gsdData}\0-RawTemp\master_sample.dta", clear
rename ea ea_original
rename o_ea ea
rename stratum strata
*obtain the total size of strata and EA from sampling frame 
bys ea: egen tot_hh_ea_frame=sum(hh_n)
label var tot_hh_ea_fram "Total size EA from sampling frame"
bys strata: egen size_strata=sum(hh_n)
merge 1:m ea using "${gsdTemp}\weights_listing.dta", nogen keep(match) 
keep key strata reg_l dist_l full_l ea o_ea n_ea_select_strata size_o_ea prob_frame tot_hh_ea_frame size_strata
order key strata reg_l dist_l full_l ea o_ea prob_frame n_ea_select_strata size_o_ea tot_hh_ea_frame size_strata

*obtain the number of hh selected
gen hh_selected=12
*obtain the number of hh interviewd
bys ea: gen hh=_n
bys ea: egen hh_itw=max(hh)
drop hh

*number of hhs in each ea from the listing form 
*exclude mogadishu and idp camps in south-central
drop if strata==101 | strata==105 
merge m:1 ea using "${gsdData}\0-RawTemp\listing_ea.dta", nogen keep(match) 
rename d hhs_ea
label var hhs_ea "No hhs in each ea from listing"
order region
save "${gsdTemp}\weights_data_allhh_sld_pld.dta", replace

*estimation of sample weights from listing
gen p1=(n_ea_select_strata*size_o_ea)/size_strata
label var p1 "Probabity of EA selection"
gen p2=hh_selected/ hhs_ea
label var p2 "Probability of hh selection"
gen attrition=hh_selected/hh_itw
gen hhweight_temp=attrition/(p1*p2)

*obtain hh weights from the sample frame 
drop prob_frame
gen p1_frame=(n_ea_select_strata*tot_hh_ea_frame)/size_strata
gen p2_frame=hh_selected/ tot_hh_ea_frame
gen hhweight_frame=attrition/(p1_frame*p2_frame)
bys strata: egen check_frame=sum(hhweight_frame)
save "${gsdTemp}\weights_listing.dta", replace

*include the number of households in each PESS region
import excel "${gsdDataRaw}/PESS_regions.xlsx", sheet("Astrata") firstrow case(lower) clear
drop pess_region
drop if astrata==.
rename hhs_tot hhs_tot_astrata
save "${gsdData}\1-CleanInput\households_pess.dta", replace


*sclae to conserve population counts per strata but using our listing (Master Sample)
use "${gsdTemp}\weights_listing.dta", replace
gen astrata=11 if strata==101
replace astrata=3 if strata==105 | strata==205 | strata==305
replace astrata=12 if strata==201
replace astrata=13 if strata==202 | strata==203
replace astrata=21 if strata==204
replace astrata=14 if strata==301
replace astrata=15 if strata==302 | strata==303 | strata==1103  | strata==1203 | strata==1303
replace astrata=22 if strata==304 | strata==1204 
preserve 
merge m:1 astrata using "${gsdData}\1-CleanInput\households_pess.dta", nogen keep(match)
bysort astrata: egen tot_hhweight_list=sum(hhweight_temp)
gen hhweight = hhweight_temp * (hhs_master_sample / tot_hhweight_list) if astrata!=3
replace hhweight= hhweight_temp if astrata==3
*check consistency of household weights
bys astrata: egen check=sum(hhweight)
assert (round(hhs_master_sample) == round(check)) if astrata!=3
keep key astrata hhweight reg_l dist_l
save "${gsdTemp}\weights_listing.dta", replace
restore

*include astrata to scale population to PESS region totals 
merge m:1 astrata using "${gsdData}\1-CleanInput\households_pess.dta", nogen keep(matched)
bysort astrata: egen tot_hhweight_list=sum(hhweight_temp)
gen hhweight = hhweight_temp * (hhs_tot_astrata / tot_hhweight_list) if astrata!=3
replace hhweight=hhweight_temp if astrata==3
*check consistency of household weights (hhs in astrata from PESS regions)
bys astrata: egen check=sum(hhweight) 
assert (round(hhs_tot_astrata) == round(check)) if astrata!=3
rename hhweight hhweight_allstrata
keep key astrata hhweight_allstrata
save "${gsdTemp}\weights_listing_all.dta", replace



*All households: for South-Central

*count number of hh per EA and per strata from sample frame
use "${gsdData}\0-RawTemp\master_sample.dta", clear
keep if zone_l=="South-Central"
*size of strata 
bys stratum: egen strata_size=total(hh_n)
label var strata_size "size (total hhs) in the strata"
*size of EA 
gen ea_size=hh_n
label var ea_size "size (total hhs) in the EA"
*rename EAs according to the other files
replace o_ea="999000050" if o_ea=="Safaaradda Talyaaniga_1-1"
replace o_ea="999000047" if o_ea=="Beelo_4-1"
replace o_ea="999000045" if o_ea=="Kulmis_6-1"
replace o_ea="999000046" if o_ea=="Qiyaad_5-1"
replace o_ea="999000049" if o_ea=="Saban Saban 3_2-1"
replace o_ea="999000041" if o_ea=="Badbaado2_10-1"
replace o_ea="999000040" if o_ea=="Beer Gadiid C_11-1"
replace o_ea="999000038" if o_ea=="Dalada Ramla_13-1"
replace o_ea="999000036" if o_ea=="Hosweyne_15-1"
replace o_ea="999000035" if o_ea=="Nunow_16-1"
replace o_ea="999000034" if o_ea=="Samafale_17-1"
replace o_ea="999000032" if o_ea=="Balcad_19-1"
replace o_ea="999000031" if o_ea=="Darasalam_20-1"
replace o_ea="999000029" if o_ea=="Labsame_22-1"
replace o_ea="999000027" if o_ea=="Unlay_24-1"
replace o_ea="999000025" if o_ea=="Atowbal 1_26-1"
replace o_ea="999000024" if o_ea=="Rajo A_27-1"
*replace the ones not considered to have a clean variable for the merge
replace o_ea="" if o_ea=="Al Cadala_8-1" | o_ea=="Aws_9-1" | o_ea=="Axmad Gurey_30-1" | o_ea=="Bilan2 Umbrela_12-1" | o_ea=="Camp Rajo IDP" | o_ea=="Dharkenly baldeq_14-1" | o_ea=="Dooxo_7-1" | o_ea=="Gurmad_21-1" | o_ea=="Heladi_29-1" | o_ea=="IDP" | o_ea=="IDP Badbaado" | o_ea=="Naruro_23-1" | o_ea=="Rajo I_28-1" | o_ea=="Wadani_3-1"  | o_ea=="Xurnimo_18-1"  | o_ea=="Zonak_25-1" 
destring o_ea, replace
rename o_ea ea_mog
save "${gsdTemp}\sweights_mog_input.dta", replace

*retrieve the number of EBs in each EA and build the structure of the file 
use "${gsdData}\0-RawTemp\hh_valid.dta", clear
*include the changes made to have a dataset with complete submissions
drop if key=="uuid:0c00c974-ad66-4ed8-8a95-826d44f3c1f7" | key=="uuid:a66cb5aa-67ae-4c4e-abc5-2afba4c5ea7c" | key=="uuid:b99dfaca-9f00-4280-9e79-ac70b8913ce4" | key=="uuid:f0e2441a-b30f-4a4a-9924-99897bebc5ba"
keep if strata==101 | strata==105 
drop ea_mog
rename ea ea_mog
*similarly, rename EAs according to the correct numeric name from Altai
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
save "${gsdTemp}\sweights_master.dta", replace
*obtain the number of hh interviewed by block
gen d=1
collapse (sum) d, by(ea_mog ea_block)
rename d hh_itw_block
label var hh_itw_block "HHs interviewed in block"
save "${gsdTemp}\sweights_hh_eb.dta", replace

use "${gsdTemp}\sweights_master.dta", clear
*obtain the original block
split o_eb, parse(-)
drop o_eb1 o_eb
rename o_eb2 o_block
destring o_block, replace
replace o_block=ea_block if o_block==.
order key strata ea_mog ea_block o_block n_eb
*integrate with the previous results 
merge m:m ea_mog using "${gsdTemp}\sweights_mog_input.dta", nogen keep(match) keepusing(reg_l dist_l strata_size ea_size)
merge m:1 ea_mog ea_block using "${gsdTemp}\sweights_hh_eb.dta", nogen assert(match)
save "${gsdTemp}\sweights_master.dta", replace

*obtain the number of selected EAs in strata
collapse (first) strata, by(ea_mog)
gen select_ea_strata=1 
collapse (sum) select_ea_strata, by(strata)
label var select_ea_strata "No. of selected EAs in strata"
save "${gsdTemp}\sweights_selected_ea.dta", replace

*obtain the number of selected blocks in EA 
use "${gsdTemp}\sweights_master.dta", clear
collapse (first) strata, by(ea_mog ea_block)
gen select_block_ea=1 
collapse (sum) select_block_ea, by(ea_mog)
label var select_block_ea "No of selected blocks in EA"
save "${gsdTemp}\sweights_selected_blocks.dta", replace

*obtain the number of selected hh in each EA
use "${gsdTemp}\sweights_master.dta", clear
gen select_hh_ea=1 
collapse (sum) select_hh_ea, by(ea_mog)
label var select_hh_ea "No of selected hh in EA"
save "${gsdTemp}\sweights_selected_hhs.dta", replace

*integrate all the variables 
use "${gsdTemp}\sweights_master.dta", clear
merge m:1 strata using "${gsdTemp}\sweights_selected_ea.dta", nogen 
merge m:1 ea_mog using "${gsdTemp}\sweights_selected_blocks.dta", nogen
merge m:1 ea_mog using "${gsdTemp}\sweights_selected_hhs.dta", nogen
save "${gsdTemp}\sweights_master.dta", replace

*estimation of sample weights from segmentation
gen b=select_block_ea / n_eb
replace b=1 if select_block_ea>=. |  n_eb>=.
gen p1=((select_ea_strata*ea_size)/strata_size)*b
gen p2= p1 * select_hh_ea / ea_size
label var p2 "Household selection probability"
gen hhweight_temp= 1/p2

*sclae to conserve population counts per strata but using our listing (Master Sample) 
gen astrata=11 if strata==101
replace astrata=3 if strata==105 | strata==205 | strata==305
replace astrata=12 if strata==201
replace astrata=13 if strata==202 | strata==203
replace astrata=21 if strata==204
replace astrata=14 if strata==301
replace astrata=15 if strata==302 | strata==303 | strata==1103  | strata==1203 | strata==1303
replace astrata=22 if strata==304 | strata==1204 
preserve 
merge m:1 astrata using "${gsdData}\1-CleanInput\households_pess.dta", nogen keep(match)
bysort astrata: egen tot_hhweight=sum(hhweight_temp)
gen hhweight=hhweight_temp *(hhs_master_sample /tot_hhweight) if astrata!=3
replace hhweight= hhweight_temp if astrata==3
*check consistency of household weights
bys astrata: egen check=sum(hhweight)
assert (round(hhs_master_sample ) == round(check)) if astrata!=3
keep key astrata hhweight reg_l dist_l
save "${gsdTemp}\weights_sc.dta", replace
restore 

*include astrata to scale population to PESS region totals for all IDPs
merge m:1 astrata using "${gsdData}\1-CleanInput\households_pess.dta", nogen keep(matched)
bysort astrata: egen tot_hhweight_list=sum(hhweight_temp)
gen hhweight = hhweight_temp * (hhs_tot_astrata / tot_hhweight_list) if astrata!=3
replace hhweight=hhweight_temp if astrata==3
*check consistency of household weights (hhs in astrata from PESS regions)
bys astrata: egen check=sum(hhweight) 
assert (round(hhs_tot_astrata) == round(check)) if astrata!=3
rename hhweight hhweight_allstrata
keep key astrata hhweight_allstrata
save "${gsdTemp}\weights_sc_all.dta", replace



*include weights in the household dataset 

*append weights for all the regions
use "${gsdTemp}\weights_listing.dta", clear
append using "${gsdTemp}\weights_sc.dta"
*now scale all IDPs to all the hhs in Master Sample
merge m:1 astrata using "${gsdData}\1-CleanInput\households_pess.dta", nogen keep(matched)
bysort astrata: egen tot_hhweight=sum(hhweight)
replace hhweight=hhweight*(hhs_master_sample/tot_hhweight) if astrata==3
*check consistency of household weights from Master Sample for IDPs
bys astrata: egen check=sum(hhweight)
assert (round(hhs_master_sample) == round(check)) 
rename hhweight weight
save "${gsdTemp}\weights_all.dta", replace

*append weights for all the regions (All hhs in astrata from PESS regions)
use "${gsdTemp}\weights_listing_all.dta", clear
append using "${gsdTemp}\weights_sc_all.dta"
*now scale all IDPs to all the hhs in PESS regions
merge m:1 astrata using "${gsdData}\1-CleanInput\households_pess.dta", nogen keep(matched)
bysort astrata: egen tot_hhweight=sum(hhweight_allstrata)
replace hhweight_allstrata=hhweight_allstrata*(hhs_tot_astrata/tot_hhweight) if astrata==3
*check consistency of household weights from PESS regions 
bys astrata: egen check=sum(hhweight_allstrata)
assert (round(hhs_tot_astrata) == round(check)) 
keep key hhweight_allstrata
rename hhweight_allstrata weight_adj
save "${gsdTemp}\weights_all_adj.dta", replace


*include sample weights in the dataset 
use "${gsdData}\0-RawTemp\hh_complete.dta", clear
merge 1:1 key using "${gsdTemp}\weights_all.dta", nogen assert(match)
merge 1:1 key using "${gsdTemp}\weights_all_adj.dta", nogen assert(match)
drop n_eb astrata 
order reg_l dist_l weight weight_adj,after(ea)
label var weight "Household weight (unadjusted)"
label var weight_adj "Household weight (adjusted)"
label var strata "Strata"
rename reg_l reg_old
label var reg_old "ID of Regions (Old classification)"
rename dist_l district
label var district "ID of District"
save "${gsdData}\0-RawTemp\hh_sweights.dta", replace




*excluding hhs with missing values in consumption: for Somaliland and Puntland

*identify 52 households with no records (eventually missing values) in consumption
use "${gsdData}/0-RawTemp/hh_e_food_clean.dta", clear
merge m:1 key using "${gsdData}/0-RawTemp/hh_complete.dta", assert(match) nogen 
drop if cons==.z
*keep only households with no records of consumption
bys key: egen cons_hh=max(cons)
keep if cons_hh==0
bys key: egen include_hh=count(foodid) if cons==0 
*finally keep only 52 households that will have missing values in consumption
drop if include_hh<50 |  include_hh>=.
collapse (first) mod_item, by (key)
keep key 
save "${gsdTemp}\hh_nocons.dta", replace

*identify 1 households with zero food consumption in the core module
use "${gsdData}/0-RawTemp/hh_e_food_clean.dta", clear
merge m:1 key using "${gsdData}/0-RawTemp/hh_complete.dta", assert(match) nogen 
drop if cons==.z
bys key: egen prelim_cons_hh=sum(cons) if cons==1
bys key: egen cons_hh=max(prelim_cons_hh)
keep if cons_hh==1 & cons==1 & foodid==65 & cons_q_kg==0.75
keep key
save "${gsdTemp}\food_hhs_cons_exclude.dta", replace

*recover the template with all the data for the estimation of sampling weights 
use "${gsdTemp}\weights_data_allhh_sld_pld.dta", clear

*drop households with missing values in consumption and those with 
merge 1:1 key using "${gsdTemp}\hh_nocons.dta", nogen keep(master) 
merge 1:1 key using "${gsdTemp}\food_hhs_cons_exclude.dta", nogen keep(master) 

*estimation of sample weights from listing
gen p1=(n_ea_select_strata*size_o_ea)/size_strata
label var p1 "Probabity of EA selection"
gen p2=hh_selected/ hhs_ea
label var p2 "Probability of hh selection"
gen attrition=hh_selected/hh_itw
gen hhweight_temp=attrition/(p1*p2)

*obtain hh weights from the sample frame 
drop prob_frame
gen p1_frame=(n_ea_select_strata*tot_hh_ea_frame)/size_strata
gen p2_frame=hh_selected/ tot_hh_ea_frame
gen hhweight_frame=attrition/(p1_frame*p2_frame)
bys strata: egen check_frame=sum(hhweight_frame)

*sclae to conserve population counts per strata but using our listing (EAs accesible w/GPS from Master Sample)
gen astrata=11 if strata==101
replace astrata=3 if strata==105 | strata==205 | strata==305
replace astrata=12 if strata==201
replace astrata=13 if strata==202 | strata==203
replace astrata=21 if strata==204
replace astrata=14 if strata==301
replace astrata=15 if strata==302 | strata==303 | strata==1103  | strata==1203 | strata==1303
replace astrata=22 if strata==304 | strata==1204 
merge m:1 astrata using "${gsdData}\1-CleanInput\households_pess.dta", nogen keep(match)
bysort astrata: egen tot_hhweight_list=sum(hhweight_temp)
gen hhweight = hhweight_temp * (hhs_master_sample / tot_hhweight_list)
*check consistency of household weights (EAs accesible w/GPS)
bys astrata: egen check=sum(hhweight)
assert (round(hhs_master_sample) == round(check))
rename hhweight weight_pre_cons
keep key weight_pre_cons
save "${gsdTemp}\weights_listing_nocons.dta", replace



*excluding hhs with missing values in consumption: for South-Central

*recover the template with all the data for the estimation of sampling weights 
use "${gsdTemp}\sweights_master.dta", clear

*drop households with missing values in consumption
merge 1:1 key using "${gsdTemp}\hh_nocons.dta", nogen keep(master) 
merge 1:1 key using "${gsdTemp}\food_hhs_cons_exclude.dta", nogen keep(master) 

*estimation of sample weights from segmentation
gen b=select_block_ea / n_eb
replace b=1 if select_block_ea>=. |  n_eb>=.
gen p1=((select_ea_strata*ea_size)/strata_size)*b
gen p2= p1 * select_hh_ea / ea_size
label var p2 "Household selection probability"
gen hhweight_temp= 1/p2

*scale to conserve population counts per strata but using our listing (EAs accesible w/GPS from Master Sample)
gen astrata=11 if strata==101
replace astrata=3 if strata==105 | strata==205 | strata==305
replace astrata=12 if strata==201
replace astrata=13 if strata==202 | strata==203
replace astrata=21 if strata==204
replace astrata=14 if strata==301
replace astrata=15 if strata==302 | strata==303 | strata==1103  | strata==1203 | strata==1303
replace astrata=22 if strata==304 | strata==1204 
merge m:1 astrata using "${gsdData}\1-CleanInput\households_pess.dta", nogen keep(match)
bysort astrata: egen tot_hhweight=sum(hhweight_temp)
gen hhweight=hhweight_temp *(hhs_master_sample/tot_hhweight)
*check consistency of household weights (EAs accesible w/GPS)
*the coverage in south-central is 100%, so the weight is the same
bys astrata: egen check=sum(hhweight)
assert (round(hhs_master_sample) == round(check))
rename hhweight weight_pre_cons
keep key weight_pre_cons
save "${gsdTemp}\weights_sc_nocons.dta", replace




*include weights in the household dataset 

*append weights for all the regions (All hhs in Strata)
use "${gsdTemp}\weights_listing_nocons.dta", clear
append using "${gsdTemp}\weights_sc_nocons.dta"
save "${gsdTemp}\weights_all_nocons.dta", replace
*include sample weights in the dataset 
use "${gsdData}\0-RawTemp\hh_sweights.dta", clear
merge 1:1 key using "${gsdTemp}\weights_all_nocons.dta", nogen keep(match master)
rename weight_pre_cons weight_cons
label var weight_cons "Household weight (Pre-cons)"
order weight_cons,after(weight_adj)
save "${gsdData}\0-RawOutput\hh.dta", replace
