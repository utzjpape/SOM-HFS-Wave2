*clean and organize child file food security 

set more off
set seed 23031980 
set sortseed 11031955

use "${gsdData}/0-RawTemp/hh_k_fsecurity_valid.dta", clear
********************************************************************
* Relabel 'Don't know' and 'Refused to respond'
********************************************************************
* Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all

**************************************************************************
* Relabel Skip patterns: Please refer to Questionnaire for relevance conditions
**************************************************************************
assert missing(fcs_food_source) if fcs_food_days<=0
recode fcs_food_source (.=.z) if fcs_food_days<=0

**************************************************************************
* Cleaning
**************************************************************************
label var fcs_pos "Food item ID"
label var fcs_food "Food item name"
label var fcs_food_hint "Food item description/hint"
label var key "Key to merge with parent"
label define lfood_item 1 "Sorghum"  2 "Maize"  3 "Other cerals"  4 "Roots and tubers" 5 "Pulses/nuts" 6 "Orange vegetables" 7 "Green leafy vegetables" 8 "Other vegetables" 9 "Fruits of orange colour" 10 "Other fruits" 11 "Meat" 12 "Liver, kidney, heart and/or other organ meat" 13 "Fish" 14 "Eggs" 15 "Milk and other dairy products" 16 "Oil/fat/butter"  17 "Sugar, or sweet" 18 "Condiments/spices"
label values fcs_pos lfood_item
drop child_key setoffcs fcs_food_som fcs_food_hint_som fcs_food fcs_food_hint
order key 

*drop empty variables
missings dropvars, force 

save "${gsdData}/0-RawTemp/hh_k_fsecurity_clean.dta", replace
