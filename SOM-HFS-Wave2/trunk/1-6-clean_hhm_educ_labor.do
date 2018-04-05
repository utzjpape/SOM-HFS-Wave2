* Cleans important HH Member, Education, and Labour variables 

set more off
set seed 23081180 
set sortseed 11041155

********************************************************************
*Open the file and prepare useful indicators
********************************************************************
use "${gsdData}/1-CleanInput/hhm.dta", clear
sort strata ea block hh hhm_id
isid strata ea block hh hhm_id
*Active in last year (variable for the imputation code - before refinements)
gen active_7d_imp =  (emp_7d_act == 1 | emp_7d_temp == 1) if !missing(emp_7d_act) | !missing(emp_7d_temp)
label var active_7d_imp "In employment in past 7 days"
*If person pursued activity in last 7 days it follows she also pursued activity in last 12 months
gen active_12m_imp=.
replace active_12m_imp = 1 if active_7d_imp==1
label var active_12m_imp "In employment in the last 12 months"

drop active_7d_imp


********************************************************************
*HH Member information
********************************************************************
gen hhhead= (hhm_relation==1)
label define l_yesno 0 "No" 1 "Yes"
label values hhhead l_yesno


*Change gender values to make it a dummy
label define hhm_gender 0 "Female" 1 "Male", replace
recode hhm_gender (2=0)
* Household Heads
* Check for <1 or >1 HH head per HH
bys strata ea block hh: egen n_hhh = sum(hhhead)
label var n_hhh "Number of reported hh heads in household"
assert n_hhh == 1
assert !mi(n_hhh)
drop n_hhh

*Age groups
recode hhm_age (0/4 = 1 "0 - 4 Years") (5/9 = 2 "5 - 9 Years") (10/14 = 3 "10 - 14 Years") (15/19 = 4 "15 - 19 Years") (20/24 = 5 "20 - 24 Years") (25/29 = 6 "25 - 29 Years") (30/34 = 7 "30 - 34 Years") (35/39 = 8 "35 - 39 Years") (40/44 = 9 "40 - 44 Years") (45/49 = 10 "45 - 49 Years") (50/54 = 11 "50 - 54 Years") (55/59 = 12 "55 - 59 Years") (60/65 = 13 "60 - 64 Years") (65/69 = 14 "65 - 69 Years") (70/74 = 15 "70 - 74 Years") (75/79 = 16 "75 - 79 Years") (80/84 = 17 "80 - 84 Years") (85/100 = 18 "85+ Years"), generate(age_cat_narrow)
la var age_cat_narrow "Age category (5-year intervals)"
recode hhm_age (0/5 = 1 "Under 6 Years") (6/14 = 2 "6 - 14 Years") (15/64 = 3 "15 - 64 Years") (64/100 = 4 "Above 64 Years"), generate(age_cat_broad)
la var age_cat_broad "Age category (4 categories)"
levelsof age_cat_broad, local(level)
foreach l of local level {
	* Create dummy for whether hh member is of age catetegory
	bys strata ea block hh: gen age_cat_broad_`l' = (age_cat_broad==`l') if !missing(hhm_age)
}


********************************************************************
*Education 
********************************************************************
*Explore overlap of Koranic and other schools
tab hhm_edu_ever

