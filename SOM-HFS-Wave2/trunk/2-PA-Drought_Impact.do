* Drought Impact graphs and regressions

set more off
set seed 23081980 
set sortseed 11041955

****************************************
****************** Maps ****************
****************************************
* Prepare maps data files
shp2dta using "${gsdShared}\0-Auxiliary\Adminstrative Maps\Som_Admbnda_Adm1_UNDP.shp", data("${gsdTemp}/Som_Admbnda_Adm1_UNDP.dta") coor("${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta") replace
shp2dta using "${gsdShared}\0-Auxiliary\Adminstrative Maps\Som_Admbnda_Adm2_UNDP.shp", data("${gsdTemp}/Som_Admbnda_Adm2_UNDP.dta") coor("${gsdTemp}/Som_Admbnda_Adm2_UNDP_coordinates.dta") replace
shp2dta using "${gsdShared}\0-Auxiliary\Adminstrative Maps\Wave1_Admin2.shp", data("${gsdTemp}/Wave1_Admin2.dta") coor("${gsdTemp}/Wave1_Admin2_coordinates.dta") replace
shp2dta using "${gsdShared}\0-Auxiliary\Adminstrative Maps\Wave2_Admin2.shp", data("${gsdTemp}/Wave2_Admin2.dta") coor("${gsdTemp}/Wave2_Admin2_coordinates.dta") replace
use "${gsdTemp}/Wave1_Admin2.dta", clear
destring block, replace
replace admin2Name = "Banadir" if team==2
save "${gsdTemp}/Wave1_Admin2.dta", replace

* interviews per pre-war region/district
use "${gsdTemp}/Som_Admbnda_Adm2_UNDP.dta", clear
merge 1:m admin2Name using "${gsdTemp}/Wave1_Admin2.dta", assert(master match) keepusing(team ea strata block hh latx longx) nogen
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/rainfall.dta", nogen assert(master match)
drop OBJECTID_1 date validOn ValidTo
gen x=1 if !mi(hh)
collapse (sum) interviews=x drought_affected1=drought1 drought_affected2=drought2, by(admin2Name admin2Pcod admin1Name admin1Pcod _ID)
save "${gsdTemp}/Wave1_Admin2_mapping.dta", replace

use "${gsdTemp}/Wave1_Admin2_mapping.dta", clear
replace interviews=. if interviews==0
spmap interviews using "${gsdTemp}/Som_Admbnda_Adm2_UNDP_coordinates.dta", id(_ID) fcolor(Blues2) clmethod(custom) clbreaks(1 10 30 50 70 100 200 500 1000) ///
	ndocolor(black) ndpattern(solid) ndlabel(None) title("SHFS W1 Coverage by District") ///
	polygon(data("${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta") ocolor(black) osize(thick)) ///
	legtitle(Interviews) legstyle(2) legend(size(medium) position(4))	
graph export "${gsdOutput}/W1_interviews_districts.png", replace

* pre-war regions with drought affected HHs
recode drought_affected1 (0=.)
spmap drought_affected1 using "${gsdTemp}/Som_Admbnda_Adm2_UNDP_coordinates.dta", id(_ID) fcolor(OrRd)  clmethod(custom) clbreaks(12 24 36 100 200) ///
	ndocolor(black) ndpattern(solid) ndlabel(None) title("Drought-Affected Households by district (Wave 1)") ///
	polygon(data("${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta") ocolor(black) osize(thick)) ///
	legtitle(Interviews) legstyle(2) legend(size(medium) position(4))	
graph export "${gsdOutput}/W1_interviews_drought1_districts.png", replace

recode drought_affected2 (0=.)
spmap drought_affected2 using "${gsdTemp}/Som_Admbnda_Adm2_UNDP_coordinates.dta", id(_ID) fcolor(OrRd)  ///
	ndocolor(black) ndpattern(solid) ndlabel(None) title("Drought-Affected Households by district (Wave 1)") ///
	polygon(data("${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta") ocolor(black) osize(thick)) ///
	legtitle(Interviews) legstyle(2) legend(size(medium) position(4))	
