*This do file performs IDP Assets analysis

***************
*	Assets
***************
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

*******************
*SIGNIFICANCE TESTS
*******************
gen siglabor = national
replace siglabor = urbanrural if national ==1
lab def siglabor 0 "idp" 1 "urban" 2 "rural"
lab val siglabor siglabor
ta siglabor 
ta urbanrural, miss
ta national, miss
gen sighostidp = 1 if comparisoncamp ==1
replace sighostidp = 2 if comparisonhost ==1
lab def sighostidp 1 "camp idp" 2 "host urban"
lab val sighostidp sighostidp

*Own productive assets now
*IDPs and urbanrural
svy: prop own_any_prod, over(siglabor)
*p<0.01
lincom [_prop_2]idp - [_prop_2]urban
lincom [_prop_2]idp - [_prop_2]rural
*Camp IDPs and hosts
svy: prop own_any_prod, over(sighostidp)
*p<0.01
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Camp and Non-camp
svy: prop own_any_prod, over(comparisoncamp)
lincom [_prop_2]Settlement - [_prop_2]_subpop_2
*Conflict and climates
svy: prop own_any_prod, over(reasonidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Man and woman head
svy: prop own_any_prod, over(genidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Protracted and not
svy: prop own_any_prod, over(durationidp)
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*Times disp
svy: prop own_any_prod, over(timesidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*40 60 
svy: prop own_any_prod, over(topbottomidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Poor
svy: prop own_any_prod, over(poor)
lincom [_prop_2]Poor - [_prop_2]_subpop_2

*Owned productive assets before -- IDPs only
*Camp and Non-camp
svy: prop own_any_prod_prev, over(comparisoncamp)
lincom [_prop_2]Settlement - [_prop_2]_subpop_2
*Conflict and climates
svy: prop own_any_prod_prev, over(reasonidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Man and woman head
svy: prop own_any_prod_prev, over(genidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Protracted and not
svy: prop own_any_prod_prev, over(durationidp)
*p<0.1
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*Times disp
svy: prop own_any_prod_prev, over(timesidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*40 60 
svy: prop own_any_prod_prev, over(topbottomidp)
*p<0.1
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Poor
svy: prop own_any_prod_prev, over(poor)
lincom [_prop_2]Poor - [_prop_2]_subpop_2

*Owned any assets -- now and before displacement
qui tabout own_any_prod national using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) replace h1("ProdAssets") f(4) 
qui tabout own_any_prod comparisonhost using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("ProdAssets") f(4) 
qui tabout own_any_prod urbanrural using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("ProdAssets") f(4) 
qui tabout own_any_prod comparisoncamp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("ProdAssets") f(4) 
qui tabout own_any_prod reasonidp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("ProdAssets") f(4) 
qui tabout own_any_prod genidp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("ProdAssets") f(4) 
qui tabout own_any_prod durationidp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("ProdAssets") f(4) 
qui tabout own_any_prod timesidp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("ProdAssets") f(4) 
qui tabout own_any_prod topbottomidp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("ProdAssets") f(4) 
qui tabout own_any_prod poor using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("ProdAssets") f(4) 

qui tabout own_any_prod_prev national using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("Prev_ProdAssets") f(4) 
*qui tabout own_any_prod_prev comparisonhost using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("Prev_ProdAssets") f(4) 
*qui tabout own_any_prod_prev urbanrural using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("Prev_ProdAssets") f(4) 
qui tabout own_any_prod_prev comparisoncamp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("Prev_ProdAssets") f(4) 
qui tabout own_any_prod_prev reasonidp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("Prev_ProdAssets") f(4) 
qui tabout own_any_prod_prev genidp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("Prev_ProdAssets") f(4) 
qui tabout own_any_prod_prev durationidp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("Prev_ProdAssets") f(4) 
qui tabout own_any_prod_prev timesidp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("Prev_ProdAssets") f(4) 
qui tabout own_any_prod_prev topbottomidp using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("Prev_ProdAssets") f(4) 
qui tabout own_any_prod_prev poor using "${gsdOutput}/Raw_Fig90.xls", svy percent c(col lb ub) npos(col) append h1("Prev_ProdAssets") f(4) 

*Tabout assets ownership by livelihood type -- For IDPs only
qui tabout own_any_prod lhood using "${gsdOutput}/Raw_Fig91.xls" if !missing(comparisoncamp), svy percent c(col lb ub) npos(col) replace h1("AssetLivelihood") f(4) 
qui tabout own_any_prod_prev lhood_prev using "${gsdOutput}/Raw_Fig91.xls" if !missing(comparisoncamp), svy percent c(col lb ub) npos(col) append h1("Pre_AssetLivelihood") f(4) 

*Place raw data into the excel figures file
foreach i of num 90 91 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}

/*
**********************************************************
*Agricultural land
**********************************************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
keep if t ==1
*Access to agricultural land, now and before December 2013
qui tabout land_access_yn comparisonoverall using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) replace h1("AgriLand") f(4) 
qui tabout land_access_yn comparisonw4 using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("AgriLand") f(4) 
qui tabout land_access_yn comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("AgriLand") f(4) 
qui tabout land_access_yn hhh_gender using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("AgriLand") f(4) 
qui tabout land_access_yn comparisoncamp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("AgriLand") f(4) 
qui tabout land_access_yn quintiles_idp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("AgriLand") f(4) 

qui tabout land_access_yn_disp comparisonoverall using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("PrevAgriLand") f(4) 
qui tabout land_access_yn_disp comparisonw4 using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("PrevAgriLand") f(4) 
qui tabout land_access_yn_disp comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("PrevAgriLand") f(4) 
qui tabout land_access_yn_disp hhh_gender using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("PrevAgriLand") f(4) 
qui tabout land_access_yn_disp comparisoncamp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("PrevAgriLand") f(4) 
qui tabout land_access_yn_disp quintiles_idp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("PrevAgriLand") f(4) 

*Significance tests
svy: mean land, over(uisig)
*Camp IDPs have about half the agri land than urban.
*p<0.01
lincom [land]Camp - [land]Urban
*not sig
lincom [land]Noncamp - [land]Urban
*p<0.01
lincom [land]Camp - [land]Noncamp

svy: mean land_disp, over(uisig)
*Camp IDPs had less land than urban before Dec 2013 too.
*p<0.01
lincom [land_disp]Camp - [land_disp]Urban
*not sig
lincom [land_disp]Noncamp - [land_disp]Urban
*p<0.01
lincom [land_disp]Camp - [land_disp]Noncamp

*Units of agri land, now and before December 2013
*Acres of land owned now
qui tabout comparisonoverall using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land lb ub se) npos(col) append h2("landacres") f(4) 
qui tabout comparisonw4 using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land lb ub se) npos(col) append h2("landacres") f(4) 
qui tabout comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land lb ub se) npos(col) append h2("landacres") f(4) 
qui tabout hhh_gender using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land lb ub se) npos(col) append h2("landacres") f(4) 
qui tabout comparisoncamp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land lb ub se) npos(col) append h2("landacres") f(4) 
qui tabout quintiles_idp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land lb ub se) npos(col) append h2("landacres") f(4) 

*Acres of land owned Pre Dec 13
qui tabout comparisonoverall using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land_disp lb ub se) npos(col) append h2("Pre_landacres") f(4) 
qui tabout comparisonw4 using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land_disp lb ub se) npos(col) append h2("Pre_landacres") f(4) 
qui tabout comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land_disp lb ub se) npos(col) append h2("Pre_landacres") f(4) 
qui tabout hhh_gender using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land_disp lb ub se) npos(col) append h2("Pre_landacres") f(4) 
qui tabout comparisoncamp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land_disp lb ub se) npos(col) append h2("Pre_landacres") f(4) 
qui tabout quintiles_idp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean land_disp lb ub se) npos(col) append h2("Pre_landacres") f(4) 

*Place raw data into the excel figures file
foreach i of num  30/34 46 47 48 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
