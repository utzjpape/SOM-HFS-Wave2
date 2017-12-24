*clean and organize child file regarding non-food

set more off
set seed 23081380 
set sortseed 11041355


********************************************************************
*Clean and prepare non-food data
********************************************************************
use "${gsdData}/0-RawTemp/rnf_nonfood_valid_successful_complete.dta", clear
drop interview__key rnf_pric_zero rnf_pr_usdkg_low rnf_pr_usdkg_high rnf_free_other rnf_item_recall
drop if rnf_item_recall_int>=.
order interview__id rnf_nonfood__id rnf_item_recall rnf_item_recall_int rnf_pric_total_kdk rnf_pric_total rnf_pric_total_curr rnf_free_yn rnf_free_main

*Categorise missing values: "Don't know": -98 --> .a, "Refused to respond": -99 --> .b
labmv, mv(-99 .b  -98 .a) all
qui foreach var of varlist interview__id-rnf_free_main {
	local type = substr("`: type `var''", 1, 3) 
		if "`type'" != "str" { 
		recode `var' (-999999999 = .) 
}
}

*Introduce purchase dummy for each item
gen purc=1
label var purc "F.2 Item was purchased in recall period?"
label define lyesno 0 "No" 1 "Yes" .a "Don't know" .b "Refused to respond" .z "Not administered" 
label values purc lyesno
order purc, after(rnf_item_recall_int)

*Clean variables 
label define lrecall 1 "7 days" 2 "1 month" 3 "3 months" 4 "12 months"
label values rnf_item_recall_int lrecall

*Include skip patterns 
replace rnf_pric_total=.z if rnf_pric_total_kdk>=.
replace rnf_pric_total_curr=.z if rnf_pric_total>=. | rnf_pric_total==0
replace rnf_free_main=.z if rnf_free_yn!=1

*Label and rename 
foreach var in rnf_pric_total_kdk rnf_pric_total_curr rnf_free_yn rnf_free_main  {
	label define `var' .a "Don't know" .b "Refused to respond" .z "Not administered", modify
}
label var rnf_nonfood__id "Non-Food ID"
label var rnf_item_recall_int "Recall period"
rename (rnf_nonfood__id rnf_item_recall_int rnf_pric_total_kdk rnf_pric_total rnf_pric_total_curr rnf_free_yn rnf_free_main) (nfoodid recall pr_kdk pr pr_c free free_main )

*Include module assignment 
gen mod_item=0 if inlist(nfoodid,1001,1005,1007,1008,1009,1010,1013,1017,1018,1019,1023,1024,1026,1027,1028,1033,1035,1067,1068,1069,1070,1078,1079,1080,1082,1083,1084,1085,1086)
replace mod_item=1 if inlist(nfoodid,1015,1016,1020,1022,1032,1036,1039,1040,1046,1055,1064,1076,1077,1087)
replace mod_item=2 if inlist(nfoodid,1002,1006,1014,1038,1042,1045,1049,1051,1053,1059,1060,1073,1075,1088,1089)
replace mod_item=3 if inlist(nfoodid,1003,1011,1025,1029,1030,1031,1037,1041,1043,1047,1048,1050,1054,1061,1062,1074)
replace mod_item=4 if inlist(nfoodid,1004,1012,1021,1034,1044,1052,1056,1057,1058,1063,1065,1066,1072,1081,1090)
label var mod_item "Assignment of item to core/optional module"
order mod_item, after(nfoodid)

save "${gsdData}/0-RawTemp/hh_nfood_clean.dta", replace
