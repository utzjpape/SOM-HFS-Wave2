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

*SIGNIFICANCE TESTS
*Reason for displacement-concise
recode disp_reason_concise (2=1), gen(disp_reason_sig)
la val disp_reason_sig disp_reason_concise
*Camp-noncamp
svy: prop disp_reason_sig, over(sigidp)
*Armed conflict -- not sig (combined or disagg)
lincom [_prop_1]noncamp - [_prop_1]camp
*Drought famine flood -- not sig
lincom [_prop_4]noncamp - [_prop_4]camp
*Discrimination -- p<0.1
lincom [Discrimination]noncamp - [Discrimination]camp
*Male-female head
svy: prop disp_reason_sig, over(genidp)
*Armed conflict -- not sig (combined or disagg)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Drought famine flood -- not sig
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*Discrimination -- p<0.05
lincom [Discrimination]_subpop_1 - [Discrimination]_subpop_2
*Quintiles -- richest different from the other four
svy: prop disp_reason_sig, over(quintileidp)
*Armed conflict -- not sig (combined or disagg)
*p<0.1
lincom [_prop_1]_subpop_5 - [_prop_1]_subpop_1
*Rest are not sig
lincom [_prop_1]_subpop_5 - [_prop_1]Q2
lincom [_prop_1]_subpop_5 - [_prop_1]Q3
lincom [_prop_1]_subpop_5 - [_prop_1]Q4
*Drought --p<0.05 for all!
lincom [_prop_4]_subpop_5 - [_prop_4]_subpop_1
lincom [_prop_4]_subpop_5 - [_prop_4]Q2
lincom [_prop_4]_subpop_5 - [_prop_4]Q3
lincom [_prop_4]_subpop_5 - [_prop_4]Q4

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
*Quintiles
*Q5 and Q4 vs Q1 and Q2
svy: prop disp_arrive_reason, over(quintileidp)
*Conflict
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_5
lincom [_prop_1]_subpop_1 - [_prop_1]Q4
lincom [_prop_1]Q2 - [_prop_1]_subpop_5
lincom [_prop_1]Q2 - [_prop_1]Q4
lincom [_prop_1]_subpop_5 - [_prop_1]Q3
lincom [_prop_1]Q4 - [_prop_1]Q3
lincom [_prop_1]Q2 - [_prop_1]Q3
lincom [_prop_1]_subpop_1 - [_prop_1]Q3
*Join family
*p<0.01
lincom [_prop_6]_subpop_1 - [_prop_6]_subpop_5
*p<0.05
lincom [_prop_6]_subpop_1 - [_prop_6]Q4
lincom [_prop_6]Q2 - [_prop_6]_subpop_5
lincom [_prop_6]Q2 - [_prop_6]Q4
lincom [_prop_6]_subpop_5 - [_prop_6]Q3
lincom [_prop_6]Q4 - [_prop_6]Q3
lincom [_prop_6]Q2 - [_prop_6]Q3
*P<0.01
lincom [_prop_6]_subpop_1 - [_prop_6]Q3
*Humanitarian access
lincom [_prop_7]_subpop_1 - [_prop_7]_subpop_5
lincom [_prop_7]_subpop_1 - [_prop_7]Q4
lincom [_prop_7]Q2 - [_prop_7]_subpop_5
lincom [_prop_7]Q2 - [_prop_7]Q4
lincom [_prop_7]_subpop_5 - [_prop_7]Q3
lincom [_prop_7]Q4 - [_prop_7]Q3
lincom [_prop_7]Q2 - [_prop_7]Q3
lincom [_prop_7]_subpop_1 - [_prop_7]Q3

