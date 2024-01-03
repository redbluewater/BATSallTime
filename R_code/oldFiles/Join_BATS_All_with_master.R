#Code from Shuting Liu
#University of California, Santa Barbara and Kean University
#uploaded to BIOS-SCOPE GitHub site 20 October 2023

library(dplyr)
setwd("~/Desktop")
master<-read.csv("Copy of BATS_BS_COMBINED_MASTER_2022.3.30.csv",header=T)
BATS<-read.csv("Copy of BATS_All.csv",header=T)
BATS_part<-BATS[BATS$decy.....>=2016.1851,]
#common column name for merge
colnames(BATS_part)[1]<-"ID"
#make sure class between two data frames are same before merging
class(BATS_part[,1])
BATS_part[,1]<-as.character(BATS_part[,1])
#there are duplicate rows in BATS_part which will add rows to master if left_join

class(master[,1])
colnames(BATS_part)
duplicate<-BATS_part[duplicated(BATS_part[,c(1:2)]),]

#check with master, keep the first four rows in duplicate dataframe, and fifth,sixth row in original dataframe
BATS_part_nodup<-BATS_part[-c(49478-48803,50153-48803,50155-48803,50164-48803,50839-48803,51026-48803),]#row name is from BATS dataframe

#left_join will keep the rows of master file, and add new columns from joining data frame
new<-left_join(master,BATS_part_nodup[,c(1,15:34)],by="ID")

#add cast, niskin information
for (i in 1:nrow(new)){
  if (substr(new$ID[i],7,7)=="0"){
    new$Cast[i]=substr(new$ID[i],8,8)
  } else{
    new$Cast[i]=substr(new$ID[i],7,8)
  }
}
for (i in 1:nrow(new)){
  if (substr(new$ID[i],9,9)=="0"){
    new$Niskin[i]=substr(new$ID[i],10,10)
  } else{
    new$Niskin[i]=substr(new$ID[i],9,10)
  }
}

write.csv(new,"new.csv",row.names=F,na="-999")

