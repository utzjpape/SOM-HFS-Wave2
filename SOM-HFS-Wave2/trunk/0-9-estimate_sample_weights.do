*Calculate sampling weights 

set more off
set seed 23061980 
set sortseed 11021955


********************************************************************
* Urban (non-host) and rural households 
********************************************************************
/*
	Probability of selecting household h in EA i of strata j is given by
	Phij = P1 * P2 * P3 * P4 such that 

	P1=Probability of selecting the EA
	P2=Probability of selecting the Block
	P3=Probability of selecting the structure
	P4=Probability of selecting the household

	P1= EAj * HOi / Hj  
	P2= BSi / Bi
	P3= SSk/Sk
	P4= HSm / Hm

	Thus, the variables needed to estimate the sampling weights are:
	
	1.1 Number of EAs selected in strata j (EAj)
	1.2 Number of households estimated in the sample frame for the original EA i (HOi)
	1.3 Number of households estimated in the sample frame in strata j (Hj)
	2.1 Number of blocks selected in EA i (BSi)
	2.2 Number of blocks in EA i (Bi)
	3.1 Number of selected structures in block k (SSk)
	3.2 Number of structures in block k (Sk)
	4.1 Number of households selected in structure m (HSm)
	4.2 Number of households structure m (Hm)
	
*/

*1.1 Number of EAs selected in strata j (EAj)
use "${gsdDataRaw}\ListPSU_all_status_v7.dta", clear
drop if n_main_strata>=.
keep strata_id n_main_final_strata
rename n_main_final_strata n_sel_ea_strata
duplicates drop 
save "${gsdTemp}\sweights_1.1_urban_rural.dta", replace

*1.2 Number of households estimated in the sample frame for the original EA i (HOi)
*List of EAs from data collection 
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if (type==1 | type==2) & type_idp_host>=.
keep ea
rename ea id_ea
duplicates drop 
*Include id of replacement EA
merge 1:1 id_ea using "${gsdData}\0-RawTemp\EA_Replacement_Table_Complete.dta", nogen keep(match master) keepusing(o_ea o_ea_2 o_ea_3)
rename id_ea psu_id
*Obtain the number of households from master sample
preserve 
use "${gsdData}\0-RawTemp\master_sample.dta", clear
drop if host_ea==1
save "${gsdTemp}\master_sample_no_host.dta", replace
restore
merge 1:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order psu_id tot_hhs_psu
rename (psu_id tot_hhs_psu) (ea_id size_ea)
*Obtain the number of households from replacement
rename o_ea psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_1 size_ea_1)
*Obtain the final original size of the EA
gen size_o_ea=size_ea if ea_id_1==. 
replace size_o_ea=size_ea_1 if ea_id_1<. & size_o_ea>=.
keep ea_id size_o_ea
rename ea_id psu_id					
save "${gsdTemp}\sweights_1.2_urban_rural.dta", replace

*1.3 Number of households estimated in the sample frame in strata j (Hj)
use "${gsdData}\0-RawTemp\master_sample.dta", clear
drop if host_ea==1
keep strata_id tot_hhs_strata
duplicates drop
save "${gsdTemp}\sweights_1.3.dta", replace

