*Run SHFS Wave 2 Pipeline


*check whether configuration is loaded
if "${gsdData}"=="" {
	di as error "Configure work environment by running 00-init.do before running the code."
	error 1
}

*API Download of data (only from Gonzalo's or Philip's computer)
if (inlist("${suser}","wb484006","WB484006","WB499706","wb499706")) {
	run "${gsdDo}/api_download.do"
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(1) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}") curl("${gsdBin}") 
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(2) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v2") curl("${gsdBin}") 
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(4) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v4") curl("${gsdBin}") 
	api_download wbhfssom, quid(f9defff5dcf94c5d93df6e7438656cac) quv(6) username(HQ_API) password(z7Ko1A#m%yPe) directory("${gsdDownloads}/v6") curl("${gsdBin}") 
}

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

*Prepare the master sample 
capture confirm file "${gsdData}\0-RawTemp\master_sample.dta"
scalar define check=_rc
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

*Prepare FSNAU prices with COICOP codes
*run "${gsdDo}/0-13-COICOP_FSNAU_prices.do"

*Clean the consumption datasets
*run "${gsdDo}/1-2-clean_fcons.do"
*run "${gsdDo}/1-3-clean_nonfcons.do"
*run "${gsdDo}/1-4-clean_assets.do"

*Report the cleaned consumption values
*run "${gsdDo}/1-5-summary_clean_data.do"

*Clean household member dataset
*run "${gsdDo}/1-6-clean_hhm_educ_labor.do"

*Clean remittances
*run "${gsdDo}/1-7-clean_remittances.do"

*Consumption Aggregates Deflator and Imputation 
*run "${gsdDo}/1-8-1-consaggr_deflator.do"
*run "${gsdDo}/1-8-2-consaggr_imputation.do"
*run "${gsdDo}/1-8-3-include_imputed_shares.do"
*run "${gsdDo}/1-8-4-consaggr_test.do"

*Clean household level dataset, integrate aggregates from previous cleaning files
*run "${gsdDo}/1-9-clean_hh.do" 
