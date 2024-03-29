* Drought Impact graphs and regressions

set more off
set seed 23081980 
set sortseed 11041955

*********************************************************
* Combine wave 1 and wave 2 data sets 
*********************************************************
* HH level dataset 
use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear
ren weight weight_unadjusted
ren weight_adj weight
ren reg_pess region
ren house_ownership tenure
append using "${gsdData}/1-CleanOutput/hh.dta", gen(t)
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
replace reg_pess = region if mi(reg_pess)
drop region
replace weight_cons = weight if mi(weight_cons)
ren weight weight_adj
recode tenure (1=1 "Own") (2=2 "Rent") (3/max=3 "Other"), gen(tenure1)
save "${gsdData}/1-CleanInput/hh_all.dta", replace
* HHM level dataset
use "${gsdData}/1-CleanInput/SHFS2016/hhm.dta", clear
ren weight weight_unadjusted
gen enrolled=edu_status==1 if inrange(age, 6, 17)
gen enrolled25 = edu_status==1 if inrange(age, 6, 25)
append using "${gsdData}/1-CleanOutput/hhm.dta", gen(t)
drop reg_pess
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
save "${gsdData}/1-CleanInput/hhm_all.dta", replace

use "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", clear
append using "${gsdData}/1-CleanTemp/hhq-poverty.dta", gen(t)
save "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty_all.dta", replace 

****************************************
****************** Maps ****************
****************************************
* Prepare maps data files
shp2dta using "${gsdShared}\0-Auxiliary\Administrative Maps\Som_Admbnda_Adm1_UNDP", database("${gsdTemp}\Som_Admbnda_Adm1_UNDP") coor("${gsdTemp}\Som_Admbnda_Adm1_UNDP_coordinates") replace
shp2dta using "${gsdShared}\0-Auxiliary\Administrative Maps\Som_Admbnda_Adm2_UNDP", database("${gsdTemp}\Som_Admbnda_Adm2_UNDP") coor("${gsdTemp}\Som_Admbnda_Adm2_UNDP_coordinates") replace
shp2dta using "${gsdShared}\0-Auxiliary\Administrative Maps\Wave1_Admin2", database("${gsdTemp}\Wave1_Admin2") coor("${gsdTemp}\Wave1_Admin2_coordinates") replace
shp2dta using "${gsdShared}\0-Auxiliary\Administrative Maps\Wave2_Admin2", database("${gsdTemp}\Wave2_Admin2") coor("${gsdTemp}\Wave2_Admin2_coordinates") replace
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetreplace sheet("Raw_Rainfall_TS") first(variables)

** IPC classification over time ** 
use "${gsdData}/1-CleanTemp/IPC_Population.dta", clear
gen projection = Date0!=Date1
gen date = (Date1 + Date0)/2
format date %td
drop *1 *0
order date total_* projection
sort date
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheet("Raw_IPC") sheetreplace firstrow(variables)

** SPI ** 
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheet("Raw_Drought_Indicators") sheetmodify cell(D1) firstrow(variables)
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheet("Raw_Drought_Indicators") sheetmodify cell(G1) firstrow(variables)

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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheet("Raw_Drought_Indicators") sheetmodify cell(A1) firstrow(variables)
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
* Correlates of drought-affected households
* Wave 1
use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_NDVI.dta", assert(match) nogen
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
gen x=1
la var x "Proportion"
tabout drought_SPI using "${gsdOutput}/DroughtImpact_raw0.xls", svy percent c(col) npos(col) sebnone h2(drought SPI Affected - Wave 1) replace
tabout drought_NDVI using "${gsdOutput}/DroughtImpact_raw0.xls", svy percent c(col) npos(col) sebnone h2(Drought NDVI Affected - Wave 1) append
gen nodrought_SPI=drought_SPI==0
gen nodrought_NDVI=drought_NDVI==0
tabout reg_pess using "${gsdOutput}/DroughtImpact_raw0.xls", sum c(sum  drought_SPI sum  nodrought_SPI) sebnone h2(drought_SPI Affected by pre-war region) append
tabout reg_pess using "${gsdOutput}/DroughtImpact_raw0.xls", sum c(sum  drought_NDVI sum  nodrought_NDVI) sebnone h2(drought NDVI Affected by pre-war region) append
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
use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", assert(match using) keep(match) keepusing(SPI_cat drought_SPI)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
egen drought = group(t drought_SPI), label

* Drop IDPs
drop if type==3
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
use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", assert(match using) keep(match) keepusing(SPI_cat drought_SPI)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata)
egen drought = group(t drought_SPI), label
drop if type==3 
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetreplace sheet("Raw_Data_3") first(variables)

* urban
use "${gsdData}/1-CleanInput/hh_all.dta", clear
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetreplace sheet("Raw_Data_3_urban") first(variables)