*2.1 Number of blocks selected in EA i (BSi)
*2.2 Number of blocks in EA i (Bi)
*Low-rank replacement EAs 
import excel "${gsdDataRaw}\Inputs EAs.xls", sheet("Master EBs") firstrow case(lower) clear
drop if ea=="EA"
drop if block_sel_dummy=="0"
foreach var in block_sel_host block_sel_ur ea {
	destring `var', replace
}
collapse (sum) block_sel_host block_sel_ur, by(ea)
gen n_block_sel_ea=block_sel_host+block_sel_ur
keep ea n_block_sel_ea
rename ea psu_id
drop if n_block_sel_ea==0
save "${gsdTemp}\sweights_2.1_lowrank.dta", replace
import excel "${gsdDataRaw}\Inputs EAs.xls", sheet("Master EAs") firstrow case(lower) clear
drop if ea=="EA"
keep if (type_pop=="Urban/Rural" & status_psu_ur_idp=="Low-rank replacement not considered") | (type_pop=="Urban/Rural and Host" & status_psu_ur_idp=="Low-rank replacement not considered")
keep ea nb_blocks_ea
destring ea, replace
destring nb_blocks_ea, replace
rename (ea nb_blocks_ea) (psu_id n_block_ea)
merge 1:1 psu_id using "${gsdTemp}\sweights_2.1_lowrank.dta", nogen keep(match)
save "${gsdTemp}\sweights_2_lowrank.dta", replace
import excel "${gsdDataRaw}\MainRepPSUs_BlockSel_VBA_001.xlsx", sheet("Sheet1") firstrow case(lower) clear
keep psu_id tot_block nbblk2se
duplicates drop
rename (tot_block nbblk2se) (n_block_ea n_block_sel_ea)
append using "${gsdTemp}\sweights_2_lowrank.dta"
save "${gsdTemp}\sweights_2_urban_rural.dta", replace

*3.1 Number of selected structures in block k (SSk)
*3.2 Number of structures in block k (Sk)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if (type==1 | type==2) & type_idp_host>=.
egen exclude_structures=rowtotal(n_str_no_success__*) 
gen tot_n_str=n_str - exclude_structures
*Impute the median number of structures to missings and zero structures
bysort strata ea: egen prelim_ea_median=median(tot_n_str) 
bysort strata ea: egen ea_median=max(prelim_ea_median) 
replace tot_n_str=ea_median if tot_n_str>=. | tot_n_str==0
keep interview__id tot_n_str
save "${gsdTemp}\sweights_3_urban_rural.dta", replace

*4.1 Number of households selected in structure m (HSm)
*4.2 Number of households structure m (Hm)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if (type==1 | type==2) & type_idp_host>=.
egen exclude_hhs=rowtotal(n_hh_no_success__*) 
gen tot_n_hhs=n_hh - exclude_hhs
*Impute the median number of households to missings and zero households
bysort strata: egen prelim_ea_median=median(tot_n_hhs) 
bysort strata: egen ea_median=max(prelim_ea_median) 
replace tot_n_hhs=ea_median if (tot_n_hhs>=. | tot_n_hhs==0) & ea_median>=0
keep interview__id tot_n_hhs
save "${gsdTemp}\sweights_4_urban_rural.dta", replace

*Estimate P1
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if (type==1 | type==2) & type_idp_host>=.
keep interview__id strata ea
rename (strata ea) (strata_id psu_id)
merge m:1 strata_id using "${gsdTemp}\sweights_1.1_urban_rural.dta", nogen keep(master match)
merge m:1 psu_id using "${gsdTemp}\sweights_1.2_urban_rural.dta", nogen keep(master match)
merge m:1 strata_id using "${gsdTemp}\sweights_1.3.dta", nogen keep(master match)
*Manual correction for EA 165725 selected multiple times for replacement as original size needs to be distributed 
preserve 
keep if psu_id==165725 
set seed 23061980 
set sortseed 11021955
gen rand_165725=uniform() if psu_id==165725 
sort rand
*Original size from EA 163944, 164129 and 164481
gen size_o_ea_correct=29.59604 if _n<=12
replace size_o_ea_correct=244.8108 if _n>12
replace size_o_ea_correct=75.30555 if _n>24
keep interview__id size_o_ea_correct
save "${gsdTemp}\sweights_correction_1.dta", replace
restore
*Manual correction for EA 114743 selected multiple times for replacement as original size needs to be distributed 
preserve 
keep if psu_id==114743 
set seed 23061980 
set sortseed 11021955
gen rand_114743=uniform() if psu_id==114743
sort rand
*Original size from EA 113690 and 117488
gen size_o_ea_correct=1866.371 if _n<=12
replace size_o_ea_correct=1918.516 if _n>12
keep interview__id size_o_ea_correct
append using "${gsdTemp}\sweights_correction_1.dta"
save "${gsdTemp}\sweights_correction_p1.dta", replace
restore 
merge 1:1 interview__id using "${gsdTemp}\sweights_correction_p1.dta", nogen keep(match master)
replace size_o_ea=size_o_ea_correct if psu_id==165725 |  psu_id==114743 
drop size_o_ea_correct
gen p1=((n_sel_ea_strata* size_o_ea)/ tot_hhs_strata) 

*Estimate P2
merge m:1 psu_id using "${gsdTemp}\sweights_2_urban_rural.dta", nogen keep(master match)
gen p2=n_block_sel_ea/n_block_ea

*Estimate P3
merge m:1 interview__id using "${gsdTemp}\sweights_3_urban_rural.dta", nogen assert(match)
gen p3=1/tot_n_str

*Estimate P4
merge m:1 interview__id using "${gsdTemp}\sweights_4_urban_rural.dta", nogen assert(match)
gen p4=1/tot_n_hhs

*Estimate Probability of selection and sampling weights 
gen prob_sel=p1*p2*p3*p4
gen weight_temp=1/prob_sel
*Drop rural Jubbaland
drop if strata==32 | strata==34
keep interview__id weight_temp
save "${gsdTemp}\sweights_urban_rural.dta", replace


********************************************************************
* Host and Urban households 
********************************************************************
/*
	Probability of selecting household h in EA i of strata j is given by
	Phij = P1 * P2 * P3 *P4 such that 

	P1=Probability of selecting the EA from two separate sampling processes (for urban/rural households and host communities)
		P1a=Probability of selecting the EA from the sampling process for urban and rural areas
		P1b=Probability of selecting the EA from the sampling process for host communities
	P2=Probability of selecting the Block
	P3=Probability of selecting the household

	P1=  P1a + P1b – P1a*P1b
	P2= BSi / Bi
	P3= SSk/Sk
	P4= HSm / Hm

	
	Thus, the variables needed to estimate the sampling weights are:
	
	1.1 Number of EAs selected in the host community sample j (EAj)
	1.2 Number of households estimated in the sample frame for the original EA i (HOi)
	1.3 Number of households estimated in the sample frame in the host community sample (Hj)

	2.1 Number of blocks selected in EA i (BSi)
	2.2 Number of blocks in EA i (Bi)
	3.1 Number of selected structures in block k (SSk)
	3.2 Number of structures in block k (Sk)
	4.1 Number of households selected in structure m (HSm)
	4.2 Number of households structure m (Hm)
	
*/

*1.1 Number of EAs selected in the host community sample j (EAj)
use "${gsdDataRaw}\ListPSU_all_status_v7.dta", clear
drop n_main_final_strata
egen n_main_final_strata=sum(selected_host_final)
keep strata_id n_main_final_strata
rename n_main_final_strata n_sel_ea_strata_b
duplicates drop 
merge 1:1 strata_id using "${gsdTemp}\sweights_1.1_urban_rural.dta", nogen assert(match)
rename n_sel_ea_strata n_sel_ea_strata_a
save "${gsdTemp}\sweights_1.1_host.dta", replace

*1.2 Number of households estimated in the sample frame for the original EA i (HOi)
*List of EAs from data collection 
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
*keep if type_idp_host==2
keep ea
rename ea id_ea
duplicates drop 
*Include id of replacement EA
merge 1:1 id_ea using "${gsdData}\0-RawTemp\EA_Replacement_Table_Complete.dta", nogen keep(match master) keepusing(o_ea_h o_ea_2_h o_ea_3_h)
rename id_ea psu_id
*Obtain the number of households from master sample
preserve 
use "${gsdData}\0-RawTemp\master_sample.dta", clear
keep if host_ea==1
save "${gsdTemp}\master_sample_host.dta", replace
restore
merge 1:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order psu_id tot_hhs_psu
rename (psu_id tot_hhs_psu) (ea_id size_ea)
*Obtain the number of households from replacement
rename o_ea_h psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_1 size_ea_1)
*Obtain the final original size of the EA
gen size_o_ea_b=size_ea if ea_id_1==. 
replace size_o_ea_b=size_ea_1 if ea_id_1<. & size_o_ea>=.
keep ea_id size_o_ea_b
rename ea_id psu_id					
merge 1:1 psu_id using "${gsdTemp}\sweights_1.2_urban_rural.dta", nogen keep(master match)
*EAs that were only host
replace size_o_ea=size_o_ea_b if size_o_ea==.
order psu_id size_o_ea size_o_ea_b
collapse (max) size_o_ea size_o_ea_b, by(psu_id)
rename size_o_ea size_o_ea_a
save "${gsdTemp}\sweights_1.2_host.dta", replace

*1.3 Number of households estimated in the sample frame in in the host community sample (Hj)
use "${gsdData}\0-RawTemp\master_sample.dta", clear
keep if host_ea==1
egen tot_hhs_strata_b=sum(tot_hhs_psu)
keep strata_id tot_hhs_strata_b
duplicates drop
merge 1:1 strata_id  using "${gsdTemp}\sweights_1.3.dta", nogen keep(match)
rename tot_hhs_strata tot_hhs_strata_a
order strata_id tot_hhs_strata_a tot_hhs_strata_b
save "${gsdTemp}\sweights_1.3_host.dta", replace

*2.1 Number of blocks selected in EA i (BSi)
*2.2 Number of blocks in EA i (Bi)
import excel "${gsdDataRaw}\Inputs EAs.xls", sheet("Master EBs") firstrow case(lower) clear
drop if ea=="EA"
drop if block_sel_dummy=="0"
foreach var in block_sel_host block_sel_ur ea {
	destring `var', replace
}
collapse (sum) block_sel_host block_sel_ur, by(ea)
gen n_block_sel_ea=block_sel_host+block_sel_ur
keep ea n_block_sel_ea
rename ea psu_id
drop if n_block_sel_ea==0
save "${gsdTemp}\sweights_2.1_host.dta", replace
import excel "${gsdDataRaw}\Inputs EAs.xls", sheet("Master EAs") firstrow case(lower) clear
drop if ea=="EA"
keep if type_pop=="Host Only" | (type_pop=="Urban/Rural" & status_psu_ur_idp=="Low-rank replacement not considered") | (type_pop=="Urban/Rural and Host" & status_psu_ur_idp=="Low-rank replacement not considered")
keep ea nb_blocks_ea
destring ea, replace
destring nb_blocks_ea, replace
rename (ea nb_blocks_ea) (psu_id n_block_ea)
merge 1:1 psu_id using "${gsdTemp}\sweights_2.1_host.dta", nogen keep(match)
save "${gsdTemp}\sweights_2_host.dta", replace
*Urban and host EAs
import excel "${gsdDataRaw}\MainRepPSUs_BlockSel_VBA_001.xlsx", sheet("Sheet1") firstrow case(lower) clear
keep psu_id tot_block nbblk2se
duplicates drop
rename (tot_block nbblk2se) (n_block_ea n_block_sel_ea)
append using "${gsdTemp}\sweights_2_host.dta"
save "${gsdTemp}\sweights_2_host.dta", replace

