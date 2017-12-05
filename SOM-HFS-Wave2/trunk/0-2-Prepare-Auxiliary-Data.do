* Prepare auxiliary data needed for analysis

clear all
set more off
set maxvar 10000
set seed 23081980 
set sortseed 11041985

*Import ACLED data
* 2017 file
import excel "${gsdShared}\0-Auxiliary\Conflict\ACLED-All-Africa-File_20170101-to-20171014.xlsx", firstrow case(lower) clear
keep if year==2017 
keep if country=="Somalia"
drop admin3
destring longitude, replace 
save "${gsdTemp}\ACLED-2017.dta", replace
* Previous years
import excel "${gsdShared}\0-Auxiliary\Conflict\ACLED-SOM_1997to2016.xlsx", firstrow case(lower) clear
keep if inlist(year, 2015, 2016)
drop admin3
append using "${gsdTemp}\ACLED-2017.dta"
save "${gsdData}/1-CleanInput/ACLED.dta", replace
export delim "${gsdOutput}/ACLED.csv", replace


* Import and format rainfall data
* Wave 1
local lrain = "2016deyr 2017gu 2016gu 2016deyr2017gu combined"
foreach c in `lrain' {
	shp2dta using "${gsdShared}\0-Auxiliary\Climate Data\Wave1_precipitation_`c'.shp", data("${gsdTemp}/Wave1_precipitation_`c'.dta") coor("${gsdTemp}/Wave1_precipitation_`c'_coordinates.dta") replace
	use "${gsdTemp}/Wave1_precipitation_`c'.dta", clear
	cap ren grid_code GRID_CODE
	drop if GRID_CODE==0
	collapse (mean) precip_`c'=GRID_CODE, by(team strata ea block hh)
	la var precip_`c' "Precipitation difference from long-term average, `c' season"
	save "${gsdTemp}/Wave1_precipitation_`c'_corrected.dta", replace
}

use "${gsdTemp}/Wave1_precipitation_2016deyr_corrected.dta", clear
local lrain2 = "2017gu 2016gu 2016deyr2017gu combined"
foreach c in `lrain2' {
merge 1:1 team strata ea block hh using "${gsdTemp}/Wave1_precipitation_`c'_corrected.dta", assert(match) nogen
}
destring block, replace
replace precip_combined=precip_combined/3
gen drought1 = (precip_combined<-29)
la var drought1 "More than 29% less rain than long term average in three seasons combined"
gen drought2 = (precip_2016deyr<-50) 
la var drought2 "More than 50% less rain than long term average in 2016 Deyr season"
gen drought3 = (precip_2016deyr2017gu<-30)
la var drought3 "More than 30% less rain than long term average in 2016 Deyr and 2017 Gu seasons"
la def ldrought 0 "Non-affected" 1 "Affected"
la val drought3 ldrought
la val drought2 ldrought
la val drought1 ldrought
save "${gsdData}/1-CleanTemp/rainfall.dta", replace
* Create map of drought-affected HHs
use "${gsdData}/1-CleanInput/SHFS2016/hh_gps_identifiers.dta", clear
merge 1:1 team strata ea block hh using "${gsdData}/1-CleanTemp/rainfall.dta", assert(match) nogen
export delim using "${gsdData}/0-RawOutput/rainfall_gps_identifiers.csv", replace nolab

* Wave 2
local lrain = "2016deyr 2016deyr2017gu 2016gu 2017gu combined"
foreach c in `lrain' {
	shp2dta using "${gsdShared}\0-Auxiliary\Climate Data\Wave2_precipitation_`c'.shp", data("${gsdTemp}/Wave2_precipitation_`c'.dta") coor("${gsdTemp}/Wave2_precipitation_`c'_coordinates.dta") replace
	use "${gsdTemp}/Wave2_precipitation_`c'.dta", clear
	cap ren grid_code GRID_CODE
	drop if GRID_CODE==0
	replace Sel_MainFi = FID_ if Sel_MainFi==0
	collapse (mean) precip_`c'=GRID_CODE X=INSIDE_X Y=INSIDE_Y, by(Strata_ID Strata_Na PSU_ID Sel_MainFi)
	la var precip_`c' "Precipitation difference from long-term average, `c' season"
	save "${gsdTemp}/Wave2_precipitation_`c'_corrected.dta", replace
}

use "${gsdTemp}/Wave2_precipitation_2016deyr_corrected.dta", clear
merge 1:1 PSU_ID using "${gsdTemp}/Wave2_precipitation_2016deyr2017gu_corrected.dta", assert(match) nogen
merge 1:1 PSU_ID using "${gsdTemp}/Wave2_precipitation_2017gu_corrected.dta", assert(match) nogen
merge 1:1 PSU_ID using "${gsdTemp}/Wave2_precipitation_2016gu_corrected.dta", assert(match) nogen
merge 1:1 PSU_ID using "${gsdTemp}/Wave2_precipitation_combined_corrected.dta", assert(match) nogen
replace precip_combined=precip_combined/3
gen drought1 = (precip_combined<-29)
la var drought1 "More than 29% less rain than long term average in three seasons combined"
gen drought2 = (precip_2016deyr<-50) 
la var drought2 "More than 50% less rain than long term average in 2016 Deyr season"
gen drought3 = (precip_2016deyr2017gu<-30)
la var drought3 "More than 30% less rain than long term average in 2016 Deyr and 2017 Gu seasons"
la def ldrought 0 "Non-affected" 1 "Affected"
la val drought3 ldrought
la val drought2 ldrought
la val drought1 ldrought
save "${gsdData}/1-CleanTemp/rainfall_w2.dta", replace
* Create map of drought-affected HHs
export delim using "${gsdData}/0-RawOutput/rainfall_gps_identifiers_w2.csv", replace nolab


* Rainfall and NDVI timeseries
import excel using "${gsdShared}\0-Auxiliary\Climate Data\Rainfall_NDVI_timeseries.xlsx", clear firstrow case(lower) sheet("Combined")
collapse (mean) rainfall_level=rainfallmm rainfall_average rainfall_anomaly_1m=onemonthanomaly rainfall_anomaly_3m=threemonthsanomaly ndvi ndvi_average ndvi_anomaly=ndvianomaly, by(year month)
gen date = ym(year, month)
order date
format date %tm
save "${gsdData}/1-CleanTemp/rainfall_timeseries.dta", replace
