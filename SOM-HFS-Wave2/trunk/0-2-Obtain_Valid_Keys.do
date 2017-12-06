*-------------------------------------------------------------------
*
*     SUCCESSFUL AND VALID INTERVIEWS
*     
*     This do-file allows to determine which interviews are 
*     valid and/or successful
*                         
*-------------------------------------------------------------------

***Importing questionnaire
use "${gsdData}/0-RawTemp/hh_manual_cleaning.dta", clear

***Creating date variables
*Date in stata format
g year = substr(today,1,4)
g month = substr(today,6,2)
g day = substr(today,9,2)
destring year month day, replace
g date_stata = mdy(month,day,year)
format date_stata %tdDD/NN/YY
drop year month day
label var date_stata "Day of data collection (stata format)"

*Date in string format
g date = substr(today,1,10)
label var date "Day of data collection (string format)"


/*-------------------------------------*/ 
/*      A - VALIDITY CRITERIA          */
/*-------------------------------------*/

/* Validity criteria

Criteria for an interview to be valid:
-The duration of the interview exceeds a certain threshold (threshold to be determined during the pilot) 
-The interview has GPS coordinates and the GPS coordinate fall within a 50m buffer zone of the EA (based on the min latitude-longitude formula)
-If the interview is from a replaced household:
		- at least one record for the original household must exist
		- the record for the original household must be valid, including the reason for no interview (except for minimum duration)
-If the interview is not conducted by the first visit:
		- a record for a previous visit must exist
		- the record for the previous visit must be valid (except for minimum duration)
		- both records must contain GPS positions that match (with a 25m + precision maximum distance).*/

*Generating dummy variable for validity of interviews 
gen itw_valid = 1
label var itw_valid "Whether the interview is valid or not"

*Generating variable for invalidity reason
gen itw_invalid_reason =.
label var itw_invalid_reason "Reason for invalid interview"
label define itw_invalid_reason 1 "Duration does not exceed threshold" ///
							    2 "No GPS coordinates" ///
							    3 "GPS coordinates do not fall within EA boundaries" ///
							    4 "No record for the original household while it is a replacement household" ///
							    5 "Record for the original household is not valid while it is a replacement household" ///
								6 "No previous record while it is not a first visit to the household" ///
							    7 "Record for previous visit is not valid while it is a second or third visit" ///
							    8 "The GPS coordinates do not match with the previous visit"
label values itw_invalid_reason itw_invalid_reason 

/*-------------------------------------*/ 
/*           1 - DURATION              */
/*-------------------------------------*/

*Duration variable was created in 0-1-manual_cleaning.do
replace itw_valid = 0 if duration_itw_min < 30 
replace itw_invalid_reason = 1 if duration_itw_min < 30 

/*-------------------------------------*/ 
/*        2 -  GPS COORDINATES         */
/*-------------------------------------*/

/*Three GPS coordinates variables in the dataset:
	- When the enumerator identifies the EA -> EA level
	- When the enumerator is in the structure -> structure level
	- At the end of the interview, if no GPS coordinates were recorded at the beginning of the interview
*/

**Renaming EA variable for consistency with block and structure variables names
g long id_ea = ea
label var id_ea "EA where the interview was conducted"

