*This do file runs the analysis for the typology of IDPs 

use "${gsdTemp}/working_file.dta", clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

lab def clustergroups 1 "Group 1" 2 "Group 2"
lab val cluster_group_war clustergroups

************************************************
*Number of observations per group
************************************************
qui tabout cluster_group_war using "${gsdOutput}/Raw_Groups.xls", svy percent c(col lb ub) npos(col) replace h1("Groups") f(4) 

************************************************
*Cause profile
************************************************
*Very low ownership overall
svy: prop own_any_prod_prev, over(cluster_group_war)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2

*No significance
svy: prop origin_now, over(cluster_group_war)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2

*No significance
svy: prop harm_dum, over(cluster_group_war)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2

*No sig.
svy: prop livestockown_pre, over(cluster_group_war)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2

*Big diff, p<0.01
svy: prop distance_pre, over(cluster_group_war)
lincom [Near]_subpop_1 - [Near]_subpop_2
qui tabout distance_pre cluster_group_war using "${gsdOutput}/Raw_Cause.xls", svy percent c(col lb ub) npos(col) replace h1("Distance_pre") f(4) 

*p<0.01
svy: prop land_access_yn_disp, over(cluster_group_war)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
qui tabout land_access_yn_disp cluster_group_war using "${gsdOutput}/Raw_Cause.xls", svy percent c(col lb ub) npos(col) append h1("Land_access_pre") f(4) 

*p<0.01
svy: prop housingimproveddisp, over(cluster_group_war)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
qui tabout housingimproveddisp cluster_group_war using "${gsdOutput}/Raw_Cause.xls", svy percent c(col lb ub) npos(col) append h1("HousingImproved_pre") f(4) 

*Drought and conflict differences!
svy: prop disp_reason_concise, over(cluster_group_war)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*p<0.1
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [Discrimination]_subpop_1 - [Discrimination]_subpop_2
*p<0.01
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
qui tabout disp_reason_concise cluster_group_war using "${gsdOutput}/Raw_Cause.xls", svy percent c(col lb ub) npos(col) append h1("Reason_Disp") f(4) 

*Very interesting divergences.
svy: prop disp_arrive_reason, over(cluster_group_war)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*p<0.05
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*p<0.05
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*p<0.01
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
qui tabout disp_arrive_reason cluster_group_war using "${gsdOutput}/Raw_Cause.xls", svy percent c(col lb ub) npos(col) append h1("Reason_Arrive") f(4) 

*Livelihood
svy: prop livelihood_prev, over(cluster_group_war)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*p<0.01
lincom [Remittances]_subpop_1 - [Remittances]_subpop_2
*p<0.01
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*p<0.01
lincom [Agriculture]_subpop_1 - [Agriculture]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
*p<0.05
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_2
qui tabout livelihood_prev cluster_group_war using "${gsdOutput}/Raw_Cause.xls", svy percent c(col lb ub) npos(col) append h1("Livelihood_pre") f(4) 

************************************************
*Needs profile (needs1: numeric; needs2: categorical)
************************************************

*NO sig
svy: prop hhh_gender, over(cluster_group_war)
lincom [Female]_subpop_1 - [Female]_subpop_2
qui tabout hhh_gender cluster_group_war using "${gsdOutput}/Raw_Needs1.xls", svy percent c(col lb ub) npos(col) replace h1("HHH_Gender") f(4) 

*p<0.01
svy: prop hhh_literacy, over(cluster_group_war)
lincom [Literate ]_subpop_1 - [Literate]_subpop_2
qui tabout hhh_literacy cluster_group_war using "${gsdOutput}/Raw_Needs2.xls", svy percent c(col lb ub) npos(col) append h1("HHH_Literacy") f(4) 

*p<0.05, small difference
svy: mean hhsize, over(cluster_group_war)
lincom [hhsize]_subpop_1 - [hhsize]_subpop_2
qui tabout cluster_group_war using "${gsdOutput}/Raw_Needs1.xls", svy sum c(mean hhsize lb ub) npos(col) append h2("HHSize") f(4) 

