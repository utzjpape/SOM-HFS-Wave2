* cleans and estimates the consumption flow of assets or durable goods

set more off
set seed 23081940 
set sortseed 11041945

*first we open the dataset, clean the data and include household weights
use "${gsdData}/1-CleanTemp/food.dta", clear
collapse (max) weight_cons opt_mod, by(strata ea block hh)
save "${gsdTemp}/assets_pre_weights.dta", replace
use "${gsdData}/1-CleanInput/assets.dta", clear
merge m:1 strata ea block hh using "${gsdTemp}/assets_pre_weights.dta", keep(match master) nogen keepusing(weight_cons opt_mod)
order weight_cons opt_mod, after(hh)
drop enum 

*next we exclude the 52 households that will have missing values in consumption, and 1 households with zero food consumption in the core module
drop if weight_cons>=.
renpfix newest_
rename (y assetid) (year itemid)
*save the original structure to eventually include records with zero consumption, in order to get the mean consumption by item (with these observations ) that ultimately will be assign to records that answered "don't know" or "refused to respond"
save "${gsdTemp}/assets_hhs_fulldataset.dta", replace

*now we identify 492 households with zero consumption of non-food items to include them at the end with zero (not missing values)
drop if own==.z | own==0 
collapse (max) opt_mod, by(strata ea block hh)
save "${gsdTemp}/assets_hhs_withcons.dta", replace
use "${gsdTemp}/assets_hhs_fulldataset.dta", clear
collapse (max) opt_mod, by(strata ea block hh)
merge 1:1 strata ea block hh using "${gsdTemp}/assets_hhs_withcons.dta", nogen keep(master)
save "${gsdTemp}/assets_hhs_with_zerocons.dta", replace

*continue removing non-administered, non-consumed items and records that answered "don't know" or "refused to respond"
use "${gsdTemp}\assets_hhs_fulldataset.dta", clear
drop if own==.z | own==0 | own==.a | own==.b

