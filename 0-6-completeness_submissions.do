*Check the completeness of submissions between parent and child files
 

set more off
set seed 23081650 
set sortseed 11041895

*Check all the different sections of the survey agains the parent file

*Household roster files
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/hhroster_age_valid_successful.dta", nogen assert(match)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/hh_roster_separated_valid_successful.dta", nogen keep(master match)
 
*Motor
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/motor_valid_successful.dta", nogen assert(match master)

*Assets
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/ra_assets_valid_successful.dta", nogen keep(master match)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/ra_assets_prev_valid_successful.dta", nogen keep(match master)

*Food items
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_valid_successful.dta", nogen keep(match master)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_cereals_valid_successful.dta", nogen keep(match master)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_fruit_valid_successful.dta", nogen keep(match master)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_meat_valid_successful.dta", nogen keep(match master)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rf_food_vegetables_valid_successful.dta", nogen keep(match master)
  
*Non-food items
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rnf_nonfood_valid_successful.dta", nogen assert(match)
 
*Livestock
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rl_livestock_valid_successful.dta", nogen keep(match master)
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/rl_livestock_pre_valid_successful.dta", nogen keep(match master)

*Shocks
use"${gsdData}/0-RawTemp/hh_valid_successful.dta", clear
merge 1:m interview__id using "${gsdData}/0-RawTemp/shocks_valid_successful.dta", nogen keep(match master)


//IDENTIFY INCOMPLETE SUBMISSIONS 

use "C:\Users\WB484006\Desktop\HHs_no_food.dta", clear
merge 1:1 interview__id using "C:\Users\WB484006\Desktop\HHs_no_food_cerals.dta"

use "C:\Users\WB484006\Desktop\HHs_no_food.dta", clear
merge 1:1 interview__id using "C:\Users\WB484006\Desktop\HHs_no_food_fruits.dta"

use "C:\Users\WB484006\Desktop\HHs_no_food.dta", clear
merge 1:1 interview__id using "C:\Users\WB484006\Desktop\HHs_no_food_vegetables.dta"

use "C:\Users\WB484006\Desktop\HHs_no_food.dta", clear
merge 1:1 interview__id using "C:\Users\WB484006\Desktop\HHs_no_food_meat.dta"




use "C:\Users\WB484006\Desktop\HHs_no_food.dta", clear
merge 1:1 interview__id using "C:\Users\WB484006\Desktop\HHs_no_food_cerals.dta", nogen keep(match)
merge 1:1 interview__id using "C:\Users\WB484006\Desktop\HHs_no_food_fruits.dta", nogen keep(match)
merge 1:1 interview__id using "C:\Users\WB484006\Desktop\HHs_no_food_vegetables.dta", nogen keep(match)
merge 1:1 interview__id using "C:\Users\WB484006\Desktop\HHs_no_food_meat.dta", nogen keep(match)
merge 1:1 interview__id using "C:\Users\WB484006\Desktop\HHs_no_assets.dta", nogen keep(match)


