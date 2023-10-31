# data_pipeline 
Updated 21 October 2023
## tasks to-do list
Whole group:
- [ ] Bring master bottle file up to 2023
- [x] 10/22/23 Shuting updated AE2213 and 2315 cruise CTD data on bottle file
      
Ellie:
- [ ] Set up revised pipeline/steps (will go onto GitHub site)
- [ ] Get the pipeline file up on GitHub

Ruth
- [ ] come up with readme file about how the season transition dates were determined (glider, pre-set, Hydrostation S)
- [ ] will generate one m-file that will run through all CTD data from 2016 until 2023 (replacing the three scripts that exist now with different time chunks)
- [ ] put glider data and metadata into BCO-DMO format

Krista 
- [x] Add to README.md: if you want to XYZ data stream ... go the data-portal (make link to that site at GitHub)
- [ ] Consider how to move the code forward in a way that combines the work that has been done into one pipeline
- [ ] Work on Craig's code to make one cast and coordinate so end up with cruise and nominal depths (setting up to integrate with data-portal)
- [ ] update GitHub README.md again once all the pieces are ready

Rachel
- [ ]  Discuss pipeline with Rod and finalize the CTD processing.
- [ ]  Does Dom needs to reprocess BIOS-SCOPE cruises?
- [ ]  Figure out why we have two folders for BIOS-SCOPE 91916 cruise on Google Drive ('91916' and '91916_QC'). Sort out which is right and move the other folder
- [ ]  difference between wet oxygen 1, 2, 3 and salts 1, 2 in the CTD files

Shuting
- [x] Update R code and share on GitHub with group
- [x] 10/22/2023 Shuting uploaded an updated R code to automate everything and reduce manual input steps in the pipeline

Craig
- [ ] Send Krista your code to make one cast from each cruise

Done:
- [x] get on the rotation for meetings: we signed up for November 15, 2023



# Started repository 17 October 2023
The repository was started during a small group meeting for the BIOS-SCOPE project. This project conducts multiple cruises and also relies ond samples and data collected during BATS cruises. The data streams include CTD data and discrete samples. The CTD data are used to calculate derived variables. The data from the discrete samples is pulled together with the CTD data to create 'master_bottle_files' that are shared with the whole project. This GtiHub repository only discusses the CTD data and discrete data files. If you are interested in the data-portal being developed to link in the sequence data, that is available [here](https://github.com/BIOS-SCOPE/data-portal).

The remainder of this repository describes how this is done, provides details and code from different people, and ends with a to-do list for each member of this small group.

The big picture overview of this process is covered nicely in this figure:\
<img src="https://github.com/BIOS-SCOPE/data_pipeline/blob/main/BS_Data%20Pipeline_Diagram.jpg"  width="50%" height="50%">

Ellie also has a nice figure that is the more detailed steps, and a revised version of that figure should be forthcoming.

## After a cruise 
* The CTD data goes to Craig Carlson to serve as an archive; no work is done on these files.
* The BATS team processes the CTD data and posts it on Dropbox. As of fall 2023, Craig and Rachel have access to the processed data on BIOS-SCOPE.

## Ruth Curry pipeline
Ruth pulls in the CTD data and calculates a few derived variables.
### Step 1: Download CTD files from BIOS-SCOPE Google drive
First, you need to download data from BATS/Dropbox in batches. Each 'batch' is CTD data from multiple cruises, possibly over multiple years. Once a set of CTD data has been processed, you don't need to redo the MATLAB steps unless the data gets reprocessed by BATS.
 
Data are currently sitting here in the BIOS-SCOPE Google Drive:\
```./1.0 DATA/1.0 ORIG CTD FROM BATS```\
```./CTDrelease_20230626  (these begin with “1” or “2”)```\
```./BIOS-SCOPE Cruises  (these begin with “9”)```

These folders contain subfolders for each cruise. Each subfolder contains various ascii files (one per each CTD cast, plus the physf_QC and MLD.dat files). Go into the CTDrelease_20230626 and highlight the cruise folders that are new --> download them to a zip file. Do the same for BIOS-SCOPE cruises.\
Make a processing folder (e.g. FromBATS_2022-2023) and move the downloaded zip archives there. Unzip them and move the cruise folders up to the processing directory. Save the *.zip files into a subfolder ./ZIPfiles.

Copy the file ```do_concat_ctd``` from a previous processing folder into the processing folder. Right now this is done in a terminal window using csh (shell interpreter).\
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
Calls functions in mfiles folder and subfolders, so be sure they are in MATLAB path.\

Krista has updated ```create_biosscope_files_2016_2020.m ``` so that it works from beginning to end for someone who gets this repository. All that you have to do is tell the code where to find the datafiles since they are too big for GitHub. (Note: Ruth will be updating this to make one file that will process all CTD data from 2016 through 2023).

Three scripts for now (one for each batch of data from BATS)\
```create_biosscope_files_2016_2020.m ```\
```create_biosscope_files_2021.m ```\
```create_biosscope_files_2022_2023.m ```

Modify and use the script ```create_biosscope_files_*.m```\
Set filenames and path details as appropriate for the computer doing the work.\
One special note about season transition dates. This information could be from (a) glider data, or (b) from Hydrostation S data, or (c) pre-set dates. Ruth will make a readme file to detail what year relies on which option. The output from this will make this file: ```Season_dates_all.mat```

Generally the rest of the code does the following:\
•	Loads CTD files from BATS, labels them with physical framework parameters\
•	Outputs CSV and MAT files\
•	Reads Master bottle file, creates structure with added fields\
•	Loops through bottle data cruise by cruise, matches the corresponding CTD cast, computes a set derived physical properties and adds the values to the bottle cast\
•	End up with a separate output file that is called ```ADD_to_MASTER_****.csv```\
•	Cut and paste the new columns into the MASTER file.\
•	Upload the new files to the Google Drive Data folders

## Shuting's pipeline
Shuting uses the CTD data as a framework to pull in the details from the discrete samples. Here are the details on her process to update the master file:
* Shuting takes BATS CTD data and then uses Excel to add columns to the BATS data so that the columns match what is already in the BIOS-SCOPE master file. Right now, columns A to AD in the master file come from BATS
* Then Shuting does a copy/paste from one batch of BATS CTD data to get the result into the BIOS-SCOPE master file
* Discrete data comes in later, which is where the R code comes in (see below)
* Shuting uses bottle ID as the key to merge the discrete data in. Right now the problem is the R code makes a new column in the merging step, so Shuting manually merges the two columns (e.g., N_Nx or N_Ny are two columns, but these should be combined together)
* BATS has duplicate bottle IDs at times, and Shuting has corrected these issues in the existing master file

Shuting's R [here](https://github.com/BIOS-SCOPE/data_pipeline/blob/main/R_code/Join_BATS_All_with_master.R). She walked us through the steps:
* read in new CSV file and existing master file
* change newID to characters
* find duplicates
* left_join in R
* (do some tidying up)
* Copy and paste the CSV file into the master bottle file

Some additional notes about the R script. First, some details are entered manually into the master data file:
* 'program' (BATS or BIOSCOPE)
* 'cruiseID' (BATS uses 5 digit code, but ignores ship detail AE vs. EN), so this is entered manually
* nominal depth --> this is done manually either by Shuting after the BIOS-SCOPE cruises and Rachel does the BATS cruises

## Craig's path to make 'one cast' for cruise
Craig currently working in R to make one single cast for each cruise so we can pull in data from pumps etc.
For the data portal, using these synpotic casts, the idea is to use cast and nominal depth as the key for merging.
