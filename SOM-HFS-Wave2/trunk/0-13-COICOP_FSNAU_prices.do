*Match items with COICOP codes and obtain FSNAU prices

set more off 
set seed 23031980 
set sortseed 11021955


********************************************************************
*Import and clean FSNAU prices
********************************************************************
import delimited "${gsdDataRaw}/FSNAU-Market-Data-2010-2017.csv", clear

drop dailylaborrate somalilandshtodjiboutifranc somalilandshtoethiopianbir somalishillingtoksh laborrateagricultural laborratenonagricultural numberofpeoplereceivingremittanc ///
     numberofpeoplereceivingcredit numberhhinmigrated numberhhoutmigrated levelofcivilinsecurity areaofsorghumharvested sorghumharvested arearofmaizeharvested maizeharvested ///
	 whitesorghum50kg redsorghum50kg yellowmaize50kg whitemaize50kg koranicschoolboypupils koranicschoolgirlpupils primaryschoolboypupils primaryschoolgirlpupils numberscreened ///
	 numberwithlesszscore newcases numberofcattleexported numberofcamelsexported numberofsheepgoatsexported percentageofsorghumestimate percentageofmaizeestimate ///
	 establishedsorghumproduction establishedmaizeproduction
order somalishillingtousd somalilandshtousd, last

*Converting some string varibles into numeric
foreach var of varlist whitesorghum1kg - somalilandshtousd {
 qui replace `var'=subinstr(`var',".0000","",1)
 qui replace `var'=subinstr(`var',"-","",1)
 qui destring `var', replace
}
*Convert 50kg products to 1kg
foreach var of varlist charcoal50kg cement50kg {
	replace `var'=`var'/50
	local oldlabel: var label `var'
    local newlabel = subinstr(`"`oldlabel'"',"50"," 1",1)
    label var `var' `"`newlabel'"'
}
ren (charcoal50kg cement50kg) (charcoal1kg cement1kg)


********************************************************************
*Cleaning the exchange rate variable
********************************************************************
gen exchrate = somalishillingtousd
replace exchrate = somalilandshtousd if mi(exchrate)

*There are 240 cases where both Somali and Somaliland currencies have values
*Exchange rate is imputed by calculating the mean
replace exchrate = (somalishillingtousd+somalilandshtousd)/2 if !mi(somalishillingtousd) & !mi(somalilandshtousd)
foreach var of varlist  whitesorghum1kg importedredrice1kg {
	replace `var'=`var'/exchrate
}


********************************************************************
*Labelling Variables
********************************************************************
lab var whitesorghum1kg "White Sorghum 1kg"
lab var wheatgrain1kg "Wheat Grain 1kg"
lab var wheatflour1kg "Wheat Flour 1kg"
lab var sugar "Sugar"
lab var tealeaves "Tea Leaves"
lab var grindingcosts1kg "Grinding Costs 1kg"
lab var localsesameoil1litre "Local Sesame Oil 1litre"
lab var vegetableoil1litre "Vegetable Oil 1litre"
lab var goatexportquality "Goat Export Quality"
lab var goatlocalquality "Goat Local Quality"
lab var sheepexportquality "Sheep Export Quality"
lab var cattleexportquality "Cattle Export Quality"
lab var cattlelocalquality "Cattle Local Quality"
lab var camellocalquality "Camel Local Quality"
lab var freshcamelmilk1litre "Fresh Camel Milk 1litre"
lab var freshcattlemilk1litre "Fresh Cattle Milk 1litre"
lab var firewoodbundle "Firewood Bundle"
lab var diesel1litre "Diesel 1litre"
lab var redsorghum1kg "Red Sorghum 1kg"
lab var petrol1litre "Petrol 1litre"
lab var kerosene1litre "Kerosene 1litre"
lab var soap1bar "Soap 1 Bar"
lab var waterdrum "Water Drum"
lab var somalishillingtousd "Somali Shilling To USD"
lab var somalilandshtousd "Somaliland Sh To USD"
lab var riceexportquality1kg "Rice Export Quality 1kg"
lab var wateronejerican20litre "Water One Jerican 20litre"
lab var transportcost "Transport Cost"
lab var yellowmaize1kg "Yellow Maize 1kg"
lab var roofingnails15kg "Roofing Nails 15kg"
lab var whitemaize1kg "White Maize 1kg"
lab var galvanisedironsheetga26 "Galvanised Iron Sheet Ga26"
lab var timber2inx4inx20ft "Timber 2in x 4in x 20ft"
lab var hollowconcreteblock10cmx20cmx40c "Hollow Concrete Block 10cm x 20cm x 40cm"
lab var plastictarpaulin14x5metres "Plastic Tarpaulin 14 x 5metres"
lab var noncollapsablejerrycan10l "Non Collapsable Jerrycan 10l"
lab var cookingpotaluminium7l "Cooking Pot Aluminium 7l"
lab var wovendryraisedblanket150cmx200cm "Woven Dry Raised Blanket 150cm x 200cm"
lab var importedredrice1kg "Imported Red Rice 1kg"


