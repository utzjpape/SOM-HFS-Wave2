*process to clean the food consumption dataset 

set more off
set seed 23081960 
set sortseed 11041965

*first we create a temp file with the identifiers of the 52 households that responded NO to the consumption of every single food item and those that responded NO and a few Don't know/Refused to respond
use "${gsdData}/1-CleanInput/food.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(weight_cons)
drop if cons==.z
*keep only households with no records of consumption
bys strata ea block hh: egen cons_hh=max(cons)
keep if cons_hh==0
bys strata ea block hh: egen include_hh=count(foodid) if cons==0 
*finally keep only 53 households that will have missing values in consumption
drop if include_hh<50 |  include_hh>=.
collapse (first) mod_item, by (strata ea block hh)
save "${gsdTemp}/food_hhs_nocons.dta", replace

*identify 1 households with zero food consumption in the core module
use "${gsdData}/1-CleanInput/food.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(weight_cons)
drop if cons==.z
bys strata ea block hh: egen prelim_cons_hh=sum(cons) if cons==1
bys strata ea block hh: egen cons_hh=max(prelim_cons_hh)
keep if cons_hh==1 & cons==1 & foodid==65 & cons_q_kg==0.75
keep strata ea block hh
save "${gsdTemp}/food_hhs_cons_exclude.dta", replace

*then we create a list with all the food items
use "${gsdData}/1-CleanInput/food.dta", clear
rename foodid itemid
collapse (mean) mod_item, by(itemid)
save "${gsdData}/1-CleanTemp/items_module_food.dta", replace

*now we open the food consumption dataset, clean the data and include household weights
use "${gsdData}/1-CleanInput/food.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(weight_cons)
order weight_cons, after(hh)
drop cons_kdk purc_kdk pr_kdk free_other cons_q_kg_est  purc_q_kg_est

*obtain the optional module for each household 
bys strata ea block hh: egen x=max(mod_item) if cons<.
bys strata ea block hh: egen opt_mod=max(x) 
drop x
order opt_mod, after(hh)
label var opt_mod "Optional module allocated to the hh"

*drop 1 households with zero food consumption in the core module
merge m:1 strata ea block hh using "${gsdTemp}/food_hhs_cons_exclude.dta", nogen keep(master)

*save the original structure to eventually include records with zero consumption, in order to get the mean consumption by item (with these observations ) that ultimately will be assign to records that answered "don't know" or "refused to respond"
save "${gsdTemp}/food_hhs_fulldataset.dta", replace

*remove non-administered, non-consumed items and records that answered "don't know" or "refused to respond"
drop if cons==.z | cons==0 | cons==.a | cons==.b

*tag items with same figure in quantity consumed, quantity purchased and price
*exclude these records from the median estimation (for consumed quantity), and eventually replace their consumed quantity by the median
gen cons_same_figures_tag=1 if (cons==1 & cons_q<.) & (cons_q == purc_q) & (purc_q == pr) 

*tag items with same figure for quantity purchased and price
*exclude these records from the median estimation (for purchase quantity and unit price), and eventually replace their unit price by the median
gen purc_same_figures_tag=1 if (purc==1 & purc_q<.) & (purc_q == pr) 

*tag units where a record has the same figure in quantity consumed and purchased, and different units
gen different_u_tag=1 if (cons_q==purc_q ) & (cons_u!=purc_u) & (cons==1 & cons_q<. & purc_q<.)
*cleaning rule: the correct unit is the one that takes the variable (consumption or purchase) closer to the weighted median value in the distribution of that variable for the same item 
*obtain the median quantity consumed/purchased
local ls = "cons purc"
levelsof foodid, local(items)
foreach s of local ls {
 gen `s'_kg_median=.
 quietly foreach item of local items {
	   sum `s'_q_kg [aw= weight_cons] if foodid==`item' & `s'_same_figures_tag!=1, detail
	   replace `s'_kg_median=r(p50) if foodid==`item'  
}
}
*obtain the absolute difference between the quantity and the median for the respective item
gen diff_cons_kg=abs(cons_q_kg - cons_kg_median) if different_u_tag==1
gen diff_purc_kg=abs(purc_q_kg - purc_kg_median) if different_u_tag==1
*introduce the replacements
replace cons_u=purc_u if diff_purc_kg<diff_cons_kg & different_u_tag==1
replace cons_q_kg=purc_q_kg if diff_purc_kg<diff_cons_kg & different_u_tag==1
replace purc_u=cons_u if diff_purc_kg>diff_cons_kg & different_u_tag==1
replace purc_kg=cons_kg if diff_purc_kg>diff_cons_kg & different_u_tag==1
drop cons_kg_median purc_kg_median diff_cons_kg diff_purc_kg

