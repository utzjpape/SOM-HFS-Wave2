*check the completeness of submissions between parent and child files
 

set more off
set seed 23081650 
set sortseed 11041895

*check all the different sections of the survey agains the parent file
*check the hhm file 
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
merge 1:m key using "${gsdData}/0-RawTemp/hhm_clean.dta", nogen assert(match)
*check the names file
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
merge 1:m key using "${gsdData}/0-RawTemp/hhm_c_names_clean.dta", nogen assert(match)
*check food consumption
*Idenified 4 submissions with no information on food, non-food, assets and livestock 
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
merge 1:m key using "${gsdData}/0-RawTemp/hh_e_food_clean.dta", nogen keep(match)
*check non-food consumption
*Idenified 4 submissions with no information on food, non-food, assets and livestock 
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
merge 1:m key using "${gsdData}/0-RawTemp/hh_f_nfood_clean.dta", nogen keep(match)
*check assets
*Idenified 4 submissions with no information on food, non-food, assets and livestock 
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
merge 1:m key using "${gsdData}/0-RawTemp/hh_h_assets_clean.dta", nogen keep(match)
*check livestock
*Idenified 7 households in addition to the 4 submissions with no information on food, non-food, assets and livestock 
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
merge 1:m key using "${gsdData}/0-RawTemp/hh_g_livestock_clean.dta", nogen keep(master match)
*check illnesses
*** 2,342 households with no info on illnesses (distributed across all regions)
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
merge 1:m key using "${gsdData}/0-RawTemp/hhm_c_illnesses_clean.dta", nogen keep(master match)
*check food security (this section was not included in South-Central)
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
drop if zone==4
merge 1:m key using "${gsdData}/0-RawTemp/hh_k_fsecurity_clean.dta", nogen assert(match)
*check income sources (this section was not included in South-Central)
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
drop if zone==4
merge 1:m key using "${gsdData}/0-RawTemp/hh_l_incomesources_clean.dta", nogen assert(match)
*check enterprises (this section was not included in South-Central)
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
drop if zone==4
merge 1:m key using "${gsdData}/0-RawTemp/hh_m_enterprises_clean.dta", nogen keep(master match)
*check shocks (this section was not included in South-Central)
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
drop if zone==4
merge 1:m key using "${gsdData}/0-RawTemp/hh_n_shocks_clean.dta", nogen keep(master match)

*introduce corrections
*drop 4 incomplete submissions with no information on food consumption, assets and livestock
use "${gsdData}/0-RawTemp/hh_clean.dta", clear
drop if key=="uuid:0c00c974-ad66-4ed8-8a95-826d44f3c1f7" | key=="uuid:a66cb5aa-67ae-4c4e-abc5-2afba4c5ea7c" | key=="uuid:b99dfaca-9f00-4280-9e79-ac70b8913ce4" | key=="uuid:f0e2441a-b30f-4a4a-9924-99897bebc5ba"
save "${gsdData}/0-RawTemp/hh_complete.dta", replace
foreach suff in "hhm_c_illnesses" "hhm" "hhm_c_names" "hh_e_food" "hh_f_nfood" "hh_g_livestock" "hh_h_assets" "hh_k_fsecurity" "hh_l_incomesources" "hh_m_enterprises" "hh_n_shocks" {
	use "${gsdData}/0-RawTemp/`suff'_clean.dta", clear
    drop if key=="uuid:0c00c974-ad66-4ed8-8a95-826d44f3c1f7" | key=="uuid:a66cb5aa-67ae-4c4e-abc5-2afba4c5ea7c" | key=="uuid:b99dfaca-9f00-4280-9e79-ac70b8913ce4" | key=="uuid:f0e2441a-b30f-4a4a-9924-99897bebc5ba"
	save "${gsdData}/0-RawOutput/`suff'.dta", replace
}

*note: no action for all of the other cases with no information (7 hhs in livestock, 3,030 hhs in enterprises, 2,683 hhs for shocks and 2,345 for illnesses). The underlying assumption is that the lack of information means the household did not have something to report

