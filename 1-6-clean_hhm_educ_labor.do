* Cleans important HH Member, Education, and Labour variables 

set more off
set seed 23081180 
set sortseed 11041155

use "${gsdData}/1-CleanInput/hhm.dta", clear

********************************************************************************
* 1. HH Member information
********************************************************************************
label define l_yesno 0 "No" 1 "Yes"
label values rhhm_ishead l_yesno

* change gender values to make it a dummy
label define hhm_gender 0 "Female" 1 "Male", replace
recode hhm_gender (2=0)

* Household Heads
* Check for <1 or >1 HH head per HH
bys strata block ea hh: egen n_hhh = sum(rhhm_ishead)
label var n_hhh "Number of reported hh heads in household"
assert n_hhh == 1
drop n_hhh

* Age groups
recode hhm_age (0/4 = 1 "0 - 4 Years") (5/9 = 2 "5 - 9 Years") (10/14 = 3 "10 - 14 Years") (15/19 = 4 "15 - 19 Years") (20/24 = 5 "20 - 24 Years") (25/29 = 6 "25 - 29 Years") (30/34 = 7 "30 - 34 Years") (35/39 = 8 "35 - 39 Years") (40/44 = 9 "40 - 44 Years") (45/49 = 10 "45 - 49 Years") (50/54 = 11 "50 - 54 Years") (55/59 = 12 "55 - 59 Years") (60/65 = 13 "60 - 64 Years") (65/69 = 14 "65 - 69 Years") (70/74 = 15 "70 - 74 Years") (75/79 = 16 "75 - 79 Years") (80/84 = 17 "80 - 84 Years") (85/100 = 18 "85+ Years"), generate(age_cat_narrow)
la var age_cat_narrow "Age category (5-year intervals)"
recode hhm_age (0/5 = 1 "Under 6 Years") (6/14 = 2 "6 - 14 Years") (15/64 = 3 "15 - 64 Years") (64/100 = 4 "Above 64 Years"), generate(age_cat_broad)
la var age_cat_broad "Age category (4 categories)"


levelsof age_cat_broad, local(level)
foreach l of local level {
	* Create dummy for whether hh member is of age catetegory
	bys strata ea block hh: gen age_cat_broad_`l' = (age_cat_broad==`l') if !missing(hhm_age)
}


********************************************************************************
* 2. Labour
********************************************************************************

* LF aggregates. 1) Identifies Working-age 2) Identifies age N/A 3) Identifies Outside Working-age by exclusion. Identifies sub-categories belonging to 1) as follows: 4) no information on activity 5) employed 6) unemployed 7) inactive, residual category identified by exclusion
gen status_7d=0 if inrange(hhm_age, 15, 64) 
replace status_7d=99 if hhm_age==.
replace status_7d=3 if status_7d==.
replace status_7d=98 if status_7d ==0 & ((emp_7d_act ==.a & inlist(emp_7d_temp,.a,.b,.z)) | (emp_7d_act ==.b & inlist(emp_7d_temp,.a,.b,.z)) | (emp_7d_act ==.z & inlist(emp_7d_temp,.a,.b,.z)) )
replace status_7d= (emp_7d_act == 1 | emp_7d_temp == 1) if status_7d ==0 & (!missing(emp_7d_act) | !missing(emp_7d_temp))
replace status_7d= 2 if status_7d==0 & ((emp_7d_act == 0 & emp_7d_temp!=1) | (emp_7d_temp == 0 & emp_7d_act!=1)) & hhm_job_search==1 & emp_available==1  
label define lstatus_7d 0 "Inactive" 1 "Employed" 2 "Unemployed"  3 "Outside Working Age" 98 "Working-age, no information on activity" 99 "Age N/A"
label values status_7d lstatus_7d
replace status_7d =1 if status_7d==0 & inlist(hhm_job_search_no,-1,10,11,14)
replace status_7d =2 if status_7d==0 & inlist(hhm_job_search_no,7,8,9,12)
tab status_7d, m
*Status_7d includes among the employed the following categories of inactive: "Already has a job" "Paid leave" "Unpaid leave" "Doing unpaid volunteer work"
*Status_7d includes among the unemployed the following categories of inactive: "Waiting for reply from employer" "Waiting for busy season" "Trying to start a business" "Low season/bad weather"


