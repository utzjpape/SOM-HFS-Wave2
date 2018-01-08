*Produce tables to report the impact of the cleaning process on consumption variables

set more off
set seed 23181960 
set sortseed 13041965


********************************************************************
*Create tables to report for food 
********************************************************************
use "${gsdData}/1-CleanTemp/food.dta" , clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(hhsize type)
replace cons_usd = cons_usd/hhsize 
replace cons_usd=. if cons_usd==0
rename (unit_price cons_usd) (unit_price_cleaned cons_usd_cleaned)
label var unit_price_cleaned "Price cleaned"
label var cons_usd_cleaned "Cons cleaned"
save "${gsdData}/1-CleanTemp/food_checking_tables.dta", replace
local va  "unit_price_cleaned cons_usd_cleaned" 
*Overall for food items
foreach v of local va {
	use  "${gsdData}/1-CleanTemp/food_checking_tables.dta" , clear
	local name : variable label `v'
	collapse (count) N = `v' (mean) mean = `v' (min) min = `v' (p1) p1 = `v' (p5) p5 = `v' (p25) p25 = `v' (p50) median = `v' (p75) p75 = `v' (p95) p95 = `v' (max) max = `v' , by(itemid)
	gsort -N 
	export excel using "${gsdOutput}/Check food cleaning.csv", first(var) sheet("Overall `name'") sheetreplace
}
*By urban/rural/IDP for food items
use "${gsdData}/1-CleanTemp/food_checking_tables.dta", clear
forval i=1/3 {
foreach v of local va {
   	display "`va'"
	use "${gsdData}/1-CleanTemp/food_checking_tables.dta" , clear
	local name : variable label `v'
	keep if type==`i'
	collapse (count) N = `v' (mean) mean = `v' (min) min = `v' (p1) p1 = `v' (p5) p5 = `v' (p25) p25 = `v' (p50) median = `v' (p75) p75 = `v' (p95) p95 = `v' (max) max = `v' , by(itemid type)
	gsort -N 
	if type==1 {
		export excel using "${gsdOutput}/Check food cleaning.csv", first(var) sheet("Urban `name'") sheetreplace
	}
	if type==2 {
		export excel using "${gsdOutput}/Check food cleaning.csv", first(var) sheet("Rural `name'") sheetreplace
	}
	if type==3 {
		export excel using "${gsdOutput}/Check food cleaning.csv", first(var) sheet("IDPs `name'") sheetreplace
	}
}
}


********************************************************************
*Create tables to report for non-food 
********************************************************************
use "${gsdData}/1-CleanTemp/nonfood.dta" , clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(hhsize type)
replace pr_usd= pr_usd/hhsize 
replace pr_usd=. if pr_usd==0
rename (pr_usd) (pr_usd_cleaned)
label var pr_usd_cleaned "Purchase value cleaned"
save "${gsdData}/1-CleanTemp/nonfood_checking_tables.dta", replace
local va  "pr_usd" 
*Overall for non-food items
foreach v of local va {
	use  "${gsdData}/1-CleanTemp/nonfood_checking_tables.dta" , clear
	local name : variable label `v'
	collapse (count) N = `v' (mean) mean = `v' (min) min = `v' (p1) p1 = `v' (p5) p5 = `v' (p25) p25 = `v' (p50) median = `v' (p75) p75 = `v' (p95) p95 = `v' (max) max = `v' , by(itemid)
	gsort -N 
	export excel using "${gsdOutput}/Check nonfood cleaning.csv", first(var) sheet("Overall `name'") sheetreplace
}
*By urban/rural/IDP for non-food items
use "${gsdData}/1-CleanTemp/nonfood_checking_tables.dta", clear
forval i=1/3 {
foreach v of local va {
   	display "`va'"
	use "${gsdData}/1-CleanTemp/nonfood_checking_tables.dta" , clear
	local name : variable label `v'
	keep if type==`i'
	collapse (count) N = `v' (mean) mean = `v' (min) min = `v' (p1) p1 = `v' (p5) p5 = `v' (p25) p25 = `v' (p50) median = `v' (p75) p75 = `v' (p95) p95 = `v' (max) max = `v' , by(itemid type)
	gsort -N 
	if type==1 {
		export excel using "${gsdOutput}/Check nonfood cleaning.csv", first(var) sheet("Urban `name'") sheetreplace
	}
	if type==2 {
		export excel using "${gsdOutput}/Check nonfood cleaning.csv", first(var) sheet("Rural `name'") sheetreplace
	}
	if type==3 {
		export excel using "${gsdOutput}/Check nonfood cleaning.csv", first(var) sheet("IDPs `name'") sheetreplace
	}
}
}
