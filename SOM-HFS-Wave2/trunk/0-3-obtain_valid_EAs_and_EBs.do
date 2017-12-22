*-------------------------------------------------------------------
*
*     VALID EAS & EA AND EB REPLACEMENTS
*     
*     This do-file allows to:
*     - finalize the replacement table at the EA level 
*     - create the replacement table at the EB level
*     - flag the invalid EAs 
*                         
*-------------------------------------------------------------------

/*----------------------------------------------------------------------------*/
/*             EA REPLACEMENT TABLE AND EA VALIDITY                           */
/*----------------------------------------------------------------------------*/

/*
An EA is valid if: 
- the EA was either sampled or was an active replacement (only became valid once another EA was substituted)
- at least 12/24/36 valid and successful interviews per EA, if the EA was sampled once/twice/thrice, except in EAs with one block
- the EA is balanced in terms of treatment for the food and non-food consumption modules (at least 2/4/6 valid and successful interviews for each treatment when 12/24/36 interviews have to be conducted), except in EAs with one block

ea_status=1 if valid
ea_status=2 if ea neither sampled nor active replacement
ea_status=3 if less than 12/24/36 valid and successful interviews per EA, if the EA was sampled once/twice/thrice, except in EAs with one block
ea_status=4 if treatment unbalanced (less than 2/4/6 valid and successful interviews for each treatment when 12/24/36 interviews have to be conducted), except in EAs with one block
*/

** GENERATING NUMBER OF VALID AND SUCCESSFUL INTERVIEWS PER EA, WITH BREAKDOWN PER TREATMENT **

*Importing questionnaire
use "${gsdData}/0-RawTemp/hh_valid_keys.dta", clear

*Generating dummy variables at the interview level (validity, success, and validity and success, with breakdown per treatment)
gen index=1
gen treat1 = (mod_opt==1)
gen treat2 = (mod_opt==2)
gen treat3 = (mod_opt==3)
gen treat4 = (mod_opt==4)
label var index "Variable equal to 1"
forvalues i = 1/4{
	label var treat`i' "Whether interview was assigned optional module `i'"
}

gen val1 = (treat1==1 & itw_valid==1)
gen val2 = (treat2==1 & itw_valid==1)
gen val3 = (treat3==1 & itw_valid==1)
gen val4 = (treat4==1 & itw_valid==1)
forvalues i = 1/4{
	label var val`i' "Whether interview was assigned optional module `i' and is valid"
}

gen succ1 = (treat1==1 & successful==1)
gen succ2 = (treat2==1 & successful==1)
gen succ3 = (treat3==1 & successful==1)
gen succ4 = (treat4==1 & successful==1)
forvalues i = 1/4{
	label var succ`i' "Whether interview was assigned optional module `i' and is successful"
}

gen val_succ1 = (treat1==1 & itw_valid==1 & successful==1)
gen val_succ2 = (treat2==1 & itw_valid==1 & successful==1)
gen val_succ3 = (treat3==1 & itw_valid==1 & successful==1)
gen val_succ4 = (treat4==1 & itw_valid==1 & successful==1)
forvalues i = 1/4{
	label var val_succ`i' "Whether interview was assigned optional module `i' and is valid and successful"
}

save "${gsdTemp}/hh_valid_keys_and_EAs_temp.dta", replace 
	 
*Collapse to make a dataset of summary elements for each EA
collapse (sum) nb_interviews_ea=index nb_treat1_ea=treat1 nb_treat2_ea=treat2 nb_treat3_ea=treat3 nb_treat4_ea=treat4 ///
	nb_valid_interviews_ea=itw_valid nb_valid_treat1_ea=val1 nb_valid_treat2_ea=val2 nb_valid_treat3_ea=val3 nb_valid_treat4_ea=val4 ///
	nb_success_interviews_ea=successful nb_success_treat1_ea=succ1 nb_success_treat2_ea=succ2 nb_success_treat3_ea=succ2 nb_success_treat4_ea=succ4 ///
	nb_valid_success_itws_ea=successful_valid nb_valid_success_treat1_ea=val_succ1 nb_valid_success_treat2_ea=val_succ2 nb_valid_success_treat3_ea=val_succ3 nb_valid_success_treat4_ea=val_succ4, by(id_ea)
order id_ea, first
save "${gsdTemp}/ea_collapse.dta", replace

** 	FINALIZING EA REPLACEMENT TABLE **

