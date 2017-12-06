*generate a file with of all the different types units for all the items in the survey and the recall period for non-food consumption

set more off 
set seed 21081980 
set sortseed 21041955

*import the Excel file with all the units to define a general template for a specific product 
import excel using "${gsdDataRaw}/Units.xlsx", clear first sheet("quantity")
gen foodid=.
sort cons_u
order foodid cons_u 
save "${gsdData}/0-RawTemp/units.dta", replace

*first we identify the total number of products in the survey, to ultimately define how many times we need to replicate the general template(looping through all the unique records of foodid)
use "${gsdData}/0-RawOutput/hh_e_food.dta", clear
levelsof foodid, local(items) 
quietly foreach i of local items {
   use "${gsdData}/0-RawTemp/units.dta", clear
   drop foodid
   gen foodid=`i'
   sort cons_u
   order foodid cons_u 
   save "${gsdTemp}/units_`i'.dta", replace
 }
*next we append all the product-specific files into one file with all the possible units and all the products in the survey
use "${gsdData}/0-RawOutput/hh_e_food.dta", clear
levelsof foodid, local(items) 
use "${gsdData}/0-RawTemp/units.dta", clear
quietly foreach i of local items {
   append using  "${gsdTemp}/units_`i'.dta"
   save "${gsdTemp}/units_all.dta", replace
 }
drop if foodid==.
sort foodid cons 
save "${gsdTemp}/units_all.dta", replace

*afterwards, we manually introduce replacements to specific units/products (previously identified as incorrectly coded) for the conversion to kg
*Biscuits with small/large piece units
replace kg=.030 if foodid==15 & cons_u==25
replace kg=.010 if foodid==15 & cons_u==26

*Bread with small/large piece units
replace kg=.400 if foodid==13 & cons_u==25
replace kg=.100 if foodid==13 & cons_u==26

*Eggs with small/large piece units
replace kg=.070 if foodid==53 & cons_u==25
replace kg=.050 if foodid==53 & cons_u==26

*Canned fish/shellfish with small/large piece units
replace kg=.420 if foodid==56 & cons_u==25
replace kg=.140 if foodid==56 & cons_u==26

*Grapefruits, lemons, guavas, limes with small/large piece units
replace kg=.350 if foodid==60 & cons_u==25
replace kg=.100 if foodid==60 & cons_u==26

*Milk with small/large piece units
replace kg=.750 if foodid==71 & cons_u==25
replace kg=.250 if foodid==71 & cons_u==26

*Milk powder with small/large piece units
replace kg=.450 if foodid==73 & cons_u==25
replace kg=.100 if foodid==73 & cons_u==26

*Garlic with small/large piece units
replace kg=.065 if foodid==32 & cons_u==25
replace kg=.040 if foodid==32 & cons_u==26

*Onion with small/large piece units
replace kg=.150 if foodid==33 & cons_u==25
replace kg=.095 if foodid==33 & cons_u==26

*Tomatoes with small/large piece units
replace kg=.200 if foodid==39 & cons_u==25
replace kg=.110 if foodid==39 & cons_u==26

*Bell-pepper with small/large piece units
replace kg=.150 if foodid==46 & cons_u==25
replace kg=.080 if foodid==46 & cons_u==26

*Sweet/ripe bananas with small/large piece units
replace kg=.110 if foodid==58 & cons_u==25
replace kg=.070 if foodid==58 & cons_u==26

*Canned vegetables with small/large piece units
replace kg=.400 if foodid==42 & cons_u==25
replace kg=.200 if foodid==42 & cons_u==26

*Sorghum, flour with cup units
replace kg=.200 if foodid==9 & cons_u==14

*Cooking oats, corn flakes with cup units
replace kg=.200 if foodid==17 & cons_u==14

*Milk powder with small bag units
replace kg=1 if foodid==73 & cons_u==29

*Other cooked foods from vendors with small bag units
replace kg=1 if foodid==79 & cons_u==29

*Purchased/prepared tea/coffee consumed at home with small bag units
replace kg=.400 if foodid==93 & cons_u==29

*Other spices with small bag units
replace kg=.400 if foodid==97 & cons_u==29

*finally, we extract the file into an Excel format 
gen purc_u=cons_u

save "${gsdData}/1-CleanInput/units_all_items.dta", replace



*prepare the files from Excel with the recall period for each item
import excel "${gsdDataRaw}/mod_f.xlsx", sheet("mod_f") firstrow clear
gen nfoodid = 1000 + id_key
gen recall_d=7 if recall=="7 DAYS"
replace recall_d=30 if recall=="1 MONTH"
replace recall_d=90 if recall=="3 MONTHS"
replace recall_d=364.25 if recall=="12 MONTHS"
label var recall_d "Recall period (Days)"
keep nfoodid recall_d
save "${gsdData}/1-CleanInput/recall_days.dta", replace