*next we introduce corrections related to currency issues
foreach measure in pr val {
	*cleaning rule: replace Somaliland shillings for Somali shillings, as they should not be used outside of Somaliland
	replace `measure'_c=1 if `measure'_c==3 & zone!=3
	replace `measure'_c=2 if `measure'_c==4 & zone!=3
	assert `measure'_c==3 | `measure'_c==4 | `measure'_c==5 if (zone==3 & `measure'_c<.)
	assert `measure'_c==1 | `measure'_c==2 | `measure'_c==5 if (zone!=3 & `measure'_c<.)
	*cleaning rule: change USD to local currency (for each zone) when the price is equal or greater than 1,000
	replace `measure'_c=3 if `measure' >= 1000 & `measure'<. & `measure'_c==5 & zone==3
	replace `measure'_c=1 if `measure' >= 1000 & `measure'<. & `measure'_c==5 & zone!=3
	*cleaning rule: change local currency to thousands (for each zone) when the price is equal or smaller than 500
	replace `measure'_c=4 if `measure' <= 500 & `measure'_c==3
	replace `measure'_c=2 if `measure' <= 500 & `measure'_c==1
	*cleaning rule: change local currency larger than 500,000 (divide by 10)
	replace `measure'=`measure'/10 if `measure'>500000 & `measure'<.
}
*include the exchange rate for each zone
merge m:1 zone using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(average_er)

*obtain price and value in USD
foreach measure in pr val {
	gen `measure'_usd=`measure' if `measure'_c==5
	replace `measure'_usd=`measure'/average_er if `measure'_c==1 | `measure'_c==3
	replace `measure'_usd=`measure'/(average_er/1000) if `measure'_c==2 | `measure'_c==4
}
label var pr_usd "Price in USD of newest item at time of purchase"
label var val_usd "Current sell value in USD of newest item"
drop average_er

*cleaning rule: set as missing all observations where zero was the amount paid for the item (current and purchase price)
replace pr_usd=. if pr_usd==0
replace val_usd=. if val_usd==0

*next we begin calculating the vintages of durable items. Items purchased in 2016 (year of the survey) are consider to be one year old (as soon they leave the store they lose value)
gen vintage=.
replace vintage =(2016-year)+1

*cleaning rule: tag vintages with 1) missing values; and 2) vintage >10, and replace them with the weighted median for each item if there are more than 3 observations or the overall median vintage considering all items 
gen tag_vintage=1 if vintage==. 
replace tag_vintage=1 if vintage>10
label var tag_vintage "Entry flagged: Issues w/vintage"
bysort itemid: egen vintage_count=count(vintage) if tag_vintage!=1
gen vintage_median=.
levelsof itemid, local(items)
quietly foreach item of local items {
        sum vintage [aw=weight_cons] if itemid==`item' & tag_vintage!=1, detail
		replace vintage_median=r(p50) if itemid==`item' & vintage_count>3
}
sum vintage [aw=weight_cons] if tag_vintage!=1, detail
gen vintage_gral_median=r(p50)
replace vintage_median=vintage_gral_median if vintage_count<=3
replace vintage=vintage_median if tag_vintage==1
lab var vintage "Years since newest item was purchased"

*generate the weighted median by item/vintage excluding records with missing values, and those with the same figure in price and value 
gen tag_same_pr_val=1 if pr_usd==val_usd & val_usd<. & vintage>1
foreach measure in pr val {
 gen tag_`measure'=1 if `measure'_usd>=.
 gen `measure'_median=.
 bysort itemid year: egen `measure'_count=count(`measure'_usd) if tag_`measure'!=1 & tag_same_pr_val!=1
	levelsof itemid, local(items)
	levelsof vintage, local(vintagelist)
	quietly foreach item of local items {
	  foreach vin of local vintagelist {
		 sum `measure'_usd [aw= weight_cons] if itemid==`item'  & vintage==`vin' & tag_`measure'!=1 & tag_same_pr_val!=1, detail
		 replace `measure'_median=r(p50) if itemid==`item' & vintage==`vin' & `measure'_count>=3 
}
}
 levelsof itemid, local(items)
 quietly foreach item of local items {
   sum `measure'_usd [aw=weight_cons] if itemid==`item' & tag_`measure'!=1 & tag_same_pr_val!=1, detail
   replace `measure'_median=r(p50) if itemid==`item' & `measure'_median==.  
}
}

*cleaning rule: replace missing values in purchase & sell value with the weighted median for each item/vintage 
replace pr_usd=pr_median if tag_pr==1
replace val_usd=val_median if tag_val==1
label var tag_pr "Entry flagged: Issues w/price"
label var tag_val "Entry flagged: Issues w/value"

*cleaning rule: replace price or value with the weighted median by item/vintage for cases with the same figure in price and value and a vintage greater than one. The correct unit is the ones that takes the variable (price or value) closer to the weighted median value in the distribution of that variable for the same item/year 
gen diff_pr= abs(pr_usd - pr_median) if tag_same_pr_val==1
gen diff_val= abs(val_usd - val_median) if tag_same_pr_val==1
replace val_usd=val_median if diff_pr<=diff_val & tag_same_pr_val==1
replace pr_usd=pr_median if diff_pr>diff_val & tag_same_pr_val==1
*adjust the vintage accordingly with the median vintage per item
replace vintage=vintage_median if diff_pr<=diff_val & tag_same_pr_val==1
replace vintage=vintage_median if diff_pr>diff_val & tag_same_pr_val==1
drop vintage_* tag_same_pr_val pr_median pr_count val_median val_count diff_pr diff_val

*check if there are any missing values or items with only a few observation 
tabstat pr_usd, by(itemid) stat(n min max)
*drop incomplete observation, unique to that itemid
drop if itemid==33

*calculate the depreciation rate by item for each household & correct errors 
*set key parameters for cash flow calculation: inflation rate & nominal interest rate
local pi = 0.005
local i = 0.02
*estimate a similar formula to that in Deaton and Zaidi (2002) (3.2)
gen drate= 1 -(1/(1+ 0.005))*((val_usd/pr_usd))^(1/vintage)

*check the depreciation rate (converted to missing and replaced by the weighted median in the next lines) for the following cases: 1) negative converted to missing (cleaned with the median in the next lines); 2) high depreciation rates and & small vintages; and 3) small drates & large vintage
replace drate=. if drate<0
set sortseed 11041945
cumul drate if drate<., gen (drate_distribution) equal
label define ldum_distr 0 "Bottom 10% (0)"  1 "Top 10% (1)"
gen dum_distr=1 if drate_distribution>=.9 & drate_distribution<.
replace dum_distr=0 if drate_distribution<=.1 
label var dum_distr "Dummy indicating top/bottom of distribution"
label values dum_distr ldum_distr
*replace inconsistent cases in the top of the drate distribution
replace drate=. if dum_distr==1 & vintage==1
*replace inconsistent cases in the bottom of the drate distribution
replace drate=. if dum_distr==0 & vintage>=3
drop drate_distribution dum_distr

*cleaning rule: replace by the weighted median the following cases: 1) negative depreciation rates; 2) high depreciation rates and & small vintages; and 3) small drates & large vintage
bysort itemid: egen drate_count=count(drate) 
gen drate_median=.
levelsof itemid, local(items)
quietly foreach item of local items {
        sum drate [aw=weight_cons] if itemid==`item', detail
		replace drate_median=r(p50) if itemid==`item' & drate_count>3
}
sum drate [aw=weight_cons], detail
gen drate_gral_median=r(p50)
replace drate_median=drate_gral_median if drate_count<=3
replace drate=drate_median if drate==. 
lab var drate "Depreciation rate for each durable item by household"
lab var drate_median "Median depreciation rate for each durable item"
drop drate_count drate_gral_median

*cleaning rule: we replace for the weighted median those cases that 1) do not report the number of goods they own but do report that they own some; and 2) own 100 items or more
bysort itemid: egen own_count=count(own) 
gen own_median=.
levelsof itemid, local(items)
quietly foreach item of local items {
        sum own_n [aw=weight_cons] if itemid==`item', detail
		replace own_median=r(p50) if itemid==`item' & own_count>3
}
sum own_n [aw=weight_cons], detail
gen own_gral_median=r(p50)
replace own_median=own_gral_median if own_count<=3
label var own_median "Median number of items owned"
replace own_n=own_median if own_n>=100
drop own_count own_gral_median	

*afterwards we calculate the consumption flow 
local pi = 0.005
local i = 0.02
gen cons_flow = (val_usd/(1-drate_median+`pi'))*(`i' - `pi' + drate_median) 
label var cons_flow "Consumption flow"
table itemid, c(median drate_median mean cons_flow) format (%10.4f)

*then we calculate the median consumption flow per item & vintage
gen cf_median=.
levelsof itemid, local(items)
levelsof vintage, local(vintagelist)
quietly foreach item of local items {
  foreach vin of local vintagelist {
        sum cons_flow [aw= weight_cons] if itemid==`item' & vintage==`vin', detail 
		replace cf_median=r(p50) if itemid==`item' & vintage==`vin' 
}
}
lab var cf_median "Median consumption flow"

