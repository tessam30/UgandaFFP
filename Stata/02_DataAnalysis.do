clear


cd "C:\Users\Tim\Documents\GitHub\UgandaFFP"
global pathin "C:/Users/Tim/Documents/Github/UgandaFFP/Datain"
global pathout "C:/Users/Tim/Documents/GitHub/UgandaFFP/Dataout"
cd $pathin

fs *.csv
foreach f in `r(files)' {
	import delimited "`f'"
	local F : subinstr local f ".csv" ""
	display "`F'"
	save $pathout/`F'.dta, replace
	clear
	}
*

*** Only need to run above once ***
* Most of the variables are already created *
* Just need to roll-them up to the district level for mapping *
* Variables needed :
* 1. Stunting prevalence under 5 and under 3
* 2. Prevalence of households with moderate or severe hunger
* 3. Average Household Dietary Diversity
* 4. Prevalence of poverty (% living on less than 1.25 / day)
* 5. Mean depth of poverty
* 6. Percentage of households using an improved drinking water source

cd $pathout
use "ag.dta", clear

* Filter on merge variables that are useful at the hh level
keep id dis vn hh strata cluster

* collapse observations by hh


use "food.dta", clear

* Keep only indicators of use
#delimit ;
keep strata id h00h cluster pvo hhwt total_members
	assets_total total_consumption mhwt gendered_hh 
	total_consumption_2010 poverty poverty_gap_index
	food_consumption_2010 poverty_line poverty_gap;
# delimit cr
save "food_subset.dta", replace
 
* This appears to only contain information on children 
use "health.dta", clear

* Eureka! chwt is the sampling weight to use for children



#delimit ; 
keep  anthro_date agedays region urbanr sex 
	length weight2 oedema agedays3 agemos lorh
	chwt wgting diarrhea filter ort foods_min 
	foods liquids breastfeeding exclusive_breast 
	age_0_23 dd* zhaz zbmi zwaz zwhz id dis vn hh;
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

mean stunted [pweight = chwt], over(sex)
mean stunted [pweight = chwt]



save "health_subset.dta", replace




# delimit ;
use "sanit.dta", clear
keep id hh vn strata cluster pvo hhwt 
	improved_water improved_sanitation 
	soap_water critical_handwashing;
# delimit cr
save "sanit_subset.dta", replace








tab dis
clonevar district = dis
la def dis 1 "Kaabong" 2 "Kotido" 3 "Abim"/*
*/4 "Moroto" 5 "Napak" 6 "Nakapiripirit" 7 "Amudat"
lab values district dis
	
