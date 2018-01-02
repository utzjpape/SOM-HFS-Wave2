*Clean and organize child file regarding livestock

set more off
set seed 23061980 
set sortseed 11061955

 
********************************************************************
*Roster on livestock for all households 
********************************************************************
use "${gsdData}/0-RawTemp/rl_livestock_valid_successful_complete.dta", clear
order interview__id rl_livestock__id rl_own_n_kdk rl_own_n rl_own_r_n_kdk rl_own_r_n rl_price_today_kdk rl_price_today rl_price_today_curr rl_sell_n_kdk rl_sell_n rl_sell_val_kdk rl_sell_val rl_sell_val_curr rl_kill_n_kdk rl_kill_n rl_give_n_kdk rl_give_n rl_give_reason rl_buy_n_kdk rl_buy_n rl_buy_val_kdk rl_buy_val rl_buy_val_curr rl_lose_n_kdk rl_lose_n rl_lose_reason
drop interview__key rl_give_reason_o rl_lose_reason_o 

*Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist interview__id-rl_lose_reason {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}

*Introduce own dummy for each item
gen own=1
label var own "G.2 Item is owned by the household?"
label define lyesno 0 "No" 1 "Yes" .a "Don't know" .b "Refused to respond" .z "Not administered" 
label values own lyesno
order own, after(rl_livestock__id)

*Include skip patterns 
replace rl_own_n=.z if rl_own_n_kdk>=.
replace rl_own_r_n=.z if rl_own_r_n_kdk>=. 
replace rl_price_today_kdk=.z if rl_own_n<=0 | rl_own_n>=.
replace rl_price_today=.z if rl_own_n<=0 | rl_price_today_kdk>=.
replace rl_price_today_curr=.z if rl_price_today>=. 
replace rl_sell_n=.z if rl_sell_n_kdk>=.
replace rl_sell_val_kdk=.z if  rl_sell_n<=0 | rl_sell_n>=.
replace rl_sell_val=.z if  rl_sell_n<=0 | rl_sell_val_kdk>=.
replace rl_sell_val_curr=.z if rl_sell_val>=.
replace rl_kill_n=.z if rl_kill_n_kdk>=. 
replace rl_give_n=.z if rl_give_n_kdk>=.
replace rl_give_reason=.z if rl_give_n<=0 | rl_give_n>=. 
replace rl_buy_n=.z if rl_buy_n_kdk>=. 
replace rl_buy_val_kdk=.z if rl_buy_n<=0 | rl_buy_n>=.
replace rl_buy_val=.z if rl_buy_n<=0 | rl_buy_val_kdk>=.
replace rl_buy_val_curr=.z if rl_buy_val>=. 
replace rl_lose_n=.z if rl_lose_n_kdk>=. 
replace rl_lose_reason=.z if rl_lose_n<=0 | rl_lose_n>=.

*Label and rename 
foreach var in rl_own_n_kdk rl_own_r_n_kdk rl_price_today_kdk rl_price_today_curr rl_sell_n_kdk rl_sell_val_kdk rl_sell_val_curr rl_kill_n_kdk rl_give_n_kdk rl_give_reason rl_buy_n_kdk rl_buy_val_kdk rl_buy_val_curr rl_lose_n_kdk rl_lose_reason {
	label define `var' .a "Don't know" .b "Refused to respond" .z "Not administered", modify
}
label var rl_livestock__id "Livestock ID"
rename (rl_livestock__id rl_own_n_kdk rl_own_n rl_own_r_n_kdk rl_own_r_n rl_price_today_kdk rl_price_today rl_price_today_curr) (livestockid own_n_kdk own_n own_r_n_kdk own_r_n pr_today_kdk pr_today pr_today_c)
rename (rl_sell_n_kdk rl_sell_n rl_sell_val_kdk rl_sell_val rl_sell_val_curr rl_kill_n_kdk rl_kill_n) (sell_n_kdk sell_n sell_val_kdk sell_val sell_val_c kill_n_kdk kill_n )
rename (rl_give_n_kdk rl_give_n rl_give_reason rl_buy_n_kdk rl_buy_n rl_buy_val_kdk rl_buy_val rl_buy_val_curr rl_lose_n_kdk rl_lose_n rl_lose_reason) (give_n_kdk give_n give_reason buy_n_kdk  buy_n buy_val_kdk buy_val buy_val_c lose_n_kdk lose_n lose_reason)

*Include the name of each item
label define livestockid 1 "Cattle" 2 "Sheep" 3 "Goats" 4 "Camels" 5 "Chickens" 6 "Donkeys" 7 "Horses" 1000 "Other"
label values livestockid livestockid

save "${gsdData}/0-RawOutput/hh_livestock_clean.dta", replace


********************************************************************
*Roster on livestock for IDP households before displacement
********************************************************************
use "${gsdData}/0-RawTemp/rl_livestock_pre_valid_successful_complete.dta", clear
order interview__id rl_livestock_pre__id rl_own_pre_kdk rl_own_pre rl_own_pre_r_n_kdk rl_own_pre_r_n
drop interview__key 

*Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist interview__id-rl_own_pre_r_n {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}

*Introduce own dummy for each item
gen own=1
label var own "G.2 Item is owned by the household?"
label define lyesno 0 "No" 1 "Yes" .a "Don't know" .b "Refused to respond" .z "Not administered" 
label values own lyesno
order own, after(rl_livestock_pre__id)

*Include skip patterns 
replace rl_own_pre=.z if rl_own_pre_kdk>=.
replace rl_own_pre_r_n=.z if rl_own_pre_r_n_kdk>=.

*Label and rename 
foreach var in rl_own_pre_kdk rl_own_pre_r_n_kdk {
	label define `var' .a "Don't know" .b "Refused to respond" .z "Not administered", modify
}
label var rl_livestock_pre__id "Livestock ID"
rename (rl_livestock_pre__id rl_own_pre_kdk rl_own_pre rl_own_pre_r_n_kdk rl_own_pre_r_n) (livestockid own_pre_kdk own_pre own_pre_r_n_kdk own_pre_r_n)

*Include the name of each item
label define livestockid 1 "Cattle" 2 "Sheep" 3 "Goats" 4 "Camels" 5 "Chickens" 6 "Donkeys" 7 "Horses" 1000 "Other"
label values livestockid livestockid

save "${gsdData}/0-RawOutput/hh_livestock_pre_clean.dta", replace
