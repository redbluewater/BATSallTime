%Set up to calculate Ruth's derived variables from all BATS cruises (e.g.,
%MLD, season, and VZ); starting with BATS cruise #1
%based on Ruth's prior code : create_biosscope_files_2022_2023.m
% Original code from Ruth Curry, BIOS / ASU
% Krista Longnecker; 8 February 2024
% Use this file to make a lookup table that will feed into makeSynoptic
% (which is in R right now...switching between languages)
% Krista Longnecker; 21 June 2024
%note that the LUtable I need for R is the same set of information we need
%to define the seasons, so just build on this as there will be more to do
%for the season definitions
%Krista Longnecker; 27 June 2024
clear all 
close all

%% >>>>>   % add ./BIOSSCOPE/CTD_BOTTLE/mfiles into matlab path
addpath(genpath('C:\Users\klongnecker\Documents\Dropbox\GitHub\data_pipeline\MATLAB_code\mfiles'));

%% update the folder information before getting started
rootdir = 'C:\Users\klongnecker\Documents\Dropbox\Current projects\Kuj_BIOSSCOPE\RawData\';
%Krista has put the next two folders outside the space accessible by GitHub
%These files are too large to put into GitHub
workdir = fullfile(rootdir,'RCcalcBATS\data_temporary\');
% workdir = fullfile(rootdir,'RCcalcBATS\data_copySmall_testing\');

outdir = fullfile(rootdir,'RCcalcBATS\data_holdingZone\');
gitdir = 'C:\Users\klongnecker\Documents\GitHub\data_pipeline\MATLAB_code';

%set this to one if you want to see a plot for each cast (that will clearly
%be a ton of plots, so this is best used if you to look at a preset number
%of casts within the full set of casts)
do_plots = 0;
   
NameOfFile = 'BATSdataForSeasonDefinitions.2024.06.27.mat';

%now do the calculations

%Ruth set this up for txt files, but the BATS txt files are a pain, use
%the BATS *mat files
cd(workdir)
dirlist = dir('*.mat');
%delete some names...not the best way to do this, but will work
s = contains({dirlist.name},'YR');
ks = find(s==1);
dirlist(ks) = []; clear s ks
s = contains({dirlist.name},'bats_ctd.mat');
ks = find(s==1);
dirlist(ks) = []; clear s ks
s = contains({dirlist.name},'bval_ctd.mat');
ks = find(s==1);
dirlist(ks) = []; clear s ks
s = contains({dirlist.name},'working.mat');
ks = find(s==1);
dirlist(ks) = []; clear s ks

nfiles = length(dirlist);
stepOne = table();

% doFiles = 1; %use for testing, smaller number of files
% doFiles = ; %use for testing, more files in case you need to test the loop
doFiles = nfiles; %do everything
for ii = 1:doFiles;
   fname = dirlist(ii).name;
   infile = fullfile(workdir,fname);
   
   %use modified function from KL, 2/8/2024
   CTD = calculate_BATSderivedVariables(infile,do_plots,outdir,0);
   %make a table, easier to manipulate; have to write a custom script to
   %make a table given the complexity of these structures
   trim = 1; %set this to one to only keep the values that are one per cruise/cast
   T = convert_RCstructure2table(CTD,trim); %this is a new KL function 6/21/2024
   stepOne = [stepOne;T];
   
   clear idx T
end
clear ii

%First make the look up table, I made an absurd mess, but this will work 
stepTwo = cell2mat(table2array(stepOne));
stepThree = array2table(stepTwo,'VariableNames',stepOne.Properties.VariableNames);

%Now export stepTwo as a CSV file for R
writetable(stepThree,fullfile(gitdir,'BATSderivedValues_lookupTable.2024.06.21.csv'))

%do some housecleaning before I move on to organize this in a way that I
%can use to define the seasons
clear stepOne stepTwo 
cd(gitdir)
save(NameOfFile,'stepThree','NameOfFile')



%%% now move on and get the MLD and DCM information

%Ruth uses script that sends out sunrise and sunset in GMT
%While I find no notes in the BATS files about time, my earlier code shows
%they operate in GMT, so that is good (and in case I need it, the daylight
%savings correction is in miscHousecleaning_4_fxn.m


% Go through each cruise and find the following:
% 1. Max MLD (will try different MLD parameters later)
% 2. The max DCM for all time on the cruise (uhh...did we say max? or mean?)
% 2b. The max DCM for nightime casts 

useMLD = 'MLD_densT2'; %define up top, change as needed

%first parse out the five digit cruise detail 
for a = 1:size(stepThree,1)
    one = char(string(stepThree.BATS_id(a)));
    one = one(1:5);
    stepThree.cruise(a,1) = str2double(one);
    clear one
end
clear a

%now that I have the BATS five digit cruises I can work on one cruise at a
%time (this is a case where R is easier than MATLAB); setup a table
uniqueCruises = array2table(unique(stepThree.cruise),'VariableNames',{'cruise'});
uniqueCruises.year = nan(size(uniqueCruises,1),1);
uniqueCruises.month = nan(size(uniqueCruises,1),1);
uniqueCruises.day = nan(size(uniqueCruises,1),1);
uniqueCruises.datetime = NaT(size(uniqueCruises,1),1);
uniqueCruises.nNightCasts = nan(size(uniqueCruises,1),1); %how many casts at night?
uniqueCruises.maxDCMallTime = nan(size(uniqueCruises,1),1); %will be a number, max DCM, any time
uniqueCruises.maxDCMatNight = nan(size(uniqueCruises,1),1); %what is the max DCM of the night time casts
uniqueCruises.MLDmax = nan(size(uniqueCruises,1),1); %number, value

for a = 1:size(uniqueCruises,1)
    k = find(uniqueCruises.cruise(a) == stepThree.cruise); %find one cruise
    makeSmall = stepThree(k,:); %easier to work with small dataset
    clear k
    %find the max DCM for the cruise; 
    maxDCM = max(makeSmall.DCM,[],'omitnan'); %need brackets or you get garbage (skipping dimension)
    if ~isempty(maxDCM)
        %actually have a value for DCM, some cruises have nothing here
        uniqueCruises.maxDCMallTime(a) = maxDCM;
        clear maxDCM
        
        %what about the DCM value at night (no photoquencing)
        %sunrise and sunset are given as hour of the day 
        %1055.23 , sunrise, is hhmm.## (ignore the fraction)
        %consider: should I round/floor/ceil the sunrise/sunset?
        meanSunset = char(string(mean(makeSmall.Sunset,'omitnan')));
        meanSunset = str2double(meanSunset(1:2));
        meanSunrise = char(string(mean(makeSmall.Sunrise,'omitnan')));
        meanSunrise = str2double(meanSunrise(1:2));
           
        kd = find(makeSmall.hour > meanSunset & makeSmall.hour < meanSunrise);
        if ~isempty(kd)
            %plenty of cases with no casts at night, so put in a check
            uniqueCruises.nNightCasts(a) = length(kd);
            uniqueCruises.maxDCMatNight(a) = max(makeSmall.DCM(kd),[],'omitnan');
        end
        clear kd meanSunset meanSunrise
    end %end if loop testing for an empty DCM
    
    %now get the maximum MLD for cruise; here no MLD = -999, but could have
    %four -999 values, so set that case to NaN
    m = max(makeSmall{:,useMLD});
    if m > 0
        uniqueCruises{a,'MLDmax'} = m;
    else 
        uniqueCruises{a,'MLDmax'} = NaN;
    end
    clear m
    
    %need to pull a date - just use the first date for each cruise
    uniqueCruises{a,'year'} = makeSmall.year(1);
    uniqueCruises{a,'month'} = makeSmall.month(1);
    uniqueCruises{a,'day'} = makeSmall.day(1);
    uniqueCruises{a,'datetime'} = datetime(datestr(makeSmall.mtime(1)));
    clear makeSmall   
end
clear a

save(NameOfFile)


