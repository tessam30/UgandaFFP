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





use "food.dta", clear

* Keep only indicators of use
#delimit ;
keep strata id h00h cluster pvo hhwt total_members
	assets_total total_consumption mhwt gendered_hh 
	total_consumption_2010 poverty poverty_gap_index
	food_consumption_2010 poverty_line poverty_gap;
# delimit cr




save "food_subset.dta", replace
 
use "health.dta", clear




#delmited ; 
keep keep anthro_date agedays region urbanr sex 
	lorh length weight2 oedema agedays3 agemos 
	chwt wgting diarrhea filter ort foods_min 
	foods liquids breastfeeding exclusive_breast 
	age_0_23 dd* zhaz zbmi zwaz zwhz id dis vn hh;
# delimit cr
save "health_subset.dta", replace




# delmited ;
use "sanit.dta", clear
keep id hh vn strata cluster pvo hhwt 
	improved_water improved_sanitation 
	soap_water critical_handwashing;
save "sanit_subset.dta", replace








tab dis
clonevar district = dis
la def dis 1 "Kaabong" 2 "Kotido" 3 "Abim"/*
*/4 "Moroto" 5 "Napak" 6 "Nakapiripirit" 7 "Amudat"
lab values district dis
	