gen status_7d_ILO_comparable=0 if inrange(hhm_age, 15, 100) 
replace status_7d_ILO_comparable=99 if hhm_age==.
replace status_7d_ILO_comparable=3 if status_7d_ILO_comparable==.
replace status_7d_ILO_comparable=98 if status_7d_ILO_comparable ==0 & ((emp_7d_act ==.a & inlist(emp_7d_temp,.a,.b,.z)) | (emp_7d_act ==.b & inlist(emp_7d_temp,.a,.b,.z)) | (emp_7d_act ==.z & inlist(emp_7d_temp,.a,.b,.z)) )
replace status_7d_ILO_comparable= (emp_7d_act == 1 | emp_7d_temp == 1) if status_7d_ILO_comparable ==0 & (!missing(emp_7d_act) | !missing(emp_7d_temp))
replace status_7d_ILO_comparable= 2 if status_7d_ILO_comparable==0 & ((emp_7d_act == 0 & emp_7d_temp!=1) | (emp_7d_temp == 0 & emp_7d_act!=1)) & hhm_job_search==1 & emp_available==1  
label define lstatus_7d_ILO_comparable 0 "Inactive" 1 "Employed" 2 "Unemployed"  3 "Outside Working Age" 98 "Working-age, no information on activity" 99 "Age N/A"
label values status_7d_ILO_comparable lstatus_7d_ILO_comparable
tab status_7d_ILO_comparable, m

* B. Basic Checks
codebook isco isco01manager isco02prof isco03tech isco04clerical isco05services isco06skilled isco07craft isco08plant isco09elementary isco10forces benadir employ_hh business_own b_regoff b_mocai b_choc b_moc b_locgov emp_12m_appr emp_12m_farm emp_12m_paid emp_12m_busi emp_12m_help emp_12m_prim emp_ever_appr emp_ever_farm emp_ever_paid emp_ever_busi emp_ever_help emp_7d_act emp_7d_hours emp_7d_hours_kdk emp_7d_prim emp_7d_prim_sector emp_7d_inac emp_7d_hh emp_7d_hh_hrs emp_7d_temp emp_available emp_status hhm_job_search hhm_job_search_type hhm_job_search_no, compact
labellist isco isco01manager isco02prof isco03tech isco04clerical isco05services isco06skilled isco07craft isco08plant isco09elementary isco10forces benadir employ_hh business_own b_regoff b_mocai b_choc b_moc b_locgov emp_12m_appr emp_12m_farm emp_12m_paid emp_12m_busi emp_12m_help emp_12m_prim emp_ever_appr emp_ever_farm emp_ever_paid emp_ever_busi emp_ever_help emp_7d_act emp_7d_hours emp_7d_hours_kdk emp_7d_prim emp_7d_prim_sector emp_7d_inac emp_7d_hh emp_7d_hh_hrs emp_7d_temp emp_available emp_status hhm_job_search hhm_job_search_type hhm_job_search_no

* Check consistency: if not active in last 7 days, no income from work; this is due to different age constraints in questions (10, 15)
tab employ_hh if emp_7d_act==0 | emp_7d_temp==0 

* C. Overview Variables
* Working age members: 15 to 64
gen working_age = inrange(hhm_age, 15, 64) if !missing(hhm_age)
la val working_age l_yesno
la var working_age "Member is of working age (15-64)"

* Youth working age: 15 to 24
gen youth = inrange(hhm_age, 15, 24) if !missing(hhm_age)
la var youth "Youth of working age (15-24)"
la val youth l_yesno

* Dependents in HH: not of working age or disabled
* Not of working age
gen dependent = !inrange(hhm_age, 15, 64) if !missing(hhm_age)
* disability
replace dependent = 1 if emp_7d_inac==2
la var dependent "Member is dependent"

* Employment Status / Labour market participation
* Occupation 
* we want to add 'pursuing education' to this variable, so need to change code by + 1 to fit it in on the scale
gen occupation = isco + 1
* -96 is 'no profession', which we want to have at 0, so recode
recode occupation (-96 = 0)
* Add: Currently pursuing education but of no profession
replace occupation=1 if hhm_edu_current==1 & (occupation==0 | missing(occupation))
label def loccupation 0 "No profession" 1 "Pursuing education" 2 "Manager" 3 "Professional" 4 "Technician or associate professional" 5 "Clerical Support Worker" 6 "Services and sales Worker" 7 "Skilled agricultural and fishery worker" 8 "Craft and related trades worker" 9 "Plant and machine operator" 10 "Elementary occupations" 11 "Armed forces"
label val occupation loccupation
label var occupation "Main occupation of HH member"

* active in last week, defined working age members
gen active_7d =  (status_7d_ILO_comparable==1)
label var active_7d "In employment in past 7 days"

