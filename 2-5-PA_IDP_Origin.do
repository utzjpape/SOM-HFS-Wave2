*Wave 2 IDP analysis -- Displacement profile

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

*Recode variables for better graphs
gen newmove_want = move_want_yn
replace newmove_want = move_want if move_want_yn ==1
tab newmove_want
label def lnewmove_want 0 "Don't want to move" 1 "Original place of residence" 2 "New area"
label values newmove_want lnewmove_want

recode move_want_time (1=4 "Less than 6 months") (2=3 "6-12 months" ) (3=2 "More than 12 months") (4=1 "Don't know yet") (nonmissing=.), gen(newmove_want_time) label(lnewmovetime)

gen tempreturn = disp_temp_return_reason
replace tempreturn= disp_temp_return if disp_temp_return ==0 
replace tempreturn = . if tempreturn == 1000
label def ltempreturn 0 "Not gone back" 1 "Visit family" 2 "Check property status" 3 "Plant and harvest" 4 "Business" 5 "Information about location" 6 "Resettle" 7 "Pasture for livestock"
lab values tempreturn ltempreturn
recode tempreturn (3 4 5 6 7 =.)
ta tempreturn

*Reason for arriving at location
*arrive reason
ta disp_arrive_reason
ta disp_arrive_reason, nolab
label define disp_arrive_reason 2 "Water access for livestock" 3 "Home / land access" 4 "Education / health access" 5 "Employment opportunities" 6 "Join family or known people" 7 "Knew people settled here" 8 "Humanitarian access (food and water)" 1000 "Other" , modify
ta disp_arrive_reason
ta disp_arrive_reason, nolab

recode disp_arrive_reason (6 7 = 6) (1000=.)
ta disp_arrive_reason

********************
*SIGNIFICANCE TESTS
********************
*Reason for displacement-concise
recode disp_reason_concise (2=1), gen(disp_reason_sig)
la val disp_reason_sig disp_reason_concise
*Camp-noncamp
svy: prop disp_reason_sig, over(comparisoncamp)
*Armed conflict -- not sig (combined or disagg)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Drought famine flood -- not sig
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*Discrimination -- p<0.1
lincom [Discrimination]_subpop_1 - [Discrimination]_subpop_2
*Male-female head
svy: prop disp_reason_sig, over(genidp)
*Armed conflict -- not sig 
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Drought famine flood -- not sig
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*Discrimination -- p<0.05
lincom [Discrimination]_subpop_1 - [Discrimination]_subpop_2
*Protracted or not.
svy: prop disp_reason_sig, over(durationidp)
*Armed conflict -- not sig 
lincom [_prop_1]_subpop_1 - [_prop_1]Protracted
*Drought famine flood -- not sig
lincom [_prop_4]_subpop_1 - [_prop_4]Protracted
*Discrimination -- not sig
lincom [Discrimination]_subpop_1 - [Discrimination]Protracted
*Times 
svy: prop disp_reason_sig, over(timesidp)
*Armed conflict -- p<0.1
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Drought famine flood -- p<0.01
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*Discrimination -- not sig
lincom [Discrimination]_subpop_1 - [Discrimination]_subpop_2
*40 60 
svy: prop disp_reason_sig, over(topbottomidp)
*Armed conflict -- p<0.1
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Drought famine flood -- p<0.1
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*Discrimination -- not sig
lincom [Discrimination]_subpop_1 - [Discrimination]_subpop_2
*Poor nonpoor
svy: prop disp_reason_sig, over(poor)
*Armed conflict -- p<0.01
lincom [_prop_1]Poor - [_prop_1]_subpop_2
*Drought famine flood -- p<0.01
lincom [_prop_4]Poor - [_prop_4]_subpop_2
*Discrimination -- not sig
lincom [Discrimination]Poor - [Discrimination]_subpop_2

