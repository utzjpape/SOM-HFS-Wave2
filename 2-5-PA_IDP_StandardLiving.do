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
gen housingimproved=inlist(housingtype,1,2,3,4) 
label var housingimproved "Household lives in improved housing"
gen housingimproveddisp = inlist(housingtype_disp,1,2,3,4)
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

*crowding of toilets.
gen toiletshare = share_num
replace toiletshare = 0 if share_facility ==2
ta toiletshare

************************
*Significance tests
************************
*Food security.
svy: prop csi_cat_new, over(sighost)
*p<0.01
lincom [_prop_1]idp - [_prop_1]host
*p<0.01
lincom [_prop_1]idp - [_prop_1]nonhost
*IDP and urbanrural
svy: prop csi_cat_new, over(sigrural)
*no sig.
lincom [_prop_1]idp - [_prop_1]rural
*p<0.01
lincom [_prop_1]idp - [_prop_1]urban
*IDP and national
svy: prop csi_cat_new, over(sigdt)
*p<0.01
lincom [_prop_1]idp - [_prop_1]national
*Camp noncamp
svy: prop csi_cat_new, over(sigcamp)
*no sig
lincom [_prop_1]camp - [_prop_1]noncamp
*Reason
svy: prop csi_cat_new, over(sigreason)
*no sig
lincom [_prop_1]conflict - [_prop_1]climate
*Protracted
svy: prop csi_cat_new, over(sigdur)
*no sig
lincom [_prop_1]unprot - [_prop_1]prot
*Multiple
svy: prop csi_cat_new, over(sigtime)
*p<0.01
lincom [_prop_1]once - [_prop_1]multiple
*HH Head
svy: prop csi_cat_new, over(siggen)
*no sig
lincom [_prop_1]woman - [_prop_1]man
*Quintile
svy: prop csi_cat_new, over(sigtb)
*p=0.109
lincom [_prop_1]top - [_prop_1]bottom

*Improved housing now and before.
*IDP and others
svy: mean housingimproved, over(sighost)
*p<0.01
lincom [housingimproved]idp - [housingimproved]host
*p<0.01
lincom [housingimproved]idp - [housingimproved]nonhost
*IDP and urbanrural
svy: mean housingimproved, over(sigrural)
*no sig.
lincom [housingimproved]idp - [housingimproved]rural
*p<0.01
lincom [housingimproved]idp - [housingimproved]urban
*IDP and national
svy: mean housingimproved, over(sigdt)
*p<0.01
lincom [housingimproved]idp - [housingimproved]national
*Are IDPs today worse off than IDPs before?
svy: mean housingimproved housingimproveddisp, over(sigrural)
*no sig. they're as badly off as before.
lincom [housingimproved]idp - [housingimproveddisp]idp
*Are IDP origin housing similar to rural now?
svy: mean housingimproved housingimproveddisp, over(sigrural)
*no sig; so yes, the two groups have similar housing
lincom [housingimproved]rural - [housingimproveddisp]idp
*Camp noncamp
svy: mean housingimproved, over(sigcamp)
*no sig
lincom [housingimproved]camp - [housingimproved]noncamp
*Reason
svy: mean housingimproved, over(sigreason)
*no sig
lincom [housingimproved]conflict - [housingimproved]climate
*Protracted
svy: mean housingimproved, over(sigdur)
*no sig
lincom [housingimproved]unprot - [housingimproved]prot
*Multiple
svy: mean housingimproved, over(sigtime)
*no sig
lincom [housingimproved]once - [housingimproved]multiple
*HH Head
svy: mean housingimproved, over(siggen)
*no sig
lincom [housingimproved]woman - [housingimproved]man
*Quintile
svy: mean housingimproved, over(sigtb)
*p<0.01
lincom [housingimproved]top - [housingimproved]bottom
*Have camp IDps lost more housing than noncamp IDPs?
svy: mean housingimproved housingimproveddisp, over(sigcamp)
*p<0.01
lincom [housingimproved]camp - [housingimproveddisp]camp
*no sig.
lincom [housingimproved]noncamp - [housingimproveddisp]noncamp
*Have the conflict IDPs lost more than drought?
svy: mean housingimproved housingimproveddisp, over(sigreason)
*no sig
lincom [housingimproved]conflict - [housingimproveddisp]conflict
*no sig
lincom [housingimproved]climate - [housingimproveddisp]climate
*Have the top lost more than the bottom?
svy: mean housingimproved housingimproveddisp, over(sigtb)
*no sig
lincom [housingimproved]top - [housingimproveddisp]top
*no sig
lincom [housingimproved]bottom - [housingimproveddisp]bottom