*Part 1: Importing administrative information and initial sample
import excel "${gsdDataRaw}/EA Replacement Table.xls", sheet("Step 1_Pre-survey repl UR") clear
drop if _n == 1 | _n == 3
foreach var of varlist * {
	rename `var' `=`var'[1]'
}
rename ea id_ea
drop if _n ==1
destring *, replace
keep id_ea-y_max main_uri-sample_initial_h
drop state nb_structures
save "${gsdTemp}/EA_Replacement_Table_Part1.dta", replace

*Part 2: Replacement table, final sample
*The replacement table at the EA level was originally constructed for the pre-survey replacements 
*During the survey, replacements are added to the replacement table manually
import excel "${gsdDataRaw}/EA Replacement Table.xls", sheet("Step 3_Final sample and repl") clear
drop if _n == 1 | _n == 3
foreach var of varlist * {
	rename `var' `=`var'[1]'
}
rename ea id_ea
drop if _n ==1
destring *, replace
keep id_ea sample_final_uri-final_rank_rep_h target_itw_ea-ea_valid
save "${gsdTemp}/EA_Replacement_Table_Part2.dta", replace

*Merging Part1 and Part2 of EA replacement table
merge 1:1 id_ea using "${gsdTemp}/EA_Replacement_Table_Part1.dta", nogenerate

*Part 3: Generating target number of interviews for all EAs included in the final sample
*The following finalizes the replacement table, notably by adding the final number of interviews per EA
replace target_itw_ea = 12*(final_main_uri + final_main_h) if tot_block > 1 & (sample_final_uri == 1 | sample_final_h == 1)
replace target_itw_ea = 1 if tot_block == 1 & (sample_final_uri == 1 | sample_final_h == 1) /* In EAs with one block, the target number of interviews is set to 1. */

*Adding number of valid and successful interviews per EA and validity status of EAs to the replacement table
*Merging EA replacement table with collapsed dataset containing number of valid and successful interviews per EA
merge 1:1 id_ea using "${gsdTemp}/ea_collapse.dta", keepusing(nb_valid_success_itws_ea nb_valid_success_treat1_ea nb_valid_success_treat2_ea nb_valid_success_treat3_ea nb_valid_success_treat4_ea)
replace nb_val_succ_itw_ea = nb_valid_success_itws_ea

*Defining EA validity status
label define ea_status_label 1 "Valid" ///
	2 "Not sampled nor active replacement" ///
	3 "Not enough interviews" ///
	4 "Not balanced in terms of treatment" ///
	5 "Not completed because of security reasons"
label values ea_status ea_status_label 

replace ea_status=1 if _merge == 3
replace ea_status=4 if _merge == 3 & target_itw_ea == 12 & ((nb_valid_success_treat1_ea<2) | (nb_valid_success_treat2_ea<2) | (nb_valid_success_treat3_ea<2) | (nb_valid_success_treat4_ea<2)) & target_itw_ea>1 /*only for EAs with more than 1 block*/
replace ea_status=4 if _merge == 3 & target_itw_ea == 24 & ((nb_valid_success_treat1_ea<4) | (nb_valid_success_treat2_ea<4) | (nb_valid_success_treat3_ea<4) | (nb_valid_success_treat4_ea<4)) & target_itw_ea>1 /*only for EAs with more than 1 block*/
replace ea_status=4 if _merge == 3 & target_itw_ea == 36 & ((nb_valid_success_treat1_ea<6) | (nb_valid_success_treat2_ea<6) | (nb_valid_success_treat3_ea<6) | (nb_valid_success_treat4_ea<6)) & target_itw_ea>1 /*only for EAs with more than 1 block*/
replace ea_status=4 if _merge == 3 & target_itw_ea == 48 & ((nb_valid_success_treat1_ea<8) | (nb_valid_success_treat2_ea<8) | (nb_valid_success_treat3_ea<8) | (nb_valid_success_treat4_ea<8)) & target_itw_ea>1 /*only for EAs with more than 1 block*/
replace ea_status=4 if _merge == 3 & target_itw_ea == 60 & ((nb_valid_success_treat1_ea<10) | (nb_valid_success_treat2_ea<10) | (nb_valid_success_treat3_ea<10) | (nb_valid_success_treat4_ea<10)) & target_itw_ea>1 /*only for EAs with more than 1 block*/
replace ea_status=3 if _merge == 3 & (nb_valid_success_itws_ea<target_itw_ea) & target_itw_ea>1 /*only for EAs with more than 1 block*/
replace ea_status=2 if _merge == 3 & (sample_final_uri != 1 & sample_final_h != 1)
replace ea_status=2 if _merge == 2
replace ea_status=5 if id_ea == 64279 | id_ea == 160751

