* Convert COICOP Matching file from xls into dta

set more off 
set seed 23031980 
set sortseed 11021955

********************************************************************************
****************** HFS SOM FOOD AND NONFOOD ITEMS *****************************
********************************************************************************
clear
import excel "${gsdDataRaw}/COICOP_matching.xlsx", sheet("HFS SOM Food Items") firstrow
save "${gsdTemp}/COICOP_conversion_food.dta", replace
clear
import excel "${gsdDataRaw}/COICOP_matching.xlsx", sheet("HFS SOM Non-Food Items") firstrow
append using "${gsdTemp}/COICOP_conversion_food.dta"

* Basic Cleaning and Formatting
gen coicop_code = COICOPCode + Seq_no
destring coicop_code, replace
la var coicop_code "COICOP Code assignment, sequenced"


* Assign Food ID and nonfoodid to commodities
gen id = foodid 
replace id = nfoodid if id==.
labmask id, values(f_item)
ren id itemid
la var itemid "Food ID"
replace f_item = "Maize" if coicop_code==11105
replace f_item = "Sorghum" if coicop_code==11117
replace f_item = "Cooking Oil" if coicop_code==11504

* Keep relevant variables and save as Stata data 
* For food 
preserve
keep if !missing(foodid) 
keep itemid coicop_code 
save "${gsdData}/1-CleanInput/COICOP_conversion_food.dta", replace
restore 
* For nonfood
keep if !missing(nfoodid) 
keep itemid coicop_code 
la var itemid "Non-Food ID"
save "${gsdData}/1-CleanInput/COICOP_conversion_nonfood.dta", replace

********************************************************************************
*********************** FSNAU Commodities **************************************
********************************************************************************
clear
import excel "${gsdDataRaw}/COICOP_matching.xlsx", sheet("FSNAU Commodities") firstrow
* Basic Cleaning and Formatting
ren FSNAUCommodityName fsnau_comm 
gen coicop_code = COICOPCode + Seq_no
destring coicop_code, replace
la var coicop_code "COICOP Code assignment, sequenced"
gen str temp = fsnau_comm
replace temp=  "Cattle" if coicop_code == 11202
replace temp= "Goat" if coicop_code == 11206
replace temp= "Maize" if coicop_code == 11105
replace temp= "Sorghum" if coicop_code == 11117
replace temp = "Diesel or Petrol" if coicop_code == 72201
labmask coicop_code, values(temp)
keep coicop_code fsnau_comm


* Save as Stata data 
save "${gsdData}/1-CleanInput/COICOP_conversion_fsnau.dta", replace

