* Remittances Chapter


* Cross tabulations of wave 1 data relevant to remittances

use "${gsdData}/1-CleanInput/SHFS2016/hhm.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", assert(match) keepusing(weight_cons type remit12m) nogen
svyset ea [pweight=weight_adj], strata(strata)

* Migration
* prepare migration variable
recode migr_from (1=1 "Same district") (2 3=2 "Same state") (4 5 6 7=3 "Different state") (1001 1002=4 "Abroad"), gen(migr)
gen migr_int = inlist(migr, 2, 3)
la def lmigr 0 "No migrant" 1 "Migrant", replace
la val migr_int lmigr_int 

tabout hh_alwayslived remit12m using "${gsdOutput}/Remittances_raw1.xls" , svy percent c(col se) npos(col) sebnone h1(Remittances and migration) replace
tabout migr remit12m using "${gsdOutput}/Remittances_raw1.xls" , svy percent c(col se) npos(col) sebnone h1(Migration origin details) append
tabout migr_from_country remit12m using "${gsdOutput}/Remittances_raw1.xls" , svy percent c(col se) npos(col) sebnone h1(Migration origin other country) append
tabout push_reasons remit12m using "${gsdOutput}/Remittances_raw1.xls" , svy percent c(col se) npos(col) sebnone h1(Migration push reasons) append
tabout pull_reasons remit12m using "${gsdOutput}/Remittances_raw1.xls" , svy percent c(col se) npos(col) sebnone h1(Migration pull reasons) append

tabout hh_alwayslived gender using "${gsdOutput}/Remittances_raw1.xls" , svy percent c(col se) npos(col) sebnone h1(gender and migration) append
tabout migr gender using "${gsdOutput}/Remittances_raw1.xls" , svy percent c(col se) npos(col) sebnone h1(Migration origin details, gender) append
tabout migr_from_country gender using "${gsdOutput}/Remittances_raw1.xls" , svy percent c(col se) npos(col) sebnone h1(Migration origin other country, gender) append
tabout push_reasons gender using "${gsdOutput}/Remittances_raw1.xls" , svy percent c(col se) npos(col) sebnone h1(Migration push reasons, gender) append
tabout pull_reasons gender using "${gsdOutput}/Remittances_raw1.xls" if age>15, svy percent c(col se) npos(col) sebnone h1(Migration pull reasons, gender) append

* Education and employment
tabout literacy remit12m using "${gsdOutput}/Remittances_raw2.xls" , svy percent c(col se) npos(col) sebnone h1(Literacy, remit) replace
tabout edu_status remit12m using "${gsdOutput}/Remittances_raw2.xls" , svy percent c(col se) npos(col) sebnone h1(Education, remit) append
tabout lfp_7d remit12m using "${gsdOutput}/Remittances_raw2.xls" , svy percent c(col se) npos(col) sebnone h1(LFP, remit) append
tabout emp_7d remit12m using "${gsdOutput}/Remittances_raw2.xls" if lfp_7d==1, svy percent c(col se) npos(col) sebnone h1(Employment, remit) append
tabout occupation remit12m using "${gsdOutput}/Remittances_raw2.xls" if emp_7d==1, svy percent c(col se) npos(col) sebnone h1(Occupation, remit) append
tabout emp_status remit12m using "${gsdOutput}/Remittances_raw2.xls" if emp_7d==1, svy percent c(col se) npos(col) sebnone h1(Employment Status, remit) append
tabout business_own remit12m using "${gsdOutput}/Remittances_raw2.xls" if age>15, svy percent c(col se) npos(col) sebnone h1(Business owner, remit) append

