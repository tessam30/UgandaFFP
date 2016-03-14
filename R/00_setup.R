# ----------------------------------------------------------------
# Purpose: Process Food For Peace Baseline Data for Uganda Mission
# Author: Tim Essam
# Date: 2016/03/09
# Attribution: USAID GeoCenter / OakStream Systems, LLC
# -----------------------------------------------------------------

# Set up folder structure (clone repo from Github)
# Set up working directory for data

library(tidyr)
library(scales)
library(haven)
library(ggplot2)
library(dplyr)

setwd("~/GitHub/UgandaFFP/Datain")

#temp = list.files(pattern="*.csv")
#myfiles = lapply(temp, read.csv)

ag <- tbl_df(read.csv("ag.csv"))

table(ag$DIS)
