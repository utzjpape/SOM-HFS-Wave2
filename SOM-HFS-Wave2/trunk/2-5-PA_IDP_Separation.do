*Wave 2 IDP analysis -- Separation and reunification

************************
*HHM-Separated prep
************************
*Prepare number of separated members variable
use "${gsdData}/1-CleanOutput/hhm_separated.dta", clear
*generate number of separated members per hh 
bys strata ea block hh : gen numsep = _N
lab var numsep "Number of members separated per household"
order numsep, after(hh)
collapse numsep, by(strata ea block hh)
count
*So it's 426 households, which is what we get after collapsing. Initially it's 594 hh members.
save "${gsdTemp}/separatedmem.dta", replace

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)
count
merge 1:1 strata ea block hh using "${gsdTemp}/separatedmem.dta",  assert(match master) keepusing(numsep) nogen
count

*Generate variable on separated members based on whether lost members are listed in the separated roster
gen separated_roster = !missing(numsep) if t ==1
lab def lyn 1 "Yes" 0 "No"
lab val separated_roster lyn
tab separated_roster
lab var separated_roster "Lost household members (calcuated using separated roster)"

*TABOUTS

*Whether the HH has lost family members
qui tabout separated_roster comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) replace h1("Separated") f(4) 
qui tabout separated_roster reasonidp using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("Separated") f(4) 
qui tabout separated_roster urbanrural using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("Separated") f(4) 
qui tabout separated_roster national using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("Separated") f(4) 
qui tabout separated_roster genidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("Separated") f(4) 
qui tabout separated_roster quintileidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("Separated") f(4) 

*Access to reunification mechanisms 
qui tabout hhm_unite comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("ReuniteAccess") f(4) 
qui tabout hhm_unite reasonidp using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("ReuniteAccess") f(4) 
qui tabout hhm_unite urbanrural using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("ReuniteAccess") f(4) 
qui tabout hhm_unite national using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("ReuniteAccess") f(4) 
qui tabout hhm_unite genidp using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("ReuniteAccess") f(4) 
qui tabout hhm_unite quintileidp using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("ReuniteAccess") f(4) 

************************
*HHM-Separated Roster indicators
************************
use "${gsdData}/1-CleanOutput/hhm_separated.dta", clear
*Merge in weights and comparison variables ; set survey data
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", keepusing(weight_adj comparisonidp genidp quintileidp reasonidp urbanrural t national tc_imp quintiles_tc) assert(match using)
svyset ea [pw=weight], strata(strata) singleunit(centered)
*Retain obs that are from hhm separated roster
keep if _merge ==3
drop _merge
*Clean age
replace hhm_sep_age = . if hhm_sep_age > 80
*Clean reason for separation
label define hhm_sep_reason 1 "Deceased" 2 "Recruited by armed forces" 3 "Stayed behind" 4 "Displaced to other location" 1000 "Other", modify
*generate number of separated members per hh 
bys strata ea block hh : gen numsep = _N
lab var numsep "Number of members separated per household"
order numsep, after(hh)

*Number of separated members
qui tabout comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean numsep lb ub se) npos(col) append h2("NumberSeparated") f(4) 
qui tabout reasonidp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean numsep lb ub se) npos(col) append h2("NumberSeparated") f(4) 
qui tabout urbanrural using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean numsep lb ub se) npos(col) append h2("NumberSeparated") f(4) 
qui tabout national using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean numsep lb ub se) npos(col) append h2("NumberSeparated") f(4) 
qui tabout genidp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean numsep lb ub se) npos(col) append h2("NumberSeparated") f(4) 
qui tabout quintileidp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean numsep lb ub se) npos(col) append h2("NumberSeparated") f(4) 

*Gender of separated members
qui tabout hhm_sep_sex comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("GenderSeparated") f(4) 
qui tabout hhm_sep_sex reasonidp using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("GenderSeparated") f(4) 
qui tabout hhm_sep_sex urbanrural using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("GenderSeparated") f(4) 
qui tabout hhm_sep_sex national using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("GenderSeparated") f(4) 
qui tabout hhm_sep_sex genidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("GenderSeparated") f(4) 
qui tabout hhm_sep_sex quintileidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("GenderSeparated") f(4) 

*Age of separated members
qui tabout comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean hhm_sep_age lb ub se) npos(col) append h2("AgeSeparated") f(4) 
qui tabout reasonidp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean hhm_sep_age lb ub se) npos(col) append h2("AgeSeparated") f(4) 
qui tabout urbanrural using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean hhm_sep_age lb ub se) npos(col) append h2("AgeSeparated") f(4) 
qui tabout national using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean hhm_sep_age lb ub se) npos(col) append h2("AgeSeparated") f(4) 
qui tabout genidp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean hhm_sep_age lb ub se) npos(col) append h2("AgeSeparated") f(4) 
qui tabout quintileidp using "${gsdOutput}/Raw_Fig11.xls", svy sum c(mean hhm_sep_age lb ub se) npos(col) append h2("AgeSeparated") f(4) 

*Contact
qui tabout hhm_sep_contact comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("ContactSeparated") f(4) 
qui tabout hhm_sep_contact reasonidp using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("ContactSeparated") f(4) 
qui tabout hhm_sep_contact urbanrural using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("ContactSeparated") f(4) 
qui tabout hhm_sep_contact national using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("ContactSeparated") f(4) 
qui tabout hhm_sep_contact genidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("ContactSeparated") f(4) 
qui tabout hhm_sep_contact quintileidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("ContactSeparated") f(4) 

*Reason for separation
qui tabout hhm_sep_reason comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("ReasonSeparated") f(4) 
qui tabout hhm_sep_reason reasonidp using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("ReasonSeparated") f(4) 
qui tabout hhm_sep_reason urbanrural using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("ReasonSeparated") f(4) 
qui tabout hhm_sep_reason national using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("ReasonSeparated") f(4) 
qui tabout hhm_sep_reason genidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("ReasonSeparated") f(4) 
qui tabout hhm_sep_reason quintileidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("ReasonSeparated") f(4) 

*Relation to hhhead -- not really interested at the moment, keep at end.
qui tabout hhm_sep_relation comparisonidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("Relationship") f(4) 
qui tabout hhm_sep_relation reasonidp using "${gsdOutput}/Raw_Fig11.xls", svy  percent c(col lb ub) npos(col) append h1("Relationship") f(4) 
qui tabout hhm_sep_relation urbanrural using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("Relationship") f(4) 
qui tabout hhm_sep_relation national using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("Relationship") f(4) 
qui tabout hhm_sep_relation genidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("Relationship") f(4) 
qui tabout hhm_sep_relation quintileidp using "${gsdOutput}/Raw_Fig11.xls", svy percent c(col lb ub) npos(col) append h1("Relationship") f(4) 

*Place raw data into the excel figures file
foreach i of num 11 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
