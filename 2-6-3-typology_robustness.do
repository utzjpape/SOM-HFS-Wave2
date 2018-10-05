*This do file runs robustness checks for the typology of IDPs

use "${gsdTemp}/working_file.dta", clear

*********************************************
*Excluding a share of the sample: 2 cluster
*********************************************
use "${gsdTemp}/working_file.dta", clear
preserve 
qui foreach x in "10" "15"  "25"  "35"  {
	use "${gsdTemp}/working_file.dta", clear
	set seed 35435 
	set sortseed 64563
	gen rand=uniform()
	sort rand 
	cumul rand, gen (rand_distribution) equal
	drop if rand_distribution<=0.`x'
	cluster wardslinkage a1 a2, gen(clust_var_`x')
	cluster tree, cutnumber(50)
	cluster stop
	cluster stop, rule(duda) 
	cluster generate cluster_group_war_`x' = group(2)
	tab cluster_group_war_`x' , m
	label values cluster_group_war_`x' cluster
	save "${gsdTemp}/robust_check_`x'.dta", replace
}
use "${gsdTemp}/working_file.dta", clear
foreach x in "10" "15" "25" "35"  {
	merge 1:1 strata ea block hh using "${gsdTemp}/robust_check_`x'.dta", keepusing(cluster_group_war_`x')
	rename _merge check_`x'
	tab cluster_group_war cluster_group_war_`x'
}
restore

*********************************************
*Excluding a share of the sample: 3 cluster
*********************************************
use "${gsdTemp}/working_file.dta", clear
preserve 
qui foreach x in "10" "15"  "25"  "35"  {
	use "${gsdTemp}/working_file.dta", clear
	set seed 35435 
	set sortseed 64563
	gen rand=uniform()
	sort rand 
	cumul rand, gen (rand_distribution) equal
	drop if rand_distribution<=0.`x'
	cluster wardslinkage a1 a2, gen(clust_var_`x')
	cluster tree, cutnumber(50)
	cluster stop
	cluster stop, rule(duda) 
	cluster generate cluster_group_war_`x' = group(3)
	tab cluster_group_war_`x' , m
	label values cluster_group_war_`x' cluster
	save "${gsdTemp}/robust_check_`x'.dta", replace
}
use "${gsdTemp}/working_file.dta", clear
foreach x in "10" "15" "25" "35"  {
	merge 1:1 strata ea block hh using "${gsdTemp}/robust_check_`x'.dta", keepusing(cluster_group_war_`x')
	rename _merge check_`x'
	tab cluster_group_war3 cluster_group_war_`x'
}
restore
