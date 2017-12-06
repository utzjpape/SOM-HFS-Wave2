*clean and organize child file regarding non-food

set more off
set seed 23081380 
set sortseed 11041355

use "${gsdData}/0-RawTemp/hh_f_nfood_valid.dta", clear

*empty f_item means form was not completed 
drop if f_item==""
ren (f_pos f_mod f_rel f_pr_t f_pr_c f_pr_kdk f_fr*) (nfoodid mod purc pr pr_c pr_kdk free*)

*change nfoodid
replace nfoodid = 1000 + nfoodid

*label values for ID and recall 
labmask nfoodid, values(f_item)
replace f_recall=lower(f_recall)
encode f_recall, generate(recall)
recode recall (4=1) (1=2) (2=4)
labmask recall, values(f_recall)

*label variables
label var nfoodid "Non-food ID"
label var mod "Randomly allocated module"
label var recall "Recall period"
label var purc "Item was paid for/received in the last recall period"
label var pr "Total price paid"
label var pr_c "Currency for total price paid"
label var pr_kdk "Options price"
label var free "Some of the item was received for free"
label var free_main "Main free source"
label var free_other "Other free source"
label var key "Key to merge with parent"
keep nfoodid mod purc* pr* free* key
order key nfoodid 
rename mod mod_item
label var mod_item "Assignment of item to core/optional module"

*drop empty variables
missings dropvars, force

*include correct denomination of missing values
foreach var in purc pr_kdk free free_main {
  replace `var'=.a if `var'==-99
  replace `var'=.b if `var'==-98
}
*include non-administered items
replace purc=.z if purc==.

*recognize non-administrered responses in the rest of the variables
foreach x of varlist pr-free_main {
   replace `x'=.z if `x'>=. & purc==.z 
}

*include changes in the lables
foreach labelname in f_rel f_pr_c f_pr_c f_pr_kdk f_fr f_fr_main {
 label define `labelname' .a "Refused to respond" .b "Don't know" .z "Not administered", modify
}

*drop variables with open answers, multiple numeric entries and/or in Somali
*drop free_other

drop if purc==.z

save "${gsdData}/0-RawTemp/hh_f_nfood_clean.dta", replace
