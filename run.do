*Run SHFS Wave 2 Pipeline


*check whether configuration is loaded
if "${gsdData}"=="" {
	di as error "Configure work environment by running 00-init.do before running the code."
	error 1
}


*API Download of data
run "${gsdDo}/api_download.do"
api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(1) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}") curl("${gsdBin}") 
api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(2) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v2") curl("${gsdBin}") 
api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(4) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v4") curl("${gsdBin}") 
api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(6) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v6") curl("${gsdBin}") 


*Monitoring Dashboard 
run "${gsdDo}/0-1-manual_cleaning.do"
run "${gsdDo}/0-2-obtain_valid_keys.do"
run "${gsdDo}/0-3-obtain_valid_EAs_and_EBs.do"
run "${gsdDo}/0-4-create_monitoring_dashboard.do"

*Obtain key for valid and successul submissions 
run "${gsdDo}/0-5-keep_valid_successful_submissions.do"

*Check the completeness of submissions between parent and child files 
run "${gsdDo}/0-6-completeness_submissions.do"

*Clean the parent and child files 
run "${gsdDo}/0-7-clean.do"

