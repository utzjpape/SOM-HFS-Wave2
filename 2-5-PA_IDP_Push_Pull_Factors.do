*Wave 2 IDP analysis -- Push and Pull factors

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

*Label the variables
do "${gsdDo}/label_multiselect_idp.do"

*Recode these variables to have less categories
*Move_no_pull
gen newmove_no_pull__1 = ( move_no_pull__1 !=0 |  move_no_pull__2 !=0 | move_no_pull__3 !=0 )
replace newmove_no_pull__1 = . if missing(move_no_pull__1) & missing(move_no_pull__2) & missing(move_no_pull__3)
label var newmove_no_pull__1 "J.51: Conflict or insecurity"

gen newmove_no_pull__2 = move_no_pull__4 !=0 & !missing(move_no_pull__4)
label var newmove_no_pull__2 "J.51: Discrimination"

gen newmove_no_pull__3 = move_no_pull__5 !=0 & !missing(move_no_pull__5)
label var newmove_no_pull__3 "J.51: Drought, famine, flood"

gen newmove_no_pull__4 = ( move_no_pull__6 !=0 |  move_no_pull__7 !=0 | move_no_pull__9 !=0 )
replace newmove_no_pull__4 = . if missing(move_no_pull__6) & missing(move_no_pull__7) & missing(move_no_pull__9)
label var newmove_no_pull__4 "J.51: Home, land, livestock, employment"

gen newmove_no_pull__5 = ( move_no_pull__8 !=0 |  move_no_pull__11 !=0 )
replace newmove_no_pull__5 = . if missing(move_no_pull__8) & missing(move_no_pull__11)
label var newmove_no_pull__5 "J.51: Health, education, humanitarian aid"

gen newmove_no_pull__6 = move_no_pull__10 !=0 & !missing(move_no_pull__10)
label var newmove_no_pull__6 "J.51: Family"

*Move_no_push
gen newmove_no_push__1 = move_no_push__1 != 0
label var newmove_no_push__1 "J.50: Better security"
ta newmove_no_push__1
ta move_no_push__1

gen newmove_no_push__2 = (move_no_push__2 !=0 | move_no_push__5 != 0)
replace newmove_no_push__2 = . if missing(move_no_push__2) & missing(move_no_push__5)
label var newmove_no_push__2 "J.50: Home, land, livestock, employment"

gen newmove_no_push__3 = ( move_no_push__3 !=0 | move_no_push__7 !=0)
replace newmove_no_push__3 = . if missing(move_no_push__3) & missing(move_no_push__7)
label var newmove_no_push__3 "J.50: Health, education, humanitarian aid"

gen newmove_no_push__4 = ( move_no_push__6!= 0)
label var newmove_no_push__4 "J.50: Family"

*Move_yes_pull
gen newmove_yes_pull__1 = ( move_yes_pull__1 !=0 )
label var newmove_yes_pull__1 "J.56: Better security"

gen newmove_yes_pull__2 = ( move_yes_pull__2 !=0 |  move_yes_pull__3 !=0 | move_yes_pull__5 !=0 )
replace newmove_yes_pull__2 = . if missing(move_yes_pull__2) & missing(move_yes_pull__3) & missing(move_yes_pull__5)
label var newmove_yes_pull__2 "J.56: Home, land, livestock, employment"

gen newmove_yes_pull__3 = ( move_yes_pull__4 !=0 |  move_yes_pull__7 !=0 )
replace newmove_yes_pull__3 = . if missing(move_yes_pull__4) & missing(move_yes_pull__7)
label var newmove_yes_pull__3 "J.56: Health, education, humanitarian aid"

gen newmove_yes_pull__4 = ( move_yes_pull__6 !=0 )
label var newmove_yes_pull__4 "J.56: Family"

*Move_yes_push
gen newmove_yes_push__1 = ( move_yes_push__1 !=0 |  move_yes_push__2 !=0 | move_yes_push__3 !=0 )
replace newmove_yes_push__1 = . if missing(move_yes_push__1) & missing(move_yes_push__2) & missing(move_yes_push__3)
label var newmove_yes_push__1 "J.51: Conflict or insecurity"

gen newmove_yes_push__2 = move_yes_push__4 !=0 & !missing(move_yes_push__4)
label var newmove_yes_push__2 "J.51: Discrimination"

gen newmove_yes_push__3 = move_yes_push__5 !=0 & !missing(move_yes_push__5)
label var newmove_yes_push__3 "J.51: Drought, famine, flood"

gen newmove_yes_push__4 = ( move_yes_push__6 !=0 |  move_yes_push__7 !=0 | move_yes_push__9 !=0 )
replace newmove_yes_push__4 = . if missing(move_yes_push__6) & missing(move_yes_push__7) & missing(move_yes_push__9)
label var newmove_yes_push__4 "J.51: Home, land, livestock, employment"