*Dummy variable: whether EA is valid or not
replace ea_valid=(ea_status==1) 

*Final cleaning
drop _merge nb_valid_success_itws_ea nb_valid_success_treat1_ea nb_valid_success_treat2_ea nb_valid_success_treat3_ea nb_valid_success_treat4_ea
order strata_id- sample_initial_h, after(id_ea)

*Labelling of EA replacement table
label var id_ea "EA"
label var strata_id "Number of the strata"
label var strata_name "Name of the strata"
label var type_pop "Type of population"
label var status_psu_UR_IDP "Status of EA in the Urban/Rural/IDP sample"
label var status_psu_host "Status of EA in the Host communities sample"
label var tot_block "Total number of blocks in the EA"
label var x_min "Minimum longitude of the EA"
label var x_max "Maximum longitude of the EA"
label var y_min "Minimum latitude of the EA"
label var y_max "Maximum latitude of the EA"
label var main_uri "Number of times main EA was originally sampled in the Urban/Rural/IDP sample"
label var rep_uri "Number of times replacement EA was originally sampled in the Urban/Rural/IDP sample for the first time"
label var rank_rep_uri "Replacement rank number 1 in the Urban/Rural/IDP sample"
label var rep_uri_2 "Number of times replacement EA was originally sampled in the Urban/Rural/IDP sample for the second time"
label var rank_rep_uri_2 "Replacement rank number 2 in the Urban/Rural/IDP sample"
label var main_h "Number of times main EA was originally sampled in the Host communities sample"
label var rep_h "Number of times replacement EA number 1 was originally sampled in the Host communities sample"
label var rank_rep_h "Replacement rank number in the Host communities sample"
label var sample_initial_uri "EA was included in the original sample for Urban/Rural and IDPs"
label var sample_initial_h "EA was included in the original sample for Host communities"
label var sample_final_uri "EA is included in the final sample for Urban/Rural and IDPs"
label var sample_final_h "EA is included in the final sample for Host communities"
label var o_ea "Original EA number 1 in the Urban/Rural/IDP sample"
label var o_ea_2 "Original EA number 2 in the Urban/Rural/IDP sample"
label var o_ea_3 "Original EA number 3 in the Urban/Rural/IDP sample"
label var r_seq "Number of replacements between original EA number 1 and the EA in the Urban/Rural/IDP sample"
label var r_seq_2 "Number of replacements between original EA number 2 and the EA in the Urban/Rural/IDP sample"
label var r_seq_3 "Number of replacements between original EA number 3 and the EA in the Urban/Rural/IDP sample"
label var r_date "Date of replacement in the Urban/Rural/IDP sample"
label var r_ea "Replacement EA number 1 in the Urban/Rural/IDP sample"
label var r_ea_2 "Replacement EA number 2 in the Urban/Rural/IDP sample"
label var r_ea_3 "Replacement EA number 3 in the Urban/Rural/IDP sample"
label var r_reason "Reason for replacement in the Urban/Rural/IDP sample"
label var test_rep "Replacement EA has been tested for replacement in the Urban/Rural/IDP sample"
label var rep_nb "Number of times the replacement EA can still be used in the Urban/Rural/IDP samp"
label var o_ea_h "Original EA number 1 in the Host communities sample"
label var o_ea_2_h "Original EA number 2 in the Host communities sample"
label var o_ea_3_h "Original EA number 3 in the Host communities sample"
label var r_seq_h "Number of replacements between original EA number 1 and the EA in the Host communities sample"
label var r_seq_2_h "Number of replacements between original EA number 2 and the EA in the Host communities sample"
label var r_seq_3_h "Number of replacements between original EA number 3 and the EA in the Host communities sample"
label var r_date_h "Date of replacement in the Host communities sample"
label var r_ea_h "Replacement EA number 1 in the Host communities sample"
label var r_ea_2_h "Replacement EA number 2 in the Host communities sample"
label var r_ea_3_h "Replacement EA number 3 in the Host communities sample"
label var r_reason_h "Reason for replacement in the Host communities sample"
label var test_rep_h "Replacement EA has been tested for replacement in the Host communities sample"
label var rep_nb_h "Number of times the replacement EA can still be used in the Host communities sample"
label var final_main_uri "Number of times 'new main' EA is sampled in the final Urban/Rural/IDP sample"
label var final_rep_uri "Number of times 'new replacement' EA is sampled in the final Urban/Rural/IDP sample"
label var final_rank_rep_uri "Replacement rank of 'new replacement' EA in the final Urban/Rural/IDP sample"
label var final_rep_uri_2 "Number of times 'new replacement' EA is sampled in the final Urban/Rural/IDP sample for the second time"
label var final_rank_rep_uri_2 "Replacement rank number 2 of 'new replacement' EA in the final Urban/Rural/IDP sample  "
label var final_main_h "Number of times 'new main' EA is sampled in the final Host communities sample"
label var final_rep_h "Number of times 'new replacement' EA is sampled in the final Host communities sample"
label var final_rank_rep_h "Replacement rank of 'new replacement' EA in the final Host communities sample"
label var target_itw_ea "Target number of valid and succesful interviews in the EA only when in final sample"
label var nb_val_succ_itw_ea "Number of valid and succesful interviews conducted in the EA"
label var ea_status "Validity status of the EA"
label var ea_valid "Whether the EA is valid"

