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

*Recode for improved housing
gen housingimproved=inlist(housingtype,1,2,3,4,5) 
label var housingimproved "Household lives in improved housing"
gen housingimproveddisp = inlist(housingtype_disp,1,2,3,4,5)
label var housingimproveddisp "Household lives in improved housing pre displacement"

*Categorize water into improved and unimproved sources as per WASH Manual
gen waterimproved =  .
*Leave bottled water (10) as missing as it's only 0.15 percent and it's not clear how to categorize it.
replace waterimproved = 0 if inlist(drink_water, 4,8,10,11,12,13)
replace waterimproved = 1 if inlist(drink_water,1,2,3,5,6,7,9)
label variable waterimproved "Water source: Categorized (as per WASH Indicator manual)"
label define lwatersourcecat 0 "Unimproved" 1 "Improved" 
label values waterimproved lwatersourcecat

*Categorize toilet into improved and unimproved sources as per WASH Manual 
gen sanitationimproved = . 
replace sanitationimproved = 0 if inlist(toilet, 4,8,10,11,12)
replace sanitationimproved = 1 if inlist(toilet, 1,2,3,5,6,7,9)
label variable sanitationimproved "Sanitation facility: Categorized (as per WASH Indicator manual)"
label values sanitationimproved lwatersourcecat
codebook share_facility
ta sanitationimproved
codebook sanitationimproved
gen sanimproved_shared = sanitationimproved
replace sanimproved_shared=0 if share_facility==1
la var sanimproved_shared "Improved sanitation, adjusted for sharing"
la val sanimproved_shared lwatersourcecat
ta sanimproved_shared	

*Distance to facilities.
recode water_time thealth tedu tmarket t_water_disp thealth_disp t_edu_disp t_market_disp (1 2 =1 "Up to ten minutes") (3=3 "10 to 30 minutes") (4=4 "30 minutes to 1 hour") (5 6 7 8 9 = 4 "1 hour or more"), pre(new) lab(timelab)

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

*2. Housing
*Housing
qui tabout housingimproved comparisonidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) replace h1("HouseImproved") f(4) 
qui tabout housingimproved urbanrural using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("HouseImproved") f(4) 
qui tabout housingimproved national using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("HouseImproved") f(4) 
qui tabout housingimproved reasonidp using "${gsdOutput}/Raw_Fig16.xls", svy  percent c(col lb ub) npos(col) append h1("HouseImproved") f(4) 
qui tabout housingimproved durationidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("HouseImproved") f(4) 
qui tabout housingimproved timesidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("HouseImproved") f(4) 
qui tabout housingimproved genidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("HouseImproved") f(4) 
qui tabout housingimproved topbottomidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("HouseImproved") f(4) 

*Improved and unimproved housing before displacement -- IDPs only
qui tabout housingimproved comparisonidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproved reasonidp using "${gsdOutput}/Raw_Fig16.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproved durationidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproved timesidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproved genidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproved topbottomidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 

*No crowding graphs as we don't have number of rooms.

*WASH.
*Water Improved
qui tabout waterimproved comparisonidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) replace h1("WaterImproved") f(4) 
qui tabout waterimproved urbanrural using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("WaterImproved") f(4) 
qui tabout waterimproved national using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("WaterImproved") f(4) 
qui tabout waterimproved reasonidp using "${gsdOutput}/Raw_Fig17.xls", svy  percent c(col lb ub) npos(col) append h1("WaterImproved") f(4) 
qui tabout waterimproved durationidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("WaterImproved") f(4) 
qui tabout waterimproved timesidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("WaterImproved") f(4) 
qui tabout waterimproved genidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("WaterImproved") f(4) 
qui tabout waterimproved topbottomidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("WaterImproved") f(4) 

*Sanitation improved -- unadjusted for sharing
qui tabout sanitationimproved comparisonidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("ToiletImproved") f(4) 
qui tabout sanitationimproved urbanrural using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("ToiletImproved") f(4) 
qui tabout sanitationimproved national using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("ToiletImproved") f(4) 
qui tabout sanitationimproved reasonidp using "${gsdOutput}/Raw_Fig17.xls", svy  percent c(col lb ub) npos(col) append h1("ToiletImproved") f(4) 
qui tabout sanitationimproved durationidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("ToiletImproved") f(4) 
qui tabout sanitationimproved timesidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("ToiletImproved") f(4) 
qui tabout sanitationimproved genidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("ToiletImproved") f(4) 
qui tabout sanitationimproved topbottomidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("ToiletImproved") f(4) 