gen newmove_yes_push__5 = ( move_yes_push__8 !=0 |  move_yes_push__11 !=0 )
replace newmove_yes_push__5 = . if missing(move_yes_push__8) & missing(move_yes_push__11)
label var newmove_yes_push__5 "J.51: Health, education, humanitarian aid"

gen newmove_yes_push__6 = move_yes_push__10 !=0 & !missing(move_yes_push__10)
label var newmove_yes_push__6 "J.51: Family"


*Stayers
*Stayers -- push factors -- ranked multiselect
foreach x of num 1 2 3 4 {
	*Dummy for whether the option was selected among the top 3
	gen dmove_no_push__`x' = newmove_no_push__`x' !=0 if !missing(newmove_no_push__`x')
	order dmove_no_push__`x', after(newmove_no_push__`x')
	*Frequency of option being selected among top 3
	egen tmove_no_push__`x' = total(dmove_no_push__`x')
	order tmove_no_push__`x', after(dmove_no_push__`x')
	*Label linked variables with same label as original option
	local lab`x' : variable label newmove_no_push__`x'
	label variable dmove_no_push__`x' "`lab`x''"
	label variable tmove_no_push__`x' "`lab`x''"
	*Label values of dummy
	lab val dmove_no_push__`x' lyno
}

*Stayers -- pull factors -- ranked multiselect
forval x = 1/6 {
	*Dummy for whether the option was selected among the top 3
	gen dmove_no_pull__`x' = newmove_no_pull__`x' !=0 if !missing(newmove_no_pull__`x')
	order dmove_no_pull__`x', after(newmove_no_pull__`x')
	*Frequency of option being selected among top 3
	egen tmove_no_pull__`x' = total(dmove_no_pull__`x')
	order tmove_no_pull__`x', after(dmove_no_pull__`x')
	*Label linked variables with same label as original option
	local lab`x' : variable label newmove_no_pull__`x'
	label variable dmove_no_pull__`x' "`lab`x''"
	label variable tmove_no_pull__`x' "`lab`x''"
	*Label values of dummy
	lab val dmove_no_pull__`x' lyno
}
*Movers
*Movers-- push-- ranked multiselect
forval x = 1/6 {
	*Dummy for whether the option was selected among the top 3
	gen dmove_yes_push__`x' = newmove_yes_push__`x' !=0 if !missing(newmove_yes_push__`x')
	order dmove_yes_push__`x', after(newmove_yes_push__`x')
	*Frequency of option being selected among top 3
	egen tmove_yes_push__`x' = total(dmove_yes_push__`x')
	order tmove_yes_push__`x', after(dmove_yes_push__`x')
	*Label linked variables with same label as original option
	local lab`x' : variable label newmove_yes_push__`x'
	label variable dmove_yes_push__`x' "`lab`x''"
	label variable tmove_yes_push__`x' "`lab`x''"
	*Label values of dummy
	lab val dmove_yes_push__`x' lyno
}

*Movers-- pull-- ranked multiselect
forval x = 1/4 {
	*Dummy for whether the option was selected among the top 3
	gen dmove_yes_pull__`x' = newmove_yes_pull__`x' !=0 if !missing(newmove_yes_pull__`x')
	order dmove_yes_pull__`x', after(newmove_yes_pull__`x')
	*Frequency of option being selected among top 3
	egen tmove_yes_pull__`x' = total(dmove_yes_pull__`x')
	order tmove_yes_pull__`x', after(dmove_yes_pull__`x')
	*Label linked variables with same label as original option
	local lab`x' : variable label newmove_yes_pull__`x'
	label variable dmove_yes_pull__`x' "`lab`x''"
	label variable tmove_yes_pull__`x' "`lab`x''"
	*Label values of dummy
	lab val dmove_yes_pull__`x' lyno
}

*SIGNIFICANCE TESTS
*Stay-Push
svy: mean dmove_no_push__1, over(comparisoncamp)
*p<0.01
lincom [dmove_no_push__1]_subpop_1- [dmove_no_push__1]_subpop_2
svy: mean dmove_no_push__1, over(genidp)
*no sig
lincom [dmove_no_push__1]_subpop_1- [dmove_no_push__1]_subpop_2

/*
*Stay-Pull
svy: mean dmove_no_pull__1, over(sigidp)
*P<0.05
lincom [dmove_no_pull__1]camp- [dmove_no_pull__1]noncamp
svy: mean dmove_no_pull__1, over(genidp)
*no sig
lincom [dmove_no_pull__1]_subpop_1- [dmove_no_pull__1]_subpop_2
svy: mean dmove_no_pull__1, over(reasonidp)
*p<0.01
lincom [dmove_no_pull__1]_subpop_1- [dmove_no_pull__1]_subpop_2
svy: mean dmove_no_pull__3, over(reasonidp)
*p<0.05
lincom [dmove_no_pull__3]_subpop_1- [dmove_no_pull__3]_subpop_2

*Move-Push
svy: mean dmove_yes_push__1, over(genidp)
lincom [dmove_yes_push__1]_subpop_1- [dmove_yes_push__1]_subpop_2
svy: mean dmove_yes_push__5, over(genidp)
lincom [dmove_yes_push__5]_subpop_1- [dmove_yes_push__5]_subpop_2
*/

*TABOUTS
keep if t ==1
*Stayers- Push Factors
qui tabout dmove_no_push__1 national using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) replace h1("Security") f(4) 
qui tabout dmove_no_push__1 comparisoncamp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_no_push__1 reasonidp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_no_push__1 genidp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_no_push__1 durationidp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_no_push__1 timesidp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_no_push__1 topbottomidp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_no_push__1 poor using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 

foreach x of num 2 3 4 {
	local label : variable label newmove_no_push__`x'
	local start = strpos("`label'",":")
	local h3 = substr("`label'",`start'+1, . )
	qui tabout dmove_no_push__`x' national using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_push__`x' comparisoncamp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_push__`x' reasonidp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_push__`x' genidp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_push__`x' durationidp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_push__`x' timesidp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_push__`x' topbottomidp using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_push__`x' poor using "${gsdOutput}/Raw_Fig7.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 

}
/*
*Stayers- Pull factors
qui tabout dmove_no_pull__1 comparisonidp using "${gsdOutput}/Raw_Fig8.xls", svy percent c(col lb ub) npos(col) replace h1("Conflict or insecurity") f(4) 
qui tabout dmove_no_pull__1 reasonidp using "${gsdOutput}/Raw_Fig8.xls", svy percent c(col lb ub) npos(col) append h1("Conflict or insecurity") f(4) 
qui tabout dmove_no_pull__1 genidp using "${gsdOutput}/Raw_Fig8.xls", svy percent c(col lb ub) npos(col) append h1("Conflict or insecurity") f(4) 
qui tabout dmove_no_pull__1 quintileidp using "${gsdOutput}/Raw_Fig8.xls", svy percent c(col lb ub) npos(col) append h1("Conflict or insecurity") f(4) 
forval x = 2/6 {
	local label : variable label newmove_no_pull__`x'
	local start = strpos("`label'",":")
	local h3 = substr("`label'",`start'+1, . )
	qui tabout dmove_no_pull__`x' comparisonidp using "${gsdOutput}/Raw_Fig8.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_pull__`x' reasonidp using "${gsdOutput}/Raw_Fig8.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_pull__`x' genidp using "${gsdOutput}/Raw_Fig8.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_pull__`x' quintileidp using "${gsdOutput}/Raw_Fig8.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
}

*Movers- Push factors
qui tabout dmove_yes_push__1 comparisonidp using "${gsdOutput}/Raw_Fig9.xls", svy percent c(col lb ub) npos(col) replace h1("Conflict or insecurity") f(4) 
qui tabout dmove_yes_push__1 reasonidp using "${gsdOutput}/Raw_Fig9.xls", svy percent c(col lb ub) npos(col) append h1("Conflict or insecurity") f(4) 
qui tabout dmove_yes_push__1 genidp using "${gsdOutput}/Raw_Fig9.xls", svy percent c(col lb ub) npos(col) append h1("Conflict or insecurity") f(4) 
qui tabout dmove_yes_push__1 quintileidp using "${gsdOutput}/Raw_Fig9.xls", svy percent c(col lb ub) npos(col) append h1("Conflict or insecurity") f(4) 
forval x = 2/6 {
	local label : variable label newmove_yes_push__`x'
	local start = strpos("`label'",":")
	local h3 = substr("`label'",`start'+1, . )
	qui tabout dmove_yes_push__`x' comparisonidp using "${gsdOutput}/Raw_Fig9.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_push__`x' reasonidp using "${gsdOutput}/Raw_Fig9.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_push__`x' genidp using "${gsdOutput}/Raw_Fig9.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_push__`x' quintileidp using "${gsdOutput}/Raw_Fig9.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
}
*/
*Movers- Pull factors
qui tabout dmove_yes_pull__1 national using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) replace h1("Security") f(4) 
qui tabout dmove_yes_pull__1 comparisoncamp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_yes_pull__1 reasonidp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_yes_pull__1 genidp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_yes_pull__1 durationidp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_yes_pull__1 timesidp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_yes_pull__1 topbottomidp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_yes_pull__1 poor using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("Security") f(4) 

forval x = 2/4 {
	local label : variable label newmove_yes_pull__`x'
	local start = strpos("`label'",":")
	local h3 = substr("`label'",`start'+1, . )
	qui tabout dmove_yes_pull__`x' national using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_pull__`x' comparisoncamp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_pull__`x' reasonidp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_pull__`x' genidp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_pull__`x' durationidp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_pull__`x' timesidp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_pull__`x' topbottomidp using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_pull__`x' poor using "${gsdOutput}/Raw_Fig10.xls", svy percent c(col lb ub) npos(col) append h1("`h3'") f(4) 

}

*Place raw data into the excel figures file
foreach i of num 7 10 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
