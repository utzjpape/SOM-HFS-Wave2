*Wave 2 IDP analysis -- Poverty

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
gen hhweight=weight_adj*hhsize
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
svy: mean poorPPP_prob if t==1, over(ind_profile)
svy: mean poorPPP_prob, over(comparisonidp)

*CREATE AND PREPARE VARIABLES
gen gap = (plinePPP - tc_imp)/plinePPP if (!missing(tc_imp)) 
replace gap = 0 if (tc_imp>plinePPP & !missing(tc_imp))
gen severity = (gap)^2 

*Get poverty figures in percentage
replace poorPPP_prob = 100*poorPPP_prob

*SIGNIFICANCE TESTS
*Poverty.
*IDP and others
svy: mean poorPPP_prob, over(sighost)
*no sig.
lincom [poorPPP_prob]idp - [poorPPP_prob]host
*p<0.05
lincom [poorPPP_prob]idp - [poorPPP_prob]nonhost
*IDP and urbanrural
svy: mean poorPPP_prob, over(sigrural)
*no sig.
lincom [poorPPP_prob]idp - [poorPPP_prob]rural
*p<0.05.
lincom [poorPPP_prob]idp - [poorPPP_prob]urban
*IDP and national
svy: mean poorPPP_prob, over(sigdt)
*p<0.1
lincom [poorPPP_prob]idp - [poorPPP_prob]national
*Camp noncamp
svy: mean poorPPP_prob, over(sigcamp)
*no sig
lincom [poorPPP_prob]camp - [poorPPP_prob]noncamp
*Reason
svy: mean poorPPP_prob, over(sigreason)
*p<0.01, climate IDPs are more poor!
lincom [poorPPP_prob]conflict - [poorPPP_prob]climate
*Protracted
svy: mean poorPPP_prob, over(sigdur)
*p<0.01, unprotracted IDPs are more poor!
lincom [poorPPP_prob]unprot - [poorPPP_prob]prot
*Multiple
svy: mean poorPPP_prob, over(sigtime)
*p<0.1, once IDPs are more poor..
lincom [poorPPP_prob]once - [poorPPP_prob]multiple
*HH Head
svy: mean poorPPP_prob, over(siggen)
*p<0.1, man headed IDPs are more poor..
lincom [poorPPP_prob]woman - [poorPPP_prob]man
*Quintile
svy: mean poorPPP_prob, over(sigtb)
*p<0.01
lincom [poorPPP_prob]top - [poorPPP_prob]bottom

*Gap
*IDP and others
svy: mean gap, over(sighost)
*no sig.
lincom [gap]idp - [gap]host
*p<0.01
lincom [gap]idp - [gap]nonhost
*IDP and urbanrural
svy: mean gap, over(sigrural)
*no sig.
lincom [gap]idp - [gap]rural
*p<0.01.
lincom [gap]idp - [gap]urban
*IDP and national
svy: mean gap, over(sigdt)
*p<0.01
lincom [gap]idp - [gap]national
*Camp noncamp
svy: mean gap, over(sigcamp)
*no sig
lincom [gap]camp - [gap]noncamp
*Reason
svy: mean gap, over(sigreason)
*p<0.05, climate IDPs are more poor!
lincom [gap]conflict - [gap]climate
*Protracted
svy: mean gap, over(sigdur)
*p<0.01, unprotracted IDPs are more poor!
lincom [gap]unprot - [gap]prot
*Multiple
svy: mean gap, over(sigtime)
*no sig.
lincom [gap]once - [gap]multiple
*HH Head
svy: mean gap, over(siggen)
*no sig.
lincom [gap]woman - [gap]man
*Quintile
svy: mean gap, over(sigtb)
*p<0.01
lincom [gap]top - [gap]bottom

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
