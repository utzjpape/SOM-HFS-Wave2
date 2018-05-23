* Remittances analysis

* Section 2.1 Data on migrant stocks
* Wave 1
use "${gsdData}/1-CleanInput/SHFS2016/hhm.dta", clear
bys strata ea block hh: egen n_always=sum(hh_alwayslived)
gen x=1 if hh_alwayslived<.
bys strata ea block hh: egen n_adult=sum(x)
gen prop_migr= 1 - n_always/n_adult
gen intl_born=born_somalia==0 if ishead==1
gen int_born=(birthplace_som!=reg_pess) if ishead==1
collapse (max) prop_migr intl_born int_born, by(strata ea block hh)
la var prop_migr "Proportion of household members who have not always lived in the current household"
la var intl_born "Household head was born outside SOM" 
la var int_born "Household head was born outside of current region" 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanInput/SHFS2016/hh.dta", nogen
gen pweight=weight_adj
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout int_born using "${gsdOutput}/Remit_raw_2.1.xls", svy percent c(col) npos(col) sebnone h2("W1, Internal") replace
tabout intl_born using "${gsdOutput}/Remit_raw_2.1.xls", svy percent c(col) npos(col) sebnone h2("W1, International") append
use "${gsdData}/1-CleanInput/SHFS2016/hhm.dta", clear
gen pweight=weight_adj
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout birthplace_outsom using "${gsdOutput}/Remit_raw_2.1.xls" if ishead==1, svy percent c(col) npos(col) sebnone h2("W1, foreign birthplace") append
insheet using "${gsdOutput}/Remit_raw_2.1.xls", clear nonames tab
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_2.1")
erase "${gsdOutput}/Remit_raw_2.1.xls"

* Wave 2
use "${gsdData}/1-CleanInput/hhm.dta", clear
bys strata ea block hh: egen n_always=sum(hh_alwayslived)
gen x=1 if hh_alwayslived<.
bys strata ea block hh: egen n_adult=sum(x)
gen prop_migr= 1 - n_always/n_adult
gen intl_born=born_somalia==0 if hhm_relation==1
gen int_born=(birthplace_som!=region) if hhm_relation==1
collapse (max) prop_migr intl_born int_born, by(strata ea block hh)
la var prop_migr "Proportion of household members who have not always lived in the current household"
la var intl_born "Household head was born outside SOM" 
la var int_born "Household head was born outside of current region" 
merge 1:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen
gen pweight=weight
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout int_born using "${gsdOutput}/Remit_raw_2.1.xls", svy percent c(col) npos(col) sebnone h2("W2, internal") replace
tabout intl_born using "${gsdOutput}/Remit_raw_2.1.xls", svy percent c(col) npos(col) sebnone h2("W2, international") append
use "${gsdData}/1-CleanInput/hhm.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen keepusing(weight)
gen pweight=weight
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
recode birthplace_outsom (101 102 = .)
tabout birthplace_outsom using "${gsdOutput}/Remit_raw_2.1.xls", svy percent c(col) npos(col) sebnone h2("W2, foreign birthplace") append
insheet using "${gsdOutput}/Remit_raw_2.1.xls", clear nonames tab
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetmodify sheet("Raw_2.1") cell(D1)
erase "${gsdOutput}/Remit_raw_2.1.xls"