*Reason for coming here
*Camp-noncamp
svy: prop disp_arrive_reason, over(sigidp)
lincom [_prop_1]noncamp - [_prop_1]camp
lincom [_prop_4]noncamp - [_prop_4]camp
lincom [_prop_5]noncamp - [_prop_5]camp
*p<0.05
lincom [_prop_6]noncamp - [_prop_6]camp
lincom [_prop_7]noncamp - [_prop_7]camp
*Conflict-drought
svy: prop disp_arrive_reason, over(reasonidp)
*p<0.05
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_2
*p<0.05
lincom [_prop_7]_subpop_1 - [_prop_7]_subpop_2
*Male-female head
svy: prop disp_arrive_reason, over(genidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_2
lincom [_prop_7]_subpop_1 - [_prop_7]_subpop_2
*Protracted
svy: prop disp_arrive_reason, over(durationidp)
lincom [_prop_1]_subpop_1 - [_prop_1]Protracted
lincom [_prop_4]_subpop_1 - [_prop_4]Protracted
lincom [_prop_5]_subpop_1 - [_prop_5]Protracted
*p<0.05
lincom [_prop_6]_subpop_1 - [_prop_6]Protracted
lincom [_prop_7]_subpop_1 - [_prop_7]Protracted
*Times
svy: prop disp_arrive_reason, over(timesidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*p<0.1
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_2
*p<0.05
lincom [_prop_7]_subpop_1 - [_prop_7]_subpop_2
*40 60 
svy: prop disp_arrive_reason, over(topbottomidp)
*p<0.05
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
lincom [_prop_5]_subpop_1 - [_prop_5]_subpop_2
*p<0.01
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_2
lincom [_prop_7]_subpop_1 - [_prop_7]_subpop_2
*Poor nonpoor
svy: prop disp_arrive_reason, over(poor)
*p<0.01
lincom [_prop_1]Poor - [_prop_1]_subpop_2
*p<0.05
lincom [_prop_4]Poor - [_prop_4]_subpop_2
lincom [_prop_5]Poor - [_prop_5]_subpop_2
*p<0.05
lincom [_prop_6]Poor - [_prop_6]_subpop_2
*p<0.01
lincom [_prop_7]Poor - [_prop_7]_subpop_2

*Location relative to origin
*Camp-noncamp
svy: prop disp_from_new, over(comparisoncamp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Conflict-drought
svy: prop disp_from_new, over(reasonidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Man-woman head
svy: prop disp_from_new, over(genidp)
*p<0.1
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Duration
svy: prop disp_from_new, over(durationidp)
lincom [_prop_1]_subpop_1 - [_prop_1]Protracted
*Times
svy: prop disp_from_new, over(timesidp)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*40 60 
svy: prop disp_from_new, over(topbottomidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*poor nonpoor
svy: prop disp_from_new, over(poor)
lincom [_prop_1]Poor - [_prop_1]_subpop_2

*Duration of displacement
*Camp-noncamp
svy: mean durationyear, over(comparisoncamp)
*p<0.01
lincom [durationyear]_subpop_1 - [durationyear]_subpop_2
*Drought-conflict
svy: mean durationyear, over(reasonidp)
lincom [durationyear]_subpop_1 - [durationyear]_subpop_2
*Man-woman head
svy: mean durationyear, over(genidp)
lincom [durationyear]_subpop_1 - [durationyear]_subpop_2
*Protracted
svy: mean durationyear, over(durationidp)
*p<0.01
lincom [durationyear]_subpop_1 - [durationyear]Protracted
*Times
svy: mean durationyear, over(timesidp)
lincom [durationyear]_subpop_1 - [durationyear]_subpop_2
*40 60 
svy: mean durationyear, over(topbottomidp)
lincom [durationyear]_subpop_1 - [durationyear]_subpop_2
*Poor
svy: mean durationyear, over(poor)
*p<0.1
lincom [durationyear]Poor - [durationyear]_subpop_2

*Duration of arrival
*Camp-noncamp
*No sig diff between arrival durations of these two! But camp have been displaced longer.
svy: mean duration_arrive_year, over(comparisoncamp)
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]_subpop_2
*Drought-conflict
svy: mean duration_arrive_year, over(reasonidp)
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]_subpop_2
*Man-woman head
svy: mean duration_arrive_year, over(genidp)
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]_subpop_2
*Protracted
svy: mean duration_arrive_year, over(durationidp)
*p<0.01
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]Protracted
*Times
svy: mean duration_arrive_year, over(timesidp)
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]_subpop_2
*40 60 
svy: mean duration_arrive_year, over(topbottomidp)
*p<0.05
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]_subpop_2
*Poor
svy: mean duration_arrive_year, over(poor)
*p<0.01
lincom [duration_arrive_year]Poor - [duration_arrive_year]_subpop_2