********************************************************************
*** Renaming variables in order to reshape the data to long format
********************************************************************
ren whitesorghum1kg price1
ren wheatgrain1kg price2
ren wheatflour1kg price3
ren cowpeas price4
ren sugar price5
ren tealeaves price6
ren salt price7
ren grindingcosts1kg price8
ren localsesameoil1litre price9
ren vegetableoil1litre price10
ren goatexportquality price11
ren goatlocalquality price12
ren sheepexportquality price13
ren cattleexportquality price14
ren cattlelocalquality price15
ren camellocalquality price16
ren freshcamelmilk1litre price17
ren freshcattlemilk1litre price18
ren charcoal1kg price19
ren firewoodbundle price20
ren diesel1litre price21
ren redsorghum1kg price22
ren petrol1litre price23
ren kerosene1litre price24
ren soap1bar price25
ren waterdrum price26
ren riceexportquality1kg price27
ren wateronejerican20litre price28
ren transportcost price29
ren yellowmaize1kg price30
ren cement1kg price31
ren roofingnails15kg price32
ren whitemaize1kg price33
ren galvanisedironsheetga26 price34
ren timber2inx4inx20ft price35
ren hollowconcreteblock10cmx20cmx40c price36
ren plastictarpaulin14x5metres price37
ren noncollapsablejerrycan10l price38
ren cookingpotaluminium7l price39
ren wovendryraisedblanket150cmx200cm price40
ren importedredrice1kg price41
drop somalishillingtousd somalilandshtousd
*Reshaping the data to long format
reshape long price, i( region district market markettype year month ) j(id)


********************************************************************
*Assign commodity names 
********************************************************************
gen name=""
replace name="White Sorghum 1kg" if id==1
replace name="Wheat Grain 1kg" if id==2
replace name="Wheat Flour 1kg" if id==3
replace name="Cowpeas" if id==4
replace name="Sugar" if id==5
replace name="Tea Leaves" if id==6
replace name="Salt" if id==7
replace name="Grinding Costs 1kg" if id==8
replace name="Local Sesame Oil 1litre" if id==9
replace name="Vegetable Oil 1litre" if id==10
replace name="Goat Export Quality" if id==11
replace name="Goat Local Quality" if id==12
replace name="Sheep Export Quality" if id==13
replace name="Cattle Export Quality" if id==14
replace name="Cattle Local Quality" if id==15
replace name="Camel Local Quality" if id==16
replace name="Fresh Camel Milk 1litre" if id==17
replace name="Fresh Cattle Milk 1litre" if id==18
replace name="Charcoal 1kg" if id==19
replace name="Firewood Bundle" if id==20
replace name="Diesel 1litre" if id==21
replace name="Red Sorghum 1kg" if id==22
replace name="Petrol 1litre" if id==23
replace name="Kerosene 1litre" if id==24
replace name="Soap 1 Bar" if id==25
replace name="Water Drum" if id==26
replace name="Rice Export Quality 1kg" if id==27
replace name="Water One Jerican 20litre" if id==28
replace name="Transport Cost" if id==29
replace name="Yellow Maize 1kg" if id==30
replace name="Cement 1kg" if id==31
replace name="Roofing Nails 15kg" if id==32
replace name="White Maize 1kg" if id==33
replace name="Galvanised Iron Sheet Ga26" if id==34
replace name="Timber 2in x 4in x 20ft" if id==35
replace name="Hollow Concrete Block 10cm x 20cm x 40cm" if id==36
replace name="Plastic Tarpaulin 14 x 5metres" if id==37
replace name="Non Collapsable Jerrycan 10l" if id==38
replace name="Cooking Pot Aluminium 7l" if id==39
replace name="Woven Dry Raised Blanket 150cm x 200cm" if id==40
replace name="Imported Red Rice 1kg" if id==41
*Export the item list to Excel
export excel name id using "${gsdData}/1-CleanInput/Item_List.xls" if year==2012 & region=="" & !(inlist(id,27,28,32) | inrange(id,33,46)), replace firstrow(variables)


