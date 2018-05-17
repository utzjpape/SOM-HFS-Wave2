*This do file makes sample properties tables

*HHQ
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
*Split over the comparison groups
*Had to remove c(col) from the line below.
qui tabout national using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col) replace h2("ComparisonGroups") f(4)
qui tabout comparisonhost using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col) append h2("ComparisonGroups") f(4)
qui tabout urbanrural using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col) append h2("ComparisonGroups") f(4)
qui tabout comparisoncamp using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col) append h2("ComparisonGroups") f(4)
qui tabout reasonidp using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col) append h2("ComparisonGroups") f(4)
qui tabout genidp using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col) append h2("ComparisonGroups") f(4)
qui tabout durationidp using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col) append h2("ComparisonGroups") f(4)
qui tabout timesidp using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col) append h2("ComparisonGroups") f(4)
*Use Population weights for the last two
svyset, clear
gen pweight = hhsize*weight_adj
svyset ea [pw=pweight], strata(strata) singleunit(centered)
qui tabout topbottomidp using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col) append h2("ComparisonGroups") f(4)
qui tabout poor using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col) append h2("ComparisonGroups") f(4)

*Location, HFS-W2
svyset, clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
*Location now
qui tabout reg_pess national using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess comparisoncamp using "${gsdOutput}/Raw_Fig0.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 

*Location, PMRN

*Place raw data into the excel figures file
foreach i of num 0 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
