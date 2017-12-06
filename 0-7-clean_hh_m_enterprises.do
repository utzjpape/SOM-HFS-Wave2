*clean and organize child file enterprises registration

set more off
set seed 23025980 
set sortseed 11025955

use "${gsdData}/0-RawTemp/hh_m_enterprises_valid.dta", clear
********************************************************************
* Relabel 'Don't know' and 'Refused to respond'
********************************************************************
* Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all

**************************************************************************
* Relabel Skip patterns: Please Refer to Questionnaire for relevance conditions
**************************************************************************
assert missing(l_regorg_no) if l_regorg!=0 | reg_pos>=9
recode l_regorg_no (.=.z) if l_regorg!=0 | reg_pos>=9

foreach v in l_regorg_no_year l_regorg_no_year_kdk {
	assert missing(`v') if l_regorg!=1
	recode `v' (.=.z) if l_regorg!=1
}

assert missing(l_regorg_no_year_warn) if l_regorg_no_year>=1900 | l_regorg!=1
recode l_regorg_no_year_warn (.=.z) if l_regorg_no_year>=1900 | l_regorg!=1

**************************************************************************
* Cleaning
**************************************************************************
label var reg_pos "Code for registration Authority/Organization"
label var reg_org "Registration Authority/Organization"
drop child_key setofrep_reg reg_org_som reg_f1 reg_f2 reg_f3 reg_f4 reg_specify
label var key "Key to merge with parent"

label define lreg_pos 1 "Attorney General"    2 "Chamber of Commerce"    3 "Court"    4 "Local government"    5 "Ministry of Commerce"    6 "Ministry of Commerce and Industry"    7 "Ministry of Finance"    8 "Regional Municipality"    9 "Other government agency (specify)"   
label values reg_pos lreg_pos

drop reg_org
order key 

*drop empty variables
missings dropvars, force 

*drop variables with open answers, multiple numeric entries and/or in Somali
*drop l_regorg_o l_regorg_no_spec

save "${gsdData}/0-RawTemp/hh_m_enterprises_clean.dta", replace
