*Find optimal threshold for each poverty line
local plines = "19 125 31"
foreach i of local plines {
	use "${gsdData}/1-CleanTemp/hhq.dta", clear
	*Add imputed total consumption aggregates as well as poverty line
	merge m:1 state ea hh using "${gsdData}/1-CleanTemp/hhq-poverty.dta", keep(match master) assert(match master) keepusing(pline*PPP tc_imp poor*PPP_prob ) nogenerate
	*rename 1.9 line for the loop
	rename (poorPPP_prob plinePPP) (poor19PPP_prob pline19PPP)
	keep urban weight hhsize tc_imp pline`i'PPP poor`i'PPP_prob
	*calculate differences in means over rural and urban strata
	forvalues u = 0/1 {
		forval n = 30/90 {
			gen poor`i'_`u'_`n' = poor`i'PPP_prob>0.`n' if !missing(tc_imp) & urban==`u'
			quietly mean poor`i'_`u'_`n' poor`i'PPP_prob [pweight=weight*hhsize] if urban==`u'
			gen diff_`u'_`n' = _b[poor`i'PPP_prob] - _b[poor`i'_`u'_`n'] 
		}
	}
	*generate a poorPPP for rural and urban for the collapse
	gen poorPPP_0=poor`i'PPP_prob if urban==0
	gen poorPPP_1=poor`i'PPP_prob if urban==1
	*collapse and reshape into long format to more easily calculate difference
	collapse poorPPP* poor`i'_?_?? [aw=weight*hhsize]
	reshape long poor`i'_0_ poor`i'_1_  , i(poorPPP_0 poorPPP_1) j(threshold)
	*replace by absolute value to get rid of negatives
	forvalues n = 0/1 {
		gen diff`n'=poorPPP_`n'-poor`i'_`n'_
		replace diff`n'=abs(diff`n')
	}
	*take the mean of the differences and keep the smallest value
	egen minimum_combined=rowmean(diff?)
	egen minimum_mean=min(minimum_combined)
	keep if minimum_mean==minimum_combined
	*with two thresholds of the same value take the lower one (doesn't make much of a difference)
	duplicates drop minimum_mean, force
	global threshold`i'=threshold
	di ${threshold`i'}
}
*optimal thresholds
display "1.9 PPP =" ${threshold19}
display "1.25 PPP =" ${threshold125}
display "3.1 PPP =" ${threshold31}
