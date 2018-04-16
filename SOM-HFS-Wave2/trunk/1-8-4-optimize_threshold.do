*Find optimal threshold for the US$ 1.9 PPP poverty line

set more off
set seed 23081985 
set sortseed 11041985


********************************************************************
*US 1.9 PPP Poverty Line
********************************************************************
use "${gsdData}/1-CleanTemp/hh.dta", clear
*Add imputed total consumption aggregates as well as poverty line
merge m:1 strata ea hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", assert(match) keepusing(pline*PPP tc_imp poor*PPP_prob ) nogene
*Rename 1.9 line for the loop
rename (poorPPP_prob plinePPP) (poor19PPP_prob pline19PPP)
keep type ind_profile weight hhsize tc_imp pline19PPP poor19PPP_prob

*Calculate differences in means for each region
levelsof ind_profile, local(region) 
qui foreach i of local region {
	 forval n = 30/90 {
			gen poor19_`i'_`n' = poor19PPP_prob>0.`n' if !missing(tc_imp) &  ind_profile==`i'
			quietly mean poor19_`i'_`n' poor19PPP_prob [pweight=weight*hhsize] if ind_profile==`i'
			gen diff_`i'_`n' = _b[poor19PPP_prob] - _b[poor19_`i'_`n'] 
	}
}

*Generate a poorPPP for each region for the collapse
gen poorPPP_1=poor19PPP_prob if ind_profile==1
gen poorPPP_2=poor19PPP_prob if ind_profile==2
gen poorPPP_3=poor19PPP_prob if ind_profile==3
gen poorPPP_4=poor19PPP_prob if ind_profile==4
gen poorPPP_5=poor19PPP_prob if ind_profile==5
gen poorPPP_6=poor19PPP_prob if ind_profile==6
gen poorPPP_7=poor19PPP_prob if ind_profile==7
gen poorPPP_8=poor19PPP_prob if ind_profile==8
gen poorPPP_9=poor19PPP_prob if ind_profile==9
gen poorPPP_11=poor19PPP_prob if ind_profile==11
gen poorPPP_12=poor19PPP_prob if ind_profile==12
gen poorPPP_13=poor19PPP_prob if ind_profile==13
	
*Collapse and reshape into long format to more easily calculate difference
collapse (mean) poorPPP_* poor19_1_* poor19_2_* poor19_3_* poor19_4_* poor19_5_* poor19_6_* poor19_7_* poor19_8_* poor19_9_* poor19_11_* poor19_12_* poor19_13_*  [aw=weight*hhsize], by(ind_profile)

levelsof ind_profile, local(region) 
qui foreach i of local region {
	
	preserve 
	keep if ind_profile==`i'
	reshape long poor19_`i'_ , i(poorPPP_`i') j(threshold)
	gen diff`i'=poorPPP_`i'-poor19_`i'_
	replace diff`i'=abs(diff`i')
	*Take the mean of the differences and keep the smallest value
	egen minimum_combined=rowmean(diff`i')
	egen minimum_mean=min(minimum_combined)
	keep if minimum_mean==minimum_combined
	duplicates drop ind_profile poor19_`i'_ diff`i', force
	gen pline=1.9
	keep ind_profile threshold pline
    save "${gsdTemp}/threshold_19_`i'.dta", replace
	restore
}
	
use "${gsdTemp}/threshold_19_1.dta", clear
append using "${gsdTemp}/threshold_19_2.dta"
append using "${gsdTemp}/threshold_19_3.dta"
append using "${gsdTemp}/threshold_19_4.dta"
append using "${gsdTemp}/threshold_19_5.dta"
append using "${gsdTemp}/threshold_19_6.dta"
append using "${gsdTemp}/threshold_19_7.dta"
append using "${gsdTemp}/threshold_19_8.dta"
append using "${gsdTemp}/threshold_19_9.dta"
append using "${gsdTemp}/threshold_19_11.dta"
append using "${gsdTemp}/threshold_19_12.dta"
append using "${gsdTemp}/threshold_19_13.dta"
save "${gsdTemp}/threshold_19_optimal.dta", replace



********************************************************************
*Food poverty line (from food cons share) and 1.9 PPP 
********************************************************************
use "${gsdData}/1-CleanTemp/hh.dta", clear
*Add imputed total consumption aggregates as well as poverty line
merge m:1 strata ea hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", assert(match) keepusing(plinePPPFood tc_imp poorPPPFood_prob) nogene
*Rename Food poverty line to 1.9 line for the loop
rename (poorPPPFood_prob plinePPPFood) (poor19PPP_prob pline19PPP)
keep type ind_profile weight hhsize tc_imp pline19PPP poor19PPP_prob

*Calculate differences in means for each region
levelsof ind_profile, local(region) 
qui foreach i of local region {
	 forval n = 30/90 {
			gen poor19_`i'_`n' = poor19PPP_prob>0.`n' if !missing(tc_imp) &  ind_profile==`i'
			quietly mean poor19_`i'_`n' poor19PPP_prob [pweight=weight*hhsize] if ind_profile==`i'
			gen diff_`i'_`n' = _b[poor19PPP_prob] - _b[poor19_`i'_`n'] 
	}
}

*Generate a poorPPP for each region for the collapse
gen poorPPP_1=poor19PPP_prob if ind_profile==1
gen poorPPP_2=poor19PPP_prob if ind_profile==2
gen poorPPP_3=poor19PPP_prob if ind_profile==3
gen poorPPP_4=poor19PPP_prob if ind_profile==4
gen poorPPP_5=poor19PPP_prob if ind_profile==5
gen poorPPP_6=poor19PPP_prob if ind_profile==6
gen poorPPP_7=poor19PPP_prob if ind_profile==7
gen poorPPP_8=poor19PPP_prob if ind_profile==8
gen poorPPP_9=poor19PPP_prob if ind_profile==9
gen poorPPP_11=poor19PPP_prob if ind_profile==11
gen poorPPP_12=poor19PPP_prob if ind_profile==12
gen poorPPP_13=poor19PPP_prob if ind_profile==13
	
*Collapse and reshape into long format to more easily calculate difference
collapse (mean) poorPPP_* poor19_1_* poor19_2_* poor19_3_* poor19_4_* poor19_5_* poor19_6_* poor19_7_* poor19_8_* poor19_9_* poor19_11_* poor19_12_* poor19_13_*  [aw=weight*hhsize], by(ind_profile)

levelsof ind_profile, local(region) 
qui foreach i of local region {
	
	preserve 
	keep if ind_profile==`i'
	reshape long poor19_`i'_ , i(poorPPP_`i') j(threshold)
	gen diff`i'=poorPPP_`i'-poor19_`i'_
	replace diff`i'=abs(diff`i')
	*Take the mean of the differences and keep the smallest value
	egen minimum_combined=rowmean(diff`i')
	egen minimum_mean=min(minimum_combined)
	keep if minimum_mean==minimum_combined
	duplicates drop ind_profile poor19_`i'_ diff`i', force
	gen pline="Food"
	keep ind_profile threshold pline
    save "${gsdTemp}/threshold_Food_`i'.dta", replace
	restore
}
	
use "${gsdTemp}/threshold_Food_1.dta", clear
append using "${gsdTemp}/threshold_Food_2.dta"
append using "${gsdTemp}/threshold_Food_3.dta"
append using "${gsdTemp}/threshold_Food_4.dta"
append using "${gsdTemp}/threshold_Food_5.dta"
append using "${gsdTemp}/threshold_Food_6.dta"
append using "${gsdTemp}/threshold_Food_7.dta"
append using "${gsdTemp}/threshold_Food_8.dta"
append using "${gsdTemp}/threshold_Food_9.dta"
append using "${gsdTemp}/threshold_Food_11.dta"
append using "${gsdTemp}/threshold_Food_12.dta"
append using "${gsdTemp}/threshold_Food_13.dta"
save "${gsdTemp}/threshold_Food_optimal.dta", replace
	
	
