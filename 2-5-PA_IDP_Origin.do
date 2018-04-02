*Wave 2 IDP analysis -- Displacement profile

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

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

*Reason for arriving at location
*arrive reason
label define disp_arrive_reason 2 "Water access for livestock" 3 "Home / land access" 4 "Education / health access" 4 "Employment opportunities" 6 "Join family or known people" 7 "Knew people settled here" 8 "Humanitarian access (food and water)" 1000 "Other" , modify
ta disp_arrive_reason
recode disp_arrive_reason (6 7 = 6) (1000=.)
ta disp_arrive_reason
*Number of times displaced
recode disp_site (1=1 "Once") (2=2 "Twice") (3=3 "Thrice") (4/10 = 4 "4 or more times"), gen(disp_times) lab(ldisp_times)

*Clean date of first displacement
gen year = substr(disp_date,1,4) if !strpos(disp_date, ".z")
gen month = substr(disp_date,6,2) if !strpos(disp_date, ".z")
gen day = substr(disp_date,9,2)
egen displacementdate = concat (year month) if !strpos(disp_date, ".z") & !missing(month) & !missing(year), p(-) 
label var displacementdate "Date of displacement (month wise)"
*Duration of displacement
*Survey date - use Nov 2017 as approx survey date (Survey ran Nov - Dec 2017, check with Gonzalo)
gen month2 = "11"
gen year2 = 2017
egen surveydate = concat(year2 month2), p(-)
*HRF to SIF
gen sdate = monthly(surveydate, "YM")
gen ddate = monthly(displacementdate, "YM")
*Duration
gen dduration = sdate - ddate
*remove outliers
*hist dduration
replace dduration =. if dduration > 120
*put in year format
gen durationyear = dduration/12
*drop unnecessary variables
drop year month day

*Do the same for date when you arrived at the current location
gen year = substr(disp_arrive_date,1,4) if !strpos(disp_arrive_date, ".z")
gen month = substr(disp_arrive_date,6,2) if !strpos(disp_arrive_date, ".z")
gen day = substr(disp_arrive_date,9,2)
egen displacement_arrive_date = concat (year month) if !strpos(disp_arrive_date, ".z") & !missing(month) & !missing(year), p(-)
ta displacement_arrive_date
label var displacement_arrive_date "Date of arriving at current location (month wise)"
*Duration of displacement
*HRF to SIF
gen s_arrive_date = monthly(surveydate, "YM")
gen d_arrive_date = monthly(displacement_arrive_date, "YM")
*Duration
gen d_arrive_duration = s_arrive_date - d_arrive_date
*remove outliers
replace d_arrive_duration =. if d_arrive_duration > 60
*one observation gives a negative duration since survey and displacement happened in 2017-07 but we approximate survey date as 2017-06.
replace d_arrive_duration = . if d_arrive_duration <0
*put in year format
gen duration_arrive_year = d_arrive_duration/12
*Check that durations are not negative (some are since date of displ is in Dec. 2017 or Jan.2018.)
*assert duration_arrive_year >= 0 if inlist(comparisonidp, 1, 2, 3)
*assert durationyear >= 0 if inlist(comparisonidp, 1, 2, 3)
*br ind_profile disp_date if durationyear <=0

*Reason for displacement-concise (including reasonidp for sake of excel table constuction ease; no need to graph it)
qui tabout disp_reason_concise comparisonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) replace h1("ReasonShort") f(4) 
*qui tabout disp_reason_concise urbanrural using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
*qui tabout disp_reason_concise t using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise quintileidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 
qui tabout disp_reason_concise reasonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonShort") f(4) 

*Reason for displacement-detailed (including reasonidp for sake of excel table constuction ease; no need to graph it)
qui tabout disp_reason comparisonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
*qui tabout disp_reason urbanrural using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
*qui tabout disp_reason t using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
qui tabout disp_reason genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
qui tabout disp_reason quintileidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 
qui tabout disp_reason reasonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonLong") f(4) 

*Reason for coming here
qui tabout disp_arrive_reason comparisonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
*qui tabout disp_arrive_reason urbanrural using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
*qui tabout disp_arrive_reason t using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason genidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason quintileidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 
qui tabout disp_arrive_reason reasonidp using "${gsdOutput}/Raw_Fig3.xls", svy percent c(col lb ub) npos(col) append h1("ReasonArrive") f(4) 

*Location now
qui tabout reg_pess comparisonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) replace h1("LocNow") f(4) 
*qui tabout reg_pess urbanrural using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
*qui tabout reg_pess t using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess genidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess quintileidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 
qui tabout reg_pess reasonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocNow") f(4) 

*Location before -- relative to current region
qui tabout disp_from_new comparisonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
*qui tabout disp_from_new urbanrural using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
*qui tabout disp_from_new t using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new genidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new quintileidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 
qui tabout disp_from_new reasonidp using "${gsdOutput}/Raw_Fig4.xls", svy percent c(col lb ub) npos(col) append h1("LocRelative") f(4) 

*When was the household first displaced -- overlay with ACLED data and drought event data?! (put next to reasons)
qui tabout displacementdate comparisonidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone replace h1("DispDate")
*qui tabout displacementdate genidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispDate")
*qui tabout displacementdate quintileidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispDate")
*qui tabout displacementdate reasonidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispDate")

*When did the household first arrive at the current location?
qui tabout displacement_arrive_date comparisonidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveDate")
*qui tabout displacement_arrive_date genidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveDate")
*qui tabout displacement_arrive_date quintileidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveDate")
*qui tabout displacement_arrive_date reasonidp using "${gsdOutput}/Raw_Fig5.xls" , svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ArriveDate")

*Number of times the household was displaced
qui tabout disp_times comparisonidp using "${gsdOutput}/Raw_Fig5.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispTimes")
qui tabout disp_times genidp using "${gsdOutput}/Raw_Fig5.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispTimes")
qui tabout disp_times quintileidp using "${gsdOutput}/Raw_Fig5.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispTimes")
qui tabout disp_times reasonidp using "${gsdOutput}/Raw_Fig5.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("DispTimes")

*Whom did you arrive with (household level or individual level?)
qui tabout disp_arrive_with comparisonidp using "${gsdOutput}/Raw_Fig5.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("Arrive_With")
qui tabout disp_arrive_with genidp using "${gsdOutput}/Raw_Fig5.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("Arrive_With")
qui tabout disp_arrive_with quintileidp using "${gsdOutput}/Raw_Fig5.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("Arrive_With")
qui tabout disp_arrive_with reasonidp using "${gsdOutput}/Raw_Fig5.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("Arrive_With")

*Want to move
qui tabout newmove_want comparisonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone replace h1("ReturnIntention")
qui tabout newmove_want genidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want quintileidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")
qui tabout newmove_want reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("ReturnIntention")

*When would you move
qui tabout newmove_want_time comparisonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time genidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time quintileidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")
qui tabout newmove_want_time reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("TimeReturn")

*Have you gone back?
qui tabout tempreturn comparisonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("VisitedBack")
qui tabout tempreturn genidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("VisitedBack")
qui tabout tempreturn quintileidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("VisitedBack")
qui tabout tempreturn reasonidp using "${gsdOutput}/Raw_Fig6.xls", svy percent c(col lb ub) f(4) npos(col) sebnone append h1("VisitedBack")

************************
*HHM indicators
************************
use "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

*Place raw data into the excel figures file
foreach i of num 3 4 5 6 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
