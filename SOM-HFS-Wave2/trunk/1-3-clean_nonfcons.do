* process to clean the non-food consumption dataset 

set more off
set seed 23081580 
set sortseed 11041555

*first we open the food consumption dataset, clean the data and include household weights
use "${gsdData}/1-CleanInput/nonfood.dta", clear
merge m:m strata ea block hh using "${gsdData}/1-CleanTemp/food.dta", keep(match master) nogen keepusing(weight_cons opt_mod)
duplicates drop
order weight_cons opt_mod, after(hh)
drop pr_kdk free_other enum

*next we exclude the 53 households that will have missing values in consumption, and 1 households with zero food consumption in the core module
preserve 
keep if weight_cons>=.
collapse (max) opt_mod, by(strata ea block hh)
save "${gsdTemp}/all_hhs_missing.dta", replace
restore 
drop if weight_cons>=.

*save the original structure to eventually include records with zero consumption, in order to get the mean consumption by item (with these observations ) that ultimately will be assign to records that answered "don't know" or "refused to respond"
save "${gsdTemp}/nfood_hhs_fulldataset.dta", replace

*now we identify 206 households with zero consumption of non-food items to include them at the end with zero (not missing values)
drop if purc==.z | purc==0 
drop if nfoodid==1087 | nfoodid==1073 | nfoodid==1061
collapse (max) opt_mod team weight_cons, by(strata ea block hh)
save "${gsdTemp}/nfood_hhs_withcons.dta", replace
use "${gsdTemp}/nfood_hhs_fulldataset.dta", clear
collapse (max) opt_mod team weight_cons, by(strata ea block hh)
merge 1:1 strata ea block hh using "${gsdTemp}/nfood_hhs_withcons.dta", nogen keep(master)
save "${gsdTemp}/nfood_hhs_with_zerocons.dta", replace

*then we create a list with all the non-food items
use "${gsdData}/1-CleanInput/nonfood.dta", clear
rename nfoodid itemid
collapse (mean) mod_item, by(itemid)
save "${gsdData}/1-CleanTemp/items_module_nonfood.dta", replace

*continue removing non-administered, non-consumed items and records that answered "don't know" or "refused to respond"
use "${gsdTemp}/nfood_hhs_fulldataset.dta", clear
drop if purc==.z | purc==0 | purc==.a | purc==.b

*introduce the recall period
merge m:1 nfoodid using "${gsdData}/1-CleanInput/recall_days.dta", nogen assert(match)
order recall_d, after(opt_mod)

*next we introduce corrections related to currency issues
*cleaning rule: replace Somaliland shillings for Somali shillings, as they should not be used outside of Somaliland
replace pr_c=2 if pr_c==4 & zone!=3
assert pr_c==3 | pr_c==4 | pr_c==5 if (zone==3 & pr_c<.)
assert pr_c==1 | pr_c==2 | pr_c==5 if (zone!=3 & pr_c<.)
*cleaning rule: change USD to local currency (for each zone) when the price is equal or greater than 1,000
replace pr_c=3 if pr >= 1000 & pr<. & pr_c==5 & zone==3
replace pr_c=1 if pr >= 1000 & pr<. & pr_c==5 & zone!=3
*cleaning rule: change local currency to thousands (for each zone) when the price is equal or smaller than 500
replace pr_c=4 if pr <= 500 & pr_c==3
replace pr_c=2 if pr <= 500 & pr_c==1
*cleaning rule: change local currency larger than 500,000 (divide by 10)
replace pr=pr/10 if pr>500000 & pr<.

*include the exchange rate for each zone
merge m:1 zone using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(average_er)

*obtain a price in USD
gen pr_usd=pr if pr_c==5
replace pr_usd=pr/average_er if pr_c==1 | pr_c==3
replace pr_usd=pr/(average_er/1000) if pr_c==2 | pr_c==4
drop average_er

*cleaning rule: tag prices equal to zero, and replace them by the median by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item
gen purc_tag=1 if pr==0