*Exporting EA replacement table in Excel and Stata format
save "${gsdData}/0-RawOutput/EA_Replacement_Table_Complete.dta", replace
export excel using "${gsdData}/0-RawOutput/EA_Replacement_Table_Complete.xls", cell(A3) sheetmodify

** ADDING INFORMATION FROM EA REPLACEMENT TABLE TO THE MAIN DATASET **

*Importing questionnaire
use "${gsdTemp}/hh_valid_keys_and_EAs_temp.dta", clear

*Merging with replacement table
merge m:1 id_ea using "${gsdData}/0-RawOutput/EA_Replacement_Table_Complete.dta", nogenerate keep(match master)
merge m:1 id_ea using "${gsdTemp}/ea_collapse", nogenerate keep(match master)

*Final cleaning and labelling
order id_ea, before(id_block)
label var nb_interviews_ea "Number of interviews per EA"
label var nb_treat1_ea "Number of interviews of Treat=1 per EA"
label var nb_treat2_ea "Number of interviews of Treat=2 per EA"
label var nb_treat3_ea "Number of interviews of Treat=3 per EA"
label var nb_treat4_ea "Number of interviews of Treat=4 per EA"
label var nb_valid_interviews_ea "Number of valid interviews per EA"
label var nb_valid_treat1_ea "Number of valid interviews of Treat=1 per EA"
label var nb_valid_treat2_ea "Number of valid interviews of Treat=2 per EA"
label var nb_valid_treat3_ea "Number of valid interviews of Treat=3 per EA"
label var nb_valid_treat4_ea "Number of valid interviews of Treat=4 per EA"
label var nb_success_interviews_ea "Number of successful interviews per EA"
label var nb_success_treat1_ea "Number of successful interviews of Treat=1 per EA"
label var nb_success_treat2_ea "Number of successful interviews of Treat=2 per EA"
label var nb_success_treat3_ea "Number of successful interviews of Treat=3 per EA"
label var nb_success_treat4_ea "Number of successful interviews of Treat=4 per EA"
label var nb_valid_success_itws_ea "Number of valid and successful interviews per EA"
label var nb_valid_success_treat1_ea "Number of valid and successful interviews of Treat=1 per EA"
label var nb_valid_success_treat2_ea "Number of valid and successful interviews of Treat=2 per EA"
label var nb_valid_success_treat3_ea "Number of valid and successful interviews of Treat=3 per EA"
label var nb_valid_success_treat4_ea "Number of valid and successful interviews of Treat=4 per EA"

save "${gsdData}/0-RawTemp/hh_valid_keys_and_EAs.dta", replace


/*----------------------------------------------------------------------------*/
/*                            EB REPLACEMENT TABLE			                  */
/*----------------------------------------------------------------------------*/

/*
Block replacement is made automatically through the questionnaire.
This code creates the replacement table at the block level from the database.
*/

*** IMPORTING DATABASE

use "${gsdData}/0-RawTemp/hh_valid_keys_and_EAs.dta", clear

*** PRELIMINARY CLEANING

/*Variable "block assigned to the enumerator at the beginning of the household selection part", equal to:
	- block the enumerator has been assigned to if it is not a replacement household
	- original block the enumerator has been assigned to if it is a replacement household
block_beginning is the block which will potentially need to be replaced */
g block_beginning = block_id

