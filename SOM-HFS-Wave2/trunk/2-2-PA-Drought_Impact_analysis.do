* Drought Impact graphs and regressions

set more off
set seed 23081980 
set sortseed 11041955

*===============================================================================
* Statistics for Introduction part of chapter 
*===============================================================================
* Rainfall and NDVI timeseries
use "${gsdData}/1-CleanTemp/rainfall_timeseries.dta", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Rainfall_TS") first(variables)

* IPC classification over time ** 
use "${gsdData}/1-CleanTemp/IPC_Population.dta", clear
gen projection = Date0!=Date1
gen date = (Date1 + Date0)/2
format date %td
drop *1 *0
order date total_* projection
sort date
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_IPC") sheetreplace firstrow(variables)

* Reporting of hunger by pre-war region
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_IPC") sheetmodify cell(A13) firstrow(variables)

* Drought-related displacement and health crises
import delim using "${gsdShared}\0-Auxiliary\EmergencyFigures_historical.csv", clear
keep if crisis_name=="Somalia"
* displacement 
preserve
keep if figure_name=="Internally Displaced due to Drought (per month)"  
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_Displacement") sheetreplace firstrow(variables)
restore
preserve
keep if figure_name=="IDPs" 
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_Displacement") sheetmodify cell(D1) firstrow(variables)
restore
preserve
keep if figure_name=="Internally Displaced due to Conflict (per year)" 
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_Displacement") sheetmodify cell(G1) firstrow(variables)
restore
* Health
preserve
keep if figure_name=="AWD/Cholera Cases (Cumulative per year)"
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_Health") sheetreplace firstrow(variables)
restore
preserve
keep if figure_name=="AWD/Cholera Deaths (Cumulative per year)"
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_Health") sheetmodify cell(D1) firstrow(variables)
restore
preserve
keep if figure_name=="Measles Suspected Cases in 2017"
export excel figure_name figure_date figure_value using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_Health") sheetmodify cell(G1) firstrow(variables)
restore
*===============================================================================
* Descriptive drought statistics
*===============================================================================
* Standardized Precipitation Index 
* All SOM
use "${gsdData}/1-CleanTemp/SPI_SOM0.dta", clear
su SPI, d
drop if SPI<-8
kdensity SPI, nograph gen(x_SPI y_SPI)
keep x_SPI y_SPI
drop if mi(x_SPI, y_SPI)
* Wave 1 HHs
append using "${gsdData}/1-CleanTemp/Wave1_SPI.dta"
kdensity SPI, at(x_SPI) nograph gen(y_SPI_hh)
keep x_SPI y_SPI y_SPI_hh
drop if mi(x_SPI, y_SPI_hh, y_SPI)
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_Drought_Indicators") sheetmodify cell(D1) firstrow(variables)
* Wave 2 HHs 
use "${gsdData}/1-CleanTemp/SPI_SOM0.dta", clear
su SPI, d
drop if SPI<-8
kdensity SPI, nograph gen(x_SPI y_SPI)
keep x_SPI y_SPI
drop if mi(x_SPI, y_SPI)
append using "${gsdData}/1-CleanTemp/Wave2_SPI.dta"
kdensity SPI, at(x_SPI) nograph gen(y_SPI_hh_w2)
keep y_SPI_hh_w2
drop if mi(y_SPI_hh_w2)
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_Drought_Indicators") sheetmodify cell(G1) firstrow(variables)

* SPI Category - Wave 1 households
use "${gsdData}/1-CleanTemp/Wave1_SPI.dta", clear
su SPI, d
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", assert(match) keepusing(weight_adj hhsize)
svyset ea [pweight=weight_adj], strata(strata)
gen x = 1
tabout SPI_cat x using "${gsdOutput}/DroughtImpact_raw00.xls" , svy percent c(col se) npos(col) sebnone h1("SPI Category - Wave 1") replace

* SPI Category - Wave 2 households
use "${gsdData}/1-CleanTemp/Wave2_SPI.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(master match) keep(match) keepusing(weight hhsize)
svyset ea [pweight=weight], strata(strata)
gen x = 1
tabout SPI_cat x using "${gsdOutput}/DroughtImpact_raw00.xls",  svy percent c(col se) npos(col) sebnone h1("SPI Category - Wave 2") append