graph export "${gsdOutput}/W1_interviews_drought2_districts.png", replace

* Wave 2
use "${gsdTemp}/Som_Admbnda_Adm2_UNDP.dta", clear
merge 1:m admin2Name using "${gsdTemp}/Wave2_Admin2.dta", keep(master match) keepusing(PSU_ID) nogen
merge m:1 PSU_ID using "${gsdData}/1-CleanTemp/rainfall_w2.dta", nogen keep(master match)
drop OBJECTID_1 date validOn ValidTo
gen x = Sel_MainFi*12
replace drought1=drought1*Sel_MainFi*12
replace drought2=drought2*Sel_MainFi*12
save "${gsdTemp}/Wave2_EAs_drought_admin.dta", replace
collapse (sum) interviews=x drought_affected1=drought1 drought_affected2=drought2, by(admin2Name admin2Pcod admin1Name admin1Pcod _ID)
save "${gsdTemp}/Wave2_Admin2_mapping.dta", replace

use "${gsdTemp}/Wave2_Admin2_mapping.dta", clear
replace interviews=. if interviews==0
spmap interviews using "${gsdTemp}/Som_Admbnda_Adm2_UNDP_coordinates.dta", id(_ID) fcolor(Blues2) ///
	ndocolor(black) ndpattern(solid) ndlabel(None) title("SHFS W2 Coverage by District") ///
	polygon(data("${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta") ocolor(black) osize(thick)) ///
	legtitle(Interviews) legstyle(2) legend(size(medium) position(4))	
graph export "${gsdOutput}/W2_interviews_districts.png", replace

recode drought_affected1 (0=.)
spmap drought_affected1 using "${gsdTemp}/Som_Admbnda_Adm2_UNDP_coordinates.dta", id(_ID) fcolor(OrRd)  ///
	ndocolor(black) ndpattern(solid) ndlabel(None) title("Drought-Affected Households by district (Wave 2)") ///
	polygon(data("${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta") ocolor(black) osize(thick)) ///
	legtitle(Interviews) legstyle(2) legend(size(medium) position(4))	
graph export "${gsdOutput}/W2_interviews_drought1_districts.png", replace

recode drought_affected2 (0=.)
spmap drought_affected2 using "${gsdTemp}/Som_Admbnda_Adm2_UNDP_coordinates.dta", id(_ID) fcolor(OrRd)  ///
	ndocolor(black) ndpattern(solid) ndlabel(None) title("Drought-Affected2 Households by district (Wave 2)") ///
	polygon(data("${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta") ocolor(black) osize(thick)) ///
	legtitle(Interviews) legstyle(2) legend(size(medium) position(4))	
graph export "${gsdOutput}/W2_interviews_drought2_districts.png", replace

* Conflict
* 2017
use "${gsdTemp}/Som_Admbnda_Adm1_UNDP.dta", clear
gen admin1 = admin1Name
replace admin1 = admin1Alt if inlist(admin1Pcod, "SO22", "SO28", "SO23", "SO27", "SO21", "SO20")
replace admin1 = "Galguduud" if admin1Pcod=="SO19"
merge 1:m admin1 using "${gsdData}/1-CleanInput/ACLED.dta", nogen assert(match)
keep if year==2017
gen x = 1
collapse (sum) events=x fatalities, by(admin1 _ID)
spmap event using "${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta", id(_ID) fcolor(Reds2) clmethod(unique) ///
	ndocolor(black) ndpattern(solid) ndlabel(None) title("2017 conflict incidents by pre-war region") ///
	legtitle(Conflict events) legstyle(2) legend(size(small) position(4))
graph export "${gsdOutput}/2017_conflict_incidents_reg.png", replace