* active in last year
gen active_12m = .
* Inactive: if person didn't pursue any activity in the last 12 months
replace active_12m = 0 if (emp_12m_appr == 0 & emp_12m_farm == 0 & emp_12m_paid == 0 & emp_12m_busi == 0 & emp_12m_help == 0)
* active: person pursued any activity in last 12 months 
replace active_12m = 1 if (emp_12m_appr == 1 | emp_12m_farm == 1 | emp_12m_paid == 1 | emp_12m_busi == 1 | emp_12m_help == 1)
* if person pursued activity in last 7 days it follows she also pursued activity in last 12 months
replace active_12m = 1 if active_7d==1
* members w/no info on activity over the last 12 months, non-working age or missing age 
replace active_12m =98  if (active_12m==. & status_7d<=2) | status_7d==98
replace active_12m =3  if status_7d==3
replace active_12m =99  if status_7d==99
label def lactive_12m 0 "Not active" 1 "Active" 3 "Outside Working Age" 98 "Working-age, no information on activity" 99 "Age N/A"
label val active_12m lactive_12m
label var active_12m "Active in the last 12 months"

* active in last year (variable for the imputation code - before refinements)
gen active_7d_imp =  (emp_7d_act == 1 | emp_7d_temp == 1) if !missing(emp_7d_act) | !missing(emp_7d_temp)
label var active_7d_imp "In employment in past 7 days"
gen active_12m_imp = .
* Inactive: if person didn't pursue any activity in the last 12 months
replace active_12m_imp = 0 if (emp_12m_appr == 0 & emp_12m_farm == 0 & emp_12m_paid == 0 & emp_12m_busi == 0 & emp_12m_help == 0)
* active: person pursued any activity in last 12 months 
replace active_12m_imp = 1 if (emp_12m_appr == 1 | emp_12m_farm == 1 | emp_12m_paid == 1 | emp_12m_busi == 1 | emp_12m_help == 1)
* if person pursued activity in last 7 days it follows she also pursued activity in last 12 months
replace active_12m_imp = 1 if active_7d_imp==1
label var active_12m_imp "In employment in the last 12 months"
drop active_7d_imp

* active ever
gen active_ever = . 
* Inactive: if person didn't pursue any activity ever
replace active_ever = 0 if (emp_ever_appr==0 & emp_ever_farm==0 & emp_ever_paid==0 & emp_ever_busi==0 & emp_ever_help==0) 
* active: person pursued at least one activity ever
replace active_ever = 1 if (emp_ever_appr==1 | emp_ever_farm==1 | emp_ever_paid==1 | emp_ever_busi==1 | emp_ever_help==1) 
* if active in last 12 months/last 7 days, active ever is true
replace active_ever = 1 if active_7d==1
replace active_ever = 1 if active_12m==1
label var active_ever "In employment ever"

* Employment 
gen emp_12m =1 if active_12m == 1 
replace emp_12m=0 if active_12m==0
la var emp_12m "In employment, 12m"
la val emp_12m l_yesno
gen emp_7d=(status_7d_ILO_comparable==1)
replace emp_7d=. if (status_7d_ILO_comparable==3 | status_7d_ILO_comparable==98 | status_7d_ILO_comparable==99)
replace emp_7d=0 if (status_7d==0 | status_7d==2)
la var emp_7d "In employment, 7d"
la val emp_7d l_yesno

* Unemployment
gen unemp_12m =1 if active_12m==0 & hhm_job_search==1 & emp_available==1 
replace unemp_12m = 0 if emp_12m==1 
la var unemp_12m "Unemployed, 12m"
la val unemp_12m l_yesno
gen unemp_7d=(status_7d_ILO_comparable==2)
replace unemp_7d=. if (status_7d_ILO_comparable==3 | status_7d_ILO_comparable==98 | status_7d_ILO_comparable==99)
replace unemp_7d=0 if (status_7d_ILO_comparable==0 | status_7d_ILO_comparable==1)
la var unemp_7d "Unemployed, 7d"
la val unemp_7d l_yesno

* Labour Force
gen lfp_12m =0 if (active_12m==0 | active_12m==1) 
replace lfp_12m =1 if (emp_12m==1 | unemp_12m==1)
la val lfp_12m l_yesno
la var lfp_12m "Labor force participation, 12m"
gen lfp_7d=(status_7d_ILO_comparable==2 | status_7d_ILO_comparable==1 )
replace lfp_7d=. if (status_7d_ILO_comparable==3 | status_7d_ILO_comparable==98 | status_7d_ILO_comparable==99)
replace lfp_7d=0 if status_7d_ILO_comparable==0
la var lfp_7d "Labor force participation, 7d"
la val lfp_7d l_yesno

