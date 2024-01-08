# put discrete data into the BIOS-SCOPE master file. These data will arrive in small pieces, so 
# need a script that will iteratively add data. 
# original code from Shuting Liu - adapt to make its own script
# Krista Longnecker, 8 January 2024
library(dplyr)

#there are multiple options for reading/writing Excel files, and because of the formatting, I need two choices
library(readxl) #use this to read in the master file

##first, read in the existing discrete file (file is *not* on GitHub, update to your own path)
dPath <- "C:/Users/klongnecker/Documents/Dropbox/Current projects/Kuj_BIOSSCOPE/RawData/DataFiles_CTDandDiscreteSamples/"
#read in the master file - which is currently an Excel file
fName <- "BATS_BS_COMBINED_MASTER_2024.01.04.KLtestingxlsx.xlsx"
sheetName <- "BATS_BS bottle file"
#definitely want suppressWarnings here to prevent one error message for each row
discrete <- suppressWarnings(read_excel(paste0(dPath,fName),sheet = sheetName))
discrete_updated <-as.data.frame(discrete)

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







#now that I have updated the discrete data, stick it back into the temporary file in the *new* sheet
fs$add_data("updatedData",discrete_updated)

##set the styles on the updatedData sheet to match the existing sytle
fs$set_cell_style(sheet = "updatedData",dims = setDim,stylesE)


#for the moment - have a new worksheet labeled "updatedData"...could probably delete that in R
#however, I will still require someone to go look at the new file and add their name
#to the log, so might not be bad to leave it (though I can imagine someone reading in the wrong sheet)
wb_save(fs,paste0(dPath,"nextSteps_checkData_UpdateLog.xlsx"))


