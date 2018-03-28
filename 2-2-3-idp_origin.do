*Wave 2 IDP analysis -- Displacement profile

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

*Reason for arriving at location
*arrive reason
label define disp_arrive_reason 2 "Water access for livestock" 3 "Home / land access" 4 "Education / health access" 4 "Employment opportunities" 6 "Join family or known people" 7 "Knew people settled here" 8 "Humanitarian access (food and water)" 1000 "Other" , modify
ta disp_arrive_reason
recode disp_arrive_reason (6 7 = 6) (1000=.)
ta disp_arrive_reason

*Reason for displacement-concise (including reasonidp for sake of excel table constuction ease; no need to graph it)
qui tabout disp_reason_concise comparisonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) replace h1("ReasonShort") f(4) 
*qui tabout disp_reason_concise urbanrural using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
*qui tabout disp_reason_concise t using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise quintileidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise reasonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 

*Reason for displacement-detailed (including reasonidp for sake of excel table constuction ease; no need to graph it)
qui tabout disp_reason comparisonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
*qui tabout disp_reason urbanrural using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
*qui tabout disp_reason t using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
qui tabout disp_reason genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
qui tabout disp_reason quintileidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
qui tabout disp_reason reasonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 

*Reason for coming here
qui tabout disp_arrive_reason comparisonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
*qui tabout disp_arrive_reason urbanrural using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
*qui tabout disp_arrive_reason t using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason quintileidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason reasonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 

*Location now
qui tabout reg_pess comparisonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) replace h1("LocNow") f(4) 
*qui tabout reg_pess urbanrural using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
*qui tabout reg_pess t using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess genidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess quintileidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess reasonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 

*Location before -- relative to current region
qui tabout disp_from_new comparisonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
*qui tabout disp_from_new urbanrural using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
*qui tabout disp_from_new t using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new genidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new quintileidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new reasonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 

************************
*HHM indicators
************************
use "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

*Place raw data into the excel figures file
foreach i of num 3 4 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
