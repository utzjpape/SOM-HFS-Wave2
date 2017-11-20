* create a fake wave 2 data set to be able to do analysis before having wave 2 data
set more off
set seed 23081980 
set sortseed 11041955


use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear
append using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", gen(t)
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/rainfall.dta", nogen assert(match) keepusing(drought1)
replace poorPPP_prob = poorPPP_prob*runiform(1.1, 1.2) if t==1
replace poorPPP_prob = poorPPP_prob*runiform(1.1, 1.2) if drought1==1 & t==1
replace pgi = pgi*runiform(1.1, 1.2) if t==1
replace pgi = pgi*runiform(1.1, 1.2) if drought1==1 & t==1
replace tc_imp = tc_imp*runiform(0.7, 0.9) if t==1
replace tc_imp = tc_imp*runiform(0.7, 0.8) if drought1==1 & t==1
drop drought1
save "${gsdData}/1-CleanInput/hh_all.dta", replace
