* Prepare auxiliary data needed for analysis

clear all
set more off
set maxvar 10000
set seed 23081980 
set sortseed 11041985

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
gen drought_SPI = SPI_cat<0
la def ldrought_SPI 0 "Not affected" 1 "Drought affected", replace
la val drought_SPI ldrought_SPI
la var drought_SPI "Drought affected (moderately/severely/extremely drought affected per SPI)"
destring block, replace
save "${gsdData}/1-CleanTemp/Wave1_SPI.dta", replace

* Wave 2 HHs
shp2dta using "${gsdShared}\0-Auxiliary\Climate Data\SPI\spi_combined_HHs_Wave2.shp", data("${gsdTemp}/spi_combined_HHs_Wave2.dta") coor("${gsdTemp}/spi_combined_HHs_Wave2_coordinates.dta") replace
use "${gsdTemp}/spi_combined_HHs_Wave2.dta", clear
replace GRID_CODE = GRID_CODE/3
drop if GRID_CODE==0
collapse (mean) SPI=GRID_CODE, by(strata ea_reg ea interview_ type)
ren interview interview__id
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
tab ea_reg SPI_cat
gen drought_SPI = SPI_cat<0
la def ldrought_SPI 0 "Not affected" 1 "Drought affected", replace
la val drought_SPI ldrought_SPI
la var drought_SPI "Drought affected (moderately/severely/extremely drought affected per SPI)"
save "${gsdData}/1-CleanTemp/Wave2_SPI.dta", replace
merge 1:1 interview__id using "${gsdData}/0-RawTemp/Wave2_hh_coordinates.dta", assert(match) keepusing(lat* long*)
ren drought_SPI drought_spi
gen drought_SPI=drought_spi
gen ndrought_SPI = drought_spi==0
export delim ea_reg strata type lat_y long_x drought_SPI ndrought_SPI using "${gsdData}/0-RawTemp/Wave2_hhs_SPI.csv", replace
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
* save in slightly different form for mapping
use "${gsdTemp}/spi_combined_SOM0.dta", clear
gen SPI = GRID_CODE/3
gen SPI_cat = -3 if inrange(SPI, `r(min)', -2)
replace SPI_cat = -2 if SPI>-2 & SPI<=-1.5
replace SPI_cat = -1 if SPI>-1.5 & SPI<=-1
replace SPI_cat = 0 if SPI>-1 & SPI<1
replace SPI_cat = 1 if SPI>=1 & SPI<1.5
replace SPI_cat = 2 if SPI>=1.5 & SPI<2
replace SPI_cat = 3 if SPI>=2
export delim POINTID SPI SPI_cat using "${gsdData}/1-CleanTemp/SPI_drought_map.csv", replace


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
su NDVI_deviation, d
la var NDVI_deviation "NDVI % difference from pre-drought years (2012-2015)"
gen NDVI_drought_cat = 0 if NDVI_deviation>=0
replace NDVI_drought_cat = 1 if NDVI_deviation<0 & NDVI_deviation>=-10
replace NDVI_drought_cat = 2 if NDVI_deviation<-10 & NDVI_deviation>=-20
replace NDVI_drought_cat = 3 if NDVI_deviation<-20 & NDVI_deviation>=-30
replace NDVI_drought_cat = 4 if NDVI_deviation<-30 
la def lNDVI_drought_cat 0 "Not affected (NDVI deviation > 0)" 1 "Moderately affected (NDVI deviation 0% to -10%)" 2 "Highly Affected (NDVI deviation -10% to -20%)" 3 "Severely Affected (NDVI deviation -20% to -30%)" 3 "Extremely Affected (NDVI deviation <-30%)", replace
la val NDVI_drought_cat lNDVI_drought_cat
gen drought_NDVI = NDVI_drought_cat>1
la def ldrought_NDVI 0 "Not affected" 1 "Drought affected", replace
la val drought_NDVI ldrought_NDVI
destring block, replace
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

* Standardized Vegetation Index, based on NDVI data
use "${gsdShared}\0-Auxiliary\Climate Data\NDVI\NDVI_series.dta", clear
* Start building z-score using 2012-2015 as baseline average and standard deviation
rename grid_code_* NDVI_*
egen NDVI_mean = rowmean(NDVI_Jan_2012-NDVI_Dec_2015)
egen NDVI_SD = rowsd(NDVI_Jan_2012-NDVI_Dec_2015)
egen NDVI_rs = rowmean(NDVI_April_June_2016 NDVI_April_June_2017 NDVI_Oct_Dec_2016)
gen z_NDVI90 = (NDVI_90_days - NDVI_mean) / NDVI_SD
gen z_NDVI30 = (NDVI_30_days - NDVI_mean) / NDVI_SD
gen z_NDVI_rs = (NDVI_rs - NDVI_mean) / NDVI_SD
gen SVI30 = normal(z_NDVI30)
la var SVI30 "Standard Vegetation Index, last 30 days"
gen SVI90 = normal(z_NDVI90)
la var SVI90 "Standard Vegetation Index, last 90 days"
gen SVIrs = normal(z_NDVI_rs)
la var SVIrs "Standard Vegetation Index, combined rainy seasons"
keep SVI* pointid z*
export delim using "${gsdData}/1-CleanTemp/SVI.csv", replace
save "${gsdData}/1-CleanTemp/SVI.dta", replace

* Merge with household data and generate household-level SVI data
import delim "${gsdShared}\0-Auxiliary\Climate Data\NDVI\Wave1_SVI_key.txt", clear
merge m:1 pointid using "${gsdData}/1-CleanTemp/SVI.dta", assert(match using) keep(match) nogen
drop if SVI30==. & SVI90==. & SVIrs==.
collapse (mean) z* SVI*, by(team strata ea block hh)
* categorise
label define lSVI 1 "Very poor" 2 "Poor" 3 "Average" 4 "Good" 5 "Very good", replace
foreach v in 30 90 rs {
	gen SVI`v'_cat = 1 if inrange(SVI`v', 0, 0.05)
	replace SVI`v'_cat = 2 if SVI`v'>0.05 & SVI`v'<=0.25
	replace SVI`v'_cat = 3 if SVI`v'>0.25 & SVI`v'<=0.75 
	replace SVI`v'_cat = 4 if SVI`v'>0.75 & SVI`v'<=0.95 
	replace SVI`v'_cat = 5 if SVI`v'>0.95 & SVI`v'<=1
	la var SVI`v'_cat "SVI`v' category" 
	la val SVI`v'_cat lSVI
}

clear

* IPC Phase data 
import excel using "${gsdShared}\0-Auxiliary\IPC\IPC_Population.xlsx", clear firstrow
save "${gsdData}/1-CleanTemp/IPC_Population.dta", replace
