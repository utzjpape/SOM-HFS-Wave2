* ==============================================================================
* Setup 
* ==============================================================================
set more off
set seed 23081980 
set sortseed 11041955

* Define sample once at the beginning: switch on and off by removing/adding '*' in the respective global 
global migr_disp = "   drop if migr_disp==1"
global pld1 	 = "   drop if inlist(ind_profile,2,4) & t==0"
global migr 	 = " * drop if prop_alwayslive==0"
global pljl2 	 = " * drop if inlist(ind_profile,4,9) & t==1"
* Choose dataset:
* NDVI1 = NDVI from Deyr 2016 + Gu 2017
* NDVI2 = NDVI from Gu 2017
* NDVI3 = NDVI from Deyr 2016
* SPI = SPI from Gu 2016 + Deyr 2016 + Gu 2017
* SPI1 = SPI from Deyr 2016 + Gu 2017
* SPI2 = SPI from Gu 2017
* SPI3 = SPI from Deyr 2016

global drought = "NDVI1"

*===============================================================================
* Statistics for Introduction part of chapter 
*===============================================================================
* Rainfall and NDVI timeseries
use "${gsdData}/1-CleanTemp/rainfall_timeseries.dta", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_Rainfall_TS") first(variables)

* IPC classification over time ** 
use "${gsdData}/1-CleanTemp/IPC_Population.dta", clear
gen projection = Date0!=Date1
gen date = (Date1 + Date0)/2
format date %td
drop *1 *0
order date total_* projection
sort date
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheet("Raw_IPC") sheetreplace firstrow(variables)

* Reporting of hunger by pre-war region
use "${gsdData}/1-CleanTemp/hh_all.dta", clear
svyset ea [pweight=weight_adj], strata(strata)
gen hunger_bin = hunger>1 if !mi(hunger)
preserve 
keep if t==1
collapse (mean) hunger_bin [pweight=weight_adj], by(reg_pess) 
export delim "${gsdOutput}/hunger_by_region_w2.csv", replace
restore
preserve
keep if t==1
bysort strata: egen hunger_reg = mean(hunger_bin)
collapse (mean) hunger_reg [pweight=weight_adj], by(reg_pess strata type) 
export delim "${gsdOutput}/hunger_urban.csv" if type==1, replace
export delim "${gsdOutput}/hunger_rural.csv" if type==2, replace
restore 
preserve
bysort strata: egen hunger_reg = mean(hunger_bin)
collapse (mean) hunger_reg [pweight=weight_adj], by(reg_pess strata type) 
export delim "${gsdOutput}/hunger_idp.csv" if type==3, replace
export delim "${gsdOutput}/hunger_nomad.csv" if type==4, replace
restore
collapse (mean) hunger_bin [pweight=weight_adj], by(t) 
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheet("Raw_IPC") sheetmodify cell(A13) firstrow(variables)

* Drought-related displacement and health crises
import delim using "${gsdShared}\0-Auxiliary\EmergencyFigures_historical.csv", clear
keep if crisis_name=="Somalia"
* displacement 
preserve
keep if figure_name=="Internally Displaced due to Drought (per month)"  
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheet("Raw_Displacement") sheetreplace firstrow(variables)
restore
preserve
keep if figure_name=="IDPs" 
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheet("Raw_Displacement") sheetmodify cell(D1) firstrow(variables)
restore
preserve
keep if figure_name=="Internally Displaced due to Conflict (per year)" 
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheet("Raw_Displacement") sheetmodify cell(G1) firstrow(variables)
restore
* Health
preserve
keep if figure_name=="AWD/Cholera Cases (Cumulative per year)"
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheet("Raw_Health") sheetreplace firstrow(variables)
restore
preserve
keep if figure_name=="AWD/Cholera Deaths (Cumulative per year)"
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheet("Raw_Health") sheetmodify cell(D1) firstrow(variables)
restore
preserve
keep if figure_name=="Measles Suspected Cases in 2017"
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheet("Raw_Health") sheetmodify cell(G1) firstrow(variables)
restore

*===============================================================================
* Drought properties 
*===============================================================================
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen assert(match master) keep(match) keepusing(${drought} drought_${drought})
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core  mi_cons_f0 mi_cons_nf0)
gen pweight=weight_adj
svyset ea [pweight=pweight], strata(strata) singleunit(centered)

* keep only relevant populations
drop if inlist(type,3,4)
$migr_disp
$pld1
$migr
$pljl2 

su ${drought}
twoway (hist ${drought} if t==0, width(1) start(`r(min)') freq) 
qui graph save Graph "${gsdTemp}/${drought}_hist_HHs_w1.gph", replace
twoway hist ${drought} if t==1, width(1) start(`r(min)')  freq
qui graph save Graph "${gsdTemp}/${drought}_hist_HHs_w2.gph", replace

qui graph use "${gsdTemp}/${drought}_hist_HHs_w1.gph", 
serset use, clear
ren (__0000*) (hist_w1 x ${drought})
sort ${drought} 
recode ${drought} (.=0)
drop x
save "${gsdTemp}/${drought}_hist_HHs_w1.dta", replace
qui graph use "${gsdTemp}/${drought}_hist_HHs_w2.gph", 
serset use, clear
ren (__0000*) (hist_w2 x ${drought})
drop x
sort ${drought} 
recode ${drought} (.=0)
merge m:m ${drought} using "${gsdTemp}/${drought}_hist_HHs_w1.dta", nogen
order ${drought} *w1 *w2
recode hist_* (.=0)
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_DroughtDistribution") firstrow(var)


* NDVI deviation Distribution
* All SOM
use "${gsdData}/1-CleanTemp/NDVI1_SOM0.dta", clear
su NDVI1_SOM0, d
drop if NDVI1_SOM0>15
drop if NDVI1_SOM0<-50
kdensity NDVI1_SOM0,  gen(x_NDVI y_NDVI)
keep x_NDVI y_NDVI
drop if mi(x_NDVI, y_NDVI)
append using "${gsdData}/1-CleanTemp/Wave1_NDVI1.dta"
kdensity NDVI1_org, at(x_NDVI) gen(y_NDVI_hh)
keep x_NDVI y_NDVI y_NDVI_hh
drop if mi(x_NDVI, y_NDVI_hh, y_NDVI)
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheet("Raw_Drought_Indicators") sheetreplace cell(A1) firstrow(variables)
* Wave 2 HHs 
use "${gsdData}/1-CleanTemp/NDVI1_SOM0.dta", clear
drop if NDVI1_SOM0>15
drop if NDVI1_SOM0<-50
kdensity NDVI1_SOM0,  gen(x_NDVI y_NDVI)
keep x_NDVI y_NDVI
drop if mi(x_NDVI, y_NDVI)
append using "${gsdData}/1-CleanTemp/Wave2_NDVI1.dta"
kdensity NDVI1_org, at(x_NDVI) nograph gen(y_NDVI_hh_w2)
keep y_NDVI_hh_w2
drop if mi(y_NDVI_hh_w2)
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheet("Raw_Drought_Indicators") sheetmodify cell(D1) firstrow(variables)


*===============================================================================
* Poverty and Consumption main estimates 
*===============================================================================
* 1. Poverty and Consumption*
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
drop mi_cons_f0 mi_cons_nf0
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen assert(match master) keep(match) keepusing(*_org ${drought}_cat drought_${drought} ${drought})
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core  mi_cons_f0 mi_cons_nf0 mi_cons_d)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match master) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/FSC_HumReach.dta", assert(match using) keep(match) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/NDVI_average_series.dta", assert(match using) keep(match) nogen keepusing(NDVI*)

gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)

* keep only relevant populations
drop if inlist(type,3,4)
$migr_disp
$pld1
$migr
$pljl2 

* Prepare dependent and independent variables
gen ltc_core = log(1+tc_core)
la var ltc_core "Log imputed core consumption"
gen droughtxpost = drought_${drought}*t
la var droughtxpost "DD Estimator"
gen rural=type==2
gen urban=type==1
gen total=1
gen fatxdrought = drought_${drought}*fatalities
* Define controls globals
global controls_region i.ind_profile i.type NDVI_av_rs 
global controls_hh hhh_lit hhh_age remit12m hhsize pgender 
global controls_dwelling i.tenure1 i.floor_comparable i.house_type_comparable i.roof_material sanitation_comparable
global controls_conflict fatalities fatxdrought
global controls_assist assist_FSC1_17
gen remitdrought = remit12m*drought_${drought}