* Youth Unemployment 
foreach stub in 7d 12m {
	gen youth_unemp_`stub' = (unemp_`stub'==1) if inrange(hhm_age, 15, 24) & !missing(hhm_age, unemp_`stub')
	la var youth_unemp_`stub' "Youth unemployment, `stub'"
	la val youth_unemp_`stub' l_yesno
}


* Adult Unemployment 
foreach stub in 7d 12m {
	gen ad_unemp_`stub' = (unemp_`stub'==1) if inrange(hhm_age, 25, 64) & !missing(hhm_age, unemp_`stub')
	la var ad_unemp_`stub' "Adult unemployment, `stub'"
	la val ad_unemp_`stub' l_yesno
}
* Youth not in employment education or training 
gen neet = (youth_unemp_7d==1 | hhm_edu_current==0) if inrange(hhm_age, 15, 24)
la val neet l_yesno
la var neet "Youth not in Employnmet, Education, or Training"

* Long-Term Unemployment
gen unemp_lt = (unemp_12m==1) if !missing(unemp_12m)
la val unemp_lt l_yesno
la var unemp_lt "Long-term unemployment"


* Employment and Unemployment Detail
gen emp_7d_d = (working_age == 1) & (active_7d == 1) if !missing(working_age, active_7d)
replace emp_7d_d = 2 if inrange(emp_7d_hours, 0, 20) 
replace emp_7d_d = -1 if (unemp_12m==1) & !missing(unemp_12m)
replace emp_7d_d = -2 if (unemp_7d==1) & active_ever==0 & !missing(unemp_12m)
la var emp_7d_d "In employment, 7d, detail"
la def lemp_7d_d -2 "First-time Job Searcher" -1 "Long-term Unemployed" 0 "Unemployed" 1 "Employed, over 20 hours per week" 2 "Employed, 20 hours and less", replace
la val emp_7d_d lemp_7d_d

* Inactivity
foreach stub in 7d 12m {
	gen inac_`stub' = (emp_`stub'==0) & (unemp_`stub'==0) if !missing(working_age, emp_`stub')
	la var inac_`stub' "Inactive, `stub'"
	la val inac_`stub' l_yesno	
}

* Inactivity detail broad
label define linact_d 0 "In labor force" 1 "Inactive, other" 2 "Inactive, household work" 3 "Inactive, discourged", replace
foreach stub in 7d {
	gen inac_`stub'_d = (emp_`stub'==0) & (unemp_`stub'==0) if !missing(working_age, emp_`stub')
	replace inac_`stub'_d = 2 if hhm_job_search_no==6
	replace inac_`stub'_d = 3 if hhm_job_search_no==16
	la var inac_`stub'_d "Inactive reasons, `stub', broad"
	la val inac_`stub'_d linact_d 
}

* Inactivity detail narrow
recode hhm_job_search_no (-1 10 = .c) (0 = 1 "Insecurity/Conflict") (1=2 "Ill/Sick") (2=3 "Disabled") (3=4 "In School") (4=5 "Too young/too old") (6=6 "Household work") (15=7 "Husband does not allow") (16=8 "Discouraged") (9 = 9 "Trying to start a business") (5 = 10 "Retired") (7/8 11/14 = 11 "Other"), gen(inac_narrow) 
replace inac_narrow=. if inac_7d!=1
replace inac_narrow = 11 if inac_7d==1 & missing(inac_narrow)
la var inac_narrow "Inactive reasons, 7d, narrow"

* Sector Breakdown
recode emp_7d_prim_sector (11/14 = 1 "Agriculture") (21/25 = 2 "Manufacturing") (26/43 = 3 "Services"), gen(emp_sector_broad)
label variable emp_sector_broad  "Employment Sector: Agriculture, Manufacturing, Services"

* Hours of work, censored at 100
gen emp_hrs = emp_7d_hours
replace emp_hrs = 100 if emp_hrs>100 & !missing(emp_hrs)
la var emp_hrs "Actual Hours Worked in past Week"

* Hours Brackets
gen emp_hrs_cat = .
replace emp_hrs_cat = 0 if unemp_7d==1
replace emp_hrs_cat = 1 if inrange(emp_hrs, 0, 10) 
replace emp_hrs_cat = 2 if inrange(emp_hrs, 11, 20)
replace emp_hrs_cat = 3 if inrange(emp_hrs, 21, 30)
replace emp_hrs_cat = 4 if inrange(emp_hrs, 31, 40)
replace emp_hrs_cat = 5 if inrange(emp_hrs, 41, 50)
replace emp_hrs_cat = 6 if inrange(emp_hrs, 51, 60)
replace emp_hrs_cat = 7 if inrange(emp_hrs, 61, 70)
replace emp_hrs_cat = 8 if inrange(emp_hrs, 71, 80)
replace emp_hrs_cat = 9 if inrange(emp_hrs, 81, 90)
replace emp_hrs_cat = 10 if inrange(emp_hrs, 91, 100)

label define emp_hrs_cat 0 "Unemployed" 1 "0-10" 2 "11-20" 3 "21-30" 4 "31-40" 5 "41-50" 6 "51-60" 7 "61-70" 8 "71-80" 9 "81-90" 10 "91-100", replace
label values emp_hrs_cat emp_hrs_cat

* Employment and Education Status (7d) - excluding "not of working age"
label define llabor_status 0 "Not of working age" 1 "Education Only" 2 "Education and Employment" 3 "Employment Only" 4 "Unemployed" 5 "Inactive, Household work" 6 "Inactive, Discouraged" 7 "Inactive, Other" 98 "Working-age, no info on Activity/Education" 99 "Age N/A", replace
gen labor_status_narrow_7d = .
*Education only: Inactive and currently enrolled in education
replace labor_status_narrow_7d = 1 if (status_7d==0 | status_7d==2) & (hhm_edu_current == 1)
*Education and employment: Active and currently enrolled in education
replace labor_status_narrow_7d = 2 if (status_7d==1) & (hhm_edu_current == 1)
*Employment only: Active and not enrolled in education
replace labor_status_narrow_7d = 3 if (status_7d==1) & (hhm_edu_current == 0)
*Unemployed: Not working, not currently enrolled in education, and looking for job
replace labor_status_narrow_7d = 4 if (status_7d==2 & hhm_edu_current == 0) | (labor_status_narrow_7d==1 & hhm_edu_current==1 & hhm_job_search==1 & emp_available==1)
*Inactive Other: Inactive over past year and not currently enrolled in education, and not looking for job
replace labor_status_narrow_7d = 7 if (status_7d==0)
*Inactive Discouraged: inactive, stopped looking for work because of bad outlook --> overwrite into inactive category
replace labor_status_narrow_7d = 6 if labor_status_narrow_7d==7 & hhm_job_search_no==16
*Inactive household work --> overwrite inactive other category where applicable
replace labor_status_narrow_7d = 5 if labor_status_narrow_7d==7 & hhm_job_search_no==6
label var labor_status_narrow_7d "Employment & education status, 7d, narrow definition"
label values labor_status_narrow_7d llabor_status
*Not of working age: less than 15 years old or greater than 64 years old
replace labor_status_narrow_7d = 0 if status_7d==3
*Age N/A and working-age, but no info on activity 
replace labor_status_narrow_7d =98 if status_7d==98 | (hhm_edu_current==.a | hhm_edu_current==.b)
replace labor_status_narrow_7d =99 if status_7d==99 

* Employment and Education Status (12m) - excluding "not of working age"
label define llabor_status 0 "Not of working age" 1 "Education Only" 2 "Education and Employment" 3 "Employment Only" 4 "Unemployed" 5 "Inactive, Household work" 6 "Inactive, Discouraged" 7 "Inactive, Other" 98 "Working-age, no info on Activity/Education" 99 "Age N/A", replace
gen labor_status_narrow_12m = .
*Not of working age: less than 15 years old or greater than 64 years old
replace labor_status_narrow_12m = 0 if status_7d==3
*Education only: Inactive over past year and currently enrolled in education
replace labor_status_narrow_12m = 1 if (active_12m == 0) & (hhm_edu_current == 1)
*Education and employment: Active over past year and currently enrolled in education
replace labor_status_narrow_12m = 2 if (active_12m == 1) & (hhm_edu_current == 1)
*employment only: Active over past year and not enrolled in education
replace labor_status_narrow_12m = 3 if (active_12m == 1) & (hhm_edu_current == 0)
*Unemployed: Not working, not currently enrolled in education, and looking for job
replace labor_status_narrow_12m = 4 if (unemp_12m == 1 & hhm_edu_current == 0) | (active_12m==0 & hhm_edu_current==1 & hhm_job_search==1 & emp_available==1)
*Inactive Other: Inactive over past year and not currently enrolled in education, and not looking for job
replace labor_status_narrow_12m = 7 if (active_12m == 0) & labor_status_narrow_12m>=.
* Inactive Discouraged: inactive, stopped looking for work because of bad outlook --> overwrite into inactive category
replace labor_status_narrow_12m = 6 if labor_status_narrow_12m==7 & hhm_job_search_no==16
* Inactive household work --> overwrite inactive other category where applicable
replace labor_status_narrow_12m = 5 if labor_status_narrow_12m==7 & hhm_job_search_no==6
*Age N/A and working-age, but no info on activity 
replace labor_status_narrow_12m =98 if active_12m==98 | (hhm_edu_current==.a | hhm_edu_current==.b)
replace labor_status_narrow_12m =99 if active_12m==99 
label var labor_status_narrow_12m "Employment & education status, 12m, narrow definition"
label values labor_status_narrow_12m llabor_status


* Employment and Education Status (Ever) - excluding "not of working age"
label define llabor_status 0 "Not of working age" 1 "Education Only" 2 "Education and Employment" 3 "Employment Only" 4 "Unemployed" 5 "Inactive, Household work" 6 "Inactive, Discouraged" 7 "Inactive, Other" 98 "Working-age, no info on Activity/Education" 99 "Age N/A", replace
gen labor_status_narrow_ever = .
*Not of working age: less than 15 years old or greater than 64 years old
*replace labor_status_narrow_ever = 0 if working_age == 0
*Education only: Inactive over past year and currently enrolled in education
replace labor_status_narrow_ever = 1 if (working_age == 1) & (active_ever == 0) & (hhm_edu_current == 1)
*Education and employment: Active over past year and currently enrolled in education
replace labor_status_narrow_ever = 2 if (working_age == 1) & (active_ever == 1) & (hhm_edu_current == 1)
*employment only: Active over past year and not enrolled in education
replace labor_status_narrow_ever = 3 if (working_age == 1) & (active_ever == 1) & (hhm_edu_current == 0)
*Unemployed: Not working, not currently enrolled in education, and looking for job
replace labor_status_narrow_ever = 4 if (working_age == 1) & (active_ever == 0) & (hhm_edu_current == 0) & (hhm_job_search == 1) & (emp_available==1)
*Inactive Other: Inactive over past year and not currently enrolled in education, and not looking for job
replace labor_status_narrow_ever = 7 if (working_age == 1) & (active_ever == 0) & (hhm_edu_current == 0) & (hhm_job_search == 0)
* Inactive Discouraged: inactive, stopped looking for work because of bad outlook --> overwrite into inactive category
replace labor_status_narrow_ever = 6 if labor_status_narrow_ever==7 & hhm_job_search_no==16
* Inactive household work --> overwrite inactive other category where applicable
replace labor_status_narrow_ever = 5 if labor_status_narrow_ever==7 & hhm_job_search_no==6
label var labor_status_narrow_ever "Employment & education status, ever, narrow definition"
label values labor_status_narrow_ever llabor_status


* Define broader categories for labour status
foreach stub in 7d 12m ever {
	recode labor_status_narrow_`stub' (1 = 1 "Education Only") (2 = 2 "Education and Employment") (3 = 3 "Employment Only") (4 = 4 "Unemployed, looking for work") (5/7 = 5 "Inactive"), gen(labor_status_broad_`stub')
	label var labor_status_broad_`stub' "Employment & education, `stub', broad definition"
}

