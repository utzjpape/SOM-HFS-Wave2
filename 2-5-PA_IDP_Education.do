*This do file performs IDP Education analysis

************************
*HHM indicators
************************
use "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
keep if t ==1

*Education variables
gen adult_literacy_rate=literacy if age>=15
label values adult_literacy_rate lliteracy
label var adult_literacy_rate "Adult (15+) literacy rate"
gen attainment_primary =(hhm_edu_level>=8) 
replace attainment_primary=. if  hhm_edu_level>=. | age<25
replace attainment_primary=0 if  hhm_edu_level==.z
label values attainment_primary lyesno
label var attainment_primary "Completed primary (aged 25+)"
gen attainment_secondary=(hhm_edu_level>=12) 
replace attainment_secondary=. if  hhm_edu_level>=. | age<25
replace attainment_secondary=0 if  hhm_edu_level==.z
label values attainment_secondary  lyesno
label var attainment_secondary  "Completed secondary (aged 25+)"

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

*****************
*Adult literacy
*****************
*Adult literacy rates, overall, by comparisongroup. 
*IDPs and urbanrural
svy: prop adult_literacy_rate, over(siglabor)
**0.01
lincom [Literate]idp - [Literate]urban
**no sig.
lincom [Literate]idp - [Literate]rural
*IDPs and hosts
svy: prop adult_literacy_rate, over(sighostidp)
**0.01
lincom [Literate]_subpop_1 - [Literate]_subpop_2
*Camp and Non-camp
svy: prop adult_literacy_rate, over(comparisoncamp)
**marginal, p=0.103
lincom [Literate]_subpop_1 - [Literate]_subpop_2
*Conflict and climates
svy: prop adult_literacy_rate, over(reasonidp)
**no sig.
lincom [Literate]_subpop_1 - [Literate]_subpop_2
*Man and woman head
svy: prop adult_literacy_rate, over(genidp)
lincom [Literate]_subpop_1 - [Literate]_subpop_2
*Protracted and not
svy: prop adult_literacy_rate, over(durationidp)
lincom [Literate]_subpop_1 - [Literate]Protracted
*Times disp
svy: prop adult_literacy_rate, over(timesidp)
lincom [Literate]_subpop_1 - [Literate]_subpop_2
*40 60 
svy: prop adult_literacy_rate, over(topbottomidp)
lincom [Literate]_subpop_1 - [Literate]_subpop_2
*Poor
svy: prop adult_literacy_rate, over(poor)
lincom [Literate]Poor - [Literate]_subpop_2

*Adult literacy rates, among genders, within certain groups.
*Overall IDPs
svy: prop adult_literacy_rate if siglabor ==0, over(gender) 
*p<0.01
lincom [Literate]Female - [Literate]Male
*Urban
svy: prop adult_literacy_rate if siglabor ==1, over(gender) 
*p<0.01
lincom [Literate]Female - [Literate]Male
*Rural
svy: prop adult_literacy_rate if siglabor ==2, over(gender) 
*p<0.01
lincom [Literate]Female - [Literate]Male
*Result below: in all the households, men are generally more literate. Not got much to do with the household head's gender.
*IDP Man Head
svy: prop adult_literacy_rate if genidp ==1, over(gender) 
*p<0.01
lincom [Literate]Female - [Literate]Male
*IDP Woman Head
svy: prop adult_literacy_rate if genidp ==0, over(gender) 
*p<0.01
lincom [Literate]Female - [Literate]Male

