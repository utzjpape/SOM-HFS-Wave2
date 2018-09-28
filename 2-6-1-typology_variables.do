*Prepare the variables to be used in the typology of IDP

set more off
set seed 23081980 
set sortseed 11041955

*Load data
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
*Keep only IDPs
keep if national ==0

*******************************
*Prepare Needs-based variables
*******************************
*Likelihood of being poor
confirm existence poorPPP_prob
confirm existence poor
lab var poor "Poor" 

*Household size (maximum hhs have 5 members)
gen hhsize5 = hhsize >=5 if !missing(hhsize)
lab def hhsize5 0 "4 or less members" 1 "5 or more members"
lab val hhsize5 hhsize5
lab var hhsize5 "Household has more than 4 members"

*Improved housing
*Now
*Recode for improved housing
gen housingimproved=inlist(housingtype,1,2,3,4)  if !missing(housingtype)
label var housingimproved "Improved housing"
label def housingimproved 0 "Unimproved house" 1 "Improved house"
label val housingimproved housingimproved

*Improved water
gen waterimproved =  .
replace waterimproved = 0 if inlist(drink_water, 4,8,10,11,12,13)
replace waterimproved = 1 if inlist(drink_water,1,2,3,5,6,7,9)
label define lwatersourcecat 0 "Unimproved" 1 "Improved" 
label values waterimproved lwatersourcecat
label var waterimproved "Improved water" 
fre waterimproved

*Improved sanitation, accounting for sharing toilets
gen sanitationimproved = . 
replace sanitationimproved = 0 if inlist(toilet, 4,8,10,11,12)
replace sanitationimproved = 1 if inlist(toilet, 1,2,3,5,6,7,9)
label values sanitationimproved lwatersourcecat
codebook share_facility
ta sanitationimproved
codebook sanitationimproved
gen sanimproved_shared = sanitationimproved
replace sanimproved_shared=0 if share_facility==1
label var sanimproved_shared "Improved sanitation"
la val sanimproved_shared lwatersourcecat
fre sanimproved_shared	

*Hunger
gen hunger_dum=(hunger>1) if !missing(hunger)
label def hungerdum 1 "Hungry" 0 "Not hungry"
label val hunger_dum hungerdum
lab var hunger_dum "Hunger in last 4 weeks"
fre hunger_dum

*Livelihood
*Now
recode lhood (1=1 "Salaried labor") (2 5 = 2 "Remittances") (7=4 "Family business") (8=5 "Agriculture") (9 10 12 = 6 "Trade, property income") (11 13 = 7 "Aid or zakat")  (3 4 6 = 9 "Other") (nonmiss = 9 "Other"), gen(livelihood)
lab var livelihood "Main livelihood"
*Livelihood alternative 1: dummy for agri non-agri livelihood
gen ldum = (livelihood ==5) if !missing(livelihood)
lab def ldum 0 "Non-agri" 1 "Agri" 
lab val ldum ldum 
*Livelihood alternative 2: dummy for each value
tab livelihood, gen(ldum_)

*Receives aid in any form
gen assist_source_any = inlist(assist__1, 1) | inlist(assist__2, 1) | inlist(assist__3, 1)
fre assist_source_any

*Access to agriclutural land
*Now
fre land_access_yn
lab def land_access 1 "Land" 0 "No land"
lab val land_access_yn land_access
fre land_access_yn
lab var land_access_yn "Agricultural land access"

