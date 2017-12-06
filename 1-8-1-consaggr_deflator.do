*calculates CPI weights

set more off 
set seed 23021980 
set sortseed 11021955

*calculate Laspeyres weights
*since we use this to impute item consumption
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
	ren opt_mod mod_hh
	ren weight_cons weight
	local li = "PL SL SC"
	local lj = "Urban Rural IDP"
	keep team strata ea block hh weight mod_item mod_hh itemid cons_value uprice astrata type
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
	*add coicop code
	merge 1:1 itemid using "${gsdData}/1-CleanInput/COICOP_conversion_`cat'.dta", nogen keep(match) assert(match using) keepusing(coicop_code)
	order coicop_code, after(itemid)
	*save weights
	save "${gsdTemp}/`cat'-weights.dta", replace
	
	*prepare median and average prices
	use "${gsdTemp}/`cat'-share.dta", clear
	*national for missing
	bysort itemid: egen up_all_med = median(uprice)
	bysort itemid: egen up_all_avg = mean(uprice)
	collapse (median) uprice_med = uprice (mean) uprice_avg = uprice [pweight=weight], by(astrata itemid up_all_*)
	replace uprice_med = up_all_med if missing(uprice_med)
	replace uprice_avg = up_all_avg if missing(uprice_avg)
	drop up_all_*
	*make one line per item with columns for a-strata
	reshape wide uprice_med uprice_avg, i(itemid) j(astrata)
	*label
	forvalues i = 1/3 {
		forvalues j = 1/3 {
			capture: label var uprice_med`i'`j' "Med Price `: word `i' of `li'' `: word `j' of `lj''"
			capture: label var uprice_avg`i'`j' "Avg Price `: word `i' of `li'' `: word `j' of `lj''"
		}
	}
	*add share
	merge 1:1 itemid using "${gsdTemp}/`cat'-weights.dta", nogen assert(match) keepusing(cons_?share)
	order cons_tshare cons_mshare, after(itemid)
	gsort -cons_tshare
	save "${gsdTemp}/shares-`cat'.dta", replace
	export excel itemid cons_* uprice_* using "${gsdOutput}/shares.xlsx", sheetreplace sheet("`cat'") first(varl)
	
	*construct deflator
	keep itemid cons_tshare uprice_med*
	reshape long uprice_med, i(itemid) j(astrata)
	gen deflator = cons_tshare * uprice_med
	collapse (sum) deflator, by(astrata)
	*normalize to 1 by using the average
	egen x = mean(deflator)
	replace deflator = deflator / x
	label var astrata "Analytical Strata"
	label var deflator "`cat' deflator"
	drop x
	save "${gsdData}/1-CleanTemp/`cat'-deflator.dta", replace
	export excel using "${gsdOutput}/deflator.xlsx", sheetreplace sheet("`cat'") first(varl)
}

*calculate CPI using prices from FSNAU
use "${gsdTemp}/food-weights.dta", clear
append using "${gsdTemp}/nonfood-weights.dta", gen(nonfood)
gen fshare = cons_tshare * (1-nonfood)
label var fshare "Share for food deflator"
egen xshare = sum(cons_tshare)
gen gshare = cons_tshare/xshare
label var gshare "Share for general deflator"
keep coicop_code fshare gshare
*collapse given that we have sometimes multiple HFS / COICOP items with the same code
*as they didn't match perfectly
collapse (sum) ?share, by(coicop_code)
*add prices
merge 1:m coicop_code using "${gsdData}/1-CleanInput/prices_fsnau.dta", nogen assert(master match) keep(match) keepusing(jan16 feb16 mar16 apr16 av_2011 reg_pess)
*collapse multiple coicop items by using average price but the same share
collapse (mean) jan16 feb16 mar16 apr16 av_2011 (max) ?share, by(coicop_code reg_pess)
*average over regions
collapse (mean) jan16 feb16 mar16 apr16 av_2011 (max) ?share, by(coicop_code)
*recalibrate shares and get deflators
local lis = "f g"
foreach k of local lis {
	egen x`k' = sum(`k'share)
	replace `k'share = `k'share / x`k'
	drop x`k'
	gen d`k'2016 = feb16 * `k'share
	gen d`k'2011 = av_2011 * `k'share
}
gen k = 1
collapse (sum) d?201?, by(k)
*get inflation
gen gg = dg2016/dg2011
gen gf = df2016/df2011
label var gg "Food and non-food CPI inflation between 2011 and Feb 2016"
label var gf "Food CPI inflation between 2011 and Feb 2016"
gen zone = 3
save "${gsdData}/1-CleanTemp/inflation.dta", replace
