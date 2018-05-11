*This do file performs IDP health analysis

************************
*HHM indicators
************************
use "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
keep if t ==1

*Recode health variables to show worse at bottom
recode delivery (1=3 "Hospital") (2 3 =2 "Maternity clinic/ MCH") (4=1 "At home") (1000=1000 "Other"), gen(delivery_new)
recode deliveryassist (1 2 =3 "Nurse / Midwife / Doctor") (4 =2 "Traditional attendant") (5=1 "Relative/friend") (nonmissing=.), gen(deliveryassist_new)

************************
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

*Likelihood of delivering a child at home. 
*IDPs and urbanrural
svy: prop delivery_new, over(siglabor)
*p<0.01
lincom [_prop_1]idp - [_prop_1]urban
*p<0.01
lincom [_prop_1]idp - [_prop_1]rural
*IDPs and hosts
svy: prop delivery_new, over(sighostidp)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Camp and Non-camp
svy: prop delivery_new, over(comparisoncamp)
*p<0.05
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Conflict and climates
svy: prop delivery_new, over(reasonidp)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Man and woman head
svy: prop delivery_new, over(genidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Protracted and not
svy: prop delivery_new, over(durationidp)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]Protracted
*Times disp
svy: prop delivery_new, over(timesidp)
*0.1
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*40 60 
svy: prop delivery_new, over(topbottomidp)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Poor
svy: prop delivery_new, over(poor)
*p<0.05
lincom [_prop_1]Poor - [_prop_1]_subpop_2

*Delivery assist
*Likelihood of having a nurse, midwife or doc deliver
svy: prop deliveryassist_new, over(siglabor)
*p<0.01
lincom [_prop_3]idp - [_prop_3]urban
*p<0.01
lincom [_prop_3]idp - [_prop_3]rural
*IDPs and hosts
svy: prop deliveryassist_new, over(sighostidp)
*p<0.01
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Camp and Non-camp
svy: prop deliveryassist_new, over(comparisoncamp)
*p<0.01
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Conflict and climates
svy: prop deliveryassist_new, over(reasonidp)
*p<0.01
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Man and woman head
svy: prop deliveryassist_new, over(genidp)
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Protracted and not
svy: prop deliveryassist_new, over(durationidp)
*p<0.01
lincom [_prop_3]_subpop_1 - [_prop_3]Protracted
*Times disp
svy: prop deliveryassist_new, over(timesidp)
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*40 60 
svy: prop deliveryassist_new, over(topbottomidp)
*p<0.05
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Poor
svy: prop deliveryassist_new, over(poor)
lincom [_prop_3]Poor - [_prop_3]_subpop_2

************************
*TABOUTS
************************
qui tabout delivery_new national using "${gsdOutput}/Raw_Fig26.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("Delivery")
qui tabout delivery_new comparisonhost using "${gsdOutput}/Raw_Fig26.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Delivery")
qui tabout delivery_new urbanrural using "${gsdOutput}/Raw_Fig26.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Delivery")
qui tabout delivery_new comparisoncamp using "${gsdOutput}/Raw_Fig26.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Delivery")
qui tabout delivery_new reasonidp using "${gsdOutput}/Raw_Fig26.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Delivery")
qui tabout delivery_new genidp using "${gsdOutput}/Raw_Fig26.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Delivery")
qui tabout delivery_new durationidp using "${gsdOutput}/Raw_Fig26.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Delivery")
qui tabout delivery_new timesidp using "${gsdOutput}/Raw_Fig26.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Delivery")
qui tabout delivery_new topbottomidp using "${gsdOutput}/Raw_Fig26.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Delivery")
qui tabout delivery_new poor using "${gsdOutput}/Raw_Fig26.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Delivery")

qui tabout deliveryassist_new national using "${gsdOutput}/Raw_Fig27.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("Assist")
qui tabout deliveryassist_new comparisonhost using "${gsdOutput}/Raw_Fig27.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Assist")
qui tabout deliveryassist_new urbanrural using "${gsdOutput}/Raw_Fig27.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Assist")
qui tabout deliveryassist_new comparisoncamp using "${gsdOutput}/Raw_Fig27.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Assist")
qui tabout deliveryassist_new reasonidp using "${gsdOutput}/Raw_Fig27.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Assist")
qui tabout deliveryassist_new genidp using "${gsdOutput}/Raw_Fig27.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Assist")
qui tabout deliveryassist_new durationidp using "${gsdOutput}/Raw_Fig27.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Assist")
qui tabout deliveryassist_new timesidp using "${gsdOutput}/Raw_Fig27.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Assist")
qui tabout deliveryassist_new topbottomidp using "${gsdOutput}/Raw_Fig27.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Assist")
qui tabout deliveryassist_new poor using "${gsdOutput}/Raw_Fig27.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Assist")

*Place raw data into the excel figures file
foreach i of num 26 27 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
