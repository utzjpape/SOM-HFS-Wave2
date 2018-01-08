*Process to clean the food consumption dataset 

set more off
set seed 23081960 
set sortseed 11041965


********************************************************************
*Open the food dataset and prepare the file
********************************************************************
*Obtain the full structure for all households and all items
use "${gsdData}/1-CleanInput/food.dta", clear
keep cons strata ea block hh foodid
reshape wide cons , i(strata ea block hh) j(foodid)
reshape long
merge 1:1 strata ea block hh foodid using "${gsdData}/1-CleanInput/food.dta", nogen keep(master match)
*Save the original structure to eventually include records with zero consumption, in order to get the mean consumption by item that ultimately will be assign to records that answered "don't know" or "refused to respond"
keep strata ea block hh foodid cons
rename cons cons_original
save "${gsdTemp}/food_hhs_fulldataset.dta", replace
use "${gsdData}/1-CleanInput/food.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(weight mod_opt)
order weight, after(hh)
drop cons_q_kdk ownprod pr_kdk free free_q free_main
rename mod_item opt_mod 
*Cleaning rule: convert to positive negative values (potential issue with CAPI)
foreach var in cons_q purc_q pr {
	replace `var'=-1*`var' if `var'<0
}
*Include conversion factors to Kg
qui foreach s in "cons" "purc" {
	gen conv_`s'_kg=.
	replace conv_`s'_kg=1 if `s'_u==1
	replace conv_`s'_kg=0.3 if `s'_u==2
	replace conv_`s'_kg=0.25 if `s'_u==3
	replace conv_`s'_kg=0.25 if `s'_u==4
	replace conv_`s'_kg=0.5 if `s'_u==5
	replace conv_`s'_kg=0.5 if `s'_u==6
	replace conv_`s'_kg=1.5 if `s'_u==7
	replace conv_`s'_kg=2 if `s'_u==8
	replace conv_`s'_kg=1 if `s'_u==9
	replace conv_`s'_kg=1 if `s'_u==10
	replace conv_`s'_kg=1.5 if `s'_u==11
	replace conv_`s'_kg=1.5 if `s'_u==12
	replace conv_`s'_kg=4 if `s'_u==13
	replace conv_`s'_kg=1 if `s'_u==14
	replace conv_`s'_kg=2.5 if `s'_u==15
	replace conv_`s'_kg=0.35 if `s'_u==16
	replace conv_`s'_kg=0.4 if `s'_u==17
	replace conv_`s'_kg=0.5 if `s'_u==18
	replace conv_`s'_kg=0.6 if `s'_u==19
	replace conv_`s'_kg=0.75 if `s'_u==20
	replace conv_`s'_kg=0.75 if `s'_u==21
	replace conv_`s'_kg=0.8 if `s'_u==22
	replace conv_`s'_kg=0.8 if `s'_u==23
	replace conv_`s'_kg=0.13 if `s'_u==24
	replace conv_`s'_kg=0.1 if `s'_u==25
	replace conv_`s'_kg=0.125 if `s'_u==26
	replace conv_`s'_kg=1 if `s'_u==27
	replace conv_`s'_kg=0.25 if `s'_u==28
	replace conv_`s'_kg=0.25 if `s'_u==29
	replace conv_`s'_kg=0.4 if `s'_u==30
	replace conv_`s'_kg=0.4 if `s'_u==31
	replace conv_`s'_kg=0.5 if `s'_u==32
	replace conv_`s'_kg=0.5 if `s'_u==33
	replace conv_`s'_kg=0.75 if `s'_u==34
	replace conv_`s'_kg=12 if `s'_u==35
	replace conv_`s'_kg=0.001 if `s'_u==36
	replace conv_`s'_kg=25 if `s'_u==37
	replace conv_`s'_kg=0.125 if `s'_u==38
	replace conv_`s'_kg=25 if `s'_u==39
	replace conv_`s'_kg=2 if `s'_u==40
	replace conv_`s'_kg=0.3 if `s'_u==41
	replace conv_`s'_kg=0.35 if `s'_u==42
	replace conv_`s'_kg=0.5 if `s'_u==43
	replace conv_`s'_kg=5 if `s'_u==44
	replace conv_`s'_kg=0.75 if `s'_u==45
	replace conv_`s'_kg=1 if `s'_u==46
	replace conv_`s'_kg=100 if `s'_u==47
	replace conv_`s'_kg=10 if `s'_u==48
	replace conv_`s'_kg=12 if `s'_u==49
	replace conv_`s'_kg=15 if `s'_u==50
	replace conv_`s'_kg=1 if `s'_u==51
	replace conv_`s'_kg=25 if `s'_u==52
	replace conv_`s'_kg=2 if `s'_u==53
	replace conv_`s'_kg=30 if `s'_u==54
	replace conv_`s'_kg=3 if `s'_u==55
	replace conv_`s'_kg=4 if `s'_u==56
	replace conv_`s'_kg=50 if `s'_u==57
	replace conv_`s'_kg=5 if `s'_u==58
	replace conv_`s'_kg=6 if `s'_u==59
	replace conv_`s'_kg=7 if `s'_u==60
	replace conv_`s'_kg=8 if `s'_u==61
	replace conv_`s'_kg=0.25 if `s'_u==62
	replace conv_`s'_kg=1 if `s'_u==63
	replace conv_`s'_kg=0.2 if `s'_u==64
	replace conv_`s'_kg=0.75 if `s'_u==65
	replace conv_`s'_kg=1.5 if `s'_u==66
	replace conv_`s'_kg=1 if `s'_u==67
	replace conv_`s'_kg=3 if `s'_u==68
	replace conv_`s'_kg=1.5 if `s'_u==69
	replace conv_`s'_kg=10 if `s'_u==70
	replace conv_`s'_kg=12.5 if `s'_u==71
	replace conv_`s'_kg=0.12 if `s'_u==72
	replace conv_`s'_kg=0.15 if `s'_u==73
	replace conv_`s'_kg=15 if `s'_u==74
	replace conv_`s'_kg=1 if `s'_u==75
	replace conv_`s'_kg=20 if `s'_u==76
	replace conv_`s'_kg=0.25 if `s'_u==77
	replace conv_`s'_kg=2 if `s'_u==78
	replace conv_`s'_kg=0.3 if `s'_u==79
	replace conv_`s'_kg=0.35 if `s'_u==80
	replace conv_`s'_kg=3 if `s'_u==81
	replace conv_`s'_kg=0.5 if `s'_u==82
	replace conv_`s'_kg=5 if `s'_u==83
	replace conv_`s'_kg=6 if `s'_u==84
	replace conv_`s'_kg=1.5 if `s'_u==85
	replace conv_`s'_kg=0.1 if `s'_u==86
	replace conv_`s'_kg=0.11 if `s'_u==87
	replace conv_`s'_kg=0.12 if `s'_u==88
	replace conv_`s'_kg=0.125 if `s'_u==89
	replace conv_`s'_kg=0.15 if `s'_u==90
	replace conv_`s'_kg=1 if `s'_u==91
	replace conv_`s'_kg=0.2 if `s'_u==92
	replace conv_`s'_kg=0.25 if `s'_u==93
	replace conv_`s'_kg=2 if `s'_u==94
	replace conv_`s'_kg=0.3 if `s'_u==95
	replace conv_`s'_kg=0.03 if `s'_u==96
	replace conv_`s'_kg=0.35 if `s'_u==97
	replace conv_`s'_kg=0.4 if `s'_u==98
	replace conv_`s'_kg=0.5 if `s'_u==99
	replace conv_`s'_kg=0.05 if `s'_u==100
	replace conv_`s'_kg=0.6 if `s'_u==101
	replace conv_`s'_kg=0.06 if `s'_u==102
	replace conv_`s'_kg=0.75 if `s'_u==103
	replace conv_`s'_kg=0.075 if `s'_u==104
	replace conv_`s'_kg=0.08 if `s'_u==105
	replace conv_`s'_kg=12.5 if `s'_u==106
	replace conv_`s'_kg=20 if `s'_u==107
	replace conv_`s'_kg=0.15 if `s'_u==108
	replace conv_`s'_kg=15 if `s'_u==109
	replace conv_`s'_kg=1 if `s'_u==110
	replace conv_`s'_kg=2.5 if `s'_u==111
	replace conv_`s'_kg=0.25 if `s'_u==112
	replace conv_`s'_kg=2 if `s'_u==113
	replace conv_`s'_kg=3 if `s'_u==114
	replace conv_`s'_kg=4 if `s'_u==115
	replace conv_`s'_kg=0.5 if `s'_u==116
	replace conv_`s'_kg=5 if `s'_u==117
	replace conv_`s'_kg=6 if `s'_u==118
	replace conv_`s'_kg=0.75 if `s'_u==119
	replace conv_`s'_kg=0.125 if `s'_u==120
	replace conv_`s'_kg=0.2 if `s'_u==121
	replace conv_`s'_kg=0.04 if `s'_u==122
	replace conv_`s'_kg=0.004 if `s'_u==123
	replace conv_`s'_kg=1 if `s'_u==124
	replace conv_`s'_kg=0.125 if `s'_u==125
}
*Convert consumption values to Kg
gen cons_q_kg=cons_q*conv_cons_kg
gen purc_q_kg=purc_q*conv_purc_kg
order cons_q_kg, after(cons_u)
order purc_q_kg, after(purc_u)
drop conv_cons_kg conv_purc_kg

