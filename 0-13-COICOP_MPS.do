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
save "${gsdData}/1-CleanTemp/coicop_item.dta", replace
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
save "${gsdData}/1-CleanTemp/mps_prices.dta", replace


