clear


cd "C:\Users\Tim\Documents\GitHub\UgandaFFP"
global pathin "C:/Users/Tim/Documents/Github/UgandaFFP/Datain"
global pathout "C:/Users/Tim/Documents/GitHub/UgandaFFP/Dataout"
cd $pathin

* Convert the .csv files to .dta files so you don't have to insheet each 
* of them each time
fs *.csv
set tr on
foreach f in `r(files)' {
	import delimited "`f'", clear
	local F : subinstr local f ".csv" ""
	display in yellow "`F'.csv now being converted to Stata file"
	save $pathout/`F'.dta, replace
	}
*

*** Only need to run above once ***
* Most of the variables are already created *
* Just need to roll-them up to the district level for mapping *
* Variables needed :
* 1. Stunting prevalence under 5 and under 3 - (check)
* 2. Prevalence of households with moderate or severe hunger 
* 3. Average Household Dietary Diversity
* 4. Prevalence of poverty (% living on less than 1.25 / day) (check)
* 5. Mean depth of poverty (check)
* 6. Percentage of households using an improved drinking water source (check)

cd $pathout

/* First, we need to figure out what uniquely identifies a household. To do 
this let's start with the hhdesc data. */
use "hhdesc.dta", clear

* Let's destring b01 as that looks to be the hh roster number
g indiv_id = .
replace indiv_id = real(b01)
drop if indiv_id == .

* isid id hhid -- this fails so we need to figure out why
bys id (indiv_id): gen ind_id = _n
egen hhid = group(id ind_id)
bys hhid: gen idfin = _N

* 4766 corresponds to the number of households reported in the final report.
tab ind_id, mi
isid id ind_id

la var ind_id "individual id"
la var id "household id"
la var hhid "unique identifier for survey subject (id + ind_id)"

* Keep only information about the household head (hhid == 1)
keep ind_id id dis vn strata cluster hhwt 
keep if ind_id == 1


la var dis "District"
la def dist 1 "Kaabong" 2 "Kotido" 3 "Abim" 4 "Moroto" 5 "Napak" 6 "Nakapiripirit" 7 "Amudat"
lab values dis dist
ren dis district

save "$pathout/hh_info.dta", replace

*************************
* Consumption  outcomes *
*************************
use "food.dta", clear

* id is a unique identifier for this dataset (at hh level)
* Keep only indicators of use
#delimit ;
keep strata id h00h cluster pvo hhwt total_members
	assets_total total_consumption mhwt gendered_hh 
	total_consumption_2010 poverty poverty_gap_index
	food_consumption_2010 poverty_line poverty_gap
	mhwt;
# delimit cr

* Merge in district information based on household id;
* Need this to make statistics at district level
merge 1:1 id using "$pathout/hh_info.dta"

* Reproduce table 4.2
rename  (total_consumption_2010 poverty_gap_index) (perCapitaExp meanDepthPov)
mean poverty perCapitaExp meanDepthPov [pweight = mhwt], over(district)

levelsof dis, local(levels)
foreach x of varlist poverty perCapitaExp meanDepthPov {
		gen `x'_dis = .
	foreach y of local levels {
			di in yellow "Running over district `y'"
			sum `x' [weight = mhwt] if dis == `y'
			replace `x'_dis = `r(mean)' if dis == `y'
	}
}

* Collapse down keeping main outcomes of interest
include "$pathdo/copylabels.do"
collapse (mean) poverty_dis poverty  perCapitaExp* meanDepthPov* (count) sample_pov=poverty, by(district)
include "$pathdo/attachlabels.do"
la var sample_pov "sample size for poverty indicators"

save "food_subset.dta", replace
 

*************************
* Child Health Outcomes *
*************************
* This appears to only contain information on children 
use "health.dta", clear

* Eureka! chwt is the sampling weight to use for children
#delimit ; 
keep  anthro_date agedays region urbanr sex 
	length weight2 oedema agedays3 agemos lorh
	chwt wgting diarrhea filter ort foods_min 
	foods liquids breastfeeding exclusive_breast 
	age_0_23 dd* d51check meal_frequency mad
	ddseven_rec ddsix_rec meal_frequency_rec1 
	meal_frequency_rec2
	zhaz zbmi zwaz zwhz id dis vn hh;
# delimit cr

* Convert these to numerical, many of them are strings; First convert the dates
g anthro_date2 = date(anthro_date, "MDY")
format anthro_date2 %td
mdesc anthro_date2
clist anthro_date anthro_date2 if anthro_date2 == .
drop anthro_date

* Grab evertthing that is not a numeric to convert to one using ds & loop
ds, has(type string)
destring `r(varlist)', replace

drop if hh == .

* Label the districts
la def dist 1 "Kaabong" 2 "Kotido" 3 "Abim" 4 "Moroto" 5 "Napak" 6 "Nakapiripirit" 7 "Amudat"
lab values dis dist

/**
foreach x of any `r(varlist)' {
		ren `x' `x'_old
		di "`x'_old"
		gen `x' = real(`x'_old)
		clist `x' `x'_old if `x'!= real(`x'_old)
		assert `x' == real(`x'_old) 
}
*/
ren zhaz stunting
ren zwaz underweight
ren zwhz wasting
ren zbmi BMI