*Improved drinking water.
*IDP and others
svy: mean waterimproved, over(sighost)
*no sig.
lincom [waterimproved]idp - [waterimproved]host
*no sig.
lincom [waterimproved]idp - [waterimproved]nonhost
*IDP and urbanrural
svy: mean waterimproved, over(sigrural)
*p<0.01
lincom [waterimproved]idp - [waterimproved]rural
*no sig.
lincom [waterimproved]idp - [waterimproved]urban
*IDP and national
svy: mean waterimproved, over(sigdt)
*no sig.
lincom [waterimproved]idp - [waterimproved]national
*Camp noncamp
svy: mean waterimproved, over(sigcamp)
*no sig
lincom [waterimproved]camp - [waterimproved]noncamp
*Reason
svy: mean waterimproved, over(sigreason)
*no sig
lincom [waterimproved]conflict - [waterimproved]climate
*Protracted
svy: mean waterimproved, over(sigdur)
*no sig
lincom [waterimproved]unprot - [waterimproved]prot
*Multiple
svy: mean waterimproved, over(sigtime)
*no sig
lincom [waterimproved]once - [waterimproved]multiple
*HH Head
svy: mean waterimproved, over(siggen)
*no sig
lincom [waterimproved]woman - [waterimproved]man
*Quintile
svy: mean waterimproved, over(sigtb)
*p<0.01
lincom [waterimproved]top - [waterimproved]bottom

*Improved sanitation- unadjusted.
*IDP and others
svy: mean sanitationimproved, over(sighost)
*p<0.01.
lincom [sanitationimproved]idp - [sanitationimproved]host
*p<0.01.
lincom [sanitationimproved]idp - [sanitationimproved]nonhost
*IDP and urbanrural
svy: mean sanitationimproved, over(sigrural)
*p<0.01
lincom [sanitationimproved]idp - [sanitationimproved]rural
*p<0.01
lincom [sanitationimproved]idp - [sanitationimproved]urban
*IDP and national
svy: mean sanitationimproved, over(sigdt)
*no sig.
lincom [sanitationimproved]idp - [sanitationimproved]national
*Camp noncamp
svy: mean sanitationimproved, over(sigcamp)
*p<0.05
lincom [sanitationimproved]camp - [sanitationimproved]noncamp
*Reason
svy: mean sanitationimproved, over(sigreason)
*p<0.05
lincom [sanitationimproved]conflict - [sanitationimproved]climate
*Protracted
svy: mean sanitationimproved, over(sigdur)
*p<0.05
lincom [sanitationimproved]unprot - [sanitationimproved]prot
*Multiple
svy: mean sanitationimproved, over(sigtime)
*no sig
lincom [sanitationimproved]once - [sanitationimproved]multiple
*HH Head
svy: mean sanitationimproved, over(siggen)
*p<0.05
lincom [sanitationimproved]woman - [sanitationimproved]man
*Quintile
svy: mean sanitationimproved, over(sigtb)
*p<0.01
lincom [sanitationimproved]top - [sanitationimproved]bottom

**Improved sanitation- adjusted for sharing.
*Is it worse overall than the unadjusted?
svy: mean sanitationimproved sanimproved_shared , over(sighost)
*p<0.01
lincom [sanitationimproved]idp - [sanimproved_shared] idp
svy: mean sanitationimproved sanimproved_shared , over(sigrural)
*p<0.01
lincom [sanitationimproved]urban - [sanimproved_shared]urban
*p<0.01
lincom [sanitationimproved]rural - [sanimproved_shared]rural

bys sighost: ta share_facility
bys sigrural: ta share_facility