**Creating a variable for GPS coordinates at the EA level (used when checking that the interview was conducted within the EA)
g latitude = .
g longitude = .
g accuracy = .
label var latitude "Latitude at the EA level"
label var longitude "Longitude at the EA level"
label var accuracy "Accuracy of GPS coordinates at the EA level"
*If barcode is working and GPS is working at the EA level
replace latitude = loc_barcode__Latitude
replace longitude = loc_barcode__Longitude
replace accuracy = loc_barcode__Accuracy
*If barcode is not working and GPS is working at the EA level
replace latitude = loc_list__Latitude if missing(latitude) | latitude == -1000000000
replace longitude = loc_list__Longitude if missing(longitude) | longitude == -1000000000
replace accuracy = loc_list__Accuracy if missing(accuracy) | accuracy == -1000000000
*If GPS is working at the structure level but was not at the EA level and it is not a return visit
replace latitude = str_loc__Latitude if missing(latitude) | latitude == -1000000000
replace longitude = str_loc__Longitude if missing(longitude) | longitude == -1000000000
replace accuracy = str_loc__Accuracy if missing(accuracy) | accuracy == -1000000000
*If GPS is working at the structure level but was not at the EA level and it is a return visit
replace latitude = loc_hhid_seg1ret1__Latitude if missing(latitude) | latitude == -1000000000
replace longitude = loc_hhid_seg1ret1__Longitude if missing(longitude) | longitude == -1000000000
replace accuracy = loc_hhid_seg1ret1__Accuracy if missing(accuracy) | accuracy == -1000000000
*If GPS is working at the end of the interview but was not at the beginning (neither at the EA level nor at the structure level)
replace latitude = loc_retry__Latitude if missing(latitude) | latitude == -1000000000
replace longitude = loc_retry__Longitude if missing(longitude) | longitude == -1000000000
replace accuracy = loc_retry__Accuracy if missing(accuracy) | accuracy == -1000000000

**Creating a variable for GPS coordinates at the structure level (used when checking consistency for return visits)
*If not a return visit
g latitude_str = str_loc__Latitude if return1 == 0
g longitude_str = str_loc__Longitude if return1 == 0
g accuracy_str = str_loc__Accuracy if return1 == 0
*If a return visit
replace latitude_str = loc_hhid_seg1ret1__Latitude if return1 == 1
replace longitude_str = loc_hhid_seg1ret1__Longitude if return1 == 1
replace accuracy_str = loc_hhid_seg1ret1__Accuracy if return1 == 1
label var latitude_str "Latitude at the structure level"
label var longitude_str "Longitude at the structure level"
label var accuracy_str "Accuracy of GPS coordinates at the structure level"
*If GPS is working at the end of the interview but was not at the beginning 
replace latitude_str = loc_retry__Latitude if missing(latitude_str) | latitude == -1000000000
replace longitude_str = loc_retry__Longitude if missing(longitude_str) | longitude == -1000000000
replace accuracy_str = loc_retry__Accuracy if missing(accuracy_str) | accuracy == -1000000000

**Checking that the interview has GPS coordinates
gen gps_coord_y_n = (latitude != . & longitude != . & latitude != -1000000000 & longitude != -1000000000) 
label var gps_coord_y_n "Whether the interview has GPS coordinates"
replace itw_valid=0 if gps_coord_y_n == 0
replace itw_invalid_reason=2 if gps_coord_y_n == 0
save "${gsdTemp}/hh_valid_keys_temp1.dta", replace

*Importing min and max coordinates of each EA
import excel "${gsdDataRaw}/Inputs EAs.xls", sheet("Master EAs") clear
keep A G H I J
rename (A G H I J) (ea lon_min lon_max lat_min lat_max)
drop if _n <= 3
label var lat_min "Minimum latitude of the EA"
label var lat_max "Maximum latitude of the EA"
label var lon_min "Minimum longitude of the EA"
label var lon_max "Maximum longitude of the EA"
destring *, replace
save "${gsdTemp}/EAs_min_max_coordinates.dta", replace

use "${gsdTemp}/hh_valid_keys_temp1.dta", clear
merge m:1 ea using "${gsdTemp}/EAs_min_max_coordinates.dta", keep(match master) nogenerate

**Checking that the GPS coordinates fall within the EA with a buffer of 50 meters
gen not_within_EA=(longitude < lon_min - ((accuracy + 50)/110000) | ///
		longitude > lon_max + ((accuracy + 50)/110000) | ///
		latitude < lat_min - ((accuracy + 50)/110000) | ///
		latitude  > lat_max + ((accuracy + 50)/110000)) 
label var not_within_EA "The GPS coordinates of the interview do not fall within the EA boundaries"

replace itw_valid=0 if not_within_EA==1
replace itw_invalid_reason =3 if not_within_EA==1

save "${gsdTemp}/hh_valid_keys_temp2.dta", replace

/*-------------------------------------*/ 
/*        3 - VALID REPLACEMENT        */
/*-------------------------------------*/

***Generating variables for block, structure and household where the interview was conducted

