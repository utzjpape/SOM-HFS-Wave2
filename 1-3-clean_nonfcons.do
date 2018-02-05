*Process to clean the non-food consumption dataset 

set more off
set seed 23081580 
set sortseed 11041555


********************************************************************
*Open the food dataset and prepare the file
********************************************************************
use "${gsdData}/1-CleanInput/nfood.dta", clear
*Include households with no record for non food items
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta"
replace nfoodid=1001 if nfoodid>=.
keep purc strata ea block hh nfoodid
reshape wide purc , i(strata ea block hh) j(nfoodid)
reshape long
merge 1:1 strata ea block hh nfoodid using "${gsdData}/1-CleanInput/nfood.dta", nogen keep(master match)
*Save the original structure to eventually include records with zero consumption, in order to get the mean consumption by item that ultimately will be assign to records that answered "don't know" or "refused to respond"
keep strata ea block hh nfoodid purc
rename purc purc_original
save "${gsdTemp}/nfood_hhs_fulldataset.dta", replace
*Then we create a list with all the non-food items
use "${gsdData}/1-CleanInput/nfood.dta", clear
rename nfoodid itemid
collapse (mean) mod_item, by(itemid)
save "${gsdData}/1-CleanTemp/items_module_nonfood.dta", replace
*Open the dataset
use "${gsdData}/1-CleanInput/nfood.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", keep(match master) nogen keepusing(weight mod_opt)
order weight mod_opt, after(hh)
drop pr_kdk enum
*Now we identify households with zero consumption of non-food items to include them at the end with zero (not missing values)
collapse (max) strata, by(ea block hh)
save "${gsdTemp}/nfood_hhs_withcons.dta", replace
use "${gsdData}/1-CleanInput/hh.dta", clear
keep strata ea block hh
merge 1:1 strata ea block hh using "${gsdTemp}/nfood_hhs_withcons.dta", nogen keep(master)
save "${gsdTemp}/nfood_hhs_with_zerocons.dta", replace
*Then we create a list with all the non-food items
use "${gsdData}/1-CleanInput/nfood.dta", clear
rename nfoodid itemid
collapse (mean) mod_item, by(itemid)
save "${gsdData}/1-CleanTemp/items_module_nonfood.dta", replace


********************************************************************
*Introduce corrections related to currency issues
********************************************************************
use "${gsdData}/1-CleanInput/nfood.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", keep(match master) nogen keepusing(weight mod_opt)
* Currency splits
* SSH only: ea_reg 2,3,4,5,6,7,8,9,10,11,12,14,15
* SLSH only: ea reg 1, 18
* Both: 13, 16, 17 
* Check that this is true in the data
assert pr_c==4 | pr_c==5 | pr_c>=. if inlist(region, 1, 18)
assert pr_c==2 | pr_c==5 | pr_c>=. if inlist(region, 2,3,4,5,6,7,8,9,10,11,12,14,15)
assert inlist(pr_c, 2, 4, 5) | pr_c>=. if inlist(region, 13, 16, 17)
	
* Define whether an observation is in an SLSH or in an SSH area
cap drop team
* SLSH 
gen team = 1 if inlist(region, 1, 18)
* SSH
replace team = 2 if inlist(region, 2,3,5,6,7,8,9,10,14,15)
replace team = 2 if inlist(region, 4,11,12)

* Now the situations where both currencies are possible to select 
replace team = 1 if inlist(region, 13, 16, 17) & pr_c==4   
replace team = 2 if inlist(region, 13, 16, 17) & pr_c==2  
* we assign team 1 if USD or missing
replace team = 1 if inlist(region, 13, 16, 17) & (pr_c==5 | mi(pr_c)) & mi(team) 
assert !mi(team)
*assert !(team==1 & pr_c==2) 
*assert !(team==2 & pr_c==4) 

*Cleaning rule: change USD to local currency (for each zone) when the price is equal or greater than 1,000
replace pr_c=4 if pr >= 1000 & pr<. & pr_c==5 & team==1
replace pr_c=2 if pr >= 1000 & pr<. & pr_c==5 & inlist(team,2,3)
*Cleaning rule: change local currency larger than 10,000, divide by 1,000 (respondents probably meant Shillings not thousands of shillings)
replace pr = pr/1000 if pr>10000 & pr<.



********************************************************************
*Obtain price in USD and identify issues
********************************************************************
*Include the exchange rate for each zone
merge m:1 team using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(average_er)
*Obtain a price in USD
gen pr_usd=pr if pr_c==5
replace pr_usd=pr/(average_er/1000) if pr_c==2 | pr_c==4
drop average_er
*Cleaning rule: tag prices equal to zero, and replace them by the median by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item
gen purc_tag=1 if pr==0
*Cleaning rule: tag prices purchased but with missing values in prices or currency, and replace them by the median by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item
replace purc_tag=1 if pr>=. |  pr_c>=.