*Location relative to origin
*Camp-noncamp
svy: prop disp_from_new, over(sigidp)
lincom [_prop_1]noncamp - [_prop_1]camp
*Conflict-drought
svy: prop disp_from_new, over(reasonidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Man-woman head
svy: prop disp_from_new, over(genidp)
*p<0.01
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
*Quintiles
svy: prop disp_from_new, over(quintileidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_5
lincom [_prop_1]_subpop_1 - [_prop_1]Q4
lincom [_prop_1]_subpop_1 - [_prop_1]Q3
lincom [_prop_1]_subpop_1 - [_prop_1]Q2

*Duration of displacement
*Camp-noncamp
svy: mean durationyear, over(sigidp)
*p<0.01
lincom [durationyear]camp - [durationyear]noncamp
*Drought-conflict
svy: mean durationyear, over(reasonidp)
lincom [durationyear]_subpop_1 - [durationyear]_subpop_2
*Man-woman head
svy: mean durationyear, over(genidp)
lincom [durationyear]_subpop_1 - [durationyear]_subpop_2
*Quintiles
svy: mean durationyear, over(quintileidp)
*p<0.05
lincom [durationyear]_subpop_5 - [durationyear]Q4
*p<0.05
lincom [durationyear]_subpop_5 - [durationyear]Q3
lincom [durationyear]_subpop_5 - [durationyear]Q2
lincom [durationyear]_subpop_5 - [durationyear]_subpop_1

*Duration of arrival
*Camp-noncamp
*No sig diff between arrival durations of these two! But camp have been displaced longer.
svy: mean duration_arrive_year, over(sigidp)
lincom [duration_arrive_year]camp - [duration_arrive_year]noncamp
*Drought-conflict
svy: mean duration_arrive_year, over(reasonidp)
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]_subpop_2
*Man-woman head
svy: mean duration_arrive_year, over(genidp)
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]_subpop_2
*Quintiles
svy: mean duration_arrive_year, over(quintileidp)
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]Q2
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]Q3
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]Q4
*P<0.1
lincom [duration_arrive_year]_subpop_1 - [duration_arrive_year]_subpop_5

*Has displacement been longer than arrival?
*Camp-noncamp
svy: mean duration_arrive_year durationyear, over(sigidp)
*p<0.01
lincom [duration_arrive_year]camp - [durationyear]camp
*p<0.01
lincom [duration_arrive_year]noncamp - [durationyear]noncamp
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

*Number of times displaced
*Camp-noncamp
svy: prop disp_times, over(sigidp)
lincom [Once]camp - [Once]noncamp
*Quintiles--no sig
svy: prop disp_times, over(quintileidp)
lincom [Once]Q2 - [Once]_subpop_1
lincom [Once]Q2 - [Once]Q3
lincom [Once]Q2 - [Once]Q4
lincom [Once]Q2 - [Once]_subpop_5

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
*Quintiles
svy: prop disp_arrive_with, over(quintileidp)
*Alone
lincom [Alone]_subpop_1 - [Alone]Q3
*p<0.1
lincom [Alone]_subpop_1 - [Alone]Q4
*p<0.05
lincom [Alone]_subpop_1 - [Alone]_subpop_5
*In a larger group
*p<0.05
lincom [_prop_3]_subpop_1 - [_prop_3]Q3
lincom [_prop_3]_subpop_1 - [_prop_3]Q4
*p<0.05
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_5

*Do you want to return
*camp-noncamp -- no sig
svy: prop newmove_want, over(sigidp)
lincom [_prop_1]camp - [_prop_1]noncamp
lincom [_prop_2]camp - [_prop_2]noncamp
lincom [_prop_3]camp - [_prop_3]noncamp
*Conflict-drought-- no sig
svy: prop newmove_want, over(reasonidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*Man-woman head
svy: prop newmove_want, over(genidp)
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
*p<0.05
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2

*Time return
*Camp-NonCamp
svy: prop newmove_want_time, over(sigidp)
lincom [_prop_1]camp - [_prop_1]noncamp
lincom [_prop_2]camp - [_prop_2]noncamp
lincom [_prop_3]camp - [_prop_3]noncamp
lincom [_prop_4]camp - [_prop_4]noncamp
*COnflict-drought
svy: prop newmove_want_time, over(reasonidp)
*p<0.1
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_2
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_2
lincom [_prop_3]_subpop_1 - [_prop_3]_subpop_2
*p<0.05
lincom [_prop_4]_subpop_1 - [_prop_4]_subpop_2
*Quintiles
svy: prop newmove_want_time, over(quintileidp)
lincom [_prop_1]_subpop_1 - [_prop_1]Q2
lincom [_prop_1]_subpop_1 - [_prop_1]Q3
lincom [_prop_1]_subpop_1 - [_prop_1]Q4
lincom [_prop_1]_subpop_1 - [_prop_1]_subpop_5

lincom [_prop_2]_subpop_1 - [_prop_2]Q2
lincom [_prop_2]_subpop_1 - [_prop_2]Q3
lincom [_prop_2]_subpop_1 - [_prop_2]Q4
lincom [_prop_2]_subpop_1 - [_prop_2]_subpop_5

*Have you gone back--nobody has gone back.

*TABOUTS
*Reason for displacement-concise (including reasonidp for sake of excel table constuction ease; no need to graph it)
qui tabout disp_reason_concise comparisonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) replace h1("ReasonShort") f(4) 
*qui tabout disp_reason_concise urbanrural using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
*qui tabout disp_reason_concise national using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise quintileidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise reasonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 