* rural
use "${gsdData}/1-CleanInput/hh_all.dta", clear
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetreplace sheet("Raw_Data_3_rural") first(variables)

********************************************************************************
********************* Diff-in-Diff estimation **********************************
********************************************************************************
use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", nogen keep(match) keepusing(SPI_cat drought_SPI)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty_all.dta", nogen keep(match master) keepusing(tc_core)
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", keep(match) nogen
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)

drop if type==3
drop if migr_idp==1
* We want to run the estimation with dep var in logs, so let's look at that
*hist tc_imp 
*hist tc_core
*graph export "${gsdOutput}/tc_imp_hist.png", replace
gen ltc_core = log(tc_core)
la var ltc_core "Log imputed core consumption"
*hist ltc_core
*graph export "${gsdOutput}/ltc_imp_hist.png", replace

/* Checking a few correlates
svy: reg tc_core hhh_gender
svy: reg drought_SPI hhh_gender
* The above two seem to indicate that hhh_gender should be left out
*svy: reg tc_imp i.hhh_edu
*svy: reg drought_SPI i.hhh_edu
svy: reg tc_core pliteracy 
svy: reg drought_SPI pliteracy
* These above two are good
svy: reg tc_core remit12m
svy: reg drought_SPI remit12m
* the above also fine
tab tenure1, gen(ten)
foreach i in 1 2 3 {
	svy: reg tc_core ten`i'
	svy: reg drought_SPI ten`i'
	drop ten`i'
}
* probably not worth including tenure
tab floor_material, gen(fm)
foreach i of numlist 1/5 {
	svy: reg tc_core fm`i'
	svy: reg drought_SPI fm`i'
	drop fm`i'
}
* floor material should probably go in
svy: reg tc_core i.roof_material
svy: reg drought_SPI i.roof_material
* roof material largely related to tc_core and largely unrelated to drought, so makes sense to include
svy: reg tc_core pgender
svy: reg drought_SPI pgender
* include pgender
*/
*svy: reg tc_core fatalities
*svy: reg drought_SPI hhsize

* Regressions 
* Poverty and consumption *
gen droughtxpost = drought_SPI*t
la var droughtxpost "DD Estimator"
gen drought_SPI1 = SPI_cat<-1
gen droughtxpost1 = drought_SPI1*t
gen rural=type==2
gen urban=type==1
gen total=1
gen fatxdrought = drought_SPI*fatalities
global controls rural hhsize fatalities fatxdrought pliteracy remit12m hhh_gender i.tenure1 pgender i.floor_material i.roof_material 


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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetreplace sheet("Raw_Data_4")
insheet using "${gsdOutput}/DroughtImpact_raw4_urban.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetmodify sheet("Raw_Data_4") cell(A17)
insheet using "${gsdOutput}/DroughtImpact_raw4_rural.txt", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetmodify sheet("Raw_Data_4") cell(A33)


/* Unconditional values for comparison
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetreplace sheet("Raw_Data_4_additional") 
*/
* Look at distribution of losses along the spectrum of being exposed to drought
use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge 1:1 t strata ea block hh using "${gsdData}/1-CleanTemp/SPI_w1w2.dta", assert(match using) keep(match) keepusing(SPI_cat drought_SPI)
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty_all.dta", nogen assert(match master) keepusing(tc_core)
gen pweight=weight_cons*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
drop if type==3
drop if migr_idp==1
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetreplace sheet("Raw_Data_5") firstrow(variables)

use "${gsdData}/1-CleanInput/hh_all.dta", clear
merge m:1 team strata ea block hh using "${gsdData}/1-CleanTemp/Wave1_SPI.dta", nogen assert(match)
merge m:1 team strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hhq-poverty.dta", nogen assert(match master) keepusing(tc_core)
gen pweight=weight_cons*hhsize
tabout SPI_cat  using "${gsdOutput}/DroughtImpact_raw5-2.xls" if t==0, svy sum c(mean tc_imp lb ub) sebnone f(3) h2("Drought Cat & consumption - W1") npos(col) replace
tabout SPI_cat  using "${gsdOutput}/DroughtImpact_raw5-2.xls" if t==1, svy sum c(mean tc_imp lb ub) sebnone f(3) h2("Drought Cat & consumption - W2") npos(col) append
insheet using "${gsdOutput}/DroughtImpact_raw5-2.xls", clear
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetmodify sheet("Raw_Data_5-2")
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
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetmodify sheet("Raw_Data_6-DID")


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
	export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetreplace sheet("Raw_Data_`i'")
}

insheet using "${gsdOutput}/DroughtImpact_raw00.xls", clear nonames tab
export excel using "${gsdOutput}/DroughtImpact_Figures_v4.xlsx", sheetreplace sheet("Raw_Data_00")

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