*Keeping only blocks which had to be replaced
keep if bl_replace == 1

*Keeping variables related to replacement
keep today id_ea block_beginning bl_replace bl_replace_reason ///
	 rep1 bl_replace1 bl_replace_reason1 rep2 bl_replace2 bl_replace_reason2 rep3 bl_replace3 bl_replace_reason3
order today id_ea block_beginning
sort id_ea block_beginning today

**Keeping only replacement blocks which have been activated as replacements
*If the first replacement block (rep1) that was proposed by the questionnaire did not need to be replaced, rep2 and rep3 have not been activated
replace rep2 = . if bl_replace1 == 0
replace rep3 = . if bl_replace1 == 0
*If the second block (rep2) that was proposed by the questionnaire did not need to be replaced, rep3 has not been activated
replace rep3 = . if bl_replace2 == 0
*Thus, we only display the blocks which really appeared in the block replacement process

*** RESHAPING DATABASE TO GET ALL CONSECUTIVE REPLACEMENTS IN ROWS

**Preparing database for reshape
rename (bl_replace bl_replace_reason) (bl_replace0 bl_replace_reason0)
g rep0 = block_beginning
order rep0, after(block_beginning)

*Creating index to uniquely identify the rows, because one block can have several replacement blocks
*Each block_beginning/index combination corresponds to a unique combination of a replaced block and its sequence of replacements
bysort id_ea block_beginning: g index = _n

*Reshaping to get one row per block replacement 
/*Before the reshape, the replaced blocks and the replacement blocks - as well as whether they need to be replaced and for which reasons - are in different columns 
	-> rep0, rep1, rep2, rep3, bl_replace0, bl_replace1, bl_replace2, bl_replace3, bl_replace_reason0, bl_replace_reason1, bl_replace_reason2, bl_replace_reason3
  The reshape aims at having one row per block replacement, with the following variables in columns:
	-> replacement block (rep), whether the block needed to be replaced (bl_replace), reason for replacement (bl_replace_reason), date of replacement (today)
  The number which was at the end of each variable name will give the replacement sequence (0,1,2 or 3) for a given original block
  A replacement sequence equal to 0 means that the block is an original block.
*/
reshape long bl_replace bl_replace_reason rep, i(id_ea block_beginning index) j(r_seq_block)

*Dropping empty observations
drop if r_seq_block > 0 & rep == .

*Renaming variables
rename (rep bl_replace_reason today) (bl_ref r_reason_block r_date_block)
*Keeping only date and not date and time
replace r_date_block = substr(r_date_block,1,10)
/*bl_ref will now serve as the reference block in the reshapes that will follow because:
	- block_beginning is (one of) its original block(s)
	- the block in the row below is (one of) its replacement block(s), if bl_ref needed to be replaced*/
*Creating original block variable if the reference block is a replacement block
g o_block = block_beginning if r_seq_block > 0

*Creating dummy variable: whether the reference block is included in the final sample
*A reference block is included in the final sample if there is at least one record where it was not replaced
g sample_final_block_temp = (bl_replace == 0)
bysort id_ea bl_ref: egen sample_final_block = max(sample_final_block_temp)
drop sample_final_block_temp


*** PART 1 OF BLOCK REPLACEMENT TABLE: REFERENCE BLOCKS AND THEIR ORIGINAL BLOCKS

/*The same reference block can have several different original blocks. We will reshape the database 
to get one row per reference block with the original blocks and their replacement sequence number(i.e. number of replacements between original block and reference block) in columns.*/
 