* NDVI Deviation
* All SOM
use "${gsdData}/1-CleanTemp/NDVI_SOM0.dta", clear
su NDVI_deviation, d
drop if NDVI_deviation>12
drop if NDVI_deviation<`r(p1)'
su NDVI_deviation, d
kdensity NDVI_deviation, nograph gen(x_NDVI y_NDVI)
keep x_NDVI y_NDVI
drop if mi(x_NDVI, y_NDVI)
append using "${gsdData}/1-CleanTemp/Wave1_NDVI.dta"
kdensity NDVI_deviation, at(x_NDVI) nograph gen(y_NDVI_hh)
keep x_NDVI y_NDVI y_NDVI_hh
drop if mi(x_NDVI, y_NDVI_hh, y_NDVI)
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheet("Raw_Drought_Indicators") sheetmodify cell(A1) firstrow(variables)
* just households
use "${gsdData}/1-CleanTemp/Wave1_NDVI.dta", clear
su NDVI_deviation, d
*twoway (histogram NDVI_deviation,  xlabel(-50(10)50)) (kdensity NDVI_deviation,  xlabel(-50(10)50) xli(`r(p50)', lpa(dash))) 
*graph export "${gsdOutput}/NDVI_deviation_Wave1.png", replace
destring block, replace
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", assert(match) keepusing(weight_adj hhsize)
svyset ea [pweight=weight_adj], strata(strata)
gen x = 1
tabout NDVI_drought_cat x using "${gsdOutput}/DroughtImpact_raw00.xls" , svy percent c(col se) npos(col) sebnone h1("NDVI Drought Category") append

* compare SPI, rainfall deviation, and NDVI deviation
use "${gsdData}/1-CleanTemp/Wave1_SPI.dta", clear
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_NDVI.dta", assert(match) nogen
destring block, replace
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanTemp/rainfall.dta", assert(match) nogen
tabstat NDVI_deviation, by(SPI_cat) stats(min mean max N)
twoway (scatter NDVI_deviation SPI) (lfit NDVI_deviation SPI)
graph export "${gsdOutput}/SPI_NDVI.png", replace
reg NDVI_deviation SPI
tabstat precip_combined, by(SPI_cat) stats(min mean max N)
twoway (scatter precip_combined NDVI_deviation) (lfit precip_combined NDVI_deviation)
reg NDVI_deviation precip_combined
* Once we have settled on the final drought measures, It would make sense to have an excel scatter plot here

*===============================================================================
* Correlates of drought-affected households
*===============================================================================
* Wave 1
use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
gen x=1
la var x "Proportion"
tabout drought_SPI using "${gsdOutput}/DroughtImpact_raw0.xls", svy percent c(col) npos(col) sebnone h2(drought SPI Affected - Wave 1) replace
gen nodrought_SPI=drought_SPI==0
gen nodrought_NDVI=drought_NDVI==0
tabout reg_pess using "${gsdOutput}/DroughtImpact_raw0.xls", sum c(sum  drought_SPI sum  nodrought_SPI) sebnone h2(drought_SPI Affected by pre-war region) append
* Wave 2
use "${gsdData}/1-CleanTemp/Wave2_SPI.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(master match) keep(match) keepusing(weight hhsize)
gen pweight=weight*hhsize
svyset ea [pweight=weight], strata(strata)
gen x=1
la var x "Proportion"
gen nodrought_SPI=drought_SPI==0
tabout region using "${gsdOutput}/DroughtImpact_raw0.xls", sum c(sum drought_SPI sum  nodrought_SPI) sebnone h2(drought_SPI Affected by pre-war region - Wave 2) append
tabout drought_SPI using "${gsdOutput}/DroughtImpact_raw0.xls", svy percent c(col) npos(col) sebnone h1(drought SPI Affected - Wave 2) append

* Main correlate stats
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", assert(match using) keep(match) keepusing(SPI_cat drought_SPI)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
egen drought = group(t drought_SPI), label

* Drop IDPs
drop if inlist(type,3,4)
* Poverty - headcount
tabout drought using "${gsdOutput}/DroughtImpact_raw1.xls", svy sum c(mean poorPPP_prob lb ub) sebnone f(3) h1(Drought (SPI) and Poverty) npos(col) replace
tabout drought type  using "${gsdOutput}/DroughtImpact_raw1.xls" , svy sum c(mean poorPPP_prob) sebnone f(3) h1(Drought (SPI) and Poverty by population type - Wave 1) npos(col) append
tabout drought reg_pess  using "${gsdOutput}/DroughtImpact_raw1.xls" , svy sum c(mean poorPPP_prob) sebnone f(3) h1(Drought (SPI) and Poverty by region - Wave 1) npos(col) append

* Poverty - gap
tabout drought using "${gsdOutput}/DroughtImpact_raw1.xls", svy sum c(mean pgi lb ub) sebnone f(3) h1(Drought and Poverty Gap) npos(col) append
tabout drought type  using "${gsdOutput}/DroughtImpact_raw1.xls" , svy sum c(mean pgi) sebnone f(3) h1(Drought and Poverty Gap by population type) npos(col) append

