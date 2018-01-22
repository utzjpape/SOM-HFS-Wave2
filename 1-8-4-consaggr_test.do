*Obtain shares after imputation

set more off 
set seed 23021980 
set sortseed 11021955


*********************************************************
*Calculate Laspeyres weights
*********************************************************
*since we use this to impute item consumption
local lis = "food nonfood"
foreach cat of local lis {
	use "${gsdData}/1-CleanOutput/`cat'.dta", clear
	*ensure that food and non-food have the same format
	if ("`cat'"=="food") {
		ren unit_price uprice
		ren cons_usd_imp cons_value
	}
	else {
		ren purc_usd_imp cons_value
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
	*assert inlist(mod_item,0,mod_hh)
	*calculate item shares relative to core or optional module
	gen denom = min(tcore,topt)
	gen cons_share = cons_value / denom
	save "${gsdTemp}/`cat'-share-t.dta", replace

	*calculate weights: aggregate across households (using hh weights)
	use "${gsdTemp}/`cat'-share-t.dta", clear
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
	label var cons_mshare "Share of module consumption after imputation"
	label var cons_tshare "Share of total consumption after imputation"
	*calibrate weights to sum up to 1 
	*check whether calibration worked
	egen x = total(cons_tshare)
	assert round(x,0.001)==1
	drop x
	ren denom mdenom
	label var tdenom "Total denominator"
	label var mdenom "Module-specific denominator"
	*add coicop code
	merge 1:1 itemid using "${gsdData}/1-CleanInput/COICOP_Codes.dta", nogen keep(match)  keepusing(coicop)
	order coicop, after(itemid)
	*save weights
	save "${gsdTemp}/`cat'-weights-t.dta", replace
	
	*prepare median and average prices
	use "${gsdTemp}/`cat'-share-t.dta", clear
	*national for missing
	bysort itemid: egen up_all_med = median(uprice)
	bysort itemid: egen up_all_avg = mean(uprice)
	collapse (median) uprice_med = uprice (mean) uprice_avg = uprice [pweight=weight], by(strata itemid up_all_*)
	replace uprice_med = up_all_med if missing(uprice_med)
	replace uprice_avg = up_all_avg if missing(uprice_avg)
	drop up_all_*
	*make one line per item with columns for a-strata
	reshape wide uprice_med uprice_avg, i(itemid) j(strata)
	*label
	forvalues j = 1/57 {
		capture: label var uprice_med`j' "Med Price `: word `j' of `lj''"
		capture: label var uprice_avg`j' "Avg Price `: word `j' of `lj''"
	}
	*add share
	merge 1:1 itemid using "${gsdTemp}/`cat'-weights-t.dta", nogen keep(match) keepusing(cons_?share)
	order cons_tshare cons_mshare, after(itemid)
	gsort -cons_tshare
	save "${gsdTemp}/shares-`cat'-t.dta", replace
	export excel itemid cons_*  using "${gsdOutput}/shares-imputed.xlsx", sheetreplace sheet("`cat'") first(varl)
	
	*construct deflator
	keep itemid cons_tshare uprice_med*
	reshape long uprice_med, i(itemid) j(strata)
	gen deflator = cons_tshare * uprice_med
	collapse (sum) deflator, by(strata)
	*normalize to 1 by using the average
	egen x = mean(deflator)
	replace deflator = deflator / x
	label var deflator "`cat' deflator"
	drop x
	save "${gsdData}/1-CleanTemp/`cat'-deflator-t.dta", replace
	export excel using "${gsdOutput}/deflator-imputed.xlsx", sheetreplace sheet("`cat'") first(varl)
}

