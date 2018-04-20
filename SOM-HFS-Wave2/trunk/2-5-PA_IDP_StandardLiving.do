*Wave 2 IDP analysis -- Standard of Living

************************
*HHQ indicators
************************
use "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", clear 
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

*1. Hunger and food aid (note: coping when hungry question not included in Somali tool)
*recode hunger 4 weeks
recode hunger (1=4 "Never") (2=3 "Rarely (1-2 times)") (3=2 "Sometimes (3-10 times)") (4=1 "Often (more than 10 times)"), gen(hunger_nores_new) lab(hunger_nores_new)
*Calculate reduced CSI Score (as per CSI Manual)
gen csi = cop_lessprefrerred *1 + cop_borrow_food*2 + cop_limitportion*1 + cop_limitadult*3 + cop_reducemeals*1
lab var csi "Reduced Coping Strategies Index (CSI) Score"
*Categorizing the CSI score
gen csi_cat=.
replace csi_cat=1 if csi<=3
replace csi_cat=2 if csi>3 & csi<=9 
replace csi_cat=3 if csi>=10 & !missing(csi)
assert csi_cat==. if csi==.
label define lcsicategories 1 "No or low" 2 "Medium" 3 "High"
label val csi_cat lcsicategories
label variable csi_cat "Reduced Coping Strategy Index (CSI) Score: Categorized"
*Reverse the scale of CSI score for intuitive graphing
sum csi
gen csi_invert = `r(max)' - csi
lab var csi_invert "Inverted CSI score"
*Reverse the scale of the CSI categories too
recode csi_cat (1=3 "No/low food insecurity") (2=2 "Medium food insecurity") (3=1 "High food insecurity"), gen(csi_cat_new)

*Hunger in last four weeks
qui tabout hunger_nores_new comparisonidp using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) replace h1("Hunger4weeks") f(4) 
qui tabout hunger_nores_new urbanrural using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("Hunger4weeks") f(4) 
qui tabout hunger_nores_new national using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("Hunger4weeks") f(4) 
qui tabout hunger_nores_new reasonidp using "${gsdOutput}/Raw_Fig15.xls", svy  percent c(col lb ub) npos(col) append h1("Hunger4weeks") f(4) 
qui tabout hunger_nores_new durationidp using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("Hunger4weeks") f(4) 
qui tabout hunger_nores_new timesidp using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("Hunger4weeks") f(4) 
qui tabout hunger_nores_new genidp using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("Hunger4weeks") f(4) 
qui tabout hunger_nores_new topbottomidp using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("Hunger4weeks") f(4) 

*CSI
qui tabout csi_cat_new comparisonidp using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("CSI") f(4) 
qui tabout csi_cat_new urbanrural using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("CSI") f(4) 
qui tabout csi_cat_new national using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("CSI") f(4) 
qui tabout csi_cat_new reasonidp using "${gsdOutput}/Raw_Fig15.xls", svy  percent c(col lb ub) npos(col) append h1("CSI") f(4) 
qui tabout csi_cat_new durationidp using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("CSI") f(4) 
qui tabout csi_cat_new timesidp using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("CSI") f(4) 
qui tabout csi_cat_new genidp using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("CSI") f(4) 
qui tabout csi_cat_new topbottomidp using "${gsdOutput}/Raw_Fig15.xls", svy percent c(col lb ub) npos(col) append h1("CSI") f(4) 

*2. Housing and WASH**
*3. Crowding
*4. Education**

*Place raw data into the excel figures file
foreach i of num 15 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
