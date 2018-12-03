*This do file uses the final set of variables (C-N-S) to identify a typology of IDPs 

set more off
set seed 324324 
set sortseed 542352

*Get data
use "${gsdData}/1-CleanTemp/typologyvariables.dta", clear
svyset ea [pweight=weight_adj], strata(strata) singleunit(centered)

*********************************************
*MCA model 
*********************************************
local cause own_any_prod_prev  distance_pre origin_now harm_dum disp_reason_concise disp_arrive_reason livestockown_pre livelihood_prev land_access_yn_disp housingimproveddisp
local needs hhsize5 housingimproved waterimproved sanimproved_shared hunger_dum livelihood assist_source_any land_access_yn own_any_prod livestockown hhh_literacy distance dependency_dum hhh_gender move_free
local solution movetime pullpush_security information_final movehelp_new
mca `cause' `needs' `solution' , method(joint) dimensions(3)
*3 dimensions seems appropriate

predict a1 a2 a3 
mcaplot, title("CNS")
graph export "${gsdOutput}/cns.png", replace
mcaplot, overlay xline(0) yline(0) scale(0.8) title("Point cloud - Variables, CNS")
graph export "${gsdOutput}/cns_vbles.png", replace 
scatter a2 a1, xline(0) yline(0) scale(.5) title("Point cloud - Households, CNS")
graph export "${gsdOutput}/cns_hhs.png", replace 

*HCA to identify households  
set seed 54352 
set sortseed 76343
cluster wardslinkage a1 a2 a3, gen(clust_var)
cluster tree, cutnumber(100) graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/cns_dendogram.gph", replace
graph export "${gsdOutput}/cns_dendogram.png", replace

*Dendogram shows 2 clusters, one big one small.
cluster stop
cluster stop, rule(duda)
cluster generate cluster_group_war = group(2)
tab cluster_group_war , m
label values cluster_group_war cluster
save "${gsdTemp}/working_file.dta", replace

*****************************
*Visualize the clusters
*****************************
*MCA cloud of HHs divided by group identified (2D and 3D)
*Two clusters
*2d
graph3d a1 a2 a3 cluster_group_war, colorscheme(cr) xangle(0) yangle(120) zangle(240) cuboid mark 
graph save "${gsdOutput}/2clusters_3d.gph"
graph export "${gsdOutput}/2clusters_3d.png", replace
*3d
twoway (scatter a2 a1 if (inlist(cluster_group_war,1)),  msize(small) mcolor(black)) ///
(scatter a2 a1 if (inlist(cluster_group_war,2)),  msize(small) mcolor(blue)), xline(0) ///
yline(0) scale(.8) legend(on order(1 "Group 1" 2 "Group 2" )) ///
ytitle(PCA dimension 1) xtitle(PCA dimension 2) yscale(range(-3 3)) xscale(range(-2 3)) ylabel(#1) xlabel(#1)  graphregion(color(white)) bgcolor(white)
graph save "${gsdOutput}/2clusters_2d.gph", replace
graph export "${gsdOutput}/2clusters_2d.png", replace

*********************************
*Summary stats of the MCA inputs
*********************************
*Cause
sum own_any_prod_prev  distance_pre origin_now harm_dum disp_reason_concise disp_arrive_reason livestockown_pre livelihood_prev land_access_yn_disp housingimproveddisp
*Needs
sum hhsize5 housingimproved waterimproved sanimproved_shared hunger_dum livelihood assist_source_any land_access_yn own_any_prod livestockown hhh_literacy distance dependency_dum hhh_gender move_free
*Solution
sum movetime pullpush_security information_final movehelp_new
*MCA inertia stats
mca `cause' `needs' `solution' , method(joint) dimensions(3)