*Has displacement been longer than arrival?
*Camp-noncamp
svy: mean duration_arrive_year durationyear, over(comparisoncamp)
*p<0.01
lincom [duration_arrive_year]_subpop_1 - [durationyear]_subpop_1
*p<0.01
lincom [duration_arrive_year]_subpop_2 - [durationyear]_subpop_2
*Conflict-drought
svy: mean duration_arrive_year durationyear, over(reasonidp)
*p<0.01
lincom [duration_arrive_year]_subpop_1 - [durationyear]_subpop_1
*p<0.01
lincom [duration_arrive_year]_subpop_2 - [durationyear]_subpop_2
*HHH gender
svy: mean duration_arrive_year durationyear, over(genidp)
*p<0.01
lincom [duration_arrive_year]_subpop_1 - [durationyear]_subpop_1
*p<0.01
lincom [duration_arrive_year]_subpop_2 - [durationyear]_subpop_2
*Duration
svy: mean duration_arrive_year durationyear, over(durationidp)
*p<0.01
lincom [duration_arrive_year]_subpop_1 - [durationyear]_subpop_1
*p<0.01
lincom [duration_arrive_year]Protracted - [durationyear]Protracted
*Times
svy: mean duration_arrive_year durationyear, over(timesidp)
*p<0.01
lincom [duration_arrive_year]_subpop_1 - [durationyear]_subpop_1
*p<0.01
lincom [duration_arrive_year]_subpop_2 - [durationyear]_subpop_2
*40 60 
svy: mean duration_arrive_year durationyear, over(topbottomidp)
*p<0.01
lincom [duration_arrive_year]_subpop_1 - [durationyear]_subpop_1
*p<0.01
lincom [duration_arrive_year]_subpop_2 - [durationyear]_subpop_2
*Poor
svy: mean duration_arrive_year durationyear, over(poor)
*p<0.01
lincom [duration_arrive_year]Poor - [durationyear]Poor
*p<0.01
lincom [duration_arrive_year]_subpop_2 - [durationyear]_subpop_2

*Whom did you arrive with
*Camp-noncamp -- no sig.
svy: prop disp_arrive_with, over(sigidp)
lincom [Alone]camp - [Alone]noncamp
lincom [_prop_3]camp - [_prop_3]noncamp
*Conflict-drought
svy: prop disp_arrive_with, over(reasonidp)
*P<0.1
lincom [Alone]_subpop_1 - [Alone]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Man-woman head -- no sig
svy: prop disp_arrive_with, over(genidp)
lincom [Alone]_subpop_1 - [Alone]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2

