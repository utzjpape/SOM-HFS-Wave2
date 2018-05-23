* Prepare auxiliary data needed for analysis

clear all
set more off
set maxvar 10000
set seed 23081980 
set sortseed 11041985

* Prepare wave 1 and wave 2 household GPS positions
use "${gsdData}/0-RawTemp/Wave2_hh_coordinates.dta", clear
keep if inlist(type,1,2)
export delim interview__id region strata ea block hh lat_y long_x type using "${gsdOutput}/Wave2_hh_coordinates.csv", replace

* ==============================================================================
* SPI related indicators
* ==============================================================================
* SPI = SPI from Gu 2016 + Deyr 2016 + Gu 2017
* Wave 1 HHs
import delim using "${gsdShared}\0-Auxiliary\Climate Data\SPI\spi_combined_HHs.txt", clear case(preserve)
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
import delim using "${gsdShared}\0-Auxiliary\Climate Data\SPI\spi_combined_HHs_Wave2.txt", clear case(preserve)
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
drop strata ea_reg
merge 1:1 interview__id using "${gsdData}/0-RawTemp/Wave2_hh_coordinates.dta",  nogen keepusing(region strata ea block hh lat_y long_x) assert(match master) keep(match)
preserve
drop interview__id lat_y long_x 
save "${gsdData}/1-CleanTemp/Wave2_SPI.dta", replace
restore
ren drought_SPI drought_spi
gen drought_SPI=drought_spi
gen ndrought_SPI = drought_spi==0
export delim region strata ea block hh lat_y long_x drought_SPI ndrought_SPI using "${gsdData}/0-RawTemp/Wave2_hhs_SPI.csv", replace
* Append wave 1 and wave 2 data
use "${gsdData}/1-CleanTemp/Wave1_SPI.dta", clear
append using "${gsdData}/1-CleanTemp/Wave2_SPI.dta", gen(t)
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
drop type region
gen cutoff = -1.5
replace cutoff = 0.5 if t==0
gen step = 0.1
save "${gsdData}/1-CleanTemp/SPI_w1w2.dta", replace

* All SOM
/*
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
su SPI
gen SPI_cat = -3 if inrange(SPI, `r(min)', -2)
replace SPI_cat = -2 if SPI>-2 & SPI<=-1.5
replace SPI_cat = -1 if SPI>-1.5 & SPI<=-1
replace SPI_cat = 0 if SPI>-1 & SPI<1
replace SPI_cat = 1 if SPI>=1 & SPI<1.5
replace SPI_cat = 2 if SPI>=1.5 & SPI<2
replace SPI_cat = 3 if SPI>=2
export delim POINTID SPI SPI_cat using "${gsdData}/1-CleanTemp/SPI_drought_map.csv", replace
*/

* Alternative drought assignments based on SPI
* SPI1 = SPI from Deyr 2016 + Gu 2017
import delim using "${gsdShared}\0-Auxiliary\Climate Data\SPI\Wave1_SPI_2016deyr2017gu.txt", clear case(preserve)
drop if GRID_CODE==0
replace GRID_CODE = GRID_CODE/2
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
ren SPI SPI1
ren SPI_cat SPI1_cat
tab team SPI1_cat
gen drought_SPI1 = -SPI1
*la def ldrought_SPI 0 "Not affected" 1 "Drought affected", replace
*la val drought_SPI1 ldrought_SPI
la var drought_SPI1 "Drought affected (moderately/severely/extremely drought affected per SPI)"
destring block, replace
save "${gsdData}/1-CleanTemp/Wave1_SPI1.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\SPI\Wave2_SPI_2016deyr2017gu.txt", clear case(preserve)
drop if GRID_CODE==0
replace GRID_CODE=GRID_CODE/2
collapse (mean) SPI=GRID_CODE, by(strata ea block hh)
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
ren SPI SPI1 
ren SPI_cat SPI1_cat
drop strata
merge 1:1 ea block hh using "${gsdData}/0-RawTemp/Wave2_hh_coordinates.dta", nogen keepusing(strata type) assert(match using) keep(match)
gen drought_SPI1 = -SPI1
*la def ldrought_SPI 0 "Not affected" 1 "Drought affected", replace
*la val drought_SPI1 ldrought_SPI
la var drought_SPI1 "Drought affected (moderately/severely/extremely drought affected per SPI)"
save "${gsdData}/1-CleanTemp/Wave2_SPI1.dta", replace
* Append wave 1 and wave 2 data
use "${gsdData}/1-CleanTemp/Wave1_SPI1.dta", clear
append using "${gsdData}/1-CleanTemp/Wave2_SPI1.dta", gen(t)
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
gen cutoff=-2.6
replace cutoff=0 if t==0
gen step = 0.2
save "${gsdData}/1-CleanTemp/SPI1_w1w2.dta", replace

