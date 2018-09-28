*Wave 2 IDP analysis -- Demographic profile

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

gen poptest = comparisoncamp
replace poptest = 3 if national ==1
lab def poptest 1 "camp" 2 "noncamp" 3 "national"
lab val poptest poptest

*Overall, are the ages different for the three groups
svy: prop age_g_idp, over(poptest)
lincom [_prop_1]camp - [_prop_1]national
lincom [_prop_2]camp - [_prop_2]national
lincom [_prop_3]camp - [_prop_3]national
*p<0.05
lincom [_prop_4]camp - [_prop_4]national

lincom [_prop_1]noncamp - [_prop_1]national
lincom [_prop_2]noncamp - [_prop_2]national
lincom [_prop_3]noncamp - [_prop_3]national
lincom [_prop_4]noncamp - [_prop_4]national

lincom [_prop_1]noncamp - [_prop_1]camp
lincom [_prop_2]noncamp - [_prop_2]camp
lincom [_prop_3]noncamp - [_prop_3]camp
*p<0.1
lincom [_prop_4]noncamp - [_prop_4]camp

*For women, are the ages different for the three groups
svy: prop age_g_idp if gender ==0, over(poptest)
lincom [_prop_1]camp - [_prop_1]national
lincom [_prop_2]camp - [_prop_2]national
lincom [_prop_3]camp - [_prop_3]national
lincom [_prop_4]camp - [_prop_4]national

lincom [_prop_1]noncamp - [_prop_1]national
lincom [_prop_2]noncamp - [_prop_2]national
lincom [_prop_3]noncamp - [_prop_3]national
lincom [_prop_4]noncamp - [_prop_4]national

lincom [_prop_1]noncamp - [_prop_1]camp
lincom [_prop_2]noncamp - [_prop_2]camp
lincom [_prop_3]noncamp - [_prop_3]camp
lincom [_prop_4]noncamp - [_prop_4]camp

*For men, are the ages different for the three groups
svy: prop age_g_idp if gender ==1, over(poptest)
lincom [_prop_1]camp - [_prop_1]national
lincom [_prop_2]camp - [_prop_2]national
lincom [_prop_3]camp - [_prop_3]national
*p<0.01
lincom [_prop_4]camp - [_prop_4]national

lincom [_prop_1]noncamp - [_prop_1]national
lincom [_prop_2]noncamp - [_prop_2]national
lincom [_prop_3]noncamp - [_prop_3]national
lincom [_prop_4]noncamp - [_prop_4]national

lincom [_prop_1]noncamp - [_prop_1]camp
lincom [_prop_2]noncamp - [_prop_2]camp
lincom [_prop_3]noncamp - [_prop_3]camp
lincom [_prop_4]noncamp - [_prop_4]camp

svy: prop gender if comparisoncamp ==2,  over(age_g_idp)
lincom [Male]_subpop_1 - [Female]_subpop_1
lincom [Male]_subpop_2 - [Female]_subpop_2
*P<0.05
lincom [Male]_subpop_3 - [Female]_subpop_3
lincom [Male]_subpop_4 - [Female]_subpop_4

*Camp IDPs have fewer men than women: 4 age groups: significant
svy: prop gender if comparisoncamp ==1,  over(age_g_idp)
lincom [Male]_subpop_1 - [Female]_subpop_1
*P<0.05
lincom [Male]_subpop_2 - [Female]_subpop_2
lincom [Male]_subpop_3 - [Female]_subpop_3
lincom [Male]_subpop_4 - [Female]_subpop_4

*National have fewer men than women: 4 age groups: significant
svy: prop gender if national==1,  over(age_g_idp)
lincom [Male]_subpop_1 - [Female]_subpop_1
*P<0.01
lincom [Male]_subpop_2 - [Female]_subpop_2
lincom [Male]_subpop_3 - [Female]_subpop_3
*p<0.1
lincom [Male]_subpop_4 - [Female]_subpop_4

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
*Significance tests

gen poptest = comparisoncamp
replace poptest = 3 if national ==1
lab def poptest 1 "camp" 2 "noncamp" 3 "national"
lab val poptest poptest

*Perc of female headed hhs
svy: mean hhh_gender, over(poptest)
*P<0.01
lincom [hhh_gender]noncamp - [hhh_gender]camp
*p<0.05
lincom [hhh_gender]noncamp - [hhh_gender]national
*no sig
lincom [hhh_gender]camp - [hhh_gender]national


*Dependency ratio-- overall
svy: mean age_dependency_ratio, over(poptest)
*no sig
lincom [age_dependency_ratio]noncamp - [age_dependency_ratio]camp
*no sig
lincom [age_dependency_ratio]noncamp - [age_dependency_ratio]national
*no sig
lincom [age_dependency_ratio]camp - [age_dependency_ratio]national

*Dependency ratio-- hhh_gender, non camp
svy: mean age_dependency_ratio if poptest ==2, over(sighh) 
*P<0.05
lincom [age_dependency_ratio]Female - [age_dependency_ratio]Male

*Dependency ratio-- hhh_gender, camp
svy: mean age_dependency_ratio if poptest ==1, over(sighh) 
*no sig
lincom [age_dependency_ratio]Female - [age_dependency_ratio]Male

*Dependency ratio-- hhh_gender, non national
svy: mean age_dependency_ratio if poptest ==3, over(sighh) 
*no sig
lincom [age_dependency_ratio]Female - [age_dependency_ratio]Male

*Household size -- overall
svy: mean hhsize, over(poptest)
*no sig
lincom [hhsize]noncamp - [hhsize]camp
*p<0.05
lincom [hhsize]noncamp - [hhsize]national
*no sig
lincom [hhsize]camp - [hhsize]national

*HHsize- hhh_gender, non camp
svy: mean hhsize if poptest ==2, over(sighh) 
*no sig
lincom [hhsize]Female - [hhsize]Male

*hhsize-- hhh_gender, camp
svy: mean hhsize if poptest ==1, over(sighh) 
*p<0.1
lincom [hhsize]Female - [hhsize]Male

*hhsize-- hhh_gender, non national
svy: mean hhsize if poptest ==3, over(sighh) 
*no sig
lincom [hhsize]Female - [hhsize]Male

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