********************************************************************
*Introduce cleaning rules for units
********************************************************************
*Tag items with same figure in quantity consumed, quantity purchased and price
*Exclude these records from the median estimation (for consumed quantity), and eventually replace their consumed quantity by the median
gen cons_same_figures_tag=1 if (cons==1 & cons_q<.) & (cons_q == purc_q) & (purc_q == pr) 
*Tag items with same figure for quantity purchased and price
*Exclude these records from the median estimation (for purchase quantity and unit price), and eventually replace their unit price by the median
gen purc_same_figures_tag=1 if (purc_q_kdk<. & purc_q<.) & (purc_q == pr) 
*Tag units where a record has the same figure in quantity consumed and purchased, and different units
gen different_u_tag=1 if (cons_q==purc_q ) & (cons_u!=purc_u) & (cons==1 & cons_q<. & purc_q<.)
*Cleaning rule: the correct unit is the one that takes the variable (consumption or purchase) closer to the weighted median value in the distribution of that variable for the same item 
*Obtain the median quantity consumed/purchased
local ls = "cons purc"
levelsof foodid, local(items)
foreach s of local ls {
	gen `s'_kg_median=.
	quietly foreach item of local items {
		   sum `s'_q_kg [aw= weight] if foodid==`item' & `s'_same_figures_tag!=1, detail
		   replace `s'_kg_median=r(p50) if foodid==`item'  
}
}
*Obtain the absolute difference between the quantity and the median for the respective item
gen diff_cons_kg=abs(cons_q_kg - cons_kg_median) if different_u_tag==1
gen diff_purc_kg=abs(purc_q_kg - purc_kg_median) if different_u_tag==1
*Introduce the replacements
replace cons_u=purc_u if diff_purc_kg<diff_cons_kg & different_u_tag==1
replace cons_q_kg=purc_q_kg if diff_purc_kg<diff_cons_kg & different_u_tag==1
replace purc_u=cons_u if diff_purc_kg>diff_cons_kg & different_u_tag==1
replace purc_kg=cons_kg if diff_purc_kg>diff_cons_kg & different_u_tag==1
drop cons_kg_median purc_kg_median diff_cons_kg diff_purc_kg
*Then we start corrections related to units
*Cleaning rule: manual corrections for consumption/purchase quantity in kg casued by an issue with units in following cases 1) quantities consumed below 1 gram; and 2) other ad-hoc 
gen cons_u_tag=.
gen purc_u_tag=.
local ls = "cons purc"
foreach s of local ls{
	*250 ml/gr units: if quantity<=.03, multiply by 4 because the enumerator probably meant lt/Kg
	replace `s'_u_tag=1            if (`s'_q_kg<=0.03 & inlist(`s'_u,3,4,28,29,62,77,93,112))
	replace `s'_q_kg=`s'_q_kg*4    if (`s'_q_kg<=0.03 & inlist(`s'_u,3,4,28,29,62,77,93,112))	
	*animal back, ribs, shoulder, thigh, head or leg: if quantity>=10 kg, divide by 10 because the enumerator probably meant kg
	replace `s'_u_tag=1            if (`s'_q_kg>=10 & `s'_q_kg<. & `s'_u>=7 & `s'_u<=12 )
	replace `s'_q_kg=`s'_q_kg/10   if (`s'_q_kg>=10 & `s'_q_kg<. & `s'_u>=7 & `s'_u<=12 )
	*basket or dengu (2 kg): if quantity>=10 divide by 10 because the enumerator probably meant kg
	replace `s'_u_tag=1            if (`s'_q_kg>=10 & `s'_q_kg<. & inlist(`s'_u,40,53,78,94,113))
	replace `s'_q_kg=`s'_q_kg/10   if (`s'_q_kg>=10 & `s'_q_kg<. & inlist(`s'_u,40,53,78,94,113))
	*kilogram (1 kg): if quantity>=100 divide by 1,000 because the enumerator probably meant grams
	replace `s'_u_tag=1              if (`s'_q_kg>=100 & `s'_q_kg<. & inlist(`s'_u,1,14,27,46,51,63,67,75,91,110,124))
	replace `s'_q_kg=`s'_q_kg/1000   if (`s'_q_kg>=100 & `s'_q_kg<. & inlist(`s'_u,1,14,27,46,51,63,67,75,91,110,124))
	*kilogram (1 kg): if quantity>20 divide by 10 because the enumerator probably meant grams
	replace `s'_u_tag=1            if (`s'_q_kg>20 & `s'_q_kg<. & inlist(`s'_u,1,14,27,46,51,63,67,75,91,110,124))
	replace `s'_q_kg=`s'_q_kg/10   if (`s'_q_kg>20 & `s'_q_kg<. & inlist(`s'_u,1,14,27,46,51,63,67,75,91,110,124))	
	*spoonfull (200g): if quantity>=2 by 2 because the enumerator probably meant grams
	replace `s'_u_tag=1            if (`s'_q_kg>=2 & `s'_q_kg<. & inlist(`s'_u,64,92,121))
	replace `s'_q_kg=`s'_q_kg/2    if (`s'_q_kg>=2 & `s'_q_kg<. & inlist(`s'_u,64,92,121))
	*faraasilad (12kg): if quantity>12 by 12 because the enumerator probably meant kg
	replace `s'_u_tag=1             if (`s'_q_kg>12 & `s'_q_kg<. & inlist(`s'_u,35,49))
	replace `s'_q_kg=`s'_q_kg/12    if (`s'_q_kg>12 & `s'_q_kg<. & inlist(`s'_u,35,49))
	*gram: if quantity<=0.001 (<1 gram) & item is a spice, then multiply by 100 because the enumerator probably meant grams
	replace `s'_u_tag=1             if (`s'_q_kg<=0.0011 & `s'_q_kg<. & `s'_u==36) & inlist(foodid,53,85,90,91,92,94,95,96,97,98,99)
	replace `s'_q_kg=`s'_q_kg*100   if (`s'_q_kg<=0.0011 & `s'_q_kg<. & `s'_u==36) & inlist(foodid,53,85,90,91,92,94,95,96,97,98,99)
	*gram: if quantity<=0.001 (<1 gram) & item is not a spice, then multiply by 1,000 because the enumerator probably meant kg
	replace `s'_u_tag=1              if (`s'_q_kg<=0.0011 & `s'_q_kg<. & `s'_u==36) & !inlist(foodid,53,85,90,91,92,94,95,96,97,98,99)
	replace `s'_q_kg=`s'_q_kg*1000   if (`s'_q_kg<=0.0011 & `s'_q_kg<. & `s'_u==36) & !inlist(foodid,53,85,90,91,92,94,95,96,97,98,99)
	*haaf (25 kg): if quantity>=25, divide by 25 because the enumerator probably meant kg
	replace `s'_u_tag=1             if (`s'_q_kg>=25 & `s'_q_kg<. & inlist(`s'_u,37,39,52))
	replace `s'_q_kg=`s'_q_kg/25    if (`s'_q_kg>=25 & `s'_q_kg<. & inlist(`s'_u,37,39,52))
	*heap (750g): if quantity >=7.5 divide by 10 because the enumerator probably meant Kg
	replace `s'_u_tag=1              if (`s'_q_kg>=7.5 & `s'_q_kg<. & inlist(`s'_u,20,21,34,45,65,103,119))
	replace `s'_q_kg=`s'_q_kg/10     if (`s'_q_kg>=7.5 & `s'_q_kg<. & inlist(`s'_u,20,21,34,45,65,103,119))
	*large bag (50 kg): if quantity >=50 divide by 50 because the enumerator probably meant kg
	replace `s'_u_tag=1                if (`s'_q_kg>=50 & `s'_q_kg<. & `s'_u==57)
	replace `s'_q_kg=`s'_q_kg/50       if (`s'_q_kg>=50 & `s'_q_kg<. & `s'_u==57)
	*spoonfull (4 g): if quantity<0.004 multiply by 25 because the enumerator probably meant grams			
	replace `s'_u_tag=1                if (`s'_q_kg<0.004 & `s'_u==123)
	replace `s'_q_kg=`s'_q_kg*25       if (`s'_q_kg<0.004 & `s'_u==123)
	*piece (30 g): if quantity<=0.02 multiply by 3.334 because the enumerator probably meant grams			
	replace `s'_u_tag=1                if (`s'_q_kg<=0.02 & `s'_q_kg<. & `s'_u==96)
	replace `s'_q_kg=`s'_q_kg*3.334    if (`s'_q_kg<=0.02 & `s'_q_kg<. & `s'_u==96)	
 	*piece (40 g): if quantity<=0.03 multiply by 2.5 because the enumerator probably meant grams			
	replace `s'_u_tag=1              if (`s'_q_kg<=0.03 & `s'_q_kg<. & `s'_u==122)
	replace `s'_q_kg=`s'_q_kg*2.5    if (`s'_q_kg<=0.03 & `s'_q_kg<. & `s'_u==122)
 	*piece (50 g): if quantity<=0.04 multiply by 2 because the enumerator probably meant grams			
	replace `s'_u_tag=1            if (`s'_q_kg<=0.04 & `s'_q_kg<. & `s'_u==100)
	replace `s'_q_kg=`s'_q_kg*2    if (`s'_q_kg<=0.04 & `s'_q_kg<. & `s'_u==100)
 	*piece (60 g): if quantity<=0.05 multiply by 1.6667 because the enumerator probably meant grams			
	replace `s'_u_tag=1                 if (`s'_q_kg<=0.05 & `s'_q_kg<. & `s'_u==102)
	replace `s'_q_kg=`s'_q_kg*1.6667    if (`s'_q_kg<=0.05 & `s'_q_kg<. & `s'_u==102)
 	*piece (75 g): if quantity<=0.065 multiply by 1.3334 because the enumerator probably meant grams			
	replace `s'_u_tag=1                 if (`s'_q_kg<=0.065 & `s'_q_kg<. & `s'_u==104)
	replace `s'_q_kg=`s'_q_kg*1.3334    if (`s'_q_kg<=0.065 & `s'_q_kg<. & `s'_u==104)
	*piece (100g): if quantity >=10 divide by 100 because the enumerator probably meant grams
	replace `s'_u_tag=1                 if (`s'_q_kg>=10 & `s'_q_kg<. & (`s'_u==86 | `s'_u==25) )
	replace `s'_q_kg=`s'_q_kg/100       if (`s'_q_kg>=10 & `s'_q_kg<. & (`s'_u==86 | `s'_u==25) )
	*piece (110g): if quantity >=11 divide by 110 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=11 & `s'_q_kg<. & `s'_u==87 )
	replace `s'_q_kg=`s'_q_kg/110      if (`s'_q_kg>=11 & `s'_q_kg<. & `s'_u==87 )
	*piece (120g): if quantity >=12 divide by 120 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=12 & `s'_q_kg<. & (`s'_u==88 | `s'_u==72))
	replace `s'_q_kg=`s'_q_kg/120      if (`s'_q_kg>=12 & `s'_q_kg<. & (`s'_u==88 | `s'_u==72))
	*piece (125g): if quantity >=12.5 divide by 125 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=12.5 & `s'_q_kg<. & inlist(`s'_u,26,38,89,120,125))
	replace `s'_q_kg=`s'_q_kg/125      if (`s'_q_kg>=12.5 & `s'_q_kg<. & inlist(`s'_u,26,38,89,120,125))
	*piece (130g): if quantity >=13 divide by 130 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=13 & `s'_q_kg<. & `s'_u==24)
	replace `s'_q_kg=`s'_q_kg/130      if (`s'_q_kg>=13 & `s'_q_kg<. & `s'_u==24)
	*piece (150g): if quantity >=15 divide by 150 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=15 & `s'_q_kg<. & inlist(`s'_u,73,90,108))
	replace `s'_q_kg=`s'_q_kg/150      if (`s'_q_kg>=15 & `s'_q_kg<. & inlist(`s'_u,73,90,108))
	*piece (300g): if quantity >=30 divide by 300 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=30 & `s'_q_kg<. & inlist(`s'_u,2,41,79,95))
	replace `s'_q_kg=`s'_q_kg/300      if (`s'_q_kg>=30 & `s'_q_kg<. & inlist(`s'_u,2,41,79,95))
	*piece (350g): if quantity >=35 divide by 350 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=35 & `s'_q_kg<. & inlist(`s'_u,16,42,80,97))
	replace `s'_q_kg=`s'_q_kg/350      if (`s'_q_kg>=35 & `s'_q_kg<. & inlist(`s'_u,16,42,80,97))
	*piece (400g): if quantity >=40 divide by 400 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=40 & `s'_q_kg<. & inlist(`s'_u,17,30,31,98))
	replace `s'_q_kg=`s'_q_kg/400      if (`s'_q_kg>=40 & `s'_q_kg<. & inlist(`s'_u,17,30,31,98))
	*piece (500g): if quantity >=50 divide by 500 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=50 & `s'_q_kg<. & inlist(`s'_u,5,6,18,32,33,43,82,99,116))
	replace `s'_q_kg=`s'_q_kg/500      if (`s'_q_kg>=50 & `s'_q_kg<. & inlist(`s'_u,5,6,18,32,33,43,82,99,116))
	*piece (600g): if quantity >=60 divide by 600 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=60 & `s'_q_kg<. & inlist(`s'_u,19,101))
	replace `s'_q_kg=`s'_q_kg/600      if (`s'_q_kg>=60 & `s'_q_kg<. & inlist(`s'_u,19,101))
	*piece (800g): if quantity >=80 divide by 800 because the enumerator probably meant grams
	replace `s'_u_tag=1                if (`s'_q_kg>=80 & `s'_q_kg<. & inlist(`s'_u,22,23))
	replace `s'_q_kg=`s'_q_kg/800      if (`s'_q_kg>=80 & `s'_q_kg<. & inlist(`s'_u,22,23))
	*rufuc/Jodha (12.5kg): if quantity >12.5 divide by 12.5 because the enumerator probably meant kg
	replace `s'_u_tag=1                if (`s'_q_kg>12.5 & `s'_q_kg<. & inlist(`s'_u,71,106))
	replace `s'_q_kg=`s'_q_kg/12.5     if (`s'_q_kg>12.5 & `s'_q_kg<. & inlist(`s'_u,71,106))
	*large bag (10 kg): if quantity >10 divide by 10 because the enumerator probably meant kg
	replace `s'_u_tag=1              if (`s'_q_kg>10 & `s'_q_kg<. & inlist(`s'_u,48,70))
	replace `s'_q_kg=`s'_q_kg/10     if (`s'_q_kg>10 & `s'_q_kg<. & inlist(`s'_u,48,70))
	*large bag (8 kg): if quantity >8 divide by 8 because the enumerator probably meant kg
	replace `s'_u_tag=1             if (`s'_q_kg>8 & `s'_q_kg<. & inlist(`s'_u,61))
	replace `s'_q_kg=`s'_q_kg/8     if (`s'_q_kg>8 & `s'_q_kg<. & inlist(`s'_u,61))
	*large bag (7 kg): if quantity >7 divide by 7 because the enumerator probably meant kg
	replace `s'_u_tag=1             if (`s'_q_kg>7 & `s'_q_kg<. & inlist(`s'_u,60))
	replace `s'_q_kg=`s'_q_kg/7     if (`s'_q_kg>7 & `s'_q_kg<. & inlist(`s'_u,60))
	*large bag (6 kg): if quantity >6 divide by 6 because the enumerator probably meant kg
	replace `s'_u_tag=1             if (`s'_q_kg>6 & `s'_q_kg<. & inlist(`s'_u,59,84,118))
	replace `s'_q_kg=`s'_q_kg/6     if (`s'_q_kg>6 & `s'_q_kg<. & inlist(`s'_u,59,84,118))
	*large bag (5 kg): if quantity >5 divide by 5 because the enumerator probably meant kg
	replace `s'_u_tag=1             if (`s'_q_kg>5 & `s'_q_kg<. & inlist(`s'_u,44,58,83,117))
	replace `s'_q_kg=`s'_q_kg/5     if (`s'_q_kg>5 & `s'_q_kg<. & inlist(`s'_u,44,58,83,117))
	*large bag (4 kg): if quantity >=16 divide by 4 because the enumerator probably meant kg
	replace `s'_u_tag=1             if (`s'_q_kg>=16 & `s'_q_kg<. & inlist(`s'_u,13,56,115))
	replace `s'_q_kg=`s'_q_kg/4     if (`s'_q_kg>=16 & `s'_q_kg<. & inlist(`s'_u,13,56,115))
	*large bag (3 kg): if quantity >=9 divide by 3 because the enumerator probably meant kg
	replace `s'_u_tag=1             if (`s'_q_kg>=9 & `s'_q_kg<. & inlist(`s'_u,55,68,81,114))
	replace `s'_q_kg=`s'_q_kg/3     if (`s'_q_kg>=9 & `s'_q_kg<. & inlist(`s'_u,55,68,81,114))
	*large bag (2.5 kg): if quantity >=6.25 divide by 6.25 because the enumerator probably meant kg
	replace `s'_u_tag=1               if (`s'_q_kg>=6.25 & `s'_q_kg<. & inlist(`s'_u,15,111))
	replace `s'_q_kg=`s'_q_kg/2.5     if (`s'_q_kg>=6.25 & `s'_q_kg<. & inlist(`s'_u,15,111))
	*large bag (1.5 kg): if quantity >=2.25 divide by 1.5 because the enumerator probably meant kg
	replace `s'_u_tag=1               if (`s'_q_kg>=2.25 & `s'_q_kg<. & inlist(`s'_u,66,69,85))
	replace `s'_q_kg=`s'_q_kg/1.5     if (`s'_q_kg>=2.25 & `s'_q_kg<. & inlist(`s'_u,66,69,85))
	*large bag (15kg): if quantity >=15 divide by 10 because the enumerator probably meant kg
	replace `s'_u_tag=1                if (`s'_q_kg>=15 & `s'_q_kg<. & inlist(`s'_u,50,74,109))
	replace `s'_q_kg=`s'_q_kg/10       if (`s'_q_kg>=15 & `s'_q_kg<. & inlist(`s'_u,50,74,109))
	*saxarad (20kg): if quantity >=20 divide by 20 because the enumerator probably meant kg
	replace `s'_u_tag=1                if (`s'_q_kg>=20 & `s'_q_kg<. & inlist(`s'_u,76,107))
	replace `s'_q_kg=`s'_q_kg/20       if (`s'_q_kg>=20 & `s'_q_kg<. & inlist(`s'_u,76,107))
	*large bag (30kg): if quantity >=30 divide by 30 because the enumerator probably meant kg
	replace `s'_u_tag=1                if (`s'_q_kg>=30 & `s'_q_kg<. & inlist(`s'_u,54))
	replace `s'_q_kg=`s'_q_kg/30       if (`s'_q_kg>=30 & `s'_q_kg<. & inlist(`s'_u,54))
	*large bag (100kg): if quantity >=100 divide by 100 because the enumerator probably meant kg
	replace `s'_u_tag=1                 if (`s'_q_kg>=100 & `s'_q_kg<. & inlist(`s'_u,47))
	replace `s'_q_kg=`s'_q_kg/100       if (`s'_q_kg>=100 & `s'_q_kg<. & inlist(`s'_u,47))
}
*Correct remaining cases where consumption or purchase was less than 1 gram
*Cleaning rule: multiply by 100 if consumption is less than 1 gram
replace cons_q_kg=cons_q_kg*100 if cons_q_kg<=.0011
replace purc_q_kg=purc_q_kg*100 if purc_q_kg<=.0011