*Dependency ratio (international definition)
bys strata ea block hh: egen pre_not_lfp=count(active_12m) if active_12m==3 
bys strata ea block hh: egen not_lfp=max(pre_not_lfp) 
bys strata ea block hh: egen pre_in_lfp=count(active_12m) if active_12m==0 | active_12m==1 | active_12m==98
bys strata ea block hh: egen in_lfp=max(pre_in_lfp) 
replace in_lfp=0 if in_lfp==. & !missing(hhm_age)
replace not_lfp=0 if not_lfp==. & !missing(hhm_age)
gen pre_dependency_ratio=not_lfp/in_lfp
bys strata ea block hh: egen dependency_ratio=max(pre_dependency_ratio)
replace dependency_ratio=. if strata==301 & ea==244 & block==. & hh==13
drop pre_not_lfp not_lfp pre_in_lfp in_lfp

*Age Dependency ratio (World Bank Definition)
bys strata ea block hh: egen no_dep= count(age_cat_broad) if inlist(age_cat_broad,1,2,4)
bys strata ea block hh: egen no_dependent = mean(no_dep)
bys strata ea block hh: egen no_w_age = count(age_cat_broad) if inlist(age_cat_broad,3)
bys strata ea block hh: egen no_working_age = mean(no_w_age)
replace no_dependent=0 if no_dependent==.
replace no_working_age=0 if no_working_age==.
gen age_dependency_ratio=no_dependent/no_working_age

