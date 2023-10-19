# data_pipeline
Started repository 17 October 2023
Place to detail how multiple datastreams are assembled into one place

Overview of what we will be putting here is covered nicely in this figure:\
<img src="https://github.com/BIOS-SCOPE/data_pipeline/blob/main/BS_Data%20Pipeline_Diagram.jpg"  width="50%" height="50%">

# Working group 19 October 2023

## data from package on rosette
* goes to Craig (as archive, no work done on that)
* in Dropbox - and BATS team processes the data and posts it on Dropbox. Right now Craig and Rachel have access to the processed data on BIOS-SCOPE

## Ruth pipeline
(these files will be in the MATLAB folder)
### Step 1: Download CTD files from BIOS-SCOPE Google drive
(Have to include the m-files from Ruth in the path, multiple custom functions, the seawater library, and a sunrise library)

First, you need to download data from BATS/Dropbox in batches. Usually each 'batch' is CTD data from multiple cruises, possibly over multiple years. Once a set of CTD data has been processed, you don't need to redo the MATLAB steps unless the data gets reprocessed by BATS.
 
Data are currently sitting here in the BIOS-SCOPE Google Drive:\
```./1.0 DATA/1.0 ORIG CTD FROM BATS```\
```./CTDrelease_20230626  (these begin with “1” or “2”)```\
```./BIOS-SCOPE Cruises  (these begin with “9”)```

These folders contain subfolders for each cruise. Each subfolder contains various ascii files (one per each CTD cast, plus the physf_QC and MLD.dat files). Go into the CTDrelease_20230626 and highlight the cruise folders that are new --> download them to a zip file. Do the same for BIOS-SCOPE cruises.\
Make a processing folder (e.g. FromBATS_2022-2023) and move the downloaded zip archives there. Unzip them and move the cruise folders up to the processing directory. Save the *.zip files into a subfolder ./ZIPfiles.

Copy the file ```do_concat_ctd``` from a previous processing folder into the processing folder.

```set curdir = `pwd` ```\
```set dirlist = (10367 10368 10369 10370 10371 10373 10374 10376 10376 10377 10378 10379 10381 10382 10383 10384 10385 10386 10387 10388 10389 20379 20380 92114 92123)```\
```for each dir ($dirlist)```\
```cd $dir```\
```echo $dir```\
```set list = `ls *c*_QC.dat` ```\
```cat $list > ../${dir}_ctd.txt```\
```cd $curdir```\
```end```

Edit dirlist to reflect the list of cruises. 
    ```set list = `ls -d 1* 9*` ```
Run the commands in a terminal window using a csh (shell interpreter).  
This will create a single text file for each cruise containing the concatenated casts; naming convention is $cruise_ctd.txt

### Step 2: Create BIOSSCOPE CTD and MasterBtl files
Calls functions in mfiles folder and subfolders, so be sure they are in MATLAB Path.\
Three scripts for now (one for each batch of data from BATS)\
```create_biosscope_files_2016_2020.m ```\
```create_biosscope_files_2021.m ```\
```create_biosscope_files_2022_2023.m ```

Modify and use the script ```create_biosscope_files_*.m```\
Filenames and local paths (add details here)\
Season transition dates (seasons - using glider data to determine seasons and/or set dates and/or use information from Hydrostation S) --> makes Season_dates_all.mat)

•	Loads CTD files from BATS, labels them with physical framework parameters\
•	Outputs CSV and MAT files\
•	Reads Master bottle file, creates structure with added fields 
•	Loops through bottle data cruise by cruise, matches the corresponding CTD cast, computes a set derived physical properties and adds the values to the bottle cast
       In a separate output file (ADD_to_MASTER_****.csv)\

Cut and paste the new columns into the MASTER file.\
Upload the new files to the Google Drive Data folders.

## Shuting pipeline
(these files will be in the R folder)


# tasks to-do list
* add to top of m-files from Ruth : Ruth Curry, BIOS, dates, keep track of who wrote the scripts and where they came from
* pull details from Ruth's Word documents and put into GitHub so they are here in GitHub\
** HowTo_Download CTD.docx\
** How to create BIOSSCOPE CTD and MasterBtl files
* Update pipeline to inclue timeline
* Get revised pipeline/steps from Ellie
* Gather Ruth's scripts into a single notebook for GitHub
* Setup flag to note how the season is defined (glider, pre-set, Hydrostation S)


