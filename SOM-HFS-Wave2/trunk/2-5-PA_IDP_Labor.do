*Wave 2 IDP analysis -- Labor

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
*Exclude Wave 1 from this (labor section was totally diff)
drop if t==0
*Remittance cleanup
sum remit12m_usd
ta remit12m
gen remittance = remit12m_usd
replace remittance = 0 if remit12m ==0
replace remittance = . if missing(remit12m)
*Livelihood, current and now, cleanup
ta lhood
recode lhood (1=1 "Salaried labor") (2 5 = 2 "Remittances") (7=4 "Family business") (8=5 "Agriculture") (9 10 12 = 6 "Trade, property income") (11 13 = 7 "Aid or zakat")  (3 4 6 = 9 "Other") (nonmiss = 9 "Other"), gen(livelihood)
ta livelihood
ta lhood_prev
gen livelihood_pre = lhood_prev 
replace livelihood_pre = lhood if lhood_prev ==0
recode livelihood_pre (1=1 "Salaried labor") (2 5 = 2 "Remittances") (7=4 "Family business") (8=5 "Agriculture") (9 10 12 = 6 "Trade, property income") (11 13 = 7 "Aid or zakat")  (3 4 6 = 9 "Other") (nonmiss = 9 "Other"), gen(livelihood_prev)
ta lhood_prev
ta livelihood_prev
*Did livelihood change?
gen lhoodchange = 0 if lhood_prev ==0
replace lhoodchange = 1 if lhood_prev !=0 & !missing(lhood_prev)
lab var lhoodchange "Livelihood was different before displacement"
lab def lhoodchange 0 "No" 1 "Yes"
lab val lhoodchange lhoodchange
ta lhoodchange if national ==0
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
************************
*Livelihoods, current
************************
svy: prop livelihood, over(siglabor)
*Is IDP livelihood different from the urban?
*p<0.01
lincom [_prop_1]idp - [_prop_1]urban
lincom [Remittances]idp - [Remittances]urban
*p<0.05
lincom [_prop_3]idp - [_prop_3]urban
*p<0.05
lincom [Agriculture]idp - [Agriculture]urban
*p<0.05
lincom [_prop_5]idp - [_prop_5]urban 
*p<0.01
lincom [_prop_6]idp - [_prop_6]urban 
*Is IDP livelihood different from the rural?
lincom [_prop_1]idp - [_prop_1]rural
lincom [Remittances]idp - [Remittances]rural
lincom [_prop_3]idp - [_prop_3]rural
*p<0.01
lincom [Agriculture]idp - [Agriculture]rural
lincom [_prop_5]idp - [_prop_5]rural 
*p<0.01
lincom [_prop_6]idp - [_prop_6]rural 	
*Is IDP livelihood different from hosts?
svy: prop livelihood, over(sighostidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [Remittances]_subpop_1 - [Remittances]_subpop_2
*p<0.05
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [Agriculture]_subpop_1 - [Agriculture]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2 
*p<0.01
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_2
*Is camp livelihood different from noncamp?
svy: prop livelihood, over(comparisoncamp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [Remittances]_subpop_1 - [Remittances]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [Agriculture]_subpop_1 - [Agriculture]_subpop_2
*p<0.1
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2 
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_2
*Is conflict livelihood different from drought?
svy: prop livelihood, over(reasonidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [Remittances]_subpop_1 - [Remittances]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*p<0.05
lincom [Agriculture]_subpop_1 - [Agriculture]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2 
*p<0.01
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_2
*Is man head livelihood different from woman head? Not really. So, no need to report.
svy: prop livelihood, over(genidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [Remittances]_subpop_1 - [Remittances]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [Agriculture]_subpop_1 - [Agriculture]_subpop_2
*p<0.1
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2 
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_2
************************
*Livelihoods, previous
************************
*Have livelihoods changed for IDPs overall?
svy: prop livelihood livelihood_prev, over(national)
lincom [_prop_1]_subpop_1 - [_prop_8]_subpop_1
*p<0.05
lincom [Remittances]_subpop_1 - [_prop_9]_subpop_1
lincom [_prop_3]_subpop_1 - [_prop_10]_subpop_1 
*p<0.01
lincom [Agriculture]_subpop_1 - [_prop_11]_subpop_1 
*p<0.01
lincom [_prop_6]_subpop_1 - [_prop_13]_subpop_1 
*Have livelihoods changed for Camp IDPs?
svy: prop livelihood livelihood_prev, over(comparisoncamp)
lincom [_prop_1]_subpop_1 - [_prop_8]_subpop_1
*p<0.05
lincom [Remittances]_subpop_1 - [_prop_9]_subpop_1
lincom [_prop_3]_subpop_1 - [_prop_10]_subpop_1 
*p<0.05
lincom [Agriculture]_subpop_1 - [_prop_11]_subpop_1 
*p<0.1
lincom [_prop_6]_subpop_1 - [_prop_13]_subpop_1 
*Have livelihoods changed for Non-camp IDPs?
lincom [_prop_1]_subpop_2 - [_prop_8]_subpop_2
lincom [Remittances]_subpop_2 - [_prop_9]_subpop_2
lincom [_prop_3]_subpop_2 - [_prop_10]_subpop_2
*p<0.01
lincom [Agriculture]_subpop_2 - [_prop_11]_subpop_2 
*p<0.05
lincom [_prop_6]_subpop_2 - [_prop_13]_subpop_2
*Have livelihoods changed for Conflict IDPs?
svy: prop livelihood livelihood_prev, over(reasonidp)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_8]_subpop_1
lincom [Remittances]_subpop_1 - [_prop_9]_subpop_1
lincom [_prop_3]_subpop_1 - [_prop_10]_subpop_1 
*p<0.05
lincom [Agriculture]_subpop_1 - [_prop_11]_subpop_1
*p<0.01
lincom [_prop_6]_subpop_1 - [_prop_13]_subpop_1
*Have livelihoods changed for Climate IDPs?
svy: prop livelihood livelihood_prev, over(reasonidp)
*p<0.01
lincom [_prop_1]_subpop_2 - [_prop_8]_subpop_2
*p<0.05
lincom [Remittances]_subpop_2 - [_prop_9]_subpop_2
lincom [_prop_3]_subpop_2 - [_prop_10]_subpop_2
*p<0.01
lincom [Agriculture]_subpop_2 - [_prop_11]_subpop_2 
lincom [_prop_6]_subpop_2 - [_prop_13]_subpop_2
************************
*Remittance amounts
************************
*Are IDP remittances different from urban and rural? Urban, ues. Rural, no.
svy: mean remittance, over(siglabor)
*p<0.1
lincom [remittance]idp - [remittance]urban
lincom [remittance]idp - [remittance]rural
*Are IDP remittances different hosts?
svy: mean remittance, over(sighostidp)
*Not significant, weirdly..
lincom [remittance]_subpop_1 - [remittance]_subpop_2
*Camp Noncamp IDPs
svy: mean remittance, over(comparisoncamp)
*p<0.1, noncamp get a LOT more.
lincom [remittance]_subpop_1 - [remittance]_subpop_2
*Climate drought IDps -- same!
svy: mean remittance, over(reasonidp)
lincom [remittance]_subpop_1 - [remittance]_subpop_2
*HHH gender
svy: mean remittance, over(genidp)
*p<0.1
lincom [remittance]_subpop_1 - [remittance]_subpop_2
*Protracted
svy: mean remittance, over(durationidp)
*p<0.05
lincom [remittance]_subpop_1 - [remittance]Protracted
*Times
svy: mean remittance, over(timesidp)
lincom [remittance]_subpop_1 - [remittance]_subpop_2
*40 60 
svy: mean remittance, over(topbottomidp)
*p<0.1
lincom [remittance]_subpop_1 - [remittance]_subpop_2
*poor non poor, no sig.
svy: mean remittance, over(poor)
lincom [remittance]Poor - [remittance]_subpop_2
************************
*Livelihoods
************************

*TABOUTS

*Table of urban and rural composition of IDPs
qui tabout urbanruraltype national using "${gsdOutput}/Raw_Fig25.xls", svy percent c(col lb ub) npos(col) replace h1("IDP_UR") f(4) 
qui tabout urbanruraltype comparisoncamp using "${gsdOutput}/Raw_Fig25.xls", svy percent c(col lb ub) npos(col) append h1("IDP_UR") f(4) 
qui tabout urbanruraltype reasonidp using "${gsdOutput}/Raw_Fig25.xls", svy percent c(col lb ub) npos(col) append h1("IDP_UR") f(4) 
qui tabout urbanruraltype genidp using "${gsdOutput}/Raw_Fig25.xls", svy percent c(col lb ub) npos(col) append h1("IDP_UR") f(4) 
qui tabout urbanruraltype durationidp using "${gsdOutput}/Raw_Fig25.xls", svy percent c(col lb ub) npos(col) append h1("IDP_UR") f(4) 
qui tabout urbanruraltype timesidp using "${gsdOutput}/Raw_Fig25.xls", svy percent c(col lb ub) npos(col) append h1("IDP_UR") f(4) 
qui tabout urbanruraltype topbottomidp using "${gsdOutput}/Raw_Fig25.xls", svy percent c(col lb ub) npos(col) append h1("IDP_UR") f(4) 
qui tabout urbanruraltype poor using "${gsdOutput}/Raw_Fig25.xls", svy percent c(col lb ub) npos(col) append h1("IDP_UR") f(4) 

*Remittances by household
qui tabout national using "${gsdOutput}/Raw_Fig23.xls", svy sum c(mean remittance lb ub se) npos(col) replace h2("Remittance") f(4)
qui tabout comparisonhost using "${gsdOutput}/Raw_Fig23.xls" , svy sum c(mean remittance lb ub se) npos(col) append h2("Remittance") f(4)
qui tabout urbanrural using "${gsdOutput}/Raw_Fig23.xls" , svy sum c(mean remittance lb ub se) npos(col) append h2("Remittance") f(4)
qui tabout comparisoncamp using "${gsdOutput}/Raw_Fig23.xls" , svy sum c(mean remittance lb ub se) npos(col) append h2("Remittance") f(4)
qui tabout reasonidp using "${gsdOutput}/Raw_Fig23.xls" , svy sum c(mean remittance lb ub se) npos(col) append h2("Remittance") f(4)
qui tabout genidp using "${gsdOutput}/Raw_Fig23.xls" , svy sum c(mean remittance lb ub se) npos(col) append h2("Remittance") f(4) 
qui tabout durationidp using "${gsdOutput}/Raw_Fig23.xls" , svy sum c(mean remittance lb ub se) npos(col) append h2("Remittance") f(4) 
qui tabout timesidp using "${gsdOutput}/Raw_Fig23.xls" , svy sum c(mean remittance lb ub se) npos(col) append h2("Remittance") f(4) 
qui tabout topbottomidp using "${gsdOutput}/Raw_Fig23.xls" , svy sum c(mean remittance lb ub se) npos(col) append h2("Remittance") f(4) 
qui tabout poor using "${gsdOutput}/Raw_Fig23.xls" , svy sum c(mean remittance lb ub se) npos(col) append h2("Remittance") f(4) 

*Note: only for 20 percent of the IDPs did lhood stay same 
*Current lhood
qui tabout livelihood national using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) replace h1("Livelihood") f(4) 
qui tabout livelihood comparisonhost using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("Livelihood") f(4) 
qui tabout livelihood urbanrural using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("Livelihood") f(4) 
qui tabout livelihood comparisoncamp using "${gsdOutput}/Raw_Fig24.xls", svy  percent c(col lb ub) npos(col) append h1("Livelihood") f(4) 
qui tabout livelihood reasonidp using "${gsdOutput}/Raw_Fig24.xls", svy  percent c(col lb ub) npos(col) append h1("Livelihood") f(4) 
qui tabout livelihood genidp using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("Livelihood") f(4) 
qui tabout livelihood durationidp using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("Livelihood") f(4) 
qui tabout livelihood timesidp using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("Livelihood") f(4) 
qui tabout livelihood topbottomidp using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("Livelihood") f(4) 
qui tabout livelihood poor using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("Livelihood") f(4)
*Previous lhood
qui tabout livelihood_prev national using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("PrevLivelihood") f(4) 
qui tabout livelihood_prev comparisoncamp using "${gsdOutput}/Raw_Fig24.xls", svy  percent c(col lb ub) npos(col) append h1("PrevLivelihood") f(4) 
qui tabout livelihood_prev reasonidp using "${gsdOutput}/Raw_Fig24.xls", svy  percent c(col lb ub) npos(col) append h1("PrevLivelihood") f(4) 
qui tabout livelihood_prev genidp using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("PrevLivelihood") f(4) 
qui tabout livelihood_prev durationidp using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("PrevLivelihood") f(4) 
qui tabout livelihood_prev timesidp using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("PrevLivelihood") f(4) 
qui tabout livelihood_prev topbottomidp using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("PrevLivelihood") f(4) 
qui tabout livelihood_prev poor using "${gsdOutput}/Raw_Fig24.xls", svy percent c(col lb ub) npos(col) append h1("PrevLivelihood") f(4)

************************
*HHM indicators
************************
use "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
*Exclude Wave 1 from this (labor section was totally diff)
drop if t==0
*LFP particip, unemp, emp
lab def lempstatus 1 "Employed" 2 "Unemployed" 3 "Enrolled" 4 "Not enrolled"
gen empstatus = 1 if emp_7d ==1
replace empstatus =2 if emp_7d ==0
replace empstatus = 3 if lfp_7d == 0 & edu_status == 1
replace empstatus =4 if lfp_7d == 0 & edu_status != 1
replace empstatus = . if working_age != 1
la val empstatus lempstatus
ta empstatus if t==1

*Employment structure
recode emp_7d_prim (1=1 "Salaried labor") (2=2 "Own business") (3=3 "Help in business") (4=4 "Own account agriculture") (5=5 "Apprenticeship"), gen(empactivity)
*Employment structure before displacement
recode emp_prev (1=1 "Salaried labor") (2=2 "Own business") (3=3 "Help in business") (4=4 "Own account agriculture") (5=5 "Apprenticeship"), gen(empactivity_prev)
*Employment strucure before displacement, aggregating those who changed and who didn't. 
gen emp_prev_all = empactivity
replace emp_prev_all = empactivity_prev if emp_prev_d ==1
la val emp_prev_all empactivity
ta emp_prev_all

*gen rural non camp
ta ind_profile if comparisoncamp ==2
la list lind_profile 
gen noncamprural = 0 
replace noncamprural = 1 if inlist(ind_profile, 4,5,8,10,12)
replace noncamprural = . if comparisoncamp !=2
label define noncamprural 0 "Urban non-camp IDP" 1 "Rural non-camp IDP"
label values noncamprural noncamprural
svy: tab noncamprural

svy: prop empactivity , over (noncamprural)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*p<0.1, rural a bit more into agriculture.
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [Apprenticeship]_subpop_1 - [Apprenticeship]_subpop_2

svy: prop empactivity , over (urbanrural)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [Apprenticeship]_subpop_1 - [Apprenticeship]_subpop_2

***********************
*SIGNIFICANCE TESTS
***********************
gen siglabor = national
replace siglabor = urbanrural if national ==1
lab def siglabor 0 "idp" 1 "urban" 2 "rural"
lab val siglabor siglabor
ta siglabor 
ta urbanrural, miss
ta national, miss
***********************
*Overall labor status
***********************
svy: prop empstatus, over(siglabor)
*Diffs between IDP and urban
lincom [Employed]idp - [Employed]urban
lincom [Unemployed]idp - [Unemployed]urban
*p<0.05
lincom [Enrolled]idp - [Enrolled]urban
lincom [_prop_4]idp - [_prop_4]urban
*Diffs between IDP and rural
lincom [Employed]idp - [Employed]rural
lincom [Unemployed]idp - [Unemployed]rural
lincom [Enrolled]idp - [Enrolled]rural
lincom [_prop_4]idp - [_prop_4]rural

*Men labor status
svy: prop empstatus if gender ==1, over(siglabor)
*Diffs between IDP and urban
lincom [Employed]idp - [Employed]urban
lincom [Unemployed]idp - [Unemployed]urban
*p<0.05
lincom [Enrolled]idp - [Enrolled]urban
*p<0.05
lincom [_prop_4]idp - [_prop_4]urban
*Diffs between IDP and rural
lincom [Employed]idp - [Employed]rural
lincom [Unemployed]idp - [Unemployed]rural
lincom [Enrolled]idp - [Enrolled]rural
lincom [_prop_4]idp - [_prop_4]rural

*Woman labor status
svy: prop empstatus if gender ==0, over(siglabor)
*Diffs between IDP and urban
lincom [Employed]idp - [Employed]urban
lincom [Unemployed]idp - [Unemployed]urban
lincom [Enrolled]idp - [Enrolled]urban
lincom [_prop_4]idp - [_prop_4]urban
*Diffs between IDP and rural
lincom [Employed]idp - [Employed]rural
lincom [Unemployed]idp - [Unemployed]rural
*p<0.1
lincom [Enrolled]idp - [Enrolled]rural
lincom [_prop_4]idp - [_prop_4]rural

*Woman and men, among IDP
svy: prop empstatus if siglabor ==0, over(gender)
*p<0.01
lincom [Employed]Female - [Employed]Male
lincom [Unemployed]Female - [Unemployed]Male
lincom [Enrolled]Female - [Enrolled]Male
*p<0.01
lincom [_prop_4]Female - [_prop_4]Male

*Woman and men, among urban
svy: prop empstatus if siglabor ==1, over(gender)
*p<0.01
lincom [Employed]Female - [Employed]Male
lincom [Unemployed]Female - [Unemployed]Male
lincom [Enrolled]Female - [Enrolled]Male
*p<0.01
lincom [_prop_4]Female - [_prop_4]Male

*Woman and men, among rural
svy: prop empstatus if siglabor ==2, over(gender)
*p<0.01
lincom [Employed]Female - [Employed]Male
lincom [Unemployed]Female - [Unemployed]Male
lincom [Enrolled]Female - [Enrolled]Male
*p<0.01
lincom [_prop_4]Female - [_prop_4]Male

***********************
*Primary employment activity
***********************
*Is it different for men and women, among IDPs? 
*Overall IDP
svy: prop empactivity if national ==0, over(gender)
*p<0.01
lincom [_prop_1]Female - [_prop_1]Male
*p<0.1
lincom [_prop_2]Female - [_prop_2]Male
*p<0.01
lincom [_prop_3]Female - [_prop_3]Male
lincom [_prop_4]Female - [_prop_4]Male
lincom [Apprenticeship]Female - [Apprenticeship]Male

*Camp IDP
svy: prop empactivity if comparisoncamp ==1, over(gender)
*p<0.01
lincom [_prop_1]Female - [_prop_1]Male
lincom [_prop_2]Female - [_prop_2]Male
*p<0.01
lincom [_prop_3]Female - [_prop_3]Male
lincom [_prop_4]Female - [_prop_4]Male
lincom [Apprenticeship]Female - [Apprenticeship]Male

*Noncamp IDP
svy: prop empactivity if comparisoncamp ==2, over(gender)
*p<0.01
lincom [_prop_1]Female - [_prop_1]Male
lincom [_prop_2]Female - [_prop_2]Male
lincom [_prop_3]Female - [_prop_3]Male
lincom [_prop_4]Female - [_prop_4]Male
lincom [Apprenticeship]Female - [Apprenticeship]Male

*Conflict IDP
svy: prop empactivity if reasonidp ==1, over(gender)
*p<0.05
lincom [_prop_1]Female - [_prop_1]Male
*p<0.1
lincom [_prop_2]Female - [_prop_2]Male
*p<0.05
lincom [_prop_3]Female - [_prop_3]Male
lincom [_prop_4]Female - [_prop_4]Male
lincom [Apprenticeship]Female - [Apprenticeship]Male
*Drought IDP
svy: prop empactivity if reasonidp ==2, over(gender)
*p<0.01
lincom [_prop_1]Female - [_prop_1]Male
*p<0.1
lincom [_prop_2]Female - [_prop_2]Male
lincom [_prop_3]Female - [_prop_3]Male
lincom [_prop_4]Female - [_prop_4]Male
lincom [Apprenticeship]Female - [Apprenticeship]Male

*Do confict and drought IDPs have different employment structures? No, not for overall.
svy: prop empactivity, over(reasonidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [Apprenticeship]_subpop_1 - [Apprenticeship]_subpop_2

*Do camp and noncamp IDPs have different employment structures? 
svy: prop empactivity, over(comparisoncamp)
*p<0.05
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*p<0.01
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [Apprenticeship]_subpop_1 - [Apprenticeship]_subpop_2

*Do IDPs overall have different employment structures than hosts?
gen sighostidp = 1 if national ==0
replace sighostidp = 2 if comparisonhost ==1
lab def sighostidp 1 "idp overall" 2 "host urban"
lab val sighostidp sighostidp
svy: prop empactivity, over(sighostidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*p<0.01
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*p<0.1
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*p<0.01
lincom [Apprenticeship]_subpop_1 - [Apprenticeship]_subpop_2

*************************
*Employment change from pre displacement
*************************
svy: prop emp_prev_d, over(comparisoncamp)
*p<0.01
lincom [Yes]_subpop_1 - [Yes]_subpop_2
svy: prop emp_prev_d, over(reasonidp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
svy: prop emp_prev_d, over(durationidp)
*p<0.05
lincom [Yes]_subpop_1 - [Yes]Protracted
svy: prop emp_prev_d, over(timesidp)
lincom [Yes]_subpop_1 - [Yes]_subpop_2
svy: prop emp_prev_d, over(genidp)
*p<0.1
lincom [Yes]_subpop_1 - [Yes]_subpop_2
svy: prop emp_prev_d, over(topbottomidp)
*p<0.05
lincom [Yes]_subpop_1 - [Yes]_subpop_2
svy: prop emp_prev_d, over(poor)
*p<0.1
lincom [Yes]Poor - [Yes]_subpop_2

*TABOUTS
*LF Status -- IDP, urban, rural
*Overall
qui tabout empstatus national  using "${gsdOutput}/Raw_Fig20.xls" , svy percent c(col lb ub) npos(col) replace h1("EmpStatus") f(4)
qui tabout empstatus urbanrural  using "${gsdOutput}/Raw_Fig20.xls" , svy percent c(col lb ub) npos(col) append h1("EmpStatus") f(4)
*Men
qui tabout empstatus national  if gender ==1 using "${gsdOutput}/Raw_Fig20.xls" , svy percent c(col lb ub) npos(col) append h1("MenEmpStatus") f(4)
qui tabout empstatus urbanrural  if gender ==1 using "${gsdOutput}/Raw_Fig20.xls" , svy percent c(col lb ub) npos(col) append h1("MenEmpStatus") f(4)
*Women 
qui tabout empstatus national  if gender ==0 using "${gsdOutput}/Raw_Fig20.xls" , svy percent c(col lb ub) npos(col) append h1("WomenEmpStatus") f(4)
qui tabout empstatus urbanrural  if gender ==0 using "${gsdOutput}/Raw_Fig20.xls" , svy percent c(col lb ub) npos(col) append h1("WomenEmpStatus") f(4)

*Primary Employment Activity
*Overall
qui tabout empactivity national using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) replace h1("EmpAct") f(4) 
qui tabout empactivity comparisonhost using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout empactivity urbanrural using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout empactivity comparisoncamp using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout empactivity reasonidp using "${gsdOutput}/Raw_Fig21.xls", svy  percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout empactivity genidp using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout empactivity durationidp using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout empactivity timesidp using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout empactivity topbottomidp using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout empactivity poor using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4)
*Men
qui tabout empactivity national if gender ==1 using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("MenEmpAct") f(4) 
qui tabout empactivity comparisonhost if gender ==1 using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("MenEmpAct") f(4) 
qui tabout empactivity urbanrural if gender ==1  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("MenEmpAct") f(4) 
qui tabout empactivity comparisoncamp if gender ==1  using "${gsdOutput}/Raw_Fig21.xls", svy  percent c(col lb ub) npos(col) append h1("MenEmpAct") f(4) 
qui tabout empactivity reasonidp if gender ==1  using "${gsdOutput}/Raw_Fig21.xls", svy  percent c(col lb ub) npos(col) append h1("MenEmpAct") f(4) 
qui tabout empactivity genidp if gender ==1  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("MenEmpAct") f(4) 
qui tabout empactivity durationidp if gender ==1  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("MenEmpAct") f(4) 
qui tabout empactivity timesidp if gender ==1  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("MenEmpAct") f(4) 
qui tabout empactivity topbottomidp if gender ==1  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("MenEmpAct") f(4) 
qui tabout empactivity poor if gender ==1  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("MenEmpAct") f(4)
*Women
qui tabout empactivity national if gender ==0 using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("WomenEmpAct") f(4) 
qui tabout empactivity comparisonhost if gender ==0 using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("WomenEmpAct") f(4) 
qui tabout empactivity urbanrural if gender ==0  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("WomenEmpAct") f(4) 
qui tabout empactivity comparisoncamp if gender ==0  using "${gsdOutput}/Raw_Fig21.xls", svy  percent c(col lb ub) npos(col) append h1("WomenEmpAct") f(4) 
qui tabout empactivity reasonidp if gender ==0  using "${gsdOutput}/Raw_Fig21.xls", svy  percent c(col lb ub) npos(col) append h1("WomenEmpAct") f(4) 
qui tabout empactivity genidp if gender ==0  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("WomenEmpAct") f(4) 
qui tabout empactivity durationidp if gender ==0  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("WomenEmpAct") f(4) 
qui tabout empactivity timesidp if gender ==0  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("WomenEmpAct") f(4) 
qui tabout empactivity topbottomidp if gender ==0  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("WomenEmpAct") f(4) 
qui tabout empactivity poor if gender ==0  using "${gsdOutput}/Raw_Fig21.xls", svy percent c(col lb ub) npos(col) append h1("WomenEmpAct") f(4)

*Did your employment change after being displaced?
*Overall
qui tabout emp_prev_d national using "${gsdOutput}/Raw_Fig22.xls", svy percent c(col lb ub) npos(col) replace h1("EmpAct") f(4) 
qui tabout emp_prev_d comparisoncamp using "${gsdOutput}/Raw_Fig22.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout emp_prev_d reasonidp using "${gsdOutput}/Raw_Fig22.xls", svy  percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout emp_prev_d genidp using "${gsdOutput}/Raw_Fig22.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout emp_prev_d durationidp using "${gsdOutput}/Raw_Fig22.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout emp_prev_d timesidp using "${gsdOutput}/Raw_Fig22.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout emp_prev_d topbottomidp using "${gsdOutput}/Raw_Fig22.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4) 
qui tabout emp_prev_d poor using "${gsdOutput}/Raw_Fig22.xls", svy percent c(col lb ub) npos(col) append h1("EmpAct") f(4)

*Place raw data into the excel figures file
foreach i of num 20 21 22 23 24 25 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