*cleaning rule: tag prices purchased but with missing values in prices or currency, and replace them by the median by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item
replace purc_tag=1 if pr>=. |  pr_c>=.

*next we define a min/max threshold (USD) for each recall period to exclude outliers, considering all the items
*for the max threshold the idea is to expand it (non-linear) as the recall period increases, since the longer recall the more likely households are to underreport consumption
gen max_pr=30 if recall_d==7 
replace max_pr=95 if recall_d==30 
replace max_pr=200 if recall_d==90  
replace max_pr=1200 if recall_d==364.25 
*for the min the idea is similar, to increase it with the recall period
gen min_pr=0.05 if recall_d==7 
replace min_pr=0.20 if recall_d==30 
replace min_pr=0.45 if recall_d==90 
replace min_pr=0.80 if recall_d==364.25

*cleaning rule: tag prices that exceed the min/max threshold by recall period, and replace them by the median by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item
replace purc_tag=1 if pr_usd<min_pr 
replace purc_tag=1 if pr_usd>max_pr & pr_usd<.
drop max_pr min_pr

*cleaning rule: tag prices that exceed the min/max threshold by item, and replace them by the median by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item
bys nfoodid: egen x=pctile(pr_usd) if purc_tag!=1, p(95) 
bys nfoodid: egen pr_95=max(x)
bys nfoodid: egen y=pctile(pr_usd) if purc_tag!=1, p(01)
bys nfoodid: egen pr_01=max(y)
drop x y 
replace purc_tag=1 if pr_usd<pr_01
replace purc_tag=1 if pr_usd>pr_95 & pr_usd<.

*then we convert all purchases to a 7 day recall period
replace pr_usd = pr_usd/recall_d*7

*replace tagged records with the median by each level of aggregation 
*by ea and nfoodid
bysort nfoodid ea: egen prelim_pr_ea_count= count(pr_usd) if purc_tag!=1
bysort nfoodid ea: egen pr_ea_count= max(prelim_pr_ea_count) 
bysort nfoodid ea: egen prelim_pr_ea_median= median(pr_usd) if purc_tag!=1
bysort nfoodid ea: egen pr_ea_median= max(prelim_pr_ea_median)
*by strata and nfoodid
bysort nfoodid strata: egen prelim_pr_strata_count= count(pr_usd) if purc_tag!=1
bysort nfoodid strata: egen pr_strata_count= max(prelim_pr_strata_count)
bysort nfoodid strata: egen prelim_pr_strata_median= median(pr_usd) if purc_tag!=1
bysort nfoodid strata: egen pr_strata_median= max(prelim_pr_strata_median)
*by nfoodid
bysort nfoodid: egen prelim_pr_item_count= count(pr_usd) if purc_tag!=1
bysort nfoodid: egen pr_item_count= max(prelim_pr_item_count)
bysort nfoodid: egen prelim_pr_item_median= median(pr_usd) if purc_tag!=1
bysort nfoodid: egen pr_item_median= max(prelim_pr_item_median)
*introduce the replacements for the cleaning rule to the price w/ constraint to the median (between 20 and 0.7 USD)
replace pr_usd=pr_ea_median if (purc_tag==1) & (pr_ea_median<20 & pr_ea_median>0.7) & (pr_ea_count>=5 & pr_ea_count<.)  
replace pr_usd=pr_strata_median if (purc_tag==1) & (pr_strata_median<20 & pr_strata_median>0.7) & (pr_ea_count<5 | pr_ea_count>=. | pr_ea_median>=20 | pr_ea_median<=0.7) & (pr_strata_count>=5 & pr_strata_count<.) 
replace pr_usd=pr_item_median if (purc_tag==1) & (pr_item_median<.) & (pr_ea_count<5 | pr_ea_count>=. | pr_ea_median>=20 | pr_ea_median<=0.7) & (pr_strata_count<5 | pr_strata_count>=. | pr_strata_median>=20 | pr_strata_median<=0.7) 
*check non-food items with less than 5 observations
tab nfoodid if purc_tag==1 & pr_item_count<5
drop prelim_* pr_ea* pr_strata* pr_item* pr_95 pr_01 