*Own productive assets (ASSET OWNERSHIP IS NEGLIGIBLE PRE DISP AND NOW -- CONSIDER DROPPING)
*Save before opening assets dataset
save "${gsdTemp}/typologyprepare1.dta", replace
use "${gsdData}/1-CleanOutput/assets_prev.dta", clear
rename own own_prev
rename assetid itemid
save "${gsdTemp}/assets_prev_idp.dta", replace
use "${gsdData}/1-CleanOutput/assets.dta", clear
*add pre-displacement assets
merge 1:1 strata ea block hh itemid using "${gsdTemp}/assets_prev_idp.dta",  keepusing(own_prev)
ta _merge
*there are asset items for which hhs  don't match. this is less than 1 percent of the overall sample.
*merge in the comparison groups
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", nogen keepusing(lhood lhood_prev weight_adj hhsize hhh_gender hhh_edu  hhh_lit urbanruraltype durationidp comparisoncamp comparisonhost comparisonw1 poor sigrural sighost siggen sigcamp sigdur sigreason sigtb sigtime sigidp sighh sigdt comparisonidp urbanrural genidp quintileidp migr_idp reasonidp timesidp topbottomidp national)
*confirm with G that this is the right weight
svyset ea [pweight=weight], strata(strata) singleunit(centered)
/* Productive assets are
15 - sewing machine
16- refrigeratore
30 - computer equipment
33 - generator
34 - motorcycle/scooter
35- car
36- minibus
37 - lorry */
*Identify ownership of any productive asset
gen productiveasset = 1 if own == 1 & inlist(itemid,15,16,30,33,34,35,36,37)
order productiveasset, after(itemid)
*Expand to all obs for the hh
bysort strata ea block hh: egen own_any_prod = max(productiveasset)
order own_any_prod, after(productiveasset)
replace own_any_prod = 0 if missing(own_any_prod)
*How many productive assets does the household own
bysort strata ea block hh: egen own_prod_sum = sum(productiveasset)
replace own_prod_sum = 0 if missing(own_prod_sum)
order own_prod_sum , after(own_any_prod)
svy: mean own_any_prod
*Same for previous ownership
*Create a varaible for ownership of any productive asset: Productive assets are Cars (1), Trucks (2), Motorcycle (3), Rickshaw (4), Bicycle (5),  Boat (6),  Plough (7),  Computer (13), Refrigerator (14) -- NOT SURE IF THAT IS PRODUCTIVE,  Hoe spade or axe (21)
gen productiveasset_prev = 1 if own_prev == 1 & inlist(itemid,15,16,30,33,34,35,36,37)
order productiveasset_prev, after(productiveasset)
*Expand to all obs for the hh
bysort strata ea block hh: egen own_any_prod_prev = max(productiveasset_prev)
order own_any_prod_prev, after(productiveasset_prev)
replace own_any_prod_prev = 0 if missing(own_any_prod_prev)
*How many productive assets did the household own
bysort strata ea block hh: egen own_prod_prev_sum = sum(productiveasset_prev)
replace own_prod_prev_sum = 0 if missing(own_prod_prev_sum)
order own_prod_prev_sum , after(own_any_prod_prev)
*Bring data to HH level
collapse own_any_prod own_any_prod_prev own_prod_sum own_prod_prev_sum, by(weight_adj strata ea block hh weight hhsize lhood lhood_prev urbanruraltype durationidp comparisoncamp comparisonhost comparisonw1 poor sigrural sighost siggen sigcamp sigdur sigreason sigtb sigtime sigidp sighh sigdt comparisonidp urbanrural genidp quintileidp migr_idp reasonidp timesidp topbottomidp national )
*Aroob's used hhm level weights but i think hhq is more fitting for this code.
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
*Label key vars
label values own_any_prod lyn
label values own_any_prod_prev lyn
label var own_any_prod "Owned any productive asset"
label var own_any_prod_prev "Owned any productive asset before displacement"
label var own_prod_sum "Sum of assets owned"
label var own_prod_prev_sum "Sum of assets owned before displacement"
save "${gsdTemp}/assets_typology_ready", replace
*Merge this into the main dataset
use "${gsdTemp}/typologyprepare1.dta", clear
merge 1:1 strata ea block hh using "${gsdTemp}/assets_typology_ready.dta", keepusing(own_any_prod own_any_prod_prev) keep(match master) nogen
lab var own_any_prod "Own productive assets"
lab var own_any_prod_prev "Owned productive assets"

