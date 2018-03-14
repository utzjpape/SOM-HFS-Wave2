*Wave 2 IDP analysis -- Demographic profile

*setup data
use "${gsdData}/1-CleanTemp/hh_all.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)

********************************************************
*Make comparison groups in HHQ.
********************************************************

*1. IDPs and host communities.
gen comparisonidp = . 
la def lcomparisonidp 1 "Non-Camp IDP" 2 "Camp IDP 2016" 3 "Camp IDP" 4 "Host" 5 "Non-host" 
replace comparisonidp = 1 if  migr_idp ==1 & t ==1 & ind_profile != 6
replace comparisonidp = 2 if t ==0 & ind_profile ==6
replace comparisonidp = 3 if migr_idp ==1 & t ==1 & ind_profile == 6
replace comparisonidp = 4 if type_idp_host == 2 & t==1 & migr_idp !=1
replace comparisonidp = 5 if type ==1 & type_idp_host !=2 & t==1 & migr_idp !=1
la val comparisonidp lcomparisonidp
la var comparisonidp "IDPs and Host Community types"

*2. Urban, Rural, National (to get national, tabout over t.), without noncamp IDPs
gen urbanrural = type
replace urbanrural = . if migr_idp ==1
replace urbanrural = . if t ==0
replace urbanrural =. if !inlist(type, 1,2)
la val urbanrural ltype
la var urbanrural "Urban or rural (excludes IDPs and Nomads)"

*3. W2 Camp IDP disaggregations
gen genidp = hhh_gender
replace genidp =. if !(migr_idp ==1 & t ==1 & ind_profile == 6)
la var genidp "HHH Gender of W2 Camp IDP"

xtile quintileidp = tc_imp [pweight=weight_cons*hhsize] if (migr_idp ==1 & t ==1 & ind_profile == 6), nquantiles(5)
la var quintileidp "Quintiles for imputed consumption of W2 Camp IDP"
la val quintileidp lquintiles_tc

save "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", replace 

********************************************************
*Merge comparison groups to HHM
********************************************************
use "${gsdData}/1-CleanTemp/hhm_all.dta", clear 
svyset ea [pweight=weight_adj], strata(strata)
merge m:1 strata ea block hh using "${gsdData}/1-CleanTemp/hh_all_idpanalysis.dta", assert(match) nogen keepusing( comparisonidp urbanrural genidp quintileidp)
save "${gsdData}/1-CleanTemp/hhm_all_idpanalysis.dta", replace