*Generate Overview Variables
*Literacy 
gen literacy = (hhm_read == 1 & hhm_write == 1) if !missing(hhm_write, hhm_read)
label var literacy "Literacy"
la def lliteracy 0 "Illiterate" 1 "Literate", replace
la val literacy lliteracy
*Primary School Age (6, 13)
gen pschool_age = inrange(hhm_age, 6, 13) if !missing(hhm_age)
la var pschool_age "Aged 6 to 13"
*Secondary School Age (14, 17)
gen sschool_age = inrange(hhm_age, 14, 17) if !missing(hhm_age)
la var sschool_age "Aged 14 to 17"
*Education: young generation vs older generations
gen gen_young = 1 if inrange(hhm_age, 15, 29) & !missing(hhm_age)
replace gen_young = 0 if hhm_age>29  & !missing(hhm_age)
la var gen_young "Indicator: Younger generation vs older generations"
la def lgen_young 0 "Aged 30 and older" 1 "Aged 15 to 29", replace
la val gen_young lgen_young
*Enrollent Status
gen edu_status = .
*Not of education age: younger than 6 
replace edu_status = 0 if (hhm_age < 6)
*Currently enrolled, 6 and older
replace edu_status = 1 if (hhm_edu_current == 1) & (hhm_age >= 6)
*Previously enrolled, school age or older
replace edu_status = 2 if (hhm_edu_ever == 1) & (hhm_age >= 6) & (hhm_edu_current == 0)
*Never enrolled, but of school age or older
replace edu_status = 3 if (hhm_edu_ever == 0) & (hhm_age >= 6) & (hhm_edu_current == 0)
label define ledu_status  0 "Not of education age" 1 "Currently enrolled" 2 "Previously enrolled" 3 "Never enrolled", replace
label values edu_status ledu_status
* Dummies
gen enrolled=edu_status==1 if inrange(hhm_age, 6, 17)
gen enrolled25 = edu_status==1 if inrange(hhm_age, 6, 25)
la val enrolled lyesno
la val enrolled25 lyesno
label var enrolled "Currently enrolled (age 6-17)"
label var enrolled25 "Currently enrolled (age 6-25)"
label variable edu_status "Education status"
*Education level groups
recode hhm_edu_level (1/7 = 1 "Incomplete Primary") (8/11 = 2 "Complete Primary/Incomplete Secondary")  (12=4 "Complete Secondary") (13/15 17= 5 "University") (16 1000 = 6 "Other"), gen(edu_level_broad)
label define edu_level_broad 0 "No education", add
replace edu_level_broad = 0 if hhm_edu_ever==0 & hhm_age>=6
la var edu_level_broad "Level of Education Group"