*then we merge the dataset with the file containing the conversion for all the units and all the products
merge m:1 cons_u foodid using "${gsdData}/1-CleanInput/units_all_items.dta", nogen keep(master match) keepusing(kg)
rename kg kg_cons
merge m:1 purc_u foodid using "${gsdData}/1-CleanInput/units_all_items.dta", nogen keep(master match) keepusing(kg)
rename kg kg_purc

*next we introduce these corrections for specific unit-items		
gen cons_q_kg_correction=cons_q*kg_cons
replace cons_q_kg=cons_q_kg_correction if cons_q_kg!=cons_q_kg_correction & cons_q_kg_correction<. 
gen purc_q_kg_correction=purc_q*kg_purc
replace purc_q_kg=purc_q_kg_correction if purc_q_kg!=purc_q_kg_correction & purc_q_kg_correction<. 
drop kg_cons kg_purc cons_q_kg_correction purc_q_kg_correction

*then we start corrections related to units
*cleaning rule: manual corrections for consumption/purchase quantity in kg casued by an issue with units in following cases 1) when there is a difference between automatic conversion to kg and the enumerator estimate; 2) quantities consumed below 1 gram; and 3) other ad-hoc 
gen cons_u_tag=.
gen purc_u_tag=.
local ls = "cons purc"
foreach s of local ls{
	*250 ml tin (0.25kg): if quantity<=.03, multiply by 4 because the enumerator probably meant ml
	replace `s'_u_tag=1            if (`s'_q_kg<=0.03 & `s'_u==3 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg*4    if (`s'_q_kg<=0.03 & `s'_u==3 & `s'==1 & `s'_q<.)
	*animal back, ribs, shoulder, thigh, head or leg: if quantity>=7 kg, divide by 10 because the enumerator probably meant kg
	replace `s'_u_tag=1            if (`s'_q_kg>=7 & `s'_u>=6 & `s'_u<=11 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10   if (`s'_q_kg>=7 & `s'_u>=6 & `s'_u<=11 & `s'==1 & `s'_q<.)
	*basket or dengu (2 kg): if quantity>=10 divide by 10 because the enumerator probably meant kg
	replace `s'_u_tag=1            if (`s'_q_kg>=10 & `s'_u==12 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10   if (`s'_q_kg>=10 & `s'_u==12 & `s'==1 & `s'_q<.)
	*bottle (1 kg): if quantity>=10 divide by 10 because the enumerator probably meant kg
	replace `s'_u_tag=1            if (`s'_q_kg>=10 & `s'_u==13 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10   if (`s'_q_kg>=10 & `s'_u==13 & `s'==1 & `s'_q<.)
	*cup (200g): if quantity>200 by 2 because the enumerator probably meant grams
	replace `s'_u_tag=1            if (`s'_q_kg>=0.21 & `s'_u==14 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/2    if (`s'_q_kg>=0.21 & `s'_u==14 & `s'==1 & `s'_q<.)
	*faraasilad (12kg): if quantity>12 by 12 because the enumerator probably meant kg
	replace `s'_u_tag=1             if (`s'_q_kg>12 & `s'_u==15 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/12    if (`s'_q_kg>12 & `s'_u==15 & `s'==1 & `s'_q<.)
	*gram: if quantity<=0.001 (<1 gram) & item is a spice, then multiply by 100 because the enumerator probably meant grams
	replace `s'_u_tag=1             if (`s'_q_kg<=0.0011 & `s'_u==16 & `s'==1 & `s'_q<.) & (foodid==32 | foodid==95 | foodid==96 | foodid==97 | foodid==98 | foodid==102 | foodid==106 | foodid==107 | foodid==108 | foodid==111 | foodid==100 | foodid==103)
	replace `s'_q_kg=`s'_q_kg*100   if (`s'_q_kg<=0.0011 & `s'_u==16 & `s'==1 & `s'_q<.) & (foodid==32 | foodid==95 | foodid==96 | foodid==97 | foodid==98 | foodid==102 | foodid==106 | foodid==107 | foodid==108 | foodid==111 | foodid==100 | foodid==103)
	*gram: if quantity<=0.001 (<1 gram) & item is not a spice, then multiply by 1,000 because the enumerator probably meant kg
	replace `s'_u_tag=1              if (`s'_q_kg<=0.0011 & `s'_u==16 & `s'==1 & `s'_q<.) & (foodid!=32 | foodid!=95 | foodid!=96 | foodid==97 | foodid==98 | foodid==102 | foodid==106 | foodid==107 | foodid==108 | foodid==111 | foodid==100 | foodid==103)
	replace `s'_q_kg=`s'_q_kg*1000   if (`s'_q_kg<=0.0011 & `s'_u==16 & `s'==1 & `s'_q<.) & (foodid!=32 | foodid!=95 | foodid!=96 | foodid==97 | foodid==98 | foodid==102 | foodid==106 | foodid==107 | foodid==108 | foodid==111 | foodid==100 | foodid==103)	
	*haaf (25 kg): if quantity>=25, divide by 25 because the enumerator probably meant kg
	replace `s'_u_tag=1             if (`s'_q_kg>=25 & `s'_u==17 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/25    if (`s'_q_kg>=25 & `s'_u==17 & `s'==1 & `s'_q<.)
	*heap (700g): if quantity >=0.69 divide by 7 because the enumerator probably meant grams
	replace `s'_u_tag=1             if (`s'_q_kg>=0.69 & `s'_u==18 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/7     if (`s'_q_kg>=0.69 & `s'_u==18 & `s'==1 & `s'_q<.)
	*kilogram: if quantity >=100 divide by 1,000 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=100 & `s'_u==19 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/1000     if (`s'_q_kg>=100 & `s'_u==19 & `s'==1 & `s'_q<.)
    *large bag (50 kg): if quantity >=50 divide by 50 because the enumerator probably meant kg
	replace `s'_u_tag=1                if (`s'_q_kg>=50 & `s'_u==20 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/50       if (`s'_q_kg>=50 & `s'_u==20 & `s'==1 & `s'_q<.)
	*liter: if quantity >=10 divide by 10 because the enumerator probably meant liters
	replace `s'_u_tag=1                if (`s'_q_kg>=10 & `s'_u==21 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10       if (`s'_q_kg>=10 & `s'_u==21 & `s'==1 & `s'_q<.)
	*Madal/Nus kilo ruba (0.75kg): if quantity >=7.5 divide by 10 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=7.5 & `s'_u==22 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10       if (`s'_q_kg>=7.5 & `s'_u==22 & `s'==1 & `s'_q<.)
	*meals (300g): if quantity >2.1 (one meal per day) divide by 10 because the enumerator probably meant grams	
	replace `s'_u_tag=1                if (`s'_q_kg>2.1 & `s'_u==23 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10       if (`s'_q_kg>2.1 & `s'_u==23 & `s'==1 & `s'_q<.)
	*packet sealed box/container (500g): if quantity >=5 divide by 10 because the enumerator probably meant grams		
	replace `s'_u_tag=1                if (`s'_q_kg>=5 & `s'_u==24 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10        if (`s'_q_kg>=5 & `s'_u==24 & `s'==1 & `s'_q<.)
	*piece (large - 300g): if quantity >=3 divide by 10 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=3 & `s'_u==25 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10       if (`s'_q_kg>=3 & `s'_u==25 & `s'==1 & `s'_q<.)
	*piece (small - 150g): if quantity >=1.5 divide by 10 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=1.5 & `s'_u==26 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10       if (`s'_q_kg>=1.5 & `s'_u==26 & `s'==1 & `s'_q<.)
	*rufuc/Jodha (12.5kg): if quantity >=12.5 divide by 10 because the enumerator probably meant kg
	replace `s'_u_tag=1                if (`s'_q_kg>=12.5 & `s'_u==27 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10       if (`s'_q_kg>=12.5 & `s'_u==27 & `s'==1 & `s'_q<.)
	*saxarad (20kg): if quantity >=20 divide by 10 because the enumerator probably meant kg
	replace `s'_u_tag=1                if (`s'_q_kg>=20 & `s'_u==28 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10       if (`s'_q_kg>=20 & `s'_u==28 & `s'==1 & `s'_q<.)
	*small bag (1 kg): if quantity>=10 divide by 10 because the enumerator probably meant grams		
	replace `s'_u_tag=1                if (`s'_q_kg>=10 & `s'_u==29 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg/10       if (`s'_q_kg>=10 & `s'_u==29 & `s'==1 & `s'_q<.)
	*teaspoon (10 g): if quantity<0.009 multiply by 10 because the enumerator probably meant grams			
	replace `s'_u_tag=1                if (`s'_q_kg<0.009 & `s'_u==30 & `s'==1 & `s'_q<.)
	replace `s'_q_kg=`s'_q_kg*10       if (`s'_q_kg<0.009 & `s'_u==30 & `s'==1 & `s'_q<.)
}
*correct remaining cases where consumption or purchase was less than 1 gram
*cleaning rule: multiply by 100 if consumption is less than 1 gram
replace cons_q_kg=cons_q_kg*100 if cons_q_kg<=.0011
replace purc_q_kg=purc_q_kg*100 if purc_q_kg<=.0011

*next we introduce corrections related to currency issues
*cleaning rule: replace Somaliland shillings for Somali shillings, as they should not be used outside of Somaliland
replace pr_c=1 if pr_c==3 & zone!=3
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

*tag records that reported to have consumed/purchased the item but do not report a quantity 
gen cons_q_tag=1 if cons==1 & cons_q>=.
gen purc_q_tag=1 if purc==1 & purc_q>=.
*include previous tag for records with same figure in quantity consumed/purchased
replace cons_q_tag=1 if cons_same_figures_tag==1
*include a constraint for cases with consumption>25 kg per item
replace cons_q_tag=1 if cons_q_kg>25

*cleaning rule: replace tagged records with the median consumption/purchased quantity (per kg) by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item. Exclude quantities greater than 25 kg per item  
gen xq_cons =cons_q_kg if cons_q_tag!=1
gen xq_purc =purc_q_kg if purc_q_tag!=1
*obtain the weigthed median (quantity per kg) by level of aggregation
local ls = "cons purc"
foreach s of local ls {
	*by ea and foodid
	bysort foodid ea: egen prelim_`s'_q_kg_ea_count= count(`s'_q_kg) if `s'_same_figures_tag!=1 & `s'_q_tag!=1 & xq_`s'<=25
	bysort foodid ea: egen `s'_q_kg_ea_count= max(prelim_`s'_q_kg_ea_count) 
	bysort foodid ea: egen prelim_`s'_q_kg_ea_median=median(xq_`s') if `s'_same_figures_tag!=1 & xq_`s'<=25
	bysort foodid ea: egen `s'_q_kg_ea_median=max(prelim_`s'_q_kg_ea_median) 
	*by strata and foodid	
	bysort foodid strata: egen prelim_`s'_q_kg_strata_count= count(`s'_q_kg) if `s'_same_figures_tag!=1 & `s'_q_tag!=1 & xq_`s'<=25
	bysort foodid strata: egen `s'_q_kg_strata_count= max(prelim_`s'_q_kg_strata_count) 
	bysort foodid strata: egen prelim_`s'_q_kg_strata_median=median(xq_`s') if `s'_same_figures_tag!=1 & xq_`s'<=25
	bysort foodid strata: egen `s'_q_kg_strata_median=max(prelim_`s'_q_kg_strata_median)
	*by foodid	
	bysort foodid: egen prelim_`s'_q_kg_item_count= count(`s'_q_kg) if `s'_same_figures_tag!=1 & `s'_q_tag!=1 & xq_`s'<=25
	bysort foodid: egen `s'_q_kg_item_count= max(prelim_`s'_q_kg_item_count) 
	bysort foodid: egen prelim_`s'_q_kg_item_median=median(xq_`s') if `s'_same_figures_tag!=1 & xq_`s'<=25
    bysort foodid: egen `s'_q_kg_item_median=max(prelim_`s'_q_kg_item_median) 
}
*introduce the replacements for the cleaning rule to the quantity consumed/purchased per kg (with a median <20 kg and >0.02 kg)
local ls = "cons purc"
foreach s of local ls {
replace `s'_q_kg=`s'_q_kg_ea_median if (`s'_q_tag==1) & (`s'_q_kg_ea_median<20 & `s'_q_kg_ea_median>0.02) & (`s'_q_kg_ea_count>=5 & `s'_q_kg_ea_count<.)
replace `s'_q_kg=`s'_q_kg_strata_median if (`s'_q_tag==1) & (`s'_q_kg_strata_median<20 & `s'_q_kg_strata_median>0.02) & (`s'_q_kg_ea_count<5 | `s'_q_kg_ea_count>=. | `s'_q_kg_ea_median>=20 | `s'_q_kg_ea_median<=0.02) & (`s'_q_kg_strata_count>=5 & `s'_q_kg_strata_count<.)
replace `s'_q_kg=`s'_q_kg_item_median if (`s'_q_tag==1) & (`s'_q_kg_item_median<.) & (`s'_q_kg_ea_count<5 | `s'_q_kg_ea_count>=. | `s'_q_kg_ea_median>=20 | `s'_q_kg_ea_median<=0.02) & (`s'_q_kg_strata_count<5 | `s'_q_kg_strata_count>=. | `s'_q_kg_strata_median>=20 | `s'_q_kg_strata_median<=0.2) 
}
*check if there are food items with less than 5 observations
tab foodid if purc_q_tag==1 & purc_q_kg_item_count<5
tab foodid if cons_q_tag==1 & cons_q_kg_item_count<5
drop prelim_* xq_cons xq_purc purc_q_kg_ea_count purc_q_kg_strata_count purc_q_kg_item_count cons_q_kg_ea_count cons_q_kg_strata_count cons_q_kg_item_count cons_q_kg_ea_median purc_q_kg_ea_median cons_q_kg_strata_median purc_q_kg_strata_median cons_q_kg_item_median purc_q_kg_item_median