*IDP and others
svy: mean sanimproved_shared, over(sighost)
*p<0.01.
lincom [sanimproved_shared]idp - [sanimproved_shared]host
*p<0.01.
lincom [sanimproved_shared]idp - [sanimproved_shared]nonhost
*IDP and urbanrural
svy: mean sanimproved_shared, over(sigrural)
*p<0.01
lincom [sanimproved_shared]idp - [sanimproved_shared]rural
*p<0.01
lincom [sanimproved_shared]idp - [sanimproved_shared]urban
*IDP and national
svy: mean sanimproved_shared, over(sigdt)
*no sig.
lincom [sanimproved_shared]idp - [sanimproved_shared]national
*Camp noncamp
svy: mean sanimproved_shared, over(sigcamp)
*no sig
lincom [sanimproved_shared]camp - [sanimproved_shared]noncamp
*Reason
svy: mean sanimproved_shared, over(sigreason)
*marginally significant, p=0.108
lincom [sanimproved_shared]conflict - [sanimproved_shared]climate
*Protracted
svy: mean sanimproved_shared, over(sigdur)
*no sig
lincom [sanimproved_shared]unprot - [sanimproved_shared]prot
*Multiple
svy: mean sanimproved_shared, over(sigtime)
*no sig
lincom [sanimproved_shared]once - [sanimproved_shared]multiple
*HH Head
svy: mean sanimproved_shared, over(siggen)
*no sig
lincom [sanimproved_shared]woman - [sanimproved_shared]man
*Quintile
svy: mean sanimproved_shared, over(sigtb)
*no sig
lincom [sanimproved_shared]top - [sanimproved_shared]bottom

*Are certain IDP groups more crowded than others?
svy: mean toiletshare, over(sigcamp)
*no sig.
lincom [toiletshare]camp - [toiletshare]noncamp
svy: mean toiletshare, over(sigreason)
*p<0.01; climate IDPs share more.
lincom [toiletshare]conflict - [toiletshare]climate
svy: mean toiletshare, over(sigdur)
*p<0.1; nonprotracted share more.
lincom [toiletshare]prot - [toiletshare]unprot
svy: mean toiletshare, over(sigtime)
*no sig.
lincom [toiletshare]once - [toiletshare]multiple
svy: mean toiletshare, over(siggen)
*p<0.05, men share more than women.
lincom [toiletshare]man - [toiletshare]woman
svy: mean toiletshare, over(sigtb)
*p<0.01; bottom share more.
lincom [toiletshare]top - [toiletshare]bottom

***Distance to various facilities. Focussing only on 1 hour or more. That seems most policy relevant.
**Water
*IDP and host, now
svy: prop newwater_time, over(sighost)
*No sig
lincom [_prop_3]idp - [_prop_3]host
*IDP origin and now
svy: prop newwater_time newt_water_disp if sighost ==1
*p<0.1
lincom [_prop_3] - [_prop_6]
**Health
*IDP and host, now
svy: prop newthealth, over(sighost)
*p<0.05
lincom [_prop_3]idp - [_prop_3]host
*IDP origin and now
svy: prop newthealth newthealth_disp if sighost ==1
*no sig.
lincom [_prop_3] - [_prop_6]
**School
*IDP and host, now
svy: prop newtedu, over(sighost)
*p<0.05
lincom [_prop_3]idp - [_prop_3]host
*IDP origin and now
svy: prop newtedu newt_edu_disp if sighost ==1
*no sig.
lincom [_prop_3] - [_prop_6]
**Market
*IDP and host, now
svy: prop newtmarket, over(sighost)
*p<0.01
lincom [_prop_3]idp - [_prop_3]host
*IDP origin and now
svy: prop newtmarket newt_market_disp if sighost ==1
*no sig.
lincom [_prop_3] - [_prop_6]

