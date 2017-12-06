* File to create auxiliary data file for PESS region assignment 

set more off 
set seed 23081930 
set sortseed 11041255

* Import file 
clear
import excel "${gsdDataRaw}/PESS_regions.xlsx", firstrow
keep zone strata reg_old district reg_pess pess_id
* Apply value labels
labmask pess_id, values(reg_pess)

* Collapse to contain only one entry per region
collapse (first) reg_pess, by(pess_id)
la var reg_pess "PESS Region, string" 
la var pess_id "PESS Region"
* save 
save "${gsdData}/0-RawTemp/reg_pess.dta", replace


*Obtain dta files from shapefiles by PESS region to create maps in the analysis  
*Shape and dbf files are coming from http://www.diva-gis.org/gdata
shp2dta using "${gsdDataRaw}/SOM_adm1", database("${gsdData}/1-CleanInput/SOM_db") coordinates("${gsdData}/1-CleanInput/SOM_coord") replace genid(id_map)

*Include the population from PESS 
import excel "${gsdDataRaw}/PESS_population.xlsx", firstrow case(lower) clear
save "${gsdData}/1-CleanInput/PESS_population.dta", replace