* Table 2.2: Remittances by population types
use "${gsdData}/1-CleanOutput/hh_w1_w2.dta", clear
gen pweight=weight_adj
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
egen remit = group(t remit12m), label
replace type = 5 if migr_disp==1
la def ltype 5 "Informally displaced" , add
tabout type remit12m using "${gsdOutput}/Remit_raw_2.2.xls" if t==0, svy percent c(row) npos(row) sebnone h1("Remittances by group") replace
tabout type remit12m using "${gsdOutput}/Remit_raw_2.2.xls" if t==1, svy percent c(row) npos(row) sebnone h1("Remittances by group") append
tabout type intremit12m_yn using "${gsdOutput}/Remit_raw_2.2.xls" if t==1, svy percent c(row) npos(row) sebnone h1("Int. Remittances by group") append
tabout type intlremit12m_yn using "${gsdOutput}/Remit_raw_2.2.xls" if t==1, svy percent c(row) npos(row) sebnone h1("Intl. Remittances by group") append
tabout type supp_som_yn using "${gsdOutput}/Remit_raw_2.2.xls" if t==1, svy percent c(row) npos(row) sebnone h1("Sending Remittances by group") append
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
tabout intlremit12m_yn intremit12m_yn using "${gsdOutput}/Remit_raw_2.2.xls", svy percent c(row) npos(row) sebnone h2("Intl x Int") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw_2.2.xls" if intlremit12m_yn ==1, svy percent c(col) npos(row) sebnone h2("Intl x Sending") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw_2.2.xls" if intremit12m_yn ==1, svy percent c(col) npos(row) sebnone h2("Int x Sending") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw_2.2.xls" if remit12m==0, svy percent c(col) npos(row) sebnone h2("no  x Sending") append

insheet using "${gsdOutput}/Remit_raw_2.2.xls", clear nonames tab
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_2.2")

* Table 3.1 - Remittances and poverty + consumption + enrollment + labor
use "${gsdData}/1-CleanOutput/hh.dta", clear
gen pweight=weight*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout intremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean poorPPP_prob se) f(3) sebnone h2("Int Remittances and Poverty") replace
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean poorPPP_prob se) f(3) sebnone h2("Intl Remittances and Poverty") append
tabout remit12m using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean poorPPP_prob se) f(3) sebnone h2("All Remittances and Poverty") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean poorPPP_prob se) f(3) sebnone h2("Sending and Cons") append
tabout intremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean tc_imp se) f(3) sebnone h2("Int Remittances and Cons") append
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean tc_imp se) f(3) sebnone h2("Intl Remittances and Cons") append
tabout remit12m using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean tc_imp se) f(3) sebnone h2("All Remittances and Cons") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean tc_imp se) f(3) sebnone h2("Sending and Cons") append
use "${gsdData}/1-CleanOutput/hhm.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", assert(match) keepusing(weight remit12m intremit12m_yn intlremit12m_yn supp_som_yn)
gen pweight=weight
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout intremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls" if !mi(enrolled), svy sum c(mean enrolled se) f(3) sebnone h2("Int Remittances and Enrollment") append
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls" if !mi(enrolled), svy sum c(mean enrolled se) f(3) sebnone h2("Intl Remittances and Enrollment") append
tabout remit12m using "${gsdOutput}/Remit_raw3.1.xls" if !mi(enrolled), svy sum c(mean enrolled se) f(3) sebnone h2("All Remittances and Enrollment") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw3.1.xls" if !mi(enrolled), svy sum c(mean enrolled se) f(3) sebnone h2("Sending and Enrollment") append
tabout intremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean lfp_7d se) f(3) sebnone h2("Int Remittances and LFP") append
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean lfp_7d se) f(3) sebnone h2("Intl Remittances and LFP") append
tabout remit12m using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean lfp_7d se) f(3) sebnone h2("All Remittances and LFP") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean lfp_7d se) f(3) sebnone h2("Sending and LFP") append
tabout intremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean emp_7d se) f(3) sebnone h2("Int Remittances and Emp") append
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean emp_7d se) f(3) sebnone h2("Intl Remittances and Emp") append
tabout remit12m using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean emp_7d se) f(3) sebnone h2("All Remittances and Emp") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean emp_7d se) f(3) sebnone h2("Sending and Emp") append
use "${gsdData}/1-CleanOutput/hh.dta", clear
gen pweight=weight
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout intremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean hhh_gender se) f(3) sebnone h2("Int Remittances and HHH gender") append
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean hhh_gender se) f(3) sebnone h2("Intl Remittances and HHH gender") append
tabout remit12m using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean hhh_gender se) f(3) sebnone h2("All Remittances and HHH gender") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean hhh_gender se) f(3) sebnone h2("Sending and HHH gender") append
tabout intremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean hhh_age se) f(3) sebnone h2("Int Remittances and HHH age") append
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean hhh_age se) f(3) sebnone h2("Intl Remittances and HHH age") append
tabout remit12m using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean hhh_age se) f(3) sebnone h2("All Remittances and HHH age") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean hhh_age se) f(3) sebnone h2("Sending and HHH age") append
gen tc_imp_hh = tc_imp*hhsize
tabout intremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean tc_imp_hh se) f(3) sebnone h2("Int Remittances and HH-Cons") append
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean tc_imp_hh se) f(3) sebnone h2("Intl Remittances and HH-Cons") append
tabout remit12m using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean tc_imp_hh se) f(3) sebnone h2("All Remittances and HH-Cons") append
tabout supp_som_yn using "${gsdOutput}/Remit_raw3.1.xls", svy sum c(mean tc_imp_hh se) f(3) sebnone h2("Sending and HH-Cons") append


