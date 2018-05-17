*This do file performs IDP Perceptions analysis

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
keep if t ==1

*Combine safety mearusres into one
*Cronbach's alpha = 0.83 (0.70 is acceptable)
alpha safe_violence safe_walking_night safe_walking_day, asis item detail gen(safety)
replace safety = 2 if safety >1 & safety <=2
replace safety = 3 if safety >2 & safety <=3
replace safety = 4 if safety > 3 & safety <=4
replace safety = 5 if safety >4 & safety <= 5
label values safety safe_violence
recode safety (1=5 "Very safe") (2=4 "Safe") (3=3 "Neither safe nor unsafe") (4=2 "Unsafe") (5=1 "Very unsafe"), pre(new) label(newsafety)
*Recode variables for better graphing
recode safe_violence safe_walking_day safe_walking_night (1=5 "Very safe") (2=4 "Safe") (3=3 "Neither safe nor unsafe") (4=2 "Unsafe") (5=1 "Very unsafe"), pre(new) label(newsafe)
recode neighbreelate (1 = 5 "Very good") (2=4 "Good") (3=3 "Neither good nor bad") (4=2 "Bad") (5=1 "Very bad"), gen(communityrelations) label(newrelations) 
recode idp_compensation (1=5 "Strongly agree") (2=4 "Agree") (3=3 "Neither agree nor disagree") (4=2 "Disagree") (5=1 "Strongly disagree"), pre(new) 
recode women_work (1=4 "Almost all") (2=3 "Majority") (3=2 "Some") (4=1 "Almost none"), pre(new)
recode women_voice (1=1 "Almost none") (2=2 "Some") (3=3 "A lot"), pre(new)

*******************
*SIGNIFICANCE TESTS
*******************
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

gen safesig = inlist(safety,1,2) if !missing(safety)
gen goodrel = inlist(neighbreelate,1,2) if !missing(neighbreelate)
gen womenwork = inlist(women_work, 1,2) if !missing(women_work)