**Flag EAs with 1 block and replace block number = 1 for those EAs
*Add total number of blocks per EA
import excel "${gsdDataRaw}/Inputs EAs.xls", sheet("Master EAs") clear
keep A M
rename (A M) (id_ea tot_block)
drop if _n <= 3
destring *, replace
merge 1:m id_ea using "${gsdTemp}/hh_valid_keys_temp2.dta", keep(match using) nogenerate

*Replace block number = 1 for EAs with 1 block
replace chosen_block = 1 if return1==0 & tot_block == 1
replace blid_seg1ret1 = 1 if return1==1 & tot_block == 1
replace original_block = 1 if replacement_hh==1 & tot_block == 1
drop tot_block

/* FINAL BLOCK
- blid_seg1ret1 if returning to household
- chosen_block if household selection through questionnaire
= id_block (= block where the interview is conducted)
*/
g id_block = blid_seg1ret1 if return1==1
replace id_block = chosen_block if return1==0 
label var id_block "Block number where interwiew was conducted"

/* FINAL STRUCTURE
- strid_seg1ret1 if returning to household
- seg_str if household selection through questionnaire
= id_structure (= structure where the interview is conducted)
*/
gen id_structure = strid_seg1ret1 if return1==1 
replace id_structure = seg_str if return1==0
label var id_structure "Structure number where interview was conducted"

/* FINAL HOUSEHOLD
- hhid_seg1ret1 if returning to household
- hhid_seg1ret0 if household selection through questionnaire
= id_household (= household where the interview is conducted)
*/
gen id_household = hhid_seg1ret1 if return1==1
replace id_household = hhid_seg1ret0 if return1==0
label var id_household "Household number where interview was conducted"

*Generating variables for block, structure and household of the original household in case of replacement (in case of no replacement, original household = household)

/* ORIGINAL BLOCK
- id_block if not a replacement household
- original_block if replacement household
= block_number_original
*/
gen block_number_original = id_block if replacement_hh==0
replace block_number_original = original_block if replacement_hh==1
label var block_number_original "Original block number"

/* ORIGINAL STRUCTURE
- id_structure if not a replacement household
- original_str if replacement household
= str_number_original
*/
gen str_number_original = id_structure if replacement_hh==0
replace str_number_original = original_str if replacement_hh==1
label var str_number_original "Original structure number"

/* ORIGINAL HOUSEHOLD
- id_household if not a replacement household
- original_hh if replacement household
= hh_number_original
*/
g hh_number_original = id_household if replacement_hh==0
replace hh_number_original = original_hh if replacement_hh==1
label var hh_number_original "Original household number"

*Sorting interviews to have all visits at the replaced household and then all visits at the replacement household after one another
sort ea_reg id_ea block_number_original str_number_original hh_number_original int_no start_time

**CHECKING WHETHER A RECORD FOR THE ORIGINAL HOUSEHOLD EXISTS IN CASE OF REPLACEMENT**

gen replaced_visit_exists=1 if replacement_hh==1
label var replaced_visit_exists "If replacement, whether a record for the original household exists"

*Not valid if there is no record for the original household while it is a visit to a replacement household
replace replaced_visit_exists=0 if (replacement_hh==1 & (ea_reg!=ea_reg[_n - 1] | id_ea!=id_ea[_n - 1] | block_number_original!=block_number_original[_n - 1] | str_number_original!=str_number_original[_n - 1] | hh_number_original!=hh_number_original[_n - 1] | int_no!=int_no[_n-1]))
replace itw_valid=0 if replacement_hh==1 & replaced_visit_exists==0
replace itw_invalid_reason=4 if replacement_hh==1 & replaced_visit_exists==0

**CHECKING WHETHER THE RECORD FOR THE ORIGINAL HOUSEHOLD IS VALID IN CASE OF REPLACEMENT**

gen replaced_visit_valid=1 if replacement_hh==1
label var replaced_visit_valid "If replacement, whether the last record for the original household is valid"

