*clean and organize child file income sources

set more off
set seed 22081980 
set sortseed 12041955


use "${gsdData}/0-RawTemp/hh_l_incomesources_valid.dta", clear
********************************************************************
* Relabel 'Don't know' and 'Refused to respond'
********************************************************************
* Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all

**************************************************************************
* Relabel Skip patterns: Please refer to Questionnaire for relevance conditions
**************************************************************************
foreach v in inc_total_ inc_total_c inc_total_kdk {
	assert missing(`v') if  inc_rel!=1 | inc_loc!=0
	recode `v' (.=.z) if  inc_rel!=1 | inc_loc!=0
}


foreach v in inc_rural_ inc_rural_c inc_rural_kdk inc_urban_ inc_urban_c inc_urban_kdk inc_intl_ inc_intl_c inc_intl_kdk {
	assert missing(`v') if  inc_rel!=1 | inc_loc!=1
	recode `v' (.=.z) if  inc_rel!=1 | inc_loc!=1
}

**************************************************************************
* Cleaning
**************************************************************************
label var inc_pos "Income type code"
label var inc_type "Type of income/remittances"
label var inc_cat "Income category"
label var inc_hint "Income source description/hint"
label define yesno 0 "No" 1 "Yes"
label values inc_loc yesno
label define lincome_code 1 "Crop farming enterprises"   2 "Other agricultural enterprises (e.g. sale of livestock)"  3 "Individual enterpreneurship (excl. taxes and payments)"  4 "Non-agricultural enterprises"  5 "Income from wage employment (excl. taxes and payments)"  6 "Irregular work payments"   7 "Cash Remittances/Transfers/Gifts from family members not currently living with the household (e.g. children)"  8 "Cash Remittances/Transfers/Gifts from Individuals (Friends/Relatives)"  9 "Food Remittances/Transfers/Gifts from Individuals (Friends/Relatives)"  10 "Non-Food In-Kind Remittances/Transfers/Gifts from Individuals (Friends/Relatives)"  11 "Savings, Interest or Other Investment Income"   12 "Pension Income"  13 "Social benefits from government"  14 "Income from Non-Agricultural Land Rental"  15 "Income from Apartment, House Rental"  16 "Income from Shop, Store Rental"   17 "Income from Car, Truck, Other Vehicle Rental"  18 "Income from Real Estate Sales"  19 "Income from Household Non-Agricultural Asset Sales"  20 "Income from Household Agricultural/Livestock/Fishing/ Asset Sales"  21 "Inheritance"   22 "Scholarship"  23 "Alimony"  24 "Zakat"  25 "Other Income (Specify)" 
label values inc_pos lincome_code

drop child_key setofrep_l inc_type inc_cat inc_cat_som inc_type_som inc_type_l_som_ inc_hint_som inc_type_l_som inc_type_l_ inc_type_l_som inc_type_l inc_loc inc_hint
label var key "Key to merge with parent"
order key 

*drop empty variables
missings dropvars, force 

*drop variables with open answers, multiple numeric entries and/or in Somali
*drop inc_other_ 

save "${gsdData}/0-RawTemp/hh_l_incomesources_clean.dta", replace

