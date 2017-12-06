*clean and organize child file regarding names of household members

set more off
set seed 23051980 
set sortseed 11051955

use "${gsdData}/0-RawTemp/hhm_c_names_valid.dta", clear

drop child_key validname setofhhm_names
label var key "Key to merge with parent"
order key 

*drop empty variables
missings dropvars, force 

save "${gsdData}/0-RawTemp/hhm_c_names_clean.dta", replace