********************************************************************
*Labor indicators
********************************************************************
label define lyesno 0 "No" 1 "Yes", replace
*Working age members: 15 to 64
gen working_age = inrange(hhm_age, 15, 64) if !missing(hhm_age)
la val working_age l_yesno
la var working_age "Member is of working age (15-64)"
*Youth working age: 15 to 24
gen youth = inrange(hhm_age, 15, 24) if !missing(hhm_age)
la var youth "Youth of working age (15-24)"
la val youth l_yesno
*Adult working age: 25 to 64
gen adult = inrange(hhm_age, 15, 24) if !missing(hhm_age)
la var adult "Adults of working age (25-64)"
la val youth l_yesno
*Employment and unemployment for hh members ages 15 to 65
label define lemp 0 "No" 1 "Yes" .d "Outside of labor force" .f "Not of working age", replace
drop unemp_7d
gen emp_7d = (emp_7d_busi==1 | emp_7d_help==1 | emp_7d_farm==7 | emp_7d_appr==1 | emp_7d_paid==1 | emp_7d_temp==1) if inrange(hhm_age, 15, 64)
gen unemp_7d = hhm_job_search==1 & inlist(hhm_available, 1, 2, 3) if inrange(hhm_age, 15, 64)
replace emp_7d = .d if unemp_7d==0 & emp_7d==0
replace unemp_7d = .d if emp_7d==.d
recode emp_7d unemp_7d (.=.f)
label values emp_7d lemp
label values unemp_7d lemp
label var emp_7d "Employed, past 7 days"
label var unemp_7d "Unemployed, past 7 days"
*Employment and unemployment in past 12 months and ever
gen emp_12m = emp_7d
replace emp_12m = 1 if emp_12m_active==1
label values emp_12m lemp
label var emp_12m "Employed, past 12 months"
gen emp_ever = emp_12m
replace emp_ever = 1 if emp_ever_active==1
label values emp_ever lemp
label var emp_ever "Employed, ever"
*Labor force participation
gen lfp_7d = (emp_7d==1 | unemp_7d==1) if inrange(hhm_age, 15, 64)
la val lfp_7d lyesno
label var lfp_7d "Labor force participation, past 7 days"
*LFP, employment, unemployment - youth and adult members
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
label var lfp_7d_youth "Labor force participation, 7 days, youth (15-24)"
label var lfp_7d_adult "Labor force participation, 7 days, adults (25-64)"
label var emp_7d_youth "Employed, 7 days, youth (15-24)"
label var emp_7d_adult "Employed, 7 days, adult (25-64)"
label var unemp_7d_youth "Unemployed, 7 days, youth (15-24)"
label var unemp_7d_adult "Unemployed, 7 days, adult (25-64)"
*Underemployment: works but wants to work more hours
gen uemp_7d = 0 if emp_7d==1
replace uemp_7d = 1 if uemp_want==1
label values uemp_7d lyesno 
label var uemp_7d "Underemployed"
*Hours of work, censored at 100
gen emp_hrs = emp_7d_hours
recode emp_hrs (-1.00e+09=.)
replace emp_hrs = 100 if emp_hrs>100 & !missing(emp_hrs)
la var emp_hrs "Actual Hours Worked in past Week"
*Hours by category
gen emp_hrs_cat = ceil(emp_hrs/10)
recode emp_hrs_cat (0=1) 
label define lemp_hrs_cat 1 "1-10" 2 "11-20" 3 "21-30" 4 "31-40" 5 "41-50" 6 "51-60" 7 "61-70" 8 "71-80" 9 "81-90" 10 "91-100", replace
label values emp_hrs_cat lemp_hrs_cat
la var emp_hrs_cat "Hrs worked category (10-hrs intervals)"

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




********************************************************************
*Renaming, Labelling, and Saving
********************************************************************
la var hhm_gender "Gender"
ren hhm_gender gender
la var hhm_age "Age"
ren hhm_age age
la var hhhead "Is Household Head"
ren hhhead ishead
bys strata ea block hh: gen hhmid=_n
bys strata ea block hh: egen hhsize=max(hhmid)
label var hhmid "Household member ID"
label var hhsize "Household size"
order hhsize ishead gender age, after(hhmid)
order literacy pschool_age sschool_age gen_young edu_status edu_level_broad, after(age)
order age_cat_narrow age_cat_broad working_age pschool_age sschool_age youth , after(age)
order gen_young literacy, after(youth)
order team strata ea block hh hhmid enum

preserve
save "${gsdData}/1-CleanTemp/hhm.dta", replace
assert hhm_id==hhh_id if ishead==1
drop hhmid
ren region reg_pess
la var reg_pess "Region (PESS)"
order reg_pess astrata strata ea block hh enum team hhm_id ishead gender age age_cat_narrow age_cat_broad working_age pschool_age sschool_age gen_young adult literacy enrolled enrolled25 edu_status edu_level_broad active_12m_imp emp_7d unemp_7d emp_12m emp_ever lfp_7d lfp_7d_youth lfp_7d_adult emp_7d_youth emp_7d_adult unemp_7d_youth unemp_7d_adult uemp_7d emp_hrs emp_hrs_cat
drop hhh_id age_cat_broad_* no_chi no_adu no_old no_children no_adults no_old_age youth hhsize
rename hhm_id hhmid
save "${gsdData}/1-CleanOutput/hhm.dta", replace


