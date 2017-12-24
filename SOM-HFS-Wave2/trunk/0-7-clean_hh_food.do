*Clean and organize child file regarding food

set more off
set seed 23081670 
set sortseed 11041675


********************************************************************
*Append and integrate one food file 
********************************************************************
use "${gsdData}/0-RawTemp/rf_food_valid_successful_complete.dta", clear
drop interview__key rf_cons_low rf_cons_high rf_purc_low rf_purc_high rf_pric_zero rf_pric_low rf_pric_high rf_free_main_sp
order interview__id rf_food__id rf_cons_quant_kdk rf_cons_quant rf_cons_unit rf_food_cons_unit5 rf_maj_ownprod rf_purc_quant_kdk rf_purc_quant rf_purc_unit rf_food_purc_unit5 rf_pric_total_kdk rf_pric_total rf_pric_total_curr rf_free_yn rf_free_quant rf_free_main
rename (rf_food_cons_unit5 rf_food_purc_unit5) (rf_food_cons_unit rf_food_purc_unit)
save "${gsdTemp}/hh_food_0.dta", replace

use "${gsdData}/0-RawTemp/rf_food_cereals_valid_successful_complete.dta", clear
drop interview__key rf_cons_low1 rf_cons_high1 rf_purc_low1 rf_purc_high1 rf_pric_zero1 rf_pric_low1 rf_pric_high1 rf_free_main1_sp
rename (rf_food_cereals__id rf_cons_quant1 rf_cons_unit1 rf_cons_quant1_kdk rf_food_cons_unit1 rf_maj_ownprod1 rf_purc_quant1 rf_purc_unit1 rf_purc_quant1_kdk rf_food_purc_unit1 rf_pric_total1 rf_pric_total_curr1 rf_pric_total1_kdk rf_free_yn1 rf_free_quant1 rf_free_main1) (rf_food__id rf_cons_quant rf_cons_unit rf_cons_quant_kdk rf_food_cons_unit rf_maj_ownprod rf_purc_quant rf_purc_unit rf_purc_quant_kdk rf_food_purc_unit rf_pric_total rf_pric_total_curr rf_pric_total_kdk rf_free_yn rf_free_quant rf_free_main)
order interview__id rf_food__id rf_cons_quant_kdk rf_cons_quant rf_cons_unit rf_food_cons_unit rf_maj_ownprod rf_purc_quant_kdk rf_purc_quant rf_purc_unit rf_food_purc_unit rf_pric_total_kdk rf_pric_total rf_pric_total_curr rf_free_yn rf_free_quant rf_free_main
save "${gsdTemp}/hh_food_1.dta", replace
 
use "${gsdData}/0-RawTemp/rf_food_meat_valid_successful_complete.dta", clear
drop interview__key rf_cons_low2 rf_cons_high2 rf_purc_low2 rf_purc_high2 rf_pric_zero2 rf_pric_low2 rf_pric_high2 rf_free_main2_sp
rename (rf_food_meat__id rf_cons_quant2 rf_cons_unit2 rf_cons_quant2_kdk rf_food_cons_unit2 rf_maj_ownprod2 rf_purc_quant2 rf_purc_unit2 rf_purc_quant2_kdk rf_food_purc_unit2 rf_pric_total2 rf_pric_total_curr2 rf_pric_total2_kdk rf_free_yn2 rf_free_quant2 rf_free_main2) (rf_food__id rf_cons_quant rf_cons_unit rf_cons_quant_kdk rf_food_cons_unit rf_maj_ownprod rf_purc_quant rf_purc_unit rf_purc_quant_kdk rf_food_purc_unit rf_pric_total rf_pric_total_curr rf_pric_total_kdk rf_free_yn rf_free_quant rf_free_main)
order interview__id rf_food__id rf_cons_quant_kdk rf_cons_quant rf_cons_unit rf_food_cons_unit rf_maj_ownprod rf_purc_quant_kdk rf_purc_quant rf_purc_unit rf_food_purc_unit rf_pric_total_kdk rf_pric_total rf_pric_total_curr rf_free_yn rf_free_quant rf_free_main
save "${gsdTemp}/hh_food_2.dta", replace

use "${gsdData}/0-RawTemp/rf_food_fruit_valid_successful_complete.dta", clear
drop interview__key rf_cons_low3 rf_cons_high3 rf_purc_low3 rf_purc_high3 rf_pric_zero3 rf_pric_low3 rf_pric_high3 rf_free_main3_sp
rename (rf_food_fruit__id rf_cons_quant3 rf_cons_unit3 rf_cons_quant3_kdk rf_food_cons_unit3 rf_maj_ownprod3 rf_purc_quant3 rf_purc_unit3 rf_purc_quant3_kdk rf_food_purc_unit3 rf_pric_total3 rf_pric_total_curr3 rf_pric_total3_kdk rf_free_yn3 rf_free_quant3 rf_free_main3) (rf_food__id rf_cons_quant rf_cons_unit rf_cons_quant_kdk rf_food_cons_unit rf_maj_ownprod rf_purc_quant rf_purc_unit rf_purc_quant_kdk rf_food_purc_unit rf_pric_total rf_pric_total_curr rf_pric_total_kdk rf_free_yn rf_free_quant rf_free_main)
order interview__id rf_food__id rf_cons_quant_kdk rf_cons_quant rf_cons_unit rf_food_cons_unit rf_maj_ownprod rf_purc_quant_kdk rf_purc_quant rf_purc_unit rf_food_purc_unit rf_pric_total_kdk rf_pric_total rf_pric_total_curr rf_free_yn rf_free_quant rf_free_main
save "${gsdTemp}/hh_food_3.dta", replace

