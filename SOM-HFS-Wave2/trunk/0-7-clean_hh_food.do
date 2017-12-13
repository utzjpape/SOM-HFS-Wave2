*clean and organize child file regarding food

set more off
set seed 23081670 
set sortseed 11041675

use "${gsdData}/0-RawTemp/hh_e_food_valid.dta", clear



rf_food
rf_food_cereals 
rf_food_fruit 
rf_food_meat 
rf_food_vegetables 



*empty e_item means form was not completed 
drop if e_item==""
labmask e_pos, values(e_item)
ren (e_pos e_mod e_rel e_pr_t e_pr_c e_pr_kdk e_fr*) (foodid mod e_rel_c pr pr_c pr_kdk free*)
foreach xxx in purchased consumed {
	local xx = substr("`xxx'",1,4)
	local x = substr("`xxx'",1,1)
	ren e_rel_`x' `xx'
	label var `xx' "Item was `xxx' in last 7 days"
	encode e_`x'_u, generate(`xx'_u)
	label var `xx'_u "Unit `xxx'"
	ren e_`x'_q `xx'_q
	label var `xx'_q "Quantity `xxx'"
	ren e_`x'_kdk `xx'_kdk
	label var `xx'_kdk "Options `xxx'"
	ren e_`x'_kg `xx'_q_kg
	label var `xx'_q_kg "Unit `xxx' (kg), automatic conversion"
	ren e_`x'_kg `xx'_q_kg_est
	label var `xx'_q_kg_est "Unit `xxx' (kg), enumerator estimate"
	order `xx' `xx'_q `xx'_u `xx'_q_kg `xx'_kdk
}
label var foodid "Food ID"
label var mod "Randomly allocated module"
label var pr "Total price paid for purchases"
label var pr_c "Currency for total price paid"
label var pr_kdk "Options price"
label var free "Some of the item was received for free"
label var free_main "Main free source"
label var free_other "Other free source"
label var key "Key to merge with parent"
keep foodid mod cons* purc* pr* free* key
order key foodid mod cons* purc*
rename mod mod_item
label var mod_item "Assignment of item to core/optional module"

*drop empty variables
missings dropvars, force

*include correct denomination of missing values
foreach var in cons cons_kdk purc purc_kdk pr_kdk free free_main {
  replace `var'=.a if `var'==-99
  replace `var'=.b if `var'==-98
}
*include non-administered consumption
replace cons=.z if cons==.

*recognize non-administrered responses in the rest of the variables
foreach x of varlist cons_q-free_main {
   replace `x'=.z if `x'>=. & cons==.z 
}

*include changes in the lables
foreach labelname in cons_u purc_u e_pr_c e_rel e_c_kdk e_rel_p e_p_kdk e_pr_kdk e_fr e_fr_main {
label define `labelname' .a "Refused to respond" .b "Don't know" .z "Not administered", modify
}

*drop variables with open answers, multiple numeric entries and/or in Somali
*drop free_other

drop if purc==.z

save "${gsdData}/0-RawTemp/hh_e_food_clean.dta", replace

