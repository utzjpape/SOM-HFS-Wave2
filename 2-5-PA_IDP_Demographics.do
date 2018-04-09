*Wave 2 IDP analysis -- Demographic profile

************************
*HHM indicators
************************
use "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

*1. Population pyramids 

*Urbanoverall (excluding IDPs)
qui tabout age_g_idp gender using "${gsdOutput}/Raw_Fig1.xls" if urbanrural==1, replace svy percent c(col ) f(3) sebnone h1("Urban")
qui tabout gender using "${gsdOutput}/Raw_Fig1.xls" if urbanrural==1, append svy percent c(col ) f(3) sebnone h1("Urban")
*Ruraloverall (excluding IDPs)
qui tabout age_g_idp gender using "${gsdOutput}/Raw_Fig1.xls" if urbanrural==2, append svy percent c(col ) f(3) sebnone h1("Rural")
qui tabout gender using "${gsdOutput}/Raw_Fig1.xls" if urbanrural==2, append svy percent c(col ) f(3) sebnone h1("Rural")
*National (excluding IDPs)
qui tabout age_g_idp gender using "${gsdOutput}/Raw_Fig1.xls" if t==1 & migr_idp !=1 & ind_profile !=13  , append svy percent c(col ) f(3) sebnone h1("National2017")
qui tabout gender using "${gsdOutput}/Raw_Fig1.xls" if t==1 & migr_idp !=1 & ind_profile !=13 , append svy percent c(col ) f(3) sebnone h1("National2017")

*Non-camp IDP
qui tabout age_g_idp gender using "${gsdOutput}/Raw_Fig1.xls" if comparisonidp==1, append svy percent c(col ) f(3) sebnone h1("NonCampPyramid")
qui tabout gender using "${gsdOutput}/Raw_Fig1.xls" if comparisonidp==1, append svy percent c(col ) f(3) sebnone h1("NonCampPyramid")
*Camp IDP 2016
qui tabout age_g_idp gender using "${gsdOutput}/Raw_Fig1.xls" if comparisonidp==2, append svy percent c(col ) f(3) sebnone h1("Camp2016")
qui tabout gender using "${gsdOutput}/Raw_Fig1.xls" if comparisonidp==2, append svy percent c(col ) f(3) sebnone h1("Camp2016")
*Camp IDP 2017
qui tabout age_g_idp gender using "${gsdOutput}/Raw_Fig1.xls" if comparisonidp==3, append svy percent c(col ) f(3) sebnone h1("Camp2017")
qui tabout gender using "${gsdOutput}/Raw_Fig1.xls" if comparisonidp==3, append svy percent c(col ) f(3) sebnone h1("Camp2017")
*Host
qui tabout age_g_idp gender using "${gsdOutput}/Raw_Fig1.xls" if comparisonidp==4, append svy percent c(col ) f(3) sebnone h1("Host")
qui tabout gender using "${gsdOutput}/Raw_Fig1.xls" if comparisonidp==4, append svy percent c(col ) f(3) sebnone h1("Host")
*Non-host
qui tabout age_g_idp gender using "${gsdOutput}/Raw_Fig1.xls" if comparisonidp==5, append svy percent c(col ) f(3) sebnone h1("Nonhost")
qui tabout gender using "${gsdOutput}/Raw_Fig1.xls" if comparisonidp==5, append svy percent c(col ) f(3) sebnone h1("Nonhost")

*All IDPs (Non-camp and camp), 2017
qui tabout age_g_idp gender using "${gsdOutput}/Raw_Fig1.xls" if inlist(comparisonidp , 1, 3 ), append svy percent c(col ) f(3) sebnone h1("AllIDPs2017")
qui tabout gender using "${gsdOutput}/Raw_Fig1.xls" if inlist(comparisonidp , 1, 3 ), append svy percent c(col ) f(3) sebnone h1("AllIDPs2017")

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)


*% of female headed households 
qui tabout hhh_gender comparisonidp using "${gsdOutput}/Raw_Fig2.xls"  , replace svy percent c(col lb ub) f(6) npos(col) sebnone h1("hhh_gender_composition")
*urban and rural 2017 (excluding idps)
qui tabout hhh_gender urbanrural using "${gsdOutput}/Raw_Fig2.xls" , append svy percent c(col lb ub) f(6) npos(col) sebnone h1("hhh_gender_composition")
*national (excluding idps)
qui tabout hhh_gender national using "${gsdOutput}/Raw_Fig2.xls", append svy percent c(col lb ub) f(4) npos(col) sebnone h1("hhh_gender_composition")

*Dependency ratio-overall
qui tabout comparisonidp  using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("age_dependency_ratio") f(4)
qui tabout urbanrural  using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("age_dependency_ratio") f(4)
qui tabout national  using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("age_dependency_ratio") f(4)
*Dependency ratio by hhh gender
qui tabout hhh_gender if comparisonidp==1 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("Noncamp_GendHH_depratio") f(4)
qui tabout hhh_gender if comparisonidp==2 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("Camp2016_GendHH_depratio") f(4)
qui tabout hhh_gender if comparisonidp==3 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("Camp_GendHH_depratio") f(4)
qui tabout hhh_gender if comparisonidp==4 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("Host_GendHH_depratio") f(4)
qui tabout hhh_gender if comparisonidp==5 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("Nonhost_GendHH_depratio") f(4)
qui tabout hhh_gender if urbanrural ==1 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("Urban_GendHH_depratio") f(4)
qui tabout hhh_gender if urbanrural ==2 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("Rural_GendHH_depratio") f(4)
qui tabout hhh_gender if national ==1 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("National_GendHH_depratio") f(4)

*Household size
*Household size-overall
qui tabout comparisonidp  using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("HHsize") f(4)
qui tabout urbanrural  using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("HHsize") f(4)
qui tabout national  using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("HHsize") f(4)
*Household size by hhh gender
qui tabout hhh_gender if comparisonidp==1 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("Noncamp_GendHH_hhsize") f(4)
qui tabout hhh_gender if comparisonidp==2 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("Camp2016_GendHH_hhsize") f(4)
qui tabout hhh_gender if comparisonidp==3 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("Camp_GendHH_hhsize") f(4)
qui tabout hhh_gender if comparisonidp==4 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("Host_GendHH_hhsize") f(4)
qui tabout hhh_gender if comparisonidp==5 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("Nonhost_GendHH_hhsize") f(4)
qui tabout hhh_gender if urbanrural ==1 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("Urban_GendHH_hhsize") f(4)
qui tabout hhh_gender if urbanrural ==2 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("Rural_GendHH_hhsize") f(4)
qui tabout hhh_gender if national ==1 using "${gsdOutput}/Raw_Fig2.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("National_GendHH_hhsize") f(4)

*Place raw data into the excel figures file
foreach i of num 1 2 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
