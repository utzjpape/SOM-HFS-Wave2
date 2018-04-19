*This do file analyses drought and conflict dates

*Drought: rainfall and NDVI stats
import excel using "${gsdShared}\0-Auxiliary\Climate Data\Rainfall_NDVI_2006-2017.xlsx", clear firstrow case(lower)
destring ndvianomaly, force replace
collapse (mean)  rainfall_anomaly_1m=onemonthanomaly rainfall_anomaly_3m=threemonthsanomaly  ndvi_anomaly=ndvianomaly, by(year month)
gen date = ym(year, month)
order date
format date %tm
gen monthstring = "Jan" if month ==1
replace monthstring = "Feb" if month ==2
replace monthstring = "Mar" if month ==3
replace monthstring = "Apr" if month ==4
replace monthstring = "May" if month ==5
replace monthstring = "Jun" if month ==6
replace monthstring = "Jul" if month ==7
replace monthstring = "Aug" if month ==8
replace monthstring = "Sep" if month ==9
replace monthstring = "Oct" if month ==10
replace monthstring = "Nov" if month ==11
replace monthstring = "Dec" if month ==12
egen stringdate = concat (monthstring year), p(-)
sort date
order stringdate
keep stringdate rainfall_anomaly_1m rainfall_anomaly_3m ndvi_anomaly
export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetreplace sheet("Rainfall-NDVI") first(variables)

*Conflict
*Prepare ACLED data
insheet using "${gsdShared}\0-Auxiliary\Conflict/ACLED_SOM-2006-2018.csv", clear 
*Convert event type to numeric and simplify categories
encode event_type, gen(x)
recode x (1 2 3=1 "Battle") (4 5 8=2 "Strategic development") ( 6=3 "Remote violence") (7=4 "Riots/Protests" ) (9=5 "Violence against civilians"), gen(events_recode)
tab events_recode 
*Get dates by month
gen date = date(event_date, "DM20Y")
format date %td
gen m=mofd(date)
format m %tm
*Reshape to get number of each event per month
collapse (count) x (sum) fatalities, by(events_recode m)
reshape wide x fatalities, j(events_recode ) i(m )
*Label the events
label var x1 "Battle" 
label var x2 "Strategic development"
label var x3 "Remote violence"
label var x4 "Riots/protests"
label var x5 "Violence against civilians"
*Keep only total fatalities from all events
egen fatalities=rowtotal(fatalities*)
drop fatalities?
label var fatalities "Fatalities"
*Reformat date for graphs
generate event_date=dofm(m)
generate d = string(event_date, "%td")
gen my = substr(d,3,.)
gen m1=strupper(substr(my,1,1))
gen m2=substr(my,2,2)
gen month=m1+m2
drop m1 m2
gen year=substr(my,4,4)
gen ym=month+"-"+year
label var ym "Month"
*Tabout the conflict data
sort m
order ym x1 x2 x3 x4 x5 fatalities
keep ym x1 x2 x3 x4 x5 fatalities
export excel using "${gsdOutput}/Figures_SOM.xlsx", sheetmodify sheet("ACLED") first(varlabels) 