tabout literacy gender using "${gsdOutput}/Remittances_raw2.xls" , svy percent c(col se) npos(col) sebnone h1(Literacy, gender) append
tabout edu_status gender using "${gsdOutput}/Remittances_raw2.xls" , svy percent c(col se) npos(col) sebnone h1(Education, gender) append
tabout lfp_7d gender using "${gsdOutput}/Remittances_raw2.xls" , svy percent c(col se) npos(col) sebnone h1(LFP, remit) append
tabout emp_7d gender using "${gsdOutput}/Remittances_raw2.xls" if lfp_7d==1, svy percent c(col se) npos(col) sebnone h1(Employment, gender) append
tabout occupation gender using "${gsdOutput}/Remittances_raw2.xls" if emp_7d==1, svy percent c(col se) npos(col) sebnone h1(Occupation, gender) append
tabout emp_status gender using "${gsdOutput}/Remittances_raw2.xls" if emp_7d==1, svy percent c(col se) npos(col) sebnone h1(Employment Status, gender) append
tabout business_own gender using "${gsdOutput}/Remittances_raw2.xls" if age>15, svy percent c(col se) npos(col) sebnone h1(Business owner, gender) append

tabout literacy hh_alwayslived using "${gsdOutput}/Remittances_raw2.xls" , svy percent c(col se) npos(col) sebnone h1(Literacy, hh_alwayslived) append
replace hh_alwayslived = -97 if age<15
tabout edu_status hh_alwayslived using "${gsdOutput}/Remittances_raw2.xls" , svy percent c(col se) npos(col) sebnone h1(Education, hh_alwayslived) append
recode hh_alwayslived (-97=.) 
tabout lfp_7d hh_alwayslived using "${gsdOutput}/Remittances_raw2.xls" , svy percent c(col se) npos(col) sebnone h1(LFP, remit) append
tabout emp_7d hh_alwayslived using "${gsdOutput}/Remittances_raw2.xls" if lfp_7d==1, svy percent c(col se) npos(col) sebnone h1(Employment, hh_alwayslived) append
tabout occupation hh_alwayslived using "${gsdOutput}/Remittances_raw2.xls" if emp_7d==1, svy percent c(col se) npos(col) sebnone h1(Occupation, hh_alwayslived) append
tabout emp_status hh_alwayslived using "${gsdOutput}/Remittances_raw2.xls" if emp_7d==1, svy percent c(col se) npos(col) sebnone h1(Employment Status, hh_alwayslived) append
tabout business_own hh_alwayslived using "${gsdOutput}/Remittances_raw2.xls", svy percent c(col se) npos(col) sebnone h1(Business owner, hh_alwayslived) append

* Household characteristics
use "${gsdData}/1-CleanInput/SHFS2016/hhm.dta", clear
gen migrant = hh_alwayslived==0
gen hhh_migrant = migrant==1 & ishead==1
collapse (max) migrant hhh_migrant, by(team strata ea block hh)
la def lmigrant 1 "Migrant" 0 "Non-migrant"
la val migrant lmigrant
la val hhh_migrant lmigrant
la var migrant "HH has migrant member"
la var hhh_migrant "HHH is migrant"
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", assert(match) nogen
svyset ea [pweight=weight_adj], strata(strata)

tabout remit12m using "${gsdOutput}/Remittances_raw3.xls", svy sum c(mean hhsize se) sebnone h2(HH size & remit) replace
tabout remit12m using "${gsdOutput}/Remittances_raw3.xls", svy sum c(mean dependency_ratio se) sebnone h2(dependency ratio & remit) append
tabout emp_7d remit12m using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(HH employment & remit) append
tabout main_income_source remit12m using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(income source & remit) append

tabout house_ownership remit12m using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(ownership & remit) append
tabout house_type_cat remit12m using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(house type & remit) append
tabout floor_material remit12m using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(floor & remit) append
tabout roof_material remit12m using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(roof & remit) append

tabout hhh_migrant using "${gsdOutput}/Remittances_raw3.xls", svy sum c(mean hhsize se) sebnone h2(HH size & migrant) append
tabout hhh_migrant using "${gsdOutput}/Remittances_raw3.xls", svy sum c(mean dependency_ratio se) sebnone h2(dependency ratio & migrant) append
tabout emp_7d_hh hhh_migrant using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(HH employment & migrant) append
tabout main_income_source hhh_migrant using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(income source & migrant) append