********************************************************************
*Introduce corrections related to currency issues
********************************************************************
*Cleaning rule: replace Somaliland shillings for Somali shillings, as they should not be used outside of Somaliland
*Note that strata 47 was able to respond in both Somali and Somalilan Shillings
replace pr_c=4 if pr_c==2 & inlist(strata,6,17,18,19,20,21,44,45,46,48,49,50,51)
replace pr_c=2 if pr_c==4 & !inlist(strata,6,17,18,19,20,21,44,45,46,48,49,50,51)
assert pr_c==4 | pr_c==5 | pr_c==.z if inlist(strata,6,17,18,19,20,21,44,45,46,48,49,50,51)
assert pr_c==2 | pr_c==5 | pr_c==.z if !inlist(strata,6,17,18,19,20,21,44,45,46,47,48,49,50,51)
*Cleaning rule: change USD to local currency (for each zone) when the price is equal or greater than 1,000
replace pr_c=4 if pr >= 1000 & pr<. & pr_c==5 & inlist(strata,6,17,18,19,20,21,44,45,46,48,49,50,51)
replace pr_c=2 if pr >= 1000 & pr<. & pr_c==5 & !inlist(strata,6,17,18,19,20,21,44,45,46,48,49,50,51)
*Cleaning rule: change local currency larger than 500,000 (divide by 10)
replace pr=pr/10 if pr>500000 & pr<.