*cleaning rule: truncate purchase value in USD per item, if it exceeds the mean plus 3 times the standard deviation
gen mean_item=.
levelsof nfoodid, local(items)
quietly foreach item of local items {
   sum pr_usd [aw= weight_cons] if nfoodid==`item', detail
   replace mean_item=r(mean) if nfoodid==`item' 
}	


gen sd_item=.
levelsof nfoodid, local(items)
quietly foreach item of local items {
   sum pr_usd [aw= weight_cons] if nfoodid==`item', detail
   replace sd_item=r(sd) if nfoodid==`item' 
}	
bysort nfoodid: egen prelim_max_pr= max(pr_usd) if pr_usd<=mean_item+3*sd_item
bysort nfoodid: egen max_pr= max(prelim_max_pr)
replace pr_usd = max_pr if pr_usd>mean_item+3*sd_item & max_pr<.
drop prelim_max_pr max_pr mean_item sd_item
save "${gsdTemp}/nfood_clean_byitem.dta", replace

*cleaning rule: replace consumption with the mean value (considering zeros) when the response to the consumption of an item was "don't know" or "refused to respond"
*first we use the full dataset to retrive records with zero consumption
use "${gsdTemp}/nfood_hhs_fulldataset.dta", clear
keep zone team strata ea block hh weight_cons nfoodid purc opt_mod mod_item astrata type
rename purc purc_original
save "${gsdTemp}/nfood_hhs_fulldataset_clean.dta", replace
*then we merge the file with the clean version of non-food consumption by item
use "${gsdTemp}/nfood_clean_byitem.dta", clear
merge 1:1 strata ea block hh nfoodid using "${gsdTemp}/nfood_hhs_fulldataset_clean.dta"
assert purc_original==purc if _merge==3
drop if purc_original==.z
*introduce zero consumption to be included in the mean consumption by item
replace pr_usd=0 if purc_original==0
*obtain the mean price per item
bys nfoodid: egen mean_pr_item=mean(pr_usd)
*asign the mean consumption (including zeros) for the item when the response was "don't know" or "refused to respond"
replace pr_usd=mean_pr_item if purc_original==.a | purc_original==.b
replace purc=purc_original
drop _merge mean_pr_item purc_original 

*next we exclude cases with a figure of zero for purchase value or missing values
drop if pr_usd==0 | pr_usd>=.
*label variables and save the cleaned version by item
label var pr_usd "Purchase value in current USD per 7 days"
label var purc_tag "Entry flagged: Issues w/prices"
rename nfoodid itemid
drop zone
order pr_usd, after(mod_item)
drop if itemid==1087 | itemid==1073 | itemid==1061 
save "${gsdData}/1-CleanTemp/nonfood.dta", replace

*now the data is collapsed at the household level and converted into wide format 
collapse (sum) pr_usd, by(strata ea block hh opt_mod mod_item)
reshape wide pr_usd, i(strata ea block hh opt_mod) j(mod_item)
ren pr_usd* cons_nf* 

*next we includes zero values for optional modules without consumption 
forvalues i=1/4 {
	replace cons_nf`i' = 0 if cons_nf`i'>=. & opt_mod==`i'
	label var cons_nf`i' "Non-Food cons. curr. USD (Mod: `i'): 7d"
}
*now, we include zero values for the core module without consumption and correct naming of missing values
replace cons_nf0=0 if cons_nf0>=.
label var cons_nf0 "Non-Food cons. curr. USD (Mod: 0): 7d"
forvalues i=1/4 {
	replace cons_nf`i'=.z if cons_nf`i'>=. 
}
*then we include households with zero and missing values in non-food consumption and save the file
gen dum_cons=1
append using "${gsdTemp}/nfood_hhs_with_zerocons.dta"
foreach var of varlist cons_nf0-cons_nf4  {
    replace `var'=0 if dum_cons>=.
 }
 forvalues i=1/4 {
	replace cons_nf`i'=.z if opt_mod!=`i' & dum_cons>=.
}
append using "${gsdTemp}/all_hhs_missing.dta"
drop dum_cons