* Inequality
gen gini = .
levelsof drought, local(drought) 
foreach i of local drought {
	su tc_imp if drought==`i'
	fastgini tc_imp [pweight=pweight] if drought==`i'
	return list 
	replace gini=r(gini) if drought==`i'
}
tabout drought gini using "${gsdOutput}/DroughtImpact_raw2.xls" , svy c(freq) sebnone f(3) npos(col) h1(GINI coefficient) replace

* Growth incidence and decomposition
* total
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", assert(match using) keep(match) keepusing(SPI_cat drought_SPI)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
egen drought = group(t drought_SPI), label
drop if inlist(type,3,4) 
drop if migr_idp==1
keep if inlist(reg_pess, 1,3,4,11,12,13,16,17,18)
preserve
keep if t==1 
save "${gsdTemp}/hh_SPI_w2.dta", replace
restore
keep if t==0
save "${gsdTemp}/hh_SPI_w1.dta", replace
cd "${gsdTemp}"
use "${gsdTemp}/hh_SPI_w1.dta", clear
gicurve using "${gsdTemp}/hh_SPI_w2.dta" [aw=pweight] if drought_SPI==1, var1(tc_imp) var2(tc_imp) np(100) ci(100) bands(20) out("gic_drought.dta") 
gicurve using "${gsdTemp}/hh_SPI_w2.dta" [aw=pweight] if drought_SPI==0, var1(tc_imp) var2(tc_imp) np(100) ci(100) bands(20) out("gic_nodrought.dta")
use "${gsdTemp}/gic_drought.dta", clear
drop gr_in_mean gr_in_median mean_of_growth intgrl1 
ren (pr_growth pg_ci_u pg_ci_l) (drought_gic drought_ci_h drought_ci_l)
merge 1:1 pctl using "${gsdTemp}/gic_nodrought.dta", assert(match) nogen keepusing(pr_growth pg_ci_u pg_ci_l)
ren (pr_growth pg_ci_u pg_ci_l) (ndrought_gic ndrought_ci_h ndrought_ci_l)
export excel using "${gsdOutput}/DroughtImpact_raw3.xls", replace first(variables)
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Data_3") first(variables)

* urban
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", assert(match using) keep(match) keepusing(SPI_cat drought_SPI)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
egen drought = group(t drought_SPI), label
keep if type==1
preserve
keep if t==1 
save "${gsdTemp}/hh_SPI_w2u.dta", replace
restore
keep if t==0
save "${gsdTemp}/hh_SPI_w1u.dta", replace
cd "${gsdTemp}"
use "${gsdTemp}/hh_SPI_w1u.dta", clear
gicurve using "${gsdTemp}/hh_SPI_w2u.dta" [aw=pweight] if drought_SPI==1, var1(tc_imp) var2(tc_imp) np(100) ci(100) bands(20) out("gic_droughtu.dta") 
gicurve using "${gsdTemp}/hh_SPI_w2u.dta" [aw=pweight] if drought_SPI==0, var1(tc_imp) var2(tc_imp) np(100) ci(100) bands(20) out("gic_nodroughtu.dta")
use "${gsdTemp}/gic_droughtu.dta", clear
drop gr_in_mean gr_in_median mean_of_growth intgrl1 
ren (pr_growth pg_ci_u pg_ci_l) (drought_gic drought_ci_h drought_ci_l)
merge 1:1 pctl using "${gsdTemp}/gic_nodroughtu.dta", assert(match) nogen keepusing(pr_growth pg_ci_u pg_ci_l)
ren (pr_growth pg_ci_u pg_ci_l) (ndrought_gic ndrought_ci_h ndrought_ci_l)
export excel using "${gsdOutput}/DroughtImpact_raw3_urban.xls", replace first(variables)
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Data_3_urban") first(variables)

* rural
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", assert(match using) keep(match) keepusing(SPI_cat drought_SPI)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
egen drought = group(t drought_SPI), label
keep if type==2
preserve
keep if t==1 
save "${gsdTemp}/hh_SPI_w2r.dta", replace
restore
keep if t==0
save "${gsdTemp}/hh_SPI_w1r.dta", replace
cd "${gsdTemp}"
use "${gsdTemp}/hh_SPI_w1r.dta", clear
gicurve using "${gsdTemp}/hh_SPI_w2r.dta" [aw=pweight] if drought_SPI==1, var1(tc_imp) var2(tc_imp) np(100) ci(100) bands(20) out("gic_droughtr.dta") 
gicurve using "${gsdTemp}/hh_SPI_w2r.dta" [aw=pweight] if drought_SPI==0, var1(tc_imp) var2(tc_imp) np(100) ci(100) bands(20) out("gic_nodroughtr.dta")
use "${gsdTemp}/gic_droughtu.dta", clear
drop gr_in_mean gr_in_median mean_of_growth intgrl1 
ren (pr_growth pg_ci_u pg_ci_l) (drought_gic drought_ci_h drought_ci_l)
merge 1:1 pctl using "${gsdTemp}/gic_nodroughtr.dta", assert(match) nogen keepusing(pr_growth pg_ci_u pg_ci_l)
ren (pr_growth pg_ci_u pg_ci_l) (ndrought_gic ndrought_ci_h ndrought_ci_l)
export excel using "${gsdOutput}/DroughtImpact_raw3_rural.xls", replace first(variables)
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Data_3_rural") first(variables)

*===============================================================================
* Main Diff-in-Diff estimates 
*===============================================================================
* 1. Poverty and Consumption*
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", nogen assert(match master) keep(match) keepusing(SPI_cat drought_SPI)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match master) nogen
merge m:1 reg_pess using "${gsdData}/1-CleanTemp/FSC_HumReach.dta", assert(match using) keep(match) nogen
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)

* keep only relevant populations
drop if inlist(type,3,4)
drop if migr_disp==1
drop if inlist(ind_profile,2,4) & t==0
drop if prop_alwayslive==0
* Prepare dependent and independent variables
gen ltc_core = log(tc_core)
la var ltc_core "Log imputed core consumption"
gen droughtxpost = drought_SPI*t
la var droughtxpost "DD Estimator"
gen rural=type==2
gen urban=type==1
gen total=1
gen fatxdrought = drought_SPI*fatalities
gen assistxpost = assist_FSC1_17*t
* Define controls globals
global controls_region rural i.ind_profile
global controls_hh hhh_lit hhh_age remit12m hhsize pgender
global controls_dwelling i.tenure1 i.floor_comparable i.house_type_comparable i.roof_material
global controls_conflict fatalities fatxdrought
global controls_assist assist_FSC1_17 assistxpost

*svy: reg poorPPP t drought_SPI droughtxpost
*outreg2 using "${gsdOutput}/DroughtImpact_test4.xls", replace ctitle("poorPPP_prob, `t', No controls") label excel keep(droughtxpost) nocons noparen

	
foreach t in total urban rural {
	preserve
	keep if `t'==1
	* 1.1 Log core consumption, full dataset
	svy: reg ltc_core t drought_SPI droughtxpost
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", replace ctitle("ltc_core, `t', No controls") dec(3) label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_SPI droughtxpost $controls_region
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", append ctitle("ltc_core, `t', Region controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_SPI droughtxpost $controls_region $controls_hh 
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", append ctitle("ltc_core, `t', Region + hh controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling 
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling + conflict controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_11_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling + conflict + assist controls") label excel keep(droughtxpost) nocons 
	* 1.2 PoorPPP_prob, full dataset 
	svy: probit poorPPP t drought_SPI droughtxpost
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", replace mfx ctitle("poorPPP_prob, `t', No controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_SPI droughtxpost $controls_region
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", append mfx ctitle("poorPPP_prob, `t', Region controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_SPI droughtxpost $controls_region $controls_hh 
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", append mfx ctitle("poorPPP_prob, `t', Region + hh controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling 
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", append mfx ctitle("poorPPP_prob, `t', Region + hh + dwelling controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", append mfx ctitle("poorPPP_prob, `t', Region + hh + dwelling + conflict controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_12_`t'.xls", append mfx ctitle("poorPPP_prob, `t', Region + hh + dwelling + conflict + assist controls") label excel keep(droughtxpost) nocons 
	
	* 2.1 log core consumption, overlapping sample w1 w2
	keep if inlist(ind_profile,1,3,5)
	global controls_region rural i.reg_pess
	svy: reg ltc_core t drought_SPI droughtxpost
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", replace ctitle("ltc_core, `t', No controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_SPI droughtxpost $controls_region
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", append ctitle("ltc_core, `t', Region controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_SPI droughtxpost $controls_region $controls_hh 
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", append ctitle("ltc_core, `t', Region + hh controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling 
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling + conflict controls") label excel keep(droughtxpost) nocons 
	svy: reg ltc_core t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_21_`t'.xls", append ctitle("ltc_core, `t', Region + hh + dwelling + conflict + assist controls") label excel keep(droughtxpost) nocons 
	* 2.2 PoorPPP_prob, overlapping sample w1 w2 
	svy: probit poorPPP t drought_SPI droughtxpost
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", replace mfx ctitle("poorPPP_prob, `t', No controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_SPI droughtxpost $controls_region
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", append mfx ctitle("poorPPP_prob, `t', Region controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_SPI droughtxpost $controls_region $controls_hh 
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", append mfx ctitle("poorPPP_prob, `t', Region + hh controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", append mfx ctitle("poorPPP_prob, `t', Region + hh + dwelling controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", append mfx ctitle("poorPPP_prob, `t', Region + hh + dwelling + conflict controls") label excel keep(droughtxpost) nocons 
	svy: probit poorPPP t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist
	mfx compute
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_22_`t'.xls", append mfx ctitle("poorPPP_prob, `t', Region + hh + dwelling + conflict + assist controls") label excel keep(droughtxpost) nocons 
	restore
}
* Check distribution with quantile regressions
foreach t in urban rural {
	cap erase "${gsdOutput}/DroughtImpact_raw4_quantile_1_`t'.xls"
	cap erase "${gsdOutput}/DroughtImpact_raw4_quantile_1_`t'.txt"
	cap erase "${gsdOutput}/DroughtImpact_raw4_quantile_2_`t'.xls"
	cap erase "${gsdOutput}/DroughtImpact_raw4_quantile_2_`t'.txt"
	preserve
	keep if `t'==1
	foreach v of numlist 0.01 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.99 {
		qreg ltc_core t drought_SPI droughtxpost [pw=pweight], q(`v') vce(robust)
		outreg2 using "${gsdOutput}/DroughtImpact_raw4_quantile_1_`t'.xls", append ctitle("p=`v', `t', ltc_core, qreg, no controls") label excel keep(droughtxpost) noparen nocons noaster
		qreg ltc_core t drought_SPI droughtxpost $controls_region $controls_hh $controls_dwelling $controls_conflict $controls_assist [pw=pweight], q(`v') vce(robust)
		outreg2 using "${gsdOutput}/DroughtImpact_raw4_quantile_2_`t'.xls", append ctitle("p=`v', `t', ltc_core, qreg, controls") label excel keep(droughtxpost) nocons noparen noaster
	}
	restore
}

*Unconditional values for comparison
egen drought = group(t drought_SPI), label
* Full sample
la var ltc_core "Log imputed core consumption"
tabout drought using "${gsdOutput}/DroughtImpact_raw4_additional.xls", svy sum c(mean poorPPP lb ub) sebnone f(3) h2("Poor & Drought (SPI)") npos(col) replace
tabout drought using "${gsdOutput}/DroughtImpact_raw4_additional.xls", svy sum c(mean tc_core lb ub) sebnone f(3) h2("Core consumption & Drought (SPI)") npos(col) append
preserve
* urban sample
keep if type==1
tabout drought using "${gsdOutput}/DroughtImpact_raw4_additional.xls", svy sum c(mean poorPPP lb ub) sebnone f(3) h2("Urban-Poor & Drought (SPI)") npos(col) append
tabout drought using "${gsdOutput}/DroughtImpact_raw4_additional.xls", svy sum c(mean tc_core lb ub) sebnone f(3) h2("Urban-Core consumption & Drought (SPI)") npos(col) append
restore
* rural sample
keep if type==2
tabout drought using "${gsdOutput}/DroughtImpact_raw4_additional.xls", svy sum c(mean poorPPP lb ub) sebnone f(3) h2("Rural-Poor & Drought (SPI)") npos(col) append
tabout drought using "${gsdOutput}/DroughtImpact_raw4_additional.xls", svy sum c(mean tc_core lb ub) sebnone f(3) h2("Rural-Core consumption & Drought (SPI)") npos(col) append

* Put it together
insheet using "${gsdOutput}/DroughtImpact_raw4_11_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Full,tc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Data_4")
insheet using "${gsdOutput}/DroughtImpact_raw4_12_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Full, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(A10)
insheet using "${gsdOutput}/DroughtImpact_raw4_11_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Full,ltc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(A20)
insheet using "${gsdOutput}/DroughtImpact_raw4_12_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Full, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(A30)
insheet using "${gsdOutput}/DroughtImpact_raw4_11_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Full, ltc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(A40)
insheet using "${gsdOutput}/DroughtImpact_raw4_12_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Full, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(A50)

insheet using "${gsdOutput}/DroughtImpact_raw4_21_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Overlapping, ltc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(I1)
insheet using "${gsdOutput}/DroughtImpact_raw4_22_total.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U+R,Overlapping, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(I10)
insheet using "${gsdOutput}/DroughtImpact_raw4_21_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Overlapping, ltc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(I20)
insheet using "${gsdOutput}/DroughtImpact_raw4_22_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "U,Overlapping, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(I30)
insheet using "${gsdOutput}/DroughtImpact_raw4_21_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Overlapping, ltc_core" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(I40)
insheet using "${gsdOutput}/DroughtImpact_raw4_22_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
replace v2 = "R,Overlapping, poorPPP_prob" in 1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(I50)
* Quantile regressions
insheet using "${gsdOutput}/DroughtImpact_raw4_quantile_1_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Data_4_qreg")
insheet using "${gsdOutput}/DroughtImpact_raw4_quantile_2_urban.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4_qreg") cell(A11)
insheet using "${gsdOutput}/DroughtImpact_raw4_quantile_1_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4_qreg") cell(A21)
insheet using "${gsdOutput}/DroughtImpact_raw4_quantile_2_rural.txt", clear
drop if v3==""
replace v2=v1 if v2==""
drop v1
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4_qreg") cell(A32)

* Additional
insheet using "${gsdOutput}/DroughtImpact_raw4_additional.xls", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Data_4_additional") 

* Look at distribution of losses along the spectrum of being exposed to drought
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", nogen keep(match) keepusing(SPI_cat drought_SPI SPI)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
egen drought = group(t drought_SPI), label
gen ltc_core = log(tc_core)
la var ltc_core "Log imputed core consumption"
* keep only urban and rural
drop if inlist(type,3,4) 
drop if migr_idp==1
* drop NE
drop if inlist(ind_profile,2,4)
gen tc_imp1 = tc_imp if t==0
gen tc_imp2 = tc_imp if t==1
twoway  (lpolyci tc_imp2 SPI, ciplot(rline)) (lpolyci tc_imp1 SPI, ciplot(rline))
graph save Graph "${gsdOutput}/SPI_tc_imp1.gph", replace
twoway (lpolyci tc_imp1 SPI, ciplot(rline)) (lpolyci tc_imp2 SPI, ciplot(rline))  
graph save Graph "${gsdOutput}/SPI_tc_imp2.gph", replace
graph use "${gsdOutput}/SPI_tc_imp1.gph"
serset use, clear
ren (__0000*) (lpolyfit1 SPI low1 high1)
save "${gsdTemp}/SPI_tc_imp_lpolyfit1.dta", replace
graph use "${gsdOutput}/SPI_tc_imp2.gph", 
serset use, clear
ren (__0000*) (lpolyfit2 SPI low2 high2)
merge 1:1 SPI using "${gsdTemp}/SPI_tc_imp_lpolyfit1.dta", nogen 
order SPI 
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Data_5") firstrow(variables)

use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", nogen  keep(match) keepusing(SPI_cat drought_SPI SPI)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen keep(match master) keepusing(tc_core)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
* drop NE
drop if inlist(ind_profile,2,4)
tabout SPI_cat  using "${gsdOutput}/DroughtImpact_raw5-2.xls" if t==0, svy sum c(mean tc_imp lb ub) sebnone f(3) h2("Drought Cat & consumption - W1") npos(col) replace
tabout SPI_cat  using "${gsdOutput}/DroughtImpact_raw5-2.xls" if t==1, svy sum c(mean tc_imp lb ub) sebnone f(3) h2("Drought Cat & consumption - W2") npos(col) append
insheet using "${gsdOutput}/DroughtImpact_raw5-2.xls", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_5-2")

******************************************************************************** 
* 2. Education *  
use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear
* for now find literacy of those unenrolled or outside of education age
keep if age>17
collapse (mean) adult_literacy=literacy [pw=weight_adj], by(t strata ea block hh)
save "${gsdTemp}/hhm-hh_adlit.dta", replace
use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear
merge m:1 t strata ea block hh using "${gsdTemp}/hhm-hh_adlit.dta", nogen assert(match master) keepusing(adult_literacy)
recode adult_literacy (.=0)
merge m:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hh_w1_w2.dta", nogen assert(match) keepusing(pliteracy pdependent   migr_idp remit12m hhh_gender tenure1 pgender floor_material roof_material)
merge m:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", nogen assert(match using) keep(match) keepusing(SPI_cat drought_SPI SPI)
merge m:1 t strata ea block hh using "${gsdData}/1-CleanOutput/hhq-poverty_w1_w2.dta", nogen assert(match master) keepusing(tc_core)
merge m:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", assert(match) nogen
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

drop if inlist(type,3,4)
drop if migr_idp==1
keep if inrange(age, 6, 17)

gen droughtxpost = drought_SPI*t
la var droughtxpost "DD Estimator"
gen drought_SPI1 = SPI_cat<-1
gen droughtxpost1 = drought_SPI1*t
gen rural=type==2
gen urban=type==1
gen total=1
gen fatxdrought = drought_SPI*fatalities
gen droughtxcons = drought_SPI*tc_core
global controls rural tc_core hhsize fatalities fatxdrought pliteracy remit12m hhh_gender i.tenure1 pgender i.floor_material i.roof_material 
svy: reg drought_SPI fatalities
svy: reg enrolled adult_literacy
gen w2_reg = !(inlist(reg_pess, 1,3,4,11,12,13,16,17,18))
drop if w2_reg==1
keep if inlist(reg_pess, 1,3,13,16,17,18)
keep if urban==0
svy: reg enrolled t drought_SPI droughtxpost adult_literacy tc_core  droughtxcons hhsize fatalities fatxdrought remit12m hhh_gender i.tenure1 pgender i.floor_material i.roof_material


foreach t in total urban rural {
	* 1-1-1 - log core consumption without controls, full sample
	preserve
	keep if `t'==1
	svy: reg ltc_core t drought_SPI droughtxpost
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", replace ctitle("1-1-1 - log core consumption without controls, full `t' sample")label excel keep(t drought_SPI droughtxpost) nocons
	* 1-1-2 - log core consumption with full set of controls, full sample
	svy: reg ltc_core t drought_SPI droughtxpost $controls
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("1-1-2 - log core consumption with full set of controls, full `t' sample")label excel keep(t drought_SPI droughtxpost) nocons
	* 1-2-1 - probit poorPPP without controls, full sample
	svy: probit poorPPP  t drought_SPI droughtxpost  
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("1-2-1 - probit poorPPP without controls, full `t' sample")label excel keep(t drought_SPI droughtxpost) nocons
	* 1-2-2 - probit poorPPP with controls, full sample
	svy: probit poorPPP t drought_SPI droughtxpost $controls 
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("1-2-2 - probit poorPPP with controls, full `t' sample")label excel keep(t drought_SPI droughtxpost) nocons
	* 2-1-1 - log core consumption without controls, overlapping sample
	keep if inlist(reg_pess, 1,3,4,11,12,13,16,17,18)
	svy: reg ltc_core t drought_SPI droughtxpost
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("2-1-1 - log core consumption without controls, overlapping `t' sample")label excel keep(t drought_SPI droughtxpost) nocons
	* 2-1-2 - log core consumption with full set of controls, overlapping sample
	svy: reg ltc_core t drought_SPI droughtxpost i.reg_pess $controls
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("2-1-2 - log core consumption with full set of controls, overlapping `t' sample")label excel keep(t drought_SPI droughtxpost) nocons
	* 2-2-1 - probit poorPPP without controls, overlapping sample
	svy: probit poorPPP t drought_SPI droughtxpost 
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("2-2-1 - probit poorPPP without controls, overlapping `t' sample")label excel keep(t drought_SPI droughtxpost) nocons
	* 2-2-2 - probit poorPPP with controls, overlapping sample
	svy: probit poorPPP t drought_SPI droughtxpost i.reg_pess $controls
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("2-2-2 - probit poorPPP with controls, overlapping `t' sample")label excel keep(t drought_SPI droughtxpost) nocons
	* 3-1-1 - log core consumption without controls, overlapping sample w/o PLD
	keep if inlist(reg_pess, 1,3,13,16,17,18)
	svy: reg ltc_core t drought_SPI droughtxpost
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("3-1-1 - log core consumption without controls, overlapping `t' sample w/o PLD")label excel keep(t drought_SPI droughtxpost) nocons
	* 3-1-2 - log core consumption with full set of controls, overlapping sample w/o PLD
	svy: reg ltc_core t drought_SPI droughtxpost i.reg_pess $controls
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("3-1-2 - log core consumption with full set of controls, overlapping `t' sample w/o PLD")label excel keep(t drought_SPI droughtxpost) nocons
	* 3-2-1 - probit poorPPP without controls, overlapping sample w/o PLD
	svy: probit poorPPP t drought_SPI droughtxpost
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("3-2-1 - probit poorPPP without controls, overlapping `t' sample w/o PLD")label excel keep(t drought_SPI droughtxpost) nocons
	* 3-2-2 - probit poorPPP with controls, overlapping sample w/o PLD
	svy: probit poorPPP t drought_SPI droughtxpost i.reg_pess $controls
	outreg2 using "${gsdOutput}/DroughtImpact_raw4_`t'.xls", append ctitle("3-2-2 - probit poorPPP with controls, overlapping `t' sample w/o PLD")label excel keep(t drought_SPI droughtxpost) nocons
	restore
}
insheet using "${gsdOutput}/DroughtImpact_raw4_total.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Data_4")
insheet using "${gsdOutput}/DroughtImpact_raw4_urban.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(A17)
insheet using "${gsdOutput}/DroughtImpact_raw4_rural.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_4") cell(A33)