tabout house_ownership hhh_migrant using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(ownership & migrant) append
tabout house_type_cat hhh_migrant using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(house type & migrant) append
tabout floor_material hhh_migrant using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(floor & migrant) append
tabout roof_material hhh_migrant using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(roof & migrant) append

tabout hhh_gender using "${gsdOutput}/Remittances_raw3.xls", svy sum c(mean hhsize se) sebnone h2(HH size & hhh gender) append
tabout hhh_gender using "${gsdOutput}/Remittances_raw3.xls", svy sum c(mean dependency_ratio se) sebnone h2(dependency ratio & hhh gender) append
tabout emp_7d_hh hhh_gender using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(HH employment & hhh gender) append
tabout main_income_source hhh_gender using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(income source & hhh gender) append

tabout house_ownership hhh_gender using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(ownership & hhh gender) append
tabout house_type_cat hhh_gender using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(house type & hhh gender) append
tabout floor_material hhh_gender using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(floor & hhh gender) append
tabout roof_material hhh_gender using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(roof & hhh gender) append

gen pw=weight_cons*hhsize
svyset ea [pweight=pw], strata(strata)
tabout remit12m using "${gsdOutput}/Remittances_raw3.xls", svy sum c(mean poorPPP_prob se) f(3) sebnone h2(Poverty & remit) append
tabout hhh_migrant using "${gsdOutput}/Remittances_raw3.xls", svy sum c(mean poorPPP_prob se) f(3) sebnone h2(Poverty & migrant) append
tabout hhh_gender using "${gsdOutput}/Remittances_raw3.xls", svy sum c(mean poorPPP_prob se) f(3) sebnone h2(Poverty & hhh gender) append

svyset ea [pweight=weight_adj], strata(strata)
tabout remit12m hhh_migrant using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(Remittances & migrant) append
tabout hhh_migrant remit12m using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(migrant & remit) append
tabout hhh_gender remit12m using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(Remittances & HHH gender) append
tabout remit12m hhh_gender using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(HHH gender & remittances) append
tabout hhh_gender hhh_migrant using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(HHH gender & migrant) append
tabout hhh_migrant hhh_gender using "${gsdOutput}/Remittances_raw3.xls" , svy percent c(col se) npos(col) sebnone h1(migrant & hhh gender) append

* Coping
recode cop_soldmore cop_spentsav cop_borrow cop_sellassets cop_migrate (-97 2 3 = 0)
tabout nomoney remit12m using "${gsdOutput}/Remittances_raw4.xls" , svy percent c(col se) npos(col) sebnone h1(No money & remit) replace
tabout cop_spentsav remit12m using "${gsdOutput}/Remittances_raw4.xls" , svy percent c(col se) npos(col) sebnone h1(Spent savings & remit) append
tabout cop_borrow remit12m using "${gsdOutput}/Remittances_raw4.xls" , svy percent c(col se) npos(col) sebnone h1(borrow money & remit) append
tabout cop_sellassets remit12m using "${gsdOutput}/Remittances_raw4.xls" , svy percent c(col se) npos(col) sebnone h1(Sell assets & remit) append
tabout cop_migrate remit12m using "${gsdOutput}/Remittances_raw4.xls" , svy percent c(col se) npos(col) sebnone h1(Migrate & remit) append

* Income sources
use "${gsdData}/1-CleanInput/SHFS2016/incomesources.dta", clear
keep if inlist(inc_pos, 7,8,9,10)
keep if inc_rel==1
drop inc_other_ inc_total_ inc_total_c inc_total_kdk 
recode zone (1=2)
merge m:1 zone using "${gsdData}/1-CleanInput/SHFS2016/HFS Exchange Rate Survey.dta", assert(match using) keep(match) nogen
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", keep(match) assert(match using) keepusing(astrata weight_adj) nogen
drop if inc_intl_==0 & inc_urban_==0 & inc_intl_==0

