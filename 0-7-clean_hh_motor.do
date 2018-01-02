*clean and organize child file regarding fisheries

set more off
set seed 23081660 
set sortseed 11041665


********************************************************************
*Roster on motors
********************************************************************
use "${gsdData}/0-RawTemp/motor_valid_successful_complete.dta", clear
order interview__id motor__id boat_motor boat_motor_capacity_kdk boat_motor_capacity
drop interview__key motor__id

*Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist interview__id-boat_motor_capacity {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}

*Introduce motor dummy for each item
gen motor=1
label var motor "K.2 Motor owned by the household?"
label define lyesno 0 "No" 1 "Yes" .a "Don't know" .b "Refused to respond" .z "Not administered" 
label values motor lyesno
order motor, after(interview__id)

*Include skip patterns 
replace boat_motor_capacity_kdk=.z if boat_motor!=1
replace boat_motor_capacity=.z if boat_motor!=1 | boat_motor_capacity_kdk>=.

*Label and rename 
foreach var in boat_motor_capacity_kdk boat_motor {
	label define `var' .a "Don't know" .b "Refused to respond" .z "Not administered", modify
}

save "${gsdData}/0-RawOutput/hh_motor_clean.dta", replace

