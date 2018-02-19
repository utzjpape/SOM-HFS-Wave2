*Clean and organize child file shocks

set more off
set seed 23081981 
set sortseed 11041956


********************************************************************
*Clean and prepare the shocks data
********************************************************************
use "${gsdData}/0-RawTemp/shocks_valid_successful_complete.dta", clear
drop shresp1_sp interview__key shresp1__1000 shresp1__n98 shresp1__n99 
order interview__id 

*Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist interview__id-shresp1__18 {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}

*Label and rename 
rename (shaffect__1 shaffect__2 shaffect__3 shaffect__4 shaffect__5) (shock_affect_1 shock_affect_2 shock_affect_3 shock_affect_4 shock_affect_5)
rename (shresp1__0 shresp1__1 shresp1__2 shresp1__3 shresp1__4 shresp1__5 shresp1__6 shresp1__7 shresp1__8 shresp1__9 shresp1__10 shresp1__11 shresp1__12 shresp1__13 shresp1__14 shresp1__15 shresp1__16 shresp1__17 shresp1__18) (shock_resp_0 shock_resp_1 shock_resp_2 shock_resp_3 shock_resp_4 shock_resp_5 shock_resp_6 shock_resp_7 shock_resp_8 shock_resp_9 shock_resp_10 shock_resp_11 shock_resp_12 shock_resp_13 shock_resp_14 shock_resp_15 shock_resp_16 shock_resp_17 shock_resp_18)
label define lyesno 0 "No" 1 "Yes" .a "Don't know" .b "Refused to respond" .z "Not administered" 
forval i=1/5  {
	label values shock_affect_`i' lyesno
}
label define limportant 0 "Not important" 1 "Most important" 2 "2nd most important" 3 "3rd most important" .a "Don't know" .b "Refused to respond" .z "Not administered" 
forval i=0/18 {
	label values shock_resp_`i' limportant
}

drop if shock_affect_1==. & shock_affect_2==. & shock_affect_3==. & shock_affect_4==. & shock_affect_5==. & shock_resp_0==. &  shock_resp_1==. & shock_resp_2==. & 	shock_resp_3==. & shock_resp_4==. & shock_resp_5==. & shock_resp_6==. & shock_resp_7==. & shock_resp_8==. & shock_resp_9==. & shock_resp_10==. & shock_resp_11==. & shock_resp_12==. & shock_resp_13==. & shock_resp_14==. & shock_resp_15==. & shock_resp_16==. & shock_resp_17==. & shock_resp_18==. 																							
rename shocks__id shock_id
label var shock_id "ID of shock"
save "${gsdData}/0-RawOutput/hh_shocks_clean.dta", replace