********************************************************************
*Define a min/max threshold for each recall period and make corrections
********************************************************************
*For the max threshold the idea is to expand it (non-linear) as the recall period increases, since the longer recall the more likely households are to underreport consumption
gen recall_d=7 if recall==1
replace recall_d=30 if recall==2
replace recall_d=90 if recall==3
replace recall_d=364.25 if recall==4
gen max_pr=30 if recall_d==7 
replace max_pr=95 if recall_d==30 
replace max_pr=200 if recall_d==90  
replace max_pr=1200 if recall_d==364.25 
*For the min the idea is similar, to increase it with the recall period
gen min_pr=0.05 if recall_d==7 
replace min_pr=0.20 if recall_d==30 
replace min_pr=0.45 if recall_d==90 
replace min_pr=0.80 if recall_d==364.25
*Cleaning rule: tag prices that exceed the min/max threshold by recall period, and replace them by the median by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item
replace purc_tag=1 if pr_usd<min_pr 
replace purc_tag=1 if pr_usd>max_pr & pr_usd<.
drop max_pr min_pr
*Cleaning rule: tag prices that exceed the min/max threshold by item, and replace them by the median by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item
bys nfoodid: egen x=pctile(pr_usd) if purc_tag!=1, p(95) 
bys nfoodid: egen pr_95=max(x)
bys nfoodid: egen y=pctile(pr_usd) if purc_tag!=1, p(01)
bys nfoodid: egen pr_01=max(y)
drop x y 
replace purc_tag=1 if pr_usd<pr_01
replace purc_tag=1 if pr_usd>pr_95 & pr_usd<.


********************************************************************
*Convert all purchases to a 7 day recall period and replace tagged records
********************************************************************
*Convert all purchases to a 7 day recall period
replace pr_usd = pr_usd/recall_d*7
*Replace tagged records with the median by each level of aggregation 
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
*Introduce the replacements for the cleaning rule to the price w/ constraint to the median (between 20 and 0.7 USD)
replace pr_usd=pr_ea_median if (purc_tag==1) & (pr_ea_median<20 & pr_ea_median>0.7) & (pr_ea_count>=5 & pr_ea_count<.)  
replace pr_usd=pr_strata_median if (purc_tag==1) & (pr_strata_median<20 & pr_strata_median>0.7) & (pr_ea_count<5 | pr_ea_count>=. | pr_ea_median>=20 | pr_ea_median<=0.7) & (pr_strata_count>=5 & pr_strata_count<.) 
replace pr_usd=pr_item_median if (purc_tag==1) & (pr_item_median<.) & (pr_ea_count<5 | pr_ea_count>=. | pr_ea_median>=20 | pr_ea_median<=0.7) & (pr_strata_count<5 | pr_strata_count>=. | pr_strata_median>=20 | pr_strata_median<=0.7) 
*Check non-food items with less than 5 observations
tab nfoodid if purc_tag==1 & pr_item_count<5
drop prelim_* pr_ea* pr_strata* pr_item* pr_95 pr_01 


********************************************************************
*Clean purchase value in USD 
********************************************************************
*Cleaning rule: truncate purchase value in USD per item, if it exceeds the mean plus 3 times the standard deviation
gen mean_item=.
levelsof nfoodid, local(items)
quietly foreach item of local items {
   sum pr_usd [aw= weight] if nfoodid==`item', detail
   replace mean_item=r(mean) if nfoodid==`item' 
}	


gen sd_item=.
levelsof nfoodid, local(items)
quietly foreach item of local items {
   sum pr_usd [aw= weight] if nfoodid==`item', detail
   replace sd_item=r(sd) if nfoodid==`item' 
}	
bysort nfoodid: egen prelim_max_pr= max(pr_usd) if pr_usd<=mean_item+3*sd_item
bysort nfoodid: egen max_pr= max(prelim_max_pr)
replace pr_usd = max_pr if pr_usd>mean_item+3*sd_item & max_pr<.
drop prelim_max_pr max_pr mean_item sd_item
save "${gsdTemp}/nfood_clean_byitem.dta", replace


********************************************************************
*Prepare the output files at the item and household level 
********************************************************************
merge 1:1 strata ea block hh nfoodid using "${gsdTemp}/nfood_hhs_fulldataset.dta"
assert purc_original==purc if _merge==3
*Include relevant info to differentiate between zero and items not administered
drop region weight enum mod_opt mod_item _merge
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(region weight enum mod_opt)
merge m:m nfoodid using "${gsdData}/1-CleanInput/nfood.dta", nogen keep(master match) keepusing(mod_item)
*Introduce zero consumption 
replace purc=0 if purc_original>=. & (mod_item==0 | mod_opt==mod_item)
replace pr_usd=0 if purc_original>=. & (mod_item==0 | mod_opt==mod_item)
foreach var in pr_kdk pr pr_c free free_main {
	replace `var'=.z  if purc_original>=. & (mod_item==0 | mod_opt==mod_item)
}
*Correctly label items not administered 
foreach var in purc pr_kdk pr pr_c free free_main {
	replace `var'=.z  if purc>=.
}
*Label variables and save the cleaned version by item
drop purc_original team recall_d
label var pr_usd "Purchase value in current USD per 7 days"
label var purc_tag "Entry flagged: Issues w/prices"
rename nfoodid itemid
order region strata ea block hh enum weight mod_opt mod_item itemid recall
order pr_usd, after(purc_tag)
save "${gsdData}/1-CleanTemp/nonfood.dta", replace
*Now the data is collapsed at the household level and converted into wide format 
collapse (sum) pr_usd, by(strata ea block hh mod_opt mod_item)
reshape wide pr_usd, i(strata ea block hh mod_opt) j(mod_item)
ren pr_usd* cons_nf* 
*Include zero values for optional modules without consumption 
forvalues i=1/4 {
	replace cons_nf`i' = 0 if cons_nf`i'>=. & mod_opt==`i'
	label var cons_nf`i' "Non-Food cons. curr. USD (Mod: `i'): 7d"
}
replace cons_nf0=0 if cons_nf0>=.
label var cons_nf0 "Non-Food cons. curr. USD (Mod: 0): 7d"
forval i=1/4 {
	replace cons_nf`i'=.z if mod_opt!=`i'
}
drop mod_opt
save "${gsdData}/1-CleanTemp/hh_nfcons.dta", replace
