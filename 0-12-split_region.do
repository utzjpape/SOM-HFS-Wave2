* Saving Data separately by Team in External folder


clear all 
set more off
set seed 23081980 
set sortseed 11041955

**************************************************************************
* 1.hh.dta
**************************************************************************
use "${gsdData}/1-CleanInput/hh.dta", clear

* Alternative team variable
gen str team_alt = "SL_Team" if team==1
replace team_alt = "SC_Team" if team==2
replace team_alt = "PL_Team" if team==3
 
foreach x in PL_Team SL_Team SC_Team {	
	preserve
	keep if team_alt == "`x'"
	* Label and save
	la da "Data for `x'"
	drop team_alt zone reg_pess team
	save "${gsdData}/1-CleanInput/External/`x'/hh.dta", replace
	export delimited using "${gsdData}/1-CleanInput/External/`x'/hh.csv", replace
	* Label too long, so make it shorter 
	la var l_totalsales_val "M.121"
	saveold "${gsdData}/1-CleanInput/External/`x'/hh_v12.dta", replace version(12)
	restore
}


**************************************************************************
* 2.hhm.dta and hhm_c_illnesses.dta
**************************************************************************
use "${gsdData}/1-CleanInput/hhm.dta", clear
* Separate datasets by team
* New team variable
gen str team_alt = "SL_Team" if team==1
replace team_alt = "SC_Team" if team==2
replace team_alt = "PL_Team" if team==3
 
foreach x in PL_Team SL_Team SC_Team {	
	preserve
	keep if team_alt == "`x'"
	* Label and save
	la da "Data for `x'"
	drop team_alt zone team
	save "${gsdData}/1-CleanInput/External/`x'/hhm.dta", replace
	export delimited using "${gsdData}/1-CleanInput/External/`x'/hhm.csv", replace
	* Label too long: 
	la var emp_12m_farm "C.85"
	la var emp_ever_farm "C.91"
	saveold "${gsdData}/1-CleanInput/External/`x'/hhm_v12.dta", replace version(12)
	restore
}


use "${gsdData}/1-CleanInput/illnesses.dta", clear
* Separate datasets by team
* New team variable 
gen str team_alt = "SL_Team" if team==1
replace team_alt = "SC_Team" if team==2
replace team_alt = "PL_Team" if team==3

foreach x in PL_Team SL_Team SC_Team {	
	preserve
	keep if team_alt == "`x'"
	* Label and save
	la da "Data for `x'"
	drop team_alt zone team
	save "${gsdData}/1-CleanInput/External/`x'/illnesses.dta", replace
	export delimited using "${gsdData}/1-CleanInput/External/`x'/illnesses.csv", replace
	saveold "${gsdData}/1-CleanInput/External/`x'/illnesses_v12.dta", replace version(12)
	restore
}

**************************************************************************
* 3.Remaining data sets
**************************************************************************
clear all
foreach sf in food nonfood livestock assets  {
    use "${gsdData}/1-CleanInput/`sf'.dta", clear
	
	gen str team_alt = "SL_Team" if team==1
	replace team_alt = "SC_Team" if team==2
	replace team_alt = "PL_Team" if team==3

	
	foreach x in PL_Team SL_Team SC_Team {	
		preserve 
		keep if team_alt == "`x'"
		* Label and save
		la da "Data for `x'"
		drop team_alt zone team
		save "${gsdData}/1-CleanInput/External/`x'/`sf'.dta", replace
		export delimited "${gsdData}/1-CleanInput/External/`x'/`sf'.csv", replace
		saveold "${gsdData}/1-CleanInput/External/`x'/`sf'_v12.dta", replace version(12)
		restore
	}	
}


* The following are not available for South Central, so modification to code
foreach sf in fsecurity enterprises shocks  {
    use "${gsdData}/1-CleanInput/`sf'.dta", clear
	 
	gen str team_alt = "SL_Team" if team==1
	replace team_alt = "PL_Team" if team==3

	foreach x in PL_Team SL_Team {	
		preserve 
		keep if team_alt == "`x'"
		* Label and save
		la da "Data for `x'"
		*drop team
		drop team_alt zone team
		save "${gsdData}/1-CleanInput/External/`x'/`sf'.dta", replace
		export delimited "${gsdData}/1-CleanInput/External/`x'/`sf'.csv", replace
		saveold "${gsdData}/1-CleanInput/External/`x'/`sf'_v12.dta", replace version(12)
		restore
	}	
}


* hh_l_incomesources.dta needs special treatment because there is a string variable that is too long for Stata 12
use "${gsdData}/1-CleanInput/incomesources.dta", clear

gen str team_alt = "SL_Team" if team==1
replace team_alt = "PL_Team" if team==3

foreach x in PL_Team SL_Team {	
	preserve 
	keep if team_alt == "`x'"
	* Label and save
	la da "Data for `x'"
	drop team_alt zone team
	save "${gsdData}/1-CleanInput/External/`x'/incomesources.dta", replace
	export delimited "${gsdData}/1-CleanInput/External/`x'/incomesources.csv", replace
	* Required for Stata 12: string max 244 characters
	recast str244 inc_other_, force
	saveold "${gsdData}/1-CleanInput/External/`x'/incomesources_v12.dta", replace version(12)
	restore
}