la var stunting "Stunting: Length/height-for-age Z-score"
la var underweight "Underweight: Weight-for-age Z-score"
la var wasting "Wasting: Weight-for-length/height Z-score"

g byte stunted = stunting < -2 if stunting != .
g byte underwgt = underweight < -2 if underweight != . 
g byte wasted = wasting < -2 if wasting != . 
g byte BMIed = BMI <-2 if BMI ~= . 
la var stunted "Child is stunting"
la var underwgt "Child is underweight for age"
la var wasted "Child is wasting"

mean stunted [pweight = chwt], over(dis)

* Create some holder vars, fill them with weighted and unweighted estimates by district
g stunted_dis = .
g stunted_dis_unwgt = . 
g stunted_und3 = .
g stunted_und3_unwgt = .
g mad_dis = .
levelsof dis, local(levels)
foreach x of local levels {
		sum stunted [weight = chwt] if dis == `x'
		replace stunted_dis = `r(mean)' if dis == `x'
		
		sum stunted  if dis == `x'
		replace stunted_dis_unwgt = `r(mean)' if dis == `x'
		
		sum stunted [weight = chwt] if dis == `x' & agemos <= 36
		replace stunted_und3 = `r(mean)' if dis == `x' & agemos <= 36
		
		sum stunted if dis == `x' & agemos <= 36
		replace stunted_und3_unwgt = `r(mean)' if dis == `x' & agemos <= 36
		
		sum mad [pweight = chwt]  if dis == `x'
		replace mad_dis = `r(mean)' if dis == `x'
}


la var stunted_dis "Average stunting rate by district (weighted) all children"
la var stunted_dis_unwgt "Average stunting rate by district (unweighted) all children"
la var stunted_und3 "Average stunting rate by district (weighted) for children under 3"
la var stunted_und3_unwgt "Average stunting rate by district (unweighted) for children under 3"
la var mad_dis "minimum acceptable diet (weighted) for children under 3"
la var dis "District"

* collapse data down to district level for mission (Parish info does not appear to exist)
include "$pathdo/copylabels.do"
collapse (mean) stunted_dis stunted_dis_unwgt stunted_und3 stunted_und3_unwgt mad_dis mad (count) sample_stunting = stunted_dis sample_mad = mad_dis, by(dis)
include "$pathdo/attachlabels.do"
drop if dis == .

save "health_subset.dta", replace


*************************
* Sanitation  Outcomes *
*************************
* This contains household information on sanitation and dietary diversity
use "sanit.dta", clear

* eligible_women means women between (15 - 49 years)

# delimit ;
keep id hh vn strata cluster pvo hhwt 
	improved_water improved_sanitation 
	hhwt hdds dis ;
# delimit cr

g dietdiv = .
replace dietdiv = real(hdds)

mean improved_water [pweight = hhwt], over(dis)
mean improved_sanitation [pweight = hhwt], over(dis)

* Creating both weighted and unweighted point estimates to give mission
* options for maps.
rename (improved_sanitation improved_water)(imp_sanit imp_h20)

levelsof dis, local(levels)
foreach x of varlist dietdiv imp_sanit imp_h20 {
		gen `x'_dis = .
	foreach y of local levels {
			di in yellow "Running over district `y'"
			sum `x' [weight = hhwt] if dis == `y'
			replace `x'_dis = `r(mean)' if dis == `y'
	}
}

la var imp_h20 "improved water source"
la var imp_sanit "improved sanitation"
la var dietdiv "dietary diversity"
la var imp_sanit_dis "improved sanitation - district ave"
la var imp_h20_dis "improved water source - district ave"
la var dietdiv_dis "dietary diversity - district ave"

* collapse data down to district level for mission (Parish info does not appear to exist)
include "$pathdo/copylabels.do"
collapse (mean) imp_h20 imp_h20_dis imp_sanit imp_sanit_dis dietdiv dietdiv_dis (count) sample_imp = imp_h20, by(dis)
include "$pathdo/attachlabels.do"
drop if dis == .

la var sample_imp "sample size from improved water sources"
















g imp_h20 = .
g imp_h20_unwgt = . 
g imp_sanit = .
g imp_sanit_unwgt = .
levelsof dis, local(levels)
foreach x of local levels {
		* First replace improved water
		sum improved_water [weight = hhwt] if dis == `x'
		replace imp_h20 = `r(mean)' if dis == `x'
		*sum improved_water  if dis == `x'
		*replace imp_h20_unwgt = `r(mean)' if dis == `x'

		* Second, replace improved sanitation
		sum improved_sanitation [weight = hhwt] if dis == `x'
		replace imp_sanit = `r(mean)' if dis == `x'
		*sum improved_sanitation if dis == `x'
		*replace imp_sanit_unwgt = `r(mean)' if dis == `x'
}

* Collapse down to district level
include "$pathdo/copylabels.do"
collapse (mean) imp_h20 improved_water imp_sanit improved_sanitation /*
*/ (count) samplesize = imp_h20, by(dis)
include "$pathdo/attachlabels.do"

foreach x of varlist imp_sanit improved_sanitation {
		replace `x' = . if `x'==0
}
save "sanit_subset.dta", replace








tab dis
clonevar district = dis
la def dis 1 "Kaabong" 2 "Kotido" 3 "Abim"/*
*/4 "Moroto" 5 "Napak" 6 "Nakapiripirit" 7 "Amudat"
lab values district dis
	
