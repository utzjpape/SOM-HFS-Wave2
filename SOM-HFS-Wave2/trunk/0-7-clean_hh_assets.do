*clean and organize child file regarding livestock

set more off
set seed 23081660 
set sortseed 11041665


ra_assets 
ra_assets_prev 




use "${gsdData}/0-RawTemp/hh_h_assets_valid.dta", clear
********************************************************************
* Relabel 'Don't know' and 'Refused to respond'
********************************************************************
* Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all

**************************************************************************
* Relabel Skip patterns: Please refer to Questionnaire for relevance conditions
**************************************************************************
foreach v in ra_owntotal ra_xown ra_ynew ra_xynew ra_prnew ra_cprnew ra_xprnew ra_sellnew ra_csellnew ra_xsellnew ra_sellnewzero {
	assert missing(`v') if  ra_own!=1
	recode `v' (.=.z) if ra_own!=1 
}

assert missing(ra_prnewzero) if ra_prnew!=0 
recode ra_prnewzero (.=.z) if ra_prnew!=0 

assert missing(ra_sellnewzero) if ra_sellnew!=0 
recode ra_sellnewzero (.=.z) if ra_sellnew!=0 

foreach v in ra_sellall ra_csellall ra_xsellall ra_sellallzero {
	assert missing(`v') if ra_owntotal<=1 | ra_own!=1
	recode `v' (.=.z) if ra_owntotal<=1  | ra_own!=1 
}

assert missing(ra_sellallzero) if ra_sellall!=0
recode ra_sellallzero (.=.z) if ra_sellall!=0

**************************************************************************
* Cleaning
**************************************************************************
*empty means form was not completed 
drop if ra_nametitle==""

labmask ra_index, values(ra_nametitle)
drop *name*
keep ra_index ra_own ra_owntotal ra_ynew ra_prnew ra_cprnew ra_sellnew ra_csellnew ra_sellall ra_csellall key
ren ra_* *
ren (index owntotal ynew prnew cprnew sellnew csellnew sellall csellall) (assetid own_n newest_y newest_pr newest_pr_c newest_val newest_val_c all_val all_val_c)

*for households with only one of the item, sell value for all items is the sell value for the newest item.
foreach suf in val val_c {
	replace all_`suf'=newest_`suf' if own_n==1
}
label var assetid "Asset ID"
label var own_n "Number owned today"
label var newest_y "Year newest item was purchased"
label var newest_pr "Price of newest item at time of purchase"
label var newest_pr_c "Currency for price"
label var newest_val "Current sell value for newest item"
label var newest_val_c "Currency for newest item sell value"
label var all_val "Current sell value for all items"
label var all_val_c "Currency for all items sell value"
label var key "Key to merge with parent"
order key

*drop empty variables
missings dropvars, force 

save "${gsdData}/0-RawTemp/hh_h_assets_clean.dta", replace
