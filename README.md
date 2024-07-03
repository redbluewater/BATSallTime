# BATSallTime
updated 3 July 2024; Krista Longecker

I cloned the BIOS-SCOPE/data_pipeline repository as I have made so many changes that it was going to be messy for the original intended use of the data_pipeline. Working in redbluewater account for now, but will also tidy up the BIOS-SCOPE data_pipeline to go back to where I was in Ruth's MATLAB code. 

# Some details
Wrote ```calcDerivedVariables_BATSallTime_v4.m``` to run through all the BATS cruises and pull the set of variables needed here. Then I use ```calculateSeason_KL.m``` to go ahead and take a first pass at the boundaries for each season. This is definitely *not* perfect, so I export the results to a CSV file that gets edited manually by looking at each cruise/year result. The edited Excel file is ```seasons_wKLedits.2024.07.03.xlsx```. With that file in hand, go back to the MATLAB files to use those bounds for season rather than some automated option.

## Some git notes for Krista
Edit file(s) on my local computer, then to get the files back to GitHub, use this set of commands to put onto GitHub:

```git add -A``` *or* ```git add MATLAB_code/\ *``` (or whatever folder you want)\
```git commit -am "Brief description goes here"``` (can use the bit in quotes to describe the update)\
```git push```\
(enter the passcode I use to get files to GitHub)