*Distance to various facilities. Using camp, noncamp, hosts.
*Define sig group for this.
gen sig3 = comparisonidp
replace sig3 = . if inlist(comparisonidp, 2,5)
la val sig3 lcomparisonidp
ta sig3
la def sig3 1 "noncamp" 3 "camp" 4 "host"
la val sig3 sig3
ta sig3
**Water
svy: prop newwater_time, over(sig3)
*no sig.
lincom [_prop_3]camp - [_prop_3]host
*no sig.
lincom [_prop_3]noncamp - [_prop_3]host
*no sig.
lincom [_prop_3]noncamp - [_prop_3]camp
**Health
svy: prop newthealth, over(sig3)
*p<0.05; camp is farthest
lincom [_prop_3]camp - [_prop_3]host
*no sig.
lincom [_prop_3]noncamp - [_prop_3]host
*no sig.
lincom [_prop_3]noncamp - [_prop_3]camp
**School
svy: prop newtedu, over(sig3)
*p<0.1; camp is farthest
lincom [_prop_3]camp - [_prop_3]host
*no sig.
lincom [_prop_3]noncamp - [_prop_3]host
*no sig.
lincom [_prop_3]noncamp - [_prop_3]camp
*Market
svy: prop newtmarket, over(sig3)
*p<0.05; camp farthest
lincom [_prop_3]camp - [_prop_3]host
*p=0.106; camp farthest
lincom [_prop_3]noncamp - [_prop_3]host
*no sig.
lincom [_prop_3]noncamp - [_prop_3]camp

************************
*Tabouts
************************

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
qui tabout housingimproveddisp comparisonidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
*qui tabout housingimproveddisp urbanrural using "${gsdOutput}/Raw_Fig16.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproveddisp national using "${gsdOutput}/Raw_Fig16.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproveddisp reasonidp using "${gsdOutput}/Raw_Fig16.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproveddisp durationidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproveddisp timesidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproveddisp genidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 
qui tabout housingimproveddisp topbottomidp using "${gsdOutput}/Raw_Fig16.xls", svy percent c(col lb ub) npos(col) append h1("Pre_HouseImproved") f(4) 

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

*How many households share a toilet
qui tabout comparisonidp using "${gsdOutput}/Raw_Fig17.xls" if t ==1, svy sum c(mean toiletshare lb ub se) npos(col) append h2("ToiletShare") f(4)
qui tabout urbanrural using "${gsdOutput}/Raw_Fig17.xls" , svy sum c(mean toiletshare lb ub se) npos(col) append h2("ToiletShare") f(4)
qui tabout national using "${gsdOutput}/Raw_Fig17.xls" , svy sum c(mean toiletshare lb ub se) npos(col) append h2("ToiletShare") f(4)
qui tabout reasonidp using "${gsdOutput}/Raw_Fig17.xls" , svy sum c(mean toiletshare lb ub se) npos(col) append h2("ToiletShare") f(4)
qui tabout durationidp using "${gsdOutput}/Raw_Fig17.xls" , svy sum c(mean toiletshare lb ub se) npos(col) append h2("ToiletShare") f(4) 
qui tabout timesidp using "${gsdOutput}/Raw_Fig17.xls" , svy sum c(mean toiletshare lb ub se) npos(col) append h2("ToiletShare") f(4) 
qui tabout genidp using "${gsdOutput}/Raw_Fig17.xls" , svy sum c(mean toiletshare lb ub se) npos(col) append h2("ToiletShare") f(4) 
qui tabout topbottomidp using "${gsdOutput}/Raw_Fig17.xls" , svy sum c(mean toiletshare lb ub se) npos(col) append h2("ToiletShare") f(4) 

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
qui tabout newt_water_disp national using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 
qui tabout newt_water_disp national using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 
qui tabout newt_water_disp reasonidp using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 
qui tabout newt_water_disp durationidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 
qui tabout newt_water_disp timesidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 
qui tabout newt_water_disp genidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 
qui tabout newt_water_disp topbottomidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Water") f(4) 

*Health
qui tabout newthealth_disp comparisonidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp national using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp national using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp reasonidp using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp durationidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp timesidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp genidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 
qui tabout newthealth_disp topbottomidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Health") f(4) 

*Education
qui tabout newt_edu_disp comparisonidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp national using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp national using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp reasonidp using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp durationidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp timesidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp genidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 
qui tabout newt_edu_disp topbottomidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_School") f(4) 

*Market
qui tabout newt_market_disp comparisonidp using "${gsdOutput}/Raw_Fig19.xls", svy percent c(col lb ub) npos(col) append h1("Pre_Market") f(4) 
qui tabout newt_market_disp national using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Market") f(4) 
qui tabout newt_market_disp national using "${gsdOutput}/Raw_Fig19.xls", svy  percent c(col lb ub) npos(col) append h1("Pre_Market") f(4) 
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
