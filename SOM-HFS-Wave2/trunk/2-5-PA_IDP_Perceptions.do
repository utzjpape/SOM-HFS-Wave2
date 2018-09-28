*This do file performs IDP Perceptions analysis

*life_control-- weird, and no big trends.
*improve_community - potential yes but low priority

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
recode neighborrelate_disp (1 = 5 "Very good") (2=4 "Good") (3=3 "Neither good nor bad") (4=2 "Bad") (5=1 "Very bad"), gen(predisprelations) label(predisprelations) 
recode idp_compensation (1=5 "Strongly agree") (2=4 "Agree") (3=3 "Neither agree nor disagree") (4=2 "Disagree") (5=1 "Strongly disagree"), pre(new) 
recode women_work (1=4 "Almost all") (2=3 "Majority") (3=2 "Some") (4=1 "Almost none"), pre(new)
recode women_voice (1=1 "Almost none") (2=2 "Some") (3=3 "A lot"), pre(new)
recode agent_of_change (4 = 1 "Waah leaders") (3=2 "District commissioner") (2=3 "Regional administration") (10 11 =4 "National government") (1 7 8 = 5 "Local or international organizations") (nonmiss =.), gen(change_agent) label(change_agent)

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
gen sighostidp = 1 if comparisoncamp ==1
replace sighostidp = 2 if comparisonhost ==1
lab def sighostidp 1 "camp idp" 2 "host urban"
lab val sighostidp sighostidp

gen safesig = inlist(safety,1,2) if !missing(safety)
gen goodrel = inlist(neighbreelate,1,2) if !missing(neighbreelate)
gen womenwork = inlist(women_work, 1,2) if !missing(women_work)
gen idpcomp = 0 if !missing(newidp_compensation)
replace idpcomp = 1 if (newidp_compensation==4 | newidp_compensation ==5) & !missing(newidp_compensation)
gen policecompetent = inlist(police_competence, 3,4) if !missing(police_competence)
gen justice = inlist(justice_confidence, 3,4) if !missing(justice_confidence)

*Agent of change - security
svy: prop change_agent, over(siglabor)
*p<0.05
lincom [_prop_1]idp - [_prop_1]urban
lincom [_prop_2]idp - [_prop_2]urban
lincom [_prop_3]idp - [_prop_3]urban
lincom [_prop_4]idp - [_prop_4]urban
lincom [_prop_5]idp - [_prop_5]urban