* SPI3 = SPI from Deyr 2016
import delim using "${gsdShared}\0-Auxiliary\Climate Data\SPI\Wave1_SPI_2016deyr.txt", clear case(preserve)
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
ren SPI SPI3
tab team SPI_cat
ren SPI_cat SPI3_cat
gen drought_SPI3 = SPI3_cat<-1
la def ldrought_SPI 0 "Not affected" 1 "Drought affected", replace
la val drought_SPI3 ldrought_SPI
la var drought_SPI3 "Drought affected (moderately/severely/extremely drought affected per SPI)"
destring block, replace
save "${gsdData}/1-CleanTemp/Wave1_SPI3.dta", replace
* wave2
import delim using "${gsdShared}\0-Auxiliary\Climate Data\SPI\Wave2_SPI_2016deyr.txt", clear case(preserve)
drop if GRID_CODE==0
collapse (mean) SPI=GRID_CODE, by(strata ea block hh)
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
ren SPI SPI3 
ren SPI_cat SPI3_cat
drop strata
merge 1:1 ea block hh using "${gsdData}/0-RawTemp/Wave2_hh_coordinates.dta", nogen keepusing(strata type) assert(match using) keep(match)
gen drought_SPI3 = SPI3_cat<-1
la def ldrought_SPI 0 "Not affected" 1 "Drought affected", replace
la val drought_SPI3 ldrought_SPI
la var drought_SPI3 "Drought affected (moderately/severely/extremely drought affected per SPI)"
save "${gsdData}/1-CleanTemp/Wave2_SPI3.dta", replace
* Append wave 1 and wave 2 data
use "${gsdData}/1-CleanTemp/Wave1_SPI3.dta", clear
append using "${gsdData}/1-CleanTemp/Wave2_SPI3.dta", gen(t)
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
gen cutoff=-2.8
replace cutoff=0 if t==0
gen step = 0.2
save "${gsdData}/1-CleanTemp/SPI3_w1w2.dta", replace

* SPI2 = SPI from Gu 2017
* Wave 1 HHs
import delim using "${gsdShared}\0-Auxiliary\Climate Data\SPI\Wave1_SPI_2017gu.txt", clear case(preserve)
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
ren SPI SPI2
tab team SPI_cat
ren SPI_cat SPI2_cat
gen drought_SPI2 = SPI2_cat<0
la def ldrought_SPI 0 "Not affected" 1 "Drought affected", replace
la val drought_SPI2 ldrought_SPI
la var drought_SPI2 "Drought affected (moderately/severely/extremely drought affected per SPI)"
destring block, replace
save "${gsdData}/1-CleanTemp/Wave1_SPI2.dta", replace
* wave2
import delim using "${gsdShared}\0-Auxiliary\Climate Data\SPI\Wave2_SPI_2017gu.txt", clear case(preserve)
drop if GRID_CODE==0
collapse (mean) SPI=GRID_CODE, by(strata ea block hh)
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
drop strata
merge 1:1 ea block hh using "${gsdData}/0-RawTemp/Wave2_hh_coordinates.dta", nogen keepusing(strata type) assert(match using) keep(match)
ren SPI SPI2
ren SPI_cat SPI2_cat
gen drought_SPI2 = SPI2_cat<-1
la def ldrought_SPI 0 "Not affected" 1 "Drought affected", replace
la val drought_SPI2 ldrought_SPI
la var drought_SPI2 "Drought affected (moderately/severely/extremely drought affected per SPI)"
save "${gsdData}/1-CleanTemp/Wave2_SPI2.dta", replace
* Append wave 1 and wave 2 data
use "${gsdData}/1-CleanTemp/Wave1_SPI2.dta", clear
append using "${gsdData}/1-CleanTemp/Wave2_SPI2.dta", gen(t)
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt 
drop type 
gen cutoff=0.4
replace cutoff=-2.4 if t==0
gen step=0.2
save "${gsdData}/1-CleanTemp/SPI2_w1w2.dta", replace