*Do you want to return
*camp-noncamp -- no sig
svy: prop newmove_want, over(comparisoncamp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Conflict-drought-- no sig
svy: prop newmove_want, over(reasonidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Man-woman head
svy: prop newmove_want, over(genidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Duration
svy: prop newmove_want, over(durationidp)
lincom [_prop_1]_subpop_1 - [_prop_1]Protracted
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
*p<0.1
lincom [_prop_3]_subpop_1 - [_prop_3]Protracted
*Times
svy: prop newmove_want, over(timesidp)
*p<0.1
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*p<0.05
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*40 60 
svy: prop newmove_want, over(topbottomidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Poor
svy: prop newmove_want, over(poor)
lincom [_prop_1]Poor - [_prop_1]_subpop_2
lincom [_prop_2]Poor - [_prop_2]_subpop_2
*p<0.1
lincom [_prop_3]Poor - [_prop_3]_subpop_2

*Time return
*Camp-NonCamp
svy: prop newmove_want_time, over(comparisoncamp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*Conflict-drought
svy: prop newmove_want_time, over(reasonidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*Man woman
svy: prop newmove_want_time, over(genidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*Duration
svy: prop newmove_want_time, over(durationidp)
*p<0.1
lincom [_prop_1]_subpop_1 - [_prop_1]Protracted
lincom [_prop_2]_subpop_1 - [_prop_2]Protracted
lincom [_prop_3]_subpop_1 - [_prop_3]Protracted
lincom [_prop_4]_subpop_1 - [_prop_4]Protracted
*Times
svy: prop newmove_want_time, over(timesidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*P<0.05
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*40 60
svy: prop newmove_want_time, over(topbottomidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*p<0.01
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*Poor
svy: prop newmove_want_time, over(poor)
lincom [_prop_1]Poor - [_prop_1]_subpop_2
*P<0.05
lincom [_prop_2]Poor - [_prop_2]_subpop_2
*P<0.05
lincom [_prop_3]Poor - [_prop_3]_subpop_2
lincom [_prop_4]Poor - [_prop_4]_subpop_2

*TABOUTS
*Reason for displacement-concise (including reasonidp for sake of excel table constuction ease; no need to graph it)
qui tabout disp_reason_concise national using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) replace h1("ReasonShort") f(4) 
qui tabout disp_reason_concise comparisoncamp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise durationidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise timesidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise topbottomidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise poor using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 

*Reason for coming here
qui tabout disp_arrive_reason national using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason comparisoncamp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason reasonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason durationidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason timesidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason topbottomidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason poor using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 

*Location before -- relative to current region
qui tabout disp_from_new national using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) replace h1("LocRelative") f(4) 
qui tabout disp_from_new comparisoncamp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new reasonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new genidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new durationidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new timesidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new topbottomidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new poor using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 

*Location now
qui tabout reg_pess comparisonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess genidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess quintileidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess genidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 

*When was the household first displaced -- overlay with ACLED data and drought event data?! (put next to reasons)
qui tabout displacementdate national using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone replace h1("DateOverall")
qui tabout displacementdate reasonidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DateReason")
qui tabout displacementdate comparisoncamp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DateCamp")

*When did the household first arrive at the current location?
qui tabout displacement_arrive_date national using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveOverall")
qui tabout displacement_arrive_date reasonidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveReason")
qui tabout displacement_arrive_date comparisoncamp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveCamp")

*Duration of displacement
qui tabout national  using "${gsdOutput}/Raw_Fig6.xls" if inlist(comparisonidp, 1, 3) , svy sum c(mean durationyear lb ub) npos(col) replace h2("DurationDisp") f(4)
qui tabout comparisoncamp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("DurationDisp") f(4)
qui tabout reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("DurationDisp") f(4)
qui tabout genidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("DurationDisp") f(4)
qui tabout durationidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("DurationDisp") f(4)
qui tabout timesidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("DurationDisp") f(4)
qui tabout topbottomidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("DurationDisp") f(4)
qui tabout poor  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("DurationDisp") f(4)

*Duration of arrival
qui tabout national using "${gsdOutput}/Raw_Fig6.xls" if inlist(comparisonidp, 1, 3), svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)
qui tabout comparisoncamp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)
qui tabout reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)
qui tabout genidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)
qui tabout durationidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)
qui tabout timesidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)
qui tabout topbottomidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)
qui tabout poor  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)

*Want to move
qui tabout newmove_want national using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want comparisoncamp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want genidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want durationidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want timesidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want topbottomidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want poor using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")

*When would you move
qui tabout newmove_want_time national using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time comparisoncamp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time genidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time durationidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time timesidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time topbottomidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time poor using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")

*Whom did you arrive with (household level or individual level?)
qui tabout disp_arrive_with national using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("Arrive_With")

*Have you gone back?
qui tabout tempreturn national using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("VisitedBack")

************************
*HHM indicators
************************
use "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

*Place raw data into the excel figures file
foreach i of num 3 4 5 6 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