********************************************************************
*Clean the variables and assign codes 
********************************************************************
*Date variable
gen date=substr(month,1,3)+ string(year)
order date, before(year)
replace region = proper(region)
replace district = proper(district)
*Assign codes to pre-war regions
gen ea_reg=.
order ea_reg, after(region)
replace ea_reg=1 if region=="Awdal"
replace ea_reg=2 if region=="Bakool"
replace ea_reg=3 if region=="Banadir"
replace ea_reg=4 if region=="Bari"
replace ea_reg=5 if region=="Bay"
replace ea_reg=6 if region=="Galgaduug"
replace ea_reg=7 if region=="Gedo"
replace ea_reg=8 if region=="Hiran"
replace ea_reg=9 if region=="Jubbada Dhexe"
replace ea_reg=10 if region=="Jubbada Hoose"
replace ea_reg=11 if region=="Mudug"
replace ea_reg=12 if region=="Nugal"
replace ea_reg=13 if region=="Sanaag"
replace ea_reg=14 if region=="Shabeellaha Dhexe"
replace ea_reg=15 if region=="Shabeellaha Hoose"
replace ea_reg=16 if region=="Sool"
replace ea_reg=17 if region=="Togdheer"
replace ea_reg=18 if region=="Woqooyi Galbeed"
*Assign COICOP codes to items
gen coicop=""
replace coicop="0111" if name=="White Sorghum 1kg"
replace coicop="0111" if name=="Wheat Grain 1kg"
replace coicop="0111" if name=="Wheat Flour 1kg"
replace coicop="0117" if name=="Cowpeas"
replace coicop="0118" if name=="Sugar"
replace coicop="0120" if name=="Tea Leaves"
replace coicop="0119" if name=="Salt"
replace coicop="1213" if name=="Grinding Costs 1kg"
replace coicop="0115" if name=="Local Sesame Oil 1litre"
replace coicop="0115" if name=="Vegetable Oil 1litre"
replace coicop="0112" if name=="Goat Export Quality"
replace coicop="0112" if name=="Goat Local Quality"
replace coicop="0112" if name=="Sheep Export Quality"
replace coicop="0112" if name=="Cattle Export Quality"
replace coicop="0112" if name=="Cattle Local Quality"
replace coicop="0112" if name=="Camel Local Quality"
replace coicop="0114" if name=="Fresh Camel Milk 1litre"
replace coicop="0114" if name=="Fresh Cattle Milk 1litre"
replace coicop="0114" if name=="Charcoal 1kg"
replace coicop="0454" if name=="Firewood Bundle"
replace coicop="0722" if name=="Diesel 1litre"
replace coicop="0111" if name=="Red Sorghum 1kg"
replace coicop="0722" if name=="Petrol 1litre"
replace coicop="0453" if name=="Kerosene 1litre"
replace coicop="1213" if name=="Soap 1 Bar"
replace coicop="0122" if name=="Water Drum"
replace coicop="0111" if name=="Rice Export Quality 1kg"
replace coicop="0122" if name=="Water One Jerican 20litre"
replace coicop="0732" if name=="Transport Cost"
replace coicop="0111" if name=="Yellow Maize 1kg"
replace coicop="0431" if name=="Cement 1kg"
replace coicop="0561" if name=="Roofing Nails 15kg"
replace coicop="0111" if name=="White Maize 1kg"
replace coicop="0431" if name=="Galvanised Iron Sheet Ga26"
replace coicop="0431" if name=="Timber 2in x 4in x 20ft"
replace coicop="0431" if name=="Hollow Concrete Block 10cm x 20cm x 40cm"
replace coicop="0561" if name=="Plastic Tarpaulin 14 x 5metres"
replace coicop="0552" if name=="Non Collapsable Jerrycan 10l"
replace coicop="0540" if name=="Cooking Pot Aluminium 7l"
replace coicop="0520" if name=="Woven Dry Raised Blanket 150cm x 200cm"
replace coicop="0111" if name=="Imported Red Rice 1kg"
lab var ea_reg "Region Code"
lab var date "Date"
lab var price "Item Price"
lab var exchrate "Exchange Rate"
lab var name "Item Name"
lab var coicop "COICOP"
drop id
save "${gsdData}/0-RawTemp/Commodity_Prices.dta", replace 


