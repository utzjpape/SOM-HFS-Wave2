* Prepare auxiliary data needed for analysis

clear all
set more off
set maxvar 10000
set seed 23081980 
set sortseed 11041985

*Import ACLED data
* 2017 file
import excel "${gsdShared}\Auxiliary\Conflict\ACLED-All-Africa-File_20170101-to-20171014.xlsx", firstrow case(lower) clear
keep if year==2017 
keep if country=="Somalia"
drop admin3
destring longitude, replace 
save "${gsdTemp}\ACLED-2017.dta", replace
* Previous years
import excel "${gsdShared}\Auxiliary\Conflict\ACLED-SOM_1997to2016.xlsx", firstrow case(lower) clear
keep if inlist(year, 2015, 2016)
drop admin3
append using "${gsdTemp}\ACLED-2017.dta"
save "${gsdData}/1-CleanInput/ACLED.dta", replace
export delim "${gsdOutput}/ACLED.csv", replace