*Reason for displacement-detailed (including reasonidp for sake of excel table constuction ease; no need to graph it)
qui tabout disp_reason comparisonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
*qui tabout disp_reason urbanrural using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
*qui tabout disp_reason national using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
qui tabout disp_reason genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
qui tabout disp_reason quintileidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
qui tabout disp_reason reasonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 

*Reason for coming here
qui tabout disp_arrive_reason comparisonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
*qui tabout disp_arrive_reason urbanrural using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
*qui tabout disp_arrive_reason national using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason quintileidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason reasonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 

*Location now
qui tabout reg_pess comparisonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) replace h1("LocNow") f(4) 
*qui tabout reg_pess urbanrural using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
*qui tabout reg_pess national using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess genidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess quintileidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess reasonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 

*Location before -- relative to current region
qui tabout disp_from_new comparisonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
*qui tabout disp_from_new urbanrural using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
*qui tabout disp_from_new national using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new genidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new quintileidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new reasonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 

*When was the household first displaced -- overlay with ACLED data and drought event data?! (put next to reasons)
qui tabout displacementdate comparisonidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone replace h1("DispDate")
*qui tabout displacementdate genidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispDate")
*qui tabout displacementdate quintileidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispDate")
qui tabout displacementdate reasonidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispDate")
qui tabout displacementdate reasonidp using "${gsdOutput}/Raw_Fig5.xls" if comparisonidp ==3, svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispDateCampReason")

*When did the household first arrive at the current location?
qui tabout displacement_arrive_date comparisonidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveDate")
*qui tabout displacement_arrive_date genidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveDate")
*qui tabout displacement_arrive_date quintileidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveDate")
qui tabout displacement_arrive_date reasonidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveDate")
qui tabout displacement_arrive_date reasonidp using "${gsdOutput}/Raw_Fig5.xls" if comparisonidp ==3, svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveDateCampReason")

*Duration of displacement
qui tabout comparisonidp  using "${gsdOutput}/Raw_Fig6.xls" if inlist(comparisonidp, 1, 3) , svy sum c(mean durationyear lb ub) npos(col) replace h2("DurationDisp") f(4)
qui tabout genidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("DurationDisp") f(4)
qui tabout quintileidp using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("DurationDisp") f(4)
qui tabout reasonidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("DurationDisp") f(4)

*Duration of arrival
qui tabout comparisonidp using "${gsdOutput}/Raw_Fig6.xls" if inlist(comparisonidp, 1, 3), svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)
qui tabout genidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)
qui tabout quintileidp using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)
qui tabout reasonidp  using "${gsdOutput}/Raw_Fig6.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("DurationArrive") f(4)

*Number of times the household was displaced
qui tabout disp_times comparisonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispTimes")
qui tabout disp_times reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispTimes")
qui tabout disp_times genidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispTimes")
qui tabout disp_times quintileidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispTimes")

*Whom did you arrive with (household level or individual level?)
qui tabout disp_arrive_with comparisonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("Arrive_With")
qui tabout disp_arrive_with reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("Arrive_With")
qui tabout disp_arrive_with genidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("Arrive_With")
qui tabout disp_arrive_with quintileidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("Arrive_With")

*Want to move
qui tabout newmove_want comparisonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want genidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want quintileidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")

*When would you move
qui tabout newmove_want_time comparisonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time genidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time quintileidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")

*Have you gone back?
qui tabout tempreturn comparisonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("VisitedBack")
qui tabout tempreturn reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("VisitedBack")
qui tabout tempreturn genidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("VisitedBack")
qui tabout tempreturn quintileidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("VisitedBack")

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
