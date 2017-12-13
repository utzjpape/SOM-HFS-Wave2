*clean and organize child file regarding livestock

set more off
set seed 23061980 
set sortseed 11061955

use "${gsdData}/0-RawTemp/hh_g_livestock_valid.dta", clear


rl_livestock 
rl_livestock_pre 


********************************************************************
* Relabel 'Don't know' and 'Refused to respond'
********************************************************************
* Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all

**************************************************************************
* Relabel Skip patterns: Please Refer to Questionnaire for relevance conditions
**************************************************************************
* Some missing values are due to the fact that they are not administered, i.e. they don't apply. For example, a child under 10 will not be asked about their profession. These are a special category of missing values and this section categorises them as such. 
* Skip pattern consistency and missing values due to skip patterns . ==> .z

assert missing(g_other_p_) if !(g_rel==1 & g_pos==7)
recode g_other_p_ (.=.z) if !(g_rel==1 & g_pos==7)

foreach v in g_born_n g_own_other g_own_n g_born_other g_kill_n g_sell_n g_sell_other g_kill_other g_give_n g_give_other g_buy_n g_buy_other g_lose_n g_lose_other  {
	assert missing(`v') if !(g_rel==1)
	recode `v' (.=.z) if !(g_rel==1)
}

foreach stub in sell kill give buy lose {
	foreach abb in val val_c val_other {
		assert missing(g_`stub'_`abb') if !(g_`stub'_n>0)
		recode g_`stub'_`abb' (.=.z) if !(g_`stub'_n>0)
	}
}

foreach stub in give lose {
	assert missing(g_`stub'_reason) if !(g_`stub'_n>0)
	recode g_`stub'_reason (.=.z) if !(g_`stub'_n>0)
}
	
foreach v in g_price_today g_price_today_c g_price_today_other {
	assert missing(`v') if !(g_own_n>0)
	recode `v' (.=.z) if !(g_own_n>0)
}
  
********************************************************************
* Adjust Value Labels
********************************************************************
labmm .z "Not administered"
labdu , delete report

*empty means form was not completed 
drop if g_n==""
ren g_* *

*other livestock or poultry should be string (but may be empty)
tostring other_, replace
tostring other_p_, replace
assert !(other_=="" & other_p_=="")
gen lstock_o=other_+other_p_
labmask pos, values(n)
drop n* *other* child_key setofrep_g

*rename and label
ren (pos rel price_today*) (lstockid raised pr_today*)
label var lstockid "Livestock ID"
label var lstock_o "Other livestock (specify)"
label var raised "Livestock was raised in last 12 months"
label var own_n "Number owned today"
label var pr_today "Price for one today"
label var pr_today_c "Price currency"
local pres = "born sell kill give buy lose"
local prelabs "born sold killed given bought lost"
local npre: word count `pres'
local sufs = "n val val_c reason reason_o"
local suflabs ""number" "value" "value currency" "reason" "reason (other)""
local nsuf: word count `sufs'
forval i = 1/`npre' {
	local pre: word `i' of `pres'
	local prelab: word `i' of `prelabs'
	local Pre = proper("`pre'")
	forval j = 1/`nsuf' {
		local suf: word `j' of `sufs'
		local suflab: word `j' of `suflabs'
		di "`suf' `suflab'"
		if "`suf'"=="n" {
			label var `pre'_`suf' "Number `prelab' in last 12 months"
		}
		else {
			cap label var `pre'_`suf' "`Pre' `suflab'"
		}
	}
}
label var key "Key to merge with parent"
order key lstock*

*drop empty variables
missings dropvars, force 

*drop variables with open answers, multiple numeric entries and/or in Somali
*drop lstock_o give_reason_o lose_reason_o



save "${gsdData}/0-RawTemp/hh_g_livestock_clean.dta", replace

