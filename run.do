*Run SHFS Wave 2 Pipeline


*check whether configuration is loaded
if "${gsdData}"=="" {
	di as error "Configure work environment by running 00-init.do before running the code."
	error 1
}


* API Download of data
run "${gsdDo}/api_download.do"
api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(1) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}") curl("${gsdBin}") 


