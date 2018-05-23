* Prepare Wave 1 data
* Household level
use "${gsdData}/1-CleanInput/SHFS2016/hhm.dta", clear
bys strata ea block hh: egen n_always=sum(hh_alwayslived)
gen x=1 if hh_alwayslived<.
bys strata ea block hh: egen n_adult=sum(x)
gen prop_migr= 1 - n_always/n_adult
gen intl_born=born_somalia==0 if ishead==1
gen int_born=(birthplace_som!=reg_pess) if ishead==1
collapse (max) prop_migr intl_born int_born, by(strata ea block hh)
la var prop_migr "Proportion of household members who have not always lived in the current household"
la var intl_born "Household head was born outside SOM" 
la var int_born "Household head was born outside of current region" 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", nogen
save "${gsdData}/1-CleanTemp/hh_w1_remit.dta", replace
* Household member level
use "${gsdData}/1-CleanInput/SHFS2016/hhm.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", nogen keepusing(remit12m remit12m_usd)
save "${gsdData}/1-CleanTemp/hhm_w1_remit.dta", replace

* Prepare Wave 2 data
* Household level
use "${gsdData}/1-CleanInput/hhm.dta", clear
bys strata ea block hh: egen n_always=sum(hh_alwayslived)
gen x=1 if hh_alwayslived<.
bys strata ea block hh: egen n_adult=sum(x)
gen prop_migr= 1 - n_always/n_adult
gen intl_born=born_somalia==0 if hhm_relation==1
gen int_born=(birthplace_som!=region) if hhm_relation==1
collapse (max) prop_migr intl_born int_born, by(strata ea block hh)
la var prop_migr "Proportion of household members who have not always lived in the current household"
la var intl_born "Household head was born outside SOM" 
la var int_born "Household head was born outside of current region" 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen

save "${gsdData}/1-CleanTemp/hh_w2_remit.dta", replace
* Household member level
use "${gsdData}/1-CleanInput/hhm.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen keepusing(remit12m remit12m_usd)
save "${gsdData}/1-CleanTemp/hhm_w2_remit.dta", replace

* Prepare comparable wave 1 and wave 2 data 
use "${gsdData}/1-CleanTemp/hhm_w1w2.dta", clear
bys t strata ea block hh: egen n_always=sum(hh_alwayslived)
gen x=1 if hh_alwayslived<.
bys t strata ea block hh: egen n_adult=sum(x)
gen prop_migr= 1 - n_always/n_adult
gen intl_born=born_somalia==0 if hhm_relation==1
gen int_born=(birthplace_som!=reg_pess) if hhm_relation==1
collapse (max) prop_migr intl_born int_born, by(t strata ea block hh)
la var prop_migr "Proportion of household members who have not always lived in the current household"
la var intl_born "Household head was born outside SOM" 
la var int_born "Household head was born outside of current region" 
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/hh_all_comparable.dta", nogen
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
save "${gsdData}/1-CleanTemp/hh_comparable_remit.dta", replace
* Household member level
use "${gsdData}/1-CleanTemp/hhm_all_comparable.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_all_comparable.dta", nogen keepusing(*emit12m *emit12m_usd)
save "${gsdData}/1-CleanTemp/hhm_comparable_remit.dta", replace