* Table 3.2 - Remittances and sources of income
tabout lhood intremit12m_yn using "${gsdOutput}/Remit_raw_3.2.xls", svy percent c(col) npos(row) sebnone h1("Int Remittances + source of income") replace
tabout lhood intlremit12m_yn using "${gsdOutput}/Remit_raw_3.2.xls", svy percent c(col) npos(row) sebnone h1("Intl Remittances + source of income") append
tabout lhood remit12m using "${gsdOutput}/Remit_raw_3.2.xls", svy percent c(col) npos(row) sebnone h1("Remittances + source of income") append
tabout lhood supp_som_yn using "${gsdOutput}/Remit_raw_3.2.xls", svy percent c(col) npos(row) sebnone h1("Sending Remittances + source of income") append

* Table 3.3 - Remittances and housing
recode tenure (1=1 "Owned") (2=2 "Rented") (3/8 = 3 "Other"), gen(tenure1)
tabout tenure1 remit12m using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Tenure x Remit") replace
tabout tenure1 intremit12m_yn using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Tenure x Int.Remit") append
tabout tenure1 intlremit12m_yn using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Tenure x Intl.Remit") append
tabout tenure1 supp_som_yn using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Tenure x Sending") append
tabout floor_material remit12m using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Tenure x Remit") append
tabout floor_material intremit12m_yn using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Floor x Int.Remit") append
tabout floor_material intlremit12m_yn using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Floor x Intl.Remit") append
tabout floor_material supp_som_yn using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Floor x Sending") append
tabout electricity_grid remit12m using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Grid x Remit") append
tabout electricity_grid intremit12m_yn using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Grid x Int.Remit") append
tabout electricity_grid intlremit12m_yn using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Grid x Intl.Remit") append
tabout electricity_grid supp_som_yn using "${gsdOutput}/Remit_raw3.3.xls" , svy percent c(col se) npos(col) sebnone h1("Grid x Sending") append

insheet using "${gsdOutput}/Remit_raw3.1.xls", clear nonames tab
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_3.1")
insheet using "${gsdOutput}/Remit_raw_3.2.xls", clear nonames tab
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_3.2")
insheet using "${gsdOutput}/Remit_raw3.3.xls", clear nonames tab
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_3.3")

* Table 3.4 - Relationship to sender
use "${gsdData}/1-CleanOutput/hh.dta", clear
gen pweight=weight
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout intremit_relation using "${gsdOutput}/Remit_raw3.4.xls" , svy percent c(col se) npos(col) sebnone h2("Family relation of sender, int remit") replace
tabout intlremit_relation using "${gsdOutput}/Remit_raw3.4.xls" , svy percent c(col se) npos(col) sebnone h2("Family relation of sender, intl remit") append
tabout intlremit_relation using "${gsdOutput}/Remit_raw3.4.xls", svy sum c(mean intlremit_source se) f(3) sebnone npos(col) h2("Lived with family prev, intl") append
tabout intremit_relation using "${gsdOutput}/Remit_raw3.4.xls", svy sum c(mean intremit_source se) f(3) sebnone npos(col) h2("Lived with family prev, int") append
tabout intlremit_relation using "${gsdOutput}/Remit_raw3.4.xls"  if intlremit_source==1, svy sum c(mean intlremit_source_mig se) f(3) sebnone npos(col) h2("Migrated for work, intl") append
tabout intremit_relation using "${gsdOutput}/Remit_raw3.4.xls" if intremit_source==1, svy sum c(mean intremit_source_mig se) f(3) sebnone npos(col) h2("Migrated for work, int") append
insheet using "${gsdOutput}/Remit_raw3.4.xls", clear nonames tab
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_3.4")