********************************************************************
*Deal items consumed without information on quantities
********************************************************************
*Tag records that reported to have consumed/purchased the item but do not report a quantity 
gen cons_q_tag=1 if cons==1 & cons_q>=.
gen purc_q_tag=1 if purc_q>=.
*include previous tag for records with same figure in quantity consumed/purchased
replace cons_q_tag=1 if cons_same_figures_tag==1
*include a constraint for cases with consumption>25 kg per item
replace cons_q_tag=1 if cons_q_kg>25
*cleaning rule: replace tagged records with the median consumption/purchased quantity (per kg) by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item. Exclude quantities greater than 25 kg per item  
gen xq_cons =cons_q_kg if cons_q_tag!=1
gen xq_purc =purc_q_kg if purc_q_tag!=1
*obtain the weigthed median (quantity per kg) by level of aggregation
local ls = "cons purc"
foreach s of local ls {
	*by ea and foodid
	bysort foodid ea: egen prelim_`s'_q_kg_ea_count= count(`s'_q_kg) if `s'_same_figures_tag!=1 & `s'_q_tag!=1 & xq_`s'<=25
	bysort foodid ea: egen `s'_q_kg_ea_count= max(prelim_`s'_q_kg_ea_count) 
	bysort foodid ea: egen prelim_`s'_q_kg_ea_median=median(xq_`s') if `s'_same_figures_tag!=1 & xq_`s'<=25
	bysort foodid ea: egen `s'_q_kg_ea_median=max(prelim_`s'_q_kg_ea_median) 
	*by strata and foodid	
	bysort foodid strata: egen prelim_`s'_q_kg_strata_count= count(`s'_q_kg) if `s'_same_figures_tag!=1 & `s'_q_tag!=1 & xq_`s'<=25
	bysort foodid strata: egen `s'_q_kg_strata_count= max(prelim_`s'_q_kg_strata_count) 
	bysort foodid strata: egen prelim_`s'_q_kg_strata_median=median(xq_`s') if `s'_same_figures_tag!=1 & xq_`s'<=25
	bysort foodid strata: egen `s'_q_kg_strata_median=max(prelim_`s'_q_kg_strata_median)
	*by foodid	
	bysort foodid: egen prelim_`s'_q_kg_item_count= count(`s'_q_kg) if `s'_same_figures_tag!=1 & `s'_q_tag!=1 & xq_`s'<=25
	bysort foodid: egen `s'_q_kg_item_count= max(prelim_`s'_q_kg_item_count) 
	bysort foodid: egen prelim_`s'_q_kg_item_median=median(xq_`s') if `s'_same_figures_tag!=1 & xq_`s'<=25
    bysort foodid: egen `s'_q_kg_item_median=max(prelim_`s'_q_kg_item_median) 
}
*introduce the replacements for the cleaning rule to the quantity consumed/purchased per kg (with a median <20 kg and >0.02 kg)
local ls = "cons purc"
foreach s of local ls {
replace `s'_q_kg=`s'_q_kg_ea_median if (`s'_q_tag==1) & (`s'_q_kg_ea_median<20 & `s'_q_kg_ea_median>0.02) & (`s'_q_kg_ea_count>=5 & `s'_q_kg_ea_count<.)
replace `s'_q_kg=`s'_q_kg_strata_median if (`s'_q_tag==1) & (`s'_q_kg_strata_median<20 & `s'_q_kg_strata_median>0.02) & (`s'_q_kg_ea_count<5 | `s'_q_kg_ea_count>=. | `s'_q_kg_ea_median>=20 | `s'_q_kg_ea_median<=0.02) & (`s'_q_kg_strata_count>=5 & `s'_q_kg_strata_count<.)
replace `s'_q_kg=`s'_q_kg_item_median if (`s'_q_tag==1) & (`s'_q_kg_item_median<.) & (`s'_q_kg_ea_count<5 | `s'_q_kg_ea_count>=. | `s'_q_kg_ea_median>=20 | `s'_q_kg_ea_median<=0.02) & (`s'_q_kg_strata_count<5 | `s'_q_kg_strata_count>=. | `s'_q_kg_strata_median>=20 | `s'_q_kg_strata_median<=0.2) 
}
*check if there are food items with less than 5 observations
tab foodid if purc_q_tag==1 & purc_q_kg_item_count<5
tab foodid if cons_q_tag==1 & cons_q_kg_item_count<5
drop prelim_* xq_cons xq_purc purc_q_kg_ea_count purc_q_kg_strata_count purc_q_kg_item_count cons_q_kg_ea_count cons_q_kg_strata_count cons_q_kg_item_count cons_q_kg_ea_median purc_q_kg_ea_median cons_q_kg_strata_median purc_q_kg_strata_median cons_q_kg_item_median purc_q_kg_item_median


