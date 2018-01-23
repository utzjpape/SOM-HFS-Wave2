*Calculate sampling weights 

set more off
set seed 23061980 
set sortseed 11021955


********************************************************************
* Urban (non-host) and rural households 
********************************************************************
/*
	Probability of selecting household h in EA i of strata j is given by
	Phij = P1 * P2 * P3 such that 

	P1=Probability of selecting the EA
	P2=Probability of selecting the Block
	P3=Probability of selecting the household

	P1= EAj * HOi / Hj  
	P2= BSi / Bi
	P3= HSi / Hi

	Thus, the variables needed to estimate the sampling weights are:
	
	1.1 Number of EAs selected in strata j (EAj)
	1.2 Number of households estimated in the sample frame for the original EA i (HOi)
	1.3 Number of households estimated in the sample frame in strata j (Hj)
	2.1 Number of blocks selected in EA i (BSi)
	2.2 Number of blocks in EA i (Bi)
	3.1 Number of households selected in EA i (HSi)
	3.2 Number of households in EA i (Hi)
	
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
*Obtain the number of households from 1st replacement
rename o_ea psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_1 size_ea_1)
*Obtain the number of households from 2nd replacement
rename o_ea_2 psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_2 size_ea_2)
*Obtain the number of households from 3rd replacement
rename o_ea_3 psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_3 size_ea_3)
*Obtain the final original size of the EA
gen size_o_ea=size_ea if (ea_id_1==. & ea_id_2==. & ea_id_3==.) 
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

*3.1 Number of households selected in EA i (HSi)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if (type==1 | type==2) & type_idp_host>=.
keep interview__id strata ea
rename (strata ea) (strata_id psu_id)
bys psu_id: egen n_hh_sel_ea=count(psu_id)
drop strata_id interview__id
duplicates drop
save "${gsdTemp}\sweights_3.1_urban_rural.dta", replace

*3.2 Number of households in EA i (Hi)
use "${gsdData}\0-RawTemp\master_sample.dta", clear
drop if host_ea==1
keep psu_id tot_hhs_psu
save "${gsdTemp}\sweights_3.2.dta", replace

*Estimate P1
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if (type==1 | type==2) & type_idp_host>=.
keep interview__id strata ea
rename (strata ea) (strata_id psu_id)
merge m:1 strata_id using "${gsdTemp}\sweights_1.1_urban_rural.dta", nogen keep(master match)
merge m:1 psu_id using "${gsdTemp}\sweights_1.2_urban_rural.dta", nogen keep(master match)
merge m:1 strata_id using "${gsdTemp}\sweights_1.3.dta", nogen keep(master match)
*Manual correction for EA 165725 selected 3 times for replacement as original size needs to be distributed 
preserve 
keep if psu_id==165725 
set seed 23061980 
set sortseed 11021955
gen rand=uniform() if psu_id==165725 
sort rand
gen size_o_ea_correct=196.2227 if _n<=12
replace size_o_ea_correct=499.27823 if _n>12
replace size_o_ea_correct=1623.1033 if _n>24
keep interview__id size_o_ea_correct
save "${gsdTemp}\sweights_correction_p1.dta", replace
restore 
merge 1:1 interview__id using "${gsdTemp}\sweights_correction_p1.dta", nogen keep(match master)
replace size_o_ea=size_o_ea_correct if psu_id==165725 
drop size_o_ea_correct
gen p1=((n_sel_ea_strata* size_o_ea)/ tot_hhs_strata) 

*Estimate P2
merge m:1 psu_id using "${gsdTemp}\sweights_2_urban_rural.dta", nogen keep(master match)
gen p2=n_block_sel_ea/n_block_ea

*Estimate P3
merge m:1 psu_id using "${gsdTemp}\sweights_3.1_urban_rural.dta", nogen keep(master match)
merge m:1 psu_id using "${gsdTemp}\sweights_3.2.dta", nogen keep(master match)
gen p3=n_hh_sel_ea/tot_hhs_psu

*Estimate Probability of selection and sampling weights 
gen prob_sel=p1*p2*p3
gen weight_temp=1/prob_sel
keep interview__id weight_temp
save "${gsdTemp}\sweights_urban_rural.dta", replace



********************************************************************
* Host and Urban households 
********************************************************************
/*
	Probability of selecting household h in EA i of strata j is given by
	Phij = P1 * P2 * P3 such that 

	P1=Probability of selecting the EA from two separate sampling processes (for urban/rural households and host communities)
		P1a=Probability of selecting the EA from the sampling process for urban and rural areas
		P1b=Probability of selecting the EA from the sampling process for host communities
	P2=Probability of selecting the Block
	P3=Probability of selecting the household

	P1=  P1a + P1b – P1a*P1b
	P2= BSi / Bi
	P3= HSi / Hi

	Thus, the variables needed to estimate the sampling weights are:
	
	1.1 Number of EAs selected in the host community sample j (EAj)
	1.2 Number of households estimated in the sample frame for the original EA i (HOi)
	1.3 Number of households estimated in the sample frame in the host community sample (Hj)

	2.1 Number of blocks selected in EA i (BSi)
	2.2 Number of blocks in EA i (Bi)
	3.1 Number of households selected in EA i (HSi)
	3.2 Number of households in EA i (Hi)
	
		
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
keep if type_idp_host==2
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
*Obtain the number of households from 1st replacement
rename o_ea_h psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_1 size_ea_1)
*Obtain the number of households from 2nd replacement
rename o_ea_2_h psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_2 size_ea_2)
*Obtain the number of households from 3rd replacement
rename o_ea_3_h psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_3 size_ea_3)
*Obtain the final original size of the EA
gen size_o_ea_b=size_ea if (ea_id_1==. & ea_id_2==. & ea_id_3==.) 
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

*3.1 Number of households selected in EA i (HSi)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type_idp_host==2
keep interview__id strata ea
rename (strata ea) (strata_id psu_id)
bys psu_id: egen n_hh_sel_ea=count(psu_id)
drop strata_id interview__id
duplicates drop
save "${gsdTemp}\sweights_3.1_host.dta", replace

*3.2 Number of households in EA i (Hi)
use "${gsdData}\0-RawTemp\master_sample.dta", clear
keep if host_ea==1
keep psu_id tot_hhs_psu
save "${gsdTemp}\sweights_3.2_host.dta", replace

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
merge m:1 psu_id using "${gsdTemp}\sweights_3.1_host.dta", nogen keep(master match)
merge m:1 psu_id using "${gsdTemp}\sweights_3.2_host.dta", nogen keep(master match)
gen p3=n_hh_sel_ea/tot_hhs_psu

*Estimate Probability of selection and sampling weights 
gen prob_sel=p1*p2*p3
gen weight_temp=1/prob_sel
keep interview__id weight_temp
save "${gsdTemp}\sweights_host.dta", replace



********************************************************************
* IDP households
********************************************************************
/*
	Probability of selecting household h in EA i of strata j is given by
	Phij = P1 * P2 * P3 *P4 such that 

	P1=Probability of selecting the Camp
	P2=Probability of selecting the EA
	P3=Probability of selecting the Block
	P4=Probability of selecting the household

	P1= HHc/Hj
	P2= EAj * HOi / HCj  
	P3= BSi / Bi
	P4= HSi / Hi

	Thus, the variables needed to estimate the sampling weights are:
	
	1.1 Number of households in the camp
	1.2 Number of households estimated in the sample frame in strata j (Hj) 
	2.1 Number of EAs selected in strata j (EAj)
	2.2 Number of households estimated in the sample frame for the original EA i (HOi)
	2.3 Number of households estimated in the sample frame in selected camps from strata j (HCj)
	3.1 Number of blocks selected in EA i (BSi)
	3.2 Number of blocks in EA i (Bi)
	4.1 Number of households selected in EA i (HSi)
	4.2 Number of households in EA i (Hi)
		
*/