spmap fatalities using "${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta", id(_ID) fcolor(Reds2) clmethod(unique) ///
	ndocolor(black) ndpattern(solid) ndlabel(None) title("2017 conflict fatalities by pre-war region") ///
	legtitle(Conflict fatalities) legstyle(2) legend(size(small) position(4))	
graph export "${gsdOutput}/2017_conflict_fatalities_reg.png", replace

use "${gsdTemp}/Som_Admbnda_Adm1_UNDP.dta", clear
gen admin1 = admin1Name
replace admin1 = admin1Alt if inlist(admin1Pcod, "SO22", "SO28", "SO23", "SO27", "SO21", "SO20")
replace admin1 = "Galguduud" if admin1Pcod=="SO19"
merge 1:m admin1 using "${gsdData}/1-CleanInput/ACLED.dta", nogen assert(match)
keep if inlist(year, 2016)
gen x = 1
collapse (sum) events=x fatalities, by(admin1 _ID)
spmap event using "${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta", id(_ID) fcolor(Reds2) clmethod(unique) ///
	ndocolor(black) ndpattern(solid) ndlabel(None) title("2016 conflict incidents by pre-war region") ///
	legtitle(Conflict events) legstyle(2) legend(size(small) position(4))
graph export "${gsdOutput}/2016_conflict_incidents_reg.png", replace

spmap fatalities using "${gsdTemp}/Som_Admbnda_Adm1_UNDP_coordinates.dta", id(_ID) fcolor(Reds2) clmethod(unique) ///
	ndocolor(black) ndpattern(solid) ndlabel(None) title("2016 conflict fatalities by pre-war region") ///
	legtitle(Conflict fatalities) legstyle(2) legend(size(small) position(4))	
graph export "${gsdOutput}/2016_conflict_fatalities_reg.png", replace

********************************************************************************
*************** Drought Stats **************************************************
********************************************************************************
* Rainfall and NDVI timeseries
use "${gsdData}/1-CleanTemp/rainfall_timeseries.dta", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheetreplace sheet("Raw_Rainfall_TS") first(variables)

