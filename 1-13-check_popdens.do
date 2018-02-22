* Prepare wave 1 EAs pop density for analysis
import excel "${gsdDataRaw}/Wave_1/Rural_EAs_Worldpop.xls", clear firstrow
collapse (mean) popdens=grid_code, by(zone_name reg_name dist_name strata ea) 
save "${gsdTemp}/Rural_EAs_Worldpop.dta", replace
import excel "${gsdDataRaw}/Wave_1/Urban_EAs_Worldpop.xls", clear firstrow
collapse (mean) popdens=grid_code, by(zone_name reg_name dist_name strata ea) 
append using "${gsdTemp}/Rural_EAs_Worldpop.dta"
merge 1:1 ea using "${gsdData}/1-CleanInput/SHFS2016/ea_anonkey.dta", keep(match) nogen
drop ea rand
ren ea_anon ea
merge 1:m ea using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", keep(match using) nogen
save "${gsdData}/1-CleanTemp/hh_PopDens-w1.dta", replace

* Prepare wave 2 EAs pop density for analysis
import delim "${gsdDataRaw}/EAs_Worldpop.txt", clear
collapse (mean) popdens=grid_code, by(strata_id psu_id type_pop) 
ren psu_id ea
merge 1:1 ea using "${gsdTemp}/ea_anonkey.dta", keep(match) nogen
drop ea rand
ren ea_anon ea
merge 1:m ea using "${gsdData}/1-CleanOutput/hh.dta", keep(match using) nogen
save "${gsdData}/1-CleanTemp/hh_PopDens-w2.dta", replace 

* Merge W1 and W2 data
use "${gsdData}/1-CleanTemp/hh_PopDens-w1.dta", clear
append using "${gsdData}/1-CleanTemp/hh_PopDens-w2.dta", gen(t)
label define lind_profile 1 "Mogadishu (Urban)" 2 "North-east Urban (Nugaal,Bari,Mudug)" 3 "North-west Urban (Woqooyi G,Awdal,Sanaag,Sool,Togdheer)" 4 "North-east Rural (Bari,Mudug,Nugaal)" 5 "North-west Rural (Awdal,Sanaag,Sool,Togdheer,Woqooyi)" 6 "IDP Settlements" 7 "Central regions Urban (Hiraan, Middle Shabelle, Galgaduud)" 8 "Central regions Rural (Hiraan, Middle Shabelle, Galgaduud)" 9 "Jubbaland Urban (Gedo, lower and middle Juba)" 10 "Jubbaland Rural (Gedo, lower and middle Juba)" 11 "South West Urban (Bay, Bakool and lower Shabelle)" 12 "South West Rural (Bay, Bakool and lower Shabelle)" 13 "Nomadic population", replace
label values ind_profile lind_profile
save "${gsdData}/1-CleanTemp/hh_PopDens.dta", replace 

* Analyse differences at EA level (unweighted)
use "${gsdData}/1-CleanTemp/hh_PopDens.dta", clear
collapse (mean) popdens, by(t strata ea ind_profile)
egen ind_t = group(ind_profile t), label
* Tabout main data
preserve 
keep if t==0
tabout ind_profile using "${gsdOutput}/PopDensity_raw1_1.xls", sum c(mean popdens) f(3) npos(col) sebnone h2("Population density, w1") replace
restore
preserve
keep if t==1
tabout ind_profile using "${gsdOutput}/PopDensity_raw1_2.xls", sum c(mean popdens) f(3) npos(col) sebnone h2("Population density, w2") replace
restore
* Prepare significance tests
drop if ind_profile>5
putexcel set "${gsdOutput}/PopDensity_raw1_3.xls", modify
levelsof ind_profile, local(ind)
local k=1
foreach i in `ind' {
	preserve
	keep if ind_profile==`i'
	mean popdens, over(ind_t)
	test _subpop_1 = _subpop_2
	putexcel A`k' ="Group`i'"
	putexcel B`k' =`r(p)'
	local k=`k'+1
	restore
}
insheet using "${gsdOutput}/PopDensity_raw1_2.xls", clear nonames tab
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("PopDensity_raw1") sheetreplace firstrow(variables)
insheet using "${gsdOutput}/PopDensity_raw1_1.xls", clear nonames tab
replace v2=v1 if v2==""
drop v1
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("PopDensity_raw1") sheetmodify cell(D1) firstrow(variables)
import excel using "${gsdOutput}/PopDensity_raw1_3.xls", clear 
ren B p_value
drop A
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("PopDensity_raw1") sheetmodify cell(F3) firstrow(variables)

* Check correlation between poverty and popdens
use "${gsdData}/1-CleanTemp/hh_all.dta", clear
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/hh_PopDens.dta", keep(master match) keepusing(popdens) nogen
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty_all.dta", nogen assert(match master) keepusing(tc_core)
svy: reg tc_core popdens t if inlist(ind_profile, 4)
outreg2 using "${gsdOutput}/PopDensity_raw2.xls", replace ctitle("tc_core w/ PopDens, NE rural") label excel keep(t popdens) nocons
svy: reg tc_core t if inlist(ind_profile, 4) & !mi(popdens)
outreg2 using "${gsdOutput}/PopDensity_raw2.xls", append ctitle("tc_core w/o PopDens, NE rural") label excel keep(t) nocons
import delim using "${gsdOutput}/PopDensity_raw2.txt", clear 
export excel using "${gsdOutput}/W1W2-comparison_v2.xlsx", sheet("PopDensity_raw2") sheetreplace firstrow(variables)


svy: reg poorPPP_prob popdens if t==0
svy: reg poorPPP_prob popdens if t==1
svy: reg poorPPP_prob popdens if type==1 
svy: reg poorPPP_prob popdens if type==2
svy: reg poorPPP_prob popdens if type==1 & t==0
svy: reg poorPPP_prob popdens if type==2 & t==0
svy: reg poorPPP_prob popdens if type==1 & t==1
svy: reg poorPPP_prob popdens if type==2 & t==1
