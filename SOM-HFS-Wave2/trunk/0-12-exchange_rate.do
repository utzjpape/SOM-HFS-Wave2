*Obtain the average exchange rate per zone to convert consumption into USD 

set more off 
set seed 23080980 
set sortseed 11040955



********************************************************************
*Check there are no incomplete cases
********************************************************************
use "${gsdDataRaw}/ERS/ers_byday.dta", clear
foreach v of varlist _all {
	assert !mi(`v') 	
}


********************************************************************
*Keep the valid dates and define currencies
********************************************************************
*December 4th to 31st 
local start 04Dec2017
local end 31Dec2017
*=============================
*============UPDATE END DATE AND INPUT DATASET WITH THE LATEST==========
keep if wBegin>=td(`start') & wBegin<=td(`end')


********************************************************************
*Obtain the mean exchange rate 
********************************************************************
*Consider two different exchange rates (SL vs. SC and PL teams)
recode team (3=2)
collapse (mean) mp, by(team)
ren mp average_er
egen x = mean(average_er) if team!=1
egen global_er = max(x)
label var average_er "Local currency exchange rate to 1 USD"
label var global_er "Global exchange rate to 1 USD"
drop x
save "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", replace
