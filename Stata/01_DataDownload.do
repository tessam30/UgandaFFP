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
capture log close
log using "Datadownload.txt", replace

* Grab data from opendata.gov
cd "$pathin"
* Fetch data from web
local url1 "https://www.usaid.gov/opengov/developer/datasets/Uganda_Agric%20Practices_Data.csv"
copy `url1' ag.csv, replace

local url2 "https://www.usaid.gov/opengov/developer/datasets/Uganda_Child%20Health_Data.csv"
copy `url2' health.csv, replace

local url3 "https://www.usaid.gov/opengov/developer/datasets/Uganda_Food%20Consumption_Data.csv"
copy `url3' food.csv, replace

local url4 "https://www.usaid.gov/opengov/developer/datasets/Uganda_HH%20Description_Data.csv"
copy `url4' hhdesc.csv, replace

local url5 "https://www.usaid.gov/opengov/developer/datasets/Uganda_Maternal%20Health%20and%20HH%20Sanitation_Data.csv"
copy `url5' sanit.csv, replace

log close