lincom [_prop_1]idp - [_prop_1]rural
lincom [_prop_2]idp - [_prop_2]rural
lincom [_prop_3]idp - [_prop_3]rural
lincom [_prop_4]idp - [_prop_4]rural
lincom [_prop_5]idp - [_prop_5]rural
*Camp IDPs and hosts
svy: prop change_agent, over(sighostidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
*Camp and Non-camp
svy: prop change_agent, over(comparisoncamp)
*p<0.05
lincom [_prop_1]Settlement - [_prop_1]_subpop_2
*p<0.05
lincom [_prop_2]Settlement - [_prop_2]_subpop_2
lincom [_prop_3]Settlement - [_prop_3]_subpop_2
lincom [_prop_4]Settlement - [_prop_4]_subpop_2
lincom [_prop_5]Settlement - [_prop_5]_subpop_2
*Conflict and climates
svy: prop change_agent, over(reasonidp)
*p<0.05
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*p<0.05
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*p<0.01
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
*Man and woman head
svy: prop change_agent, over(genidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*p<0.1
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
*Protracted and not
svy: prop change_agent, over(durationidp)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]Protracted
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
lincom [_prop_3]_subpop_1 - [_prop_3]Protracted
lincom [_prop_4]_subpop_1 - [_prop_4]Protracted
lincom [_prop_5]_subpop_1 - [_prop_5]Protracted
*Times disp
svy: prop change_agent, over(timesidp)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*p<0.05
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
* 40 60
svy: prop change_agent, over(topbottomidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*p<0.1
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
*Poor
svy: prop change_agent, over(poor)
lincom [_prop_1]Poor - [_prop_1]_subpop_2
*p<0.1
lincom [_prop_2]Poor - [_prop_2]_subpop_2
lincom [_prop_3]Poor - [_prop_3]_subpop_2
lincom [_prop_4]Poor - [_prop_4]_subpop_2
lincom [_prop_5]Poor - [_prop_5]_subpop_2

*Justice confidence
svy: prop change_agent, over(siglabor)
lincom [_prop_2]idp - [_prop_2]urban
lincom [_prop_2]idp - [_prop_2]rural
*Camp IDPs and hosts
svy: prop justice, over(sighostidp)
*p<0.01
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Camp and Non-camp
svy: prop justice, over(comparisoncamp)
lincom [_prop_2]Settlement - [_prop_2]_subpop_2
*Conflict and climates
svy: prop justice, over(reasonidp)
*<0.01
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Man and woman head
svy: prop justice, over(genidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Protracted and not
svy: prop justice, over(durationidp)
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*Times disp
svy: prop justice, over(timesidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*40 60 
svy: prop justice, over(topbottomidp)
*p<0.1
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Poor
svy: prop justice, over(poor)
*p<0.1
lincom [_prop_2]Poor - [_prop_2]_subpop_2

*Police competence
svy: prop policecompetent, over(siglabor)
lincom [_prop_2]idp - [_prop_2]urban
lincom [_prop_2]idp - [_prop_2]rural
*Camp IDPs and hosts
svy: prop policecompetent, over(sighostidp)
*p<0.01
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Camp and Non-camp
svy: prop policecompetent, over(comparisoncamp)
lincom [_prop_2]Settlement - [_prop_2]_subpop_2
*Conflict and climates
svy: prop policecompetent, over(reasonidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Man and woman head
svy: prop policecompetent, over(genidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Protracted and not
svy: prop policecompetent, over(durationidp)
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*Times disp
svy: prop policecompetent, over(timesidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*40 60 
svy: prop policecompetent, over(topbottomidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Poor
svy: prop policecompetent, over(poor)
lincom [_prop_2]Poor - [_prop_2]_subpop_2

*IDPs have been compensated
*IDPs and urbanrural
svy: prop idpcomp, over(siglabor)
lincom [_prop_2]idp - [_prop_2]urban
lincom [_prop_2]idp - [_prop_2]rural
*Camp IDPs and hosts
svy: prop idpcomp, over(sighostidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Camp and Non-camp
svy: prop idpcomp, over(comparisoncamp)
lincom [_prop_2]Settlement - [_prop_2]_subpop_2
*Conflict and climates
svy: prop idpcomp, over(reasonidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Man and woman head
svy: prop idpcomp, over(genidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Protracted and not
svy: prop idpcomp, over(durationidp)
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*Times disp
svy: prop idpcomp, over(timesidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*40 60 
svy: prop idpcomp, over(topbottomidp)
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*Poor
svy: prop idpcomp, over(poor)
lincom [_prop_2]Poor - [_prop_2]_subpop_2

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
lincom [_prop_2]Settlement - [_prop_2]_subpop_2
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
lincom [_prop_2]Settlement - [_prop_2]_subpop_2
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
lincom [_prop_2]Settlement - [_prop_2]_subpop_2
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

qui tabout predisprelations national using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("PreDispRelations")
qui tabout predisprelations comparisoncamp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("PreDispRelations")
qui tabout predisprelations reasonidp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("PreDispRelations")
qui tabout predisprelations genidp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("PreDispRelations")
qui tabout predisprelations durationidp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("PreDispRelations")
qui tabout predisprelations timesidp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("PreDispRelations")
qui tabout predisprelations topbottomidp using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("PreDispRelations")
qui tabout predisprelations poor using "${gsdOutput}/Raw_Fig31.xls", svy percent c(col lb ub) npos(col) append f(4) h1("PreDispRelations")

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

*Threats experienced
qui tabout conf_nonphys_harm__1 national using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("Harm_1")
qui tabout conf_nonphys_harm__1 comparisonhost using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_1")
qui tabout conf_nonphys_harm__1 urbanrural using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_1")
qui tabout conf_nonphys_harm__1 comparisoncamp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_1")
qui tabout conf_nonphys_harm__1 reasonidp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_1")
qui tabout conf_nonphys_harm__1 genidp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_1")
qui tabout conf_nonphys_harm__1 durationidp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_1")
qui tabout conf_nonphys_harm__1 timesidp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_1")
qui tabout conf_nonphys_harm__1 topbottomidp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_1")
qui tabout conf_nonphys_harm__1 poor using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_1")

forval x = 2/5 {
	qui tabout conf_nonphys_harm__`x' national using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_`x'")
	qui tabout conf_nonphys_harm__`x' comparisonhost using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_`x'")
	qui tabout conf_nonphys_harm__`x' urbanrural using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_`x'")
	qui tabout conf_nonphys_harm__`x' comparisoncamp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_`x'")
	qui tabout conf_nonphys_harm__`x' reasonidp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_`x'")
	qui tabout conf_nonphys_harm__`x' genidp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_`x'")
	qui tabout conf_nonphys_harm__`x' durationidp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_`x'")
	qui tabout conf_nonphys_harm__`x' timesidp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_`x'")
	qui tabout conf_nonphys_harm__`x' topbottomidp using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_`x'")
	qui tabout conf_nonphys_harm__`x' poor using "${gsdOutput}/Raw_Fig46.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Harm_`x'")
}

*Belief in police competence
qui tabout police_competence national using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("Police_Competence")
qui tabout police_competence comparisonhost using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Police_Competence")
qui tabout police_competence urbanrural using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Police_Competence")
qui tabout police_competence comparisoncamp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Police_Competence")
qui tabout police_competence reasonidp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Police_Competence")
qui tabout police_competence genidp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Police_Competence")
qui tabout police_competence durationidp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Police_Competence")
qui tabout police_competence timesidp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Police_Competence")
qui tabout police_competence topbottomidp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Police_Competence")
qui tabout police_competence poor using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Police_Competence")

*Confidence in getting justice
qui tabout justice_confidence national using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Justice_Confidence")
qui tabout justice_confidence comparisonhost using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Justice_Confidence")
qui tabout justice_confidence urbanrural using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Justice_Confidence")
qui tabout justice_confidence comparisoncamp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Justice_Confidence")
qui tabout justice_confidence reasonidp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Justice_Confidence")
qui tabout justice_confidence genidp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Justice_Confidence")
qui tabout justice_confidence durationidp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Justice_Confidence")
qui tabout justice_confidence timesidp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Justice_Confidence")
qui tabout justice_confidence topbottomidp using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Justice_Confidence")
qui tabout justice_confidence poor using "${gsdOutput}/Raw_Fig47.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Justice_Confidence")

*Agent of change
qui tabout change_agent national using "${gsdOutput}/Raw_Fig48.xls", svy percent c(col lb ub) npos(col) replace f(4) h1("Change_Agent")
qui tabout change_agent comparisonhost using "${gsdOutput}/Raw_Fig48.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Change_Agent")
qui tabout change_agent urbanrural using "${gsdOutput}/Raw_Fig48.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Change_Agent")
qui tabout change_agent comparisoncamp using "${gsdOutput}/Raw_Fig48.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Change_Agent")
qui tabout change_agent reasonidp using "${gsdOutput}/Raw_Fig48.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Change_Agent")
qui tabout change_agent genidp using "${gsdOutput}/Raw_Fig48.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Change_Agent")
qui tabout change_agent durationidp using "${gsdOutput}/Raw_Fig48.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Change_Agent")
qui tabout change_agent timesidp using "${gsdOutput}/Raw_Fig48.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Change_Agent")
qui tabout change_agent topbottomidp using "${gsdOutput}/Raw_Fig48.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Change_Agent")
qui tabout change_agent poor using "${gsdOutput}/Raw_Fig48.xls", svy percent c(col lb ub) npos(col) append f(4) h1("Change_Agent")

*Risk aversion! Are IDPs, esp conflict IDPs, more present-biased?

*Place raw data into the excel figures file
foreach i of num  30/34 46 47 48 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}

