# put discrete data into the BIOS-SCOPE master file. These data arrive in small pieces, so 
# need a script that will add data in small pieces. Use New_ID for the merging, will 
# also need to specify colnames as data arrive with all sorts of names
# original code from Shuting Liu - adapt to make its own script
# Note that this version will also automate the averaging across duplicate 
# samples (e.g., two injections on the Shimadzu)
# Krista Longnecker, 24 January 2024
# Krista Longnecker, 26 January 2024 change sheet name to 'DATA' (was 'BATS_BS bottle file')
#
#Some notes from Krista: 
# (1) you will need to update the path information and file names up through row ~50 in this code. 
# There should be no need to change anything past that point.
# (2) This script will open a single worksheet in Excel - that worksheet needs to copied into the bottle
# file, and then header gets copied from the prior version of the bottle file. I cannot use the 
# that would (in theory) allow the formatting to be copied because it creates a corrupted Excel file

##need the existing discrete file (file is *not* on GitHub, update to your own path)
# if you are on a Mac, your path will be something like this --> /users/klongnecker
# if you are on a PC, your path will be something like this --> c:/users/klongnecker
dPath <- "C:/Users/klongnecker/Documents/Dropbox/Current projects/Kuj_BIOSSCOPE/RawData/DataFiles_CTDandDiscreteSamples/"
#read in the master file - this is an Excel file
fName <- "BATS_BS_COMBINED_MASTER_2024.01.21.xlsx"

#need the file information for the new data file. Note, you must have a variable "New_ID"
nPath <- "C:/Users/klongnecker/Documents/Dropbox/GitHub/data_pipeline/data_holdingZone/"
nDatafile <- "sampleDataFile_useAsExampleForYourData.xlsx"
nSheetName <- "data"
fileType <- 'xlsx' #one of two choices: 'csv' or 'xlsx'

#need to explicitly link the column names in the bottle file with those in the incoming data file
#tempColumns is the values in the incoming discrete data file
#existingColumns is the matching labels in the existing bottle file

#will accumulate lots of these, so comment them out and add to the list as needed
#Shimadzu data from Ellie 1/24/2024
existingColumns <- c("DOC (umol/kg)")
tempColumns <- c("DOC [UMOL/KG]")

# #Lomas FCM data
# existingColumns <- c("Pro(cells/ml)","Syn(cells/ml)","Piceu(cells/ml)","Naneu(cells/ml)")
# tempColumns <- c("Pro","Syn","picoeuk","nanoeuk")

# #Ruth's calculated values (will be a direct match, so easy)
# existingColumns <- c("Sunrise","Sunset","MLD_dens125","MLD_bvfrq","MLD_densT2","DCM","VertZone","Season" )
# tempColumns <- existingColumns






########## should not need to update anything below this point
########## Krista Longnecker, 21 January 2024

library(dplyr)
#there are multiple options for reading/writing Excel files, and because of the formatting, I need two choices
library(readxl) #use this to read in the master file

#read in the existing bottle file (using values from above)
sheetName <- "DATA" #(was "BATS_BS bottle file")
#definitely want suppressWarnings here to prevent one error message for each row
discrete <- suppressWarnings(read_excel(paste0(dPath,fName),
                                        sheet = sheetName,
                                        guess_max=Inf))
discrete_updated <-as.data.frame(discrete)

#now read in the new discrete data file, could be xlsx or csv based on values from above
if (!is.na(match(fileType,'csv'))) {
  #use this version to read in data in a CSV format
  newDiscreteData <- read.csv(paste0(nPath,nDatafile))
  
} else if (!is.na(match(fileType,'xlsx'))) {
  #use this version when the data are in xlsx
  #and read in the new discrete data file (again, values are as above)
  newDiscreteData <- suppressWarnings(read_excel(paste0(nPath,nDatafile),
                                                 sheet = nSheetName,
                                                 guess_max=Inf))
  newDiscreteData <-as.data.frame(newDiscreteData)
}

#next: make sure I don't have duplicate samples (rows), and if I do
#send up a warning, ask if that is expected, and move on to do averaging
#if the answer is yes
uv <- length(unique(newDiscreteData$New_ID))
av <- length(newDiscreteData$New_ID)

if (uv != av) {
  warning('Careful, some samples are repeated in here.\n')
  x <- readline("Is this expected (type 'yes' or 'no')\n")
  
  if (x=='yes') {
    warning('OK, move on')
    
    #group_by by New_ID, can put in multiple columns at once (using tempColumns
    #which is defined above), and then take mean, drop the NA 
    ### (or whatever comes in with Carlson lab data)
    
    newDiscreteData <- newDiscreteData %>% 
      group_by(New_ID) %>% 
      summarise(across(tempColumns, ~ mean(.x,na.rm=TRUE)))

  } else if (x=='no') {
    stop('Then you have a problem...go check out the data')
  }
}

#now, match up the columns (where the match between the existing bottle file
#new discrete data are given above)
colIdxDiscrete <- which(colnames(discrete_updated) %in% existingColumns)
colIdxNew <- which(colnames(newDiscreteData) %in% tempColumns)

#before moving on, tidy up and remove this package
detach("package:readxl",unload=TRUE)


### read in the file with openxlsx2 because that will be the easiest way to pull in the existing style
library(openxlsx2)

# If I assemble my own workbook, I can save the file that results from Excel
# But will only be one sheet with new data...can paste that into new bottle file
wb <- wb_workbook()

#will put the updated version of discrete here:
wb$add_worksheet("updatedData")

##now - find the rows that match between newDiscreteData and discrete
#do this as a loop because that's how my brain operates today

for (idx in 1:nrow(newDiscreteData)) {
  one <- newDiscreteData$New_ID[idx]

  #figure out which row matches in the discrete file
  m <- match(one,discrete_updated$New_ID)

  #first, set the existing data to -999 (being cautious)
  discrete_updated[m,colIdxDiscrete] <- -999

  #now, put in the right variables
  discrete_updated[m,colIdxDiscrete] <- newDiscreteData[idx,colIdxNew]
}

#now that I have updated the discrete data, stick it back into the workbook
wb$add_data("updatedData",discrete_updated)

#this next line will open up the file in Excel. Sadly you will still have to copy
#and paste into a new sheet, but at least you can copy the whole sheet
xl_open(wb)