* ==============================================================================
* NDVI-based drought indicators
* ==============================================================================
* Wave 1 HHs
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\W1_HHs_2016deyr.txt", clear
drop if grid_code==0
drop if grid_code>50
drop if grid_code<-100
collapse (mean) NDVI=grid_code, by(team strata ea block hh)
su NDVI, d
destring block, replace
save "${gsdTemp}/Wave1_2016deyr_NDVI.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\W1_HHs_2017gu.txt", clear
drop if grid_code==0
drop if grid_code>50
drop if grid_code<-100
collapse (mean) NDVI=grid_code, by(team strata ea block hh)
su NDVI, d
destring block, replace
save "${gsdTemp}/Wave1_2017gu_NDVI.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\W1_HHs_2016gu.txt", clear
drop if grid_code==0
drop if grid_code>50
drop if grid_code<-100
collapse (mean) NDVI=grid_code, by(team strata ea block hh)
su NDVI, d
destring block, replace
save "${gsdTemp}/Wave1_2016gu_NDVI.dta", replace


* Wave 2 HHs
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\W2_urbanHHs_2016deyr.txt", clear
drop if grid_code==0
drop if grid_code>50
drop if grid_code<-100
collapse (mean) NDVI=grid_code, by(strata ea block hh)
su NDVI, d
save "${gsdTemp}/W2_urban_2016deyr_NDVI.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\W2_ruralHHs_2016deyr.txt", clear
drop if grid_code==0
drop if grid_code>50
drop if grid_code<-100
collapse (mean) NDVI=grid_code, by(strata ea block hh)
su NDVI, d
save "${gsdTemp}/W2_rural_2016deyr_NDVI.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\W2_urbanHHs_2017gu.txt", clear
drop if grid_code==0
drop if grid_code>50
drop if grid_code<-100
collapse (mean) NDVI=grid_code, by(strata ea block hh)
su NDVI, d
save "${gsdTemp}/W2_urban_2017gu_NDVI.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\W2_ruralHHs_2017gu.txt", clear
drop if grid_code==0
drop if grid_code>50
drop if grid_code<-100
collapse (mean) NDVI=grid_code, by(strata ea block hh)
su NDVI, d
save "${gsdTemp}/W2_rural_2017gu_NDVI.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\W2_urbanHHs_2016gu.txt", clear
drop if grid_code==0
drop if grid_code>50
drop if grid_code<-100
collapse (mean) NDVI=grid_code, by(strata ea block hh)
su NDVI, d
save "${gsdTemp}/W2_urban_2016gu_NDVI.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\W2_ruralHHs_2016gu.txt", clear
drop if grid_code==0
drop if grid_code>50
drop if grid_code<-100
collapse (mean) NDVI=grid_code, by(strata ea block hh)
su NDVI, d
save "${gsdTemp}/W2_rural_2016gu_NDVI.dta", replace