*Number of children, adults, old-age
bys strata ea block hh: egen no_chi= count(age_cat_broad) if inlist(age_cat_broad,1,2)
bys strata ea block hh: egen no_children = mean(no_chi)
replace no_children=0 if no_children==.

bys strata ea block hh: egen no_adu= count(age_cat_broad) if inlist(age_cat_broad,3)
bys strata ea block hh: egen no_adults = mean(no_adu)
replace no_adults=0 if no_adults==.

bys strata ea block hh: egen no_old= count(age_cat_broad) if inlist(age_cat_broad,4)
bys strata ea block hh: egen no_old_age = mean(no_old)
replace no_old_age=0 if no_old_age==.

********************************************************************************
* 3. Education 
********************************************************************************

* Basic Checks
codebook hhm_read hhm_write hhm_edu_current hhm_edu_ever hhm_edu_level hhm_edu_level_other hhm_edu_years hhm_edu_k_current hhm_edu_k_ever hhm_edu_k_years absent_duration absent_reason absent_specify, compact
labellist hhm_read hhm_write hhm_edu_current hhm_edu_ever hhm_edu_level hhm_edu_level_other hhm_edu_years hhm_edu_k_current hhm_edu_k_ever hhm_edu_k_years absent_duration absent_reason absent_specify