la var drought_${drought} "DroughtIntensity (SD of NDVI loss)"
la var t "Post" 
la var type "Population type"
la def ind_p 1 "Mogadishu" 2 "NE x urban" 3 "NW x urban" 4 "NE x rural" 5 "NW x rural" 7 "Central  urban" 8 "Central x rural" 9 "Jubbaland x urban" 11 "SW x urban" 12 "SW x rural", replace
la drop lind_profile
la val ind_profile ind_p
la var ind_profile "Region x Type"
la var NDVI_av_rs "Average NDVI"
la var hhh_lit "HH head literacy"
la var hhh_age "HH head age"
la var remit12m "Received remittances"
la var hhsize "Household size"
la var pgender "Gender composition"
la var tenure1 "Dwelling tenure"
la var floor_comparable "Dwelling floor"
la def lfloor_comparable 1 "Cement" 2 "Tiles or mud" 3 "Other", replace
la val floor_comparable lfloor_comparable
la var house_type_comparable "Dwelling type"
la def lhouse_type_comparable 1 "Shared" 2 "Separate" 3 "Other", modify
la var roof_material "Dwelling roof"
label define roof_material 1 "Metal Sheets" 2 "Tiles" 3 "Harar" 4 "Raar" 5 "Wood" 6 "Plastic" 7 "Concrete" 1000 "Other", replace
la val roof_material roof_material
la var sanitation_comparable "Improved sanitation"
la var fatalities "Conflict fatalities in district"
la var fatxdrought "Conflict x drought"
la var assist_FSC1_17 "Asisstance (% of beneficiaries reached)"

cap erase "${gsdOutput}/DroughtImpact_full.xls"
cap erase "${gsdOutput}/DroughtImpact_full.txt"
cap erase "${gsdOutput}/DroughtImpact_nocontrol.xls"
cap erase "${gsdOutput}/DroughtImpact_nocontrol.txt"

foreach t in total urban rural {
	preserve
	keep if `t'==1
	*global controls_region i.ind_profile
	* 1.1 Log core consumption, full dataset
	svy: reg ltc_core t drought_${drought} droughtxpost
	outreg2 using "${gsdOutput}/DroughtImpact_nocontrol.xls", append ctitle("Full Sample, Consumption, `t'") label excel nocons dec(3) pdec(3)
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", replace ctitle("ltc_core, `t', No controls")  label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", append ctitle("ltc_core, `t', Region controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh 
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", append ctitle("ltc_core, `t', Region + hh controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling 
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling + conflict controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling + conflict + assist controls") label excel keep(droughtxpost) nocons 
	outreg2 using "${gsdOutput}/DroughtImpact_full.xls", append ctitle("Full Sample, Consumption, `t'") label excel nocons dec(3) pdec(3)
	* 1.2 PoorPPP_prob, full dataset 
	svy: probit poorPPP t drought_${drought} droughtxpost
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", replace ctitle("Poverty, `t', full sample") label excel keep(droughtxpost) nocons 
	outreg2 using "${gsdOutput}/DroughtImpact_nocontrol.xls", append ctitle("Full Sample, Poverty, `t'") label excel nocons
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", append ctitle("poorPPP_prob, `t', Region controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", append ctitle("poorPPP_prob, `t', Region + hh controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", append ctitle("poorPPP_prob, `t', Region + hh + dwelling controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", append ctitle("poorPPP_prob, `t', Region + hh + dwelling + conflict controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", append ctitle("poorPPP_prob, `t', Region + hh + dwelling + conflict + assist controls") label excel keep(droughtxpost) nocons 
	outreg2 using "${gsdOutput}/DroughtImpact_full.xls", append ctitle("Full Sample, Poverty, `t'") label excel nocons dec(3) pdec(3)
	restore
}
keep if inlist(ind_profile,1,3,5)

foreach t in total urban rural {
	preserve
	keep if `t'==1
	* 2.1 log core consumption, overlapping sample w1 w2
	svy: reg ltc_core t drought_${drought} droughtxpost
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", replace ctitle("ltc_core, `t', No controls") label excel keep(droughtxpost) nocons
	outreg2 using "${gsdOutput}/DroughtImpact_nocontrol.xls", append ctitle("Overlapping Sample, Consumption, `t'") label excel nocons dec(3) pdec(3)
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", append ctitle("ltc_core, `t', Region controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh 
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", append ctitle("ltc_core, `t', Region + hh controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling 
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling + conflict controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling  $controls_conflict $controls_assist
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling + conflict + assist controls") label excel keep(droughtxpost) nocons 
	outreg2 using "${gsdOutput}/DroughtImpact_full.xls", append ctitle("Overlapping Sample, Consumption, `t'") label excel nocons dec(3) pdec(3)
	* 2.2 PoorPPP_prob, overlapping sample w1 w2 
	svy: probit poorPPP t drought_${drought} droughtxpost
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", replace ctitle("poorPPP, `t', No controls") label excel keep(droughtxpost) nocons 
	outreg2 using "${gsdOutput}/DroughtImpact_nocontrol.xls", append ctitle("Overlapping Sample, Poverty, `t'") label excel nocons dec(3) pdec(3)
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", append ctitle("poorPPP, `t', Region controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", append ctitle("poorPPP, `t', Region + hh controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", append ctitle("poorPPP, `t', Region + hh + dwelling controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling  $controls_conflict
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", append ctitle("poorPPP, `t', Region + hh + dwelling + conflict controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling  $controls_conflict $controls_assist
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", append ctitle("poorPPP_prob, `t', Region + hh + dwelling + conflict + assist controls") label excel keep(droughtxpost) nocons 
	outreg2 using "${gsdOutput}/DroughtImpact_full.xls", append ctitle("Overlapping Sample, Poverty, `t'") label excel nocons dec(3) pdec(3)
	restore
}
* Put it together
insheet using "${gsdOutput}/DroughtImpact_raw4_11_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Full,tc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_Pov_Cons")
insheet using "${gsdOutput}/DroughtImpact_raw4_12_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Full, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(A10)
insheet using "${gsdOutput}/DroughtImpact_raw4_11_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Full,ltc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(A20)
insheet using "${gsdOutput}/DroughtImpact_raw4_12_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Full, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(A30)
insheet using "${gsdOutput}/DroughtImpact_raw4_11_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Full, ltc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(A40)
insheet using "${gsdOutput}/DroughtImpact_raw4_12_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Full, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(A50)

insheet using "${gsdOutput}/DroughtImpact_raw4_21_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Overlapping, ltc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(I1)
insheet using "${gsdOutput}/DroughtImpact_raw4_22_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Overlapping, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(I10)
insheet using "${gsdOutput}/DroughtImpact_raw4_21_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Overlapping, ltc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(I20)
insheet using "${gsdOutput}/DroughtImpact_raw4_22_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Overlapping, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(I30)
insheet using "${gsdOutput}/DroughtImpact_raw4_21_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Overlapping, ltc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(I40)
insheet using "${gsdOutput}/DroughtImpact_raw4_22_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Overlapping, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Pov_Cons") cell(I50)

* ==============================================================================
* Check distribution of drought impact on consumption w/ quantile regressions
* ==============================================================================
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen assert(match master) keep(match) keepusing(${drought}_cat drought_${drought} NDVI1_org)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match master) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/FSC_HumReach.dta", assert(match using) keep(match) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/NDVI_average_series.dta", assert(match using) keep(match) nogen keepusing(NDVI*)

gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
* keep only relevant populations
drop if inlist(type,3,4)
$migr_disp
$pld1
$migr
$pljl2 

* Prepare dependent and independent variables
gen ltc_core = log(1+tc_core)
la var ltc_core "Log imputed core consumption"
gen droughtxpost = drought_${drought}*t
la var droughtxpost "DD Estimator"
gen rural=type==2
gen urban=type==1
gen total=1
gen fatxdrought = drought_${drought}*fatalities
* Define controls globals
global controls_region i.ind_profile i.type NDVI_av_rs 
global controls_hh hhh_lit hhh_age remit12m hhsize pgender
global controls_dwelling i.tenure1 i.floor_comparable i.house_type_comparable i.roof_material sanitation_comparable
global controls_conflict fatalities fatxdrought
global controls_assist assist_FSC1_17

