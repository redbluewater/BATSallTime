###This R code is for merging new bottlefile data into existing master bottlefile
##adopted from old R code "Join_BATS_ALL_with_master.R" by Shuting Liu before July 2022, 
#updated by Shuting on Oct 20, 2023 to add more automatic functional and reduce the manual editing 
#Krista Longnecker, updating to add in BATS cruises 10390 to 10404; 2 January 2024

library(dplyr)
library(readxl)


##first, read in the existing discrete file so that you know what you are matching the columns to...
dPath <- "C:/Users/klongnecker/Documents/Dropbox/Current projects/Kuj_BIOSSCOPE/RawData/DataFiles_CTDandDiscreteSamples/"
#master<-read.csv(paste0(dPath,"BATS_BS_COMBINED_MASTER_2023.11.28.csv"),header=T) #read in old master (CSV?)
#read in the master file - which is currently an Excel file
fName <- "BATS_BS_COMBINED_MASTER_2023.11.28.xlsx"
sheetName <- "BATS_BS bottle file"

#definitely want suppressWarnings here to prevent one error message for each row
discrete <- suppressWarnings(read_excel(paste0(dPath,fName),sheet = sheetName))
rm(dPath,fName,sheetName)


setwd("C:/Users/klongnecker/Documents/Dropbox/Current projects/Kuj_BIOSSCOPE/RawData/CTDdata/BSworking")


#get the list of folders - will go into each folder one at a time and concatenate the results
D <- dir(pattern = "*BIOSSCOPE_physf*",recursive=T)
cruiseType <- 'BATS' #or BIOSSCOPE

idx <- 1

##add new CTD data first
#download new BATS or BIOSSCOPE bottle file from "ORIG CTD FROM BATS" folder
#open .dat files and separate into columns
new<-read.delim(D[[idx]],header=F,sep="")

#add in header information from CTD ID.docx in 91614 folder in "ORIG CTD FROM BATS", or you can find header from BATS data website
colnames(new)<-c("Niskin_ID","YYYYMMDD_In","YYYYMMDD_out","Dec_yr_in","Year_day_in","Time_in(GMT)","Time_out(GMT)","Lat(N)_in","Lat(N)_out","Long(W)_in","Long(W)_out","flag","P(dbar)","z(m)","CTD_temp(degC)","CTD_SBE35T(degC)","Cond(S_m)","CTD_salt","DO(umol/kg)","BAC (m-1)","Fl(RFU)","PAR(uE/m^2)","Pot_Temp(degC)","sig_theta(kg/m^3)","wet_salt1","wet_salt2","Wet_O2_1","Wet_O2_2","Wet_O2_3","Nisken_temp (degC)","Oxy_anom1(umol/kg)","Oxy_anom2(umol/kg)","Oxy_anom3(umol/kg)")
#Delete columns to match same columns on BIOSSCOPE Master bottlefile, we use _in data
new<- new[ , -which(colnames(new) %in% c("YYYYMMDD_out","Year_day_in","Time_out(GMT)","Lat(N)_out","Long(W)_out","flag","wet_salt2","Wet_O2_1","Wet_O2_2","Wet_O2_3","Oxy_anom2(umol/kg)","Oxy_anom3(umol/kg)"))]
#new file column name match master column name
colnames(new)<-c("New_ID","yyyymmdd","decy","time(UTC)","latN","lonW","Pressure(dbar)","Depth","Temp","CTD_SBE35T(degC)","Conductivity(S/m)","CTD_S","O2(umol/kg)","BAC(m-1)","Fluo(RFU)","PAR","Pot_Temp(degC)","sig_theta(kg/m^3)","salt","Nisken_temp (degC)","Oxy_Anom1(umol/kg)")
#add new columns
new$Program<-rep(cruiseType, nrow(new))  #change to "BATS" if merging new BATS cruises

