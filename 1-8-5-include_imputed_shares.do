*Includes imputed consumption into food and nonfood data sets
set more off
set seed 23081920 
set sortseed 11041925


*********************************************************
*Create a file with imputed consumption (pc pd curr USD) 
*********************************************************
foreach cat in f nf {
	use "${gsdData}/1-CleanTemp/hhq-poverty.dta", clear
	keep strata ea block hh weight hhsize opt_mod mi_cons_`cat'0 mi_cons_`cat'1 mi_cons_`cat'2 mi_cons_`cat'3 mi_cons_`cat'4 
    ren (mi_cons_`cat'*) (x*)
    reshape long x, i(strata ea block hh) j(mod_item)
    ren x mi_cons_`cat'
	*include data in the same units (current USD per hh per week)
	replace mi_cons_`cat'=mi_cons_`cat'*hhsize*7
	if ("`cat'"=="f") {
		rename mi_cons_f mi_cons_food
		save "${gsdTemp}/mi_food_collapsed.dta", replace
		}
	else {
		rename mi_cons_nf mi_cons_nonfood
		save "${gsdTemp}/mi_nonfood_collapsed.dta", replace
	}
    
}


*********************************************************
*Prepare clean food and non-food datasets to loop over them
*********************************************************
use "${gsdData}/1-CleanTemp/food.dta", clear
save "${gsdTemp}/food.dta", replace
use "${gsdData}/1-CleanTemp/nonfood.dta", clear
rename pr_usd cons_usd
*Include households with zero non-food consumption 
append using "${gsdTemp}/nfood_hhs_with_zerocons.dta"
replace itemid=1001 if itemid>=.
save "${gsdTemp}/nonfood.dta", replace


*********************************************************
*Create a file with all the items for all the households & obtain shares 
*********************************************************
set sortseed 11041925
foreach cat in food nonfood {
	use "${gsdTemp}/`cat'.dta", clear
	keep strata ea block hh weight mod_opt itemid mod_item cons_usd
	reshape wide mod_item cons_usd , i(strata ea block hh mod_opt) j(itemid) 
	reshape long mod_item cons_usd, i(strata ea block hh mod_opt) j(itemid) 
	*include module of each item
	drop mod_item
	merge m:1 itemid using "${gsdData}/1-CleanTemp/items_module_`cat'.dta", keep(match) nogen keepusing(mod_item) 
	save "${gsdTemp}/dataset_`cat'.dta", replace
	*next we obtain the consumption share of each item
	collapse (sum) cons_usd (mean) mod_item, by(itemid)	
	bys mod_item: egen cons_usd_tot=sum(cons_usd)
	gen share_`cat'=cons_usd/cons_usd_tot
	save "${gsdTemp}/shares_`cat'.dta", replace
}


*********************************************************
*Continue merging the previous files, allocating imputed consumption and dropping/rescaling small values
*********************************************************
set sortseed 11041925
foreach cat in food nonfood {
	use "${gsdTemp}/dataset_`cat'.dta", clear
    drop if weight>=. 
    drop if mod_opt==.
	merge m:1 itemid using "${gsdTemp}/shares_`cat'.dta", assert(match) nogen keepusing(share_`cat')
	merge m:1 strata ea block hh mod_item using "${gsdTemp}/mi_`cat'_collapsed.dta", keep(match) nogen keepusing(mi_cons_`cat') 
	*include hh size and order the dataset
	merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", keep(match) nogen keepusing(hhsize)
	order strata ea block hh weight hhsize mod_opt itemid mod_item cons_usd share_`cat' mi_cons_`cat'
	*obtain the imputed consumption per household per item (pc pd curr USD)
	gen mi_cons_value = . 
	replace mi_cons_value  = share_`cat' * mi_cons_`cat' if mod_item!=0 & mod_opt!=mod_item
    replace mi_cons_value  = cons_usd if mod_item==0 | mod_opt==mod_item
    replace mi_cons_value  = 0 if mi_cons_value>=.

	*check that the imputed consumption by item sums up to the module aggregate
	preserve
	ren mi_cons_value sumcheck
	collapse (first) mi_cons_`cat' (sum) sumcheck, by(strata ea block hh mod_item )
    assert round(mi_cons_`cat' - sumcheck ,.001)==0 if (!missing(mi_cons_`cat'))
    restore	
	*check that the consumption share of each item is still the same 
	preserve
	collapse (sum) mi_cons_value (mean) mod_item, by(itemid)	
	bys mod_item: egen mi_cons_tot=sum(mi_cons_value)
	gen share_`cat'_after=mi_cons_value/mi_cons_tot
	merge 1:1 itemid using "${gsdTemp}/shares_`cat'.dta", assert(match) nogen keepusing(share_`cat')
	assert round(share_`cat'_after)==round(share_`cat')
	restore

	*generate a flag for imputed values 
	gen imputed = (mod_opt!=mod_item & mod_item >0) 
	label define limputed 0 "collected" 1 "imputed"
	label values imputed limputed
	label var imputed "Source of consumption value"

	*organize the dataset
	drop share_`cat' mi_cons_`cat'
	ren (cons_usd mi_cons_value) (cons_usd_org cons_usd_imp)
	label var cons_usd_org "Collected consumption in curr USD 7d"
	assert missing(cons_usd_org) if imputed == 1

	*drop items with zero or very small consumption (<0.0005 approx. 1.6 SSh per hh per day) for non-collected data & rescale the other items
	gen small = (cons_usd_imp< 0.0005) & imputed
	bys strata ea block hh: egen sum = sum(cons_usd_imp) 
	bys strata ea block hh: egen x= sum(cons_usd_imp) if small == 1
	bys strata ea block hh: egen y= sum(cons_usd_imp) if small == 0 
	*distribute to all records
	bys strata ea block hh: egen small_sum = max(x)
	bys strata ea block hh: egen nonsmall_sum= max(y)
	drop x y
	*obtain the factor to scale consumption values 
	gen factor= cons_usd_imp / nonsmall_sum 
    gen scaled_cons = cons_usd_imp + (factor * small_sum) if !missing(small_sum)
	replace scaled_cons=cons_usd_imp if missing(small_sum)
	*check that the rescaling was done correctly, organize and save the dataset
	bys strata ea block hh: egen sum_scaled_cons = sum(scaled_cons)
	assert scaled_cons==cons_usd_imp if missing(small_sum)
	assert round(sum_scaled_cons - sum,.001)==0 if sum_scaled_cons!=0 & small_sum>=.
	drop cons_usd_imp
	ren  scaled_cons cons_usd_imp
	drop sum small_sum nonsmall_sum factor sum_scaled_cons
	order cons_usd_imp, after(cons_usd_org)
	label var cons_usd_imp "Imputed Consumption in curr USD 7d"
	save "${gsdData}/1-CleanTemp/imputed_`cat'_byitem.dta", replace
}