*1.1 Number of households in the camp
*1.2 Number of households estimated in the sample frame in strata j (Hj) 
use "${gsdData}\0-RawTemp\master_sample.dta", clear
keep if tot_hhs_sel_camp_strata<.
bys strata_name: egen tot_hh_camp=sum(tot_hhs_psu)
keep psu_id tot_hh_camp tot_hhs_strata
save "${gsdTemp}\sweights_1_idp.dta", replace

*2.1 Number of EAs selected in strata j (EAj)
import excel "${gsdDataRaw}\IDPMasterStrata_v15.xlsx", sheet("Final_Sample") firstrow case(lower) clear
drop if strata_id==.
keep if selected_final>=1
bys ea_id: egen n_intw_ea=sum(selected_final)
gen n_sel_ea=n_intw_ea/12
keep strata_id ea_id n_sel_ea
duplicates drop 
bys strata_id: egen n_sel_ea_strata=sum(n_sel_ea)
drop n_sel_ea ea_id
duplicates drop 
save "${gsdTemp}\sweights_2.1_idp.dta", replace

*2.2 Number of households estimated in the sample frame for the original EA i (HOi)
*List of EAs from data collection 
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type==3
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
*Obtain the number of households from 1st replacement
rename o_ea psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_1 size_ea_1)
*Obtain the number of households from 2nd replacement
rename o_ea_2 psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_2 size_ea_2)
*Obtain the number of households from 3rd replacement
rename o_ea_3 psu_id
merge m:1 psu_id using  "${gsdTemp}\master_sample_no_host.dta", nogen keep(master match) keepusing(tot_hhs_psu)
order tot_hhs_psu, after(psu_id)
rename (psu_id tot_hhs_psu) (ea_id_3 size_ea_3)
*Obtain the final original size of the EA
gen size_o_ea=size_ea if (ea_id_1==. & ea_id_2==. & ea_id_3==.) 
replace size_o_ea=size_ea_1 if ea_id_1<. & size_o_ea>=.
keep ea_id size_o_ea
rename ea_id psu_id					
save "${gsdTemp}\sweights_2.2_idp.dta", replace