*Livestock
*Save before opening livestock dataset
save "${gsdTemp}/typologyprepare2.dta", replace 
*Load livestock roster
use "${gsdData}/1-CleanOutput/livestock_pre.dta", clear
rename own own_pre_yn
rename own_pre own_pre_n
save "${gsdTemp}/livestock_prev_idp.dta", replace
use "${gsdData}/1-CleanOutput/livestock.dta", clear
*rename key variables
rename own own_yn
*add pre-displacement livestock
merge 1:1 strata ea block hh livestockid using "${gsdTemp}/livestock_prev_idp.dta",  keepusing(own_pre_yn own_pre_n)
ta _merge
*Some 800 obs from using only - check with G.
*add comparison groups
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", nogen keepusing(lhood lhood_prev weight_adj hhsize hhh_gender hhh_edu  hhh_lit urbanruraltype durationidp comparisoncamp comparisonhost comparisonw1 poor sigrural sighost siggen sigcamp sigdur sigreason sigtb sigtime sigidp sighh sigdt comparisonidp urbanrural genidp quintileidp migr_idp reasonidp timesidp topbottomidp national)
svyset ea [pweight=weight], strata(strata) singleunit(centered)
***Calculating Livestock Units reference:http://www.lrrd.org/lrrd18/8/chil18117.htm
foreach var of varlist own_n own_pre_n {
	*Set to 0 if n is missing (missing = not owned)
	gen `var'_LU = 0 if missing(`var')
	*Cattle: 0.7
	replace `var'_LU = 0.7*`var' if livestockid == 1
	*Horses: 0.4
	replace `var'_LU = 0.4*`var' if livestockid == 7
	*Donkey/mule: 0.5
	replace `var'_LU = 0.5*`var' if livestockid == 6
	*Sheep: 0.1; Goats: 0.1
	replace `var'_LU = 0.1*`var' if inlist(livestockid, 2,3)
	*Poultry: 0.01
	replace `var'_LU = 0.01*`var' if livestockid == 5
	*Camels
	replace `var'_LU = 0.75*`var' if livestockid == 4
	bysort strata ea block hh: egen `var'_LU_sum = total(`var'_LU)
}
*Does the household own any livestock (expand to all obs for an hh)
gen livestockowned = 1 if own_yn == 1 
bysort strata ea block hh: egen own_livestock = max(livestockowned)
replace own_livestock = 0 if missing(own_livestock)
*Same for pre displacement
gen livestockownedpre = 1 if own_pre_yn == 1 
bysort strata ea block hh: egen own_livestock_pre = max(livestockownedpre)
replace own_livestock_pre = 0 if missing(own_livestock_pre)
drop livestockowned livestockownedpre
*Bring data to HH level
count
collapse own_livestock own_livestock_pre own_n_LU_sum own_pre_n_LU_sum, by(strata ea block hh weight_adj hhsize lhood lhood_prev urbanruraltype durationidp comparisoncamp comparisonhost comparisonw1 poor sigrural sighost siggen sigcamp sigdur sigreason sigtb sigtime sigidp sighh sigdt comparisonidp urbanrural genidp quintileidp migr_idp reasonidp timesidp topbottomidp national )
*Keep only IDPs
keep if national==0
*Aroob's used hhm level weights but i think hhq is more fitting for this code.
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
*Label key vars
label values own_livestock lyn
label values own_livestock_pre lyn
label var own_livestock "Owned any livestock"
label var own_livestock_pre "Owned any livestock before December 2013"
rename (own_n_LU_sum own_pre_n_LU_sum) (livestockunits livestockunits_pre)
label var livestockunits "Total units of livestock owned by household"
label var livestockunits_pre "Total units of livestock owned by household before displacement"
save "${gsdTemp}/livestock_typology_ready", replace
*Merge this into the main dataset
use "${gsdTemp}/typologyprepare2.dta", clear
merge 1:1 strata ea block hh using "${gsdTemp}/livestock_typology_ready.dta", keepusing(livestockunits livestockunits_pre) keep(match master) nogen
*Categorize into dummies: own and don't own livestock
*Now
gen livestockown = livestockunits >0 & !missing(livestockunits)
lab def livestockown 0 "No livestock" 1 "Livestock"
lab val livestockown livestockown
lab var livestockown "Own livestock"
*Education level of hh head
confirm existence hhh_edu
lab var hhh_edu "HH head education level" 
*Less than 30 mins from various services
recode water_time thealth tedu tmarket t_water_disp thealth_disp t_edu_disp t_market_disp (1 2 3 =1 "Up to 30 minutes") (4 5 6 7 8 9 =0 "30 minutes or more"), pre(dt_) lab(dumtimelab)
lab def lnearfar 0 "Far" 1 "Near"
lab val dt_* lnearfar