foreach inc in inc_rural inc_urban inc_intl {
	*correct issue with currency-units 
	*cleaning rule: change USD to local currency (for each zone) when the price is equal or greater than 1,000
	replace `inc'_c=3 if `inc'_ >= 10000 & `inc'_<. & `inc'_c==5 & team==1
	replace `inc'_c=1 if `inc'_ >= 10000 & `inc'_<. & `inc'_c==5 & team!=1
	*cleaning rule: change local currency to thousands (for each zone) when the price is equal or smaller than 500
	replace `inc'_c=4 if `inc'_ <= 1000 & `inc'_c==3 & team==1
	replace `inc'_c=2 if `inc'_ <= 1000 & `inc'_c==1 & team!=1
	*cleaning rule: change thousands to local currency (for each zone) larger than 100,000 thousands
	replace `inc'_c=3 if `inc'_ >= 100000 & `inc'_c==4 & team==1
	replace `inc'_c=1 if `inc'_ >= 100000 & `inc'_c==2 & team!=1


	*convert to USD
	gen `inc'_usd = `inc'_ if `inc'_c==5
	replace `inc'_usd = `inc'_ / average_er if inlist(`inc'_c, 1, 3)
	replace `inc'_usd = `inc'_ / average_er/1000 if inlist(`inc'_c, 2, 4)
	recode `inc'_usd (0=.) 

	*cleaning rule: replace values in the top/bottom 1% by the median value in USD within the same astrata 
	set sortseed 11041925
	cumul `inc'_usd, gen(cumul_distr_`inc') equal
	levelsof astrata, local(regions)
	foreach region of local regions {
	   sum `inc'_usd [aw= weight_adj] if astrata==`region' & cumul_distr_`inc'>0.01 & cumul_distr_`inc'<0.99, detail 
	   replace `inc'_usd=r(p50) if `inc'_usd<. & astrata==`region' & (cumul_distr_`inc'>0.99  | cumul_distr_`inc'<0.01 )	
	}

	* Cleaning rule: replace values smaller than 1 usd to missing 
	replace `inc'_usd = . if `inc'_usd<1

	* Cleaning rule: replace missing, "don't know" and "refused to respond" to mean of astrata
	bys astrata: egen `inc'_astrata_mean = mean(`inc'_usd)
	replace `inc'_usd = `inc'_astrata_mean if inlist(`inc'_kdk, .a, .b) | `inc'_usd==.
	drop `inc'_astrata_mean
}
drop cumul* *_c *_ *kdk inc_rel zone average_er global_er
reshape wide inc_urban_usd inc_rural_usd inc_intl_usd, i(team strata ea block hh) j(inc_pos)
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", keep(match using) assert(match using) nogen
drop if team==2
foreach i in 7 8 9 10 {
	gen inc`i' = !mi(inc_rural_usd`i') | !mi(inc_urban_usd`i') | !mi(inc_intl_usd`i')
	replace inc_rural_usd`i' = inc_rural_usd`i' / hhsize
	replace inc_urban_usd`i' = inc_urban_usd`i' / hhsize
	replace inc_intl_usd`i' = inc_intl_usd`i' / hhsize
	
}
svyset ea [pweight=weight_adj], strata(strata)
tabout inc7 using "${gsdOutput}/Remittances_raw5.xls" , svy percent c(col se) npos(col) sebnone h1(Income type 7) replace
tabout inc8 using "${gsdOutput}/Remittances_raw5.xls" , svy percent c(col se) npos(col) sebnone h1(Income type 8) append
tabout inc9 using "${gsdOutput}/Remittances_raw5.xls" , svy percent c(col se) npos(col) sebnone h1(Income type 9) append
tabout inc10 using "${gsdOutput}/Remittances_raw5.xls" , svy percent c(col se) npos(col) sebnone h1(Income type 10) append
gen pw = weight_adj*hhsize
svyset ea [pweight=pw], strata(strata)