la var drought_${drought} "DroughtIntensity (SD of NDVI loss)"
la var t "Post" 
la var type "Population type"
la def ind_p 1 "Mogadishu" 2 "NE x urban" 3 "NW x urban" 4 "NE x rural" 5 "NW x rural" 7 "Central  urban" 8 "Central x rural" 9 "Jubbaland x urban" 11 "SW x urban" 12 "SW x rural", replace
la drop lind_profile
la val ind_profile ind_p
la var ind_profile "Region x Population"
la var NDVI_av_rs "Average NDVI"
la var hhh_lit "HH head literacy"
la var hhh_age "HH head age"
la var remit12m "Received remittances"
la var hhsize "Household size"
la var pgender "Gender composition"
la var tenure1 "Dwelling tenure"
la var floor_comparable "Dwelling floor"
la def lfloor_comparable 1 "Cement" 2 "Tiles or mud" 3 "Other", replace
la val floor_comparable lfloor_comparable
la var house_type_comparable "Dwelling type"
la def lhouse_type_comparable 1 "Shared" 2 "Separate" 3 "Other", modify
la var roof_material "Dwelling roof"
label define roof_material 1 "Metal Sheets" 2 "Tiles" 3 "Harar" 4 "Raar" 5 "Wood" 6 "Plastic" 7 "Concrete" 1000 "Other", replace
la val roof_material roof_material
la var sanitation_comparable "Improved sanitation"
la var fatalities "Conflict fatalities in district"
la var fatxdrought "Conflict x drought"
la var assist_FSC1_17 "Asisstance (% of beneficiaries reached)"

foreach t in urban rural {
	cap erase "${gsdOutput}/DroughtImpact_raw4_quantile_1_`t'.xls"
	cap erase "${gsdOutput}/DroughtImpact_raw4_quantile_1_`t'.txt"
	preserve
	keep if `t'==1
	foreach v of numlist 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 {
		* full sample 
		*global controls_region i.ind_profile
		qreg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist [pw=pweight], q(`v') vce(robust)	
		outreg2 using "${gsdOutput}/DroughtImpact_raw4_quantile_1_`t'.xls", append ctitle("p=`v', full `t', ltc_core, qreg, controls") label excel keep(droughtxpost) noparen nocons noaster
	}
	restore
}

* overlapping sample
recode ind_profile (1=1) (3 5 = 2) (2 4 6 7 8 9 11 12 = 0), gen(ind_overlapping)
keep if inlist(ind_profile,1,3,5)
foreach t in urban rural {
	cap erase "${gsdOutput}/DroughtImpact_raw4_quantile_2_`t'.xls"
	cap erase "${gsdOutput}/DroughtImpact_raw4_quantile_2_`t'.txt"
	*global controls_region i.ind_overlapping
	preserve
	keep if `t'==1
	foreach v of numlist 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 {
		qreg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_assist [pw=pweight], q(`v') vce(robust)
		outreg2 using "${gsdOutput}/DroughtImpact_raw4_quantile_2_`t'.xls", append ctitle("p=`v', overlapping `t', ltc_core, qreg, controls") label excel keep(droughtxpost) nocons noparen noaster
			}
	restore
}
* Outputting
insheet using "${gsdOutput}/DroughtImpact_raw4_quantile_1_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U, full" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_Distribution")
insheet using "${gsdOutput}/DroughtImpact_raw4_quantile_2_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U, overlapping" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Distribution") cell(A11)
insheet using "${gsdOutput}/DroughtImpact_raw4_quantile_1_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R, full" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Distribution") cell(A21)
insheet using "${gsdOutput}/DroughtImpact_raw4_quantile_2_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R, overlapping" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Distribution") cell(A32)

*===============================================================================
* Hunger 
*===============================================================================
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen assert(match master) keep(match) keepusing(${drought}_cat drought_${drought} ${drought}_org)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match master) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/FSC_HumReach.dta", assert(match using) keep(match) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/NDVI_average_series.dta", assert(match using) keep(match) nogen keepusing(NDVI*)
gen pweight=weight_adj
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
recode hunger (1=0) (2 3 4 = 1), gen(hunger_bin)
la var hunger_bin "Hunger in December 2017"

* keep only relevant populations
drop if inlist(type,3,4)
$migr_disp
$pld1
$migr
$pljl2 

xtile q_tc = tc_core if t==0 & type==1, nq(5)
xtile q_tc1 = tc_core if t==0 & type==2, nq(5)
xtile q_tc2 = tc_core if t==1 & type==1, nq(5)
xtile q_tc3 = tc_core if t==1 & type==2, nq(5)
replace q_tc=q_tc1 if mi(q_tc)
replace q_tc=q_tc2 if mi(q_tc)
replace q_tc=q_tc3 if mi(q_tc)

* Prepare dependent and independent variables
gen ltc_core = log(1+tc_core)
la var ltc_core "Log imputed core consumption"
gen droughtxpost = drought_${drought}*t
la var droughtxpost "DD Estimator"
gen rural=type==2
gen urban=type==1
gen total=1
gen fatxdrought = drought_${drought}*fatalities
gen assistxpost = assist_FSC1_17*t
recode remit12m_usd (missing=0)
*recode reg_pess (1 18 = 1) (2 5 = 2) (3=3) (4 11 12 = 4) (6=6) (7 10 = 7) (8=8) (13 16 = 13) (14=14) (15=15) (17=17), gen(reg1)
*gen reg1type = reg1*type
* Define controls globals
global controls_region i.ind_profile i.type NDVI_av_rs 
global controls_hh hhh_lit hhh_age remit12m hhsize pgender q_tc
global controls_dwelling i.tenure1 i.floor_comparable i.house_type_comparable i.roof_material sanitation_comparable
global controls_conflict fatalities fatxdrought
global controls_assist assist_FSC1_17

la var drought_${drought} "DroughtIntensity (SD of NDVI loss)"
la var t "Post" 
la var type "Population type"
la def ind_p 1 "Mogadishu" 2 "NE x urban" 3 "NW x urban" 4 "NE x rural" 5 "NW x rural" 7 "Central  urban" 8 "Central x rural" 9 "Jubbaland x urban" 11 "SW x urban" 12 "SW x rural", replace
la drop lind_profile
la val ind_profile ind_p
la var ind_profile "Region x Population"
la var NDVI_av_rs "Average NDVI"
la var hhh_lit "HH head literacy"
la var hhh_age "HH head age"
la var remit12m "Received remittances"
la var hhsize "Household size"
la var pgender "Gender composition"
la var tenure1 "Dwelling tenure"
la var floor_comparable "Dwelling floor"
la def lfloor_comparable 1 "Cement" 2 "Tiles or mud" 3 "Other", replace
la val floor_comparable lfloor_comparable
la var house_type_comparable "Dwelling type"
la def lhouse_type_comparable 1 "Shared" 2 "Separate" 3 "Other", modify
la var roof_material "Dwelling roof"
label define roof_material 1 "Metal Sheets" 2 "Tiles" 3 "Harar" 4 "Raar" 5 "Wood" 6 "Plastic" 7 "Concrete" 1000 "Other", replace
la val roof_material roof_material
la var sanitation_comparable "Improved sanitation"
la var fatalities "Conflict fatalities in district"
la var fatxdrought "Conflict x drought"
la var assist_FSC1_17 "Asisstance (% of beneficiaries reached)"

cap erase "${gsdOutput}/DroughtImpact_hunger_full.xls"
cap erase "${gsdOutput}/DroughtImpact_hunger_full.txt"

