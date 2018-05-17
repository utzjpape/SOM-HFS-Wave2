*Wave 2 IDP analysis -- Documents

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
*SET POPULATION LEVEL WEIGHTS FOR THIS GRAPH TO MAKE IT COMPARABLE TO THE LEGAL ID GRAPH.
gen weight_pop = hhsize*weight_adj
svyset ea [pweight=weight_pop], strata(strata) singleunit(centered)

*Lost legal documents
*seems like legal_id_disp was not administered due to questionnaire coding error

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

*So IDps have less document restoration access than urban and hosts, but regardless of the circumstances of the displacement, the IDPs have a similar rate of access.
*Exception is the top 60- bottom 40.
*IDPs and urbanrural
svy: prop legal_id_access_disp, over(siglabor)
*p<0.01
lincom [Yes]idp - [Yes]urban
lincom [Yes]idp - [Yes]rural
*IDPs and hosts
svy: prop legal_id_access_disp, over(sighostidp)
*p<0.01
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Camp and Non-camp
svy: prop legal_id_access_disp, over(comparisoncamp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Conflict and climates
svy: prop legal_id_access_disp, over(reasonidp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Man and woman head
svy: prop legal_id_access_disp, over(genidp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Protracted and not
svy: prop legal_id_access_disp, over(durationidp)
lincom [Yes]_subpop_1 - [Yes]Protracted
*Times disp
svy: prop legal_id_access_disp, over(timesidp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*40 60 
svy: prop legal_id_access_disp, over(topbottomidp)
*p<0.01
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Poor
svy: prop legal_id_access_disp, over(poor)
lincom [Yes]Poor - [Yes]_subpop_2

*Access to get new documents
qui tabout legal_id_access_disp national using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) replace h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp comparisonhost using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp urbanrural using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp comparisoncamp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp reasonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp genidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp durationidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp timesidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp topbottomidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 
qui tabout legal_id_access_disp poor using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("AccessNewDocs") f(4) 

************************
*HHM indicators
************************
use "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

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

*IDPs and urbanrural
svy: prop legal_id, over(siglabor)
*p<0.01
lincom [Yes]idp - [Yes]urban
lincom [Yes]idp - [Yes]rural
*IDPs and hosts
svy: prop legal_id, over(sighostidp)
*p<0.01
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Camp and Non-camp
svy: prop legal_id, over(comparisoncamp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Conflict and climates
svy: prop legal_id, over(reasonidp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Man and woman head
svy: prop legal_id, over(genidp)
*p<0.01
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Protracted and not
svy: prop legal_id, over(durationidp)
lincom [Yes]_subpop_1 - [Yes]Protracted
*Times disp
svy: prop legal_id, over(timesidp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*40 60 
svy: prop legal_id, over(topbottomidp)
*p<0.05
lincom [Yes]_subpop_1 - [Yes]_subpop_2
*Poor
svy: prop legal_id, over(poor)
lincom [Yes]Poor - [Yes]_subpop_2

*Do you have legal id?
qui tabout legal_id national using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id comparisonhost using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id urbanrural using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id comparisoncamp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id reasonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id genidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id durationidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id timesidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id topbottomidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 
qui tabout legal_id poor using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("HaveLegalID") f(4) 

/*
*Low priority for graphing.
*Type of legal id owned
qui tabout legal_id_type__1 comparisonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
qui tabout legal_id_type__1 reasonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
qui tabout legal_id_type__1 urbanrural using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
qui tabout legal_id_type__1 national using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
qui tabout legal_id_type__1 genidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
qui tabout legal_id_type__1 quintileidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("Birth Certificate") f(4) 
*7 8 9 10 and 11 have less than 20 obs total.
foreach x of num 2 3 4 5 6 12 13 14 {
	local lab`x' : variable label legal_id_type__`x'
	local label : variable label legal_id_type__`x'
    local space = strpos("`label'",":")
    local l = length("`label'")
    local h3`x' = substr("`label'",`space'+1,`l')
	qui tabout legal_id_type__`x' comparisonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`h3`x''") f(4) 
	qui tabout legal_id_type__`x' reasonidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`lab`x''") f(4) 
	qui tabout legal_id_type__`x' urbanrural using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`lab`x''") f(4) 
	qui tabout legal_id_type__`x' national using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`lab`x''") f(4) 
	qui tabout legal_id_type__`x' genidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`h3`x''") f(4) 
	qui tabout legal_id_type__`x' quintileidp using "${gsdOutput}/Raw_Fig12.xls", svy percent c(col lb ub) npos(col) append h1("`lab`x''") f(4) 
	
}
*/

*Place raw data into the excel figures file
foreach i of num 12 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