*include the exchange rate for each zone
merge m:1 zone using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(average_er)

*obtain a price in USD
gen pr_usd=pr if pr_c==5
replace pr_usd=pr/average_er if pr_c==1 | pr_c==3
replace pr_usd=pr/(average_er/1000) if pr_c==2 | pr_c==4
drop average_er

*obtain unit price (USD) per kilo
gen unit_price=pr_usd/purc_q_kg

*tag records that reported 1) to have purchased the item but do not report a price; 2) a quantity consumed but not purchased; or 3) a price equal to zero 
gen purc_p_tag=1 if purc==1 & pr>=.
replace purc_p_tag=1 if cons==1 & purc!=1
replace purc_p_tag=1 if pr<=0
*include previous tag for records with same figure in quantity purchased and price
replace purc_p_tag=1 if purc_same_figures_tag==1
*include a constraint for cases with a unit price>20 USD & unit price<.005 USD
replace purc_p_tag=1 if unit_price>20
replace purc_p_tag=1 if unit_price<0.005
*cleaning rule: replace tagged records with the median unit price by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item. Exclude prices >20 USD and <0.005 
gen xq = unit_price if purc_p_tag!=1
*obtain the weigthed median (unit_price) by level of aggregation
*by ea and foodid
bysort foodid ea: egen prelim_unit_price_ea_count= count(unit_price) if purc_same_figures_tag!=1 & purc_p_tag!=1 & xq<=20 & xq>=0.005
bysort foodid ea: egen unit_price_ea_count= max(prelim_unit_price_ea_count) 
bysort foodid ea: egen prelim_unit_price_ea_median= median(unit_price) if purc_same_figures_tag!=1 & xq<=20 & xq>=0.005
bysort foodid ea: egen unit_price_ea_median= max(prelim_unit_price_ea_median)
*by strata and foodid
bysort foodid strata: egen prelim_unit_price_strata_count= count(unit_price) if purc_same_figures_tag!=1 & purc_p_tag!=1 & xq<=20 & xq>=0.005
bysort foodid strata: egen unit_price_strata_count= max(prelim_unit_price_strata_count)
bysort foodid strata: egen prelim_unit_price_strata_median= median(unit_price) if purc_same_figures_tag!=1 & xq<=20 & xq>=0.005
bysort foodid strata: egen unit_price_strata_median= max(prelim_unit_price_strata_median)
*by foodid
bysort foodid: egen prelim_unit_price_item_count= count(unit_price) if purc_same_figures_tag!=1 & purc_p_tag!=1 & xq<=20 & xq>=0.005
bysort foodid: egen unit_price_item_count= max(prelim_unit_price_item_count)
bysort foodid: egen prelim_unit_price_item_median= median(unit_price) if purc_same_figures_tag!=1 & xq<=20 & xq>=0.005
bysort foodid: egen unit_price_item_median= max(prelim_unit_price_item_median)
*introduce the replacements for the cleaning rule to the unit price per kg (with a median <15 UDS and >0.2 USD)
replace unit_price=unit_price_ea_median if (purc_p_tag==1) & (unit_price_ea_median<15 & unit_price_ea_median>0.2) & (unit_price_ea_count>=5 & unit_price_ea_count<.)  
replace unit_price=unit_price_strata_median if (purc_p_tag==1) & (unit_price_strata_median<15 & unit_price_strata_median>0.2) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=15 | unit_price_ea_median<=0.2) & (unit_price_strata_count>=5 & unit_price_strata_count<.) 
replace unit_price=unit_price_item_median if (purc_p_tag==1) & (unit_price_item_median<.) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=15 | unit_price_ea_median<=0.2) & (unit_price_strata_count<5 | unit_price_strata_count>=. | unit_price_strata_median>=15 | unit_price_strata_median<=0.2) 
*check if there are food items with less than 5 observations
tab foodid if purc_p_tag==1 & unit_price_item_count<5
drop prelim_* xq unit_price_*