*2.3 Number of households estimated in the sample frame in selected camps from strata j (HCj)
use "${gsdData}\0-RawTemp\master_sample.dta", clear
keep if tot_hhs_sel_camp_strata<.
keep strata_id tot_hhs_sel_camp_strata
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

*4.1 Number of households selected in EA i (HSi)
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type==3
keep interview__id strata ea
rename (strata ea) (strata_id psu_id)
bys psu_id: egen n_hh_sel_ea=count(psu_id)
drop strata_id interview__id
duplicates drop
save "${gsdTemp}\sweights_4.1_idp.dta", replace

*4.2 Number of households in EA i (Hi)
use "${gsdData}\0-RawTemp\master_sample.dta", clear
keep if tot_hhs_sel_camp_strata<.
keep psu_id tot_hhs_psu
save "${gsdTemp}\sweights_4.2_idp.dta", replace

*Estimate P1
use "${gsdData}\0-RawOutput\hh_clean.dta", clear
keep if type==3
keep interview__id strata ea
rename (strata ea) (strata_id psu_id)
merge m:1 psu_id using "${gsdTemp}\sweights_1_idp.dta", nogen keep(master match)
gen p1=tot_hh_camp/ tot_hhs_strata

*Estimate P2
merge m:1 strata_id using "${gsdTemp}\sweights_2.1_idp.dta", nogen keep(master match)
merge m:1 psu_id using "${gsdTemp}\sweights_2.2_idp.dta", nogen keep(master match)
merge m:1 strata_id using "${gsdTemp}\sweights_2.3_idp.dta", nogen keep(master match)
gen p2=((n_sel_ea_strata* size_o_ea)/ tot_hhs_strata) 

*Estimate P3
merge m:1 psu_id using "${gsdTemp}\sweights_3_idp.dta", nogen keep(master match)
gen p3=n_block_sel_ea/n_block_ea

*Estimate P4
merge m:1 psu_id using "${gsdTemp}\sweights_4.1_idp.dta", nogen keep(master match)
merge m:1 psu_id using "${gsdTemp}\sweights_4.2_idp.dta", nogen keep(master match)
gen p4=n_hh_sel_ea/tot_hhs_psu

*Estimate Probability of selection and sampling weights 
gen prob_sel=p1*p2*p3*p4
gen weight_temp=1/prob_sel
keep interview__id weight_temp
save "${gsdTemp}\sweights_idp.dta", replace



********************************************************************
*Integrate and scale the sampling weights for all households
********************************************************************
use "${gsdTemp}\sweights_urban_rural.dta", clear
append using "${gsdTemp}\sweights_host.dta"
append using "${gsdTemp}\sweights_idp.dta"
*Include strata and households from PESS
merge 1:1 interview__id using "${gsdData}\0-RawOutput\hh_clean.dta", nogen assert(match) keepusing(strata)
rename strata strata_id
preserve
use "${gsdData}\0-RawTemp\master_sample.dta", clear
drop if host_ea==1
keep strata_id tot_hhs_strata
duplicates drop 
save "${gsdTemp}\strata_pess_hhs.dta", replace
restore
merge m:1 strata_id using "${gsdTemp}\strata_pess_hhs.dta", assert(match) nogen
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
save "${gsdData}\0-RawTemp\hh_sweights.dta", replace