********************************************************************
*Obtain unit prices and identify issues
********************************************************************
*Include the exchange rate for each zone
drop team
gen team=1 if inlist(strata,6,17,18,19,20,21,44,45,46,47,48,49,50,51)
replace team=2 if !inlist(strata,6,17,18,19,20,21,44,45,46,47,48,49,50,51)
merge m:1 team using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(average_er)
*obtain a price in USD
gen pr_usd=pr if pr_c==5
replace pr_usd=pr/(average_er/1000) if pr_c==2 | pr_c==4
drop average_er team
*obtain unit price (USD) per kilo
gen unit_price=pr_usd/purc_q_kg
*tag records that reported 1) to have purchased the item but do not report a price; 2) a quantity consumed but not purchased; or 3) a price equal to zero 
gen purc_p_tag=1 if purc_q_kdk==1 & pr>=.
replace purc_p_tag=1 if cons==1 & purc_q_kdk!=1
replace purc_p_tag=1 if pr<=0
*include previous tag for records with same figure in quantity purchased and price
replace purc_p_tag=1 if purc_same_figures_tag==1
*include a constraint for cases with a unit price>20 USD & unit price<.005 USD
replace purc_p_tag=1 if unit_price>20
replace purc_p_tag=1 if unit_price<0.005
*cleaning rule: replace tagged records with the median unit price by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item. Exclude prices >20 USD and <0.005 
gen xq = unit_price if purc_p_tag!=1
*obtain the weigthed median (unit_price) by level of aggregation
*by ea and foodid
bysort foodid ea: egen prelim_unit_price_ea_count= count(unit_price) if purc_same_figures_tag!=1 & purc_p_tag!=1 & xq<=20 & xq>=0.005
bysort foodid ea: egen unit_price_ea_count= max(prelim_unit_price_ea_count) 
bysort foodid ea: egen prelim_unit_price_ea_median= median(unit_price) if purc_same_figures_tag!=1 & xq<=20 & xq>=0.005
bysort foodid ea: egen unit_price_ea_median= max(prelim_unit_price_ea_median)
*by strata and foodid
bysort foodid strata: egen prelim_unit_price_strata_count= count(unit_price) if purc_same_figures_tag!=1 & purc_p_tag!=1 & xq<=20 & xq>=0.005
bysort foodid strata: egen unit_price_strata_count= max(prelim_unit_price_strata_count)
bysort foodid strata: egen prelim_unit_price_strata_median= median(unit_price) if purc_same_figures_tag!=1 & xq<=20 & xq>=0.005
bysort foodid strata: egen unit_price_strata_median= max(prelim_unit_price_strata_median)
*by foodid
bysort foodid: egen prelim_unit_price_item_count= count(unit_price) if purc_same_figures_tag!=1 & purc_p_tag!=1 & xq<=20 & xq>=0.005
bysort foodid: egen unit_price_item_count= max(prelim_unit_price_item_count)
bysort foodid: egen prelim_unit_price_item_median= median(unit_price) if purc_same_figures_tag!=1 & xq<=20 & xq>=0.005
bysort foodid: egen unit_price_item_median= max(prelim_unit_price_item_median)
*introduce the replacements for the cleaning rule to the unit price per kg (with a median <15 UDS and >0.2 USD)
replace unit_price=unit_price_ea_median if (purc_p_tag==1) & (unit_price_ea_median<15 & unit_price_ea_median>0.2) & (unit_price_ea_count>=5 & unit_price_ea_count<.)  
replace unit_price=unit_price_strata_median if (purc_p_tag==1) & (unit_price_strata_median<15 & unit_price_strata_median>0.2) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=15 | unit_price_ea_median<=0.2) & (unit_price_strata_count>=5 & unit_price_strata_count<.) 
replace unit_price=unit_price_item_median if (purc_p_tag==1) & (unit_price_item_median<.) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=15 | unit_price_ea_median<=0.2) & (unit_price_strata_count<5 | unit_price_strata_count>=. | unit_price_strata_median>=15 | unit_price_strata_median<=0.2) 
*check if there are food items with less than 5 observations
tab foodid if purc_p_tag==1 & unit_price_item_count<5
drop prelim_* xq unit_price_*