*3.1 Number of selected structures in block k (SSk)
*3.2 Number of structures in block k (Sk)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type_idp_host==2
egen exclude_structures=rowtotal(n_str_no_success__*) 
gen tot_n_str=n_str - exclude_structures
*Impute the median number of structures to missings and zero structures
bysort strata ea: egen prelim_ea_median=median(tot_n_str) 
bysort strata ea: egen ea_median=max(prelim_ea_median) 
replace tot_n_str=ea_median if tot_n_str>=. | tot_n_str==0
keep interview__id tot_n_str
save "${gsdTemp}\sweights_3_host.dta", replace

*4.1 Number of households selected in structure m (HSm)
*4.2 Number of households structure m (Hm)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type_idp_host==2
egen exclude_hhs=rowtotal(n_hh_no_success__*) 
gen tot_n_hhs=n_hh - exclude_hhs
*Impute the median number of households to missings and zero households
bysort strata ea: egen prelim_ea_median=median(tot_n_hhs) 
bysort strata ea: egen ea_median=max(prelim_ea_median) 
replace tot_n_hhs=ea_median if tot_n_hhs>=. | tot_n_hhs==0
keep interview__id tot_n_hhs
save "${gsdTemp}\sweights_4_host.dta", replace

*Estimate P1
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type_idp_host==2
keep interview__id strata ea
rename (strata ea) (strata_id psu_id)
merge m:1 strata_id using "${gsdTemp}\sweights_1.1_host.dta", nogen keep(master match)
merge m:1 psu_id using "${gsdTemp}\sweights_1.2_host.dta", nogen keep(master match)
merge m:1 strata_id using "${gsdTemp}\sweights_1.3_host.dta", nogen keep(master match)
gen p1a=((n_sel_ea_strata_a* size_o_ea_a)/ tot_hhs_strata_a) 
gen p1b=((n_sel_ea_strata_b* size_o_ea_b)/ tot_hhs_strata_b) 
gen p1=(p1a + p1b) - (p1a*p1b)