* Regressions
foreach t in total urban rural {
	preserve
	keep if `t'==1
	* hunger in full dataset 
	svy: probit hunger_bin t drought_${drought} droughtxpost
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_nocontrol.xls", append ctitle("Full Sample, Hunger, `t'") label excel nocons dec(3) pdec(3)
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_1_`t'.xls", replace ctitle("`t', No controls") label excel keep(droughtxpost) nocons dec(3) pdec(3)
	svy: probit hunger_bin t drought_${drought} droughtxpost $controls_hh 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_1_`t'.xls", append ctitle("`t', individual+hh controls controls") label excel keep(droughtxpost) nocons dec(3) pdec(3)
	svy: probit hunger_bin t drought_${drought} droughtxpost  $controls_hh $controls_dwelling 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_1_`t'.xls", append ctitle("`t', individual+hh+dwelling controls") label excel keep(droughtxpost) nocons dec(3) pdec(3)
	svy: probit hunger_bin t drought_${drought} droughtxpost  $controls_hh $controls_dwelling $controls_conflict
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_1_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict controls") label excel keep(droughtxpost) nocons dec(3) pdec(3)
	svy: probit hunger_bin t drought_${drought} droughtxpost $controls_hh $controls_dwelling $controls_conflict $controls_assist
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_1_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict+assist controls") label excel keep(droughtxpost) nocons  dec(3) pdec(3)
	svy: probit hunger_bin t drought_${drought} droughtxpost $controls_hh $controls_dwelling $controls_conflict $controls_assist $controls_region
	margins, dydx(droughtxpost) at(q_tc=(1(1)10))
	*marginsplot 
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_1_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict+assist+region controls") label excel keep(droughtxpost) nocons  dec(3) pdec(3)
	outreg2 using "${gsdOutput}/DroughtImpact_full.xls", append ctitle("Full Sample, Hunger, `t'") label excel nocons dec(3) pdec(3)
	restore
}
	foreach t in total urban rural {
	preserve
	keep if `t'==1	
	* hunger in overlapping sample w1 w2
	keep if inlist(ind_profile,1,3,5)
	svy: probit hunger_bin t drought_${drought} droughtxpost
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_2_`t'.xls", replace ctitle("`t', No controls") label excel keep(droughtxpost) nocons dec(3) pdec(3)
	outreg2 using "${gsdOutput}/DroughtImpact_nocontrol.xls", append ctitle("Overlapping Sample, Hunger, `t'") label excel nocons dec(3) pdec(3)
	svy: probit hunger_bin t drought_${drought} droughtxpost $controls_hh 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_2_`t'.xls", append ctitle("`t', individual+hh controls controls") label excel keep(droughtxpost) nocons dec(3) pdec(3)
	svy: probit hunger_bin t drought_${drought} droughtxpost $controls_hh $controls_dwelling 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_2_`t'.xls", append ctitle("`t', individual+hh+dwelling controls") label excel keep(droughtxpost) nocons dec(3) pdec(3)
	svy: probit hunger_bin t drought_${drought} droughtxpost $controls_hh $controls_dwelling 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_2_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict controls") label excel keep(droughtxpost) nocons dec(3) pdec(3)
	svy: probit hunger_bin t drought_${drought} droughtxpost $controls_hh $controls_dwelling $controls_assist
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_2_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict+assist controls") label excel keep(droughtxpost) nocons dec(3) pdec(3)
	svy: probit hunger_bin t drought_${drought} droughtxpost $controls_hh $controls_dwelling $controls_assist $controls_region
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw5_2_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict+assist+region controls") label excel keep(droughtxpost) nocons 
	outreg2 using "${gsdOutput}/DroughtImpact_full.xls", append ctitle("Overlapping Sample, Hunger, `t'") label excel nocons dec(3) pdec(3)
	restore
}

* Put it together
insheet using "${gsdOutput}/DroughtImpact_raw5_1_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "HUNGER" in 1
replace v2 = "U+R,Full" in 2
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_Hunger")
insheet using "${gsdOutput}/DroughtImpact_raw5_1_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Full" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Hunger") cell(A10)
insheet using "${gsdOutput}/DroughtImpact_raw5_1_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Full" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Hunger") cell(A20)

insheet using "${gsdOutput}/DroughtImpact_raw5_2_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Overlapping" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Hunger") cell(I1)
insheet using "${gsdOutput}/DroughtImpact_raw5_2_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Overlapping" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Hunger") cell(I10)
insheet using "${gsdOutput}/DroughtImpact_raw5_2_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Overlapping" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Hunger") cell(I20)