#not sure...but I think this next bit only applies to BIOSSCOPE cruises
# new$Cruise_ID<-paste("AE",substr(new$New_ID,2,5),sep="")  #need to find cast sheet for BATS cruises and no Cruise_ID contained in BATS ID
# #add cast, niskin information
# for (i in 1:nrow(new)){
#   if (substr(new$New_ID[i],7,7)=="0"){
#     new$Cast[i]=substr(new$New_ID[i],8,8)
#   } else{
#     new$Cast[i]=substr(new$New_ID[i],7,8)
#   }
# }
# for (i in 1:nrow(new)){
#   if (substr(new$New_ID[i],9,9)=="0"){
#     new$Niskin[i]=substr(new$New_ID[i],10,10)
#   } else{
#     new$Niskin[i]=substr(new$New_ID[i],9,10)
#   }
# }
# new$ID<-paste("BS",new$Cruise_ID,".",new$Cast,".",new$Niskin,sep="") #New_ID start with 9 for BIOSSCOPE cruise and only BIOSSCOPE cruises have different ID and New_ID, all BATS cruises have same New_ID and ID

#add Nominal_Depth, depend on each cruise, this range may need to change, check cast sheets
for (j in 1:nrow(new)){
  if (new$Depth[j]<7){
    new$Nominal_Depth[j]=1
  } else if (new$Depth[j]<23 & new$Depth[j]>18){
    new$Nominal_Depth[j]=20
  } else if (new$Depth[j]<43 & new$Depth[j]>38){
    new$Nominal_Depth[j]=40
  } else if (new$Depth[j]<53 & new$Depth[j]>48){
    new$Nominal_Depth[j]=50
  } else if (new$Depth[j]<63 & new$Depth[j]>57){
    new$Nominal_Depth[j]=60
  } else if (new$Depth[j]<83 & new$Depth[j]>78){
    new$Nominal_Depth[j]=80
  } else if (new$Depth[j]<92 & new$Depth[j]>87){
    new$Nominal_Depth[j]=90
  } else if (new$Depth[j]<98 & new$Depth[j]>92){
    new$Nominal_Depth[j]=95
  } else if (new$Depth[j]<102 & new$Depth[j]>98){
    new$Nominal_Depth[j]=100
  } else if (new$Depth[j]<107 & new$Depth[j]>102){
    new$Nominal_Depth[j]=105
  } else if (new$Depth[j]<113 & new$Depth[j]>107){
    new$Nominal_Depth[j]=110
  } else if (new$Depth[j]<118 & new$Depth[j]>113){
    new$Nominal_Depth[j]=115
  } else if (new$Depth[j]<123 & new$Depth[j]>118){
    new$Nominal_Depth[j]=120
  } else if (new$Depth[j]<133 & new$Depth[j]>128){
    new$Nominal_Depth[j]=130
  } else if (new$Depth[j]<143 & new$Depth[j]>138){
    new$Nominal_Depth[j]=140
  } else if (new$Depth[j]<163 & new$Depth[j]>518){
    new$Nominal_Depth[j]=160
  } else if (new$Depth[j]<203 & new$Depth[j]>198){
    new$Nominal_Depth[j]=200
  } else if (new$Depth[j]<253 & new$Depth[j]>248){
    new$Nominal_Depth[j]=250
  } else if (new$Depth[j]<304 & new$Depth[j]>298){
    new$Nominal_Depth[j]=300
  } else if (new$Depth[j]<505 & new$Depth[j]>497){
    new$Nominal_Depth[j]=500
  } else if (new$Depth[j]<805 & new$Depth[j]>797){
    new$Nominal_Depth[j]=800
  } else if (new$Depth[j]<858 & new$Depth[j]>853){
    new$Nominal_Depth[j]=855
  } else if (new$Depth[j]<1007 & new$Depth[j]>998){
    new$Nominal_Depth[j]=1000
  } else if (new$Depth[j]<2003 & new$Depth[j]>1998){
    new$Nominal_Depth[j]=2000
  } else if (new$Depth[j]<2605 & new$Depth[j]>2598){
    new$Nominal_Depth[j]=2600
  }                                      
}

# #note some casts (AE2315 C1,C5,C8) annotate surface as 5m nominal_depths instead of 1m, check cast sheets
# new$Nominal_Depth[which(new$Cruise_ID=="AE2315"& (new$Cast==1 |new$Cast==5|new$Cast==8))]=5
# #add empty OxFix column
# new$OxFix<-rep(-999,nrow(new))