*cleaning rule: replace 1) unit prices in the top 10% and 2) below 0.07 with the median price by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item
set sortseed 11041965
cumul unit_price, gen (unit_price_distribution) equal
*by ea and foodid
bysort foodid ea: egen prelim_unit_price_ea_count= count(unit_price) if unit_price_distribution<0.9
bysort foodid ea: egen unit_price_ea_count= max(prelim_unit_price_ea_count) 
bysort foodid ea: egen prelim_unit_price_ea_median= median(unit_price) if unit_price_distribution<0.9
bysort foodid ea: egen unit_price_ea_median= max(prelim_unit_price_ea_median)
*by strata and foodid
bysort foodid strata: egen prelim_unit_price_strata_count= count(unit_price) if unit_price_distribution<0.9
bysort foodid strata: egen unit_price_strata_count= max(prelim_unit_price_strata_count)
bysort foodid strata: egen prelim_unit_price_strata_median= median(unit_price) if unit_price_distribution<0.9
bysort foodid strata: egen unit_price_strata_median= max(prelim_unit_price_strata_median)
*by foodid
bysort foodid: egen prelim_unit_price_item_count= count(unit_price) if unit_price_distribution<0.9
bysort foodid: egen unit_price_item_count= max(prelim_unit_price_item_count)
bysort foodid: egen prelim_unit_price_item_median= median(unit_price) if unit_price_distribution<0.9
bysort foodid: egen unit_price_item_median= max(prelim_unit_price_item_median)
*introduce the replacements for the cleaning rule to unit price per kg
replace unit_price=unit_price_ea_median if (unit_price_distribution>=0.9) & (unit_price_ea_median<. & unit_price_ea_median>0.2) & (unit_price_ea_count>=5 & unit_price_ea_count<.)  
replace unit_price=unit_price_strata_median if (unit_price_distribution>=0.9) & (unit_price_strata_median<. & unit_price_strata_median>0.2) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=. | unit_price_ea_median<=0.2) & (unit_price_strata_count>=5 & unit_price_strata_count<.) 
replace unit_price=unit_price_item_median if (unit_price_distribution>=0.9) & (unit_price_item_median<.) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=. | unit_price_ea_median<=0.2) & (unit_price_strata_count<5 | unit_price_strata_count>=. | unit_price_strata_median>=. | unit_price_strata_median<=0.2) 
replace unit_price=unit_price_ea_median if (unit_price<0.07) & (unit_price_ea_median<. & unit_price_ea_median>0.2) & (unit_price_ea_count>=5 & unit_price_ea_count<.)  
replace unit_price=unit_price_strata_median if (unit_price<0.07) & (unit_price_strata_median<. & unit_price_strata_median>0.2) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=. | unit_price_ea_median<=0.2) & (unit_price_strata_count>=5 & unit_price_strata_count<.) 
replace unit_price=unit_price_item_median if (unit_price<0.07) & (unit_price_item_median<.) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=. | unit_price_ea_median<=0.2) & (unit_price_strata_count<5 | unit_price_strata_count>=. | unit_price_strata_median>=. | unit_price_strata_median<=0.2) 
drop prelim_* unit_price_*