*p<0.05
svy: mean age_dependency_ratio, over(cluster_group_war)
lincom [age_dependency_ratio]_subpop_1 - [age_dependency_ratio]_subpop_2
qui tabout cluster_group_war using "${gsdOutput}/Raw_Needs1.xls", svy sum c(mean age_dependency_ratio lb ub) npos(col) append h2("DepRatio") f(4) 

*Poverty
svyset, clear
gen hhweight=weight_adj*hhsize
svyset ea [pweight=hhweight], strata(strata) singleunit(centered)
svy: mean poorPPP_prob, over(cluster_group_war)
*p<0.05
lincom [poorPPP_prob ]_subpop_1 - [poorPPP_prob]_subpop_2
qui tabout cluster_group_war using "${gsdOutput}/Raw_Needs1.xls", svy sum c(mean poorPPP_prob lb ub) npos(col) append h2("Poverty") f(4) 
svyset, clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

*p<0.05
svy: prop hunger_dum, over(cluster_group_war)
lincom [Hungry ]_subpop_1 - [Hungry ]_subpop_2
qui tabout hunger_dum cluster_group_war using "${gsdOutput}/Raw_Needs2.xls", svy percent c(col lb ub) npos(col) replace h1("Hunger") f(4) 

*No sig
svy: prop waterimproved, over(cluster_group_war)
lincom [Improved ]_subpop_1 - [Improved ]_subpop_2

*p<0.01
svy: prop housingimproved, over(cluster_group_war)
lincom [_prop_2 ]_subpop_1 - [_prop_2 ]_subpop_2
qui tabout housingimproved cluster_group_war using "${gsdOutput}/Raw_Needs2.xls", svy percent c(col lb ub) npos(col) append h1("Housing") f(4) 

*p<0.01
svy: prop sanimproved_shared, over(cluster_group_war)
lincom [Improved ]_subpop_1 - [Improved ]_subpop_2
qui tabout sanimproved_shared cluster_group_war using "${gsdOutput}/Raw_Needs2.xls", svy percent c(col lb ub) npos(col) append h1("Sanitation") f(4) 

*p<0.01
svy: prop land_access_yn, over(cluster_group_war)
lincom [Land ]_subpop_1 - [Land]_subpop_2
qui tabout land_access_yn cluster_group_war using "${gsdOutput}/Raw_Needs2.xls", svy percent c(col lb ub) npos(col) append h1("Land") f(4) 

*Livelihood
svy: prop livelihood, over(cluster_group_war)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*p<0.01
lincom [Remittances]_subpop_1 - [Remittances]_subpop_2
*p<0.01
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*p<0.01
lincom [Agriculture]_subpop_1 - [Agriculture]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
*p<0.01
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_2
qui tabout livelihood cluster_group_war using "${gsdOutput}/Raw_Needs2.xls", svy percent c(col lb ub) npos(col) append h1("Livelihood") f(4) 

*NO sig
svy: prop assist_source_any, over(cluster_group_war)
lincom [_prop_2 ]_subpop_1 - [_prop_2]_subpop_2

*NO sig
svy: prop own_any_prod, over(cluster_group_war)
lincom [_prop_2 ]_subpop_1 - [_prop_2]_subpop_2

*NO sig
svy: prop livestockown, over(cluster_group_war)
lincom [Livestock ]_subpop_1 - [Livestock]_subpop_2

*NO sig
svy: prop distance, over(cluster_group_war)
lincom [Near ]_subpop_1 - [Near]_subpop_2

*NO sig
svy: prop move_free, over(cluster_group_war)
lincom [_prop_2 ]_subpop_1 - [_prop_2]_subpop_2

************************************************
*Solution profile
************************************************

svy: prop movetime, over(cluster_group_war)
lincom [Stay]_subpop_1 - [Stay]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*p<0.01
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*p<0.01
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
qui tabout movetime cluster_group_war using "${gsdOutput}/Raw_Solution.xls", svy percent c(col lb ub) npos(col) replace h1("MoveIntention") f(4) 

