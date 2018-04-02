*Wave 2 IDP analysis -- Push and Pull factors

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

*Label the variables
do "${gsdDo}/label_multiselect_idp.do"

*Stayers
*Stayers -- push factors -- ranked multiselect
foreach x of num 1 2 3 5 6 7 {
	*Dummy for whether the option was selected among the top 3
	gen dmove_no_push__`x' = move_no_push__`x' !=0 if !missing(move_no_push__`x')
	order dmove_no_push__`x', after(move_no_push__`x')
	*Frequency of option being selected among top 3
	egen tmove_no_push__`x' = total(dmove_no_push__`x')
	order tmove_no_push__`x', after(dmove_no_push__`x')
	*Label linked variables with same label as original option
	local lab`x' : variable label move_no_push__`x'
	label variable dmove_no_push__`x' "`lab`x''"
	label variable tmove_no_push__`x' "`lab`x''"
	*Label values of dummy
	lab val dmove_no_push__`x' lyno
}


*Stayers -- pull factors -- ranked multiselect
forval x = 1/11 {
	*Dummy for whether the option was selected among the top 3
	gen dmove_no_pull__`x' = move_no_pull__`x' !=0 if !missing(move_no_pull__`x')
	order dmove_no_pull__`x', after(move_no_pull__`x')
	*Frequency of option being selected among top 3
	egen tmove_no_pull__`x' = total(dmove_no_pull__`x')
	order tmove_no_pull__`x', after(dmove_no_pull__`x')
	*Label linked variables with same label as original option
	local lab`x' : variable label move_no_pull__`x'
	label variable dmove_no_pull__`x' "`lab`x''"
	label variable tmove_no_pull__`x' "`lab`x''"
	*Label values of dummy
	lab val dmove_no_pull__`x' lyno
}
*Movers
*Movers-- push-- ranked multiselect
forval x = 1/11 {
	*Dummy for whether the option was selected among the top 3
	gen dmove_yes_push__`x' = move_yes_push__`x' !=0 if !missing(move_yes_push__`x')
	order dmove_yes_push__`x', after(move_yes_push__`x')
	*Frequency of option being selected among top 3
	egen tmove_yes_push__`x' = total(dmove_yes_push__`x')
	order tmove_yes_push__`x', after(dmove_yes_push__`x')
	*Label linked variables with same label as original option
	local lab`x' : variable label move_yes_push__`x'
	label variable dmove_yes_push__`x' "`lab`x''"
	label variable tmove_yes_push__`x' "`lab`x''"
	*Label values of dummy
	lab val dmove_yes_push__`x' lyno
}


*Movers-- pull-- ranked multiselect
forval x = 1/7 {
	*Dummy for whether the option was selected among the top 3
	gen dmove_yes_pull__`x' = move_yes_pull__`x' !=0 if !missing(move_yes_pull__`x')
	order dmove_yes_pull__`x', after(move_yes_pull__`x')
	*Frequency of option being selected among top 3
	egen tmove_yes_pull__`x' = total(dmove_yes_pull__`x')
	order tmove_yes_pull__`x', after(dmove_yes_pull__`x')
	*Label linked variables with same label as original option
	local lab`x' : variable label move_yes_pull__`x'
	label variable dmove_yes_pull__`x' "`lab`x''"
	label variable tmove_yes_pull__`x' "`lab`x''"
	*Label values of dummy
	lab val dmove_yes_pull__`x' lyno
}

*TABOUTS
*Stayers- Push Factors
qui tabout dmove_no_push__1 comparisonidp using "${gsdOutput}/Raw_Fig7.xls", svy c(col lb ub) npos(col) replace h1("Security") f(4) 
qui tabout dmove_no_push__1 genidp using "${gsdOutput}/Raw_Fig7.xls", svy c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_no_push__1 quintileidp using "${gsdOutput}/Raw_Fig7.xls", svy c(col lb ub) npos(col) append h1("Security") f(4) 
qui tabout dmove_no_push__1 reasonidp using "${gsdOutput}/Raw_Fig7.xls", svy c(col lb ub) npos(col) append h1("Security") f(4) 
foreach x of num 2 3 5 6 7 {
	local label : variable label move_no_push__`x'
	local start = strpos("`label'","1")
	local h3 = substr("`label'",`start'+1, . )
	qui tabout dmove_no_push__`x' comparisonidp using "${gsdOutput}/Raw_Fig7.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_push__`x' genidp using "${gsdOutput}/Raw_Fig7.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_push__`x' quintileidp using "${gsdOutput}/Raw_Fig7.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_push__`x' reasonidp using "${gsdOutput}/Raw_Fig7.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
}

*Stayers- Pull factors
qui tabout dmove_no_pull__1 comparisonidp using "${gsdOutput}/Raw_Fig8.xls", svy c(col lb ub) npos(col) replace h1("ArmedConflictArea") f(4) 
qui tabout dmove_no_pull__1 genidp using "${gsdOutput}/Raw_Fig8.xls", svy c(col lb ub) npos(col) append h1("ArmedConflictArea") f(4) 
qui tabout dmove_no_pull__1 quintileidp using "${gsdOutput}/Raw_Fig8.xls", svy c(col lb ub) npos(col) append h1("ArmedConflictArea") f(4) 
qui tabout dmove_no_pull__1 reasonidp using "${gsdOutput}/Raw_Fig8.xls", svy c(col lb ub) npos(col) append h1("ArmedConflictArea") f(4) 
forval x = 2/11 {
	local label : variable label move_no_pull__`x'
	local start = strpos("`label'","2")
	local h3 = substr("`label'",`start'+1, . )
	qui tabout dmove_no_pull__`x' comparisonidp using "${gsdOutput}/Raw_Fig8.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_pull__`x' genidp using "${gsdOutput}/Raw_Fig8.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_pull__`x' quintileidp using "${gsdOutput}/Raw_Fig8.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_no_pull__`x' reasonidp using "${gsdOutput}/Raw_Fig8.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
}

*Movers- Push factors
qui tabout dmove_yes_push__1 comparisonidp using "${gsdOutput}/Raw_Fig9.xls", svy c(col lb ub) npos(col) replace h1("ArmedConflictArea") f(4) 
qui tabout dmove_yes_push__1 genidp using "${gsdOutput}/Raw_Fig9.xls", svy c(col lb ub) npos(col) append h1("ArmedConflictArea") f(4) 
qui tabout dmove_yes_push__1 quintileidp using "${gsdOutput}/Raw_Fig9.xls", svy c(col lb ub) npos(col) append h1("ArmedConflictArea") f(4) 
qui tabout dmove_yes_push__1 reasonidp using "${gsdOutput}/Raw_Fig9.xls", svy c(col lb ub) npos(col) append h1("ArmedConflictArea") f(4) 
forval x = 2/11 {
	local label : variable label move_yes_push__`x'
	local start = strpos("`label'","3")
	local h3 = substr("`label'",`start'+1, . )
	qui tabout dmove_yes_push__`x' comparisonidp using "${gsdOutput}/Raw_Fig9.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_push__`x' genidp using "${gsdOutput}/Raw_Fig9.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_push__`x' quintileidp using "${gsdOutput}/Raw_Fig9.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_push__`x' reasonidp using "${gsdOutput}/Raw_Fig9.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
}

*Movers- Pull factors
qui tabout dmove_yes_pull__1 comparisonidp using "${gsdOutput}/Raw_Fig10.xls", svy c(col lb ub) npos(col) replace h1("BetterSecurity") f(4) 
qui tabout dmove_yes_pull__1 genidp using "${gsdOutput}/Raw_Fig10.xls", svy c(col lb ub) npos(col) append h1("BetterSecurity") f(4) 
qui tabout dmove_yes_pull__1 quintileidp using "${gsdOutput}/Raw_Fig10.xls", svy c(col lb ub) npos(col) append h1("BetterSecurity") f(4) 
qui tabout dmove_yes_pull__1 reasonidp using "${gsdOutput}/Raw_Fig10.xls", svy c(col lb ub) npos(col) append h1("BetterSecurity") f(4) 
forval x = 2/7 {
	local label : variable label move_yes_pull__`x'
	local start = strpos("`label'","55")
	local h3 = substr("`label'",`start'+2, . )
	qui tabout dmove_yes_pull__`x' comparisonidp using "${gsdOutput}/Raw_Fig10.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_pull__`x' genidp using "${gsdOutput}/Raw_Fig10.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_pull__`x' quintileidp using "${gsdOutput}/Raw_Fig10.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
	qui tabout dmove_yes_pull__`x' reasonidp using "${gsdOutput}/Raw_Fig10.xls", svy c(col lb ub) npos(col) append h1("`h3'") f(4) 
}

*Place raw data into the excel figures file
foreach i of num 10 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