use "${gsdData}/0-RawTemp/rf_food_vegetables_valid_successful_complete.dta", clear
drop interview__key rf_cons_low4 rf_cons_high4 rf_purc_low4 rf_purc_high4 rf_pric_zero4 rf_pric_low4 rf_pric_high4 rf_free_main4_sp
rename (rf_food_vegetables__id rf_cons_quant4 rf_cons_unit4 rf_cons_quant4_kdk rf_food_cons_unit4 rf_maj_ownprod4 rf_purc_quant4 rf_purc_unit4 rf_purc_quant4_kdk rf_food_purc_unit4 rf_pric_total4 rf_pric_total_curr4 rf_pric_total4_kdk rf_free_yn4 rf_free_quant4 rf_free_main4) (rf_food__id rf_cons_quant rf_cons_unit rf_cons_quant_kdk rf_food_cons_unit rf_maj_ownprod rf_purc_quant rf_purc_unit rf_purc_quant_kdk rf_food_purc_unit rf_pric_total rf_pric_total_curr rf_pric_total_kdk rf_free_yn rf_free_quant rf_free_main)
order interview__id rf_food__id rf_cons_quant_kdk rf_cons_quant rf_cons_unit rf_food_cons_unit rf_maj_ownprod rf_purc_quant_kdk rf_purc_quant rf_purc_unit rf_food_purc_unit rf_pric_total_kdk rf_pric_total rf_pric_total_curr rf_free_yn rf_free_quant rf_free_main
save "${gsdTemp}/hh_food_4.dta", replace
 
use "${gsdTemp}/hh_food_0.dta", clear
forval i=1/4 {
	append using "${gsdTemp}/hh_food_`i'.dta"
}


********************************************************************
*Clean and prepare food data
********************************************************************
*Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist interview__id-rf_free_main {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}

*Introduce consumption dummy for each item
gen cons=1
label var cons "E.2 Item was consumed in last 7 days?"
label define lyesno 0 "No" 1 "Yes" .a "Don't know" .b "Refused to respond" .z "Not administered" 
label values cons lyesno
order cons, after(rf_food__id)

*Include skip patterns 
replace rf_cons_quant=.z if rf_cons_quant_kdk>=.
replace rf_cons_unit=.z if rf_cons_quant>=.
replace rf_food_cons_unit=.z if rf_cons_unit>=. 
replace rf_maj_ownprod=.z if inlist(rf_food__id,28,44,77,89,90,97,101) 
replace rf_purc_quant=.z if rf_purc_quant_kdk>=.
replace rf_purc_unit=.z if rf_purc_quant>=.
replace rf_food_purc_unit=.z if rf_purc_unit>=.
replace rf_pric_total=.z if rf_pric_total_kdk>=. | rf_purc_quant<=0
replace rf_pric_total_curr=.z if rf_pric_total>=.
replace rf_free_quant=.z if rf_free_yn!=1 
replace rf_free_main=.z if rf_free_yn!=1 

*Clean variables 
replace rf_food_cons_unit=rf_food_cons_unit/1000 if rf_food_cons_unit<.
replace rf_food_purc_unit=rf_food_purc_unit/1000 if rf_food_purc_unit<.

