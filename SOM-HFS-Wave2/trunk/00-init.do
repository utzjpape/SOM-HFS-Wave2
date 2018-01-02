
*Initialize work environment

global suser = c(username)

clear all
set more off
set maxvar 10000
set seed 23081980 
set sortseed 11041985

if (inlist("${suser}","wb390290","WB390290")) {
	*Utz
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\wb390290\OneDrive - WBG\Home\Countries\Somalia\Projects\HFS\Code\Wave2"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\wb390290\OneDrive - WBG\Home\Countries\Somalia\Projects\HFS\Shared\Wave2\Analysis\DataBox"
}
else if (inlist("${suser}","wb484006","WB484006")) {
	*Gonzalo
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\WB484006\OneDrive - WBG\Code\SOM\Wave 2"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\WB484006\WBG\Utz Johann Pape - Shared\Wave2\Analysis\DataBox"
	* cURL directory
	local curl = "C:\Users\WB484006\Documents"             
}
	
else if (inlist("${suser}","WB499706", "wb499706")) {
	*Philip
	*Local directory of your checked out copy of the code
	local swdLocal = "C:\Users\WB499706\OneDrive - WBG\WBG Data PW\Code\SOM\Wave 2"
	*Box directory where the Data folder can be located
	local swdBox = "C:\Users\WB499706\WBG\Utz Johann Pape - Sh-SOM-HFS\Wave2\Analysis\DataBox"
	* cURL directory
	local curl = "C:\Users\WB499706\Documents"
}

else if ("${suser}"=="Anne-Elisabeth") {
	*Anne-Elisabeth
	*Local directory of your checked out copy of the code
	local swdLocal = "C:/Users/Anne-Elisabeth/Dropbox/WB SHFS II/9. Data, Data Monitoring/1. Inputs, Codes and Outputs Pipeline/Code"
	*Box directory where the Data folder can be located
	local swdBox = "C:/Users/Anne-Elisabeth/Dropbox/WB SHFS II/9. Data, Data Monitoring/1. Inputs, Codes and Outputs Pipeline/Data"
}

else if ("${suser}"=="user") {
	*Jérôme
	*Local directory of your checked out copy of the code
	local swdLocal = "C:/Users/user/Dropbox/WB SHFS II/9. Data, Data Monitoring/1. Inputs, Codes and Outputs Pipeline/Code"
	*Box directory where the Data folder can be located
	local swdBox = "C:/Users/user/Dropbox/WB SHFS II/9. Data, Data Monitoring/1. Inputs, Codes and Outputs Pipeline/Data"
}

else if ("${suser}"=="romaingalgani") {
	*Romain
	*Local directory of your checked out copy of the code
	local swdLocal = "/Users/romaingalgani/Dropbox/WB SHFS II/9. Data, Data Monitoring/1. Inputs, Codes and Outputs Pipeline/Code"
	*Box directory where the Data folder can be located
	local swdBox = "/Users/romaingalgani/Dropbox/WB SHFS II/9. Data, Data Monitoring/1. Inputs, Codes and Outputs Pipeline/Data"
}	

else if ("${suser}"=="Antoine") {
	*Agnes
	*Local directory of your checked out copy of the code
	local swdLocal = "C:/Users/Antoine/Dropbox/WB SHFS II/9. Data, Data Monitoring/1. Inputs, Codes and Outputs Pipeline/Code"
	*Box directory where the Data folder can be located
	local swdBox = "C:/Users/Antoine/Dropbox/WB SHFS II/9. Data, Data Monitoring/1. Inputs, Codes and Outputs Pipeline/Data"
}
	
else {
	di as error "Configure work environment in 00-init.do before running the code."
	error 1
}


global gsdData = "`swdLocal'/Data"
global gsdDo = "`swdLocal'/Do"
global gsdTemp = "`swdLocal'/Temp"
global gsdOutput = "`swdLocal'/Output"
global gsdDownloads = "`swdBox'/00-Downloads"
global gsdDataRaw = "`swdBox'/0-RawInput"
global gsdShared = "`swdBox'"
global gsdBin = "`curl'"

*If needed, install the directories and packages used in the process 
capture confirm file "`swdLocal'/Data/nul"
scalar define n_data=_rc
capture confirm file "`swdLocal'/Temp/nul"
scalar define n_temp=_rc
capture confirm file "`swdLocal'/Output/nul"
scalar define n_output=_rc
scalar define check=n_data+n_temp+n_output
di check


if check==0 {
		display "No action needed"
}
else {
	mkdir "${gsdData}"
	mkdir "${gsdData}/0-RawTemp"
	mkdir "${gsdData}/0-RawOutput"
	mkdir "${gsdData}/1-CleanInput"
	mkdir "${gsdData}/1-CleanInput/SHFS2016"
	mkdir "${gsdData}/1-CleanTemp"
	mkdir "${gsdData}/1-CleanOutput"
	mkdir "${gsdTemp}"
	mkdir "${gsdOutput}"

}

*install packages used in the process
local commands = "labmask insheetjson missings diff labmv outreg2 geodist vincenty fastgini tabout logout svylorenz shp2dta spmap"
foreach c of local commands {
	qui capture which `c' 
	qui if _rc!=0 {
		noisily di "This command requires '`c''. The package will now be downloaded and installed."
		ssc install `c'
	}
}

qui capture which gicurve
qui if _rc!=0 {
		noisily di "This command requires 'gicurve'. The package will now be downloaded and installed."
		net install gicurve, replace from (http://www.adeptanalytics.org/download/ado) 
	}