*Sanitation improved -- adjusted for sharing
qui tabout sanimproved_shared comparisonidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("sanimproved_shared") f(4) 
qui tabout sanimproved_shared urbanrural using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("sanimproved_shared") f(4) 
qui tabout sanimproved_shared national using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("sanimproved_shared") f(4) 
qui tabout sanimproved_shared reasonidp using "${gsdOutput}/Raw_Fig17.xls", svy  percent c(col lb ub) npos(col) append h1("sanimproved_shared") f(4) 
qui tabout sanimproved_shared durationidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("sanimproved_shared") f(4) 
qui tabout sanimproved_shared timesidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("sanimproved_shared") f(4) 
qui tabout sanimproved_shared genidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("sanimproved_shared") f(4) 
qui tabout sanimproved_shared topbottomidp using "${gsdOutput}/Raw_Fig17.xls", svy percent c(col lb ub) npos(col) append h1("sanimproved_shared") f(4) 

*Distance to facilities, currently.
*Water
qui tabout newwater_time comparisonidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) replace h1("Water") f(4) 
qui tabout newwater_time urbanrural using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Water") f(4) 
qui tabout newwater_time national using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Water") f(4) 
qui tabout newwater_time reasonidp using "${gsdOutput}/Raw_Fig18.xls", svy  percent c(col lb ub) npos(col) append h1("Water") f(4) 
qui tabout newwater_time durationidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Water") f(4) 
qui tabout newwater_time timesidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Water") f(4) 
qui tabout newwater_time genidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Water") f(4) 
qui tabout newwater_time topbottomidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Water") f(4) 

*Health
qui tabout newthealth comparisonidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Health") f(4) 
qui tabout newthealth urbanrural using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Health") f(4) 
qui tabout newthealth national using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Health") f(4) 
qui tabout newthealth reasonidp using "${gsdOutput}/Raw_Fig18.xls", svy  percent c(col lb ub) npos(col) append h1("Health") f(4) 
qui tabout newthealth durationidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Health") f(4) 
qui tabout newthealth timesidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Health") f(4) 
qui tabout newthealth genidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Health") f(4) 
qui tabout newthealth topbottomidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Health") f(4) 

*Education
qui tabout newtedu comparisonidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("School") f(4) 
qui tabout newtedu urbanrural using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("School") f(4) 
qui tabout newtedu national using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("School") f(4) 
qui tabout newtedu reasonidp using "${gsdOutput}/Raw_Fig18.xls", svy  percent c(col lb ub) npos(col) append h1("School") f(4) 
qui tabout newtedu durationidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("School") f(4) 
qui tabout newtedu timesidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("School") f(4) 
qui tabout newtedu genidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("School") f(4) 
qui tabout newtedu topbottomidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("School") f(4) 

*Market
qui tabout newtmarket comparisonidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Market") f(4) 
qui tabout newtmarket urbanrural using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Market") f(4) 
qui tabout newtmarket national using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Market") f(4) 
qui tabout newtmarket reasonidp using "${gsdOutput}/Raw_Fig18.xls", svy  percent c(col lb ub) npos(col) append h1("Market") f(4) 
qui tabout newtmarket durationidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Market") f(4) 
qui tabout newtmarket timesidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Market") f(4) 
qui tabout newtmarket genidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Market") f(4) 
qui tabout newtmarket topbottomidp using "${gsdOutput}/Raw_Fig18.xls", svy percent c(col lb ub) npos(col) append h1("Market") f(4) 

*Distance to facilities, pre displacement- For IDPs only.
*Water
qui tabout newt_water_disp comparisonidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) replace h1("Pre_Water") f(4) 
qui tabout newt_water_disp reasonidp using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 
qui tabout newt_water_disp durationidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 
qui tabout newt_water_disp timesidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 
qui tabout newt_water_disp genidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 
qui tabout newt_water_disp topbottomidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 

*Health
qui tabout newthealth_disp comparisonidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp reasonidp using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp durationidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp timesidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp genidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp topbottomidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 

*Education
qui tabout newt_edu_disp comparisonidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp reasonidp using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp durationidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp timesidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp genidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp topbottomidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 

*Market
qui tabout newt_market_disp comparisonidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Market") f(4) 
qui tabout newt_market_disp reasonidp using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Market") f(4) 
qui tabout newt_market_disp durationidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Market") f(4) 
qui tabout newt_market_disp timesidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Market") f(4) 
qui tabout newt_market_disp genidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Market") f(4) 
qui tabout newt_market_disp topbottomidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Market") f(4) 

*4. Education**
*6. Food aid

*Place raw data into the excel figures file
foreach i of num 15 16 17 18 19 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