lab var dt_tmarket "Closest market"
lab var dt_t_market_disp "Closest market, before disp"
lab var dt_tedu "Closest school"
lab var dt_t_edu_disp "Closest school, before disp"
lab var dt_thealth "Closest health facility"
lab var dt_thealth_disp "Closest health facility, before disp"

corr dt_water_time dt_tmarket dt_tedu dt_thealth
alpha dt_water_time dt_tmarket dt_tedu dt_thealth, gen(dist)
recode dist (0/0.5 = 0 "Far") (0.51/1 = 1 "Near"), gen(distance)
lab var distance "Near (30 mins or less) from facilities on average"
fre distance
fre dist

corr dt_t_water_disp dt_t_market_disp dt_t_edu_disp dt_thealth_disp
alpha dt_t_water_disp dt_t_market_disp dt_t_edu_disp dt_thealth_disp, gen(dist_pre)
fre dist_pre
recode dist_pre (0/0.5 = 0 "Far") (0.51/1 = 1 "Near"), gen(distance_pre)
fre distance_pre
lab var distance_pre "Near (30 mins or less) from facilities on average"

*Dependency ratios of the household: below or above 1
gen dependency_dum = age_dependency_ratio >=1 if !missing(age_dependency_ratio)
lab def dependency_dum 0 "Depratio below 1" 1 "Depratio 1 or more"
lab val dependency_dum dependency_dum
lab var dependency_dum "Dependency ratio" 

*Gender of HouseholdHead
confirm existence hhh_gender
lab var hhh_gender "HH head gender"

*Safety to move
lab def move_free 0 "Not safe to move around" 1 "Safe to move around", modify
fre move_free
lab var move_free "Freedom of movement around camp"

*******************************
*Prepare Cause-based variables
*******************************
*State -- not really covered much in Somalia due to the location pre-drought and post-drought discussion.
*(consider)

*How far were you displaced
rename disp_from_new origin_now
fre origin_now
lab var origin_now "Relative location: origin and now"