*For the visits to replacement households, we check that the visits to the original household are valid
replace replaced_visit_valid=0 if (replacement_hh==1 & ea_reg==ea_reg[_n - 1] & id_ea==id_ea[_n - 1] & block_number_original==block_number_original[_n - 1] & str_number_original==str_number_original[_n - 1] & hh_number_original==hh_number_original[_n - 1] & (id_block!=id_block[_n-1] | id_structure!=id_structure[_n-1] | id_household!=id_household[_n-1] | int_no!=int_no[_n-1]) & itw_valid[_n-1]==0) 
replace itw_valid=0 if replacement_hh==1 & replaced_visit_valid==0
replace itw_invalid_reason=5 if replacement_hh==1 & replaced_visit_valid==0


/*-------------------------------------*/
/*      	4 - VALID RETURN VISIT	   */
/*-------------------------------------*/

*Sorting interviews to have all visits to a specific household after each other
sort ea_reg id_ea id_block id_structure id_household int_no start_time

**CHECKING WHETHER A PREVIOUS RECORD EXISTS IF RETURN VISIT**

gen previous_visit_exists=1 if return1==1
label var previous_visit_exists "If return visit, whether a previous record for the household exists"

*Not valid if no previous record while it is not a first visit to the household
replace previous_visit_exists=0 if (return1==1 & (ea_reg!=ea_reg[_n - 1] | id_ea!=id_ea[_n - 1] | id_block!=id_block[_n - 1] | id_structure!= id_structure[_n-1] | id_household!=id_household[_n-1] | int_no!=int_no[_n-1]))
replace itw_valid=0 if return1==1 & previous_visit_exists==0
replace itw_invalid_reason=6 if return1==1 & previous_visit_exists==0

**CHECKING WHETHER PREVIOUS RECORD IS VALID IF RETURN VISIT**

gen previous_visit_valid=1 if return1==1
label var previous_visit_valid "If return visit, whether a previous record for the household is valid"

*For the second and third visits to the household, we check that the previous visit was a valid visit
replace previous_visit_valid=0 if (return1==1 & ea_reg==ea_reg[_n - 1] & id_ea==id_ea[_n - 1] & id_block==id_block[_n - 1] & id_structure==id_structure[_n-1] & id_household==id_household[_n-1] & int_no==int_no[_n-1] & itw_valid[_n - 1]==0)
replace itw_valid=0 if return1==1 & previous_visit_valid==0
replace itw_invalid_reason=7 if return1==1 & previous_visit_valid==0

**CHECKING WETHER THE GPS COORDINATES BETWEEN THE TWO VISITS MATCH**

*We also have to check that the GPS coordinates between the two visits to the same household match 
*Both records must have GPS coordinates
gen GPS_pair=1 if return1==1
replace GPS_pair=0 if (latitude_str==. | longitude_str==. | (return1==1 & ea_reg==ea_reg[_n - 1] & id_ea==id_ea[_n - 1] & id_block==id_block[_n - 1] & id_structure==id_structure[_n-1] & id_household==id_household[_n-1] & int_no==int_no[_n-1] & (latitude_str[_n-1]==. | longitude_str[_n-1]==.)))
label var GPS_pair "Whether the visit to the household and the previous one both have GPS coordinates"

*Using Vincenty package to calculate distances on the Earth's surface
gen latitude_pr=latitude_str[_n-1] if (return1==1 & ea_reg==ea_reg[_n - 1] & id_ea==id_ea[_n - 1] & id_block==id_block[_n - 1] & id_structure==id_structure[_n-1] & id_household==id_household[_n-1] & int_no==int_no[_n-1])
gen longitude_pr=longitude_str[_n-1] if (return1==1 & ea_reg==ea_reg[_n - 1] & id_ea==id_ea[_n - 1] & id_block==id_block[_n - 1] & id_structure==id_structure[_n-1] & id_household==id_household[_n-1] & int_no==int_no[_n-1])
gen accuracy_pr=accuracy_str[_n-1] if (return1==1 & ea_reg==ea_reg[_n - 1] & id_ea==id_ea[_n - 1] & id_block==id_block[_n - 1] & id_structure==id_structure[_n-1] & id_household==id_household[_n-1] & int_no==int_no[_n-1])
label var latitude_pr "Latitude of previous visit to the household"
label var longitude_pr "Longitude of previous visit to the household"
label var accuracy_pr "Accuracy of GPS coordinates of previous visit to the household"