#reorder column to match master column order
new_order = c("ID","New_ID","Program","Cruise_ID","Cast","Niskin","yyyymmdd","decy","time(UTC)","latN","lonW","Depth","Nominal_Depth","Temp","CTD_SBE35T(degC)","Conductivity(S/m)","CTD_S","salt","Pressure(dbar)","sig_theta(kg/m^3)","O2(umol/kg)","OxFix","Oxy_Anom1(umol/kg)","BAC(m-1)","Fluo(RFU)","PAR","Pot_Temp(degC)","Nisken_temp (degC)")
new <- new[, new_order]

write.csv(new,"new.csv",row.names=F) #you can either use R code to add this new data into dataframe or paste outside R in excel using this saved csv file





#add more columns to match same column number as master, master has 127 columns, new has 28 columns
new[,c((ncol(new)+1):ncol(master))]<- -999
colnames(new)<-colnames(master)
#append new data
new_master<-rbind(master,new)

#if it is BATS or BATS bloom cruise, you need to reorder row order (new_master<-new_master[c(xx:xx,xx:xx,xx:xx),]) (xx use actual row number) to put it before BIOSSCOPE cruise, order: BATS (start with 1), BATS bloom (start with 2), BIOSSCOPE (start with 9) 
write.csv(new_master,"new_master.csv",row.names=F) #replace old with this new data sheet 

# #####Below check duplicate is for some old data note, ignore this section if for new data now
# #if you are merging old BATS data, there are some duplicate rows
# BATS<-read.csv("Copy of bats_bottle.csv",header=T)
# BATS_part<-BATS[BATS$decy.....>=2016.1851,]
# #common column name for merge
# colnames(BATS_part)[1]<-"ID"
# #make sure class between two data frames are same before merging
# class(BATS_part[,1])
# BATS_part[,1]<-as.character(BATS_part[,1])
# #there are duplicate rows in BATS_part which will add rows to master if left_join
# class(master[,1])
# colnames(BATS_part)
# duplicate<-BATS_part[duplicated(BATS_part[,c(1:2)]),]
# #check with master, keep the first four rows in duplicate dataframe, and fifth,sixth row in original dataframe
# BATS_part_nodup<-BATS_part[-c(49478-48803,50153-48803,50155-48803,50164-48803,50839-48803,51026-48803),]#row name is from BATS dataframe
# #########################################



# ####next step is to add discrete data once they are in
# 
# #left_join will keep the rows of master file, and add new columns from joining data frame
# #nutrient for example
# merge<-read.csv("AE2213_nut.csv", header=T)
# #make sure you include ID for merging, and matching header name with master header
# colnames(merge)<-c("ID","NO3.NO2.umol.kg.","PO4.umol.kg.")
# #calculate NO3 from N+N and NO2 if it is BATS cruise, we don't measure NO2 for BIOSSCOPE cruise
# merge$NO3.umol.kg.<-ifelse(merge$NO3.NO2.umol.kg.!=-999 & new$NO2.umol.kg.!=-999, new$NO3.NO2.umol.kg.-new$NO2.umol.kg., -999)
# merge$NO3.umol.kg.<-ifelse(merge$NO3.umol.kg.<0 & merge$NO3.umol.kg.!=-999,0,merge$NO3.umol.kg.)
# 
# #make sure ID class are the same as master, if not, change to character
# class(new_master$ID)
# class(merge$ID)
# merge$ID<-as.character(merge$ID)
# 
# new_master_merge<-left_join(new_master,merge,by="ID") #left join keep same rows as new_master rows, if there are new rows, you may want to use full_join()
# #this will create two new columns with same header as .x and .y, new data in .y and old data in .x
# #merge these two
# new_master_merge[which(new_master_merge$ID %in% merge$ID),]$NO3.NO2.umol.kg..x<-new_master_merge[which(new_master_merge$ID %in% merge$ID),]$NO3.NO2.umol.kg..y
# new_master_merge[which(new_master_merge$ID %in% merge$ID),]$PO4.umol.kg..x<-new_master_merge[which(new_master_merge$ID %in% merge$ID),]$PO4.umol.kg..y
# new_master_merge<-new_master_merge[,-c(138:139)] #delete .y columns
# colnames(new_master_merge)[c(31,37)]<-c("NO3.NO2.umol.kg.","PO4.umol.kg.") #change back column name without x or y
# 
# 
# write.csv(new_master_merge,"new_master_merge.csv",row.names=F) #replace old with this new data sheet 





