*Calculates CPI weights

set more off 
set seed 23021980 
set sortseed 11021955


********************************************************************
*Calculate Laspeyres weights
********************************************************************
local lis = "food nonfood"
foreach cat of local lis {
	use "${gsdData}/1-CleanTemp/`cat'.dta", clear
	*ensure that food and non-food have the same format
	if ("`cat'"=="food") {
		ren unit_price uprice
		ren cons_usd cons_value
	}
	else {
		ren pr_usd cons_value
		*dummy for unit price
		gen uprice = cons_value
	}
	ren mod_opt mod_hh
	local lj = "Central_Regions_idp Galgaduud_idp Jubaland_idp Mogadishu_idp Puntland_idp Somaliland_idp South_West_idp Hiraan_nomad Middle_Shabelle_nomad Galgaduud_nomad Gedo_nomad Lower_Juba_nomad Middle_Juba_nomad Bari_nomad Mudug_nomad Nugaal_nomad Awdal_nomad Sanaag_nomad Sool_nomad Toghdeer_nomad Woqooyi_Galbeed_nomad Bakool_nomad Bay_nomad Lower_Shabelle_nomad Hiraan_rural Hiraan_urban Middle_Shabelle_rural Middle_Shabelle_urban Galgaduud_rural Galgaduud_urban Lower_Juba_urban Gedo_rural Gedo_urban Lower_Juba_rural Middle_Juba_rural Middle_Juba_urban Banadir_urban Bari_rural Bari_urban Mudug_rural Mudug_urban Nugaal_rural Nugaal_urban Awdal_rural Awdal_urban Sanaag_urban_rural Sool_urban_rural Toghdeer_rural Toghdeer_urban Woqooyi_Galbeed_rural Woqooyi_Galbeed_urban Bay_urban Bakool_rural Bakool_urban Bay_rural Lower_Shabelle_rural Lower_Shabelle_urban"
	keep strata ea block hh weight mod_item mod_hh itemid cons_value uprice 
	*calculate core and optional module consumption per hh
	bys strata ea block hh: egen tcore = total(cons_value) if mod_item==0
	bys strata ea block hh: egen topt = total(cons_value) if mod_item==mod_hh
	*add zero consumption
	reshape wide cons_value uprice, i(strata ea block hh mod_item) j(itemid)
	foreach v of varlist cons_value* {
		replace `v' = 0 if missing(`v') & inlist(mod_item,0,mod_hh)
	}
	reshape long cons_value uprice, i(strata ea block hh mod_item) j(itemid)
	drop if missing(cons_value)
	assert inlist(mod_item,0,mod_hh)
	*calculate item shares relative to core or optional module
	gen denom = min(tcore,topt)
	gen cons_share = cons_value / denom
	save "${gsdTemp}/`cat'-share.dta", replace

	*calculate weights: aggregate across households (using hh weights)
	use "${gsdTemp}/`cat'-share.dta", clear
	collapse (mean) cons_share denom [pweight=weight], by(itemid mod_item)
	drop if cons_share==0
	*calculate total denominator for core and all optional modules
	reshape wide denom, i(itemid cons_share) j(mod_item)
	foreach v of varlist denom? {
		egen t`v'= max(`v')
		assert `v'==t`v' if !missing(`v')
	}
	egen tdenom = rowtotal(tdenom?)
	egen denom = rowmin(denom?)
	drop denom? tdenom?
	*save module specific shares
	ren cons_share cons_mshare
	gen cons_tshare = cons_mshare * denom / tdenom
	label var cons_mshare "Share of module consumption"
	label var cons_tshare "Share of total consumption"
	*calibrate weights to sum up to 1 
	*check whether calibration worked
	egen x = total(cons_tshare)
	assert round(x,0.001)==1
	drop x
	ren denom mdenom
	label var tdenom "Total denominator"
	label var mdenom "Module-specific denominator"
	*save weights
	save "${gsdTemp}/`cat'-weights.dta", replace
	
	*prepare median and average prices
	use "${gsdTemp}/`cat'-share.dta", clear
	*national for missing
	bysort itemid: egen up_all_med = median(uprice)
	bysort itemid: egen up_all_avg = mean(uprice)
	collapse (median) uprice_med = uprice (mean) uprice_avg = uprice [pweight=weight], by(strata itemid up_all_*)
	replace uprice_med = up_all_med if missing(uprice_med)
	replace uprice_avg = up_all_avg if missing(uprice_avg)
	drop up_all_*
	*make one line per item with columns for strata
	reshape wide uprice_med uprice_avg, i(itemid) j(strata)
	*label
		forvalues j = 1/57 {
			capture: label var uprice_med`j' "Med Price `: word `j' of `lj''"
			capture: label var uprice_avg`j' "Avg Price `: word `j' of `lj''"
	}
	*add share
	merge 1:1 itemid using "${gsdTemp}/`cat'-weights.dta", nogen assert(match) keepusing(cons_?share)
	order cons_tshare cons_mshare, after(itemid)
	gsort -cons_tshare
	save "${gsdTemp}/shares-`cat'.dta", replace
	export excel itemid cons_* uprice_* using "${gsdOutput}/shares.xlsx", sheetreplace sheet("`cat'") first(varl)
	
	*construct deflator
	keep itemid cons_tshare uprice_med*
	reshape long uprice_med, i(itemid) j(strata)
	gen deflator = cons_tshare * uprice_med
	collapse (sum) deflator, by(strata)
	*normalize to 1 by using the average
	egen x = mean(deflator)
	replace deflator = deflator / x
	label var strata "Strata"
	label var deflator "`cat' deflator"
	drop x
	save "${gsdData}/1-CleanTemp/`cat'-deflator.dta", replace
	export excel using "${gsdOutput}/deflator.xlsx", sheetreplace sheet("`cat'") first(varl)
}


********************************************************************
*Calculate CPI using prices from FSNAU
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
merge 1:m coicop using "${gsdData}/1-CleanTemp/mps_prices.dta", nogen keep(match) 


********************************************************************
*Recalibrate shares and get deflators
********************************************************************
local lis = "f g"
foreach k of local lis {
	egen x`k' = sum(`k'share)
	replace `k'share = `k'share / x`k'
	drop x`k'
	gen d`k'2016 = feb16 * `k'share
	gen d`k'2017 = dec17 * `k'share
}
gen team= 1
collapse (sum) d?201?, by(team)
*get inflation
gen gg_1617 = dg2017/dg2016
gen gf_1617 = df2017/df2016
* bring in 2011 to 2016 inflation
merge 1:1 team using "${gsdData}/1-CleanInput/SHFS2016/inflation.dta", keepusing(gg gf) nogen
replace gg = gg*gg_1617
replace gf = gf*gf_1617
drop *_1617 df* dg*
label var gg "Food and non-food CPI inflation between 2011 and Dec 2017"
label var gf "Food CPI inflation between 2011 and Dec 2017"
save "${gsdData}/1-CleanTemp/inflation.dta", replace