* NDVI3
use "${gsdTemp}/W2_urban_2016deyr_NDVI.dta", clear
append using "${gsdTemp}/W2_rural_2016deyr_NDVI.dta"
drop strata
merge 1:1 ea block hh using "${gsdData}/0-RawTemp/Wave2_hh_coordinates.dta", nogen keepusing(strata) assert(match using) keep(match)
append using "${gsdTemp}/Wave1_2016deyr_NDVI.dta", gen(temp)
gen t=temp==0
drop temp
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt
tabstat NDVI, by(t) stats(p5 p10 p25 median mean p75 p90)
ren NDVI NDVI3
la var NDVI3 "NDVI, 2016 Deyr"
save "${gsdTemp}/NDVI_2016deyr_w1w2.dta", replace
gen NDVI3r = -NDVI3
zscore NDVI3r
gen drought_NDVI3 = z_NDVI3r
drop NDVI3 
gen NDVI3 = z_NDVI3r
drop NDVI3r z_NDVI3r
*la def ldrought_NDVI 0 "Not affected" 1 "Drought affected", replace
*la val drought_NDVI3 ldrought_NDVI
*la var drought_NDVI3 "Drought affected (per NDVI)"
gen NDVI3_cat=.
gen cutoff = -7
replace cutoff = -20 if t==0
gen step=1
save "${gsdData}/1-CleanTemp/NDVI3_w1w2.dta", replace
* NDVI2 
use "${gsdTemp}/W2_urban_2017gu_NDVI.dta", clear
append using "${gsdTemp}/W2_rural_2017gu_NDVI.dta"
drop strata
merge 1:1 ea block hh using "${gsdData}/0-RawTemp/Wave2_hh_coordinates.dta", nogen keepusing(strata) assert(match using) keep(match)
append using "${gsdTemp}/Wave1_2017gu_NDVI.dta", gen(temp)
gen t=temp==0
drop temp
la def lt 0 "Wave1" 1 "Wave2", replace
la val t lt
tabstat NDVI, by(t) stats(p5 p10 p25 median mean p75)
ren NDVI NDVI2 
la var NDVI2 "NDVI, 2017 Gu"
gen NDVI2r = -NDVI2
zscore NDVI2r
gen drought_NDVI2 = z_NDVI2r
ren NDVI2 NDVI2_org
gen NDVI2 = z_NDVI2r
drop NDVI2r z_NDVI2r
*la def ldrought_NDVI 0 "Not affected" 1 "Drought affected", replace
*la val drought_NDVI2 ldrought_NDVI
gen NDVI2_cat = .
gen cutoff = -1
replace cutoff = -19 if t==0
gen step=1
la var drought_NDVI2 "Drought affected (per NDVI)"
save "${gsdData}/1-CleanTemp/NDVI2_w1w2.dta", replace
* NDVI1
drop drought_NDVI2 cutoff step NDVI2
merge 1:1 strata ea block hh using "${gsdTemp}/NDVI_2016deyr_w1w2.dta", assert(match) nogen keepusing(NDVI*)
egen NDVI1 = rowmean(NDVI2_org NDVI3)
drop NDVI2_org NDVI3
tabstat NDVI1, by(t) stats(p5 p10 p25 median mean p75)
gen NDVI1r = -NDVI1
zscore NDVI1r
gen drought_NDVI1 = z_NDVI1r
ren NDVI1 NDVI1_org
gen NDVI1 = z_NDVI1r
drop NDVI1r z_NDVI1r
*la def ldrought_NDVI 0 "Not affected" 1 "Drought affected", replace
*la val drought_NDVI1 ldrought_NDVI
la var drought_NDVI1 "Drought affected, NDVI 2016 Deyr + 2017 Gu"
gen NDVI1_cat = .
gen cutoff = -1
replace cutoff = -17 if t==0
gen step=1
save "${gsdData}/1-CleanTemp/NDVI1_w1w2.dta", replace 
preserve
keep if t==0 
collapse (mean) NDVI1_org, by(strata ea block hh)
save "${gsdData}/1-CleanTemp/Wave1_NDVI1.dta", replace
restore
keep if t==1
collapse (mean) NDVI1_org, by(strata ea block hh)
save "${gsdData}/1-CleanTemp/Wave2_NDVI1.dta", replace


* Rainfall and NDVI timeseries
import excel using "${gsdShared}\0-Auxiliary\Climate Data\Rainfall_NDVI_timeseries.xlsx", clear firstrow case(lower) sheet("Combined")
collapse (mean) rainfall_level=rainfallmm rainfall_average rainfall_anomaly_1m=onemonthanomaly rainfall_anomaly_3m=threemonthsanomaly ndvi ndvi_average ndvi_anomaly=ndvianomaly, by(year month)
gen date = ym(year, month)
order date
format date %tm
save "${gsdData}/1-CleanTemp/rainfall_timeseries.dta", replace

