use "${gsdDataRaw}/mps-imputed.dta", clear
* drop products with very high variance which makes them unreliable
drop if inlist(mps_id, 67, 68, 69, 70, 83) 
* keep relevant periods and products
gen monthly = mofd(wBegin)
* March 2018 only has a few observations, so drop 
drop if monthly>tm(2018m2)
* Combine February with March because February has only two weeks of observations
replace monthly=tm(2016m3) if monthly==tm(2016m2)
keep mps_id market monthly p
* keep full series by month
collapse (mean) p, by(mps_id market monthly)
reshape wide p, i(mps_id market) j(monthly)

foreach v of varlist p674-p697 {
	drop if mi(`v')
}
reshape long p, i(mps_id market) j(monthly) 
format monthly %tm
*gen base = inrange(wBegin, td("20feb2016"), td("12mar2016"))
merge m:1 mps_id using "${gsdTemp}/coicop_mps.dta", keep(match) nogen keepusing(coicop)
collapse (mean) p*, by(coicop monthly)
save "${gsdData}/1-CleanTemp/mps_prices_full.dta", replace

********************************************************************
*Calculate CPI using prices from MPS
********************************************************************
use "${gsdTemp}/food-weights.dta", clear
append using "${gsdTemp}/nonfood-weights.dta", gen(nonfood)
gen fshare = cons_tshare * (1-nonfood)
label var fshare "Share for food deflator"
egen xshare = sum(cons_tshare)
gen gshare = cons_tshare/xshare
label var gshare "Share for general deflator"
keep itemid fshare gshare
*Bring in the COICOP code and prices 
merge 1:m itemid using "${gsdData}/1-CleanTemp/coicop_item.dta", keep(match) nogen keepusing(coicop)
*Collapse given that we have sometimes multiple HFS / COICOP items with the same code
collapse (sum) ?share, by(coicop)
destring coicop, replace
*Add prices
merge 1:m coicop using "${gsdData}/1-CleanTemp/mps_prices_full.dta", nogen keep(match) 

********************************************************************
*Recalibrate shares and get deflators
********************************************************************
local lis = "f g"
foreach k of local lis {
	bysort monthly: egen x`k' = sum(`k'share)
	replace `k'share = `k'share / x`k'
	drop x`k'
	bysort monthly: gen d`k' = p * `k'share
}
gen team= 1
collapse (sum) dg df, by(team monthly)
*get inflation
su dg if monthly == tm(2016m2) | monthly == tm(2016m3)
gen dg_w1 = `r(mean)'
su df if monthly == tm(2016m2) | monthly == tm(2016m3)
gen df_w1 = `r(mean)'

gen gg_1617 = dg/dg_w1
gen gf_1617 = df/df_w1

* bring in 2011 to 2016 inflation
merge m:1 team using "${gsdData}/1-CleanInput/SHFS2016/inflation.dta", keepusing(gg gf) nogen
replace gg = gg*gg_1617
replace gf = gf*gf_1617
drop *_1617 df* dg*
drop gf 
label var gg "Food and non-food CPI inflation"
save "${gsdData}/1-CleanTemp/w2_inflation_series.dta", replace
