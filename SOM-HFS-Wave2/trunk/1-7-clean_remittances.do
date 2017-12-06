* Cleans remittances data

* prepare household level dataset
use "${gsdData}/1-CleanInput/hh.dta", clear
merge 1:1 strata ea block hh using "${gsdData}/1-CleanTemp/hhm-hh.dta", keepusing(hhsize) nogen assert(match)
*obtain exchange rates 
merge m:1 zone using "${gsdData}/1-CleanInput/HFS Exchange Rate Survey.dta", nogen assert(master match) keepusing(average_er)
*replace missing Puntland 2 exchange rate with Puntland 1 exchange rates
egen x=max(average_er) if zone==2
egen av_er_zone1=max(x)
replace average_er=av_er_zone1 if zone==1
gen average_er_thousands=average_er/1000

*check that we have Somaliland units in SL and Somali in SC or PL
tab remit12m_amount_c team

*correct issue with currency-units 
*cleaning rule: change USD to local currency (for each zone) when the price is equal or greater than 1,000
replace remit12m_amount_c=3 if remit12m_amount >= 10000 & remit12m_amount<. & remit12m_amount_c==5 & team==1
replace remit12m_amount_c=1 if remit12m_amount >= 10000 & remit12m_amount<. & remit12m_amount_c==5 & team!=1
*cleaning rule: change local currency to thousands (for each zone) when the price is equal or smaller than 500
replace remit12m_amount_c=4 if remit12m_amount <= 1000 & remit12m_amount_c==3 & team==1
replace remit12m_amount_c=2 if remit12m_amount <= 1000 & remit12m_amount_c==1 & team!=1
*cleaning rule: change thousands to local currency (for each zone) larger than 100,000 thousands
replace remit12m_amount_c=3 if remit12m_amount >= 100000 & remit12m_amount_c==4 & team==1
replace remit12m_amount_c=1 if remit12m_amount >= 100000 & remit12m_amount_c==2 & team!=1

*convert to USD
gen remit12m_usd=remit12m_amount if remit12m_amount_c==5
replace remit12m_usd=remit12m_amount/average_er if inlist(remit12m_amount_c, 1, 3)
replace remit12m_usd=remit12m_amount/average_er_thousands if inlist(remit12m_amount_c, 2, 4)
drop x av_er_zone1 average_er*
la var remit12m_usd "Remittances in past 12 month, USD amount"

*cleaning rule: replace values in the top/bottom 1% by the median value in USD within the same astrata 
set sortseed 11041925
cumul remit12m_usd, gen(cumul_distr_remittances) equal
levelsof astrata, local(regions)
foreach region of local regions {
   sum remit12m_usd [aw= weight_cons] if astrata==`region' & cumul_distr_remittances>0.01 & cumul_distr_remittances<0.99, detail 
   replace remit12m_usd=r(p50) if remit12m_usd<. & astrata==`region' & (cumul_distr_remittances>0.99  | cumul_distr_remittances<0.01 )	
}

* Cleaning rule: replace "don't know" and "refused to respond" to mean of astrata
bys astrata: egen remit12m_astrata_mean = mean(remit12m_usd)
replace remit12m_usd = remit12m_astrata_mean if inlist(remit12m_amount_kdk, .a, .b)
drop remit12m_astrata_mean

* generate per capita per diem remittances values
gen remit_pcpd = remit12m_usd / hhsize / 365
recode remit_pcpd (missing=0)
la var remit_pcpd "Value of remittances per capita per diem"

save "${gsdData}/1-CleanTemp/hh.dta", replace