gen x = 1
foreach i in 7 8 9 10 {
	egen inc_usd`i' = rowtotal(inc_urban_usd`i' inc_rural_usd`i' inc_intl_usd`i')
	recode inc_usd`i' (0=.)
	tabout x using "${gsdOutput}/Remittances_raw5.xls", svy sum c(mean inc_urban_usd`i') sebnone h2("urban av pc inc `i'") append
	tabout x using "${gsdOutput}/Remittances_raw5.xls", svy sum c(mean inc_rural_usd`i') sebnone h2("rural av pc inc `i'") append
	tabout x using "${gsdOutput}/Remittances_raw5.xls", svy sum c(mean inc_intl_usd`i') sebnone h2("intl av pc inc `i'") append
	tabout x using "${gsdOutput}/Remittances_raw5.xls", svy sum c(mean inc_usd`i') sebnone h2("total av pc inc `i'") append
}
drop pw 
gen pw=weight_cons*hhsize
svyset ea [pweight=pw], strata(strata)
tabout inc7 using "${gsdOutput}/Remittances_raw5.xls", svy sum c(mean poorPPP_prob) f(3) sebnone h2("inc7 poverty rate") append
tabout inc8 using "${gsdOutput}/Remittances_raw5.xls", svy sum c(mean poorPPP_prob) f(3) sebnone h2("inc8 poverty rate") append
tabout inc9 using "${gsdOutput}/Remittances_raw5.xls", svy sum c(mean poorPPP_prob) f(3) sebnone h2("inc9 poverty rate") append
tabout inc10 using "${gsdOutput}/Remittances_raw5.xls", svy sum c(mean poorPPP_prob) f(3) sebnone h2("inc10 poverty rate") append

gen no_transfer = inc7==0 & inc8==0 & inc9==0 & inc10==0
egen total_transfer = rowtotal(inc_usd*) 
tabout no_transfer using "${gsdOutput}/Remittances_raw5.xls" , svy percent c(col se) npos(col) sebnone h1(No transfer) append
tabout no_transfer using "${gsdOutput}/Remittances_raw5.xls", svy sum c(mean poorPPP_prob) f(3) sebnone h2("Poverty no transfer") append
tabout x using "${gsdOutput}/Remittances_raw5.xls", svy sum c(mean total_transfer) sebnone h2("total av pc inc, all types") append


* Household enterprises
use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear
svyset ea [pweight=weight_adj], strata(strata)
gen hh_enterprise = (l_lstock==1 | l_gum==1 | l_remit==1 | l_telec==1 | l_omanuf==1 | l_taxi==1 | l_oact==1)
tabout hh_enterprise using "${gsdOutput}/Remittances_raw6.xls" , svy percent c(col se) npos(col) sebnone h1(HH enterprises) replace
tabout poorPPP hh_enterprise  using "${gsdOutput}/Remittances_raw6.xls" , svy percent c(col se) npos(col) sebnone h1(HH enterprises & Poverty) append

********************************************************************************
* Round 2: additional statistics
use "${gsdData}/1-CleanInput/SHFS2016/hhm.dta", clear
recode migr_from (1=1 "Same district") (2 3=2 "Same state") (4 5 6 7=3 "Different state") (1001 1002=4 "Abroad"), gen(migr)
gen int_migrant = inlist(migr, 2, 3)
gen intl_migrant = migr==4
gen enrolled = edu_status==1 if inrange(age,6,17)
gen sage = inrange(age, 6, 17) if !mi(age)
gen childrenu5 = inrange(age, 0, 5)
collapse (max) int_migrant intl_migrant childrenu5 (mean) literacy enrolled sage hhsize , by(team strata ea block hh)
gen s_aged=round(sage*hhsize)
la def lint_migrant 1 "Int Migrant" 0 "Non-migrant", replace
la val int_migrant lint_migrant
la def lintl_migrant 1 "Intl Migrant" 0 "Non-migrant", replace
la val intl_migrant lintl_migrant
la var int_migrant "HH has int migrant member"
la var intl_migrant "HH has intl migrant member"
la var literacy "Literacy share"
la var enrolled "Enrollment share"
la var s_aged "Nb school-aged"
gen non_migrant = int_migrant==0 & intl_migrant==0
save "${gsdData}/1-CleanTemp/hhm-migrant-edu.dta", replace

*School expenditures 
use "${gsdData}/1-CleanInput/SHFS2016/nonfood.dta", clear 
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhm-migrant-edu.dta", assert(match using) keep(match) nogen keepusing(s_aged hhsize int_migrant intl_migrant non_migrant enrolled childrenu5)
keep if inlist(itemid, 1080, 1081)
ren purc_usd_imp exp
drop purc* imputed pr* free*
reshape wide exp, i(strata ea block hh) j(itemid)
gen educ_expense = exp1080*52/s_aged if s_aged>0
gen health_expense = exp1081*52/hhsize
la var educ_expense "Mean annual educational expenses per school-aged child, current USD"
la var health_expense "Mean annual health care expenses per capita, current USD"
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", assert(match using) nogen
gen pw=weight_cons*hhsize
svyset ea [pw=pw], strata(strata)

* Income quintiles with remittances receipt, migration, literacy
* New additions 
tabout remit12m quintiles_tc  using "${gsdOutput}/Remittances_raw7.xls" , svy percent c(col se) npos(col) sebnone h1(Remittances and income quintiles) replace
recode remit_pcpd (0=.)
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if !missing(remit_pcpd), svy sum c(mean remit_pcpd se) f(3) sebnone npos(col) h2("Mean value (USD) of remittances pc (Conditional) pd") append
tabout int_migrant quintiles_tc  using "${gsdOutput}/Remittances_raw7.xls" , svy percent c(col se) npos(col) sebnone h1("Internal migrants and income quintiles") append
tabout intl_migrant quintiles_tc  using "${gsdOutput}/Remittances_raw7.xls" , svy percent c(col se) npos(col) sebnone h1("International migrants and income quintiles") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==0, svy sum c(mean pliteracy se) f(3) sebnone npos(col) h2("income quintiles and literacy, non-recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean pliteracy se) f(3) sebnone npos(col) h2("income quintiles and literacy, recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==0, svy sum c(mean tc_imp se) f(3) sebnone npos(col) h2("income quintiles and consumption, non-recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean tc_imp se) f(3) sebnone npos(col) h2("income quintiles and consumption, recipients") append
replace tc_imp_f=tc_imp_f/7/hhsize
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==0, svy sum c(mean tc_imp_f se) f(3) sebnone npos(col) h2("income quintiles and food consumption, non-recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean tc_imp_f se) f(3) sebnone npos(col) h2("income quintiles and food consumption, recipients") append
gen remit_proportion = remit_pcpd / tc_imp
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean remit_proportion se) f(3) sebnone npos(col) h2("income quintiles, remittances as proportion of income") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==0, svy sum c(mean enrolled se) f(3) sebnone npos(col) h2("income quintiles and education, non-recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean enrolled se) f(3) sebnone npos(col) h2("income quintiles and education, recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==0, svy sum c(mean educ_expense se) f(3) sebnone npos(col) h2("income quintiles and educational expense, non-recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean educ_expense se) f(3) sebnone npos(col) h2("income quintiles and educational expense, recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==0, svy sum c(mean health_expense se) f(3) sebnone npos(col) h2("income quintiles and health expense, non-recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean health_expense se) f(3) sebnone npos(col) h2("income quintiles and health expense, recipients") append
replace tc_imp_nf=tc_imp_nf/7/hhsize
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==0, svy sum c(mean tc_imp_nf se) f(3) sebnone npos(col) h2("income quintiles and nonfood expenditure, non-recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean tc_imp_nf se) f(3) sebnone npos(col) h2("income quintiles and nonfood expenditure, recipients") append
drop if team==2
drop quintiles_tc
xtile quintiles_tc = tc_imp [pw=pw], n(5)
replace meals_adult=. if meals_adult>10
replace meals_childrenu5=. if meals_childrenu5>10
svyset ea [pw=weight_adj], strata(strata)
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==0, svy sum c(mean nomoney se) f(3) sebnone npos(col) h2("income quintiles and lack of money for food, non-recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean nomoney se) f(3) sebnone npos(col) h2("income quintiles and lack of money for food, recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==0, svy sum c(mean meals_adult se) f(3) sebnone npos(col) h2("income quintiles and adult meals, non-recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean meals_adult se) f(3) sebnone npos(col) h2("income quintiles and adult meals, recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==0, svy sum c(mean meals_childrenu5 se) f(3) sebnone npos(col) h2("income quintiles and child meals, non-recipients") append
tabout quintiles_tc using "${gsdOutput}/Remittances_raw7.xls" if remit12m==1, svy sum c(mean meals_childrenu5 se) f(3) sebnone npos(col) h2("income quintiles and child meals, recipients") append



* Housetypes
tabout remit12m house_type_cat  using "${gsdOutput}/Remittances_raw8.xls" , svy percent c(col se) npos(col) sebnone h1(Remittances and housing) replace
tabout house_type_cat using "${gsdOutput}/Remittances_raw8.xls" if !missing(remit_pcpd), svy sum c(mean remit_pcpd se) f(3) sebnone npos(col) h2(Mean value (USD) of remittances pc (Conditional) pd by housing) append
tabout int_migrant house_type_cat using "${gsdOutput}/Remittances_raw8.xls" , svy percent c(col se) npos(col) sebnone h1(Internal migrants and housing) append
tabout intl_migrant house_type_cat using "${gsdOutput}/Remittances_raw8.xls" , svy percent c(col se) npos(col) sebnone h1(International migrants and housing) append

tabout remit12m house_ownership  using "${gsdOutput}/Remittances_raw8.xls" , svy percent c(col se) npos(col) sebnone h1(Remittances and ownership) append
tabout house_ownership using "${gsdOutput}/Remittances_raw8.xls" if !missing(remit_pcpd), svy sum c(mean remit_pcpd se) f(3) sebnone npos(col) h2(Mean value (USD) of remittances pc (Conditional) pd by ownership) append
tabout int_migrant house_ownership using "${gsdOutput}/Remittances_raw8.xls" , svy percent c(col se) npos(col) sebnone h1(Internal migrants and house ownership) append
tabout intl_migrant house_ownership using "${gsdOutput}/Remittances_raw8.xls" , svy percent c(col se) npos(col) sebnone h1(International migrants and house ownership) append

* Remittances and Migration
svyset ea [pw=weight_adj], strata(strata)
tabout remit12m int_migrant  using "${gsdOutput}/Remittances_raw9.xls" , svy percent c(col se) npos(col) sebnone h1(Remittances and int migrant) replace
tabout remit12m intl_migrant  using "${gsdOutput}/Remittances_raw9.xls" , svy percent c(col se) npos(col) sebnone h1(Remittances and intl migrant) append
tabout int_migrant using "${gsdOutput}/Remittances_raw9.xls" if !missing(remit_pcpd), svy sum c(mean remit_pcpd se) f(3) sebnone npos(col) h2(Mean value (USD) of remittances pc (Conditional) pd, int migrant) append
tabout intl_migrant using "${gsdOutput}/Remittances_raw9.xls" if !missing(remit_pcpd), svy sum c(mean remit_pcpd se) f(3) sebnone npos(col) h2(Mean value (USD) of remittances pc (Conditional) pd, intl migrant) append
tabout remit12m non_migrant using "${gsdOutput}/Remittances_raw9.xls" , svy percent c(col se) npos(col) sebnone h1(Remittances and no migrants in HH) append
tabout remit12m int_migrant using "${gsdOutput}/Remittances_raw9.xls" , c(freq col) npos(col) f(0) sebnone h1(Recipients and int migrants in HH) append
tabout remit12m intl_migrant using "${gsdOutput}/Remittances_raw9.xls" , c(freq col) npos(col) f(0) sebnone h1(Recipients and intl migrants in HH) append
tabout remit12m non_migrant using "${gsdOutput}/Remittances_raw9.xls" , c(freq col) npos(col) f(0) sebnone h1(Recipients and no migrants in HH) append
tabout non_migrant using "${gsdOutput}/Remittances_raw9.xls" if !missing(remit_pcpd), svy sum c(mean remit_pcpd se) f(3) sebnone npos(col) h2(Mean value (USD) of remittances pc (Conditional) pd, no migrant) append

* Remittances and child labour 
use "${gsdData}/1-CleanInput/SHFS2016/hhm.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", assert(match) keepusing(weight_cons type remit12m reg_pess) nogen
svyset ea [pweight=weight_adj], strata(strata)
gen work12m_1015 = ( emp_12m_appr==1 | emp_12m_farm==1 | emp_12m_paid==1 | emp_12m_busi==1 | emp_12m_help==1 | emp_12m_prim==1) if inrange(age, 10, 15)
gen work12m_1620 = ( emp_12m_appr==1 | emp_12m_farm==1 | emp_12m_paid==1 | emp_12m_busi==1 | emp_12m_help==1 | emp_12m_prim==1) if inrange(age, 16, 20)
gen work7d_hh1015 = emp_7d_hh==1 if inrange(age, 10, 15)
gen work7d_hh1620 = emp_7d_hh==1 if inrange(age, 16, 20)
gen enrolled=edu_status==1
svy: probit work12m_1015 remit12m type i.reg_pess gender enrolled
svy: probit enrolled remit12m
svy: probit work12m_1620 remit12m
svy: probit work7d_hh1015 remit12m type i.reg_pess gender hhsize
svy: mean work7d_hh1015, over(remit12m)
svy: mean work12m_1015, over(remit12m)
tabout work12m_1015 remit12m using "${gsdOutput}/Remittances_raw10.xls" , svy percent c(col se) npos(col) sebnone h1(Child labor (10-15) & remit) replace
tabout work12m_1620 remit12m using "${gsdOutput}/Remittances_raw10.xls" , svy percent c(col se) npos(col) sebnone h1(Child labor (16-20) & remit) append
tabout work7d_hh1015 remit12m using "${gsdOutput}/Remittances_raw10.xls" , svy percent c(col se) npos(col) sebnone h1(Child work in HH (10-15) & remit) append
tabout work7d_hh1620 remit12m using "${gsdOutput}/Remittances_raw10.xls" , svy percent c(col se) npos(col) sebnone h1(Child work in HH (16-20) & remit) append

* Remittances by urban-rural-IDP
use "${gsdData}/1-CleanInput/SHFS2016/hh.dta", clear
svyset ea [pweight=weight_adj], strata(strata)
tabout remit12m type  using "${gsdOutput}/Remittances_raw11.xls" , svy percent c(col se) npos(col) sebnone h1("Remittances and population type") replace
tabout type using "${gsdOutput}/Remittances_raw11.xls" if !missing(remit_pcpd), svy sum c(mean remit_pcpd se) f(3) sebnone npos(col) h2(Mean value (USD) of remittances pc (Conditional) pd, no migrant) append


* put it all together
foreach i of numlist 1/11 {
	insheet using "${gsdOutput}/Remittances_raw`i'.xls", clear nonames tab
	export excel using "${gsdOutput}/Remittances_Figures_v2.xlsx", sheetreplace sheet("Raw_Data_`i'")
}
*

label dir
numlabel `r(names)', add