* Replace outliers in years of attendance: cutoff at 20 years of education
replace hhm_edu_k_years=.c if hhm_edu_k_years>20
* Explore overlap of Koranic and other schools
tab hhm_edu_k_ever hhm_edu_ever

* Generate Overview Variables
* Literacy 

gen literacy = (hhm_read == 1 & hhm_write == 1) if !missing(hhm_write, hhm_read)
label var literacy "Literacy"
la def lliteracy 0 "Illiterate" 1 "Literate", replace
la val literacy lliteracy

* Primary School Age (6, 13)
gen pschool_age = inrange(hhm_age, 6, 13) if !missing(hhm_age)
la var pschool_age "Aged 6 to 13"
* Secondary School Age (14, 17)
gen sschool_age = inrange(hhm_age, 14, 17) if !missing(hhm_age)
la var sschool_age "Aged 14 to 17"

* Education: young generation vs older generations
gen gen_young = 1 if inrange(hhm_age, 15, 29) & !missing(hhm_age)
replace gen_young = 0 if hhm_age>29  & !missing(hhm_age)
la var gen_young "Indicator: Younger generation vs older generations"
la def lgen_young 0 "Aged 30 and older" 1 "Aged 15 to 29", replace
la val gen_young lgen_young

* Enrollent Status
gen edu_status = .
* Not of education age: younger than 6 
replace edu_status = 0 if (hhm_age < 6)
* Currently enrolled, 6 and older
replace edu_status = 1 if (hhm_edu_current == 1) & (hhm_age >= 6)
* previously enrolled, school age or older
replace edu_status = 2 if (hhm_edu_ever == 1) & (hhm_age >= 6) & (hhm_edu_current == 0)
* never enrolled, but of school age or older 
replace edu_status = 3 if (hhm_edu_ever == 0) & (hhm_age >= 6) & (hhm_edu_current == 0)
label define ledu_status  0 "Not of education age" 1 "Currently enrolled" 2 "Previously enrolled" 3 "Never enrolled", replace
label values edu_status ledu_status
label variable edu_status "Education status"

* Education level groups
recode hhm_edu_level (1/7 = 1 "Incomplete Primary") (8/11 = 2 "Complete Primary/Incomplete Secondary")  (12=4 "Complete Secondary") (13/15 17= 5 "University") (16 1000 = 6 "Other"), gen(edu_level_broad)
label define edu_level_broad 0 "No education", add
replace edu_level_broad = 0 if hhm_edu_ever==0 & hhm_age>=6
la var edu_level_broad "Level of Education Group"


********************************************************************************
* Renaming, Labelling, and Saving
********************************************************************************
la var hhm_gender "Gender"
ren hhm_gender gender
la var hhm_age "Age"
ren hhm_age age
la var rhhm_ishead "Is Household Head"
ren rhhm_ishead ishead
bys strata ea block hh: gen hhmid=_n
bys strata ea block hh: egen hhsize=max(hhmid)
drop member_id  
label var hhmid "Household member ID"
label var hhsize "Household size"
order zone team strata ea block hh enum hhmid
order hhsize ishead gender age, after(hhmid)
order literacy pschool_age sschool_age gen_young edu_status edu_level_broad, after(age)
order age_cat_narrow-labor_status_broad_ever, after(edu_level_broad)
order age_cat_narrow age_cat_broad working_age pschool_age sschool_age youth occupation , after(age)
order gen_young dependent literacy, after(youth)
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", nogen keepusing(weight_adj) assert(match)
order weight_adj, after(hh)
drop pre_dependency_ratio 
order zone team strata ea block hh hhmid weight_adj enum
label var status_7d "Stuatus, 7d"
label var status_7d_ILO_comparable "Stuatus ILO comparable, 7d"
label var emp_hrs_cat "No. of Hrs Employed"
label var dependency_ratio "Dependency Ratio"
label var age_dependency_ratio "Age Dependency Ratio"
label var no_children "Number of children in the household" 
label var no_adults "Number of adults in the household"
label var no_old_age "Number of old-age people in the household"
order dependency_ratio, after(hhsize)
preserve
svyset ea [pweight=weight], strata(strata)
drop top2_illnesses age_cat_broad_* 
save "${gsdData}/1-CleanTemp/hhm.dta", replace
drop active_12m_imp
save "${gsdData}/1-CleanTemp/hhm_poverty_profile.dta", replace
drop no_dep no_dependent no_w_age no_working_age age_dependency_ratio no_chi no_children no_adu no_adults no_old no_old_age
save "${gsdData}/1-CleanOutput/hhm.dta", replace

