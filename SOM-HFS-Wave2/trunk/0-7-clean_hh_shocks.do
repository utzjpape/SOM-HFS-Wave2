*clean and organize child file shocks

set more off
set seed 23081981 
set sortseed 11041956

use "${gsdData}/0-RawTemp/hh_n_shocks_valid.dta", clear

shocks


********************************************************************
* Relabel 'Don't know' and 'Refused to respond'
********************************************************************
* Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all

**************************************************************************
* Relabel Skip patterns: Please Refer to Questionnaire for relevance conditions
**************************************************************************
assert missing(shresp2) if shresp1<=0
recode shresp2 (.=.z) if shresp1<=0

assert missing(shresp3) if shresp1<=0 | shresp2<=0
recode shresp3 (.=.z) if shresp1<=0 | shresp2<=0

**************************************************************************
* Cleaning
**************************************************************************
label var r_shock_id "ID for each type of shock"
label var r_shock_name "Type of shock"
label var r_shock_pos "Severity of the shock"
label define lr_shock_pos 1 "Most severe shock" 2 "Second most severe shock" 3 "Third most severe shock"
label values r_shock_pos lr_shock_pos
label define lr_shock_id  1 "Drought/Irregular Rains"  2 "Floods/Landslides"  3 "Fire"  4 "Earthquakes"  5 "Insufficient water supply for farming/gardening"  6 "Insufficient energy demand"  7 "Unusually high level of crop Pests or disease"  8 "Unusually High level of livestock disease"  9 "Unusually low prices for agricultural output"  10 "Unusually high costs of agricultural inputs"  11 "Unusually high prices for food"  12 "End of regular assistance/aid/remittances from outside"  13 "Reduction in the Earnings from Household (Non-Agricultural) Business (Not due to Illness or Accident)"  14 "Household (Non-Agricultural) business failure (Not due to Illness or Accident)"  15 "Reduction in the Earnings of Currently Salaried Household Member(s) (Not due to Illness or Accident)"  16 "Loss of employment of previously salaried household member(s) (Not due to Illness or Accident)"  17 "Serious illness or accident of household member(s)"  18 "Birth in the household"  19 "Death of income earner(s)"  20 "Death of other household member(s)"  21 "Accident"  22 "Break-up of household"  23 "Theft of money/valuables/assets/agricultural output"  24 "Disputes on land issues"  25 "Destruction of assets/valuables/agricultural output"  26 "Conflict/Violence"  27 "Land eviction"  28 "Inadequate Employment" 29 "Temporary/permanent loss of access to school/health"
label values r_shock_id lr_shock_id

drop child_key setofshocks r_shock_pos r_shock_name
label var key "Key to merge with parent"
order key 

*drop empty variables
missings dropvars, force 

save "${gsdData}/0-RawTemp/hh_n_shocks_clean.dta", replace
