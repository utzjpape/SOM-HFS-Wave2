*******************************************************************************
* Get Hargeisa, Burco, and Mogadishu district data for wave 2
* Mogadishu
import delim "${gsdDataRaw}/Join_EAs_W2_PESS-Mog.txt", clear
keep psu_id strata_id region_n district_n town_n sub_dist_n combined_c hh
ren (strata_id combined_c hh) (strata ea_pess nhh_pess)
destring ea_pess, replace
save "${gsdTemp}/Join_EAs_W2_PESS-Mog.dta", replace
* Somaliland 
import delim "${gsdDataRaw}/Join_EAs_W2_NW.txt", clear
keep psu_id strata_id region_n district_n town_n sub_dist_n combined_c hh
ren (strata_id combined_c hh) (strata ea_pess nhh_pess)
save "${gsdTemp}/Join_EAs_W2_PESS_NW.dta", replace
/* Hargeisa
import delim "${gsdDataRaw}/Join_EAs_W2_PESS-Hargeisa.txt", clear
keep psu_id strata_id region_n district_n town_n sub_dist_n combined_c hh
ren (strata_id combined_c hh) (strata ea_pess nhh_pess)
save "${gsdTemp}/Join_EAs_W2_PESS-Hargeisa.dta", replace
* Burco
import delim "${gsdDataRaw}/Join_EAs_W2_PESS-Burco.txt", clear
keep psu_id strata_id region_n district_n town_n sub_dist_n combined_c hh
ren (strata_id combined_c hh) (strata ea_pess nhh_pess)
save "${gsdTemp}/Join_EAs_W2_PESS-Burco.dta", replace
* Put them all together and merge with Wave 2 data
append using "${gsdTemp}/Join_EAs_W2_PESS-Mog.dta"
append using "${gsdTemp}/Join_EAs_W2_PESS-Hargeisa.dta"
*/
* Put them all together and merge with Wave 2 data
append using "${gsdTemp}/Join_EAs_W2_PESS-Mog.dta"
ren psu_id ea
merge 1:1 ea using "${gsdTemp}/ea_anonkey.dta", keep(match) nogen
drop ea rand
ren ea_anon ea
merge 1:m ea using "${gsdData}/1-CleanOutput/hh.dta", keep(match using) nogen keepusing(strata ea block hh type ind_profile)
* Let's see which EAs PESS considers Mog but we didn't
ta ind_profile if region_n=="Banadir"
save "${gsdData}/1-CleanTemp/hh-PESS_district.dta", replace

/* Obtain PESS district names for Wave 1
import delim "${gsdDataRaw}/Join_EAs_W1_urban.txt", clear
keep region_n district_n town_n sub_dist_n ea
duplicates drop ea, force
tostring ea, gen(ea_alt) format(%f30)
merge 1:1 ea using "${gsdData}/1-CleanInput/SHFS2016/ea_anonkey.dta"
*/


* Identify which EAs in Mogadishu are outside of Banadir in Wave 1
import excel using "${gsdShared}\0-Auxiliary\Administrative Maps\Wave1_Admin2.xls", clear firstrow
keep admin1Name team strata ea block hh
ren admin1Name region_alt 
save "${gsdData}/1-CleanTemp/Wave1_Admin1.dta", replace
ta region_alt if team==2
