/*-------------------------------------------------------------------------------
# Name:		01_Datadownload
# Purpose:	Download the data from the USAID open data portal
# Author:	Tim Essam, Ph.D.
# Created:	2016/03/07
# Owner:	USAID GeoCenter | OakStream Systems, LLC
# License:	MIT License
# Ado(s):	see below
#-------------------------------------------------------------------------------
*/


cd "$pathin"
* Fetch data from web
local url1 "https://www.usaid.gov/opengov/developer/datasets/Uganda_Agric%20Practices_Data.csv"
copy `url1' ag.csv, replace

copy `url2' health.csv, replace
local url2 "https://www.usaid.gov/opengov/developer/datasets/Uganda_Child%20Health_Data.csv"

local url3 "https://www.usaid.gov/opengov/developer/datasets/Uganda_Food%20Consumption_Data.csv"
copy `url3' food.csv, replace

local url4 "https://www.usaid.gov/opengov/developer/datasets/Uganda_Maternal%20Health%20and%20HH%20Sanitation_Data.csv"
copy `url4' sanit.csv, replace



















local req_file ag health food sanit
local urls url1 url2 url3 url4
local n: word count `urls'

forvalues i = 1/`n' {
		local a: word `i' of `req_file'
		local b: word `i' of `urls'
		capture findfile `a'.csv
			if _rc == 601 {
					copy `b' `a'.csv, replace
			}
		else disp in yellow "`x' already downloaded and unzipped to Pathin folder." 	
}










local  
local required_file ag health food sanit 
cd "$pathin"

local i = 1
foreach x of local required_file {
		capture findfile `x'.csv
			if _rc == 601 {
					copy  `x'.csv, replace 
			}
			
}


