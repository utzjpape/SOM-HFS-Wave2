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

* SPI data 
* Wave 1 HHs
shp2dta using "${gsdShared}\0-Auxiliary\Climate Data\SPI\spi_combined_HHs.shp", data("${gsdTemp}/spi_combined_HHs.dta") coor("${gsdTemp}/spi_combined_HHs_coordinates.dta") replace
use "${gsdTemp}/spi_combined_HHs.dta", clear
replace GRID_CODE = GRID_CODE/3
drop if GRID_CODE==0
collapse (mean) SPI=GRID_CODE, by(team strata ea block hh)
su SPI, d
gen SPI_cat = -3 if inrange(SPI, `r(min)', -2)
replace SPI_cat = -2 if SPI>-2 & SPI<=-1.5
replace SPI_cat = -1 if SPI>-1.5 & SPI<=-1
replace SPI_cat = 0 if SPI>-1 & SPI<1
replace SPI_cat = 1 if SPI>=1 & SPI<1.5
replace SPI_cat = 2 if SPI>=1.5 & SPI<2
replace SPI_cat = 3 if SPI>=2
la def lSPI_cat -3 "Extremely dry (SPI<=-2)" -2 "Severely dry (SPI -1.5 to -1.99)" -1 "Moderately dry (SPI -1.0 to -1.49)" 0 "Near normal (SPI -.99 to +.99)" 1 "Moderately wet (SPI 1.0 to 1.49)" 2 "Very wet (SPI 1.5 to 1.99)" 3 "Extremely wet (SPI>=2)", replace
la val SPI_cat lSPI_cat
la var SPI_cat "SPI Category"
la var SPI "Standard Precipitation Index (SPI)"
tabstat SPI, by(SPI_cat) stats(mean min max N) 
tab team SPI_cat
save "${gsdData}/1-CleanTemp/Wave1_SPI.dta", replace
* All SOM
shp2dta using "${gsdShared}\0-Auxiliary\Climate Data\SPI\spi_combined_SOM0.shp", data("${gsdTemp}/spi_combined_SOM0.dta") coor("${gsdTemp}/spi_combined_SOM0_coordinates.dta") replace
use "${gsdTemp}/spi_combined_SOM0.dta", clear
replace GRID_CODE = GRID_CODE/3
drop if GRID_CODE==0
ren GRID_CODE SPI
su SPI, d
gen SPI_cat = -3 if inrange(SPI, `r(min)', -2)
replace SPI_cat = -2 if SPI>-2 & SPI<=-1.5
replace SPI_cat = -1 if SPI>-1.5 & SPI<=-1
replace SPI_cat = 0 if SPI>-1 & SPI<1
replace SPI_cat = 1 if SPI>=1 & SPI<1.5
replace SPI_cat = 2 if SPI>=1.5 & SPI<2
replace SPI_cat = 3 if SPI>=2
la def lSPI_cat -3 "Extremely dry (SPI<=-2)" -2 "Severely dry (SPI -1.5 to -1.99)" -1 "Moderately dry (SPI -1.0 to -1.49)" 0 "Near normal (SPI -.99 to +.99)" 1 "Moderately wet (SPI 1.0 to 1.49)" 2 "Very wet (SPI 1.5 to 1.99)" 3 "Extremely wet (SPI>=2)", replace
la val SPI_cat lSPI_cat
tabstat SPI, by(SPI_cat) stats(mean min max N) 
la var SPI_cat "SPI Category"
la var SPI "Standard Precipitation Index (SPI)"
drop _ID
save "${gsdData}/1-CleanTemp/SPI_SOM0.dta", replace


* NDVI data around Wave 1 HHs
shp2dta using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\Wave1_NDVI_HHs_Team1.shp", data("${gsdTemp}/Wave1_NDVI_Team1.dta") coor("${gsdTemp}/Wave1_NDVI_Team1_coordinates.dta") replace
shp2dta using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\Wave1_NDVI_HHs_Team2.shp", data("${gsdTemp}/Wave1_NDVI_Team2.dta") coor("${gsdTemp}/Wave1_NDVI_Team2_coordinates.dta") replace
shp2dta using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\Wave1_NDVI_HHs_Team3.shp", data("${gsdTemp}/Wave1_NDVI_Team3.dta") coor("${gsdTemp}/Wave1_NDVI_Team3_coordinates.dta") replace
use "${gsdTemp}/Wave1_NDVI_Team1.dta", clear
append using "${gsdTemp}/Wave1_NDVI_Team2.dta"
append using "${gsdTemp}/Wave1_NDVI_Team3.dta"
* correct mistake values
drop if grid_code==0
drop if grid_code>100
drop if grid_code<-100
collapse (mean) NDVI_deviation=grid_code, by(team strata ea block hh)
hist NDVI_deviation
su NDVI_deviation, d
la var NDVI_deviation "NDVI % difference from pre-drought years (2012-2015)"
*gen NDVI_drought_cat = 0 if NDVI_deviation>=0
*replace NDVI_drought_cat = 1 if NDVI_deviation<0 & NDVI_deviation>=-10
*replace NDVI_drought_cat = 2 if NDVI_deviation<-10 & NDVI_deviation>=-20
*replace NDVI_drought_cat = 3 if NDVI_deviation<-20 & NDVI_deviation>=-30
*replace NDVI_drought_cat = 4 if NDVI_deviation<-30 
*la def lNDVI_drought_cat 0 "Not affected" 1 "Slightly affected" 2 "Moderately affected" 3 "Severely Affected" 4 "Extremely Affected", replace
*gen drought_affected = 0 if NDVI_deviation>=0
*replace drought_affected = 1 if inrange(NDVI_deviation, -10, 0)
save "${gsdData}/1-CleanTemp/Wave1_NDVI.dta", replace


* NDVI full data
shp2dta using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\ndvi2017_points_SOM0_1000m.shp", data("${gsdTemp}/ndvi2017_points_SOM0_1000m.dta") coor("${gsdTemp}/ndvi2017_points_SOM0_1000m_coordinates.dta") replace
use "${gsdTemp}/ndvi2017_points_SOM0_1000m.dta", clear
drop if grid_code==0
drop if grid_code>100
drop if grid_code<-100
ren grid_code NDVI_deviation
la var NDVI_deviation "NDVI % difference from pre-drought years (2012-2015)"
save "${gsdData}/1-CleanTemp/NDVI_SOM0.dta", replace


* Rainfall and NDVI timeseries
import excel using "${gsdShared}\0-Auxiliary\Climate Data\Rainfall_NDVI_timeseries.xlsx", clear firstrow case(lower) sheet("Combined")
collapse (mean) rainfall_level=rainfallmm rainfall_average rainfall_anomaly_1m=onemonthanomaly rainfall_anomaly_3m=threemonthsanomaly ndvi ndvi_average ndvi_anomaly=ndvianomaly, by(year month)
gen date = ym(year, month)
order date
format date %tm
save "${gsdData}/1-CleanTemp/rainfall_timeseries.dta", replace