* NDVI long-term data
foreach k in "Awdal" "Bakool" "Banadir" "Bari" "Bay" "Galgaduud" "Gedo" "Hiran" "JubbadaDhexe" "JubbadaHoose" "Mudug" "Nugaal" "Sanaag" "ShabeellahaDhexe" "ShabeellahaHoose" "Sool" "Togdheer" "Woqooyi" {
	

	import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI/`k'_series.txt", clear
	keep if year==2017
	collapse (mean) average, by(year month)
	reshape wide average, j(month) i(year)
	* rainy season average
	egen NDVI_av_gu = rowmean(average4 average5 average6)
	la var NDVI_av_gu "NDVI 2002-2012 average, Gu rainy season"
	egen NDVI_av_deyr = rowmean(average10 average11 average12)
	la var NDVI_av_deyr "NDVI 2002-2012 average, Deyr rainy season"
	egen NDVI_av_rs = rowmean(average4 average5 average6 average10 average11 average12)
	la var NDVI_av_rs "NDVI 2002-2012 average, Gu+Deyr rainy season"
	egen NDVI_av_yr = rowmean(average*)
	la var NDVI_av_yr "NDVI 2002-2012 average, full year"
	drop year
	gen str reg = "`k'"
	save "${gsdTemp}/`k'_series.dta", replace
}
use "${gsdTemp}/Awdal_series.dta", clear
foreach j in "Bakool" "Banadir" "Bari" "Bay" "Galgaduud" "Gedo" "Hiran" "JubbadaDhexe" "JubbadaHoose" "Mudug" "Nugaal" "Sanaag" "ShabeellahaDhexe" "ShabeellahaHoose" "Sool" "Togdheer" "Woqooyi" {
	append using  "${gsdTemp}/`j'_series.dta"
}
gen reg_pess = 1 if reg=="Awdal"
replace reg_pess = 2 if reg=="Bakool"
replace reg_pess = 3 if reg=="Banadir"
replace reg_pess = 4 if reg=="Bari"
replace reg_pess = 5 if reg=="Bay"
replace reg_pess = 6 if reg=="Galgaduud"
replace reg_pess = 7 if reg=="Gedo"
replace reg_pess = 8 if reg=="Hiran"
replace reg_pess = 9 if reg=="JubbadaDhexe"
replace reg_pess = 10 if reg=="JubbadaHoose"
replace reg_pess = 11 if reg=="Mudug"
replace reg_pess = 12 if reg=="Nugaal"
replace reg_pess = 13 if reg=="Sanaag"
replace reg_pess = 14 if reg=="ShabeellahaDhexe"
replace reg_pess = 15 if reg=="ShabeellahaHoose"
replace reg_pess = 16 if reg=="Sool"
replace reg_pess = 17 if reg=="Togdheer"
replace reg_pess = 18 if reg=="Woqooyi"
save "${gsdData}/1-CleanTemp/NDVI_average_series.dta", replace

* SPI long-term data
foreach k in "Awdal" "Bakool" "Banadir" "Bari" "Bay" "Galgaduud" "Gedo" "Hiraan" "JubbadaDhexe" "JubbadaHoose" "Mudug" "Nugaal" "Sanaag" "ShabeellahaDhexe" "ShabeellahaHoose" "Sool" "Togdheer" "Woqooyi" {
	

	import delim using "${gsdShared}\0-Auxiliary\Climate Data\SPI/`k'_series.txt", clear
	keep if year==2017
	ren averagemm average
	collapse (mean) average, by(year month)
	reshape wide average, j(month) i(year)
	* rainy season average
	egen SPI_av_gu = rowmean(average4 average5 average6)
	la var SPI_av_gu "SPI 2002-2012 average, Gu rainy season"
	egen SPI_av_deyr = rowmean(average10 average11 average12)
	la var SPI_av_deyr "SPI 2002-2012 average, Deyr rainy season"
	egen SPI_av_rs = rowmean(average4 average5 average6 average10 average11 average12)
	la var SPI_av_rs "SPI 2002-2012 average, Gu+Deyr rainy season"
	egen SPI_av_yr = rowmean(average*)
	la var SPI_av_yr "SPI 2002-2012 average, full year"
	drop year
	gen str reg = "`k'"
	save "${gsdTemp}/SPI_`k'_series.dta", replace
}
use "${gsdTemp}/SPI_Awdal_series.dta", clear
foreach j in "Bakool" "Banadir" "Bari" "Bay" "Galgaduud" "Gedo" "Hiraan" "JubbadaDhexe" "JubbadaHoose" "Mudug" "Nugaal" "Sanaag" "ShabeellahaDhexe" "ShabeellahaHoose" "Sool" "Togdheer" "Woqooyi" {
	append using  "${gsdTemp}/SPI_`j'_series.dta"
}
gen reg_pess = 1 if reg=="Awdal"
replace reg_pess = 2 if reg=="Bakool"
replace reg_pess = 3 if reg=="Banadir"
replace reg_pess = 4 if reg=="Bari"
replace reg_pess = 5 if reg=="Bay"
replace reg_pess = 6 if reg=="Galgaduud"
replace reg_pess = 7 if reg=="Gedo"
replace reg_pess = 8 if reg=="Hiraan"
replace reg_pess = 9 if reg=="JubbadaDhexe"
replace reg_pess = 10 if reg=="JubbadaHoose"
replace reg_pess = 11 if reg=="Mudug"
replace reg_pess = 12 if reg=="Nugaal"
replace reg_pess = 13 if reg=="Sanaag"
replace reg_pess = 14 if reg=="ShabeellahaDhexe"
replace reg_pess = 15 if reg=="ShabeellahaHoose"
replace reg_pess = 16 if reg=="Sool"
replace reg_pess = 17 if reg=="Togdheer"
replace reg_pess = 18 if reg=="Woqooyi"
save "${gsdData}/1-CleanTemp/SPI_average_series.dta", replace


