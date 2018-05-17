*This do file performs IDP mobile network analysis

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
keep if t ==1

*Do households have electricity to Raw_Fig61 phones? 
gen phone_charge = electricity_phone
replace phone_charge = 0 if electricity ==0
ta phone_charge
lab def phone_charge 0 "No" 1 "Yes" 
lab val phone_charge phone_charge

*How close are households from network?
recode phone_network2 (1 2 3 = 1 "Less than 15 mins") (4 5 = 0 "15 mins or more"), gen(network)

**********************
*SIGNIFICANCE TESTS
************************
gen siglabor = national
replace siglabor = urbanrural if national ==1
lab def siglabor 0 "idp" 1 "urban" 2 "rural"
lab val siglabor siglabor
ta siglabor 
ta urbanrural, miss
ta national, miss
gen sighostidp = 1 if national ==0
replace sighostidp = 2 if comparisonhost ==1
lab def sighostidp 1 "idp overall" 2 "host urban"
lab val sighostidp sighostidp

*Having electricity to Raw_Fig61 phones. 
*IDPs and urbanrural
svy: prop phone_charge, over(siglabor)
*p<0.01
lincom [Yes]idp - [Yes]urban
lincom [Yes]idp - [Yes]rural
*IDPs and hosts
svy: prop phone_charge, over(sighostidp)
*p<0.01
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Camp and Non-camp
svy: prop phone_charge, over(comparisoncamp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Conflict and climates
svy: prop phone_charge, over(reasonidp)
*p<0.05
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Man and woman head
svy: prop phone_charge, over(genidp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Protracted and not
svy: prop phone_charge, over(durationidp)
lincom [Yes]_subpop_1 - [Yes]Protracted
*Times disp
svy: prop phone_charge, over(timesidp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*40 60 
svy: prop phone_charge, over(topbottomidp)
*p<0.01
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Poor
svy: prop phone_charge, over(poor)
*p<0.1
lincom [Yes]Poor - [Yes]_subpop_2


*Having network close by (less than 15 mins away)
svy: prop network, over(siglabor)
*p<0.01
lincom [_prop_2]idp - [_prop_2]urban
lincom [_prop_2]idp - [_prop_2]rural
*IDPs and hosts
svy: prop network, over(sighostidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Camp and Non-camp
svy: prop network, over(comparisoncamp)
*p<0.05
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Conflict and climates
svy: prop network, over(reasonidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Man and woman head
svy: prop network, over(genidp)
*p<0.01
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Protracted and not
svy: prop network, over(durationidp)
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*Times disp
svy: prop network, over(timesidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*40 60 
svy: prop network, over(topbottomidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Poor
svy: prop network, over(poor)
*p<0.05
lincom [_prop_2]Poor - [_prop_2]_subpop_2

************************
*TABOUTS
************************
qui tabout phone_charge national using "${gsdOutput}/Raw_Fig60.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("Charge")
qui tabout phone_charge comparisonhost using "${gsdOutput}/Raw_Fig60.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Charge")
qui tabout phone_charge urbanrural using "${gsdOutput}/Raw_Fig60.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Charge")
qui tabout phone_charge comparisoncamp using "${gsdOutput}/Raw_Fig60.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Charge")
qui tabout phone_charge reasonidp using "${gsdOutput}/Raw_Fig60.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Charge")
qui tabout phone_charge genidp using "${gsdOutput}/Raw_Fig60.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Charge")
qui tabout phone_charge durationidp using "${gsdOutput}/Raw_Fig60.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Charge")
qui tabout phone_charge timesidp using "${gsdOutput}/Raw_Fig60.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Charge")
qui tabout phone_charge topbottomidp using "${gsdOutput}/Raw_Fig60.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Charge")
qui tabout phone_charge poor using "${gsdOutput}/Raw_Fig60.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Charge")

qui tabout network national using "${gsdOutput}/Raw_Fig61.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("Network")
qui tabout network comparisonhost using "${gsdOutput}/Raw_Fig61.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Network")
qui tabout network urbanrural using "${gsdOutput}/Raw_Fig61.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Network")
qui tabout network comparisoncamp using "${gsdOutput}/Raw_Fig61.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Network")
qui tabout network reasonidp using "${gsdOutput}/Raw_Fig61.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Network")
qui tabout network genidp using "${gsdOutput}/Raw_Fig61.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Network")
qui tabout network durationidp using "${gsdOutput}/Raw_Fig61.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Network")
qui tabout network timesidp using "${gsdOutput}/Raw_Fig61.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Network")
qui tabout network topbottomidp using "${gsdOutput}/Raw_Fig61.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Network")
qui tabout network poor using "${gsdOutput}/Raw_Fig61.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Network")

*Place raw data into the excel figures file
foreach i of num 60 61 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
