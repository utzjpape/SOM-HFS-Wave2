*file to obtain market price data for Somalia CPI


set more off
set seed 21081980 
set sortseed 10041955

foreach region in Awdal Bakool Banaadir Bari Bay Galgaguud Gedo Hiraan Lower_Juba Lower_Shabelle Middle_Juba Middle_Shabelle Mudug Nugaal Sanaag Sool Togdheer Woqooyi_Galbeed {
	clear
	import excel "${gsdDataRaw}/market_prices.xlsx", sheet("`region'") firstrow
	
	* Keep 2011 average
	preserve
	* keep only relevant time periods	
	keep if Year==2011
	* Reshape
	rename (Product Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec) (product m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12)
	reshape long m, i(product) j(month)
	collapse (mean) av_2011=m, by(product) 
	la var av_2011 "Average price 2011"
	save "${gsdTemp}/`region'_av2011.dta", replace
	restore
	
	* Keep 2012 average
	preserve
	* keep only relevant time periods	
	keep if Year==2012
	* Reshape
	rename (Product Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec) (product m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12)
	reshape long m, i(product) j(month)
	collapse (mean) av_2012=m, by(product) 
	la var av_2012 "Average price 2012"
	save "${gsdTemp}/`region'_av2012.dta", replace
	restore
	
	* keep 2016 entries
	keep if Year==2016
	drop May-Dec
	ren (Product Jan Feb Mar Apr) (product jan16 feb16 mar16 apr16)
	la var product "Product Name"
	la var jan16 "Price Jan 16"
	la var feb16 "Price Feb 16"
	la var mar16 "Price Mar 16"
	la var apr16 "Price Apr 16"
	drop Year
	gen str reg_pess = "`region'"
	la var reg_pess "Region(PESS)"
	
	* merge back with 2011 and 2012 averages 
	merge m:1 product using "${gsdTemp}/`region'_av2011.dta", keep(master match) nogen 
	merge m:1 product using "${gsdTemp}/`region'_av2012", keep(master match) nogen 
	save "${gsdTemp}/market_prices_`region'.dta", replace
	
}
	
* append all regions 
use "${gsdTemp}/market_prices_Awdal.dta", clear
foreach region in Bakool Banaadir Bari Bay Galgaguud Gedo Hiraan Lower_Juba Lower_Shabelle Middle_Juba Middle_Shabelle Mudug Nugaal Sanaag Sool Togdheer Woqooyi_Galbeed {
	append using "${gsdTemp}/market_prices_`region'.dta"
}

save "${gsdData}/1-CleanInput/prices_fsnau.dta", replace

use "${gsdData}/1-CleanInput/prices_fsnau.dta", clear
* Convert Prices to USD
keep if strpos(product, "USD")
ren (jan16 feb16 mar16 apr16 av_2011 av_2012) (jan16usd feb16usd mar16usd apr16usd av_2011usd av_2012usd)
drop product
merge 1:m reg_pess using "${gsdData}/1-CleanInput/prices_fsnau.dta", assert(match) nogen
foreach v in jan16 feb16 mar16 apr16 av_2011 av_2012 {
	replace `v' = `v'/`v'usd
}
drop *usd
drop if strpos(product, "USD")
la var jan16 "Price Jan 16, USD"
la var feb16 "Price Feb 16, USD"
la var mar16 "Price Mar 16, USD"
la var apr16 "Price Apr 16, USD"
la var av_2011 "2011 price average, USD"
la var av_2012 "2012 price average, USD"

replace product = "Camel Local" if product=="Camel local"
replace product = "Camel Milk 1l" if product=="Camel milk 1l"
replace product = "Cattle Local" if product=="Cattle local"
replace product = "Cattle Local" if product=="Cattle Local "
replace product = "White Maize 1kg" if product=="White Maize"
replace product = "Vegetable Oil" if product=="Vegetable oil"
replace product = "Goat Export" if product=="Goat Export Quality"
replace product = "Goat Local" if product=="Goat Local Quality"
replace product = "Cooking Pot" if product=="Cooking Pot "

* Drop 50kg where 1kg is available
drop if product=="White Maize 50kg" 
drop if product=="Yellow Maize Maize 50kg" 
drop if product=="White Sorghum 50kg"
drop O
* Merge with COICOP conversion data, keep only matches
ren product fsnau_comm
merge m:1 fsnau_comm using "${gsdData}/1-CleanInput/COICOP_conversion_fsnau.dta", keep(match) nogen keepusing(coicop_code)

* add in itemid for HFS
joinby coicop_code using "${gsdData}/1-CleanInput/COICOP_conversion_food.dta", unmatched(master)
drop _m
joinby coicop_code using "${gsdData}/1-CleanInput/COICOP_conversion_nonfood.dta", unmatched(master) update
drop _m

* Convert to 1kg where possible, drop 50kg, where 1kg is available 
foreach v in jan16 feb16 mar16 apr16 av_2011 {
	replace `v' = `v'/50 if strpos(fsnau_comm, "50kg")
}
replace fsnau_comm = "Cement 1kg" if fsnau_comm== "Cement 50kg"
replace fsnau_comm = "Charcoal 1kg" if fsnau_comm== "Charcoal 50kg"


replace jan16 = jan16/15 if strpos(fsnau_comm, "15kg")
foreach v in jan16 feb16 mar16 apr16 av_2011 {
	replace `v' = `v'/15 if strpos(fsnau_comm, "15kg")
}

replace fsnau_comm = "Roofing Nails 1kg" if fsnau_comm=="Roofing Nails 15kg"

* Add in region 
replace reg_pess = "Galgaduud" if reg_pess=="Galgaguud"
replace reg_pess = "Banadir" if reg_pess=="Banaadir"
replace reg_pess = "Woqooyi Galbeed" if reg_pess=="Woqooyi_Galbeed"
replace reg_pess = "Lower Juba" if reg_pess=="Lower_Juba"
replace reg_pess = "Middle Juba" if reg_pess=="Middle_Juba"
replace reg_pess = "Lower Shabelle" if reg_pess=="Lower_Shabelle"
replace reg_pess = "Middle Shabelle" if reg_pess=="Middle_Shabelle"

merge m:1 reg_pess using "${gsdData}/0-RawTemp/reg_pess.dta", nogen assert(match) keepusing(pess_id)
drop reg_pess
ren pess_id reg_pess
save "${gsdData}/1-CleanInput/prices_fsnau.dta", replace


