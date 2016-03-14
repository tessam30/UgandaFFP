clear

cd "C:\Users\t\Documents\GitHub\UgandaFFP"
global pathin "C:/Users/t/Documents/Github/UgandaFFP/Datain"
global pathout "C:/Users/t/Documents/GitHub/UgandaFFP/Dataout"
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
use ag, clear

* Keep only indicators of use









tab dis
clonevar district = dis
la def dis 1 "Kaabong" 2 "Kotido" 3 "Abim"/*
*/4 "Moroto" 5 "Napak" 6 "Nakapiripirit" 7 "Amudat"
lab values district dis
	