*Estimate P2
merge m:1 psu_id using "${gsdTemp}\sweights_2_host.dta", nogen keep(master match)
gen p2=n_block_sel_ea/n_block_ea

*Estimate P3
merge m:1 interview__id using "${gsdTemp}\sweights_3_host.dta", nogen assert(match)
gen p3=1/tot_n_str

*Estimate P4
merge m:1 interview__id using "${gsdTemp}\sweights_4_host.dta", nogen assert(match)
gen p4=1/tot_n_hhs

*Estimate Probability of selection and sampling weights 
gen prob_sel=p1*p2*p3*p4
gen weight_temp=1/prob_sel
keep interview__id weight_temp
save "${gsdTemp}\sweights_host.dta", replace


********************************************************************
* IDP households
********************************************************************
/*
	Probability of selecting household h in EA i of strata j of Camp c is given by
	Phijc = P1 * P2 * P3 * P4 * P5 such that 

	P1=Probability of selecting the Camp
	P2=Probability of selecting the EA
	P3=Probability of selecting the Block
	P4=Probability of selecting the structure
	P5=Probability of selecting the household

	P1= Cj * Hc /Hj
	P2= EAc * Bi / Bc  
	P3= BSi / Bi
	P4= SSk/Sk
	P5= HSm / Hm

	Thus, the variables needed to estimate the sampling weights are:
	
	1.1 Number of camps selected in strata j (Cj)
	1.2 Number of households estimated in the sample frame in camp c (Hc)
	1.3 Number of households estimated in the sample frame in strata j (Hj)
	2.1 Number of EAs selected in camp c (EAc)
	2.2 Number of blocks in the sample frame in the original EA i (Bi)
	2.3 Number of blocks in the sample frame in the camp (Bc)
	3.1 Number of blocks selected in EA i (BSi)
	3.2 Number of blocks in EA i (Bi)
	4.1 Number of selected structures in block k (SSk)
	4.2 Number of structures in block k (Sk)
	5.1 Number of households selected in structure m (HSm)
	5.2 Number of households structure m (Hm)
	
*/