*===============================================================================
* Components of consumptions 
*===============================================================================
* Look into the different components of consumptions
foreach x in cons_food {
	use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
	drop mi_cons_f0 mi_cons_nf0
	merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen assert(match master) keep(match) keepusing(${drought}_cat drought_${drought} ${drought})
	merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core  mi_cons_f0 mi_cons_nf0 mi_cons_d)
	merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match master) nogen
	merge m:1 reg_pess using "${gsdData}/1-CleanTemp/FSC_HumReach.dta", assert(match using) keep(match) nogen
	merge m:1 reg_pess using "${gsdData}/1-CleanTemp/NDVI_average_series.dta", assert(match using) keep(match) nogen keepusing(NDVI*)

	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)
	ren (mi_cons_f0 mi_cons_nf0 mi_cons_d) (cons_food cons_nonfood cons_durables)
	la var cons_food "Food consumption"
	la var cons_nonfood "Nonfood consumption"
	la var cons_durables "Durables"
	gen sal_lab = lhood==1 if !mi(lhood) 
	replace sal_lab=1 if main_income_source==1 & !mi(main_income_source) 
	replace sal_lab=0 if main_income_source!=1 & !mi(main_income_source)

	* keep only relevant populations
	drop if inlist(type,3,4)
	$migr_disp
	$pld1
	$migr
	$pljl2 

	* Prepare dependent and independent variables
	gen ltc_core = log(1+`x')
	la var ltc_core "log `x'"

	gen droughtxpost = drought_${drought}*t
	la var droughtxpost "DD Estimator"
	gen rural=type==2
	gen urban=type==1
	gen total=1
	gen fatxdrought = drought_${drought}*fatalities
	* Define controls globals
	global controls_region i.ind_profile i.type NDVI_av_rs 
	global controls_hh hhh_lit hhh_age remit12m hhsize pgender
	global controls_dwelling i.tenure1 i.floor_comparable i.house_type_comparable i.roof_material sanitation_comparable
	global controls_conflict fatalities fatxdrought
	global controls_assist assist_FSC1_17 
	
	la var drought_${drought} "DroughtIntensity (SD of NDVI loss)"
	la var t "Post" 
	la var type "Population type"
	la def ind_p 1 "Mogadishu" 2 "NE x urban" 3 "NW x urban" 4 "NE x rural" 5 "NW x rural" 7 "Central  urban" 8 "Central x rural" 9 "Jubbaland x urban" 11 "SW x urban" 12 "SW x rural", replace
	la drop lind_profile
	la val ind_profile ind_p
	la var ind_profile "Region x Population"
	la var NDVI_av_rs "Average NDVI"
	la var hhh_lit "HH head literacy"
	la var hhh_age "HH head age"
	la var remit12m "Received remittances"
	la var hhsize "Household size"
	la var pgender "Gender composition"
	la var tenure1 "Dwelling tenure"
	la var floor_comparable "Dwelling floor"
	la def lfloor_comparable 1 "Cement" 2 "Tiles or mud" 3 "Other", replace
	la val floor_comparable lfloor_comparable
	la var house_type_comparable "Dwelling type"
	la def lhouse_type_comparable 1 "Shared" 2 "Separate" 3 "Other", modify
	la var roof_material "Dwelling roof"
	label define roof_material 1 "Metal Sheets" 2 "Tiles" 3 "Harar" 4 "Raar" 5 "Wood" 6 "Plastic" 7 "Concrete" 1000 "Other", replace
	la val roof_material roof_material
	la var sanitation_comparable "Improved sanitation"
	la var fatalities "Conflict fatalities in district"
	la var fatxdrought "Conflict x drought"
	la var assist_FSC1_17 "Asisstance (% of beneficiaries reached)"

	foreach t in total urban rural {
		preserve
		keep if `t'==1
		* 1.1 Log core consumption, full dataset
		svy: reg ltc_core t drought_${drought} droughtxpost
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_11_`t'.xls", replace ctitle("`x', `t', No controls") dec(3) label excel keep(droughtxpost) nocons
		outreg2 using "${gsdOutput}/DroughtImpact_nocontrol.xls", append ctitle("Full Sample, `x', `t'") label excel nocons dec(3) pdec(3)
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_11_`t'.xls", append ctitle("`x', `t', Region controls") label excel keep(droughtxpost) nocons 
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh 
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_11_`t'.xls", append ctitle("`x', `t', Region + hh controls") label excel keep(droughtxpost) nocons 
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling 
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_11_`t'.xls", append ctitle("`x', `t', Region + hh + dwelling controls") label excel keep(droughtxpost) nocons 
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_11_`t'.xls", append ctitle("`x', `t', Region + hh + dwelling + conflict controls") label excel keep(droughtxpost) nocons 
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_11_`t'.xls", append ctitle("`x', `t', Region + hh + dwelling + conflict + assist controls") label excel keep(droughtxpost) nocons
		outreg2 using "${gsdOutput}/DroughtImpact_full.xls", append ctitle("Full Sample, `x', `t'") label excel nocons dec(3) pdec(3)
		restore
	}
		foreach t in urban rural {
		cap erase "${gsdOutput}/DroughtImpact_raw9_quantile_1_`t'.xls"
		cap erase "${gsdOutput}/DroughtImpact_raw9_quantile_1_`t'.txt"
		preserve
		keep if `t'==1
		foreach v of numlist 0.05(0.05)0.95 {
			* full sample 
			*global controls_region i.ind_profile
			qreg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist [pw=pweight], q(`v') vce(robust, kernel)	
			outreg2 using "${gsdOutput}/DroughtImpact_raw9_quantile_1_`t'.xls", append ctitle("p=`v', full `t', `x', qreg, controls") label excel keep(droughtxpost) noparen nocons noaster
		}
		restore
	}
	
	keep if inlist(ind_profile,1,3,5)
	foreach t in total urban rural {
		preserve
		keep if `t'==1
		* 2.1 log core consumption, overlapping sample w1 w2
		svy: reg ltc_core t drought_${drought} droughtxpost
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_21_`t'.xls", replace ctitle("`x', `t', No controls") label excel keep(droughtxpost) nocons
		outreg2 using "${gsdOutput}/DroughtImpact_nocontrol.xls", append ctitle("Overlapping Sample, `x', `t'") label excel nocons dec(3) pdec(3)
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_21_`t'.xls", append ctitle("`x', `t', Region controls") label excel keep(droughtxpost) nocons 
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh 
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_21_`t'.xls", append ctitle("`x', `t', Region + hh controls") label excel keep(droughtxpost) nocons 
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling 
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_21_`t'.xls", append ctitle("`x', `t', Region + hh + dwelling controls") label excel keep(droughtxpost) nocons 
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_21_`t'.xls", append ctitle("`x', `t', Region + hh + dwelling + conflict controls") label excel keep(droughtxpost) nocons 
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_21_`t'.xls", append ctitle("`x', `t', Region + hh + dwelling + conflict + assist controls") label excel keep(droughtxpost) nocons 
		outreg2 using "${gsdOutput}/DroughtImpact_full.xls", append ctitle("Overlapping Sample, `x', `t'") label excel nocons dec(3) pdec(3)
		restore
	}
	* Put it together
	insheet using "${gsdOutput}/DroughtImpact_raw9_11_total.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "U+R,Full,`x'" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_`x'")
	insheet using "${gsdOutput}/DroughtImpact_raw9_11_urban.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "U,Full,`x'" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_`x'") cell(A10)
	insheet using "${gsdOutput}/DroughtImpact_raw9_11_rural.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "R,Full, `x'" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_`x'") cell(A20)
	insheet using "${gsdOutput}/DroughtImpact_raw9_21_total.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "U+R,Overlapping,`x'" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_`x'") cell(I1)
	insheet using "${gsdOutput}/DroughtImpact_raw9_21_urban.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "U,Overlapping,`x'" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_`x'") cell(I10)
	insheet using "${gsdOutput}/DroughtImpact_raw9_21_rural.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "R,Overlapping, `x'" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_`x'") cell(I20)
	insheet using "${gsdOutput}/DroughtImpact_raw9_quantile_1_urban.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "U, full" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_`x'_Dist")
	insheet using "${gsdOutput}/DroughtImpact_raw9_quantile_1_rural.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "R, full" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_`x'_Dist") cell(A10)
	

}

* Outputting full tables
insheet using "${gsdOutput}/DroughtImpact_nocontrol.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_table")
insheet using "${gsdOutput}/DroughtImpact_full.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_table_full")

*===============================================================================
* Poverty and Consumption robustness estimates 
*===============================================================================
cap erase "${gsdOutput}/DroughtImpact_robust.xls"
cap erase "${gsdOutput}/DroughtImpact_robust.txt"
foreach k of numlist 2 7 9 11 { 
	*Poverty and Consumption*
	use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
	drop mi_cons_f0 mi_cons_nf0
	merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen assert(match master) keep(match) keepusing(*_org ${drought}_cat drought_${drought} ${drought})
	merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core  mi_cons_f0 mi_cons_nf0 mi_cons_d)
	merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match master) nogen
	merge m:1 reg_pess using "${gsdData}/1-CleanTemp/FSC_HumReach.dta", assert(match using) keep(match) nogen
	merge m:1 reg_pess using "${gsdData}/1-CleanTemp/NDVI_average_series.dta", assert(match using) keep(match) nogen keepusing(NDVI*)

	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)

	* keep only relevant populations
	drop if inlist(type,3,4)
	$migr_disp
	$pld1
	$migr
	$pljl2 
	drop if ind_profile==`k'
	keep if type==1
	* Prepare dependent and independent variables
	gen ltc_core = log(1+tc_core)
	la var ltc_core "Log imputed core consumption"
	gen droughtxpost = drought_${drought}*t
	la var droughtxpost "DD Estimator"
	gen rural=type==2
	gen urban=type==1
	gen total=1
	gen fatxdrought = drought_${drought}*fatalities
	* Define controls globals
	global controls_region i.ind_profile i.type NDVI_av_rs 
	global controls_hh hhh_lit hhh_age remit12m hhsize pgender 
	global controls_dwelling i.tenure1 i.floor_comparable i.house_type_comparable i.roof_material sanitation_comparable
	global controls_conflict fatalities fatxdrought
	global controls_assist assist_FSC1_17
	gen remitdrought = remit12m*drought_${drought}

	la var drought_${drought} "DroughtIntensity (SD of NDVI loss)"
	la var t "Post" 
	la var type "Population type"
	la def ind_p 1 "Mogadishu" 2 "NE x urban" 3 "NW x urban" 4 "NE x rural" 5 "NW x rural" 7 "Central  urban" 8 "Central x rural" 9 "Jubbaland x urban" 11 "SW x urban" 12 "SW x rural", replace
	la drop lind_profile
	la val ind_profile ind_p
	la var ind_profile "Region x Type"
	la var NDVI_av_rs "Average NDVI"
	la var hhh_lit "HH head literacy"
	la var hhh_age "HH head age"
	la var remit12m "Received remittances"
	la var hhsize "Household size"
	la var pgender "Gender composition"
	la var tenure1 "Dwelling tenure"
	la var floor_comparable "Dwelling floor"
	la def lfloor_comparable 1 "Cement" 2 "Tiles or mud" 3 "Other", replace
	la val floor_comparable lfloor_comparable
	la var house_type_comparable "Dwelling type"
	la def lhouse_type_comparable 1 "Shared" 2 "Separate" 3 "Other", modify
	la var roof_material "Dwelling roof"
	label define roof_material 1 "Metal Sheets" 2 "Tiles" 3 "Harar" 4 "Raar" 5 "Wood" 6 "Plastic" 7 "Concrete" 1000 "Other", replace
	la val roof_material roof_material
	la var sanitation_comparable "Improved sanitation"
	la var fatalities "Conflict fatalities in district"
	la var fatxdrought "Conflict x drought"
	la var assist_FSC1_17 "Asisstance (% of beneficiaries reached)"

	* 1.1 Log core consumption, full dataset
	svy: reg ltc_core t drought_${drought} droughtxpost
	outreg2 using "${gsdOutput}/DroughtImpact_robust.xls", append ctitle("Urban, Consumption, w/o `k', no controls") label excel nocons dec(3) pdec(3) keep(droughtxpost)
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
	outreg2 using "${gsdOutput}/DroughtImpact_robust.xls", append ctitle("Urban, Consumption, w/o `k', yes controls") label excel nocons dec(3) pdec(3) keep(droughtxpost)
	* 1.2 PoorPPP_prob, full dataset 
	svy: probit poorPPP t drought_${drought} droughtxpost
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_robust.xls", append ctitle("Urban, Poverty, w/o `k', no controls") label excel nocons dec(3) pdec(3) keep(droughtxpost)
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_robust.xls", append ctitle("Urban, Poverty, w/o `k', yes controls") label excel nocons dec(3) pdec(3) keep(droughtxpost)
	
}

