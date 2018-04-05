*Run SHFS Wave 2 Pipeline


*Check whether configuration is loaded
if "${gsdData}"=="" {
	di as error "Configure work environment by running 00-init.do before running the code."
	error 1
}

*Decide which parts of the pipeline should be run
local runimport = 0

*API Download of data for Urban, Rural and IDP households
if (`runimport'==1) {
	run "${gsdDo}/api_download.do"
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(1) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}") curl("${gsdBin}") 
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(2) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v2") curl("${gsdBin}") 
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(4) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v4") curl("${gsdBin}") 
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(6) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v6") curl("${gsdBin}") 
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(9) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v9") curl("${gsdBin}") 
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(10) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v10") curl("${gsdBin}") 
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(11) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v11") curl("${gsdBin}") 
}


* API Download of education phone survey data
if (`runimport'==1)  {
	run "${gsdDo}/api_download.do"
	api_download wbhfssom, quid(21cafde6df224ec8bd0be429d919bc40) quv(5) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/Phone Survey - v5") curl("${gsdBin}") 
	api_download wbhfssom, quid(21cafde6df224ec8bd0be429d919bc40) quv(6) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/Phone Survey - v6") curl("${gsdBin}")
}

*API Download of data for Nomads 
if (`runimport'==1) {
	run "${gsdDo}/api_download.do"
	api_download wbhfssom, quid(a539b55e361e41e9b8b549402c6e54d2) quv(1) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/Nomads - v1") curl("${gsdBin}") 
	api_download wbhfssom, quid(a539b55e361e41e9b8b549402c6e54d2) quv(2) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/Nomads - v2") curl("${gsdBin}") 
	api_download wbhfssom, quid(a539b55e361e41e9b8b549402c6e54d2) quv(4) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/Nomads - v4") curl("${gsdBin}") 
    *Listing form
	api_download wbhfssom, quid(22c77f1a675547ccb9eb878812bfe1ab) quv(1) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/Nomads - Listing") curl("${gsdBin}") 
}

*Manual cleaning of submissions
run "${gsdDo}/0-1-manual_cleaning.do"

*Obtain valid interviews
run "${gsdDo}/0-2-obtain_valid_keys.do"
run "${gsdDo}/0-3-obtain_valid_EAs_and_EBs.do"

*Include education 
run "${gsdDo}/0-4-Include_education.do"

*Obtain key for valid and successul submissions 
run "${gsdDo}/0-5-keep_valid_successful_submissions.do"

*Check the completeness of submissions between parent and child files 
run "${gsdDo}/0-6-completeness_submissions.do"

*Clean the parent and child files 
run "${gsdDo}/0-7-clean.do"

*Prepare the master sample 
capture confirm file "${gsdData}\0-RawTemp\master_sample.dta"
scalar define check_1=_rc
capture confirm file "${gsdData}\0-RawTemp\master_idps_camps.dta"
scalar define check_2=_rc
gen check=check_1+check_2
scalar define check=check_1+check_2
di check
if check==0 {
	display "Master Sample already obtained: No need to re-run this part of the code"
}
else {
	run "${gsdDo}/0-8-prepare_master_sample.do"
}

*Obtain the sampling weights
run "${gsdDo}/0-9-estimate_sample_weights.do"

*Include regional breakdown and files needed 
run "${gsdDo}/0-10-PESS_regions.do"

*Anonymize the datasets
run "${gsdDo}/0-11-anonymize_dataset.do"

*Obtain the average exchange rate
run "${gsdDo}/0-12-exchange_rate.do"

*Prepare MPS prices with COICOP codes
run "${gsdDo}/0-13-COICOP_MPS.do"

*Clean the consumption datasets
run "${gsdDo}/1-2-clean_fcons.do"
run "${gsdDo}/1-3-clean_nonfcons.do"
run "${gsdDo}/1-4-clean_assets.do"

*Report the cleaned consumption values
run "${gsdDo}/1-5-summary_clean_data.do"

*Clean household member dataset
run "${gsdDo}/1-6-clean_hhm_educ_labor.do"

*Clean remittances
run "${gsdDo}/1-7-clean_remittances.do"

*Consumption Aggregates Deflator and Imputation 
run "${gsdDo}/1-8-1-consaggr_deflator.do"
run "${gsdDo}/1-8-2-consaggr_imputation.do"
run "${gsdDo}/1-8-3-include_imputed_shares.do"
run "${gsdDo}/1-8-4-consaggr_test.do"


*Decide which parts of the pipeline should be run
local run_imputation_robustness = 0

*Robustness for the imputation 
if (`run_imputation_robustness'==1) {
	run "${gsdDo}/1-8-5-consaggr_imputation_robustness.do" 
}


*Clean household level dataset, integrate aggregates from previous cleaning files
run "${gsdDo}/1-9-clean_hh.do" 

*Produce a combined dataset for Wave 1 and 2
run "${gsdDo}/1-10-Combine_w1_w2.do" 

/*
Conduct IDP analysis
run "${gsdDo}/2-5-PA_IDP_Comparison_Groups.do"   
run "${gsdDo}/2-5-PA_IDP_Demographics.do" 
run "${gsdDo}/2-5-PA_IDP_Origin.do" 
run "${gsdDo}/2-5-PA_IDP_Push_Pull_Factors.do" 
run "${gsdDo}/2-5-PA_IDP_Documents.do" 
run "${gsdDo}/2-5-PA_IDP_Separation.do"