*obtain consumption in USD
gen cons_usd=cons_q_kg*unit_price
label var cons_usd "Current consumption in USD (7 days)"

*cleaning rule: truncate the consumption value in USD if the value exceeds the mean plus 3 times the standard deviation
gen x=.
levelsof foodid, local(items)
quietly foreach item of local items {
   sum cons_usd [aw= weight_cons] if foodid==`item', detail
   replace x=r(mean) if foodid==`item'  
}	
gen y=.
levelsof foodid, local(items)
quietly foreach item of local items {
   sum cons_usd [aw= weight_cons] if foodid==`item', detail
   replace y=r(sd) if foodid==`item'  
}	
bysort foodid: egen z = max(cons_usd) if cons_usd<=x+3*y
bysort foodid: egen zz = max(z)
replace cons_usd = zz if cons_usd>x+3*y & cons_usd<.
drop x y z zz
save "${gsdTemp}/food_clean_byitem.dta", replace

*cleaning rule: replace consumption with the mean value (considering zeros) when the response to the consumption of an item was "don't know" or "refused to respond"
*first we use the full dataset to retrive records with zero consumption
use "${gsdTemp}/food_hhs_fulldataset.dta", clear
keep zone team strata ea block hh weight_cons foodid cons opt_mod mod_item astrata type
rename cons cons_original
save "${gsdTemp}/food_hhs_fulldataset_clean.dta", replace
*then we merge the file with the clean version of food consumption by item
use "${gsdTemp}/food_clean_byitem.dta", clear
merge 1:1 strata ea block hh foodid using "${gsdTemp}/food_hhs_fulldataset_clean.dta"
assert cons_original==cons if _merge==3
*exclude 52 households that responded "NO" or mostly "NO" and "Don't know"/"Refused to respond" to every single food item; they will be missing values
drop if cons_original==.z
*keep only households with no records of consumption
bys strata ea block hh: egen cons_hh=max(cons_original)
bys strata ea block hh: egen exclude_hh=count(foodid) if cons_original==0 & cons_hh==0
*finally keep only households that will have missing values in consumption
drop if exclude_hh>50 &  exclude_hh<. 
gen d=1
bys strata ea block hh: egen x=sum(d) if cons_hh==0 
drop if x<10
drop x d
*introduce zero consumption to be included in the mean consumption by item
replace cons_usd=0 if cons_original==0
*obtain the mean consumption per item
bys foodid: egen mean_cons_item=mean(cons_usd)
*asign the mean consumption (including zeros) for the item when the response was "don't know" or "refused to respond"
replace cons_usd=mean_cons_item if cons_original==.a | cons_original==.b
replace cons=cons_original
drop _merge mean_cons_item cons_original cons_hh exclude_hh