foreach k of numlist 4 8 12 { 

	*Poverty and Consumption*
	use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
	drop mi_cons_f0 mi_cons_nf0
	merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen assert(match master) keep(match) keepusing(*_org ${drought}_cat drought_${drought} ${drought})
	merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core  mi_cons_f0 mi_cons_nf0 mi_cons_d)
	merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match master) nogen
	merge m:1 reg_pess using "${gsdData}/1-CleanTemp/FSC_HumReach.dta", assert(match using) keep(match) nogen
	merge m:1 reg_pess using "${gsdData}/1-CleanTemp/NDVI_average_series.dta", assert(match using) keep(match) nogen keepusing(NDVI*)

	gen pweight=weight_cons*hhsize
	svyset ea [pweight=pweight], strata(strata) singleunit(centered)

	* keep only relevant populations
	drop if inlist(type,3,4)
	$migr_disp
	$pld1
	$migr
	$pljl2 
	drop if ind_profile==`k'
	keep if type==2
	* Prepare dependent and independent variables
	gen ltc_core = log(1+tc_core)
	la var ltc_core "Log imputed core consumption"
	gen droughtxpost = drought_${drought}*t
	la var droughtxpost "DD Estimator"
	gen rural=type==2
	gen urban=type==1
	gen total=1
	gen fatxdrought = drought_${drought}*fatalities
	* Define controls globals
	global controls_region i.ind_profile i.type NDVI_av_rs 
	global controls_hh hhh_lit hhh_age remit12m hhsize pgender 
	global controls_dwelling i.tenure1 i.floor_comparable i.house_type_comparable i.roof_material sanitation_comparable
	global controls_conflict fatalities fatxdrought
	global controls_assist assist_FSC1_17
	gen remitdrought = remit12m*drought_${drought}

	la var drought_${drought} "DroughtIntensity (SD of NDVI loss)"
	la var t "Post" 
	la var type "Population type"
	la def ind_p 1 "Mogadishu" 2 "NE x urban" 3 "NW x urban" 4 "NE x rural" 5 "NW x rural" 7 "Central  urban" 8 "Central x rural" 9 "Jubbaland x urban" 11 "SW x urban" 12 "SW x rural", replace
	la drop lind_profile
	la val ind_profile ind_p
	la var ind_profile "Region x Type"
	la var NDVI_av_rs "Average NDVI"
	la var hhh_lit "HH head literacy"
	la var hhh_age "HH head age"
	la var remit12m "Received remittances"
	la var hhsize "Household size"
	la var pgender "Gender composition"
	la var tenure1 "Dwelling tenure"
	la var floor_comparable "Dwelling floor"
	la def lfloor_comparable 1 "Cement" 2 "Tiles or mud" 3 "Other", replace
	la val floor_comparable lfloor_comparable
	la var house_type_comparable "Dwelling type"
	la def lhouse_type_comparable 1 "Shared" 2 "Separate" 3 "Other", modify
	la var roof_material "Dwelling roof"
	label define roof_material 1 "Metal Sheets" 2 "Tiles" 3 "Harar" 4 "Raar" 5 "Wood" 6 "Plastic" 7 "Concrete" 1000 "Other", replace
	la val roof_material roof_material
	la var sanitation_comparable "Improved sanitation"
	la var fatalities "Conflict fatalities in district"
	la var fatxdrought "Conflict x drought"
	la var assist_FSC1_17 "Asisstance (% of beneficiaries reached)"


	* 1.1 Log core consumption, full dataset
	svy: reg ltc_core t drought_${drought} droughtxpost
	outreg2 using "${gsdOutput}/DroughtImpact_robust.xls", append ctitle("Rural, Consumption, w/o `k', no controls") label excel nocons dec(3) pdec(3) keep(droughtxpost)
	svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
	outreg2 using "${gsdOutput}/DroughtImpact_robust.xls", append ctitle("Rural, Consumption, w/o `k', yes controls") label excel nocons dec(3) pdec(3) keep(droughtxpost)
	* 1.2 PoorPPP_prob, full dataset 
	svy: probit poorPPP t drought_${drought} droughtxpost
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_robust.xls", append ctitle("Rural, Poverty, w/o `k', no controls") label excel nocons dec(3) pdec(3) keep(droughtxpost)
	svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_robust.xls", append ctitle("Rural, Poverty, w/o `k', yes controls") label excel nocons dec(3) pdec(3) keep(droughtxpost)
	
}

* Put it together
insheet using "${gsdOutput}/DroughtImpact_robust.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_Robust")

* ==============================================================================
* Simulations & vulnerabilities 
* ==============================================================================
use "${gsdData}/1-CleanOutput/hh.dta", clear
merge 1:1 strata ea block hh using  "${gsdData}/1-CleanTemp/hhq-poverty.dta", nogen
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen keep(master match) keepusing(*_org )
drop if migr_disp==1
gen pweight=weight*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
drop if type>2
keep if type==2 
gen x=1
tabout x using "${gsdOutput}/DroughtImpact_simulation.xls", svy sum c(mean poorPPPshock_prob) f(3) npos(col) h2("Poverty after shock") replace
tabout x using "${gsdOutput}/DroughtImpact_simulation.xls", svy sum c(mean poorPPPcore_prob) f(3) npos(col) h2("Baseline poverty") append

* Income distribution graph
xtile deciles_tc = tc_core [pweight=pweight], n(10)
tabout deciles_tc using "${gsdOutput}/DroughtImpact_simulation.xls" , svy sum c(mean tc_core) f(3) npos(col) append
tabout deciles_tc using "${gsdOutput}/DroughtImpact_simulation.xls" , svy sum c(mean tc_core_shock) f(3) npos(col) append

* look at vulnerability to shocks
svyset ea [pweight=weight], strata(strata) singleunit(centered)
gen borrow_difficult = inlist(social_ease,4,5) if !mi(social_ease)
gen borrow_difficult2 = inlist(social_ease,5) if !mi(social_ease)
gen agri = lhood==8 if !mi(lhood)
gen sal = lhood==1 if !mi(lhood)
gen busi = lhood==7 if !mi(lhood)
gen remit = inlist(lhood,2,5) if !mi(lhood)
gen remote_market=tmarket>5
* look at correlations with drought
gen drought = (shocks0__1==1 | shocks0__4==1 | shocks0__5==1 | shocks0__8==1 )
svy: reg drought NDVI1_org
svy: probit drought agri  NDVI1_org i.ind_profile tc_imp hhsize hhh_lit
margins, dydx(*) post
outreg2 using "${gsdOutput}/DroughtImpact_vulnerable.xls", replace ctitle("Livelihood and drought") label excel nocons dec(3) pdec(3)
svy: probit drought  sal  NDVI1_org i.ind_profile tc_imp hhsize hhh_lit
margins, dydx(*) post
outreg2 using "${gsdOutput}/DroughtImpact_vulnerable.xls", append ctitle("Livelihood and drought 2") label excel nocons dec(3) pdec(3)
gen remote_agri = agri*remote_market
svy: probit drought borrow_difficult2 remote_agri water_home NDVI1_org i.ind_profile tc_imp hhsize hhh_lit i.lhood 
margins, dydx(*) post
outreg2 using "${gsdOutput}/DroughtImpact_vulnerable.xls", append ctitle("Services and drought") label excel nocons dec(3) pdec(3)


* Put it together
insheet using "${gsdOutput}/DroughtImpact_simulation.xls", clear nonames tab
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_Simulation")
insheet using "${gsdOutput}/DroughtImpact_vulnerable.txt", clear nonames tab
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_Vulnerable")

