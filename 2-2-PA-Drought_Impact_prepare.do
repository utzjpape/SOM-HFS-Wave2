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
*shp2dta using "${gsdShared}\0-Auxiliary\Climate Data\SPI\spi_combined_HHs", data("${gsdTemp}/spi_combined_HHs_Wave2") coor("${gsdTemp}/spi_combined_HHs_Wave2_coordinates") replace
import delimited "${gsdShared}\0-Auxiliary\Climate Data\SPI\spi_combined_HHs_Wave2.txt", clear
save "${gsdTemp}/spi_combined_HHs_Wave2.dta", replace
use "${gsdTemp}/spi_combined_HHs_Wave2.dta", clear
replace grid_code = grid_code/3
drop if grid_code==0
collapse (mean) SPI=grid_code, by(strata ea_reg ea interview_ type)
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
save "${gsdData}/1-CleanTemp/SPI_w1w2.dta", replace

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
su SPI
gen SPI_cat = -3 if inrange(SPI, `r(min)', -2)
replace SPI_cat = -2 if SPI>-2 & SPI<=-1.5
replace SPI_cat = -1 if SPI>-1.5 & SPI<=-1
replace SPI_cat = 0 if SPI>-1 & SPI<1
replace SPI_cat = 1 if SPI>=1 & SPI<1.5
replace SPI_cat = 2 if SPI>=1.5 & SPI<2
replace SPI_cat = 3 if SPI>=2
export delim POINTID SPI SPI_cat using "${gsdData}/1-CleanTemp/SPI_drought_map.csv", replace

* Rainfall and NDVI timeseries
import excel using "${gsdShared}\0-Auxiliary\Climate Data\Rainfall_NDVI_timeseries.xlsx", clear firstrow case(lower) sheet("Combined")
collapse (mean) rainfall_level=rainfallmm rainfall_average rainfall_anomaly_1m=onemonthanomaly rainfall_anomaly_3m=threemonthsanomaly ndvi ndvi_average ndvi_anomaly=ndvianomaly, by(year month)
gen date = ym(year, month)
order date
format date %tm
save "${gsdData}/1-CleanTemp/rainfall_timeseries.dta", replace

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
save "${gsdData}/1-CleanTemp/FSC_HumReach.dta", replace