*Prepare household member dataset for imputation
use "${gsdData}/1-CleanOutput/hhm.dta", clear
gen hhh_literacy=literacy if ishead
gen nchild = age<15 if !missing(age)
gen nsenior = age>64 if !missing(age)
gen hhsex = gender if ishead
gen hhedu = hhm_edu_ever if ishead
rename hhmid hhm_id
merge 1:1 strata ea block hh hhm_id using "${gsdData}/1-CleanTemp/hhm.dta", nogen assert(match) keepusing(active_12m_imp)
gen hhempl=active_12m_imp if ishead
collapse (sum) nchild nsenior hhh_literacy (min) hhsex hhempl hhedu (count) hhsize = hhm_id, by(strata ea block hh)
gen pchild = nchild / hhsize
gen psenior = nsenior / hhsize
drop nchild nsenior
save "${gsdData}/1-CleanTemp/hhm-hh.dta", replace
restore

********************************************************************
*Generate Aggregate Variables, and collapse to HH level, save 
********************************************************************
* Generate HH head variables
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/hh.dta", nogen assert(match) keepusing(hhr_id)
gen hhr_gender = gender if hhm_id==hhr_id
gen hhr_age = age if hhm_id==hhr_id
gen hhh_gender = gender if ishead==1
gen hhh_age = age if ishead==1
replace hhh_age=. if hhh_age < 16
gen hhh_edu = edu_level_broad if ishead==1 & !mi(hhh_age)
recode lfp_7d emp_7d (missing=0) 
* School enrollment dummy
gen enrol = edu_status==1 if inrange(age, 6, 17)
gen enrol_p =  edu_status==1 if inrange(age, 6, 13)
gen enrol_s =  edu_status==1 if inrange(age, 14, 17)

* Identify whether HH head was born in a different state 
gen hhh_outstate=(birthplace_som!=region) if ishead==1 & !mi(birthplace_som)
replace hhh_outstate=1 if born_somalia==0 & ishead==1
replace hhh_outstate=-97 if ishead==0
replace hhh_outstate=-99 if hhh_outstate==.


*Apply labels
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
collapse (mean) penrol=enrol penrol_p=enrol_p penrol_s=enrol_s pgender=gender pworking_age=working_age no_children no_adults no_old_age pliteracy=literacy page_cat_broad_1=age_cat_broad_1 page_cat_broad_2=age_cat_broad_2 page_cat_broad_3=age_cat_broad_3 page_cat_broad_4=age_cat_broad_4 (count) hhsize=hhmid (min) hhh_gender hhh_age hhh_edu hhr_gender hhr_age (max) lfp_7d_hh=lfp_7d emp_7d_hh=emp_7d hhh_outstate, by(strata ea block hh)

replace lfp_7d_hh=0 if mi(lfp_7d_hh)
replace emp_7d_hh=0 if mi(emp_7d_hh)

*Reapply labels - min
foreach var of local collapselist_min  {
	*Reapply variable labels
	label variable `var' "`l`var''"
	*Reapply value labels
	label value `var' `vl`var''
}


* New Labels 
la var hhr_gender "Respondent gender"
la var hhr_age "Respondent age"
la var hhsize "Number of members in HH"
la var pgender "Share of males in HH"
la var pworking_age "Proportion of working age members in HH"
la var pliteracy "Proportion literate in HH" 
la var penrol "Proportion enrolled at school age (6,17)"
la var penrol_p "Proportion enrolled at primary school age (6,13)"
la var penrol_s "Proportion enrolled at secondary school age (14,17)"
la var pliteracy "Proportion literate in HH" 
la var penrol "Proportion enrolled at school age (6,17)"
la var penrol_p "Proportion enrolled at primary school age (6,13)"
la var penrol_s "Proportion enrolled at secondary school age (14,17)"
la var lfp_7d_hh "Household has at least one economically active member"
la var emp_7d_hh "Household has at least one employed member"
la var hhh_outstate "HH head born outside current Somali region of residence"
recode hhh_outstate (-97 -99=.)
la def lhhh_outstate 1 "Born outisde" 0 "Born inside", replace
la val hhh_outstate lhhh_outstate


save "${gsdData}/1-CleanTemp/hh_hhm.dta", replace