********************************************************************
*Clean unit prices
********************************************************************
*cleaning rule: replace 1) unit prices in the top 10% and 2) below 0.07 with the median price by item and EA (if there are at least 5 records), or item and Strata (if there are at least 5 records) or item
set sortseed 11041965
cumul unit_price, gen (unit_price_distribution) equal
*by ea and foodid
bysort foodid ea: egen prelim_unit_price_ea_count= count(unit_price) if unit_price_distribution<0.9
bysort foodid ea: egen unit_price_ea_count= max(prelim_unit_price_ea_count) 
bysort foodid ea: egen prelim_unit_price_ea_median= median(unit_price) if unit_price_distribution<0.9
bysort foodid ea: egen unit_price_ea_median= max(prelim_unit_price_ea_median)
*by strata and foodid
bysort foodid strata: egen prelim_unit_price_strata_count= count(unit_price) if unit_price_distribution<0.9
bysort foodid strata: egen unit_price_strata_count= max(prelim_unit_price_strata_count)
bysort foodid strata: egen prelim_unit_price_strata_median= median(unit_price) if unit_price_distribution<0.9
bysort foodid strata: egen unit_price_strata_median= max(prelim_unit_price_strata_median)
*by foodid
bysort foodid: egen prelim_unit_price_item_count= count(unit_price) if unit_price_distribution<0.9
bysort foodid: egen unit_price_item_count= max(prelim_unit_price_item_count)
bysort foodid: egen prelim_unit_price_item_median= median(unit_price) if unit_price_distribution<0.9
bysort foodid: egen unit_price_item_median= max(prelim_unit_price_item_median)
*introduce the replacements for the cleaning rule to unit price per kg
replace unit_price=unit_price_ea_median if (unit_price_distribution>=0.9) & (unit_price_ea_median<. & unit_price_ea_median>0.2) & (unit_price_ea_count>=5 & unit_price_ea_count<.)  
replace unit_price=unit_price_strata_median if (unit_price_distribution>=0.9) & (unit_price_strata_median<. & unit_price_strata_median>0.2) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=. | unit_price_ea_median<=0.2) & (unit_price_strata_count>=5 & unit_price_strata_count<.) 
replace unit_price=unit_price_item_median if (unit_price_distribution>=0.9) & (unit_price_item_median<.) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=. | unit_price_ea_median<=0.2) & (unit_price_strata_count<5 | unit_price_strata_count>=. | unit_price_strata_median>=. | unit_price_strata_median<=0.2) 
replace unit_price=unit_price_ea_median if (unit_price<0.07) & (unit_price_ea_median<. & unit_price_ea_median>0.2) & (unit_price_ea_count>=5 & unit_price_ea_count<.)  
replace unit_price=unit_price_strata_median if (unit_price<0.07) & (unit_price_strata_median<. & unit_price_strata_median>0.2) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=. | unit_price_ea_median<=0.2) & (unit_price_strata_count>=5 & unit_price_strata_count<.) 
replace unit_price=unit_price_item_median if (unit_price<0.07) & (unit_price_item_median<.) & (unit_price_ea_count<5 | unit_price_ea_count>=. | unit_price_ea_median>=. | unit_price_ea_median<=0.2) & (unit_price_strata_count<5 | unit_price_strata_count>=. | unit_price_strata_median>=. | unit_price_strata_median<=0.2) 
drop prelim_* unit_price_*


