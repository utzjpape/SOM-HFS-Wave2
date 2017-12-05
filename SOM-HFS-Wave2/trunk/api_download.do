* Program for data download from Survey Solutions servers with API using cURL

***************
*** PROGRAM ***
***************
capture program drop api_download
program api_download 
	syntax namelist(name=prefix id="Server prefix" local), username(string) password(string) quid(string) quv(string) directory(string) curl(string) [fmt(string) suffix(string)]	
	
	*** Check file paths and packages in place 
	* cURL
	capture confirm file "${gsdBin}/curl.exe"
	qui if _rc!=0 { 
		noisily di as error "It appears cURL does not exist in the directory you specified." 
		noisily di as error "On the website that is about to open - https://curl.haxx.se/dlwiz/ - follow the following steps"
		noisily di as error "Step 1: choose 'curl executable'."
		noisily di as error "Step 2: Select your operating system (Most likely Win64)."
		noisily di as error "Step 3: Choose generic."
		noisily di as error "Step 4: Choose any."
		noisily di as error "Step 5: Select x86_64."
		noisily di as error "Step 6: Choose a download and, once downloaded, look for 'curl.exe'"
		noisily di as error "Step 7: In the init.do file, make sure that the 'gsdBin' path specifies the folder where 'curl.exe' is found."
		sleep 5000
		view browse https://curl.haxx.se/dlwiz/
	}
	*insheetjson, which we need in the process, is installed
	qui capture which insheetjson
	qui if _rc!=0 {
		noisily di "This command requires 'insheetjson'. The package will now be downloaded and installed."
		ssc install insheetjson
	}

	*** Define other necessary parameters ***
	* Start the compilation of the download file
	local action_start = "start"
	* check on progress of compilation
	local action_check = "details"
	* Download the file
	local action_download = ""
	* Set default value of format to "stata"
	qui if "`fmt'"=="" {
		noisily di "Default format: Stata data (.dta). To change format, specify fmt() option."
		local fmt "stata"
	}
	* Set default subdirectory 
	qui capture confirm file "`directory'/nul" 
	if _rc!=0 {
		noisily di "Specified directory not found. Directory `directory' created."
		capture mkdir "`directory'"
	}
	* request for curl, using the local macros defined by program
	local request = "https://`prefix'.mysurvey.solutions/api/v1/export/`fmt'/`quid'$`quv'"

	*** Requests ***
	* prompt server to rebuild data set 
	shell "`curl'/curl" -H "Content-Length: 0" -u "`username':`password'" --request POST "`request'/`action_start'" --insecure 
	* since rebuilding takes a bit of time, make Stata wait for 10 seconds
	noisily di "Requesting data sets to be compiled on server..."
	sleep 10000
	* now check on status of rebuilding 		
	shell "`curl'/curl" -u "`username':`password'" --request GET "`request'/`action_check'" --insecure --output "`directory'/status`suffix'"
	* Inspect status - if not done, wait and  then try again
	qui insheetjson using "`directory'/status`suffix'", topscalars 
	noisily di "Status of compilation:"
	noisily di r(ExportStatus)
	while (r(ExportStatus)!="Finished") {
		* give it a bit of time
		sleep 10000
		* get updated status 
		shell "`curl'/curl" -u "`username':`password'" --request GET "`request'/`action_check'" --insecure --output "`directory'/status`suffix'"
		* Inspect status
		qui insheetjson using "`directory'/status`suffix'", topscalars 
		noisily di r(ExportStatus)
		* If there's an error, we want to restart the process
		if (r(ExportStatus)=="FinishedWithError") {
			* prompt server to rebuild data set 
			shell "`curl'/curl" -H "Content-Length: 0" -u "`username':`password'" --request POST "`request'/`action_start'" --insecure 
			* since rebuilding takes a bit of time, make Stata wait for 10 seconds
			sleep 10000
		}
	}

	*** Download the data ***
	noisily di "Downloading the data..."
	shell "`curl'/curl" -u "`username':`password'" --request GET "`request'/`action_download'" --insecure > "`directory'/Downloads`suffix'.zip" 
	noisily di "Unzipping data sets..."
	* unzipfile command isn't very flexible, requires changing directory
	local default_dir `c(pwd)'
	qui cd "`directory'"
	qui unzipfile "`directory'/Downloads`suffix'.zip", replace
	* change back to default directory
	qui cd "`default_dir'"
	* remove unnecessary files
	qui rm "`directory'/Downloads`suffix'.zip"
	qui rm "`directory'/status`suffix'"
	di as result "Data successfully downloaded to `directory'"
end

**************
*** SYNTAX ***
**************
* api_download prefix, quid() quv() username() password() directory() curl() [fmt() suffix()]

*Required*
* prefix: the server prefix e.g. wbmpsssd for SSD MPS
* quid(namelist): the questionnaire ID  
* quv(namelist): the questionnaire version
* directory(namelist): Directory for data download
* curl(namelist): Directory in which cURL is found

*Optional*
* fmt(namelist): the default is Stata data (.dta). Other formats may be specified
* Options for fmt(): stata, tabular, spss, binary, paradata
* suffix(namelist): suffix will be placed after downloaded 
* zip file and json file (both are deleted once the process is finished).

* Test
*api_download server_name, quid(...) quv(...) username(...) password(...) directory("Downloads folder path/...") curl("cURL.exe path/...") suffix(...)

