*Wave 2 IDP analysis -- Displacement profile

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

*Reason for arriving at location
*arrive reason
label define disp_arrive_reason 2 "Water access for livestock" 3 "Home / land access" 4 "Education / health access" 4 "Employment opportunities" 6 "Join family or known people" 7 "Knew people settled here" 8 "Humanitarian access (food and water)" 1000 "Other" , modify
ta disp_arrive_reason
recode disp_arrive_reason (6 7 = 6) (1000=.)
ta disp_arrive_reason

*Clean date of first displacement
gen year = substr(disp_date,1,4)
replace year = "" if year == "N/A"
gen month = substr(disp_date,6,2)
gen day = substr(disp_date,9,2)
egen displacementdate = concat (year month), p(-)
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
gen year = substr(disp_arrive_date,1,4)
replace year = "" if year == "N/A"
gen month = substr(disp_arrive_date,6,2)
gen day = substr(disp_arrive_date,9,2)
egen displacement_arrive_date = concat (year month), p(-)
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
assert duration_arrive_year >= 0 if inlist(comparisonidp, 1, 2, 3)
assert durationyear >= 0 if inlist(comparisonidp, 1, 2, 3)
br ind_profile disp_date if durationyear <=0
---
----
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


*Duration of displacement and duration at current camp (put next to location relative to original).

*Number of times the household was displaced

*Separation and reunification tables

*Reasons for separation

*Reasons for arriving at current location

*Trends in return intentions

*Pull and push factors for leavers

*Pull and push factors for stayers

/*
*Number of times displaced
qui tabout disp_times comparisonidp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Times_displ")
qui tabout disp_times comparisoncamp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Times_displ")
qui tabout disp_times hhh_gender using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Times_displ")
qui tabout disp_times quintiles_idp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Times_displ")

*Duration of displacement
qui tabout comparisonidp  using "${gsdOutput}/Raw_Fig38.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("duration_disp_year") f(4)
qui tabout comparisoncamp  using "${gsdOutput}/Raw_Fig38.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("duration_disp_year") f(4)
qui tabout hhh_gender using "${gsdOutput}/Raw_Fig38.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("duration_disp_year") f(4)
qui tabout quintiles_idp  using "${gsdOutput}/Raw_Fig38.xls", svy sum c(mean durationyear lb ub) npos(col) append h2("duration_disp_year") f(4)

*Whom did you arrive with (household level or individual level?)
qui tabout disp_arrive_with comparisonidp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Arrive_With")
qui tabout disp_arrive_with comparisoncamp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Arrive_With")
qui tabout disp_arrive_with hhh_gender using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Arrive_With")
qui tabout disp_arrive_with quintiles_idp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Arrive_With")

*Reason for coming here
qui tabout disp_arrive_reason comparisonidp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Arrive_reason")
qui tabout disp_arrive_reason comparisoncamp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Arrive_reason")
qui tabout disp_arrive_reason hhh_gender using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Arrive_reason")
qui tabout disp_arrive_reason quintiles_idp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Arrive_reason")

*Date of first displacement
qui tabout displacementdate comparisonidp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("DispDate")
qui tabout displacementdate comparisoncamp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("DispDate")
qui tabout displacementdate hhh_gender using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("DispDate")
qui tabout displacementdate quintiles_idp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("DispDate")

*Years of being in current camp
qui tabout comparisonidp  using "${gsdOutput}/Raw_Fig38.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("duration_arrive_year") f(4)
qui tabout comparisoncamp  using "${gsdOutput}/Raw_Fig38.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("duration_arrive_year") f(4)
qui tabout hhh_gender using "${gsdOutput}/Raw_Fig38.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("duration_arrive_year") f(4)
qui tabout quintiles_idp  using "${gsdOutput}/Raw_Fig38.xls", svy sum c(mean duration_arrive_year lb ub) npos(col) append h2("duration_arrive_year") f(4)

*Years of difference between the first arrival in camp and first date of displacement -- interpret cautiously, some values are negative as it's possible that your family member arrived at the camp first, later you got 'displaced' yourself and came to the camp. 
qui tabout displacement_difference comparisonidp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Difference_duration")
qui tabout displacement_difference comparisoncamp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Difference_duration")
qui tabout displacement_difference hhh_gender using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Difference_duration")
qui tabout displacement_difference quintiles_idp using "${gsdOutput}/Raw_Fig38.xls" if !missing(comparisonidp), append svy percent c(col lb ub) f(3)  npos(col) sebnone h1("Difference_duration")

************************
*HHM indicators
************************
use "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

*Place raw data into the excel figures file
foreach i of num 3 4 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