* Table 4.1 - Receipt of remittances 
* by income quintile
use "${gsdData}/1-CleanOutput/hh.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", nogen keep(match master) keepusing(tc_core)
gen pweight=weight*hhsize
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
gen quantiles_tc = quintiles_tc>2
la def lquantiles_tc 0 "Bottom 40%" 1 "Top 60%", replace
la val quantiles_tc lquantiles_tc
tabout intremit12m_yn quantiles_tc using "${gsdOutput}/Remit_raw4.1.xls" , svy percent c(col) npos(col) sebnone h1("Int.Remittances and income quintiles") replace
tabout intlremit12m_yn quantiles_tc using "${gsdOutput}/Remit_raw4.1.xls" , svy percent c(col) npos(col) sebnone h1("Intl.Remittances and income quintiles") append
recode *remit_pcpd (0=.)
tabout quantiles_tc using "${gsdOutput}/Remit_raw4.1.xls" if !missing(intremit_pcpd), svy sum c(mean intremit_pcpd se) f(3) sebnone npos(col) h2("Int.Remit value, pc pd") append
tabout quantiles_tc using "${gsdOutput}/Remit_raw4.1.xls" if !missing(intlremit_pcpd), svy sum c(mean intlremit_pcpd se) f(3) sebnone npos(col) h2("Intl.Remit value, pc pd") append
tabout quantiles_tc using "${gsdOutput}/Remit_raw4.1.xls" if intremit12m==1, svy sum c(mean tc_imp se) f(3) sebnone npos(col) h2("int. recipients, income quintiles and consumption") append
tabout quantiles_tc using "${gsdOutput}/Remit_raw4.1.xls" if intlremit12m==1, svy sum c(mean tc_imp se) f(3) sebnone npos(col) h2("intl. recipients, income quintiles and consumption") append
tabout supp_som_yn quantiles_tc using "${gsdOutput}/Remit_raw4.1.xls" , svy percent c(col) npos(col) sebnone h1("sending and income quintiles") append
tabout quantiles_tc using "${gsdOutput}/Remit_raw4.1.xls" if !missing(supp_som_pcpd), svy sum c(mean supp_som_pcpd se) f(4) sebnone npos(col) h2("Sending value, pc pd") append

* annual value, overall and by group
svyset ea [pweight=weight], strata(strata) singleunit(centered)
replace type=5 if migr_disp==1 
la def ltype 5 "Informally displaced", add
gen cons_annual = tc_imp*hhsize*365
xtile temp_hh = cons_annual [pw=weight], nq(5)
gen quantiles_hh =temp_hh>2
su remit12m_usd
su intremit12m_usd
su intlremit12m_usd
drop remit12m_usd 
egen remit12m_usd = rowtotal(*remit12m_usd)
recode remit12m_usd (0=.)

