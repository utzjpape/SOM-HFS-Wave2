*Wave 2 IDP analysis -- Poverty

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_cons], strata(strata) singleunit(centered)

*CREATE AND PREPARE VARIABLES
gen gap = (plinePPP - tc_imp)/plinePPP if (!missing(tc_imp)) 
replace gap = 0 if (tc_imp>plinePPP & !missing(tc_imp))
gen severity = (gap)^2 

*Get poverty figures in percentage
replace poorPPP_prob = 100*poorPPP_prob

*SIGNIFICANCE TESTS
*Define sig test with IDPs as a unit, versus national and rural
*Should we have an IDP overall somewhere too? I think yes. can put it in national wala group. make that a compulsory 2, national and IDP from wave 2 and wave 1 missing.
*TABOUTS
*Poverty headcount ratio: % of Population living on $1.90 PPP per person per day
qui tabout comparisonidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean poorPPP_prob lb ub se) npos(col) replace h2("Poverty") f(4)
qui tabout urbanrural using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean poorPPP_prob lb ub se) npos(col) append h2("Poverty") f(4)
qui tabout national using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean poorPPP_prob lb ub se) npos(col) append h2("Poverty") f(4)
qui tabout reasonidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean poorPPP_prob lb ub se) npos(col) append h2("Poverty") f(4)
qui tabout durationidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean poorPPP_prob lb ub se) npos(col) append h2("Poverty") f(4) 
qui tabout timesidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean poorPPP_prob lb ub se) npos(col) append h2("Poverty") f(4) 
qui tabout genidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean poorPPP_prob lb ub se) npos(col) append h2("Poverty") f(4) 
qui tabout topbottomidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean poorPPP_prob lb ub se) npos(col) append h2("Poverty") f(4) 

*Gap
qui tabout comparisonidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean gap lb ub se) npos(col) append h2("Gap") f(4)
qui tabout urbanrural using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean gap lb ub se) npos(col) append h2("Gap") f(4)
qui tabout national using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean gap lb ub se) npos(col) append h2("Gap") f(4)
qui tabout reasonidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean gap lb ub se) npos(col) append h2("Gap") f(4)
qui tabout durationidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean gap lb ub se) npos(col) append h2("Gap") f(4) 
qui tabout timesidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean gap lb ub se) npos(col) append h2("Gap") f(4) 
qui tabout genidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean gap lb ub se) npos(col) append h2("Gap") f(4) 
qui tabout topbottomidp using "${gsdOutput}/Raw_Fig14.xls" , svy sum c(mean gap lb ub se) npos(col) append h2("Gap") f(4) 

*Place raw data into the excel figures file
foreach i of num 14 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