*prepare household member dataset for imputation
use "${gsdData}/1-CleanOutput/hhm.dta", clear
gen nchild = age<15 if !missing(age)
gen nsenior = age>64 if !missing(age)
gen hhsex = gender if ishead
gen hhedu = hhm_edu_ever if ishead
merge 1:1 strata ea block hh hhmid using "${gsdData}/1-CleanTemp/hhm.dta", nogen assert(match) keepusing(active_12m_imp)
gen hhempl=active_12m_imp if ishead
collapse (sum) nchild nsenior (min) hhsex hhempl hhedu (count) hhsize = hhmid, by(strata ea block hh)
gen pchild = nchild / hhsize
gen psenior = nsenior / hhsize
drop nchild nsenior
save "${gsdData}/1-CleanTemp/hhm-hh.dta", replace


********************************************************************************
* Generate Aggregate Variables, and collapse to HH level, save 
********************************************************************************
restore
* Generate HH head variables
gen hhh_gender = gender if ishead==1
gen hhh_age = age if ishead==1
replace hhh_age=. if hhh_age < 16
gen hhh_edu = edu_level_broad if ishead==1 & !mi(hhh_age)
recode lfp_7d emp_7d (.=0) 

* School enrollment dummy
gen enrol = edu_status==1 if inrange(age, 6, 17)
gen enrol_p =  edu_status==1 if inrange(age, 6, 13)
gen enrol_s =  edu_status==1 if inrange(age, 14, 17)

* apply labels
la val hhh_gender hhm_gender
la var hhh_gender "Gender of Household Head"
la val hhh_edu edu_level_broad
la var hhh_edu "Education Level of Household Head"
la var hhh_age "Age of Household Head"

local collapselist_min "hhh_gender hhh_age hhh_edu"

*Save labels - min
foreach var of local collapselist_min {
	*Save variable labels
	local l`var' : variable label `var'
	if `"`l`var''"' == "" {
		local l`var' "`var'"
	}
	*Save value labels
	local vl`var': value label `var'
	if `"`vl`var''"' == "" {
		local vl`var' "` '"
	}
}



* Collapse without weights since "count" command will create sum of weights in household; weights come in when merging this with hh.dta
collapse (mean) penrol=enrol penrol_p=enrol_p penrol_s=enrol_s pgender=gender pworking_age=working_age pdependent=dependent dependency_ratio age_dependency_ratio no_children no_adults no_old_age pliteracy=literacy page_cat_broad_1=age_cat_broad_1 page_cat_broad_2=age_cat_broad_2 page_cat_broad_3=age_cat_broad_3 page_cat_broad_4=age_cat_broad_4 (count) hhsize=hhmid (min) hhh_gender hhh_age hhh_edu (max) lfp_7d_hh=lfp_7d emp_7d_hh=emp_7d, by(strata ea block hh)


*Reapply labels - min
foreach var of local collapselist_min  {
	*Reapply variable labels
	label variable `var' "`l`var''"
	*Reapply value labels
	label value `var' `vl`var''
}


* New Labels 
la var hhsize "Number of members in HH"
la var pgender "Share of males in HH"
la var pworking_age "Proportion of working age members in HH"
la var pdependent "Proportion of dependents in HH"
la var dependency_ratio "Dependency ratio (Intl definition)"
la var pliteracy "Proportion literate in HH" 
la var penrol "Proportion enrolled at school age (6,17)"
la var penrol_p "Proportion enrolled at primary school age (6,13)"
la var penrol_s "Proportion enrolled at secondary school age (14,17)"
la var lfp_7d_hh "Household has at least one economically active member"
la var emp_7d_hh "Household has at least one employed member"
la var age_dependency_ratio "Age dependency ratio (no of dependents/no of adults (age 15-64))"
la var no_children "Number of children (age 0-14) in the household"
la var no_adults "Number of adults (age 15-64) in the household"
la var no_old_age "Number of elders (age 64+) in the household"

save "${gsdData}/1-CleanTemp/hh_hhm.dta", replace