* SOM NDVI
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\2016deyrSOM0.txt", clear 
ren grid_code NDVI_2016deyr
save "${gsdTemp}/2016deyrSOM0.dta", replace
import delim using "${gsdShared}\0-Auxiliary\Climate Data\NDVI\2017guSOM0.txt", clear 
ren grid_code NDVI_2017gu 
merge 1:1 pointid using "${gsdTemp}/2016deyrSOM0.dta", assert(match) nogen
drop if NDVI_2016deyr==0
drop if NDVI_2016deyr>50
drop if NDVI_2016deyr<-100
drop if NDVI_2017gu==0
drop if NDVI_2017gu>50
drop if NDVI_2017gu<-100
egen NDVI1_SOM0 = rowmean(NDVI*)
save "${gsdData}/1-CleanTemp/NDVI1_SOM0.dta", replace

* IPC Phase data 
import excel using "${gsdShared}\0-Auxiliary\IPC\IPC_Population.xlsx", clear firstrow
save "${gsdData}/1-CleanTemp/IPC_Population.dta", replace

* ACLED Conflict data
import excel using "${gsdShared}\0-Auxiliary\Conflict\ACLED_SOM-2015-20180127_SOM2.xls", clear firstrow
* a bit of cleaning
drop OBJECTID Join_Count TARGET_FID JOIN_FID Shape_Leng ValidTo validOn date admin1 admin2 admin3 OBJECTID_1 admin2RefN admin2AltN admin1Pcod admin2Al_1
save "${gsdData}/1-CleanTemp/ACLED-series.dta", replace
* select dates and collaspe: beginning wave 1 to beginning of Wave 2
gen x=1
collapse (sum) events=x fatalities, by(admin2Name event_type)
save "${gsdData}/1-CleanTemp/ACLED-collapsed.dta", replace
use "${gsdData}/1-CleanTemp/ACLED-series.dta", clear
* just pre-wave 1
drop if event_type=="Headquarters or base established"
drop if event_type=="Non-violent transfer of territory"
drop if event_date>td(15mar2016)
drop if event_date<td(15jun2015)
gen x=1
collapse (sum) events=x fatalities, by(admin2Name)
save "${gsdData}/1-CleanTemp/ACLED-collapsed_w1.dta", replace
* pre wave 2
use "${gsdData}/1-CleanTemp/ACLED-series.dta", clear
drop if event_type=="Headquarters or base established"
drop if event_type=="Non-violent transfer of territory"
drop if event_date>td(15dec2017)
drop if event_date<td(15mar2017)
gen x=1
collapse (sum) events=x fatalities, by(admin2Name)
save "${gsdData}/1-CleanTemp/ACLED-collapsed_w2.dta", replace


* SOM2 (Districts) asssignment to Wave1 and Wave2 households
* Wave 1
import excel using "${gsdShared}\0-Auxiliary\Administrative Maps\Wave1_Admin2.xls", clear firstrow
drop FID_Wave1_ FID FID_Som_Ad OID_ OBJECTID_1 admin2RefN admin2AltN admin2AltN admin2Al_1 admin1Name admin1Pcod admin0Name date validOn ValidTo Shape_Leng Shape_Area latx longx accx enum
replace admin2Name="Banadir" if team==2
drop team
save "${gsdData}/1-CleanTemp/Wave1_Admin2.dta", replace

import excel using "${gsdShared}\0-Auxiliary\Administrative Maps\Wave2_Admin2.xls", clear firstrow
drop FID OBJECTID Join_Count TARGET_FID JOIN_FID lat_y long_x OBJECTID_1 admin2RefN admin2RefN admin2AltN admin2Al_1 admin1Name admin1Pcod admin0Name admin0Pcod date Shape_Leng validOn ValidTo
ren interview_ interview__id
replace admin2Name="Banadir" if ea_reg=="Banadir"
drop strata ea_reg
merge 1:1 interview__id using "${gsdData}/0-RawTemp/Wave2_hh_coordinates.dta", assert(master match) keep(match) keepusing(region strata ea block hh) nogen
drop interview__id
save "${gsdData}/1-CleanTemp/Wave2_Admin2.dta", replace

