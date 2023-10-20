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

Krista has updated ```create_biosscope_files_2016_2020.m ``` so that it works from beginning to end for someone who gets this repository. All that you have to do is tell the code where to find the datafiles since they are too big for GitHub.

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
Shuting's steps:
* Shuting takes BATS CTD data and then uses Excel to add columns to the BATS data so that the columns match what is already in the BIOS-SCOPE master file
**  Right now, columns A to AD in the master file come from BATS
* Then Shuting copy/paste from the batch of BATS CTD data file into the BIOS-SCOPE master file
* Discrete data comes in later, and that is where the R code comes in
* **Shuting was using the bottle ID as the key to merge the discrete data in. Right now the problem is the R code makes a new column in the merging step, so Shuting manually merges the two columns (e.g., N_Nx or N_Ny)
* BATS has duplicate bottle IDs at times, and Shuting has corrected these issues in the existing master file
* 

Shuting's R code...she walked us through this:
* read in new CSV file and existing master file
* change newID to characters
* find duplicates
* left_join in R
* (do some tidying up)
* Copy and paste the CSV file into the master bottle file

* Some notes: some details are entered manually into the master data file:
* **'program' into the Excel file
* ** AE cruise ID (e.g., BATS uses 5 digit code, but ignores ship detail AE vs. EN), so this entered manually
* **nominal depth ...this is done manually either by Shuting after the BIOS-SCOPE cruises and Rachel does the BATS cruises


## Craig's path to make 'one cast' for cruise
Craig currently working in R to make one single cast for each cruise so we can pull in data from pumps etc.
(need Craig's R code to see how he is making one cast)
For the data portal, using these synpotic casts, the idea is to use cast and nominal depth as the key for merging.



# tasks to-do list
* Ellie: Set up revised pipeline/steps (will go onto GitHub site)
* 
* Ruth: come up with readme file about how the season transition dates were determined (glider, pre-set, Hydrostation S)
* Ruth: will generate one m-file that will run through all CTD data from 2016 until 2023 (replacing the three scripts that exist now with different time chunks)
* Ruth: put glider data and metadata into BCO-DMO format
*

* Some things entered manually into the master data file:
* **'program' into the Excel file
* **missing AE cruise ID (e.g., BATS uses 5 digit code, but ignores ship detail AE vs. EN)
* **nominal depth ...this is done manually either (Shuting does this after the cruises...but Rachel does some)

* get on the rotation for meetings...in the maybe time slot...set up use cases for how the data portal would be used

* Krista : update GitHub README.md
* *If you want to XYZ data stream ... go the data-portal (make link to that site at GitHub)
* How to move the code forward
* Discuss pipeline with Rod and finalize the CTD processing.
Does Dom needs to reprocess BIOS-SCOPE cruises?
![image](https://github.com/BIOS-SCOPE/data_pipeline/assets/143524821/2990a19a-3772-4909-b839-5a43d60f2835)