use "${gsdData}/1-CleanOutput/hhm_w1_w2.dta", clear
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
merge m:1 t team strata ea block hh using "${gsdData}/1-CleanOutput/hh_w1_w2.dta", nogen assert(match) keepusing(hhh_gender hhh_edu type remit12m reg_pess)
svyset ea [pweight=weight_adj], strata(strata)
egen drought = group(t drought_SPI), label
tabout drought using "${gsdOutput}/DroughtImpact_raw6.xls" if !mi(enrolled), svy sum c(mean enrolled lb ub) sebnone f(3) h2("Enrollment & drought") npos(col) replace
tabout drought using "${gsdOutput}/DroughtImpact_raw6.xls" if !mi(enrolled) & gender==1, svy sum c(mean enrolled lb ub) sebnone f(3) h2("Boys' enrollment & drought") npos(col) append
tabout drought using "${gsdOutput}/DroughtImpact_raw6.xls" if !mi(enrolled) & gender==0, svy sum c(mean enrolled lb ub) sebnone f(3) h2("Girls' enrollment & drought") npos(col) append
tabout age t using "${gsdOutput}/DroughtImpact_raw6.xls" if !mi(enrolled25) & drought_SPI==0, svy sum c(mean enrolled25 lb ub) sebnone f(3) h1("Enrollment by age, not affected") npos(col) append
tabout age t using "${gsdOutput}/DroughtImpact_raw6.xls" if !mi(enrolled25) & drought_SPI==1, svy sum c(mean enrolled25 lb ub) sebnone f(3) h1("Enrollment by age, drought affected") npos(col) append
* Diff-in-Diff
* Overall
* (1) without any controls, dep var in logs
diff enrolled [pw=weight_adj], period(t) treated(drought_SPI) 
outreg2 using "${gsdOutput}/DroughtImpact_raw6-DID.txt", replace ctitle(`r(depvar)' - No controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
* (2) with pop type, hhh gender, hhh edu, remit12m
tab hhh_edu, gen(educ)
tab type, gen(type)
tab reg_pess, gen(region)
diff enrolled [pw=weight_adj], period(t) treated(drought_SPI) cov(type* region* remit12m hhh_gender educ*)
outreg2 using "${gsdOutput}/DroughtImpact_raw6-DID.txt", append ctitle(`r(depvar)' - Population type, regions, HHH edu and gender, remittances controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
* Boys
diff enrolled [pw=weight_adj] if gender==1, period(t) treated(drought_SPI) 
outreg2 using "${gsdOutput}/DroughtImpact_raw6-DID.txt", append ctitle(`r(depvar)' - Boys, No controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
diff enrolled [pw=weight_adj] if gender==1, period(t) treated(drought_SPI) cov(type* region* remit12m hhh_gender educ*)
outreg2 using "${gsdOutput}/DroughtImpact_raw6-DID.txt", append ctitle(`r(depvar)' - Boys, Population type, regions, HHH edu and gender, remittances controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
* Girls
diff enrolled [pw=weight_adj] if gender==0, period(t) treated(drought_SPI) 
outreg2 using "${gsdOutput}/DroughtImpact_raw6-DID.txt", append ctitle(`r(depvar)' - Girls, No controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
diff enrolled [pw=weight_adj] if gender==0, period(t) treated(drought_SPI) cov(type* region* remit12m hhh_gender educ*)
outreg2 using "${gsdOutput}/DroughtImpact_raw6-DID.txt", append ctitle(`r(depvar)' - Girls, Population type, regions, HHH edu and gender, remittances controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
insheet using "${gsdOutput}/DroughtImpact_raw6-DID.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetmodify sheet("Raw_Data_6-DID")


*Access to water and sanitation
*Labor market, sources of income, and remittances
tabout drought1 using "${gsdOutput}/DroughtImpact_raw2.xls", svy sum c(mean poorPPP_vulnerable_10_prob lb ub) sebnone f(3) h2(Drought and Vulnerability - Wave 1) replace
* Hunger
gen hunger_bin = hunger>1
la def lhunger_bin 0 "Never experienced food shortage" 1 "Experienced food shortage"
la val hunger_bin lhunger_bin
tabout drought1 using "${gsdOutput}/DroughtImpact_raw3.xls", svy sum c(mean hunger_bin lb ub) sebnone f(3) h2(Drought and Hunger - Wave 1) replace


* Put all created sheets into one excel document
foreach i of numlist 1/1 {
	insheet using "${gsdOutput}/DroughtImpact_raw`i'.xls", clear nonames tab
	export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Data_`i'")
}

insheet using "${gsdOutput}/DroughtImpact_raw00.xls", clear nonames tab
export excel using "${gsdOutput}/DroughtImpact_Figures_v5.xlsx", sheetreplace sheet("Raw_Data_00")
