* cleans and estimates the consumption flow of assets or durable goods

set more off
set seed 23081940 
set sortseed 11041945


********************************************************************
*Open the food dataset and prepare the file
********************************************************************
use "${gsdData}/1-CleanInput/assets.dta", clear
*Include households with no record for non food items
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta"
replace assetid=2 if assetid>=.
keep own strata ea block hh assetid
reshape wide own, i(strata ea block hh) j(assetid)
reshape long
merge 1:1 strata ea block hh assetid using "${gsdData}/1-CleanInput/assets.dta", nogen keep(master match)
*Save the original structure to eventually include records with zero consumption, in order to get the mean consumption by item that ultimately will be assign to records that answered "don't know" or "refused to respond"
keep strata ea block hh assetid own
rename (own assetid) (own_original itemid)
save "${gsdTemp}/assets_hhs_fulldataset.dta", replace
*Open the dataset
use "${gsdData}/1-CleanInput/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", keep(match master) nogen keepusing(weight)
order weight, after(hh)
*Now we identify households with zero consumption of non-food items to include them at the end with zero (not missing values)
collapse (max) strata, by(ea block hh)
save "${gsdTemp}/assets_hhs_withcons.dta", replace
use "${gsdData}/1-CleanInput/hh.dta", clear
keep strata ea block hh
merge 1:1 strata ea block hh using "${gsdTemp}/assets_hhs_withcons.dta", nogen keep(master)
save "${gsdTemp}/assets_hhs_with_zerocons.dta", replace


********************************************************************
*Introduce corrections related to currency issues
********************************************************************
use "${gsdData}/1-CleanInput/assets.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", nogen keep(master match) keepusing(weight)
renpfix newest_
rename (y assetid c) (year itemid pr_c)
foreach measure in pr val {
	* Currency splits
	* SSH only: ea_reg 2,3,4,5,6,7,8,9,10,11,12,14,15
	* SLSH only: ea reg 1, 18
	* Both: 13, 16, 17 
	* Check that this is true in the data
	assert `measure'_c==4 | `measure'_c==5 | `measure'_c>=. if inlist(region, 1, 18)
	assert `measure'_c==2 | `measure'_c==5 | `measure'_c>=. if inlist(region, 2,3,4,5,6,7,8,9,10,11,12,14,15)
	assert inlist(`measure'_c, 2, 4, 5) | `measure'_c>=. if inlist(region, 13, 16, 17)
}	
* Define whether an observation is in an SLSH or in an SSH area
cap drop team
* SLSH 
gen team = 1 if inlist(region, 1, 18)
* SSH
replace team = 2 if inlist(region, 2,3,5,6,7,8,9,10,14,15)
replace team = 2 if inlist(region, 4,11,12)
* Now the situations where both currencies are possible to select: we want to assign one team for each observation depending on whether...
* ... it is in SLSH or SSH. To be able to assign a unique team value, we need to ensure that there are no cases in which `pr' is in a different ...
* ... currency than 'val':
assert !((pr_c==4 & val_c==2) | (pr_c==2 & val_c==4)) if inlist(region, 13, 16, 17)
* Now assign team value
replace team = 1 if inlist(region, 13, 16, 17) & (pr_c==4 | val_c==4)   
replace team = 2 if inlist(region, 13, 16, 17) & (pr_c==2 | val_c==2) 
* we assign team 1 if USD or missing
replace team = 1 if inlist(region, 13, 16, 17) & (pr_c==5 | mi(pr_c)) & mi(team) 
assert !mi(team)

foreach measure in pr val {
	*cleaning rule: change USD to local currency (for each zone) when the price is equal or greater than 1,000
	replace `measure'_c=4 if `measure' >= 1000 & `measure'<. & `measure'_c==5 & team==1
	replace `measure'_c=2 if `measure' >= 1000 & `measure'<. & `measure'_c==5 & inlist(team, 2, 3) 
	*Cleaning rule: change local currency larger than 10,000, divide by 1,000 (respondents probably meant Shillings not thousands of shillings)
	replace `measure' = `measure'/1000 if `measure'>10000 & `measure'<.
}


