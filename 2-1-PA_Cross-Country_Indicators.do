*Purpose: obtain cross-country indicators for the Somali Poverty Profile 2016

set more off
set seed 23081980 
set sortseed 11041955


*****************************************
************* INSTRUCTIONS **************
*****************************************

* If you want to add a new variable follow the next steps:

* 1) Look for the full name and code under "Indicators - All series" using the "db wbopendata" command directly in Stata 

* 2) Define a short name for the new variable like "poverty" or "gini"(not previously used)

* 3) At the end of the "if" loop in section A) include two additional lines of code; one with the "wbopendata" command including the "code - full name" (in that format) for the 
*    new variable in parenthesis where referenced for the indicator, "indicator()". The second line should be to save the dataset in the Temp folder with the format
*    "WB_data_XX", where XX corresponds to the short name of the new variable 

* 4) Include the short name of the new variable in the "foreach" loop of Section B)

* 5) Include two lines of code after the last "else if" in loop of Section B). This will be anoter "else if" loop using the short name of the new variable and 
*	 the original name of the variable (substituting dots . for underscores _ in & upper cases for lower cases in the original name), as it appears in the dataset 

* 6) Include the short name of the new variable in the "foreach" loop of Section C)

* 7) Finally, set the local "runimport" equal to 1 so that the import process takes place when running the code 


*****************************************
********** A) IMPORT THE DATA ***********
*****************************************

*decide if we want to re-import the data 
local runimport = 1