* Rainfall values --> Potentially add rainfall kdensity into Sheet Drought_Indicators_Raw
import delim using "${gsdShared}\0-Auxiliary\Climate Data\2016deyr_table.txt", clear
ren value PercentDeviation2016Deyr
gen n = _n
save "${gsdTemp}/2016deyr_rain_table.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\2016gu_table.txt", clear
ren value PercentDeviation2016Gu
gen n = _n
save "${gsdTemp}/2016gu_rain_table.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\2017gu_table.txt", clear
ren value PercentDeviation2017Gu
gen n = _n
merge 1:1 n using "${gsdTemp}/2016deyr_rain_table.dta", assert(match) nogen keepusing(PercentDeviation2016Deyr)
merge 1:1 n using "${gsdTemp}/2016gu_rain_table.dta", assert(match) nogen keepusing(PercentDeviation2016Gu)
su PercentDeviation2016Deyr, d 
twoway (kdensity PercentDeviation2016Deyr,  xlabel(-100(25)100) xli(`r(p50)', lpa(dash))) 
graph export "${gsdOutput}/2016Deyr_kdens.png", replace
su PercentDeviation2016Gu, d 
twoway (kdensity PercentDeviation2016Gu,  xlabel(-100(25)100) xli(`r(p50)', lpa(dash))) 
graph export "${gsdOutput}/2016Gu_kdens.png", replace
su PercentDeviation2017Gu, d 
twoway (kdensity PercentDeviation2017Gu,  xlabel(-100(25)100) xli(`r(p50)', lpa(dash))) 
graph export "${gsdOutput}/2017Gu_kdens.png", replace
ren (PercentDeviation2016Gu PercentDeviation2016Deyr PercentDeviation2017Gu) (PercentDeviation1 PercentDeviation2 PercentDeviation3)
reshape long PercentDeviation, i(n) j(season)
la def ls 1 "2016 Gu" 2 "2016 Deyr" 3 "2017 Gu", replace
la val season ls
tabout season using "${gsdOutput}/DroughtImpact_raw00.xls", sum oneway cells(mean PercentDeviation min PercentDeviation max PercentDeviation p50 PercentDeviation) f(3) replace
* All SOM rainfall combined
use "${gsdData}/1-CleanTemp/Rainfall_SOM0.dta", clear
su rainfall_deviation, d 
twoway (kdensity rainfall_deviation,  xlabel(-100(10)100) xli(`r(p50)', lpa(dash)) xli(-29, lpa(line) lcolor(grey))) 
graph export "${gsdOutput}/rainfall_combined_kdens.png", replace
gen x = 1
tabout x using "${gsdOutput}/DroughtImpact_raw00.xls", sum oneway cells(mean rainfall_deviation min rainfall_deviation max rainfall_deviation p50 rainfall_deviation sd rainfall_deviation) f(3) append
* Look at households in both waves
use "${gsdData}/1-CleanTemp/rainfall.dta", clear
su precip_combined, d
twoway (kdensity precip_combined,  xlabel(-100(10)100) xli(`r(p50)', lpa(dash)) xli(-29, lpa(line) lcolor(grey))) 
graph export "${gsdOutput}/combined_kdens_hhs.png", replace
use "${gsdData}/1-CleanTemp/rainfall_w2.dta", clear
su precip_combined, d
twoway (kdensity precip_combined,  xlabel(-100(10)100) xli(`r(p50)', lpa(dash)) xli(-29, lpa(line) lcolor(grey))) 
graph export "${gsdOutput}/combined_kdens_hhs_w2.png", replace
expand Sel_MainFi, gen(original)
expand 12
append using "${gsdData}/1-CleanTemp/rainfall.dta", gen(wave1)
tabout wave1 using "${gsdOutput}/DroughtImpact_raw00.xls", sum oneway cells(mean precip_combined min precip_combined max precip_combined p50 precip_combined) f(3) append

********************************************************************************
** SPI ** 
* All SOM
use "${gsdData}/1-CleanTemp/SPI_SOM0.dta", clear
su SPI, d
*twoway (histogram SPI, xli(`r(p50)', lpa(dash))) (kdensity SPI) 
*graph export "${gsdOutput}/SPI_SOM0.png", replace
drop if SPI<-8
kdensity SPI, nograph gen(x_SPI y_SPI)
keep x_SPI y_SPI
drop if mi(x_SPI, y_SPI)
append using "${gsdData}/1-CleanTemp/Wave1_SPI.dta"
kdensity SPI, at(x_SPI) nograph gen(y_SPI_hh)
keep x_SPI y_SPI y_SPI_hh
drop if mi(x_SPI, y_SPI_hh, y_SPI)
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheet("Raw_Drought_Indicators") sheetmodify cell(D1) firstrow(variables)
* just households
use "${gsdData}/1-CleanTemp/Wave1_SPI.dta", clear
su SPI, d
*twoway (histogram SPI) (kdensity SPI, xli(`r(p50)', lpa(dash))) 
*graph export "${gsdOutput}/SPI.png", replace
destring block, replace
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", assert(match) keepusing(weight_adj hhsize)
svyset ea [pweight=weight_adj], strata(strata)
gen x = 1
tabout SPI_cat x using "${gsdOutput}/DroughtImpact_raw00.xls" , svy percent c(col se) npos(col) sebnone h1("SPI Category") append

** NDVI Deviation **
* All SOM
use "${gsdData}/1-CleanTemp/NDVI_SOM0.dta", clear
*su NDVI_deviation, d
*twoway (kdensity NDVI_deviation,  xlabel(-50(10)50) xli(`r(p50)', lpa(dash)))  
*graph export "${gsdOutput}/NDVI_deviation_SOM0.png", replace
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheet("Raw_Drought_Indicators") sheetmodify cell(A1) firstrow(variables)
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

**************************************************
********************* Graphs *********************
**************************************************
use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_NDVI.dta", assert(match) nogen

gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)

* Correlates of drought-affected households
* Overview
gen x=1
la var x "Proportion"
tabout drought_SPI using "${gsdOutput}/DroughtImpact_raw0.xls", svy percent c(col) npos(col) sebnone h1(drought SPI Affected - Wave 1) replace
tabout drought_NDVI using "${gsdOutput}/DroughtImpact_raw0.xls", svy percent c(col) npos(col) sebnone h1(Drought NDVI Affected - Wave 1) append
gen nodrought_SPI=drought_SPI==0
gen nodrought_NDVI=drought_NDVI==0
tabout reg_pess using "${gsdOutput}/DroughtImpact_raw0.xls", sum c(sum  drought_SPI sum  nodrought_SPI) sebnone h1(drought_SPI Affected by pre-war region) append
tabout reg_pess using "${gsdOutput}/DroughtImpact_raw0.xls", sum c(sum  drought_NDVI sum  nodrought_NDVI) sebnone h1(drought NDVI Affected by pre-war region) append
* Wave 2
use "${gsdTemp}/Wave2_Admin2.dta", clear
drop if PSU_ID==0
drop Sel_MainFi FID_
merge 1:1 PSU_ID using "${gsdData}/1-CleanTemp/rainfall_w2.dta", assert(match) nogen
expand Sel_MainFi, gen(original)
expand 12
tabout drought1 using "${gsdOutput}/DroughtImpact_raw0.xls",  percent c(col) npos(col) sebnone h1(Drought1 Affected - Wave 1) append
tabout drought2 using "${gsdOutput}/DroughtImpact_raw0.xls",  percent c(col) npos(col) sebnone h1(Drought2 Affected - Wave 1) append
gen nodrought1=drought1==0
gen nodrought2=drought2==0
tabout admin1Name using "${gsdOutput}/DroughtImpact_raw0.xls", sum c(sum drought1 sum nodrought1) sebnone f(0) h2(Drought1 Affected by pre-war region - W2) append
tabout admin1Name using "${gsdOutput}/DroughtImpact_raw0.xls", sum c(sum drought2 sum nodrought2) sebnone f(0) h2(Drought2 Affected by pre-war region - W2) append

* Main correlate stats
use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_NDVI.dta", nogen assert(match)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)

egen drought = group(t drought_SPI), label

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
use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_NDVI.dta", nogen assert(match)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
egen drought = group(t drought_SPI), label
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheetreplace sheet("Raw_Data_3") first(variables)

********************* Diff-in-Diff estimation **********************************
* CHANGE TC_IMP TO tc_imp ONCE ACTUAL WAVE 2 DATA IS IN
use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
*merge m:1 team strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", nogen assert(match master) keepusing(tc_imp)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)

* We want to run the estimation with dep var in logs, so let's look at that
*hist tc_imp 
*graph export "${gsdOutput}/tc_imp_hist.png", replace
gen ltc_imp = log(tc_imp)
la var ltc_imp "Log imputed core consumption"
*hist ltc_imp
*graph export "${gsdOutput}/ltc_imp_hist.png", replace

* Checking a few correlates
svy: reg tc_imp hhh_gender
svy: reg drought_SPI hhh_gender
svy: reg tc_imp i.hhh_edu
svy: reg drought_SPI i.hhh_edu
svy: reg tc_imp pliteracy 
svy: reg drought_SPI pliteracy
svy: reg drought_SPI remit12m

* Now let's look at a few specifications
* (1) without any controls, dep var in logs
diff ltc_imp [pw=pweight], period(t) treated(drought_SPI) 
outreg2 using "${gsdOutput}/DroughtImpact_raw4.xls", replace ctitle(`r(depvar)' - No controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
* (2) with population type controls, dep var in logs
tab type, gen(type)
tab reg_pess, gen(region)
diff ltc_imp [pw=pweight], period(t) treated(drought_SPI) cov(type*)
outreg2 using "${gsdOutput}/DroughtImpact_raw4.xls", append ctitle(`r(depvar)' - Population type controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
* (3) with pre-war region control as robustness
diff ltc_imp [pw=pweight], period(t) treated(drought_SPI) cov(type* region*)
outreg2 using "${gsdOutput}/DroughtImpact_raw4.xls", append ctitle(`r(depvar)' - Population type and regions controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
gen droughtxpost = drought_SPI*t
svy: reg ltc_imp t drought_SPI droughtxpost i.type i.reg_pess
* (4) with pop type, hhh gender, hhh edu, remit12m
tab hhh_edu, gen(educ)
diff ltc_imp [pw=pweight], period(t) treated(drought_SPI) cov(type* region* remit12m hhh_gender educ*)
outreg2 using "${gsdOutput}/DroughtImpact_raw4.xls", append ctitle(`r(depvar)' - Population type, regions, HHH edu and gender, remittances controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
* (5) With poor PPP_prob
diff poorPPP_prob [pw=pweight], period(t) treated(drought_SPI) 
outreg2 using "${gsdOutput}/DroughtImpact_raw4.xls", append ctitle(`r(depvar)' - No controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
* (6) PoorPPP_prob with controls 
diff poorPPP_prob [pw=pweight], period(t) treated(drought_SPI) cov(type* region* remit12m hhh_gender educ*)
outreg2 using "${gsdOutput}/DroughtImpact_raw4.xls", append ctitle(`r(depvar)' - Population type, regions, HHH edu and gender, remittances controls) addstat(Mean control t(0), r(mean_c0), Mean treated t(0), r(mean_t0), Diff t(0), r(diff0), Mean control t(1), r(mean_c1), Mean treated t(1), r(mean_t1), Diff t(1), r(diff1)) label excel keep(_diff) nocons
* (7) with continuous treatment
gen SPIxpost = SPI*t
svy: reg ltc_imp t SPI SPIxpost i.type i.reg_pess
outreg2 using "${gsdOutput}/DroughtImpact_raw4b.xls", replace ctitle(`r(depvar)' - Population type and regions controls, with continuous treatment)   label excel nocons

insheet using "${gsdOutput}/DroughtImpact_raw4.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheetreplace sheet("Raw_Data_4")
insheet using "${gsdOutput}/DroughtImpact_raw4b.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheetmodify sheet("Raw_Data_4") cell(A20)

* Unconditional values for comparison
use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
merge m:1 team strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", nogen assert(match master) keepusing(tc_imp)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
egen drought = group(t drought_SPI), label
gen ltc_imp = log(tc_imp)
la var ltc_imp "Log imputed core consumption"
tabout drought using "${gsdOutput}/DroughtImpact_raw4_additional.xls", svy sum c(mean poorPPP_prob lb ub) sebnone f(3) h2("Poor (prob) & Drought (SPI)") npos(col) replace
tabout drought using "${gsdOutput}/DroughtImpact_raw4_additional.xls", svy sum c(mean ltc_imp lb ub) sebnone f(3) h2("Log core consumption & Drought (SPI)") npos(col) append
tabout drought using "${gsdOutput}/DroughtImpact_raw4_additional.xls", svy sum c(mean tc_imp lb ub) sebnone f(3) h2("Core consumption & Drought (SPI)") npos(col) append
insheet using "${gsdOutput}/DroughtImpact_raw4_additional.xls", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheetreplace sheet("Raw_Data_4_additional") 

* Look at distribution of losses along the spectrum of being exposed to drought
use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
merge m:1 team strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", nogen assert(match master) keepusing(tc_core)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
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
merge 1:1 SPI using "${gsdTemp}/SPI_tc_imp_lpolyfit1.dta", nogen assert(match)
order SPI 
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheetreplace sheet("Raw_Data_5") firstrow(variables)

use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
merge m:1 team strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", nogen assert(match master) keepusing(tc_core)
gen pweight=weight_cons*hhsize
tabout SPI_cat  using "${gsdOutput}/DroughtImpact_raw5-2.xls" if t==0, svy sum c(mean tc_imp lb ub) sebnone f(3) h2("Drought Cat & consumption - W1") npos(col) replace
tabout SPI_cat  using "${gsdOutput}/DroughtImpact_raw5-2.xls" if t==1, svy sum c(mean tc_imp lb ub) sebnone f(3) h2("Drought Cat & consumption - W2") npos(col) append
insheet using "${gsdOutput}/DroughtImpact_raw5-2.xls", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheetmodify sheet("Raw_Data_5-2")
******************************************************************************** 
*Education 
use "${gsdData}/1-CleanInput/hhm_all.dta", clear
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
merge m:1 t team strata ea block hh using "${gsdData}/1-CleanInput/hh_all.dta", nogen assert(match) keepusing(hhh_gender hhh_edu type remit12m reg_pess)
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheetmodify sheet("Raw_Data_6-DID")


*Access to water and sanitation
*Labor market, sources of income, and remittances
tabout drought1 using "${gsdOutput}/DroughtImpact_raw2.xls", svy sum c(mean poorPPP_vulnerable_10_prob lb ub) sebnone f(3) h2(Drought and Vulnerability - Wave 1) replace
* Hunger
gen hunger_bin = hunger>1
la def lhunger_bin 0 "Never experienced food shortage" 1 "Experienced food shortage"
la val hunger_bin lhunger_bin
tabout drought1 using "${gsdOutput}/DroughtImpact_raw3.xls", svy sum c(mean hunger_bin lb ub) sebnone f(3) h2(Drought and Hunger - Wave 1) replace



* Put all created sheets into one excel document
foreach i of numlist 6/6 {
	insheet using "${gsdOutput}/DroughtImpact_raw`i'.xls", clear nonames tab
	export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheetreplace sheet("Raw_Data_`i'")
}

insheet using "${gsdOutput}/DroughtImpact_raw00.xls", clear nonames tab
export excel using "${gsdOutput}/DroughtImpact_Figures_v2.xlsx", sheetreplace sheet("Raw_Data_00")

********************************************************************************
*************** Simulations ****************************************************
********************************************************************************
clear
set obs 1000
gen hhid = _n
gen drought = (hhid>=50)
gen cons = runiform(0,1)
gen poor = cons<0.5
gen post = runiformint(0,1)
gen postxdrought = post*drought

* No drought effect expected
reg poor post drought postxdrought
reg cons post drought postxdrought

* Penalising drought-affected households
gen cons_drought = cons
replace cons_drought = cons*runiform(0.6, 0.8) if drought==1 & post==1
gen poor_drought = cons_drought<0.5

reg poor_drought post drought postxdrought
reg cons_drought post drought postxdrought

* Introducing pre-treatment differences
gen cons_drought1 = cons
replace cons_drought1 = cons*runiform(1.2, 1.4) if drought==1
replace cons_drought1 = cons_drought1*runiform(0.6, 0.8) if drought==1 & post==1
gen poor_drought1 = cons_drought1<0.5

reg poor_drought1 post drought postxdrought
reg cons_drought1 post drought postxdrought

mean cons_drought, over(drought)
mean cons_drought, over(post)
mean cons_drought, over(post drought)

* Try to model other characteristic that drives poverty independent of drought (e.g. conflict) 
gen conflict = runiformint(0,1)
gen cons_drought2 = cons_drought1*runiform(0.7, 0.8)*conflict
gen poor_drought2 = cons_drought2<0.5

reg poor_drought1 post drought postxdrought
reg poor_drought2 post drought postxdrought
reg poor_drought2 post drought postxdrought conflict
* effect comes back if you control for it