*p<0.01
svy: prop pullpush_security, over(cluster_group_war)
lincom [Security]_subpop_1 - [Security]_subpop_2
qui tabout pullpush_security cluster_group_war using "${gsdOutput}/Raw_Solution.xls", svy percent c(col lb ub) npos(col) append h1("PullPush") f(4) 

svy: prop information_final, over(cluster_group_war)
*p<0.1
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*p<0.1
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
qui tabout information_final cluster_group_war using "${gsdOutput}/Raw_Solution.xls", svy percent c(col lb ub) npos(col) append h1("Info") f(4) 

*p<0.05
svy: prop movehelp_new, over(cluster_group_war)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
qui tabout movehelp_new cluster_group_war using "${gsdOutput}/Raw_Solution.xls", svy percent c(col lb ub) npos(col) append h1("Security_Settle") f(4) 

************************************************
*Profile over the Comparison Groups
************************************************
qui tabout cluster_group_war comparisonidp using "${gsdOutput}/Raw_CompGroup.xls", svy percent c(col lb ub) npos(col) replace h1("CompGroup") f(4) 
qui tabout cluster_group_war national using "${gsdOutput}/Raw_CompGroup.xls", svy percent c(col lb ub) npos(col) append h1("CompGroup") f(4) 
qui tabout cluster_group_war reasonidp using "${gsdOutput}/Raw_CompGroup.xls", svy  percent c(col lb ub) npos(col) append h1("CompGroup") f(4) 
qui tabout cluster_group_war durationidp using "${gsdOutput}/Raw_CompGroup.xls", svy percent c(col lb ub) npos(col) append h1("CompGroup") f(4) 
qui tabout cluster_group_war timesidp using "${gsdOutput}/Raw_CompGroup.xls", svy percent c(col lb ub) npos(col) append h1("CompGroup") f(4) 
qui tabout cluster_group_war genidp using "${gsdOutput}/Raw_CompGroup.xls", svy percent c(col lb ub) npos(col) append h1("CompGroup") f(4) 
qui tabout cluster_group_war topbottomidp using "${gsdOutput}/Raw_CompGroup.xls", svy percent c(col lb ub) npos(col) append h1("CompGroup") f(4) 

************************************************
*Place in Figures file
************************************************
insheet using "${gsdOutput}/Raw_Groups.xls", clear nonames
	export excel using "${gsdOutput}/Figures_typology.xlsx", sheetreplace sheet("Raw_Groups") 
	rm "${gsdOutput}/Raw_Groups.xls"
	
insheet using "${gsdOutput}/Raw_Cause.xls", clear nonames
	export excel using "${gsdOutput}/Figures_typology.xlsx", sheetreplace sheet("Raw_Cause") 
	rm "${gsdOutput}/Raw_Cause.xls"

insheet using "${gsdOutput}/Raw_Needs1.xls", clear nonames
	export excel using "${gsdOutput}/Figures_typology.xlsx", sheetreplace sheet("Raw_Needs1") 
	rm "${gsdOutput}/Raw_Needs1.xls"
		
insheet using "${gsdOutput}/Raw_Needs2.xls", clear nonames
	export excel using "${gsdOutput}/Figures_typology.xlsx", sheetreplace sheet("Raw_Needs2") 
	rm "${gsdOutput}/Raw_Needs2.xls"
	
insheet using "${gsdOutput}/Raw_Solution.xls", clear nonames
	export excel using "${gsdOutput}/Figures_typology.xlsx", sheetreplace sheet("Raw_Solution") 
	rm "${gsdOutput}/Raw_Solution.xls"
	
insheet using "${gsdOutput}/Raw_CompGroup.xls", clear nonames
	export excel using "${gsdOutput}/Figures_typology.xlsx", sheetreplace sheet("Raw_CompGroup") 
	rm "${gsdOutput}/Raw_CompGroup.xls"