la def lquantiles_tc 0 "Bottom 40%" 1 "Top 60%", replace
la val quantiles_hh lquantiles_tc
tabout quantiles_hh using "${gsdOutput}/Remit_raw4.1.xls" if !missing(intremit12m_usd), svy sum c(mean intremit12m_usd se) f(3) sebnone npos(col) h2("IncQ-Int.Remit value, annual") append
tabout quantiles_hh using "${gsdOutput}/Remit_raw4.1.xls" if !missing(intlremit12m_usd), svy sum c(mean intlremit12m_usd se) f(3) sebnone npos(col) h2("IncQ-Intl.Remit value, annual") append
tabout type using "${gsdOutput}/Remit_raw4.1.xls" if !missing(intremit12m_usd), svy sum c(mean intremit12m_usd se) f(3) sebnone npos(col) h2("Type-Int.Remit value, annual") append
tabout type using "${gsdOutput}/Remit_raw4.1.xls" if !missing(intlremit12m_usd), svy sum c(mean intlremit12m_usd se) f(3) sebnone npos(col) h2("Type-Intl.Remit value, annual") append
tabout type using "${gsdOutput}/Remit_raw4.1.xls" if !missing(supp_som_usd), svy sum c(mean supp_som_usd se) f(3) sebnone npos(col) h2("Type-Sending value, annual") append
tabout type using "${gsdOutput}/Remit_raw4.1.xls" if !missing(remit12m_usd), svy sum c(mean remit12m_usd se) f(3) sebnone npos(col) h2("Type-All.Remit, annual") append

*tabout type using "${gsdOutput}/Remit_raw4.1.xls" if !missing(intremit12m_usd), svy sum c(mean cons_annual se) f(3) sebnone npos(col) h2("Type-Expenditure, annual") append
svy: mean intlremit12m_usd intremit12m_usd
test intlremit12m_usd = intremit12m_usd


* Check importance with quantile regression
cap erase "${gsdOutput}/Remit_raw4.1_additional1.xls"
cap erase "${gsdOutput}/Remit_raw4.1_additional1.txt"
cap erase "${gsdOutput}/Remit_raw4.1_additional2.xls"
cap erase "${gsdOutput}/Remit_raw4.1_additional2.txt"

gen ltc_core = log(tc_core)
recode *remit_pcpd (.=0)

