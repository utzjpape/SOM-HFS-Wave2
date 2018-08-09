* Prepare COICOP and MPS price data


********************************************************************
* Assign COICOP codes to products
********************************************************************
import excel using "${gsdDataRaw}/COICOP.xlsx", sheet("W2_Food") firstrow clear
save "${gsdTemp}/coicop_food.dta", replace
import excel using "${gsdDataRaw}/COICOP.xlsx", sheet("W2_Nonfood") firstrow clear
append using "${gsdTemp}/coicop_food.dta"
ren code itemid
sort coicop itemid
*export excel "${gsdOutput}/coicop_item.xlsx", sheet("HFS") sheetreplace
keep itemid coicop
save "${gsdData}/1-CleanInput/coicop_item.dta", replace
import excel using "${gsdDataRaw}/COICOP.xlsx", sheet("MPS") firstrow clear
keep mps_id coicop 
save "${gsdTemp}/coicop_mps.dta", replace

********************************************************************
* Prepare MPS data
********************************************************************
use "${gsdDataRaw}/mps-imputed.dta", clear
* drop products with very high variance which makes them unreliable
drop if inlist(mps_id, 67, 68, 69, 70, 83) 
* keep relevant periods and products
preserve 
keep if inrange(wBegin, td("20feb2016"), td("12mar2016"))
collapse (mean) feb16=p, by(mps_id market)
save "${gsdTemp}/mps_feb16.dta", replace
restore
keep if inrange(wBegin, td("04dec2017"), td("15jan2018"))
collapse (mean) dec17=p, by(mps_id market)
merge 1:1 market mps_id using "${gsdTemp}/mps_feb16.dta", keep(match) nogen
merge m:1 mps_id using "${gsdTemp}/coicop_mps.dta", keep(match) nogen keepusing(coicop)
collapse (mean) dec17 feb16, by(coicop)
save "${gsdData}/1-CleanInput/mps_prices.dta", replace


*Migrate files from RawInput to 1-CleanInput
use "${gsdDataRaw}/food_units_bands.dta", clear
save "${gsdData}/1-CleanInput/food_units_bands.dta", replace
use "${gsdDataRaw}/nonfood_units_bands.dta", clear
save "${gsdData}/1-CleanInput/nonfood_units_bands.dta", replace
import excel "${gsdDataRaw}/Flowminder_Deliverable_v1.xlsx", sheet("Flowminder") firstrow case(lower) clear
save "${gsdData}/1-CleanInput/Satellite_Estimates.dta", replace


********************************************************************
*Save a file matching itemid and COICOP codes
********************************************************************
import excel "${gsdDataRaw}/Match_Items_COICOP.xlsx", sheet("W2_Food") firstrow case(lower) clear
drop name 
rename code itemid
save "${gsdTemp}/COICOP_food.dta", replace 
import excel "${gsdDataRaw}/Match_Items_COICOP.xlsx", sheet("W2_Nonfood") firstrow case(lower) clear
drop name 
rename code itemid
save "${gsdTemp}/COICOP_nonfood.dta", replace 
use "${gsdTemp}/COICOP_food.dta", clear
append using "${gsdTemp}/COICOP_nonfood.dta"
save "${gsdData}/1-CleanInput/COICOP_Codes.dta", replace 