*1.1 Number of camps selected in strata j (Cj)
use "${gsdData}\0-RawTemp\master_idps_camps.dta", clear
gen n_camp_sel_strata=1
collapse (sum) n_camp_sel_strata, by(strata_id)
save "${gsdTemp}\sweights_1.1_idp.dta", replace

*1.2 Number of households in the camp
*1.3 Number of households estimated in the sample frame in strata j (Hj) 
use "${gsdData}\0-RawTemp\master_sample.dta", clear
keep if tot_hhs_sel_camp_strata<.
bys strata_name: egen tot_hh_camp=sum(tot_hhs_psu)
keep psu_id tot_hh_camp tot_hhs_strata
save "${gsdTemp}\sweights_1.2_1.3_idp.dta", replace

*2.1 Number of EAs selected in camp c (EAc)
import excel "${gsdDataRaw}\IDPMasterStrata_v15.xlsx", sheet("Final_Sample") firstrow case(lower) clear
drop if strata_id==.
keep if selected_final>=1
bys ea_id: egen n_intw_ea=sum(selected_final)
gen n_sel_ea=n_intw_ea/12
keep strata_id idp_camp ea_id n_sel_ea 
duplicates drop 
bys idp_camp: egen n_sel_ea_camp=sum(n_sel_ea)
drop n_sel_ea ea_id
duplicates drop 
save "${gsdTemp}\sweights_2.1_idp.dta", replace