capture: vincenty latitude_str longitude_str latitude_pr longitude_pr if GPS_pair==1 & return1==1, h(d_hav) l(d_loc) inkm
*inkm requests distances expressed in kilometers
*d_hav stores the results of Haversine-based calculations 
*d_loc stores the results of Law-of-Cosines-based calculations
label var d_hav "Distance with previous visit to the same household - Haversine calculations kms"
label var d_loc "Distance with previous visit to the same household - Law of Cosines calculations kms"

*The previous variables in meters
gen d_hav_m=d_hav*1000
gen d_loc_m=d_loc*1000
label var d_hav_m "Distance with previous visit to the same household - Haversine calculations ms"
label var d_loc_m "Distance with previous visit to the same household - Law of Cosines calculations ms"

*Generating variable for distance check
gen dist_previous_visit_check=1
replace dist_previous_visit_check=(d_hav_m<=(max(accuracy_pr, accuracy_str)+25)) if (return1==1 & ea_reg==ea_reg[_n - 1] & id_ea==id_ea[_n - 1] & id_block==id_block[_n - 1] & id_structure==id_structure[_n-1] & id_household==id_household[_n-1] & int_no==int_no[_n-1] & GPS_pair==1)
label var dist_previous_visit_check "Whether the GPS coordinates match with the previous visit to the household" 

replace itw_valid=0 if return1==1 & dist_previous_visit_check==0
replace itw_invalid_reason=8 if return1==1 & dist_previous_visit_check==0

/*-------------------------------------*/
/*      	5 - RE RUN VALIDITY  	   */
/*-------------------------------------*/ 

*We have to run again parts of the code on validity criteria for replacements to invalidate the replacements for which the records for the original household were invalidated because of incorrect return visits
*Sorting interviews to have all visits at the replaced household and then all visits at the replacement household after one another
sort ea_reg id_ea block_number_original str_number_original hh_number_original int_no start_time
*For the visits to replacement households, we check that the visits to the original household are valid
replace replaced_visit_valid=0 if (replacement_hh==1 & ea_reg==ea_reg[_n - 1] & id_ea==id_ea[_n - 1] & block_number_original==block_number_original[_n - 1] & str_number_original==str_number_original[_n - 1] & hh_number_original==hh_number_original[_n - 1] & (id_block!=id_block[_n-1] | id_structure!=id_structure[_n-1] | id_household!=id_household[_n-1] | int_no!=int_no[_n-1]) & itw_valid[_n-1]==0) 
replace itw_valid=0 if replacement_hh==1 & replaced_visit_valid==0
replace itw_invalid_reason=5 if replacement_hh==1 & replaced_visit_valid==0

*We have to run again parts of the code on validity criteria for return visits to invalidate the return visits of replacement households for which the first visit was invalidated at the previous step
*Sorting interviews to have all visits to a specific household after each other
sort ea_reg id_ea id_block id_structure id_household int_no start_time
*For the second and third visits to the household, we check that the previous visit was a valid visit
replace previous_visit_valid=0 if (return1==1 & ea_reg==ea_reg[_n - 1] & id_ea==id_ea[_n - 1] & id_block==id_block[_n - 1] & id_structure==id_structure[_n-1] & id_household==id_household[_n-1] & int_no==int_no[_n-1] & itw_valid[_n - 1]==0)
replace itw_valid=0 if return1==1 & previous_visit_valid==0
replace itw_invalid_reason=7 if return1==1 & previous_visit_valid==0

/*-------------------------------------*/ 
/*    B - SUCCESSFULNESS CRITERIA      */
/*-------------------------------------*/

*An interview is considered successful if an eligible adult was home and consented to be interviewed. 
gen successful=(athome==1 & adult==1 & maycontinue==1)
label var successful "Whether the interview is successful"
gen successful_valid=(successful==1 & itw_valid==1)
label var successful_valid "Whether the interview is successful and valid"

save "${gsdData}/0-RawTemp/hh_valid_keys.dta", replace