*next we exclude cases with a figure of zero for consumption value or missing values and save the file 
drop if cons_usd==0 | cons_usd>=.
order zone strata ea block hh weight_cons opt_mod foodid mod_item cons_usd pr_usd unit_price
drop enum
drop zone
rename foodid itemid
label var pr_usd "Current price in USD"
label var unit_price "Current price per Kg in USD"
label var cons_same_figures_tag "Entry w/same figure in quantity consumed, purchased and price"
label var purc_same_figures_tag "Entry w/same figure for quantity purchased and price"
label var different_u_tag "Entry w/same figure in quantity consumed & purchased, yet different units"
label var cons_u_tag "Entry flagged: issues w/units in consumption"
label var purc_u_tag "Entry flagged: issues w/units in purchase"
label var cons_q_tag "Entry flagged: issues w/quantity in consumption"
label var purc_q_tag "Entry flagged: issues w/quantity in purchase"
label var purc_p_tag "Entry flagged: issues w/prices"
save "${gsdData}/1-CleanTemp/food.dta", replace

*now the data is collapsed at the household level and converted into wide format 
use "${gsdData}/1-CleanTemp/food.dta", clear
collapse (sum) cons_usd, by(strata ea block hh opt_mod mod_item)
reshape wide cons_usd, i(strata ea block hh opt_mod) j(mod_item)
ren cons_usd* cons_f* 