*2.2 Number of blocks in the sample frame in the original EA i (Bi)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type==3
keep ea
rename ea id_ea
duplicates drop 
*Include id of replacement EA
merge 1:1 id_ea using "${gsdData}\0-RawTemp\EA_Replacement_Table_Complete.dta", nogen keep(match master) keepusing(o_ea o_ea_2 o_ea_3)
rename id_ea psu_id
*Obtain the number of blocks from master sample
preserve
import excel "${gsdDataRaw}\IDPMasterStrata_v15.xlsx", sheet("Final_Sample") firstrow case(lower) clear
destring ea_id, replace
drop if ea_id>=.
keep ea_id no_blocks_ea
duplicates drop
rename ea_id psu_id
save "${gsdTemp}\master_idp_blocks_psu.dta", replace
restore
merge 1:1 psu_id using  "${gsdTemp}\master_idp_blocks_psu.dta", nogen keep(master match) keepusing(no_blocks_ea)
order psu_id no_blocks_ea
rename (psu_id no_blocks_ea) (ea_id size_ea)
*Obtain the number of households from 1st replacement
rename o_ea psu_id
merge m:1 psu_id using  "${gsdTemp}\master_idp_blocks_psu.dta", nogen keep(master match) keepusing(no_blocks_ea)
order no_blocks_ea, after(psu_id)
rename (psu_id no_blocks_ea) (ea_id_1 size_ea_1)
*Obtain the final original size of the EA
gen size_o_ea=size_ea if ea_id_1==. 
replace size_o_ea=size_ea_1 if ea_id_1<. & size_o_ea>=.
keep ea_id size_o_ea
rename (ea_id size_o_ea) (psu_id blocks_o_ea)
save "${gsdTemp}\sweights_2.2_idp.dta", replace

*2.3 Number of blocks in the sample frame in the camp (Bc)
use "${gsdData}\0-RawTemp\master_idps_eas.dta", clear
rename strata_name idp_camp
bys idp_camp: egen n_block_camp=sum(no_blocks_ea)
keep strata_id idp_camp n_block_camp
duplicates drop
save "${gsdTemp}\sweights_2.3_idp.dta", replace

*3.1 Number of blocks selected in EA i (BSi)
*3.2 Number of blocks in EA i (Bi)
import excel "${gsdDataRaw}\IDPMasterStrata_v15.xlsx", sheet("Final_Sample") firstrow case(lower) clear
drop if strata_id==.
bys ea_id: egen n_block_sel_ea_1=sum(selected_final)
bys ea_id: egen n_block_sel_ea_2=sum(replace_1st_final)
gen n_block_sel_ea=n_block_sel_ea_1
replace n_block_sel_ea=n_block_sel_ea_2 if  n_block_sel_ea==0
keep ea_id no_blocks_ea n_block_sel_ea
rename (ea_id no_blocks_ea) (psu_id n_block_ea)
drop if n_block_sel_ea==0
duplicates drop
destring psu_id, replace
save "${gsdTemp}\sweights_3_idp.dta", replace