********************************************************************
*Obtain prices per COICOP code for relevant months
********************************************************************
use "${gsdData}/0-RawTemp/Commodity_Prices.dta", clear
gen pr_usd=price/exchrate
*Prepare month variable
replace month="1" if month=="January"
replace month="2" if month=="February"
replace month="3" if month=="March"
replace month="4" if month=="April"
replace month="5" if month=="May"
replace month="6" if month=="June"
replace month="7" if month=="July"
replace month="8" if month=="August"
replace month="9" if month=="September"
replace month="10" if month=="October"
replace month="11" if month=="November"
replace month="12" if month=="December"
destring month, replace
*Correct the names without spaces for the loop below 
replace region="Lower_Juba" if region=="Lower Juba"
replace region="Lower_Shabelle" if region=="Lower Shabelle" 
replace region="Middle_Juba" if region=="Middle Juba"
replace region="Middle_Shabelle" if region=="Middle Shabelle"
replace region="Woqooyi_Galbeed" if region=="Woqooyi Galbeed"
drop if region=="" | region=="0"
collapse (mean) pr_usd, by( region coicop date year month)
foreach region in Awdal Bakool Banaadir Bari Bay Galgaduud Gedo Hiraan Lower_Juba Lower_Shabelle Middle_Juba Middle_Shabelle Mudug Nugaal Sanaag Sool Togdheer Woqooyi_Galbeed  {
	*Obtain the 2011 average
	preserve
	keep if region=="`region'"
	keep if year==2011
	drop date year region
	collapse (mean) av_2011=pr_usd, by(coicop) 
	la var av_2011 "2011 price average, USD"
	save "${gsdTemp}/`region'_av2011.dta", replace
	restore
	*Obtain the 2012 average
	preserve
	keep if region=="`region'"
	keep if year==2012
	drop date year region
	collapse (mean) av_2012=pr_usd, by(coicop) 
	la var av_2012 "2012 price average, USD"
	save "${gsdTemp}/`region'_av2012.dta", replace
	restore
	*Obtain months during data collection (December 2017 and January 2018)
	preserve
	keep if region=="`region'"
	keep if (month==12 & year==2017) | (month==1 & year==2018)
	drop region date year
	reshape wide pr_usd, i(coicop) j(month) 
	ren pr_usd12 dec17
	la var coicop "Product"
    la var dec17 "Price Dec 17, USD"
	gen str region="`region'"
	la var region "Somali region"
	*Merge back with 2011 and 2012 averages 
	merge m:1 coicop using "${gsdTemp}/`region'_av2011.dta", keep(master match) nogen 
	merge m:1 coicop using "${gsdTemp}/`region'_av2012.dta", keep(master match) nogen 
	save "${gsdTemp}/market_prices_`region'.dta", replace
	restore
	
}
*Append all regions 
use "${gsdTemp}/market_prices_Awdal.dta", clear
foreach region in Bakool Banaadir Bari Bay Galgaduud Gedo Hiraan Lower_Juba Lower_Shabelle Middle_Juba Middle_Shabelle Mudug Nugaal Sanaag Sool Togdheer Woqooyi_Galbeed {
	append using "${gsdTemp}/market_prices_`region'.dta"
}
order region coicop av_2011 av_2012 dec17 
save "${gsdData}/1-CleanInput/Prices_FSNAU.dta", replace 


********************************************************************
*Save a file matching itemid and COICOP codes
********************************************************************
import excel "${gsdDataRaw}/Match_Items_COICOP.xlsx", sheet("W2_Food") firstrow case(lower) clear
drop name 
rename code itemid
save "${gsdTemp}/COICOP_food.dta", replace 
import excel "${gsdDataRaw}/Match_Items_COICOP.xlsx", sheet("W2_Nonfood") firstrow case(lower) clear
drop name 
rename code itemid
save "${gsdTemp}/COICOP_nonfood.dta", replace 
use "${gsdTemp}/COICOP_food.dta", clear
append using "${gsdTemp}/COICOP_nonfood.dta"
save "${gsdData}/1-CleanInput/COICOP_Codes.dta", replace 