********************************************************************
*Obtain price and value in USD and identify issues
********************************************************************
merge m:1 team using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(average_er)
*Obtain price and value in USD
foreach measure in pr val {
	gen `measure'_usd=`measure' if `measure'_c==5
	replace `measure'_usd=`measure'/(average_er/1000) if `measure'_c==2 | `measure'_c==4
}
label var pr_usd "Price in USD of newest item at time of purchase"
label var val_usd "Current sell value in USD of newest item"
drop average_er
*Cleaning rule: set as missing all observations where zero was the amount paid for the item (current and purchase price)
replace pr_usd=. if pr_usd==0
replace val_usd=. if val_usd==0


********************************************************************
*Calculate and clean the vintages of each item 
********************************************************************
*Items purchased in 2017 or 2018 (year of the survey) are consider to be one year old (as soon they leave the store they lose value)
gen vintage=.
replace vintage =(2017-year)+1 if year!=2018
replace vintage =(2018-year)+1 if year==2018
*Cleaning rule: tag vintages with 1) missing values; and 2) vintage >10, and replace them with the weighted median for each item if there are more than 3 observations or the overall median vintage considering all items 
gen tag_vintage=1 if vintage==. 
replace tag_vintage=1 if vintage>10
label var tag_vintage "Entry flagged: Issues w/vintage"
bysort itemid: egen vintage_count=count(vintage) if tag_vintage!=1
gen vintage_median=.
levelsof itemid, local(items)
quietly foreach item of local items {
        sum vintage [aw=weight] if itemid==`item' & tag_vintage!=1, detail
		replace vintage_median=r(p50) if itemid==`item' & vintage_count>3
}
sum vintage [aw=weight] if tag_vintage!=1, detail
gen vintage_gral_median=r(p50)
replace vintage_median=vintage_gral_median if vintage_count<=3
replace vintage=vintage_median if tag_vintage==1
lab var vintage "Years since newest item was purchased"


********************************************************************
*Clean purchase and sell value with median values for each item/vintage
********************************************************************
*Generate the weighted median by item/vintage excluding records with missing values, and those with the same figure in price and value 
gen tag_same_pr_val=1 if pr_usd==val_usd & val_usd<. & vintage>1
foreach measure in pr val {
 gen tag_`measure'=1 if `measure'_usd>=.
 gen `measure'_median=.
 bysort itemid year: egen `measure'_count=count(`measure'_usd) if tag_`measure'!=1 & tag_same_pr_val!=1
	levelsof itemid, local(items)
	levelsof vintage, local(vintagelist)
	quietly foreach item of local items {
	  foreach vin of local vintagelist {
		 sum `measure'_usd [aw= weight] if itemid==`item'  & vintage==`vin' & tag_`measure'!=1 & tag_same_pr_val!=1, detail
		 replace `measure'_median=r(p50) if itemid==`item' & vintage==`vin' & `measure'_count>=3 
}
}
 levelsof itemid, local(items)
 quietly foreach item of local items {
   sum `measure'_usd [aw=weight] if itemid==`item' & tag_`measure'!=1 & tag_same_pr_val!=1, detail
   replace `measure'_median=r(p50) if itemid==`item' & `measure'_median==.  
}
}
*Cleaning rule: replace missing values in purchase & sell value with the weighted median for each item/vintage 
replace pr_usd=pr_median if tag_pr==1
replace val_usd=val_median if tag_val==1
label var tag_pr "Entry flagged: Issues w/price"
label var tag_val "Entry flagged: Issues w/value"
*Cleaning rule: replace price or value with the weighted median by item/vintage for cases with the same figure in price and value and a vintage greater than one. The correct unit is the ones that takes the variable (price or value) closer to the weighted median value in the distribution of that variable for the same item/year 
gen diff_pr= abs(pr_usd - pr_median) if tag_same_pr_val==1
gen diff_val= abs(val_usd - val_median) if tag_same_pr_val==1
replace val_usd=val_median if diff_pr<=diff_val & tag_same_pr_val==1
replace pr_usd=pr_median if diff_pr>diff_val & tag_same_pr_val==1
*Adjust the vintage accordingly with the median vintage per item
replace vintage=vintage_median if diff_pr<=diff_val & tag_same_pr_val==1
replace vintage=vintage_median if diff_pr>diff_val & tag_same_pr_val==1
drop vintage_* tag_same_pr_val pr_median pr_count val_median val_count diff_pr diff_val
*Check if there are any missing values or items with only a few observation 
tabstat pr_usd, by(itemid) stat(n min max)


********************************************************************
*Calculate the depreciation rate by item for each household & correct errors 
********************************************************************
*Set key parameters for cash flow calculation: inflation rate & nominal interest rate
local pi = 0.005
local i = 0.02
*estimate a similar formula to that in Deaton and Zaidi (2002) (3.2)
gen drate= 1 -(1/(1+ 0.005))*((val_usd/pr_usd))^(1/vintage)
*Check the depreciation rate (converted to missing and replaced by the weighted median in the next lines) for the following cases: 1) negative converted to missing (cleaned with the median in the next lines); 2) high depreciation rates and & small vintages; and 3) small drates & large vintage
replace drate=. if drate<0
set sortseed 11041945
cumul drate if drate<., gen (drate_distribution) equal
label define ldum_distr 0 "Bottom 10% (0)"  1 "Top 10% (1)"
gen dum_distr=1 if drate_distribution>=.9 & drate_distribution<.
replace dum_distr=0 if drate_distribution<=.1 
label var dum_distr "Dummy indicating top/bottom of distribution"
label values dum_distr ldum_distr
*Replace inconsistent cases in the top of the drate distribution
replace drate=. if dum_distr==1 & vintage==1
*Replace inconsistent cases in the bottom of the drate distribution
replace drate=. if dum_distr==0 & vintage>=3
drop drate_distribution dum_distr
*Cleaning rule: replace by the weighted median the following cases: 1) negative depreciation rates; 2) high depreciation rates and & small vintages; and 3) small drates & large vintage
bysort itemid: egen drate_count=count(drate) 
gen drate_median=.
levelsof itemid, local(items)
quietly foreach item of local items {
        sum drate [aw=weight] if itemid==`item', detail
		replace drate_median=r(p50) if itemid==`item' & drate_count>3
}
sum drate [aw=weight], detail
gen drate_gral_median=r(p50)
replace drate_median=drate_gral_median if drate_count<=3
replace drate=drate_median if drate==. 
lab var drate "Depreciation rate for each durable item by household"
lab var drate_median "Median depreciation rate for each durable item"
drop drate_count drate_gral_median
*Cleaning rule: we replace for the weighted median those cases that 1) do not report the number of goods they own but do report that they own some; and 2) own 100 items or more
bysort itemid: egen own_count=count(own) 
gen own_median=.
levelsof itemid, local(items)
quietly foreach item of local items {
        sum own_n [aw=weight] if itemid==`item', detail
		replace own_median=r(p50) if itemid==`item' & own_count>3
}
sum own_n [aw=weight], detail
gen own_gral_median=r(p50)
replace own_median=own_gral_median if own_count<=3
label var own_median "Median number of items owned"
replace own_n=own_median if own_n>=100
drop own_count own_gral_median	


********************************************************************
*Calculate and clean the consumption flow 
********************************************************************
local pi = 0.005
local i = 0.02
gen cons_flow = (val_usd/(1-drate_median+`pi'))*(`i' - `pi' + drate_median) 
label var cons_flow "Consumption flow"
table itemid, c(median drate_median mean cons_flow) format (%10.4f)
*Then we calculate the median consumption flow per item & vintage
gen cf_median=.
levelsof itemid, local(items)
levelsof vintage, local(vintagelist)
quietly foreach item of local items {
  foreach vin of local vintagelist {
        sum cons_flow [aw= weight] if itemid==`item' & vintage==`vin', detail 
		replace cf_median=r(p50) if itemid==`item' & vintage==`vin' 
}
}
lab var cf_median "Median consumption flow"
*Now we estimate the final consumption flow of durable goods 
ma drop all
local pi `"0.005"'
local i  `"0.02"'
gen cons_d= (val_usd/(1-drate_median+`pi'))*(`i' - `pi' + drate_median) if own_n==1 
replace cons_d= (val_usd/(1-drate_median+`pi'))*(`i' - `pi' + drate_median) + ((own_n-1)*cf_median) if own_n>=2 
*Cleaning rule: replace with the median by item for 1) top/bottom 1% of the total distribution
set sortseed 11041945
cumul cons_d, gen (durables_cumulative) equal
label define ldurables_distr 1 "Bottom 1% (1)" 2 "Top 1% (2)"
gen durables_distr=1 if durables_cumulative<=0.01 
replace durables_distr=2 if durables_cumulative>=0.99 
label values durables_distr ldurables_distr
gen consd_median=.
levelsof itemid, local(items)
quietly foreach item of local items {
   sum cons_d [aw=weight] if itemid==`item' & durables_distr>=., detail
   replace consd_median=r(p50) if itemid==`item' 
}
replace cons_d=consd_median if consd_median<. & (durables_distr==1  |  durables_distr==2) 
drop durables_cumulative durables_distr consd_median
*Cleaning rule: truncate values that exceed 3 sd from the mean in the distribution of each item to that thresold 
gen mean_item=.
levelsof itemid, local(items)
quietly foreach item of local items {
   sum cons_d [aw=weight] if itemid==`item', detail
   replace mean_item=r(mean) if itemid==`item' 
}	
gen sd_item=.
levelsof itemid, local(items)
quietly foreach item of local items {
   sum cons_d [aw=weight] if itemid==`item', detail
   replace sd_item=r(sd) if itemid==`item' 
}	
bysort itemid: egen prelim_max_consd= max(cons_d) if cons_d<=mean_item+3*sd_item 
bysort itemid: egen max_consd = max(prelim_max_consd) 
replace cons_d= max_consd if cons_d>mean_item+3*sd_item
drop mean_item sd_item prelim_max_consd max_consd


********************************************************************
*Prepare the output files at the item and household level 
********************************************************************
*Transform annual consumption into weekly consumption 
replace cons_d=cons_d/12/4
label var cons_d "Consumption of durables curr. USD: 7d"
drop team
order weight, after(hh)
save "${gsdData}/1-CleanTemp/assets_clean_byitem.dta", replace
*Include relevant info for items not owned 
merge 1:1 strata ea block hh itemid using "${gsdTemp}/assets_hhs_fulldataset.dta"
assert own_original==own if _merge==3
drop region weight enum _merge
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(region weight enum )
*Introduce zero consumption to be included in the mean consumption by item
replace own=0 if own_original>=. 
replace cons_d=0 if own_original>=. 
foreach var in own_n_kdk own_n y_kdk year pr_kdk pr pr_c val_kdk val val_c all_val_kdk all_val all_val_c {
	replace `var'=.z  if own_original>=. 
}
drop own_original 
order region strata ea block hh enum weight itemid
save "${gsdData}/1-CleanTemp/assets.dta", replace
*Collapse at the household level 
keep strata ea block hh cons_d
collapse (sum) cons_d, by(strata ea block hh)
lab var cons_d "Consumption flow of durables (curr. USD, 7d)"
save "${gsdData}/1-CleanTemp/hh_durables.dta", replace
