# put discrete data into the BIOS-SCOPE master file. These data arrive in small pieces, so 
# need a script that will add data in small pieces. Use New_ID for the merging, will 
# also need to specify colnames as data arrive with all sorts of names
# original code from Shuting Liu - adapt to make its own script
# Krista Longnecker, 21 January 2024

#use this section at the top to set path names and file names

##need the existing discrete file (file is *not* on GitHub, update to your own path)
dPath <- "C:/Users/klongnecker/Documents/Dropbox/Current projects/Kuj_BIOSSCOPE/RawData/DataFiles_CTDandDiscreteSamples/"
#read in the master file - this is an Excel file
fName <- "BATS_BS_COMBINED_MASTER_2024.01.21.xlsx"

#need the file information for the new data file :
nPath <- "C:/Users/klongnecker/Documents/GitHub/data_pipeline/data_holdingZone/"
nDatafile <- "ADD_to_MASTER_temporary.csv"
fileType <- 'csv' #can also use fileType <- 'xlsx'

#need to explicitly link the column names in the bottle file with those in the incoming data file
#tempColumns is the values in the incoming discrete data file
#existingColumns is the matching labels in the existing bottle file

#will accumulate lots of these, so comment them out and add to the list as needed
# #Lomas FCM data
# existingColumns <- c("Pro(cells/ml)","Syn(cells/ml)","Piceu(cells/ml)","Naneu(cells/ml)")
# tempColumns <- c("Pro","Syn","picoeuk","nanoeuk")

#Ruth's calculated values (will be a direct match, so easy)
existingColumns <- c("Sunrise","Sunset","MLD_dens125","MLD_bvfrq","MLD_densT2","DCM","VertZone","Season" )
tempColumns <- existingColumns





########## should not need to update anything below this point
########## Krista Longnecker, 21 January 2024

library(dplyr)
#there are multiple options for reading/writing Excel files, and because of the formatting, I need two choices
library(readxl) #use this to read in the master file

#read in the existing bottle file (using values from above)
sheetName <- "BATS_BS bottle file"
#definitely want suppressWarnings here to prevent one error message for each row
discrete <- suppressWarnings(read_excel(paste0(dPath,fName),
                                        sheet = sheetName,
                                        guess_max=Inf))
discrete_updated <-as.data.frame(discrete)

#now read in the new discrete data file, could be xlsx or csv based on values from above
if (match(fileType,'csv')) {
  #use this version to read in data in a CSV format
  newDiscreteData <- read.csv(paste0(nPath,nDatafile))
  
} else if (match(fileType,'xlsx')) {
  #use this version when the data are in xlsx
  #and read in the new discrete data file (again, values are as above)
  newDiscreteData <- suppressWarnings(read_excel(paste0(nPath,nDatafile),
                                                 sheet = "Sheet1",
                                                 guess_max=Inf))
  newDiscreteData <-as.data.frame(newDiscreteData)
}








#now, match up the columns (where the match between the existing bottle file 
#new discrete data are given above)
colIdxDiscrete <- which(colnames(discrete_updated) %in% existingColumns)
colIdxNew <- which(colnames(newDiscreteData) %in% tempColumns)

#before moving on, tidy up and remove this package
detach("package:readxl",unload=TRUE)


### read in the file with openxlsx2 because that will be the easiest way to pull in the existing style
library(openxlsx2)
fs <- wb_load(file = paste0(dPath,fName))

#I can get the number of rows from discrete to set dims (seems like that would be an obvious function in openxlsx2 but I cannot find it)
setDim <- paste0("A1:EG",nrow(discrete))
stylesE <- wb_get_cell_style(wb = fs,sheet=sheetName,dims = setDim)

#will put the updated version of discrete here:
fs$add_worksheet("updatedData")

##here - go get the new discrete data (e.g., nutrients? DOC?), find the matching rows in forExport, and add in the result
##now - find the rows that match between newFCMdata and discrete
#do this as a loop because that's how my brain operates today

for (idx in 1:nrow(newDiscreteData)) { 
  one <- newDiscreteData$ID[idx]
  
  #figure out which row matches in the discrete file
  m <- match(one,discrete_updated$New_ID)
  
  #first, set the existing data to -999 (being cautious)
  discrete_updated[m,colIdxDiscrete] <- -999
  
  #now, put in the right variables
  discrete_updated[m,colIdxDiscrete] <- newDiscreteData[idx,colIdxNew]
}








#now that I have updated the discrete data, stick it back into the temporary file in the *new* sheet
fs$add_data("updatedData",discrete_updated)

##set the styles on the updatedData sheet to match the existing sytle
fs$set_cell_style(sheet = "updatedData",dims = setDim,stylesE)


#changing my mind...shuffle the names so there is only the sheet: BATS_BS bottle file


#for the moment - have a new worksheet labeled "updatedData"...could probably delete that in R
#however, I will still require someone to go look at the new file and add their name
#to the log, so might not be bad to leave it (though I can imagine someone reading in the wrong sheet)
wb_save(fs,paste0(dPath,"nextSteps_checkData_UpdateLog.xlsx"))


