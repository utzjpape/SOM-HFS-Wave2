*Wave 2 IDP analysis -- Documents

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

*Lost legal documents
*seems like legal_id_disp was not administered due to questionnaire coding error

*Access to get new documents
qui tabout legal_id_access_disp comparisonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) replace h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp genidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp quintileidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp reasonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp urbanrural using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp t using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 

************************
*HHM indicators
************************
use "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

*Do you have legal id?
qui tabout legal_id comparisonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id genidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id quintileidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id reasonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id urbanrural using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id t using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 

*Low priority for graphing.
*Type of legal id owned
qui tabout legal_id_type__1 comparisonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
qui tabout legal_id_type__1 genidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
qui tabout legal_id_type__1 quintileidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
qui tabout legal_id_type__1 reasonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
qui tabout legal_id_type__1 urbanrural using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
qui tabout legal_id_type__1 t using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
*7 8 9 10 and 11 have less than 20 obs total.
foreach x of num 2 3 4 5 6 12 13 14 {
	local lab`x' : variable label legal_id_type__`x'
	local label : variable label legal_id_type__`x'
    local space = strpos("`label'",":")
    local l = length("`label'")
    local h3`x' = substr("`label'",`space'+1,`l')
	qui tabout legal_id_type__`x' comparisonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`h3`x''") f(4) 
	qui tabout legal_id_type__`x' genidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`h3`x''") f(4) 
	qui tabout legal_id_type__`x' quintileidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`lab`x''") f(4) 
	qui tabout legal_id_type__`x' reasonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`lab`x''") f(4) 
	qui tabout legal_id_type__`x' urbanrural using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`lab`x''") f(4) 
	qui tabout legal_id_type__`x' t using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`lab`x''") f(4) 

}

*Place raw data into the excel figures file
foreach i of num 12 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
