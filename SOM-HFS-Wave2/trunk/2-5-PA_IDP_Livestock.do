*This do file performs IDP Livestock analysis

**********************************************************
*Livestock 
**********************************************************
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
collapse own_livestock own_livestock_pre own_n_LU_sum own_pre_n_LU_sum, by(weight_adj strata ea block hh weight hhsize lhood lhood_prev urbanruraltype durationidp comparisoncamp comparisonhost comparisonw1 poor sigrural sighost siggen sigcamp sigdur sigreason sigtb sigtime sigidp sighh sigdt comparisonidp urbanrural genidp quintileidp migr_idp reasonidp timesidp topbottomidp national )
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

*Livestock units now
*IDPs and urbanrural
svy: mean livestockunits, over(siglabor)
*p<0.01
lincom [livestockunits]idp - [livestockunits]urban
*p<0.05
lincom [livestockunits]idp - [livestockunits]rural
*Camp IDPs and hosts
svy: mean livestockunits, over(sighostidp)
lincom [livestockunits]_subpop_1 - [livestockunits]_subpop_2
*Camp and Non-camp
svy: mean livestockunits, over(comparisoncamp)
*p=0.104
lincom [livestockunits]Settlement - [livestockunits]_subpop_2
*Conflict and climates
svy: mean livestockunits, over(reasonidp)
lincom [livestockunits]_subpop_1 - [livestockunits]_subpop_2
*Man and woman head
svy: mean livestockunits, over(genidp)
*p<0.1
lincom [livestockunits]_subpop_1 - [livestockunits]_subpop_2
*Protracted and not
svy: mean livestockunits, over(durationidp)
lincom [livestockunits]_subpop_1 - [livestockunits]Protracted
*Times disp
svy: mean livestockunits, over(timesidp)
lincom [livestockunits]_subpop_1 - [livestockunits]_subpop_2
*40 60 
svy: mean livestockunits, over(topbottomidp)
*p<0.1
lincom [livestockunits]_subpop_1 - [livestockunits]_subpop_2
*Poor
svy: mean livestockunits, over(poor)
*p<0.05
lincom [livestockunits]Poor - [livestockunits]_subpop_2

*Livestock units before -- IDPs only
*Camp and Non-camp
svy: mean livestockunits_pre, over(comparisoncamp)
*p<0.05
lincom [livestockunits_pre]Settlement - [livestockunits_pre]_subpop_2
*Conflict and climates
svy: mean livestockunits_pre, over(reasonidp)
lincom [livestockunits_pre]_subpop_1 - [livestockunits_pre]_subpop_2
*Man and woman head
svy: mean livestockunits_pre, over(genidp)
*p<0.05
lincom [livestockunits_pre]_subpop_1 - [livestockunits_pre]_subpop_2
*Protracted and not
svy: mean livestockunits_pre, over(durationidp)
*p<0.1
lincom [livestockunits_pre]_subpop_1 - [livestockunits_pre]Protracted
*Times disp
svy: mean livestockunits_pre, over(timesidp)
lincom [livestockunits_pre]_subpop_1 - [livestockunits_pre]_subpop_2
*40 60 
svy: mean livestockunits_pre, over(topbottomidp)
*p<0.1
lincom [livestockunits_pre]_subpop_1 - [livestockunits_pre]_subpop_2
*Poor
svy: mean livestockunits_pre, over(poor)
lincom [livestockunits_pre]Poor - [livestockunits_pre]_subpop_2

*Tabouts
*Livestock Units owned, now and before displacement
qui tabout national using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits lb ub se) npos(col) replace h2("LU") f(4) 
qui tabout comparisonhost using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits lb ub se) npos(col) append h2("LU") f(4) 
qui tabout urbanrural using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits lb ub se) npos(col) append h2("LU") f(4) 
qui tabout comparisoncamp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits lb ub se) npos(col) append h2("LU") f(4) 
qui tabout reasonidp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits lb ub se) npos(col) append h2("LU") f(4) 
qui tabout genidp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits lb ub se) npos(col) append h2("LU") f(4) 
qui tabout durationidp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits lb ub se) npos(col) append h2("LU") f(4) 
qui tabout timesidp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits lb ub se) npos(col) append h2("LU") f(4) 
qui tabout topbottomidp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits lb ub se) npos(col) append h2("LU") f(4) 
qui tabout poor using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits lb ub se) npos(col) append h2("LU") f(4) 

qui tabout national using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits_pre lb ub se) npos(col) append h2("LU_Pre") f(4) 
qui tabout comparisoncamp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits_pre lb ub se) npos(col) append h2("LU_Pre") f(4) 
qui tabout reasonidp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits_pre lb ub se) npos(col) append h2("LU_Pre") f(4) 
qui tabout genidp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits_pre lb ub se) npos(col) append h2("LU_Pre") f(4) 
qui tabout durationidp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits_pre lb ub se) npos(col) append h2("LU_Pre") f(4) 
qui tabout timesidp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits_pre lb ub se) npos(col) append h2("LU_Pre") f(4) 
qui tabout topbottomidp using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits_pre lb ub se) npos(col) append h2("LU_Pre") f(4) 
qui tabout poor using "${gsdOutput}/Raw_Fig92.xls", svy sum c(mean livestockunits_pre lb ub se) npos(col) append h2("LU_Pre") f(4) 

*Tabout livestock ownership by livelihood type -- For  IDPs only
qui tabout lhood using "${gsdOutput}/Raw_Fig93.xls" if !missing(comparisoncamp), svy sum c(mean livestockunits lb ub) npos(col) replace h2("LivestockLivelihood") f(4) 
qui tabout lhood_prev using "${gsdOutput}/Raw_Fig93.xls" if !missing(comparisoncamp), svy sum c(mean livestockunits_pre lb ub) npos(col) append h2("Pre_LivestockLivelihood") f(4) 

*Place raw data into the excel figures file
foreach i of num 92 93 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