*4.1 Number of selected structures in block k (SSk)
*4.2 Number of structures in block k (Sk)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type==3
egen exclude_structures=rowtotal(n_str_no_success__*) 
gen tot_n_str=n_str - exclude_structures
*Impute the median number of structures to missings and zero structures
bysort strata ea: egen prelim_ea_median=median(tot_n_str) 
bysort strata ea: egen ea_median=max(prelim_ea_median) 
replace tot_n_str=ea_median if tot_n_str>=. | tot_n_str==0
keep interview__id tot_n_str
save "${gsdTemp}\sweights_4_idp.dta", replace

*5.1 Number of households selected in structure m (HSm)
*5.2 Number of households structure m (Hm)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type==3
egen exclude_hhs=rowtotal(n_hh_no_success__*) 
gen tot_n_hhs=n_hh - exclude_hhs
*Impute the median number of households to missings and zero households
bysort strata ea: egen prelim_ea_median=median(tot_n_hhs) 
bysort strata ea: egen ea_median=max(prelim_ea_median) 
replace tot_n_hhs=ea_median if tot_n_hhs>=. | tot_n_hhs==0
keep interview__id tot_n_hhs
save "${gsdTemp}\sweights_5_idp.dta", replace

*Estimate P1
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type==3
keep interview__id strata ea
rename (strata ea) (strata_id psu_id)
merge m:1 strata_id using "${gsdTemp}\sweights_1.1_idp.dta", nogen assert(match)
merge m:1 psu_id using "${gsdTemp}\sweights_1.2_1.3_idp.dta", nogen keep(match)
gen p1=(n_camp_sel_strata * tot_hh_camp) /tot_hhs_strata 

*Estimate P2
merge m:1 psu_id using "${gsdTemp}\sweights_2.2_idp.dta", nogen keep(master match)
*Include the link between EA and camp
preserve
import excel "${gsdDataRaw}\IDPMasterStrata_v15.xlsx", sheet("Final_Sample") firstrow case(lower) clear
keep ea_id idp_camp
rename ea_id psu_id
duplicates drop
destring psu_id, replace
save "${gsdTemp}\sweights_match_ea_camp.dta", replace	
restore	
merge m:1 psu_id using "${gsdTemp}\sweights_match_ea_camp.dta", nogen keep(match)
merge m:1 idp_camp using "${gsdTemp}\sweights_2.1_idp.dta", nogen keep(match)
merge m:1 idp_camp using "${gsdTemp}\sweights_2.3_idp.dta", nogen keep(match)
gen p2=((n_sel_ea_camp*blocks_o_ea)/  n_block_camp) 

*Estimate P3
merge m:1 psu_id using "${gsdTemp}\sweights_3_idp.dta", nogen keep(master match)
gen p3=n_block_sel_ea/n_block_ea

*Estimate P4
merge m:1 interview__id using "${gsdTemp}\sweights_4_idp.dta", nogen assert(match)
gen p4=1/tot_n_str

*Estimate P5
merge m:1 interview__id using "${gsdTemp}\sweights_5_idp.dta", nogen assert(match)
gen p5=1/tot_n_hhs

*Estimate Probability of selection and sampling weights 
gen prob_sel=p1*p2*p3*p4*p5
gen weight_temp=1/prob_sel
keep interview__id weight_temp
save "${gsdTemp}\sweights_idp.dta", replace


********************************************************************
* Nomadic households 
********************************************************************
/*
	Probability of selecting household h in water point i of strata j is given by
	Phij = P1 * P2 * P3 such that 

	P1=Probability of selecting the water point
	P2=Probability of selecting the listing round
	P3=Probability of selecting the household

	P1= WSj / Wj
	P2= LSSr/Lr
	P3= HSr / Hr
	
	However, since all the listing rounds were always selected, then P2=1
	
	
	Thus, the variables needed to estimate the sampling weights are:
	
	1.1 Number of selected water points in strata j (WSj)
	1.2 Number of water points in strata j(Wj)
	3.1 Number of households selected in listing round r(HSr)
	3.2 Number of households listed in round r (Hr)
	
	

*/

