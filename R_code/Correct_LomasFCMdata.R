# use this script to correct the error in the Lomas/FCM data, mostly based on
#Join_discreteData.R
# note this will make a temporary file with a new sheet called 'UpdatedData' - this
# was done to encourage people to double-check that everything ended up in the right place
# Krista Longnecker, 17 January 2024
library(dplyr)

#there are multiple options for reading/writing Excel files, and because of the formatting, I need two choices
library(readxl) #use this to read in the master file

##first, read in the existing discrete file (file is *not* on GitHub, update to your own path)
dPath <- "C:/Users/klongnecker/Documents/Dropbox/Current projects/Kuj_BIOSSCOPE/RawData/DataFiles_CTDandDiscreteSamples/"
#read in the master file - which is currently an Excel file
fName <- "BATS_BS_COMBINED_MASTER_2024.01.04.xlsx"
sheetName <- "BATS_BS bottle file"
#definitely want suppressWarnings here to prevent one error message for each row
#have to set guess_max to Inf so that it does not try and guess based on 
#first rows (and then fail when it gets to the BIOS-SCOPE cruises)
discrete <- suppressWarnings(read_excel(paste0(dPath,fName),
                                        sheet = sheetName,
                                        guess_max=Inf))

discrete_updated <-as.data.frame(discrete)

#read in the new data from Lomas, file is available here
nPath <- "C:/Users/klongnecker/Documents/Dropbox/__wasDROPBOX_nowCurrent/ZZ_BIOSSCOPE_dataProcessingCode/"
nDatafile <- "10334_20346fcm_phys_final_annotatedKL.2024.01.16.xlsx"
newFCMdata <- suppressWarnings(read_excel(paste0(nPath,nDatafile),
                                          sheet = "Sheet1",
                                          guess_max=Inf))
newFCMdata <-as.data.frame(newFCMdata)

#need to explicitely link colnames as people are using various options, which 
#or may not match what is in the bottle file
tempColumns <- c("Pro","Syn","picoeuk","nanoeuk")
existingColumns <- c("Pro(cells/ml)","Syn(cells/ml)","Piceu(cells/ml)","Naneu(cells/ml)")

colIdxDiscrete <- which(colnames(discrete_updated) %in% existingColumns)
colIdxLomas <- which(colnames(newFCMdata) %in% tempColumns)
  

#before moving on, tidy up and remove this package
detach("package:readxl",unload=TRUE)

### now read in the file with openxlsx2 because that will be the easiest way to pull in the existing style
#but it is much harder to manipulate the files with openxlsx2
library(openxlsx2)
fs <- wb_load(file = paste0(dPath,fName))

#I can get the number of rows from discrete to set dims (seems like that would be an obvious function in openxlsx2 but I cannot find it)
setDim <- paste0("A1:EG",nrow(discrete))
stylesE <- wb_get_cell_style(wb = fs,sheet=sheetName,dims = setDim)

#will put the updated version of discrete here:
fs$add_worksheet("updatedData")


##now - find the rows that match between newFCMdata and discrete
#do this as a loop because that's how my brain operates today

for (idx in 1:nrow(newFCMdata)) { 
  one <- newFCMdata$ID[idx]
  
  #figure out which row matches in the discrete file
  m <- match(one,discrete_updated$New_ID)
  
  #first, set the existing data to -999 (being cautious)
  discrete_updated[m,colIdxDiscrete] <- -999
  
  #now, put in the right variables
  discrete_updated[m,colIdxDiscrete] <- newFCMdata[idx,colIdxLomas]
}


#now that I have updated the discrete data, stick it back into the temporary file in the *new* sheet
fs$add_data("updatedData",discrete_updated)

##set the styles on the updatedData sheet to match the existing sytle
fs$set_cell_style(sheet = "updatedData",dims = setDim,stylesE)


#for the moment - have a new worksheet labeled "updatedData".
#however, I will still require someone to go look at the new file and add their name
#to the log, so I think it's wise to leave it this way and require that one 
#manual update to change the name of the new sheet
wb_save(fs,paste0(dPath,"nextSteps_checkData_UpdateLog.xlsx"))