*obtain the data for each variable
if (`runimport'==1) {

	*make sure the wbopendata command is available
	set checksum off, permanently
	ssc install wbopendata

	*sourcing from WB Open data to Temp in dta file 
	wbopendata, language(en - English) country() topics() indicator(SI.POV.DDAY - Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)) clear long
	save "${gsdTemp}/WB_data_poverty.dta", replace
	wbopendata, language(en - English) country() topics() indicator(SI.POV.GAPS - Poverty gap at $1.90 a day (2011 PPP) (%)) clear long
	save "${gsdTemp}/WB_data_gap.dta", replace
	wbopendata, language(en - English) country() topics() indicator(SI.POV.GINI - GINI index (World Bank estimate)) clear long
	save "${gsdTemp}/WB_data_gini.dta", replace
	wbopendata, language(en - English) country() topics() indicator(BX.TRF.PWKR.CD.DT - Personal remittances, received (current US$)) clear long
	save "${gsdTemp}/WB_data_remittances.dta", replace
	wbopendata, language(en - English) country() topics() indicator(SP.POP.TOTL - Population, total) clear long
	save "${gsdTemp}/WB_data_population.dta", replace
	wbopendata, language(en - English) country() topics() indicator(SL.TLF.ACTI.ZS - Labor force participation rate, total (% of total population ages ages 15-64) (modeled ILO estimate)) clear long
	save "${gsdTemp}/WB_data_lfp.dta", replace 				 
	wbopendata, language(en - English) country() topics() indicator(NY.GDP.PCAP.PP.CD - GDP per capita, PPP (current international $)) clear long
	save "${gsdTemp}/WB_data_gdppc.dta", replace
	wbopendata, language(en - English) country() topics() indicator(NY.GDP.PCAP.CD - GDP per capita (current $)) clear long
	save "${gsdTemp}/WB_data_gdppc_c.dta", replace
	wbopendata, language(en - English) country() topics() indicator(SL.EMP.TOTL.SP.ZS - Employment to population ratio, 15+, total (%) (modeled ILO estimate)) clear long
	save "${gsdTemp}/WB_data_employment.dta", replace 			
	wbopendata, language(en - English) country() topics() indicator(SE.ADT.LITR.ZS - Adult literacy rate, population 15+ years, both sexes (%)) clear long
	save "${gsdTemp}/WB_data_adult_literacy_rate.dta", replace
	wbopendata, language(en - English) country() topics() indicator(SE.PRM.NENR - Net enrolment rate, primary, both sexes (%)) clear long
	save "${gsdTemp}/WB_data_enrollment_primary.dta", replace 
   	wbopendata, language(en - English) country() topics() indicator(SE.PRM.CUAT.ZS - Completed primary education, (%) of population aged 25+) clear long
	save "${gsdTemp}/WB_data_attainment_primary.dta", replace 
	wbopendata, language(en - English) country() topics() indicator(SE.SEC.CUAT.LO.ZS - Completed lower secondary education, (%) of population aged 25+) clear long
	save "${gsdTemp}/WB_data_attainment_secondary.dta", replace 
	wbopendata, language(en - English) country() topics() indicator(SH.H2O.SAFE.ZS - Access to an improved water source, (%) of population) clear long
	save "${gsdTemp}/WB_data_improved_water.dta", replace
	wbopendata, language(en - English) country() topics() indicator(SH.STA.ACSN - Access to improved sanitation facilities , (%) of population) clear long
	save "${gsdTemp}/WB_data_improved_sanitation.dta", replace 
	wbopendata, language(en - English) country() topics() indicator(1.1_ACCESS.ELECTRICITY.TOT - Access to electricity (% of total population)) clear long
	save "${gsdTemp}/WB_data_electricity.dta", replace 
	wbopendata, language(en - English) country() topics() indicator(VC.IDP.NWCV - Internally displaced persons, new displacement associated with conflict and violence (number of cases)) clear long
	save "${gsdTemp}/WB_data_idps_conflict.dta", replace 
	wbopendata, language(en - English) country() topics() indicator(VC.IDP.NWDS - Internally displaced persons, new displacement associated with disasters (number of cases)) clear long
	save "${gsdTemp}/WB_data_idps_disaster.dta", replace 
	wbopendata, language(en - English) country() topics() indicator(VC.IDP.TOCV - Internally displaced persons, total displaced by conflict and violence (number of people)) clear long
	save "${gsdTemp}/WB_data_idps_total.dta", replace 
}


****************************************
******** B) PROCESS THE DATA ***********
****************************************

*for each variable obtain the latest figures and year available
foreach indicator in poverty gap gini remittances population lfp gdppc gdppc_c employment adult_literacy_rate enrollment_primary attainment_primary attainment_secondary improved_water improved_sanitation electricity idps_conflict idps_disaster idps_total {
	use "${gsdTemp}/WB_data_`indicator'.dta", clear

		if "`indicator'" == "poverty" {
		rename si_pov_dday `indicator'
		}
		else if "`indicator'" == "gap" {
		rename si_pov_gaps `indicator'
		}
		else if "`indicator'" == "gini" {
		rename si_pov_gini `indicator'
		}
		else if "`indicator'" == "remittances" {
		rename bx_trf_pwkr_cd_dt `indicator'
		}
		else if "`indicator'" == "population" {
		rename sp_pop_totl `indicator'
		}
		else if "`indicator'" == "lfp" {
		rename sl_tlf_acti_zs `indicator'
		}
		else if "`indicator'" == "gdppc" {
		rename ny_gdp_pcap_pp_cd `indicator'
		}	
		else if "`indicator'" == "gdppc_c" {
		rename ny_gdp_pcap_cd `indicator' 
		}
		else if "`indicator'" == "employment" {
		rename sl_emp_totl_sp_zs `indicator' 
		}
		else if "`indicator'" == "adult_literacy_rate" {
		rename se_adt_litr_zs `indicator' 
		}
		else if "`indicator'" == "enrollment_primary" {
		rename se_prm_nenr `indicator' 
		}
		else if "`indicator'" == "attainment_primary" {
		rename se_prm_cuat_zs `indicator' 
		}
		else if "`indicator'" == "attainment_secondary" {
		rename se_sec_cuat_lo_zs `indicator' 
		}
		else if "`indicator'" == "improved_water" {
		rename sh_h2o_safe_zs `indicator' 
		}
		else if "`indicator'" == "improved_sanitation" {
		rename sh_sta_acsn `indicator' 
		}
		else if "`indicator'" == "electricity" {
		rename v1_1_access_electric `indicator' 
		}
		else if "`indicator'" == "idps_conflict" {
		rename vc_idp_nwcv `indicator' 
		}
		else if "`indicator'" == "idps_disaster" {
		rename vc_idp_nwds `indicator' 
		}		
		else if "`indicator'" == "idps_total" {
		rename vc_idp_tocv `indicator' 
		}
	   		
		
	bysort countryname: egen l_y_`indicator'=max(year) if !missing(`indicator')
	keep if year==l_y_`indicator'
	keep countryname countrycode l_y_`indicator' `indicator' 

	save "${gsdTemp}/WB_clean_`indicator'.dta", replace 
}



****************************************
********* C) EXPORT THE DATA ***********
****************************************

*integrate the final dataset and export it to excel 
use "${gsdTemp}/WB_clean_poverty.dta", clear
foreach indicator in gap gini remittances population lfp gdppc gdppc_c employment adult_literacy_rate enrollment_primary attainment_primary attainment_secondary improved_water improved_sanitation electricity idps_conflict idps_disaster idps_total {
	merge 1:1 countryname using "${gsdTemp}\WB_clean_`indicator'.dta", nogen
}
save "${gsdTemp}/WB_clean_all.dta", replace 