*1.1 Number of selected water points in strata j (WSj)
use "${gsdData}\0-RawTemp\master_nomads.dta", clear
bys strata_id: egen n_sel_wp_strata=sum(main_wp)
keep strata_id n_sel_wp_strata
duplicates drop
save "${gsdTemp}\sweights_1.1_nomads.dta", replace

*1.2 Number of water points in strata j(Wj)
use "${gsdData}\0-RawTemp\master_nomads.dta", clear
gen n_tot_wp_strata=1
collapse (sum) n_tot_wp_strata, by(strata_id)
save "${gsdTemp}\sweights_1.2_nomads.dta", replace

*3.1 Number of households selected in listing round r(HSr)
*3.2 Number of households listed in round r (Hr)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type==4
gen x=1
bys water_point listing_day listing_round: egen n_sel=sum(x)
merge m:1 water_point listing_day listing_round using "${gsdData}\0-RawTemp\master_nomads_listing.dta", nogen keep(master match)
keep interview__id n_eligible n_sel
*Correct missing values 
replace n_eligible=n_sel if n_eligible>=.
replace n_eligible=1 if n_eligible==0
save "${gsdTemp}\sweights_3_nomads.dta", replace

*Estimate P1
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type==4
keep interview__id strata ea listing_day
rename (strata ea) (strata_id psu_id)
merge m:1 strata_id using "${gsdTemp}\sweights_1.1_nomads.dta", nogen keep(match)
merge m:1 strata_id using "${gsdTemp}\sweights_1.2_nomads.dta", nogen keep(match)
gen p1=n_sel_wp_strata/n_tot_wp_strata

*Estimate P3
merge 1:1 interview__id using "${gsdTemp}\sweights_3_nomads.dta", nogen keep(match)
gen p3=n_sel / n_eligible

*Estimate Probability of selection and sampling weights 
gen prob_sel=p1*1*p3
gen weight_temp=1/prob_sel
keep interview__id weight_temp
save "${gsdTemp}\sweights_nomads.dta", replace


********************************************************************
*Integrate and scale the sampling weights for all households
********************************************************************
use "${gsdTemp}\sweights_urban_rural.dta", clear
append using "${gsdTemp}\sweights_host.dta"
append using "${gsdTemp}\sweights_idp.dta"
append using "${gsdTemp}\sweights_nomads.dta"
*Include strata and households from PESS
merge 1:1 interview__id using "${gsdData}\0-RawOutput\hh_clean.dta", nogen keep(match) keepusing(strata)
rename strata strata_id
preserve
use "${gsdData}\0-RawTemp\master_sample.dta", clear
drop if host_ea==1
keep strata_id tot_hhs_strata
duplicates drop 
save "${gsdTemp}\strata_pess_hhs.dta", replace
restore
merge m:1 strata_id using "${gsdTemp}\strata_pess_hhs.dta", keep(match master) nogen
*Include households from PESS for the nomads
replace tot_hhs_strata=56398 if strata_id==8
replace tot_hhs_strata=30499 if strata_id==9
replace tot_hhs_strata=70664 if strata_id==10
replace tot_hhs_strata=78497 if strata_id==12
replace tot_hhs_strata=173286 if strata_id==13
replace tot_hhs_strata=78247 if strata_id==14
*Scale weights to match households from PESS regions 
bys strata_id: egen weight_temp_strata=sum(weight_temp)
gen weight = weight_temp * (tot_hhs_strata/ weight_temp_strata) 
*Check consistency of household weights and save
bys strata_id: egen check=sum(weight) 
assert (round(tot_hhs_strata) == round(check)) 
keep interview__id weight
save "${gsdTemp}\weights_all_hhs.dta", replace
*Include weights in the household dataset 
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
merge 1:1 interview__id using "${gsdTemp}\weights_all_hhs.dta", nogen keep(master match)
order weight, after(block_id)
label var weight "Household weight"
*Drop rural Jubbaland
drop if strata==32 | strata==34
save "${gsdData}\0-RawTemp\hh_sweights.dta", replace