*********************************************************************************
/* Poverty and consumption at different cutoffs
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
drop mi_cons_f0 mi_cons_nf0
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen assert(match master) keep(match) keepusing(cutoff step ${drought}_cat drought_${drought} ${drought} ${drought}_org)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core  mi_cons_f0 mi_cons_nf0 mi_cons_d)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match master) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/FSC_HumReach.dta", assert(match using) keep(match) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/NDVI_average_series.dta", assert(match using) keep(match) nogen keepusing(NDVI*)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)

gen sal_lab = lhood==1 if !mi(lhood) 
replace sal_lab=1 if main_income_source==1 & !mi(main_income_source) 
replace sal_lab=0 if main_income_source!=1 & !mi(main_income_source)

* keep only relevant populations
drop if inlist(type,3,4)
$migr_disp
$pld1
$migr
$pljl2 

* Prepare dependent and independent variables
gen ltc_core = log(1+tc_core)
la var ltc_core "Log imputed core consumption"
gen droughtxpost = drought_${drought}*t
la var droughtxpost "DD Estimator"
gen rural=type==2
gen urban=type==1
gen total=1
gen fatxdrought = drought_${drought}*fatalities
gen assistxpost = assist_FSC1_17*t
recode remit12m_usd (missing=0)
*recode reg_pess (1 18 = 1) (2 5 = 2) (3=3) (4 11 12 = 4) (6=6) (7 10 = 7) (8=8) (13 16 = 13) (14=14) (15=15) (17=17), gen(reg1)
*gen reg1type = reg1*type
* Define controls globals
global controls_region i.ind_profile i.type NDVI_av_rs
global controls_hh hhh_lit hhh_age remit12m hhsize pgender n_dependent
global controls_dwelling i.tenure1 i.floor_comparable i.house_type_comparable i.roof_material sanitation_comparable
global controls_conflict fatalities fatxdrought
global controls_assist assist_FSC1_17

cap erase "${gsdOutput}/DroughtImpact_raw4_cutoff1_urban.xls"
cap erase "${gsdOutput}/DroughtImpact_raw4_cutoff1_urban.txt"
cap erase "${gsdOutput}/DroughtImpact_raw4_cutoff1_rural.xls"
cap erase "${gsdOutput}/DroughtImpact_raw4_cutoff1_rural.txt"
su step 
local step = `r(mean)'
di `step'
su cutoff
foreach i of numlist `r(min)'(`step')`r(max)' {
	foreach t in urban rural {
		preserve
		keep if `t'==1
		drop drought_${drought} droughtxpost
		gen drought_${drought} = ${drought}_org<`i'
		gen droughtxpost = drought_${drought}*t
		svy: reg ltc_core t drought_${drought} droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
		outreg2 using "${gsdOutput}/DroughtImpact_raw4_cutoff1_`t'.xls", append ctitle("cutoff=`i', `t', controls") label excel keep(droughtxpost) noparen nocons noaster
		restore
	}

}
su step 
local step = `r(mean)'
di `step'
su cutoff
cap erase "${gsdOutput}/DroughtImpact_raw4_cutoff2_urban.xls"
cap erase "${gsdOutput}/DroughtImpact_raw4_cutoff2_urban.txt"
cap erase "${gsdOutput}/DroughtImpact_raw4_cutoff2_rural.xls"
cap erase "${gsdOutput}/DroughtImpact_raw4_cutoff2_rural.txt"
foreach i of numlist `r(min)'(`step')`r(max)' {
	foreach t in urban rural {
		preserve
		keep if `t'==1
		drop drought_${drought} droughtxpost
		gen drought_${drought} = ${drought}_org<`i'
		gen droughtxpost = drought_${drought}*t
		svy: probit poorPPP t drought_${drought} droughtxpost $controls_region $controls_hh  $controls_conflict $controls_dwelling $controls_assist
		margins, dydx(droughtxpost) post
		outreg2 using "${gsdOutput}/DroughtImpact_raw4_cutoff2_`t'.xls", append ctitle("cutoff=`i', poorPPP, `t', controls") label excel keep(droughtxpost) noparen nocons noaster
		restore
	}

}

* Outputting
insheet using "${gsdOutput}/DroughtImpact_raw4_cutoff1_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U, Consumption" in 2
replace v2 = "CUTOFFS" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_DroughtIntensity")
insheet using "${gsdOutput}/DroughtImpact_raw4_cutoff2_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U, Poverty" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_DroughtIntensity") cell(A10)
insheet using "${gsdOutput}/DroughtImpact_raw4_cutoff1_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R, Consumption" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_DroughtIntensity") cell(A20)
insheet using "${gsdOutput}/DroughtImpact_raw4_cutoff2_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R, Poverty" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_DroughtIntensity") cell(A30)
*/