*introduce correct nomenclature for these 53 missing households
foreach var of varlist cons_nf0-cons_nf4  {
    replace `var'=.c if `var'==.
}
save "${gsdData}/1-CleanTemp/hh_nfcons.dta", replace



*save a version w/comparable items to Somaliland 2013
use "${gsdData}/1-CleanInput/hh.dta", clear
keep if ( strata==105 & ea==65 & block==11 & hh==7) | ( strata==105 & ea==65 & block==25 & hh==1) | ( strata==105 & ea==65 & block==25 & hh==10) | ( strata==105 & ea==86 & block==20 & hh==8) | ( strata==105 & ea==309 & block==7 & hh==7) | ( strata==105 & ea==310 & block==15 & hh==12) | ( strata==105 & ea==310 & block==20 & hh==10) | ( strata==204 & ea==178 & block==. & hh==2) | ( strata==204 & ea==319 & block==. & hh==1) | ( strata==204 & ea==319 & block==. & hh==8) | ( strata==205 & ea==32 & block==18 & hh==3) | ( strata==301 & ea==259 & block==. & hh==8) | ( strata==302 & ea==296 & block==. & hh==3) | ( strata==304 & ea==58 & block==. & hh==4) | ( strata==304 & ea==164 & block==. & hh==11) | ( strata==304 & ea==233 & block==. & hh==7) | ( strata==304 & ea==251 & block==. & hh==12)
keep strata ea block hh 
save "${gsdTemp}/zero_nf_comparable_2012.dta", replace

use "${gsdData}/1-CleanTemp/nonfood.dta", clear
drop if itemid==1081 | itemid==1087 | itemid==1073 | itemid==1061 

*now the data is collapsed at the household level and converted into wide format 
collapse (sum) pr_usd, by(strata ea block hh opt_mod mod_item)
reshape wide pr_usd, i(strata ea block hh opt_mod) j(mod_item)
ren pr_usd* cons_nf* 

*next we includes zero values for optional modules without consumption 
forvalues i=1/4 {
	replace cons_nf`i' = 0 if cons_nf`i'>=. & opt_mod==`i'
	label var cons_nf`i' "Non-Food cons. curr. USD (Mod: `i'): 7d"
}
*now, we include zero values for the core module without consumption and correct naming of missing values
replace cons_nf0=0 if cons_nf0>=.
label var cons_nf0 "Non-Food cons. curr. USD (Mod: 0): 7d"
forvalues i=1/4 {
	replace cons_nf`i'=.z if cons_nf`i'>=. 
}
*then we include households with zero and missing values in non-food consumption and save the file
gen dum_cons=1
append using "${gsdTemp}/nfood_hhs_with_zerocons.dta"
foreach var of varlist cons_nf0-cons_nf4  {
    replace `var'=0 if dum_cons>=.
 }
 forvalues i=1/4 {
	replace cons_nf`i'=.z if opt_mod!=`i' & dum_cons>=.
}
append using "${gsdTemp}/all_hhs_missing.dta"
*include 3 additional hhs w/zero cons due to the dropped items 
drop if (strata==101 & ea==104 & block==25 & hh==10) | (strata==101 & ea==303 & block==23 & hh==6) | (strata==101 & ea==317 & block==10 & hh==6)
append using "${gsdTemp}/zero_comparable_2012.dta"
append using "${gsdTemp}/zero_nf_comparable_2012.dta"
drop dum_cons

*introduce correct nomenclature for these 63 missing households
foreach var of varlist cons_nf0-cons_nf4  {
    replace `var'=.c if `var'==.
}
save "${gsdData}/1-CleanTemp/hh_nfcons_comparable_2013.dta", replace