* Build file containing HH identifiers and conflict data
use "${gsdData}/1-CleanTemp/ACLED-collapsed_w1.dta", clear
merge 1:m admin2Name using "${gsdData}/1-CleanTemp/Wave1_Admin2.dta", keep(match using) nogen
recode events fatalities (.=0)
save "${gsdData}/1-CleanTemp/Wave1_ACLED.dta", replace
* wave 2
use "${gsdData}/1-CleanTemp/ACLED-collapsed_w2.dta", clear
merge 1:m admin2Name using "${gsdData}/1-CleanTemp/Wave2_Admin2.dta", keep(match using) nogen
recode events fatalities (.=0)
save "${gsdData}/1-CleanTemp/Wave2_ACLED.dta", replace
use "${gsdData}/1-CleanTemp/Wave1_ACLED.dta", clear
destring block, replace 
append using "${gsdData}/1-CleanTemp/Wave2_ACLED.dta", gen(t)
drop type region
la var events "Conflict events past 9 months before data collection"
la var fatalities "Conflict fatalities past 9 months before data collection"
save "${gsdData}/1-CleanTemp/ACLED_w1w2.dta", replace

* Humanitarian assistance
* Food security cluster 1
import excel "${gsdShared}\0-Auxiliary\HumanAssist.xlsx", sheet("FSC1") cellrange(A2:T21) firstrow clear
destring January, replace
recode TotalPopulationUNFPA2014-October (.=0)
gen assist_FSC1_Oct17 = October/OctoberTarget
la var assist_FSC1_Oct17 "Percentage of population reached through activities geared towards improving access to food and safety nets, Oct17"
gen assist_FSC1_17 = (January + February + March + April + May + June + July + August + September + October) / (MonthlyTarget*4 + MayTarget + JuneTarget + JulyTarget + AugustTarget + SeptemberTarget + OctoberTarget) 
keep assist_* reg_id
ren reg_id reg_pess
save "${gsdTemp}/FSC1.dta", replace
* Food security cluster 2
import excel "${gsdShared}\0-Auxiliary\HumanAssist.xlsx", sheet("FSC2") cellrange(A2) firstrow clear
destring January, replace
recode TotalPopulationUNFPA2014-October (.=0)
gen assist_FSC2_MayAug17 = (May + June + July + August)/MayAugTarget
la var assist_FSC2_MayAug17 "% of people reached through livelihood investment and asset activities May-Aug2017"
gen assist_FSC2_17 = (January + February + March + April + May + June + July + August + September + October) / (JanApr + MayAug + SeptemberDec/2) 
keep assist_* reg_id
ren reg_id reg_pess
save "${gsdTemp}/FSC2.dta", replace
* Food security cluster 3
import excel "${gsdShared}\0-Auxiliary\HumanAssist.xlsx", sheet("FSC3") cellrange(A2) firstrow clear
recode TotalPopulationUNFPA2014-October (.=0)
gen assist_FSC3_MayAug17 = (May + June + July)/MayJulyRevisedtarget
la var assist_FSC3_MayAug17 "% of people reached through livelihood investment and asset activities May-Aug2017"
gen assist_FSC3_1617 = (August2016January2017Cumul + February + March + April + May + June + July + September + October) / (EndseasontargetAug2016J + MayJulyRevisedtarget + SeptemberRevisedTarget/2) 
keep assist_* reg_id
ren reg_id reg_pess
save "${gsdTemp}/FSC3.dta", replace
merge 1:1 reg_pess using "${gsdTemp}/FSC2.dta", assert(match) nogen
merge 1:1 reg_pess using "${gsdTemp}/FSC1.dta", assert(match) nogen
egen assist_FSC_17 = rowmean(*_17 assist_FSC3_1617)
save "${gsdData}/1-CleanTemp/FSC_HumReach.dta", replace
* Education
import excel "${gsdShared}\0-Auxiliary\HumanAssist.xlsx", sheet("Edu4") cellrange(A2:N21) firstrow clear
gen assist_edu17 = October/Endyeartarget
keep assist_* reg_id
ren reg_id reg_pess
save "${gsdData}/1-CleanTemp/Assist_Educ.dta", replace