*Nonphysical harm during conflict
foreach v in conf_nonphys_harm__1 conf_nonphys_harm__2 conf_nonphys_harm__3 conf_nonphys_harm__4 conf_nonphys_harm__5 {
	recode `v' (0=0 "Not harmed") (1=1 "Harmed"), gen(`v'_f)
	fre `v'_f
}
lab var conf_nonphys_harm__1_f "Insult"
lab var conf_nonphys_harm__2_f  "Threat"
lab var conf_nonphys_harm__3_f "Weapon threat"
lab var conf_nonphys_harm__4_f "Sexual harrassment"
lab var conf_nonphys_harm__5_f "Discriminated"

alpha conf_nonphys_harm__1_f conf_nonphys_harm__2_f conf_nonphys_harm__3_f conf_nonphys_harm__4_f conf_nonphys_harm__5_f, gen(harm)
fre harm
recode harm (0=0 "No harm") (0.25=1 "Low harm") (0.5=2 "Some harm") (0.75 = 3 "Substantial harm") (1=4 "Most harm"), gen(harm_f)

gen harm_dum = . 
lab def harm_dum 0 "No/low harm" 1 "High harm"
replace harm_dum = 0 if harm_f == 0 | harm_f ==1
replace harm_dum = 1 if harm_f == 2 | harm_f ==3 | harm_f ==4
lab val harm_dum harm_dum
fre harm_dum

*Reason for leaving
fre  disp_reason_concise

*Reason for arriving
fre disp_arrive_reason
label define disp_arrive_reason 2 "Water access for livestock" 3 "Home / land access" 4 "Education / health access" 5 "Employment opportunities" 6 "Join family or known people" 7 "Knew people settled here" 8 "Humanitarian access (food and water)" 1000 "Other" , modify
fre disp_arrive_reason
recode disp_arrive_reason (6 7 = 6) (1000=.)
fre disp_arrive_reason

*Livestock before displacement 
gen livestockown_pre = livestockunits_pre >0 & !missing(livestockunits_pre)
lab def livestockown_pre 0 "No livestock before" 1 "Livestock before"
lab val livestockown_pre livestockown_pre
lab var livestockown_pre "Owned livestock"

*Livelihood before conflict
fre lhood_prev
gen livelihood_pre = lhood_prev 
replace livelihood_pre = lhood if lhood_prev ==0
recode livelihood_pre (1=1 "Salaried labor") (2 5 = 2 "Remittances") (7=4 "Family business") (8=5 "Agriculture") (9 10 12 = 6 "Trade, property income") (11 13 = 7 "Aid or zakat")  (3 4 6 = 9 "Other") (nonmiss = 9 "Other"), gen(livelihood_prev)
fre lhood_prev
fre livelihood_prev

*Productive asset ownership before displacement(VERY LOW, CONSIDER DROPPING)
fre own_any_prod_prev

*Land ownership before displacement
*Pre disp
fre land_access_yn_disp
lab def land_access_disp 1 "Land before" 0 "No land before"
lab val land_access_yn_disp land_access_disp
fre land_access_yn_disp
lab var land_access_yn_disp "Access to agricultural land pre-disp"
*Improved housing before displacement
*Pre disp
gen housingimproveddisp = inlist(housingtype_disp,1,2,3,4) if !missing(housingtype_disp)
label var housingimproveddisp "Household lives in improved housing pre displacement"
label var housingimproveddisp "Improved housing pre-displacement"
label def housingimproveddisp 0 "Unimproved house disp" 1 "Improved house disp"
label val housingimproveddisp housingimproveddisp

*********************************
*Prepare Solution-based variables
*********************************
*Return intention
*Recode variables for better graphs
gen newmove_want = move_want_yn
replace newmove_want = move_want if move_want_yn ==1
tab newmove_want
label def lnewmove_want 0 "Don't want to move" 1 "Original place of residence" 2 "New area"
label values newmove_want lnewmove_want

*Move when
fre move_want_time
gen movetime =.
replace movetime = 0 if newmove_want ==0
replace movetime = move_want_time if !missing(move_want_time)
lab def movetime 0 "Stay" 1 "6 months" 2 "6-12 months" 3 ">=12 months" 4 "Don't know when"
lab val movetime movetime
fre movetime
lab var movetime "Time of moving"

*Stayers -- push factors -- ranked multiselect
*Move_no_push
gen newmove_no_push__1 = move_no_push__1 == 1
label var newmove_no_push__1 "J.50: Better security"
ta newmove_no_push__1
ta move_no_push__1
gen newmove_no_push__2 = (move_no_push__2 ==1 | move_no_push__5 == 1)
replace newmove_no_push__2 = . if missing(move_no_push__2) & missing(move_no_push__5)
label var newmove_no_push__2 "J.50: Home, land, livestock, employment"
gen newmove_no_push__3 = ( move_no_push__3 ==1 | move_no_push__7 ==1)
replace newmove_no_push__3 = . if missing(move_no_push__3) & missing(move_no_push__7)
label var newmove_no_push__3 "J.50: Health, education, humanitarian aid"
gen newmove_no_push__4 = ( move_no_push__6== 1)
label var newmove_no_push__4 "J.50: Family"

*Move pull-- ranked multiselect
*Move_yes_pull
gen newmove_yes_pull__1 = ( move_yes_pull__1 ==1 )
label var newmove_yes_pull__1 "J.56: Better security"
gen newmove_yes_pull__2 = ( move_yes_pull__2 ==1 |  move_yes_pull__3 ==1 | move_yes_pull__5 ==1 )
replace newmove_yes_pull__2 = . if missing(move_yes_pull__2) & missing(move_yes_pull__3) & missing(move_yes_pull__5)
label var newmove_yes_pull__2 "J.56: Home, land, livestock, employment"
gen newmove_yes_pull__3 = ( move_yes_pull__4 ==1 |  move_yes_pull__7 ==1 )
replace newmove_yes_pull__3 = . if missing(move_yes_pull__4) & missing(move_yes_pull__7)
label var newmove_yes_pull__3 "J.56: Health, education, humanitarian aid"
gen newmove_yes_pull__4 = ( move_yes_pull__6 ==1 )
label var newmove_yes_pull__4 "J.56: Family"

*One variable for push-stay and pull-move. i.e. positive motivators.
*(Must have one variable for those who want to stay and move. Having separate variables for movers and stayers will make the MCA impossible as they're mutually exclusive groups.
label define pullpush 1 "Move, security" 2 "Move, home/land" 3 " Move, services/aid" 4 "Move, family" ///
5 "Stay, security" 6 "Stay, home/land" 7 " Stay, services/aid" 8 "Stay, family"  
gen pullpush = . 
replace pullpush = 1 if newmove_yes_pull__1 ==1
replace pullpush = 2 if newmove_yes_pull__2 ==1
replace pullpush = 3 if newmove_yes_pull__3 ==1
replace pullpush = 4 if newmove_yes_pull__4 ==1
replace pullpush = 5 if newmove_no_push__1 ==1
replace pullpush = 6 if newmove_no_push__2 ==1
replace pullpush = 7 if newmove_no_push__3 ==1
replace pullpush = 8 if newmove_no_push__4 ==1
label values pullpush pullpush
fre pullpush
recode pullpush (1=1 "Move, security") (2=2 "Move, home/land") (3 4 = 3 "Move, other") (5 = 4 "Stay, security") (6 = 5 "Stay, home/land") (7 8 =6 "Stay, services/family"), gen(pullpush_final)
fre pullpush_final
lab var pullpush_final "Pull and push factors for return"
*Further recoding.
recode pullpush_final (1 4 = 1 "Security") (2 3 5 6 =2 "Non-security") , gen(pullpush_security)
lab var pullpush_security "Pull and push factors: security or others"
fre pullpush_security

*Information needed to settle.
gen information_want = .
label define information_want 0 "Have all info" 1 "Political and security" 2 "Basic services" 3 "Work, land, property, docs" 4 "Transport" 5 "Return to camp" 6 "Aid" 7 "Climate"
replace information_want = 0 if inf_comp ==1
replace information_want = 1 if (inf_want__1 ==1 | inf_want__2 ==1 | inf_want__3 ==1)
replace information_want = 2 if (inf_want__4 ==1 | inf_want__5 ==1) 
replace information_want = 3 if (inf_want__6 == 1 | inf_want__7 ==1 | inf_want__11 ==1) 
replace information_want = 4 if inf_want__8 ==1
replace information_want = 5 if inf_want__9 ==1
replace information_want = 6 if inf_want__10 == 1
replace information_want = 7 if inf_want__12==1
label values information_want information_want
fre information_want
recode information_want (0=0 "Have all info") (1=1 "Security and political info") (2 3 4 5 6 =2 "Other info"), gen(information_final)
lab var information_final "Information needed to decide where to settle" 

*Help needed in moving
gen movehelp = . 
foreach i of num 1/17 {
	replace movehelp = `i' if move_help__`i' == 1
}
fre movehelp
recode movehelp (1 2=1 "Security") (3 4 = 2 "Housing") (5 6 7 8 9 10 = 3 "Livelihood") (11 12 13 14 17 = 4 "Services") (15 16 = 5 "Transport and regrouping"), gen(movehelp_final)
lab var movehelp_final "Help needed to settle" 
fre movehelp_final

*WHY ARE 221 missing?

*********************************
*Save dataset
*********************************
save "${gsdData}/1-CleanTemp/typologyvariables.dta", replace
