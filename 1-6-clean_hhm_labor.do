label define lyesno 0 "No" 1 "Yes", replace

* Working age members: 15 to 64
gen working_age = inrange(hhm_age, 15, 64) if !missing(hhm_age)
la val working_age l_yesno
la var working_age "Member is of working age (15-64)"

* Youth working age: 15 to 24
gen youth = inrange(hhm_age, 15, 24) if !missing(hhm_age)
la var youth "Youth of working age (15-24)"
la val youth l_yesno

* Adult working age: 25 to 64
gen adult = inrange(hhm_age, 15, 24) if !missing(hhm_age)
la var adult "Adults of working age (25-64)"
la val youth l_yesno

* Employment and unemployment for hh members ages 15 to 65
label define lemp 0 "No" 1 "Yes" .d "Outside of labor force" .f "Not of working age", replace
cap drop emp_7d unemp_7d
gen emp_7d = (emp_7d_busi==1 | emp_7d_help==1 | emp_7d_farm==7 | emp_7d_appr==1 | emp_7d_paid==1 | emp_7d_temp==1) if inrange(hhm_age, 15, 64)
gen unemp_7d = hhm_job_search==1 & inlist(hhm_available, 1, 2, 3) if inrange(hhm_age, 15, 64)
replace emp_7d = .d if unemp_7d==0 & emp_7d==0
replace unemp_7d = .d if emp_7d==.d
recode emp_7d unemp_7d (.=.f)
label values emp_7d lemp
label values unemp_7d lemp
label emp_7d "Employed, past 7 days"
label unemp_7d "Unemployed, past 7 days"

* Employment and unemployment in past 12 months and ever
gen emp_12m = emp_7d
replace emp_12m = 1 if emp_12m_active==1
label values emp_12m lemp
label emp_12m "Employed, past 12 months"
gen emp_ever = emp_12m
replace emp_ever = 1 if emp_ever_active==1
label values emp_ever lemp
label emp_ever "Employed, ever"

* Labor force participation
gen lfp_7d = (emp_7d==1 | unemp_7d==1) if inrange(hhm_age, 15, 64)
la val lfp_7d lyesno
label lfp_7d "Labor force participation, past 7 days"

* LFP, employment, unemployment - youth and adult members
foreach v in lfp_7d emp_7d unemp_7d {
	gen `v'_youth = `v' if youth==1
	gen `v'_adult = `v' if adult==1
}
label values emp_7d_youth lemp
label values emp_7d_adult lemp
label values unemp_7d_youth lemp
label values unemp_7d_adult lemp
label values lfp_7d_youth lyesno 
label values lfp_7d_adult lyesno
label lfp_7d_youth "Labor force participation, 7 days, youth (15-24)"
label lfp_7d_adult "Labor force participation, 7 days, adults (25-64)"
label emp_7d_youth "Employed, 7 days, youth (15-24)"
label emp_7d_adult "Employed, 7 days, adult (25-64)"
label unemp_7d_youth "Unemployed, 7 days, youth (15-24)"
label unemp_7d_adult "Unemployed, 7 days, adult (25-64)"

* Underemployment: works but wants to work more hours
gen uemp_7d = 0 if emp_7d==1
replace uemp_7d = 1 if uemp_want==1
label values uemp_7d lyesno 
label uemp_7d "Underemployed"

* Hours of work, censored at 100
gen emp_hrs = emp_7d_hours
recode emp_hrs (-1.00e+09=.)
replace emp_hrs = 100 if emp_hrs>100 & !missing(emp_hrs)
la var emp_hrs "Actual Hours Worked in past Week"
* Hours by category
gen emp_hrs_cat = ceil(emp_hrs/10)
recode emp_hrs_cat (0=1) 
label define lemp_hrs_cat 1 "1-10" 2 "11-20" 3 "21-30" 4 "31-40" 5 "41-50" 6 "51-60" 7 "61-70" 8 "71-80" 9 "81-90" 10 "91-100", replace
label values emp_hrs_cat lemp_hrs_cat
