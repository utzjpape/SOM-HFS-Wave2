*clean and organize child file regarding illness of household members

set more off
set seed 23081990 
set sortseed 11041975

use "${gsdData}/0-RawTemp/hhm_c_illnesses_valid.dta", clear

label var r_illness_id "Illness"
label define illnessname 0  "No illness"  1  "Malaria"  2  "Diarrhoea"  3  "Stomach ache"  4  "Vomiting"  5  "Sore throat"  6  "Upper respiratory (sinuses)"  7  "Lower respiratory (chest, lungs)"  8  "Flu"  9  "Asthma"  10  "Headache"  11  "Fainting"  12  "Skin problem"  13  "Dental problem"  14  "Eye problem"  15  "Ear/nose/throat"  16  "Backache"  17  "Blood pressure"  18  "Pain when passing urine"  19  "Diabetes"  20  "Mental disorder"  21  "TB (tuberculosis)"  22  "Sexually transmitted disease"  23  "Burn"  24  "Fracture"  25  "Wound"  26  "Poisoning"  27  "Unspecified long-term illness"  28  "Typhoid"  29  "Rheumatism"  30  "Yellow fever"  31  "Sick but no diagnosis"  -98  "Don't know"  -99  " Refused to respond"
label values r_illness_id illnessname
label var r_illness_id "Illness"

drop child_key setofillnesses r_illness_pos r_illness_name1 r_illness_name2
label var key "Key to merge with parent"
order key 

*drop empty variables
missings dropvars, force 

*drop variables with open answers, multiple numeric entries and/or in Somali
*drop diagnosis_spec cure_spec

save "${gsdData}/0-RawTemp/hhm_c_illnesses_clean.dta", replace
