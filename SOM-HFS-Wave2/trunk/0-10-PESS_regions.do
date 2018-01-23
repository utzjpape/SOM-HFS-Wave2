*Create region assignment for the Poverty Assessment

set more off 
set seed 23081930 
set sortseed 11041255


use "${gsdData}/0-RawTemp/hh_sweights.dta", clear

********************************************************************
*Indicator variables as in Wave 1
********************************************************************
gen ind_profile=1 if strata==37
replace ind_profile=2 if strata==39 | strata==41 | strata==43
replace ind_profile=3 if strata==45 | strata==49 | strata==51
replace ind_profile=3 if type==1 & (strata==46 | strata==47)
replace ind_profile=4 if strata==38 | strata==40 | strata==42 
replace ind_profile=5 if strata==44 | strata==48 |  strata==50
replace ind_profile=5 if type==2 & (strata==46 | strata==47)
replace ind_profile=6 if inlist(strata,1,3,4,5,6,7)
replace ind_profile=7 if strata==26 | strata==28 |  strata==30
replace ind_profile=8 if strata==25 | strata==27 |  strata==29
replace ind_profile=9 if strata==31 | strata==33 |  strata==36
replace ind_profile=10 if strata==32 | strata==34 |  strata==35
replace ind_profile=11 if strata==52 | strata==54 |  strata==57
replace ind_profile=12 if strata==53 | strata==55 |  strata==56
replace ind_profile=13 if inlist(strata,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24)
label define lind_profile 1 "Mogadishu (Urban)" 2 "North-east Urban (Nugaal,Bari,Mudug)" 3 "North-west Urban (Woqooyi G,Awdal,Sanaag,Sool,Togdheer)" 4 "North-east Rural (Bari,Mudug,Nugaal)" 5 "North-west Rural (Awdal,Sanaag,Sool,Togdheer,Woqooyi)" 6 "IDP Settlements" 7 "Central regions Urban (Hiraan, Middle Shabelle, Galgaduud)" 8 "Central regions Rural (Hiraan, Middle Shabelle, Galgaduud)" 9 "Jubbaland Urban (Gedo, lower and middle Juba)" 10 "Jubbaland Rural (Gedo, lower and middle Juba)" 11 "South West Urban (Bay, Bakool and lower Shabelle)" 12 "South West Rural (Bay, Bakool and lower Shabelle)" 13 "Nomadic population"
label values ind_profile lind_profile
label var ind_profile "Indicator of regional breakdown"
order ind_profile, after(weight)
save "${gsdData}/0-RawTemp/hh_for_anon.dta", replace


********************************************************************
*Obtain dta files from shapefiles by PESS region to create maps in the analysis  
********************************************************************
*Shape and dbf files are coming from http://www.diva-gis.org/gdata
shp2dta using "${gsdDataRaw}/SOM_adm1", database("${gsdData}/1-CleanInput/SOM_db") coordinates("${gsdData}/1-CleanInput/SOM_coord") replace genid(id_map)


********************************************************************
*Include the population from PESS 
********************************************************************
import excel "${gsdDataRaw}/PESS_population.xlsx", firstrow case(lower) clear
save "${gsdData}/1-CleanInput/PESS_population.dta", replace


********************************************************************
*Include the files from Wave 1 into 1-CleanInput 
********************************************************************
foreach dataset in "hh" "hhm" "food" "nonfood" "assets" "hhq-poverty" {
	use "${gsdDataRaw}/Wave_1/`dataset'.dta", clear
	cap ren reg_pess reg_pess_old
	cap recode reg_pess_old (1=1 "Awdal") (2=3 "Banadir") (3=4 "Bari") (4=11 "Mudug") (5=12 "Nugal") (6=13 "Sanaag") (7=16 "Sool") (8=17 "Togdheer") (9=18 "Woqooyi Galbeed"), gen(reg_pess)
	cap label reg_pess "Region (PESS)"
	cap drop reg_pess_old
	save "${gsdData}/1-CleanInput/SHFS2016/`dataset'.dta", replace
}