*********************************************************
*Integrate final dataset for food consumption
*********************************************************
use "${gsdData}/1-CleanTemp/food.dta", replace
drop if weight>=. 
merge 1:1 strata ea block hh itemid using "${gsdData}/1-CleanTemp/imputed_food_byitem.dta", assert(match using) nogen
drop if small == 1
drop cons_usd small
order region strata ea block hh hhsize enum weight mod_opt itemid mod_item cons_usd_org cons_usd_imp imputed 
*label items as non-administered
foreach v of varlist cons-purc_p_tag {
   replace `v'=.z if imputed==1
}
sort strata ea block hh
*Correctly code each variable and integrate output files
*items in the core should have a zero or positive value and not missing
replace cons_usd_org=0 if missing(cons_usd_org) & mod_item==0
replace cons_usd_imp=0 if cons_usd_org==0 & mod_item==0
*items in the administered module should have a zero or positive value and not missing
replace cons_usd_org=0 if missing(cons_usd_org) & mod_item==mod_opt
replace cons_usd_imp=0 if cons_usd_org==0 & mod_item==mod_opt
*items in the non-admin module should be coded as such
replace cons_usd_org=.z if cons_usd_org>=. & mod_opt!=mod_item & mod_item!=0
*check imputed equals collected for the core and assigned modules 
assert round(cons_usd_org-cons_usd_imp,.01)==0 if imputed==0
*other checks for consistency
assert cons_usd_org>=. if mod_opt!=mod_item & mod_item!=0
assert imputed==1 if mod_opt!=mod_item & mod_item!=0
assert imputed==0 if mod_opt==mod_item | mod_item==0
assert cons_usd_org==.z if imputed==1
assert cons_usd_imp>0 if imputed==1
assert cons_usd_org== cons_usd_imp & cons_usd_imp==0 if cons==.
rename region reg_pess
la var reg_pess "Region (PESS)"
rename tag_curr_change curr_change_tag  
replace curr_change_tag=0 if curr_change_tag==.
la var curr_change_tag "Entry flagged: issues w/currency"
order reg_pess astrata 
save "${gsdData}/1-CleanOutput/food.dta", replace


*********************************************************
*Integrate final dataset for non-food consumption
*********************************************************
*correctly consider all values as imputed for the 206 hhs in non-food w/zero non-food cons
use "${gsdTemp}/nfood_hhs_with_zerocons.dta", clear
gen imputed_correct=1 
save "${gsdTemp}/nfood_mi_hhs_zerocons.dta", replace
use "${gsdData}/1-CleanTemp/imputed_nonfood_byitem.dta", clear
merge m:1 strata ea block hh using "${gsdTemp}/nfood_mi_hhs_zerocons.dta", keep (master match) nogen keepusing(imputed_correct) 
replace imputed_correct=0 if mod_item==0 & imputed_correct==1
replace imputed_correct=0 if mod_item==mod_opt & imputed_correct==1
replace imputed=imputed_correct if imputed_correct<.
drop imputed_correct
save "${gsdData}/1-CleanTemp/imputed_nonfood_byitem.dta", replace
*integrate into the final dataset for non-food consumption (including 206 hhs)
use "${gsdData}/1-CleanTemp/nonfood.dta", clear
drop if weight>=. 
merge 1:1 strata ea block hh itemid using "${gsdData}/1-CleanTemp/imputed_nonfood_byitem.dta", assert(match using) nogen
drop if small == 1
drop pr_usd small
order cons_usd_org cons_usd_imp imputed, after(mod_item)
rename (cons_usd_org cons_usd_imp) (purc_usd_org purc_usd_imp)
label var purc_usd_imp "Purchase value (imputed) in curr USD 7d"
label var purc_usd_org "Purchase value in curr USD 7d"
order region strata ea block hh hhsize enum weight mod_opt itemid recall mod_item purc_usd_org purc_usd_imp imputed 
*label items as non-administered
foreach var of varlist purc-purc_tag {
   replace `var'=.z if imputed==1
}
*correct for the hhs with zero consumption as not every item was not administered 
merge m:1 strata ea block hh using "${gsdTemp}/nfood_hhs_with_zerocons.dta", keep(master match)
foreach var of varlist purc-purc_tag {
   replace `var'=. if _merge==3 & (mod_opt==mod_item | mod_item==0)
}
drop _merge
sort strata ea block hh
*correctly code each variable 
*items in the core should have a zero or positive value and not missing
replace purc_usd_org=0 if purc_usd_org>=. & mod_item==0
replace purc_usd_imp=0 if purc_usd_org==0 & mod_item==0
*items in the administered module should have a zero or positive value and not missing
replace purc_usd_org=0 if purc_usd_org>=. & mod_item==mod_opt
replace purc_usd_imp=0 if purc_usd_org==0 & mod_item==mod_opt
*items in the non-admin module should be coded as such
replace purc_usd_org=.z if purc_usd_org>=. & mod_opt!=mod_item & mod_item!=0
*check imputed equals collected for the core and assinged modules 
assert round(purc_usd_org-purc_usd_imp,.01)==0 if imputed==0
*other checks for consistency
assert purc_usd_org>=. if mod_opt!=mod_item & mod_item!=0
assert imputed==1 if mod_opt!=mod_item & mod_item!=0
assert imputed==0 if mod_opt==mod_item | mod_item==0
assert purc_usd_org==.z if imputed==1
assert purc_usd_imp>0 if imputed==1
assert purc_usd_org==purc_usd_imp & purc_usd_imp==0 if purc==.
rename region reg_pess
la var reg_pess "Region (PESS)"
rename tag_curr_change curr_change_tag  
replace curr_change_tag=0 if curr_change_tag==.
la var curr_change_tag "Entry flagged: issues w/currency"
order reg_pess astrata 
save "${gsdData}/1-CleanOutput/nonfood.dta", replace