*now we estimate the final consumption flow of durable goods 
ma drop all
local pi `"0.005"'
local i  `"0.02"'
gen cons_d= (val_usd/(1-drate_median+`pi'))*(`i' - `pi' + drate_median) if own_n==1 
replace cons_d= (val_usd/(1-drate_median+`pi'))*(`i' - `pi' + drate_median) + ((own_n-1)*cf_median) if own_n>=2 

*cleaning rule: replace with the median by item for 1) top/bottom 1% of the total distribution
set sortseed 11041945
cumul cons_d, gen (durables_cumulative) equal
label define ldurables_distr 1 "Bottom 1% (1)" 2 "Top 1% (2)"
gen durables_distr=1 if durables_cumulative<=0.01 
replace durables_distr=2 if durables_cumulative>=0.99 
label values durables_distr ldurables_distr
gen consd_median=.
levelsof itemid, local(items)
quietly foreach item of local items {
   sum cons_d [aw=weight_cons] if itemid==`item' & durables_distr>=., detail
   replace consd_median=r(p50) if itemid==`item' 
}
replace cons_d=consd_median if consd_median<. & (durables_distr==1  |  durables_distr==2) 
drop durables_cumulative durables_distr consd_median

*cleaning rule: truncate values that exceed 3 sd from the mean in the distribution of each item to that thresold 
gen mean_item=.
levelsof itemid, local(items)
quietly foreach item of local items {
   sum cons_d [aw=weight_cons] if itemid==`item', detail
   replace mean_item=r(mean) if itemid==`item' 
}	
gen sd_item=.
levelsof itemid, local(items)
quietly foreach item of local items {
   sum cons_d [aw=weight_cons] if itemid==`item', detail
   replace sd_item=r(sd) if itemid==`item' 
}	
bysort itemid: egen prelim_max_consd= max(cons_d) if cons_d<=mean_item+3*sd_item 
bysort itemid: egen max_consd = max(prelim_max_consd) 
replace cons_d= max_consd if cons_d>mean_item+3*sd_item
drop mean_item sd_item prelim_max_consd max_consd

*then we transform annual consumption into weekly consumption 
replace cons_d=cons_d/12/4
label var cons_d "Consumption of durables curr. USD: 7d"
save "${gsdData}/1-CleanTemp/assets_clean_byitem.dta", replace

*cleaning rule: replace consumption with the mean value (considering zeros) when the response to the ownership of the assset was "don't know" or "refused to respond"
*first we use the full dataset to retrive records with zero assets
use "${gsdTemp}/assets_hhs_fulldataset.dta", clear
keep zone team strata ea block hh weight_cons itemid own astrata type
rename own own_original
save "${gsdTemp}/assets_hhs_fulldataset_clean.dta", replace
*then we merge the file with the clean version of assets by item
use "${gsdData}/1-CleanTemp/assets_clean_byitem.dta", clear
merge 1:1 strata ea block hh itemid using "${gsdTemp}/assets_hhs_fulldataset_clean.dta"
assert own_original==own if _merge==3
drop if own_original==.z
*introduce zero consumption to be included in the mean consumption by item
replace cons_d=0 if own_original==0
*obtain the mean price per item
bys itemid: egen mean_cons_d_item=mean(cons_d)
*asign the mean consumption (including zeros) for the item when the response was "don't know" or "refused to respond"
replace cons_d=mean_cons_d_item if own_original==.a | own_original==.b
replace own=own_original
drop if own_original==0
drop _merge mean_cons_d_item own_original zone
save "${gsdData}/1-CleanTemp/assets.dta", replace

*next we collapse at the household level 
keep strata ea block hh cons_d
collapse (sum) cons_d, by(strata ea block hh)
lab var cons_d "Consumption flow of durables (curr. USD, 7d)"

*then we include households with zero and missing values in consumption of durables and save the file
gen dum_cons=1
append using "${gsdTemp}/assets_hhs_with_zerocons.dta"
replace cons_d=0 if dum_cons>=.
append using "${gsdTemp}/all_hhs_missing.dta"
drop dum_cons
replace cons_d=.c if cons_d==.
drop opt_mod
save "${gsdData}/1-CleanTemp/hh_durables.dta", replace



*save a version w/comparable items to Somaliland 2013
use "${gsdData}/1-CleanInput/hh.dta", clear
keep if ( strata==302 & ea==165 & block==. & hh==11) | ( strata==304 & ea==140 & block==. & hh==8) | ( strata==304 & ea==140 & block==. & hh==9) | ( strata==304 & ea==185 & block==. & hh==3)
keep strata ea block hh 
save "${gsdTemp}/zero_d_comparable_2012.dta", replace

use "${gsdData}/1-CleanTemp/assets.dta", clear
drop if itemid==23

*next we collapse at the household level 
keep strata ea block hh cons_d
collapse (sum) cons_d, by(strata ea block hh)
lab var cons_d "Consumption flow of durables (curr. USD, 7d)"

*then we include households with zero and missing values in consumption of durables and save the file
gen dum_cons=1
append using "${gsdTemp}/assets_hhs_with_zerocons.dta"
replace cons_d=0 if dum_cons>=.
append using "${gsdTemp}/all_hhs_missing.dta"
*include 3 additional hhs w/zero cons due to the dropped items 
append using "${gsdTemp}/zero_d_comparable_2012.dta"
drop dum_cons
replace cons_d=.c if cons_d==.
drop opt_mod
save "${gsdData}/1-CleanTemp/hh_durables_comparable_2013.dta", replace