**Women work
*IDPs and urbanrural
svy: prop womenwork, over(siglabor)
lincom [_prop_2]idp - [_prop_2]urban
*p<0.1
lincom [_prop_2]idp - [_prop_2]rural
*IDPs and hosts
svy: prop safesig, over(sighostidp)
*p<0.05
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Camp and Non-camp
svy: prop safesig, over(comparisoncamp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Conflict and climates
svy: prop safesig, over(reasonidp)
*p<0.1
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Man and woman head
svy: prop safesig, over(genidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Protracted and not
svy: prop safesig, over(durationidp)
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*Times disp
svy: prop safesig, over(timesidp)
*p<0.05
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*40 60 
svy: prop safesig, over(topbottomidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Poor
svy: prop safesig, over(poor)
lincom [_prop_2]Poor - [_prop_2]_subpop_2

**Good relations
*Camp and Non-camp
svy: prop goodrel, over(comparisoncamp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Conflict and climates
svy: prop goodrel, over(reasonidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Man and woman head
svy: prop goodrel, over(genidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Protracted and not
svy: prop goodrel, over(durationidp)
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*Times disp
svy: prop goodrel, over(timesidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*40 60 
svy: prop goodrel, over(topbottomidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Poor
svy: prop goodrel, over(poor)
lincom [_prop_2]Poor - [_prop_2]_subpop_2

**Safety
*IDPs and urbanrural
svy: prop safesig, over(siglabor)
lincom [_prop_2]idp - [_prop_2]urban
lincom [_prop_2]idp - [_prop_2]rural
*IDPs and hosts
svy: prop safesig, over(sighostidp)
*p<0.05
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Camp and Non-camp
svy: prop safesig, over(comparisoncamp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Conflict and climates
svy: prop safesig, over(reasonidp)
*p<0.1
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Man and woman head
svy: prop safesig, over(genidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Protracted and not
svy: prop safesig, over(durationidp)
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*Times disp
svy: prop safesig, over(timesidp)
*p<0.05
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*40 60 
svy: prop safesig, over(topbottomidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Poor
svy: prop safesig, over(poor)
lincom [_prop_2]Poor - [_prop_2]_subpop_2




*******************
*TABOUTS
*******************
qui tabout safety national using "${gsdOutput}/Raw_Fig30.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("Safety")
qui tabout safety comparisonhost using "${gsdOutput}/Raw_Fig30.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Safety")
qui tabout safety urbanrural using "${gsdOutput}/Raw_Fig30.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Safety")
qui tabout safety comparisoncamp using "${gsdOutput}/Raw_Fig30.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Safety")
qui tabout safety reasonidp using "${gsdOutput}/Raw_Fig30.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Safety")
qui tabout safety genidp using "${gsdOutput}/Raw_Fig30.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Safety")
qui tabout safety durationidp using "${gsdOutput}/Raw_Fig30.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Safety")
qui tabout safety timesidp using "${gsdOutput}/Raw_Fig30.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Safety")
qui tabout safety topbottomidp using "${gsdOutput}/Raw_Fig30.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Safety")
qui tabout safety poor using "${gsdOutput}/Raw_Fig30.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Safety")

qui tabout communityrelations national using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("CommunityRelate")
qui tabout communityrelations comparisoncamp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("CommunityRelate")
qui tabout communityrelations reasonidp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("CommunityRelate")
qui tabout communityrelations genidp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("CommunityRelate")
qui tabout communityrelations durationidp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("CommunityRelate")
qui tabout communityrelations timesidp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("CommunityRelate")
qui tabout communityrelations topbottomidp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("CommunityRelate")
qui tabout communityrelations poor using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("CommunityRelate")

qui tabout newidp_compensation national using "${gsdOutput}/Raw_Fig32.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("IDPCompensated")
qui tabout newidp_compensation comparisonhost using "${gsdOutput}/Raw_Fig32.xls", svy percent c(col lb ub) npos(col) append f(4) h1("IDPCompensated")
qui tabout newidp_compensation urbanrural using "${gsdOutput}/Raw_Fig32.xls", svy percent c(col lb ub) npos(col) append f(4) h1("IDPCompensated")
qui tabout newidp_compensation comparisoncamp using "${gsdOutput}/Raw_Fig32.xls", svy percent c(col lb ub) npos(col) append f(4) h1("IDPCompensated")
qui tabout newidp_compensation reasonidp using "${gsdOutput}/Raw_Fig32.xls", svy percent c(col lb ub) npos(col) append f(4) h1("IDPCompensated")
qui tabout newidp_compensation genidp using "${gsdOutput}/Raw_Fig32.xls", svy percent c(col lb ub) npos(col) append f(4) h1("IDPCompensated")
qui tabout newidp_compensation durationidp using "${gsdOutput}/Raw_Fig32.xls", svy percent c(col lb ub) npos(col) append f(4) h1("IDPCompensated")
qui tabout newidp_compensation timesidp using "${gsdOutput}/Raw_Fig32.xls", svy percent c(col lb ub) npos(col) append f(4) h1("IDPCompensated")
qui tabout newidp_compensation topbottomidp using "${gsdOutput}/Raw_Fig32.xls", svy percent c(col lb ub) npos(col) append f(4) h1("IDPCompensated")
qui tabout newidp_compensation poor using "${gsdOutput}/Raw_Fig32.xls", svy percent c(col lb ub) npos(col) append f(4) h1("IDPCompensated")

qui tabout newwomen_work national using "${gsdOutput}/Raw_Fig33.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("WomenWork")
qui tabout newwomen_work comparisonhost using "${gsdOutput}/Raw_Fig33.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenWork")
qui tabout newwomen_work urbanrural using "${gsdOutput}/Raw_Fig33.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenWork")
qui tabout newwomen_work comparisoncamp using "${gsdOutput}/Raw_Fig33.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenWork")
qui tabout newwomen_work reasonidp using "${gsdOutput}/Raw_Fig33.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenWork")
qui tabout newwomen_work genidp using "${gsdOutput}/Raw_Fig33.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenWork")
qui tabout newwomen_work durationidp using "${gsdOutput}/Raw_Fig33.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenWork")
qui tabout newwomen_work timesidp using "${gsdOutput}/Raw_Fig33.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenWork")
qui tabout newwomen_work topbottomidp using "${gsdOutput}/Raw_Fig33.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenWork")
qui tabout newwomen_work poor using "${gsdOutput}/Raw_Fig33.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenWork")

qui tabout newwomen_voice national using "${gsdOutput}/Raw_Fig34.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("WomenVoice")
qui tabout newwomen_voice comparisonhost using "${gsdOutput}/Raw_Fig34.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenVoice")
qui tabout newwomen_voice urbanrural using "${gsdOutput}/Raw_Fig34.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenVoice")
qui tabout newwomen_voice comparisoncamp using "${gsdOutput}/Raw_Fig34.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenVoice")
qui tabout newwomen_voice reasonidp using "${gsdOutput}/Raw_Fig34.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenVoice")
qui tabout newwomen_voice genidp using "${gsdOutput}/Raw_Fig34.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenVoice")
qui tabout newwomen_voice durationidp using "${gsdOutput}/Raw_Fig34.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenVoice")
qui tabout newwomen_voice timesidp using "${gsdOutput}/Raw_Fig34.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenVoice")
qui tabout newwomen_voice topbottomidp using "${gsdOutput}/Raw_Fig34.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenVoice")
qui tabout newwomen_voice poor using "${gsdOutput}/Raw_Fig34.xls", svy percent c(col lb ub) npos(col) append f(4) h1("WomenVoice")

*Place raw data into the excel figures file
foreach i of num 30/34 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