preserve 
*Keeping only reference blocks having an original block
keep if o_block != .
*Creating an index to uniquely identify the rows
*Each reference block/index_o combination corresponds to a unique reference block/original block combination
bysort id_ea bl_ref: g index_o = _n 
*Maximum number of originl blocks that a reference block can have
sum index_o
global index_o_max = `r(max)'
*Keeping variables related to original blocks
keep id_ea bl_ref index_o o_block r_seq_block sample_final_block
order id_ea bl_ref index_o o_block r_seq_block sample_final_block
*Reshaping to get one row per reference block with the original blocks and their replacement sequence number in columns
reshape wide o_block r_seq_block, i(id_ea bl_ref sample_final_block) j(index_o)
*Saving part 1 of block replacement table
save "${gsdTemp}/EB_Replacement_Table_Part1.dta", replace
restore

*** PART 2 OF BLOCK REPLACEMENT TABLE: REFERENCE BLOCKS AND THEIR REPLACEMENT BLOCKS

preserve
*Creating replacement block as the following block in the list of blocks if the 2 blocks belong to the same sequence of replacement
*Reminder: index allows identifying the different sequences of replacement for a given original block
sort id_ea block_beginning index r_seq_block
g r_block = bl_ref[_n+1] if (id_ea == id_ea[_n+1] & block_beginning == block_beginning[_n+1] & index == index[_n+1])
*Keeping only blocks which have been replaced
keep if bl_replace == 1
*Creating an index to uniquely identify the rows
*Each reference block/index_r combination corresponds to a unique reference block/replacement block combination
bysort id_ea bl_ref: g index_r = _n 
*Maximum number of originl blocks that a reference block can have
sum index_r
global index_r_max = `r(max)'
*Keeping variables related to replacement blocks
keep id_ea bl_ref index_r r_block r_date_block r_reason_block
order id_ea bl_ref index_r r_block r_date_block r_reason_block 
*Reshaping to get one row per reference block with the replacement blocks and the date and reason for replacement in columns
reshape wide r_block r_date_block r_reason_block, i(id_ea bl_ref) j(index_r)
*Saving part 2 of block replacement table
save "${gsdTemp}/EB_Replacement_Table_Part2.dta", replace
restore

*** ADDING THE 2 PARTS OF THE EB REPLACEMENT TABLE TO THE EB REPLACEMENT TABLE TEMPLATE

import excel "${gsdDataRaw}/Inputs EAs.xls", sheet("Master EBs") clear
drop if _n == 1 | _n == 3
foreach var of varlist * {
	rename `var' `=`var'[1]'
}
rename (ea block_sel_dummy) (id_ea sample_initial)
drop if _n ==1
destring *, replace

keep strata_id strata_name id_ea block_number sample_initial
order strata_id strata_name id_ea block_number sample_initial

rename block_number bl_ref
merge 1:1 id_ea bl_ref using "${gsdTemp}/EB_Replacement_Table_Part1.dta", nogenerate
merge 1:1 id_ea bl_ref using "${gsdTemp}/EB_Replacement_Table_Part2.dta", nogenerate
rename  bl_ref id_block
save "${gsdTemp}/EB_Replacement_Table_temp.dta", replace

*** FINALIZING EB REPLACEMENT TABLE WITH INFORMATION ON BLOCKS WHICH WERE NOT REPLACED
** GENERATING NUMBER OF VALID AND SUCCESSFUL INTERVIEWS PER EB

*Importing questionnaire
use "${gsdData}/0-RawTemp/hh_valid_keys_and_EAs.dta", clear 
*Collapse to make a dataset of summary elements for each EB
collapse (sum) nb_interviews_eb=index nb_valid_success_itws_eb=successful_valid, by(id_ea id_block)
order id_ea id_block, first
save "${gsdTemp}/eb_collapse.dta", replace

*Adding summary elements in the EB replacement table
use "${gsdTemp}/EB_Replacement_Table_temp.dta", clear
merge 1:1 id_ea id_block using "${gsdTemp}/eb_collapse.dta"

*Adding blocks in which at least one interview was conducted to the final sample
replace sample_final_block=1 if nb_interviews_eb >=1 & missing(nb_interviews_eb) == 0

*Labelling of variables
label var strata_name "Strata name"
label var strata_id "Strata ID"
label var id_ea "EA"
label var id_block "Block"
label var sample_initial "Whether block was initially sampled"
label var sample_final_block "Whether block is included in the final sample"
forvalues i = 1/$index_r_max{
	label var r_block`i' "Replacement block number `i'"
	label var r_reason_block`i' "Reason for replacement number `i'"
	label var r_date_block`i' "Date of replacement number `i'"
}
forvalues i = 1/$index_o_max{
	label var o_block`i' "Original block number `i'"
	label var r_seq_block`i' "Number of replacements between block and original block number `i' "
}
label var nb_interviews_eb "Number of interviews conducted in the block"
label var nb_valid_success_itws_eb "Number of valid and successful interviews conducted in the block"

*Exporting EB replacement table
save "${gsdData}/0-RawOutput/EB_Replacement_Table_Complete.dta", replace
export excel using "${gsdData}/0-RawOutput/EB_Replacement_Table_Complete.xlsx", firstrow(variables) sheetmodify