/*
* ==============================================================================
* 2. Education DiD *  
* ==============================================================================
* Enrollment levels
use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear
drop no_children
merge m:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hh_w1_w2.dta", nogen assert(match) keepusing(lfp_7d_hh no_children sanitation_comparable main_income_source lhood hhh_gender prop_alwayslive migr_disp tenure1 floor_comparable house_type_comparable roof_material hhh_lit hhh_age remit12m hhsize pgender ind_profile)
merge m:1 t strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen assert(match master) keep(match) keepusing(${drought} drought_${drought})
merge m:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core)
merge m:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match master) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/Assist_Educ.dta", assert(match using) keep(match) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/FSC_HumReach.dta", assert(match using) keep(match) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/NDVI_average_series.dta", assert(match using) keep(match) nogen keepusing(NDVI*)
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

* keep relevant populations
drop if inlist(type,3,4)
$migr_disp
$pld1
$migr
$pljl2 
keep if inrange(age,6,18)

* prepare variables
gen rural=type==2
gen urban=type==1
gen total=1
gen fatxdrought = drought_${drought}*fatalities
gen assistxpost = assist_edu17*t
gen droughtxpost = drought_${drought}*t
gen droughtxcons = tc_core*drought_${drought}
gen sal_lab = lhood==1 if !mi(lhood) 
replace sal_lab=1 if main_income_source==1 & !mi(main_income_source) 
replace sal_lab=0 if main_income_source!=1 & !mi(main_income_source)
*recode reg_pess (1 18 = 1) (2 5 = 2) (3=3) (4 11 12 = 4) (6=6) (7 10 = 7) (8=8) (13 16 = 13) (14=14) (15=15) (17=17), gen(reg1)
*gen reg1type = reg1*type
*recode ind_profile (1=1) (3 5 = 2) (2 4 6 7 8 9 11 12 = 0), gen(ind_overlapping)
recode lfp_7d (missing=0)
* Define controls globals
global controls_region i.ind_profile i.type NDVI_av_rs 
global controls_ind age gender i.hhm_relation tc_core
global controls_hh hhh_lit hhh_age remit12m hhsize hhh_gender no_dependent
global controls_dwelling i.tenure1 i.floor_comparable i.house_type_comparable i.roof_material sanitation_comparable
global controls_conflict fatalities fatxdrought
global controls_assist assist_FSC_17 
la var droughtxpost "DD Estimator"

cap erase "${gsdOutput}/DroughtImpact_edu_full.xls"
cap erase "${gsdOutput}/DroughtImpact_edu_full.txt"


* Unconditional values for comparison
*egen drought = group(t drought_${drought}), label
*tabout drought using "${gsdOutput}/DroughtImpact_raw6_additional.xls" if rural==1, svy sum c(mean enrolled) sebnone f(3) h2("Enrolled & Drought (SPI)") npos(col) replace

foreach t in total urban rural {
	preserve
	keep if `t'==1
	* 1.2 Probit enrollment, full dataset 
	svy: probit enrolled t drought_${drought} droughtxpost
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_1_`t'.xls", replace ctitle("`t', No controls") label excel keep(droughtxpost) nocons 
	svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_1_`t'.xls", append ctitle("`t', individual+hh controls controls") label excel keep(droughtxpost) nocons 
	svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh $controls_dwelling 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_1_`t'.xls", append ctitle("`t', individual+hh+dwelling controls") label excel keep(droughtxpost) nocons 
	svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh $controls_dwelling $controls_conflict
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_1_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict controls") label excel keep(droughtxpost) nocons 
	svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh $controls_dwelling $controls_conflict $controls_assist
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_1_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict+assist controls") label excel keep(droughtxpost) nocons 
	svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh $controls_dwelling $controls_conflict $controls_assist $controls_region
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_1_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict+assist+region controls") label excel keep(droughtxpost) nocons 
	outreg2 using "${gsdOutput}/DroughtImpact_edu_full.xls", append ctitle("Enrollment, `t', full sample") label excel nocons 
	
	* 2.1 enrollment overlapping sample w1 w2
	keep if inlist(ind_profile,1,3,5)
	svy: probit enrolled t drought_${drought} droughtxpost
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_2_`t'.xls", replace ctitle("`t', No controls") label excel keep(droughtxpost) nocons 
	svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_2_`t'.xls", append ctitle("`t', individual+hh controls controls") label excel keep(droughtxpost) nocons 
	svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh $controls_dwelling 
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_2_`t'.xls", append ctitle("`t', individual+hh+dwelling controls") label excel keep(droughtxpost) nocons 
	svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh $controls_dwelling
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_2_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict controls") label excel keep(droughtxpost) nocons 
	svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh $controls_dwelling $controls_assist
	margins, dydx(droughtxpost) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_2_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict+assist controls") label excel keep(droughtxpost) nocons 
	svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh $controls_dwelling $controls_assist $controls_region
	margins, dydx(*) post
	outreg2 using "${gsdOutput}/DroughtImpact_raw6_2_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict+assist+region controls") label excel keep(droughtxpost) nocons 
	outreg2 using "${gsdOutput}/DroughtImpact_edu_full.xls", append ctitle("Enrollment, `t', overlapping sample") label excel nocons 
	restore
}

* Put it together
insheet using "${gsdOutput}/DroughtImpact_raw6_1_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Full" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_Education")
insheet using "${gsdOutput}/DroughtImpact_raw6_1_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Full" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Education") cell(A10)
insheet using "${gsdOutput}/DroughtImpact_raw6_1_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Full" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Education") cell(A20)

insheet using "${gsdOutput}/DroughtImpact_raw6_2_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Overlapping" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Education") cell(I1)
insheet using "${gsdOutput}/DroughtImpact_raw6_2_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Overlapping" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Education") cell(I10)
insheet using "${gsdOutput}/DroughtImpact_raw6_2_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Overlapping" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Education") cell(I20)

* Additional
*insheet using "${gsdOutput}/DroughtImpact_raw6_additional.xls", clear
*export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_Education_additional") 

* ==============================================================================
* Enrollment by gender  
* ==============================================================================
* Enrollment levels
foreach x in women men {
	use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear
	merge m:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hh_w1_w2.dta", nogen assert(match) keepusing(sanitation_comparable tc_imp main_income_source lhood hhh_gender prop_alwayslive migr_disp tenure1 floor_comparable house_type_comparable roof_material hhh_lit hhh_age remit12m hhsize pgender ind_profile)
	merge m:1 t strata ea block hh using "${gsdData}/1-CleanTemp/${drought}_w1w2.dta", nogen assert(match master) keep(match) keepusing(${drought} drought_${drought})
	merge m:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core)
	merge m:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match master) nogen
	merge m:1 reg_pess using "${gsdData}/1-CleanTemp/Assist_Educ.dta", assert(match using) keep(match) nogen
	merge m:1 reg_pess using "${gsdData}/1-CleanTemp/FSC_HumReach.dta", assert(match using) keep(match) nogen
	merge m:1 reg_pess using "${gsdData}/1-CleanTemp/NDVI_average_series.dta", assert(match using) keep(match) nogen keepusing(NDVI*)
	svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

	* keep relevant populations
	drop if inlist(type,3,4)
	$migr_disp
	$pld1
	$migr
	$pljl2 
	keep if inrange(age,6,18)
	gen women=gender==0
	gen men=gender==1
	keep if `x'==1

	
	* prepare variables
	gen rural=type==2
	gen urban=type==1
	gen total=1
	gen fatxdrought = drought_${drought}*fatalities
	gen assistxpost = assist_edu17*t
	gen droughtxpost = drought_${drought}*t
	gen droughtxcons = tc_core*drought_${drought}
	gen sal_lab = lhood==1 if !mi(lhood) 
	replace sal_lab=1 if main_income_source==1 & !mi(main_income_source) 
	replace sal_lab=0 if main_income_source!=1 & !mi(main_income_source)
	*recode reg_pess (1 18 = 1) (2 5 = 2) (3=3) (4 11 12 = 4) (6=6) (7 10 = 7) (8=8) (13 16 = 13) (14=14) (15=15) (17=17), gen(reg1)
	*gen reg1type = reg1*type
	*recode ind_profile (1=1) (3 5 = 2) (2 4 6 7 8 9 11 12 = 0), gen(ind_overlapping)
	recode lfp_7d (missing=0)
	* Define controls globals
	global controls_region i.ind_profile i.type NDVI_av_rs 
	global controls_ind age i.hhm_relation tc_core
	global controls_hh hhh_lit hhh_age remit12m hhsize hhh_gender n_dependent
	global controls_dwelling i.tenure1 i.floor_comparable i.house_type_comparable i.roof_material sanitation_comparable
	global controls_conflict fatalities fatxdrought
	global controls_assist assist_FSC_17 
	la var droughtxpost "DD Estimator"

	* Unconditional values for comparison
	*egen drought = group(t drought_${drought}), label
	*tabout drought using "${gsdOutput}/DroughtImpact_raw6_additional.xls" if rural==1, svy sum c(mean enrolled) sebnone f(3) h2("Enrolled & Drought (SPI)") npos(col) replace

	foreach t in total urban rural {
		preserve
		keep if `t'==1
		* 1.2 Probit enrollment, full dataset 
		svy: probit enrolled t drought_${drought} droughtxpost
		margins, dydx(droughtxpost) post
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_1_`t'.xls", replace ctitle("`t', No controls") label excel keep(droughtxpost) nocons 
		svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh $controls_dwelling $controls_conflict $controls_assist $controls_region
		margins, dydx(droughtxpost) post
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_1_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict+assist+region controls") label excel keep(droughtxpost) nocons 
		
		* 2.1 enrollment overlapping sample w1 w2
		keep if inlist(ind_profile,1,3,5)
		svy: probit enrolled t drought_${drought} droughtxpost
		margins, dydx(droughtxpost) post
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_2_`t'.xls", replace ctitle("`t', No controls") label excel keep(droughtxpost) nocons 
		svy: probit enrolled t drought_${drought} droughtxpost $controls_ind $controls_hh $controls_dwelling $controls_assist $controls_conflict $controls_region
		margins, dydx(droughtxpost) post
		outreg2 using "${gsdOutput}/DroughtImpact_raw9_2_`t'.xls", append ctitle("`t', individual+hh+dwelling+conflict+assist+region controls") label excel keep(droughtxpost) nocons 
		restore
	}
	* Put it together
	insheet using "${gsdOutput}/DroughtImpact_raw9_1_total.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "U+R,Full" in 2
	replace v2 = "Enrollment, `x'" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetreplace sheet("Raw_Education_`x'")
	insheet using "${gsdOutput}/DroughtImpact_raw9_1_urban.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "U,Full" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Education_`x'") cell(A10)
	insheet using "${gsdOutput}/DroughtImpact_raw9_1_rural.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "R,Full" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Education_`x'") cell(A20)

	insheet using "${gsdOutput}/DroughtImpact_raw9_2_total.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "U+R,Overlapping" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Education_`x'") cell(D1)
	insheet using "${gsdOutput}/DroughtImpact_raw9_2_urban.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "U,Overlapping" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Education_`x'") cell(D10)
	insheet using "${gsdOutput}/DroughtImpact_raw9_2_rural.txt", clear
	drop if v3==""
	replace v2=v1 if v2==""
	drop v1
	replace v2 = "R,Overlapping" in 1
	export excel using "${gsdOutput}/DroughtImpact_Figures_${drought}.xlsx", sheetmodify sheet("Raw_Education_`x'") cell(D20)

}