*then we includes zero values for optional modules without consumption and correct naming of missing values
forvalues i=1/4 {
	replace cons_f`i' = 0 if cons_f`i'>=. & opt_mod==`i'
	label var cons_f`i' "Food consumption in current USD (Mod: `i'): 7d"
}
replace cons_f0=0 if cons_f0>=.
label var cons_f0 "Food consumption in current USD (Mod: 0): 7d"
forvalues i=1/4 {
	replace cons_f`i'=.z if cons_f`i'>=. 
}
*next, we include missing values for households that 1) responded NO to the consumption of every single item in food consumption; and 2) hhs with only 1 record of consumption and non-credible item/quantity for food consumption
append using "${gsdTemp}/food_hhs_nocons.dta"
append using "${gsdTemp}/food_hhs_cons_exclude.dta"
drop mod_item

*introduce correct nomenclature for these 53 missing households
foreach var of varlist cons_f0-cons_f4  {
    replace `var'=.c if `var'==.
}
save "${gsdData}/1-CleanTemp/hh_fcons.dta", replace



*save a version w/comparable items to Somaliland 2013

*identify 3 additional hhs w/zero cons due to the dropped items 
use "${gsdData}/1-CleanInput/hh.dta", clear
keep if (strata==101 & ea==104 & block==25 & hh==10) | (strata==101 & ea==303 & block==23 & hh==6) | (strata==101 & ea==317 & block==10 & hh==6)
keep strata ea block hh 
save "${gsdTemp}/zero_comparable_2012.dta", replace