*****************
*Enrolment
*****************
*School-aged enrolment rates, overall, by comparisongroup. 
*IDPs and urbanrural
svy: prop enrolled, over(siglabor)
**0.01
lincom [_prop_2]idp - [_prop_2]urban
**no sig.
lincom [_prop_2]idp - [_prop_2]rural
*IDPs and hosts
svy: prop enrolled, over(sighostidp)
**0.01
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Camp and Non-camp
svy: prop enrolled, over(comparisoncamp)
**0.1
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Conflict and climates
svy: prop enrolled, over(reasonidp)
**no sig.
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Man and woman head
svy: prop enrolled, over(genidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Protracted and not
svy: prop enrolled, over(durationidp)
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*Times disp
svy: prop enrolled, over(timesidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*40 60 
svy: prop enrolled, over(topbottomidp)
**0.05
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Poor
svy: prop enrolled, over(poor)
lincom [_prop_2]Poor - [_prop_2]_subpop_2

*Enrolment, among genders, within certain groups.
*Overall IDPs
svy: prop enrolled if siglabor ==0, over(gender) 
*no sig
lincom [_prop_2]Female - [_prop_2]Male
*Urban
svy: prop enrolled if siglabor ==1, over(gender) 
lincom [_prop_2]Female - [_prop_2]Male
*Rural
svy: prop enrolled if siglabor ==2, over(gender) 
lincom [_prop_2]Female - [_prop_2]Male
*IDP Man Head
svy: prop enrolled if genidp ==1, over(gender) 
lincom [_prop_2]Female - [_prop_2]Male
*IDP Woman Head
svy: prop enrolled if genidp ==0, over(gender) 
lincom [_prop_2]Female - [_prop_2]Male
*IDP Conflict
svy: prop enrolled if reasonidp ==1, over(gender) 
lincom [_prop_2]Female - [_prop_2]Male
*IDP Climate
svy: prop enrolled if reasonidp ==2, over(gender) 
lincom [_prop_2]Female - [_prop_2]Male
*IDP Poor
svy: prop enrolled if poor ==1, over(gender) 
lincom [_prop_2]Female - [_prop_2]Male
*IDP Bottom 40
svy: prop enrolled if topbottomidp ==1, over(gender) 
lincom [_prop_2]Female - [_prop_2]Male

************************
*TABOUTS
************************
**Literacy
*Overall
qui tabout adult_literacy_rate national using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("AdultLiteracy")
qui tabout adult_literacy_rate comparisonhost using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("AdultLiteracy")
qui tabout adult_literacy_rate urbanrural using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("AdultLiteracy")
qui tabout adult_literacy_rate comparisoncamp using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("AdultLiteracy")
qui tabout adult_literacy_rate reasonidp using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("AdultLiteracy")
qui tabout adult_literacy_rate genidp using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("AdultLiteracy")
qui tabout adult_literacy_rate durationidp using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("AdultLiteracy")
qui tabout adult_literacy_rate timesidp using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("AdultLiteracy")
qui tabout adult_literacy_rate topbottomidp using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("AdultLiteracy")
qui tabout adult_literacy_rate poor using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("AdultLiteracy")

*Men
qui tabout adult_literacy_rate national if gender ==1 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Men")
qui tabout adult_literacy_rate comparisonhost if gender ==1 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Men")
qui tabout adult_literacy_rate urbanrural if gender ==1 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Men")
qui tabout adult_literacy_rate comparisoncamp if gender ==1 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Men")
qui tabout adult_literacy_rate reasonidp if gender ==1 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Men")
qui tabout adult_literacy_rate genidp if gender ==1 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Men")
qui tabout adult_literacy_rate durationidp if gender ==1 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Men")
qui tabout adult_literacy_rate timesidp if gender ==1 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Men")
qui tabout adult_literacy_rate topbottomidp if gender ==1 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Men")
qui tabout adult_literacy_rate poor if gender ==1 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Men")

*Women
qui tabout adult_literacy_rate national if gender ==0 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Women")
qui tabout adult_literacy_rate comparisonhost if gender ==0 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Women")
qui tabout adult_literacy_rate urbanrural if gender ==0 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Women")
qui tabout adult_literacy_rate comparisoncamp if gender ==0 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Women")
qui tabout adult_literacy_rate reasonidp if gender ==0 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Women")
qui tabout adult_literacy_rate genidp if gender ==0 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Women")
qui tabout adult_literacy_rate durationidp if gender ==0 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Women")
qui tabout adult_literacy_rate timesidp if gender ==0 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Women")
qui tabout adult_literacy_rate topbottomidp if gender ==0 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Women")
qui tabout adult_literacy_rate poor if gender ==0 using "${gsdOutput}/Raw_Fig28.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Women")

**Enrolment
qui tabout enrolled national using "${gsdOutput}/Raw_Fig29.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("Enrolled")
qui tabout enrolled comparisonhost using "${gsdOutput}/Raw_Fig29.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Enrolled")
qui tabout enrolled urbanrural using "${gsdOutput}/Raw_Fig29.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Enrolled")
qui tabout enrolled comparisoncamp using "${gsdOutput}/Raw_Fig29.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Enrolled")
qui tabout enrolled reasonidp using "${gsdOutput}/Raw_Fig29.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Enrolled")
qui tabout enrolled genidp using "${gsdOutput}/Raw_Fig29.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Enrolled")
qui tabout enrolled durationidp using "${gsdOutput}/Raw_Fig29.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Enrolled")
qui tabout enrolled timesidp using "${gsdOutput}/Raw_Fig29.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Enrolled")
qui tabout enrolled topbottomidp using "${gsdOutput}/Raw_Fig29.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Enrolled")
qui tabout enrolled poor using "${gsdOutput}/Raw_Fig29.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Enrolled")

*Place raw data into the excel figures file
foreach i of num 28 29 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
