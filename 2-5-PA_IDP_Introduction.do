*IDP analysis -- Overall drought and conflict stats 

import excel using "${gsdShared}/0-Auxiliary/UNHCR-PRMN-Displacement-Dataset.xlsx", clear firstrow
rename _all, lower

*Clean date
gen month = substr(monthend, 4,2)
gen year = substr(monthend, 7, 4)
egen monthyear = concat(year month), p(-)
ta monthyear
sort year month

*Get TOTAL displacement numbers by month
bys monthyear: egen disptotal = sum(numberofindividuals)
*Get CONFLICT displacement numbers by month
gen numberconflict = numberofindividuals if strpos(reason, "Conflict")
bys monthyear: egen dispconflict = sum(numberconflict) 
*Get DROUGHT displacement numbers by month
gen numberdrought = numberofindividuals if strpos(reason, "Drought")
bys monthyear: egen dispdrought = sum(numberdrought)
*Get Other displacement numbers by month
gen numberother = numberofindividuals if (strpos(reason, "Other") | strpos(reason, "Flood"))
bys monthyear: egen dispother = sum(numberother) 

*Sanity check
assert dispconflict + dispdrought + dispother == disptotal

*TABOUTS
qui tabout monthyear using "${gsdOutput}/Raw_Fig40.xls", sum c(mean disptotal) npos(col) replace h2("Total Displacements") f(4)
qui tabout monthyear using "${gsdOutput}/Raw_Fig41.xls", sum c(mean dispconflict) npos(col) replace h2("Conflict Displacements") f(4)
qui tabout monthyear using "${gsdOutput}/Raw_Fig42.xls", sum c(mean dispdrought) npos(col) replace h2("Drought Displacements") f(4)
qui tabout monthyear using "${gsdOutput}/Raw_Fig43.xls", sum c(mean dispother) npos(col) replace h2("Other Displacements") f(4)

*Location
bys currentregion: egen displocation = sum(numberofindividuals)
egen totaldisplacement = sum(numberofindividuals)
replace displocation = (displocation/totaldisplacement)*100
qui tabout currentregion using "${gsdOutput}/Raw_Fig44.xls", sum c(mean displocation) npos(col) replace h1("LocationPMRN")

*Place raw data into the excel figures file
foreach i of num 40/44 {
	insheet using "${gsdOutput}/Raw_Fig`i'.xls", clear nonames
	export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Raw_Fig`i'") 	
	rm "${gsdOutput}/Raw_Fig`i'.xls"
}