use "${gsdData}/1-CleanTemp/food.dta", clear
drop if itemid==46 | (itemid>=103 & itemid<=122)

*now the data is collapsed at the household level and converted into wide format 
collapse (sum) cons_usd, by(strata ea block hh opt_mod mod_item)
reshape wide cons_usd, i(strata ea block hh opt_mod) j(mod_item)
ren cons_usd* cons_f* 

*then we includes zero values for optional modules without consumption and correct naming of missing values
forvalues i=1/4 {
	replace cons_f`i' = 0 if cons_f`i'>=. & opt_mod==`i'
	label var cons_f`i' "Food consumption in current USD (Mod: `i'): 7d"
}
replace cons_f0=0 if cons_f0>=.
label var cons_f0 "Food consumption in current USD (Mod: 0): 7d"
forvalues i=1/4 {
	replace cons_f`i'=.z if cons_f`i'>=. 
}
*next, we include missing values for households that 1) responded NO to the consumption of every single item in food consumption; and 2) hhs with only 1 record of consumption and non-credible item/quantity for food consumption
append using "${gsdTemp}/food_hhs_nocons.dta"
append using "${gsdTemp}/food_hhs_cons_exclude.dta"
*exclude 3 additional hhs w/zero cons due to the dropped items 
append using "${gsdTemp}/zero_comparable_2012.dta"
drop mod_item

*introduce correct nomenclature for these missing households
foreach var of varlist cons_f0-cons_f4  {
    replace `var'=.c if `var'==.
}
save "${gsdData}/1-CleanTemp/hh_fcons_comparable_2013.dta", replace

