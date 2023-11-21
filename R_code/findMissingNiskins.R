#Some Niskins are skipped in the discrete data list
#Some of these Niskins were sampled for HR-DOM samples...so the skip is an issue
#Krista Longnecker, 21 November 2023

library(readxl)
library(dplyr)
library(stringr)
library(pracma)

#use R to read in the discrete data file and figure out how many times we have 
#casts where there are gaps in the Niskins fired. There may be cases where we did not #fire all the bottles, but there should be no cases where a Niskin was skipped
#(though given how BATS fires bottles, there truly could be)

fName <- "BATS_BS_COMBINED_MASTER_2023.11.08.xlsx"
sheetName <- 'BATS_BS bottle file'
#definitely want suppressWarnings here to prevent one error message for each row
discrete <- suppressWarnings(read_excel(fName,sheet = sheetName))

ccn <- discrete[,c('Cruise_ID','Cast','Niskin')]

#now, go through and find cases where Niskins have been skipped. I don't have 
#a good way to know if all Niskins were fired, but at the very least I can 
#find the ones that are skipped

#1. first, find unique combinations of cruise/cast
#2. second, find cases where there is non-contiguous set of Niskins

cc_unique <- unique(ccn[,1:2])

missingNiskins <- data.frame('Cruise_ID' = character(),
                          'Cast' = double(),
                          'Niskin' = double())

#now loop through the unique cruise/cast combinations
for (i in 1:dim(cc_unique)[1]){
  oneCruise <- cc_unique$Cruise_ID[i]
  oneCast <- cc_unique$Cast[i]
  
  #don't forget the comma at the end to get all columns
  tData <-ccn[ccn$Cruise_ID == oneCruise & ccn$Cast == oneCast,]
  
  #now - look to see if the Niskins are all there...have min/max, does the   
  #count add up, or does R have a diff command like in MATLAB?
  dtm <- diff(tData$Niskin) #will be all 1 if these are in order
  wd <- which(dtm >1) #is there anything skipped?
  nMissing <- max(dtm) - 1 #fencepost - take one away
 
  if(!identical(wd,integer(0))) {
    #put in a 1 if this will be an issue
    cc_unique[i,'issues'] <- 1
    
    #Have cases with multiple missing in one cast; make a full set and then
    #remove the ones where there is already a row in the discrete file
    ma = max(tData$Niskin)
    n <- seq(1,ma,1)
    df <- data.frame('Cruise_ID' = rep(oneCruise,length(n)),
                      'Cast' = rep(oneCast,length(n)),
                      'Niskin' = n)
    rm(ma,n)
    #now find the rows that already exist
    missingOne <- symdiff(df,tData)
                          
    #now append that to the running list
    missingNiskins <- rbind(missingNiskins,missingOne)
    rm(df,missingOne)
  }
  rm(oneCruise,oneCast,tData,dtm,wd,nMissing)
}

#end by exporting missingNiskins as a CSV file...I am not sure of the easiest way 
#to add these to the discrete data file
write.csv(missingNiskins,
          file = "BIOSSCOPE_missingNiskins.2023.11.21.csv",
          row.names = FALSE)

