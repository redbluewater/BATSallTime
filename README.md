# data_pipeline
Started repository 17 October 2023
Place to detail how multiple datastreams are assembled into one place

Overview of what we will be putting here is covered nicely in this figure:\
<img src="https://github.com/BIOS-SCOPE/data_pipeline/blob/main/BS_Data%20Pipeline_Diagram.jpg"  width="50%" height="50%">

# Working group 19 October 2023

## data from package on rosette
* goes to Craig (as archive, no work done on that)
* in Dropbox - and BATS team processes the data and posts it on Dropbox. Right now Craig and Rachel have access to the processed data on BIOS-SCOPE
* 
## Ruth pipeline
### first, get the data from Dropbox and do stuff, one cast/cruise at a time
see Word document for details: HowTo_Download CTD.docx
(includes details on concatenate the CTD data --> 
 Download data from BATS/Dropbox in batches, once a batch is done, don't need to redo it
in FromBATS_2016-2020 folder and run do_concat_ctd (now in C Shell)
Makes a single *txt file for each cruise

### Create BIOSSCOPE CTD and MasterBtl files
(see Word document for details) (for one set..will call create_BIOSCOPE_ctd_files.m)\
Three scripts for now (one for each batch of data from BATS) 
create_biosscope_files_2016_2020.m 
create_biosscope_files_2021.m 
create_biosscope_files_2022_2023.m 

#### First: process the single cast/cruise
Right now: series of functions and scripts from Ruth; have to include the m-files from Ruth in the path, multiple custom functions, the seawater library, and a sunrise library)
(will create a series of files...then create CSV files that get uploaded to Google Drive)

#### Then need to combine the information into one file
(seasons - using glider data to determine seasons and/or set dates and/or use information from Hydrostation S) --> makes Season_dates_all.mat
(make a CSV file that is 'add to master')

#### Then cut and paste from CSV file into the on-going master file (which is in Excel, xlsx file)


## Shuting pipeline


# tasks to-do list
* add to top of m-files from Ruth : Ruth Curry, BIOS, dates, keep track of who wrote the scripts and where they came from
* pull details from Ruth's Word documents and put into GitHub so they are here in GitHub\
** HowTo_Download CTD.docx\
** How to create BIOSSCOPE CTD and MasterBtl files
* Update pipeline to inclue timeline
* Get revised pipeline/steps from Ellie
* Gather Ruth's scripts into a single notebook for GitHub
* Setup Ruth scripts so they allow a person to point to a local data directory (will allow scripts to be updated on GitHub, but then leave data locally)
* Setup flag to note how the season is defined (glider, pre-set, Hydrostation S)