foreach v of numlist 0.05(0.05)0.95 {
	qreg ltc_core intremit12m_yn i.type [pw=pweight], q(`v') vce(robust)	
	outreg2 using "${gsdOutput}/Remit_raw4.1_additional1.xls", append ctitle("qreg at p=`v', pop-type controls") label excel keep(intremit12m_yn) noparen nocons noaster
}

foreach v of numlist 0.05(0.05)0.95 {
	qreg ltc_core intlremit12m_yn i.type [pw=pweight], q(`v') vce(robust)	
	outreg2 using "${gsdOutput}/Remit_raw4.1_additional2.xls", append ctitle("qreg at p=`v', pop-type controls") label excel keep(intlremit12m_yn) noparen nocons noaster
}

insheet using "${gsdOutput}/Remit_raw4.1.xls", clear nonames tab
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_4.1")
insheet using "${gsdOutput}/Remit_raw4.1_additional1.txt", clear nonames tab
drop v2 
drop if mi(v3)
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetmodify sheet("Raw_4.1") cell(I1)
insheet using "${gsdOutput}/Remit_raw4.1_additional2.txt", clear nonames tab
drop v2 
drop if mi(v3)
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetmodify sheet("Raw_4.1") cell(I8)

* 4.2 - Uses of remittances
use "${gsdData}/1-CleanOutput/nonfood.dta", clear 
keep if inlist(itemid, 1082, 1083, 1084, 1085, 1086)
ren purc_usd_imp exp
drop purc* imputed pr* free* recall astrata tag_curr_change
reshape wide exp, i(strata ea block hh) j(itemid)
gen educ_expense = (exp1082 + exp1083)*52
gen health_expense = (exp1084 + exp1085 + exp1086)*52
la var educ_expense "Mean annual educational expenses, current USD"
la var health_expense "Mean annual health care expenses, current USD"
drop exp*
merge 1:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", nogen
gen pweight=weight
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
replace educ_expense = log(1 + educ_expense)
replace health_expense = log(1 + educ_expense)
* Health and education
svy: reg educ_expense intremit12m_yn hhsize tc_imp i.type
outreg2 using "${gsdOutput}/Remit_raw4.2.xls", replace ctitle("Log(Educational expenditure)") dec(3) label excel nocons keep(intremit*)
svy: reg educ_expense intlremit12m_yn hhsize tc_imp i.type
outreg2 using "${gsdOutput}/Remit_raw4.2.xls", append ctitle("Log(Educational expenditure)") dec(3) label excel nocons keep(intlremit*)
svy: reg health_expense intremit12m_yn hhsize tc_imp i.type
outreg2 using "${gsdOutput}/Remit_raw4.2.xls", append ctitle("Log(Health expenditure)") dec(3) label excel nocons keep(intremit*)
svy: reg health_expense intlremit12m_yn hhsize tc_imp i.type
outreg2 using "${gsdOutput}/Remit_raw4.2.xls", append ctitle("Log(Health expenditure)") dec(3) label excel nocons keep(intlremit*)
* Land 
svy: probit land_access_yn intremit12m_yn hhsize tc_imp i.type
margins, dydx(intremit12m_yn) post
outreg2 using "${gsdOutput}/Remit_raw4.2_additional.xls", append ctitle("Land access") dec(3) label excel nocons keep(intremit*)
svy: reg land_access_yn intlremit12m_yn hhsize tc_imp i.type
margins, dydx(intlremit12m_yn) post
outreg2 using "${gsdOutput}/Remit_raw4.2.xls", append ctitle("Land access") dec(3) label excel nocons keep(intlremit*)
insheet using "${gsdOutput}/Remit_raw4.2.txt", clear
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_4.2")

* Remittances and education 
use "${gsdData}/1-CleanOutput/hhm.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", assert(match) keepusing(quintiles_tc weight remit12m intremit12m_yn intlremit12m_yn supp_som_yn)
gen pweight=weight
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
gen quantiles_tc=quintiles_tc>2
la def lquantiles_tc 0 "Bottom 40%" 1 "Top 60%", replace
la val quantiles_tc lquantiles_tc
tabout quantiles_tc using "${gsdOutput}/Remit_raw4.3.xls" if !mi(enrolled) & intremit12m_yn==1, svy sum c(mean enrolled se) f(3) sebnone h2("Enrollment&inyRemit") replace
tabout quantiles_tc using "${gsdOutput}/Remit_raw4.3.xls" if !mi(enrolled) & intremit12m_yn==0, svy sum c(mean enrolled se) f(3) sebnone h2("Enrollment&NoIntRemit") append
tabout quantiles_tc using "${gsdOutput}/Remit_raw4.3.xls" if !mi(enrolled) & intlremit12m_yn==1, svy sum c(mean enrolled se) f(3) sebnone h2("Enrollment&IntlRemit") append
tabout quantiles_tc using "${gsdOutput}/Remit_raw4.3.xls" if !mi(enrolled) & intlremit12m_yn==0, svy sum c(mean enrolled se) f(3) sebnone h2("Enrollment&NoIntlRemit") append
insheet using "${gsdOutput}/Remit_raw4.3.xls", clear
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_4.3")
* Remittances
use "${gsdData}/1-CleanOutput/hhm.dta", clear
merge m:1 strata ea block hh using "${gsdData}/1-CleanOutput/hh.dta", assert(match) keepusing(hhh_lit tc_imp type reg_pess quintiles_tc weight remit12m intremit12m_yn intlremit12m_yn supp_som_yn)
gen pweight=weight
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
xtile quantiles = tc_imp [pweight=weight], nq(20) 
svy: probit enrolled intremit12m_yn hhh_lit tc_imp i.type i.reg_pess
margins, dydx(intremit12m_yn) at(tc_imp=(1(1)20))

svy: probit enrolled intlremit12m_yn hhh_lit tc_imp i.type i.reg_pess
margins, dydx(intlremit12m_yn) at(tc_imp=(1(1)20))

* 4.4 Remittances and financial inclusion
use "${gsdData}/1-CleanOutput/hh.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_hhm.dta", keepusing(hhr_gender) nogen
gen pweight=weight
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
tabout intremit12m_yn using "${gsdOutput}/Remit_raw4.4.xls", svy sum c(mean acc_bank1 se) f(3) sebnone h2("Int Remittances and Bank account") replace
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw4.4.xls", svy sum c(mean acc_bank1 se) f(3) sebnone h2("Intl Remittances and Bank account") append
tabout remit12m using "${gsdOutput}/Remit_raw4.4.xls", svy sum c(mean acc_bank1 se) f(3) sebnone h2("All Remittances and Bank account") append
tabout intremit12m_yn using "${gsdOutput}/Remit_raw4.4.xls", svy sum c(mean acc_bank2 se) f(3) sebnone h2("Int Remittances and mobile money") append
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw4.4.xls", svy sum c(mean acc_bank2 se) f(3) sebnone h2("Intl Remittances and mobile money") append
tabout remit12m using "${gsdOutput}/Remit_raw4.4.xls", svy sum c(mean acc_bank2 se) f(3) sebnone h2("All Remittances and mobile money") append
tabout intremit12m_yn using "${gsdOutput}/Remit_raw4.4.xls" if hhr_gender==0, svy sum c(mean inc_savings se) f(3) sebnone h2("Int Remittances and savings, women") append
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw4.4.xls" if hhr_gender==0, svy sum c(mean inc_savings se) f(3) sebnone h2("Intl Remittances and savings, women") append
tabout remit12m using "${gsdOutput}/Remit_raw4.4.xls" if hhr_gender==0, svy sum c(mean inc_savings se) f(3) sebnone h2("All Remittances and savings, women") append
tabout intremit12m_yn using "${gsdOutput}/Remit_raw4.4.xls" if hhr_gender==1, svy sum c(mean inc_savings se) f(3) sebnone h2("Int Remittances and savings, men") append
tabout intlremit12m_yn using "${gsdOutput}/Remit_raw4.4.xls" if hhr_gender==1, svy sum c(mean inc_savings se) f(3) sebnone h2("Intl Remittances and savings, men") append
tabout remit12m using "${gsdOutput}/Remit_raw4.4.xls" if hhr_gender==1, svy sum c(mean inc_savings se) f(3) sebnone h2("All Remittances and savings, men") append
* regressions
svy: probit acc_bank1 intremit12m_yn hhsize tc_imp i.type
margins, dydx(intremit12m_yn) post
outreg2 using "${gsdOutput}/Remit_raw4.4_additional.xls", replace ctitle("Bank access") dec(3) label excel nocons keep(intremit*)
svy: probit acc_bank2 intremit12m_yn hhsize tc_imp i.type
margins, dydx(intremit12m_yn) post
outreg2 using "${gsdOutput}/Remit_raw4.4_additional.xls", append ctitle("Mobile money") dec(3) label excel nocons keep(intremit*)
svy: probit inc_savings intremit12m_yn hhsize tc_imp i.type
margins, dydx(intremit12m_yn) post
outreg2 using "${gsdOutput}/Remit_raw4.4_additional.xls", append ctitle("Savings") dec(3) label excel nocons keep(intremit*)
svy: probit acc_bank1 intlremit12m_yn hhsize tc_imp i.type
margins, dydx(intlremit12m_yn) post
outreg2 using "${gsdOutput}/Remit_raw4.4_additional.xls", append ctitle("Bank access") dec(3) label excel nocons keep(intlremit*)
svy: probit acc_bank2 intlremit12m_yn hhsize tc_imp i.type
margins, dydx(intlremit12m_yn) post
outreg2 using "${gsdOutput}/Remit_raw4.4_additional.xls", append ctitle("Mobile money") dec(3) label excel nocons keep(intlremit*)
svy: probit inc_savings intlremit12m_yn hhsize tc_imp i.type
margins, dydx(intlremit12m_yn) post
outreg2 using "${gsdOutput}/Remit_raw4.4_additional.xls", append ctitle("Savings") dec(3) label excel nocons keep(intlremit*)

insheet using "${gsdOutput}/Remit_raw4.4.xls", clear
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_4.4")
insheet using "${gsdOutput}/Remit_raw4.4_additional.txt", clear
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetmodify sheet("Raw_4.4") cell(E1)

* Remittance channels
use "${gsdData}/1-CleanOutput/hh.dta", clear
recode *remit_pcpd supp_som_pcpd(0=.)
svyset ea [pweight=weight], strata(strata) singleunit(centered)
foreach pre in "int" "intl" {
	la var `pre'remit_mode__1 "Mode: Bank"
	la var `pre'remit_mode__2 "Mode: Remittances company"
	la var `pre'remit_mode__3 "Mode: Mail"
	la var `pre'remit_mode__4 "Mode: Courier"
	la var `pre'remit_mode__5 "Mode: Internet"
	la var `pre'remit_mode__6 "Mode: Bank card"
	la var `pre'remit_mode__7 "Mode: travel of family member"
	la var `pre'remit_mode__8 "Mode: Bus/Minibus"
	la var `pre'remit_mode__9 "Mode: Mobile phone"
	
}
* Channels of receipt
tabout intlremit_mode__1 using "${gsdOutput}/Remit_raw4.5.xls" , svy percent c(col se) npos(col) sebnone h2("Intl remit mode 1") replace
foreach i of numlist 2/9 {
	tabout intlremit_mode__`i' using "${gsdOutput}/Remit_raw4.5.xls" , svy percent c(col se) npos(col) sebnone h2("Intl remit mode `i'") append
}
recode intremit_mode* (0=0) (1/9=1)
tabout intremit_mode__1 using "${gsdOutput}/Remit_raw4.5.xls" , svy percent c(col se) npos(col) sebnone h2("Int remit mode 1") append
foreach i of numlist 2/9 {
	tabout intremit_mode__`i' using "${gsdOutput}/Remit_raw4.5.xls" , svy percent c(col se) npos(col) sebnone h2("Int remit mode `i'") append
}
* Frequency of receipt
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset ea [pweight=weight], strata(strata) singleunit(centered)
tabout intremit_freq using "${gsdOutput}/Remit_raw4.5.xls" , svy percent c(col se) npos(col) sebnone h2("Int remit frequency") append
tabout intlremit_freq using "${gsdOutput}/Remit_raw4.5.xls" , svy percent c(col se) npos(col) sebnone h2("Intl remit frequency") append

* Change in receipt 
tabout intlremitmoreless using "${gsdOutput}/Remit_raw4.5.xls" , svy percent c(col se) npos(col) sebnone h2("Remittance change") append
tabout intlremitchange using "${gsdOutput}/Remit_raw4.5.xls" , svy percent c(col se) npos(col) sebnone h2("Change reason") append

insheet using "${gsdOutput}/Remit_raw4.5.xls", clear
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetreplace sheet("Raw_4.5")


* 4.5 Insurance against drought
use "${gsdData}/1-CleanOutput/hh.dta", clear
gen pweight=weight
svyset ea [pweight=pweight], strata(strata) singleunit(centered)
gen drought = shocks0__1
gen sallab = lhood==1 
gen remit = lhood==2 | lhood==5 
gen busi = lhood==7
gen ag = lhood==8
gen lintremit_usd = log(intremit12m_usd)
gen lintlremit_usd = log(intlremit12m_usd)
svy: reg lintremit_usd drought hhh_lit hhsize i.type i.reg_pess sallab busi remit ag tc_imp hhh_gender lfp_7d_hh i.tenure i.housingtype i.floor_material 
outreg2 using "${gsdOutput}/Remit_raw4.6.xls", replace ctitle("Remit + Drought") label excel 
svy: reg lintlremit_usd drought hhh_lit hhsize i.type i.reg_pess sallab busi remit ag tc_imp hhh_gender lfp_7d_hh i.tenure i.housingtype i.floor_material 
outreg2 using "${gsdOutput}/Remit_raw4.6.xls", append ctitle("Remit + Drought") label excel 
insheet using "${gsdOutput}/Remit_raw4.6.txt", clear
export excel using "${gsdOutput}/Remittances_Figures_v6.xlsx", sheetmodify sheet("Raw_4.6")