*Label and rename 
foreach var in rf_cons_quant_kdk rf_cons_unit rf_maj_ownprod rf_purc_quant_kdk rf_purc_unit rf_pric_total_kdk rf_pric_total_curr rf_free_yn rf_free_main  {
	label define `var' .a "Don't know" .b "Refused to respond" .z "Not administered", modify
}
label var rf_food__id "Food ID"
label var rf_food_cons_unit "Quantity consumed in Kg"
label var rf_food_purc_unit "Quantity purchased in Kg"
rename (rf_food__id rf_cons_quant rf_cons_quant_kdk rf_cons_unit rf_food_cons_unit) (foodid cons_q cons_q_kdk cons_u cons_q_kg)
rename (rf_maj_ownprod rf_purc_quant_kdk rf_purc_quant rf_purc_unit rf_food_purc_unit) (ownprod purc_q_kdk purc_q purc_u purc_q_kg)
rename (rf_pric_total_kdk rf_pric_total rf_pric_total_curr rf_free_yn rf_free_quant rf_free_main) (pr_kdk pr pr_c free free_q free_main)

*Include the name of each item
label define lfoodid 1 "Paddy,  Basmati" 2 "Rice, husked" 3 "Green maize cob" 4 "Maize, grain" 5 "Maize, flour" 6 "Millet, grain" 7 "Millet, flour" 8 "Sorghum, grain" 9 "Sorghum, flour" 10 "Wheat, grain" 11 "Wheat, flour" 12 "Barley" 13 "Bread" 14 "Biscuits" 15 "Buns and cakes" 16 "Cooking oats, corn flakes" 17 "Macaroni, spaghetti" 18 "Chapati" 19 "Goat or sheep meat" 20 "Cattle meat (including mince sausages)" 21 "Dried meat, plain or chopped (Muqamad/Luqmad)" 22 "Offal (liver, kidney)" 23 "Canned meat" 24 "Wild birds and insects" 25 "Bones sauce" 26 "Fresh camel meat" 27 "Fresh chicken - local" 28 "Frozen chicken - import" 29 "Fresh fish" 30 "Dried or salted fish/shellfish" 31 "Canned fish/shellfish" 32 "Groundnuts in shell, cashewnuts, and almonds" 33 "Sweet/ripe bananas" 34 "Oranges/tangerines" 35 "Grapefruits" 36 "Lemons, guavas, limes" 37 "Mangoes" 38 "Avocados" 39 "Pawpaw" 40 "Pineapples" 41 "Melons" 42 "Apples and pears" 43 "Canned fruits" 44 "Dates - import (timir)" 45 "Potatoes" 46 "Cooking bananas, plantains" 47 "Peas, dry" 48 "Beans, dry" 49 "Lentils" 50 "White beans" 51 "Carrots" 52 "Radishes and beets" 53 "Garlic" 54 "Onion" 55 "Leeks" 56 "Spinach" 57 "Lettuce" 58 "Cabbage" 59 "Tomatoes" 60 "Lady's fingers/okra" 61 "Eggplant/brinjal" 62 "Canned vegetables" 63 "Dried vegetables" 64 "Cucumber" 65 "Pumpkin" 66 "Bell pepper" 67 "Begel" 68 "Canned sweetcorn" 69 "Ginger (zanjabiil)" 70 "Eggs" 71 "Yoghurt" 72 "Cream" 73 "Cheese" 74 "Cow milk (fresh or pasteurized)" 75 "Camel milk" 76 "Milk Powder" 77 "Sesame or sunflower oil" 78 "Coconut oil" 79 "Butter or margarine" 80 "Cooking oil (vegetable)" 81 "Olive oil" 82 "Canned and bottled juices and squashes" 83 "Vimto (squash)" 84 "Sugar canes" 85 "Sugar" 86 "Honey" 87 "Syrup, jams, marmalade, jellies" 88 "Chocolate and sweets" 89 "Baby foods excluding milk" 90 "Salt" 91 "Red or black pepper" 92 "Curry powder" 93 "Vinegar" 94 "Yeast, baking powder" 95 "Baker's vanilla (carfiso buskut)" 96 "Cardamom (heyl)" 97 "Cinnamon (qarfo)" 98 "Clove (dhago yare)" 99 "Foster Powder" 100 "Ketchup" 101 "Mayonnaise" 102 "Parsley - local (kabasr caleen)" 103 "Tea (leaves)" 104 "Coffee (beans, ground, or instant)" 105 "Bottled soft drinks" 106 "Water bottles/container" 107 "Fresh fruit juices" 108 "Breakfast from restaurant or vendor (outside the home)" 109 "Lunch from restaurant or vendor (outside the home)" 110 "Dinner from restaurant or vendor (outside the home)" 111 "Liquid tea, coffee, or soft drinks from restaurants or vendors" 112 "Liquid tea, coffee, soft drinks (from vendors and restaurants) consumed at home" 113 "Take-out meals (from vendors and restaurants) consumed at home" 114 "School meals prepared and consumed at school cafeteria or school restaurant"
label values foodid lfoodid

*Include module assignment 
gen mod_item=0 if inlist(foodid,1,2,5,7,9,13,14,17,18,19,20,26,31,33,44,45,47,48,50,51,52,53,54,57,59,74,75,76,80,81,82,85,90,103,108,109,110,111)
replace mod_item=1 if inlist(foodid,4,11,16,22,27,35,36,40,42,43,55,62,64,83,84,86,92,100,105,107,112)
replace mod_item=2 if inlist(foodid,6,10,28,29,32,41,56,63,65,71,78,94,95,96,97,98,106,114)
replace mod_item=3 if inlist(foodid,3,8,12,24,25,34,46,61,66,67,69,70,72,77,79,91,93,101,104)
replace mod_item=4 if inlist(foodid,15,21,23,30,37,38,39,49,58,60,68,73,87,88,89,99,102,113)
label var mod_item "Assignment of item to core/optional module"
order mod_item, after(foodid)

save "${gsdData}/0-RawTemp/hh_food_clean.dta", replace
