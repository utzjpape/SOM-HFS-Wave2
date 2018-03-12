* Extract energy statistics

use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
keep if inlist(type, 1, 2)
* access to grid
tabout electricity_grid type using "${gsdOutput}/Electricity_stats_raw1.xls" , svy percent c(col se) npos(col) sebnone h1("Households with access to electricity") replace
* Electricity source 
recode light (1=2 "Generator") (2 3 = 3 "Solar System") (4 = 4 "Battery") (5 = 5 "Flashlight") (6=6 "Candle") (7=7 "Open wick lamp") (8 9 = 8 "Pressure lamp") (10 = 9 "Firewood") (11=10 "Gas") (1000=11 "Other") (12=12 "None"), gen(electricity_source)
replace electricity_source = 1 if electricity_grid==1
tabout electricity_source type using "${gsdOutput}/Electricity_stats_raw1.xls" , svy percent c(col se) npos(col) sebnone h1("Electricity/lighting source") append

* Charge phone from electricty source
tabout electricity_phone type using "${gsdOutput}/Electricity_stats_raw1.xls" , svy percent c(col se) npos(col) sebnone h1("Can charge phone from electricity") append
* Electricity choice
tabout electricity_choice type using "${gsdOutput}/Electricity_stats_raw1.xls" , svy percent c(col se) npos(col) sebnone h1("Choice between different electricity suppliers") append
* Electricty price in USD 
* Clean electricity prices
gen team = 1 if inlist(reg_pess, 1, 18)
* SSH
replace team = 2 if inlist(reg_pess, 3)
replace team = 3 if inlist(reg_pess, 4,11,12)
replace team = 4 if inlist(reg_pess, 8, 6, 14)
replace team = 5 if inlist(reg_pess, 7, 10)
replace team = 6 if inlist(reg_pess, 5, 2, 15)
* Now the situations where both currencies are possible to select 
replace team = 1 if inlist(reg_pess, 13, 16, 17) & electricity_price_curr==4   
replace team = 3 if inlist(reg_pess, 13, 16, 17) & electricity_price_curr==2  
* we assign team 1 if USD or missing
replace team = 1 if inlist(reg_pess, 13, 16, 17) & (electricity_price_curr==5 | mi(electricity_price_curr)) & mi(team) 
assert !mi(team)
merge m:1 team using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(average_er)
gen electricity_price_usd = electricity_price if electricity_price_curr==5
replace electricity_price_usd=electricity_price/(average_er/1000) if electricity_price_usd==2 | electricity_price_usd==4
replace electricity_price_usd = .d if electricity_grid==1 & mi(electricity_price_usd)
*Cleaning rule: replace values in the top/bottom 1% by the median value in USD within the same astrata 
set sortseed 11041925
cumul electricity_price_usd, gen(cumul_distr_e_pr_usd) equal
levelsof ind_profile, local(regions)
foreach region of local regions {
   sum electricity_price_usd [aw= weight] if ind_profile==`region' & cumul_distr_e_pr_usd>0.01 & cumul_distr_e_pr_usd<0.99, detail 
   replace electricity_price_usd=r(p50) if electricity_price_usd<. & ind_profile==`region' & (cumul_distr_e_pr_usd>0.99  | cumul_distr_e_pr_usd<0.01)	
}
*Cleaning rule: replace "don't know" and "refused to respond" to mean of astrata
bys ind_profile: egen e_pr_usd_astrata_mean = mean(electricity_price_usd)
replace electricity_price_usd = e_pr_usd_astrata_mean if electricity_price_usd==.d
drop e_pr_usd_astrata_mean cumul_distr_e_pr_usd team
tabout type using "${gsdOutput}/Electricity_stats_raw1.xls", svy sum c(mean electricity_price_usd se) sebnone h2("Electricity cost past month") append

* Electricity meter
tabout electricity_meter type using "${gsdOutput}/Electricity_stats_raw1.xls" , svy percent c(col se) npos(col) sebnone h1("HH has electricity meter") append
* Electricity fee
tabout electricity_fee type using "${gsdOutput}/Electricity_stats_raw1.xls" , svy percent c(col se) npos(col) sebnone h1("Fixed or varied fee") append
* Perception about electricity prices
tabout electricity_price_perception type using "${gsdOutput}/Electricity_stats_raw1.xls" , svy percent c(col se) npos(col) sebnone h1("Perception about electricity price") append
* Daily hours of electricity
tabout type using "${gsdOutput}/Electricity_stats_raw1.xls", svy sum c(mean electricity_hours se) sebnone h2("Daily hours of electricity") append
* Daily blackouts
tabout electricity_blackout type using "${gsdOutput}/Electricity_stats_raw1.xls" , svy percent c(col se) npos(col) sebnone h1("Blackouts per day") append
* Cooking source
tabout cooking type using "${gsdOutput}/Electricity_stats_raw1.xls" , svy percent c(col se) npos(col) sebnone h1("Cooking source") append

* Put it all together
insheet using "${gsdOutput}/Electricity_stats_raw1.xls", clear nonames tab
export excel using "${gsdOutput}/SHFS-Electricity_Statistics.xlsx", sheet("Raw_data") sheetreplace first(varlabels)