********************************************************************
*Obtain consumption in USD and clean the consumption values
********************************************************************
gen cons_usd=cons_q_kg*unit_price
label var cons_usd "Current consumption in USD (7 days)"
*cleaning rule: truncate the consumption value in USD if the value exceeds the mean plus 3 times the standard deviation
gen x=.
levelsof foodid, local(items)
quietly foreach item of local items {
   sum cons_usd [aw= weight] if foodid==`item', detail
   replace x=r(mean) if foodid==`item'  
}	
gen y=.
levelsof foodid, local(items)
quietly foreach item of local items {
   sum cons_usd [aw= weight] if foodid==`item', detail
   replace y=r(sd) if foodid==`item'  
}	
bysort foodid: egen z = max(cons_usd) if cons_usd<=x+3*y
bysort foodid: egen zz = max(z)
replace cons_usd = zz if cons_usd>x+3*y & cons_usd<.
drop x y z zz
save "${gsdTemp}/food_clean_byitem.dta", replace


********************************************************************
*Prepare the output files at the item and household level 
********************************************************************
*First we merge with the full dataset to retrive records with zero consumption
merge 1:1 strata ea block hh foodid using "${gsdTemp}/food_hhs_fulldataset.dta"
assert cons_original==cons if _merge==3
*Include relevant info to differentiate between zero and items not administered
drop region weight enum mod_opt opt_mod
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(region weight enum mod_opt)
merge m:m foodid using "${gsdData}/1-CleanInput/food.dta", nogen keep(master match) keepusing(mod_item)
*Introduce zero consumption 
replace cons=0 if cons_original>=. & (mod_item==0 | mod_opt==mod_item)
replace cons_usd=0 if cons_original>=. & (mod_item==0 | mod_opt==mod_item)
foreach var in cons_q cons_u cons_q_kg purc_q_kdk purc_q purc_u purc_q_kg pr pr_c {
	replace `var'=.z  if cons_original>=. & (mod_item==0 | mod_opt==mod_item)
}
*Correctly label items not administered 
foreach var in cons cons_q cons_u cons_q_kg purc_q_kdk purc_q purc_u purc_q_kg pr pr_c cons_same_figures_tag purc_same_figures_tag different_u_tag cons_u_tag purc_u_tag cons_q_tag purc_q_tag pr_usd unit_price purc_p_tag cons_usd {
	replace `var'=.z  if cons>=.
}
drop _merge cons_original 
label var cons_q_kg "Consumption in Kg"
label var purc_q_kg "Purchase in Kg"
label var pr_usd "Current price in USD"
label var unit_price "Current price per Kg in USD"
label var cons_same_figures_tag "Entry w/same figure in quantity consumed, purchased and price"
label var purc_same_figures_tag "Entry w/same figure for quantity purchased and price"
label var different_u_tag "Entry w/same figure in quantity consumed & purchased, yet different units"
label var cons_u_tag "Entry flagged: issues w/units in consumption"
label var purc_u_tag "Entry flagged: issues w/units in purchase"
label var cons_q_tag "Entry flagged: issues w/quantity in consumption"
label var purc_q_tag "Entry flagged: issues w/quantity in purchase"
label var purc_p_tag "Entry flagged: issues w/prices"
*Include the key variables for all the records
drop region weight enum mod_opt mod_item
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", assert(match) nogen keepusing(region weight enum mod_opt)
merge m:m foodid using "${gsdData}/1-CleanInput/food.dta", nogen keep(master match) keepusing(mod_item)
rename foodid itemid
order region strata ea block hh enum weight mod_opt mod_item
save "${gsdData}/1-CleanTemp/food.dta", replace
*Now the data is collapsed at the household level and converted into wide format 
use "${gsdData}/1-CleanTemp/food.dta", clear
collapse (sum) cons_usd, by(strata ea block hh mod_opt mod_item)
reshape wide cons_usd, i(strata ea block hh mod_opt) j(mod_item)
ren cons_usd* cons_f* 
*Then we includes zero values for optional modules without consumption and correct naming of missing values
forval i=1/4 {
	replace cons_f`i' = 0 if cons_f`i'>=. & mod_opt==`i'
	label var cons_f`i' "Food consumption in current USD (Mod: `i'): 7d"
}
replace cons_f0=0 if cons_f0>=.
label var cons_f0 "Food consumption in current USD (Mod: 0): 7d"
forval i=1/4 {
	replace cons_f`i'=.z if mod_opt!=`i'
}
drop mod_opt
save "${gsdData}/1-CleanTemp/hh_fcons.dta", replace
