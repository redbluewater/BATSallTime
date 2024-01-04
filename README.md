# data_pipeline 
Updated 4 January 2024
## tasks to-do list
Whole group:
- [x] Bring master bottle file up to 2023 (BIOS-SCOPE and BATS cruises now done through summer 2023)
      
Ellie:
- [ ] Set up revised pipeline/steps (will go onto GitHub site)
- [ ] Get the pipeline file up on GitHub

Ruth
- [x] come up with readme file about how the season transition dates were determined (glider, pre-set, Hydrostation S)
- [x] will generate one m-file that will run through all CTD data from 2016 until 2023 (replacing the three scripts that exist now with different time chunks)
- [x] share new m-file for GitHub
- [ ] put glider data and metadata into BCO-DMO format

Krista 
- [x] Add to README.md: if you want to XYZ data stream ... go the data-portal (make link to that site at GitHub)
- [x] update GitHub README.md again once all the pieces are ready
- [ ] Work on Craig's code to make one cast and coordinate so end up with cruise and nominal depths (setting up to integrate with data-portal)
- [ ] organize brainstorming session for February BIOS-SCOPE meeting

Rachel
- [ ]  Discuss pipeline with Rod and finalize the CTD processing.
- [ ]  Does Dom needs to reprocess BIOS-SCOPE cruises?
- [ ]  Figure out why we have two folders for BIOS-SCOPE 91916 cruise on Google Drive ('91916' and '91916_QC'). Sort out which is right and move the other folder
- [ ]  difference between wet oxygen 1, 2, 3 and salts 1, 2 in the CTD files

Shuting (all done!)

Craig
- [ ] Send Krista your code to make one cast from each cruise

# Updated README 4 January 2024
The repository was started during a small group meeting for the BIOS-SCOPE project. This project conducts multiple cruises and also relies ond samples and data collected during BATS cruises. The data streams include CTD data and discrete samples. The CTD data are used to calculate derived variables. The data from the discrete samples is pulled together with the CTD data to create 'master_bottle_files' that are shared with the whole project. This GtiHub repository only discusses the CTD data and discrete data files. If you are interested in the data-portal being developed to link in the sequence data, that is available [here](https://github.com/BIOS-SCOPE/data-portal).

The remainder of this repository describes how this is done, provides details and code from different people, and ends with a to-do list for each member of this small group.

The big picture overview of this process is covered nicely in this figure:\
<img src="https://github.com/BIOS-SCOPE/data_pipeline/blob/main/BS_Data%20Pipeline_Diagram.jpg"  width="50%" height="50%">

Ellie also has a nice figure that is the more detailed steps, and a revised version of that figure should be forthcoming.

## After a cruise 
* The CTD data goes to Craig Carlson to serve as an archive; no work is done on these files.
* The BATS team processes the CTD data and posts it on Dropbox. As of fall 2023, Craig and Rachel have access to the processed data on BIOS-SCOPE.

### Step 1: Download CTD files from BIOS-SCOPE Google drive
First, you need to download data from BATS/Dropbox in batches. Each 'batch' is CTD data from multiple cruises, possibly over multiple years. 
 
Data are currently sitting here in the BIOS-SCOPE Google Drive:\
```./1.0 DATA/1.0 ORIG CTD FROM BATS```\
```./CTDrelease_20230626  (these begin with “1” or “2”)```\
```./BIOS-SCOPE Cruises  (these begin with “9”)```

These folders contain subfolders for each cruise. Each subfolder contains various ascii files (one per each CTD cast, plus the physf_QC and MLD.dat files). Go into the CTDrelease_20230626 and highlight the cruise folders that are new --> download them to a zip file.\
Make a processing folder (e.g. BIOSSCOPE_working) and move the downloaded zip archives there. Unzip the files. 

## Shuting's pipeline (in R)
Latest: Krista modified Shuting's code to go through a series of folders to find new BATS CTD data (code will need to be slightly modified the next time there is a new BIOS-SCOPE cruise). The updated R files is [here](https://github.com/BIOS-SCOPE/data_pipeline/blob/main/R_code/Join_BATS_All_with_master_updated_Krista.R). 

The code now does the following (after data files have been downloaded from Google Drive as described above:\
* read in the current master file ("BATS_BS_COMBINED_MASTER_2023.11.28.csv") and then use that to set the headers for the data incoming data
* get the headers that are used on the BATS CTD data files
* get "BIOS-SCOPE Time-series Master Log_2023.10.15.xlsx" which enable a BATS cruise number to be converted to a cruise ID (e.g., BATS10321 --> AE1602)
* Go through one cruise at a time and
    * read in the "*BIOSSCOPE_physf*" file
    * delete the columns we do not want and rename columns as needed
    * get the cast and Niskin information from the New_ID
    * add in the nominal depths
    * resize everything so it can be pasted into the existing bottle file
* Repeat for all cruises and export the result as a CSV file
* Copy/paste to put the new cruise/cast/Niskin into the BIOS-SCOPE master file

Some notes on steps that will be needed to use this code for a BIOS-SCOPE cruise:
* change cruiseType to 'BIOSSCOPE' (line 42)

## Ruth Curry pipeline (in MATLAB)
Once Shuting's code has been used to add the necessary samples to the master bottle file, then you can run Ruth's code to calculate the derived variables. Ruth pulls in the CTD data and calculates a few derived variables.

Use the script ```do_concat_ctd.m``` (which is in ```data_pipeline\MATLAB_code\mfiles\``` to create a single text file for each cruise containing the concatenated casts; naming convention is $cruise_ctd.txt

Calls functions in mfiles folder and subfolders, so be sure they are in MATLAB path.\

Krista has updated ```create_biosscope_files_2022_2023_Krista.m ``` to pick up where the previous processing script ended. This file will start with 10390 (March 2022) and then go to 10404 (May 2023). The path information is set for Krista's desktop. 

One special note about season transition dates. This information could be from (a) glider data, or (b) from Hydrostation S data, or (c) pre-set dates. Ruth will make a readme file to detail what year relies on which option. The output from this will make this file: ```Season_dates_all.mat```

Generally the rest of the code does the following:\
•	Loads CTD files from BATS, labels them with physical framework parameters\
•	Outputs CSV and MAT files\
•	Reads Master bottle file, creates structure with added fields\
•	Loops through bottle data cruise by cruise, matches the corresponding CTD cast, computes a set derived physical properties and adds the values to the bottle cast\
•	End up with a separate output file that is called ```ADD_to_MASTER_****.csv```\
•	Cut and paste the new columns into the MASTER file.\
•	Upload the new files to the Google Drive Data folders

Once a set of CTD data has been processed, you don't need to redo the MATLAB steps unless the data gets reprocessed by BATS.

## Back to Shuting's R code: merging in the discrete dataset as they become available
(section not yet updated, but copy and pasted from earlier version of the readme file on 1/4/2024)\
* Discrete data comes in later, which is where the R code comes in (see below)
* Shuting uses bottle ID as the key to merge the discrete data in. Right now the problem is the R code makes a new column in the merging step, so Shuting manually merges the two columns (e.g., N_Nx or N_Ny are two columns, but these should be combined together)
* BATS has duplicate bottle IDs at times, and Shuting has corrected these issues in the existing master file


## Craig's path to make 'one cast' for cruise
Craig currently working in R to make one single cast for each cruise so we can pull in data from pumps etc.
For the data portal, using these synpotic casts, the idea is to use cast and nominal depth as the key for merging.
