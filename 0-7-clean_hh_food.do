*clean and organize child file regarding food

set more off
set seed 23081670 
set sortseed 11041675


********************************************************************
*Roster on food items
********************************************************************
use "${gsdData}/0-RawTemp/ra_food_valid_successful_complete.dta", clear






*Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist ra_assets__id-interview__key {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}

*Introduce own dummy for each item
gen own=1
label var own "H.2 Does anyone in your household own the item?"
label define lyesno 0 "No" 1 "Yes" .a "Don't know" .b "Refused to respond" .z "Not administered" 
label values own lyesno

*Clean variables 
split ra_ynew, parse(-)
drop ra_ynew ra_ynew2 ra_ynew3
rename ra_ynew1 ra_ynew
replace ra_ynew="" if ra_ynew=="##N/A##"
destring ra_ynew, replace

*Include skip patterns 
replace ra_owntotal=.z if ra_owntotal_kdk>=.
replace ra_ynew=.z if ra_ynew_kdk>=.
replace ra_prnew=.z if ra_prnew_kdk>=.
replace ra_prnew_curr=.z if ra_prnew>=.
replace ra_sellnew=.z if ra_sellnew_kdk>=.
replace ra_sellnew_curr=.z if ra_sellnew>=.
replace ra_sellall_kdk=.z if ra_owntotal<=1 | ra_owntotal>=.
replace ra_sellall=.z if ra_sellall_kdk>=.
replace ra_sellall_curr=.z if ra_sellall>=.

*Label and rename 
foreach var in ra_owntotal_kdk ra_ynew_kdk ra_prnew_kdk ra_sellnew_kdk ra_sellall_kdk ra_prnew_curr ra_sellnew_curr ra_sellall_curr {
	label define `var' .a "Don't know" .b "Refused to respond" .z "Not administered", modify
}
label var ra_assets__id "Asset ID"
label var ra_ynew "H.4 What year did the household buy the newest %rostertitle%?"
drop ra_namelp interview__key ra_prnewzero ra_sellnewzero ra_sellallzero
order interview__id ra_assets__id own ra_owntotal_kdk ra_owntotal ra_ynew_kdk ra_ynew ra_prnew_kdk ra_prnew ra_prnew_curr ra_sellnew_kdk ra_sellnew ra_sellnew_curr ra_sellall_kdk ra_sellall ra_sellall_curr 
rename (ra_assets__id ra_owntotal ra_owntotal_kdk ra_ynew_kdk ra_ynew) (assetid own_n own_n_kdk newest_y_kdk newest_y)
rename (ra_prnew_kdk ra_prnew ra_prnew_curr) (newest_pr_kdk newest_pr newest_c)
rename (ra_sellnew_kdk ra_sellnew ra_sellnew_curr )(newest_val_kdk newest_val newest_val_c)
rename (ra_sellall_kdk ra_sellall ra_sellall_curr) (all_val_kdk all_val all_val_c)

*Include the name of each item
label define lassetid 1 "Bed with mattress" 2 "Mattress without bed" 3 "Chair" 4 "Upholstered chair, sofa set" 5 "Desk" 6 "Table" 7 "Coffee table (for sitting room)" 8 "Cupboard, drawers, bureau" 9 "Kitchen furniture" 10 "Mortar/pestle" 11 "Iron" 12 "Clock" 13 "Fan" 14 "Air conditioner" 15 "Sewing machine" 16 "Refrigerator" 17 "Washing machine" 18 "Stove for charcoal" 19 "Electric stove or hot plate" 20 "Gas stove" 21 "Kerosene/paraffin stove" 22 "Lantern (paraffin)" 23 "Small solar light" 24 "Cell phone" 25 "Photo camera" 26 "Radio ('wireless')" 27 "Tape or CD/DVD player; HiFi" 28 "Television" 29 "VCR" 30 "Computer equipment & accessories" 31 "Satellite dish" 32 "Solar panel" 33 "Generator" 34 "Motorcycle/scooter" 35 "Car" 36 "Mini-bus" 37 "Lorry"
label values assetid lassetid

save "${gsdData}/0-RawTemp/hh_assets_clean.dta", replace




********************************************************************
*Roster on cerals
********************************************************************
rf_food_cereals 


********************************************************************
*Roster on fruit 
********************************************************************
rf_food_fruit 


********************************************************************
*Roster on Meat
********************************************************************
rf_food_meat 


********************************************************************
*Roster on Vegetables
********************************************************************
rf_food_vegetables 





********************************************************************
*Append and integrate one food dta file 
********************************************************************






















