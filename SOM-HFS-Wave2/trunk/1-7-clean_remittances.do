* Cleans remittances data

set more off 
set seed 23031180 
set sortseed 12121955


********************************************************************
*Open and prepare the dataset 
********************************************************************
use "${gsdData}/1-CleanInput/hh.dta", clear

********************************************************************
*Introduce corrections related to currency issues
********************************************************************
ren supp_som_* supp_som12m_*
gen supp_som12m=1 if supp_som12m_yn==1
* Make sure currency splits are correctly observed
foreach measure in "intremit" "remit" "supp_som" {
	* Currency splits
	* SSH only: ea_reg 2,3,4,5,6,7,8,9,10,11,12,14,15
	* SLSH only: ea reg 1, 18
	* Both: 13, 16, 17 
	* Check that this is true in the data
	assert `measure'12m_amount_c==4 | `measure'12m_amount_c==5 | `measure'12m_amount_c>=. if inlist(region, 1, 18)
	assert `measure'12m_amount_c==2 | `measure'12m_amount_c==5 | `measure'12m_amount_c>=. if inlist(region, 2,3,4,5,6,7,8,9,10,11,12,14,15)
	assert inlist(`measure'12m_amount_c, 2, 4, 5) | `measure'12m_amount_c>=. if inlist(region, 13, 16, 17)
}	

* Generate zone variable to merge with exchange rates
* Define whether an observation is in an SLSH or in an SSH area
cap drop team
* SLSH 
gen team = 1 if inlist(region, 1, 18)
* SSH
replace team = 2 if inlist(region, 3)
replace team = 3 if inlist(region, 4,11,12)
replace team = 4 if inlist(region, 8, 6, 14)
replace team = 5 if inlist(region, 7, 10)
replace team = 6 if inlist(region, 5, 2, 15)
* Now the situations where both currencies are possible to select 
foreach measure in "intremit" "remit" "supp_som" {
	replace team = 1 if inlist(region, 13, 16, 17) & (`measure'12m_amount_c==4)   
	replace team = 3 if inlist(region, 13, 16, 17) & (`measure'12m_amount_c==2) 
}
foreach measure in "intremit" "remit" "supp_som" {
	* we assign team 1 if USD or missing
	replace team = 1 if inlist(region, 13, 16, 17) & (`measure'12m_amount_c==5 | mi(`measure'12m_amount_c)) & mi(team) 
	*assert !(team==1 & `measure'12m_amount_c==2)
	*assert !(team==2 & `measure'12m_amount_c==4)
}


foreach type_remit in "intremit" "remit" "supp_som"{
	*Cleaning rule: change USD to local currency (for each zone) when the price is equal or greater than 10,000
	replace `type_remit'12m_amount_c=4 if `type_remit'12m_amount>= 10000 & `type_remit'12m_amount<. & `type_remit'12m_amount_c==5 & team==1
	replace `type_remit'12m_amount_c=2 if `type_remit'12m_amount>= 10000 & `type_remit'12m_amount<. & `type_remit'12m_amount_c==5 & team!=1 
	*Cleaning rule: change local currency larger than 500,000 (divide by 10)
	replace `type_remit'12m_amount=`type_remit'12m_amount/10 if `type_remit'12m_amount>500000 & `type_remit'12m_amount<.
}
merge m:1 team using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen keepusing(average_er)
drop team 

********************************************************************
*Convert to USD and introduce cleaning rules
********************************************************************
foreach type_remit in "intremit" "remit" "supp_som" {
	gen `type_remit'12m_usd=`type_remit'12m_amount if `type_remit'12m_amount_c==5
	replace `type_remit'12m_usd=`type_remit'12m_amount/(average_er/1000) if inlist(remit12m_amount_c, 2, 4)
	*Cleaning rule: replace values in the top/bottom 1% by the median value in USD within the same astrata 
	set sortseed 11041925
	cumul `type_remit'12m_usd, gen(cumul_distr_`type_remit') equal
	levelsof strata, local(regions)
	foreach region of local regions {
	   sum `type_remit'12m_usd [aw= weight] if strata==`region' & cumul_distr_`type_remit'>0.01 & cumul_distr_`type_remit'<0.99, detail 
	   replace `type_remit'12m_usd=r(p50) if `type_remit'12m_usd<. & strata==`region' & (cumul_distr_`type_remit'>0.99  | cumul_distr_`type_remit'<0.01 )	
	}
	*Cleaning rule: replace "don't know" and "refused to respond" to mean of astrata
	bys strata: egen `type_remit'12m_astrata_mean = mean(`type_remit'12m_usd)
	replace `type_remit'12m_usd = `type_remit'12m_astrata_mean if (`type_remit'12m_yn>=.) | (`type_remit'12m_yn==1 & `type_remit'12m_amount>=. & inlist(`type_remit'12m,1,3))
	drop `type_remit'12m_astrata_mean
	*Generate per capita per diem remittances values
	gen `type_remit'_pcpd = `type_remit'12m_usd / hhsize / 365
	recode `type_remit'_pcpd (missing=0)
}
la var intremit_pcpd "Value of internal remittances per capita per day"
la var remit_pcpd "Value of external remittances per capita per day"
la var remit12m_usd "External remittances in past 12 month, USD amount"
la var intremit12m_usd "Internal remittances in past 12 month, USD amount"
drop average_er* cumul_distr_intremit cumul_distr_remit supp_som12m cumul_distr_supp_som
ren supp_som12m_* supp_som_*
order intremit12m_yn intremit12m intremit12m_amount_kdk intremit12m_amount intremit12m_amount_c intremit12m_usd intremit_pcpd, after(lhood_prev)
order remit12m_yn remit12m remit12m_amount_kdk remit12m_amount remit12m_amount_c  remit12m_usd remit_pcpd remit12m_usd remit_pcpd, after(intremit_freq)
order supp_som_usd supp_som_pcpd, after(supp_som_amount_kdk)
rename remit* intlremit*
foreach pre in "int" "intl" {
	la var `pre'remit_mode__1 "Mode: Bank"
	la var `pre'remit_mode__2 "Mode: Remittances company"
	la var `pre'remit_mode__3 "Mode: Mail"
	la var `pre'remit_mode__4 "Mode: Courier"
	la var `pre'remit_mode__5 "Mode: Internet"
	la var `pre'remit_mode__6 "Mode: Bank card"
	la var `pre'remit_mode__7 "Mode: travel of family member"
	la var `pre'remit_mode__8 "Mode: Bus/Minibus"
	la var `pre'remit_mode__9 "Mode: Mobile phone"
	
}

********************************************************************
*Rename to make compatible with Wave 1 data
********************************************************************

gen remit12m = (intremit12m_yn==1 | intlremit12m_yn==1)
la val remit12m lyesno
gen remit_pcpd = (intremit_pcpd + intlremit_pcpd)
gen remit12m_usd = intremit12m_usd + intlremit12m_usd 
la var remit12m "Remittances receipt internal + international (Y/N)"
la var remit_pcpd "Value of internal + interhnational remittances per capita per day"
la var remit12m_usd "Internal + international remittances in past 12 month, USD amount"
order remit*, before(intremit12m_yn) 


save "${gsdData}/1-CleanTemp/hh.dta", replace
