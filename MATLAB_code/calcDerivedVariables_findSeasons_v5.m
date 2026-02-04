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
%Krista Longnecker; 2 February 2026 %different format of data being made
%available...adjust accordingly
clear all 
close all

%%add options depending on computer, KL is jumping between computers
if isequal(getenv('COMPUTERNAME'),'ESPRESSO')
    %% add ./BIOSSCOPE/CTD_BOTTLE/mfiles into matlab path
    addpath(genpath('C:\Users\klongnecker\Documents\GitHub\BATSallTime\MATLAB_code\mfiles'));    
    
    %% update the folder information before getting started
    rootdir = 'C:\Users\klongnecker\Documents\Dropbox\Current projects\Kuj_BIOSSCOPE\RawData\';
    %Krista has put the next two folders outside the space accessible by GitHub
    %These files are too large to put into GitHub
    workdir = fullfile(rootdir,'RCcalcBATS\data_temporary\');
    % workdir = fullfile(rootdir,'RCcalcBATS\data_copySmall_testing\');
    outdir = fullfile(rootdir,'RCcalcBATS\data_holdingZone\');
elseif isequal(getenv('COMPUTERNAME'),'DESKTOP-QB9J1SQ')
    %% add ./BIOSSCOPE/CTD_BOTTLE/mfiles into matlab path    
    addpath(genpath('mfiles')); %use generic, will be easy to find from this script

    %% update the folder information before getting started
    rootdir = 'D:\Dropbox\GitHub_niskin\BATSallTime\RawData\';
    %Krista has put the next two folders outside the space accessible by GitHub
    %These files are too large to put into GitHub
    workdir = fullfile(rootdir,'CTDrelease_20250314\');
    outdir = fullfile(rootdir,'processedCTDfiles\');
end

gitdir = pwd;
%set this to one if you want to see a plot for each cast (that will clearly
%be a ton of plots, so this is best used if you to look at a preset number
%of casts within the full set of casts)
do_plots = 0;
   
NameOfFile = 'BATSdataForSeasonDefinitions.2026.02.02.mat';

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
   CTD = calculate_BATSderivedVariables_pullDetailsForSeasons(infile,do_plots,outdir,0);
   %make a table, easier to manipulate; have to write a custom script to
   %make a table given the complexity of these structures
   trim = 1; %set this to one to only keep the values that are one per cruise/cast
   T = convert_RCstructure2table(CTD,trim); %this is a new KL function 6/21/2024
   stepOne = [stepOne;T];
   
   clear idx T trim CTD infile fname
end
clear ii nfiles doFiles dirlist do_plots

%First make the look up table, I made an absurd mess, but this will work 
stepTwo = cell2mat(table2array(stepOne));
stepThree = array2table(stepTwo,'VariableNames',stepOne.Properties.VariableNames);

%Now export stepTwo as a CSV file for R
writetable(stepThree,fullfile(gitdir,'BATSderivedValues_lookupTable.2026.02.02.csv'))

%do some housecleaning before I move on to organize this in a way that I
%can use to define the seasons
clear stepOne stepTwo 
cd(gitdir)
clear gitdir outdir rootdir workdir
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
% 3. Is the DCM in the mixed layer, new variable 1 (yes); 2 (no); NaN (no
% DCM information so we cannot say)

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
%% This table is getting out of hand...KL needs to correct this
unCru = array2table(unique(stepThree.cruise),'VariableNames',{'cruise'});
unCru.year = nan(size(unCru,1),1);
unCru.month = nan(size(unCru,1),1);
unCru.day = nan(size(unCru,1),1);
unCru.datetime = NaT(size(unCru,1),1);
unCru.maxDCM = nan(size(unCru,1),1); %will be a number, max DCM, any time
unCru.maxDCM_depthTop = nan(size(unCru,1),1);
unCru.maxDCM_depthBot = nan(size(unCru,1),1);
unCru.DCMinML = nan(size(unCru,1),1); %new 7/2/2024, is the DCM in the ML?
unCru.MLDmax = nan(size(unCru,1),1); %number, value
unCru.season = nan(size(unCru,1),1); %number, value


for a = 1:size(unCru,1)
    k = find(unCru.cruise(a) == stepThree.cruise); %find one cruise
    makeSmall = stepThree(k,:); %easier to work with small dataset
    clear k
    %find the max DCM for the cruise; 
    [maxDCM id] = max(makeSmall.DCM,[],'omitnan'); %need brackets or you get garbage (skipping dimension)
    %have three cruises with issues (10155, 50056, 50058) with DCM > 500,
    %ignore them for now
    if ~isempty(maxDCM) && maxDCM < 250
        %actually have a value for DCM, some cruises have nothing here
        unCru.maxDCM(a) = maxDCM;
        unCru.maxDCM_depthTop(a) =  makeSmall.DCMde_top(id);%depth of the top of the DCM for the DCM that is the max
        unCru.maxDCM_depthBot(a) =  makeSmall.DCMde_bot(id);%depth of the top of the DCM for the DCM that is the max
        unCru.DCMinML(a) = makeSmall.DCMinML(id);
        clear maxDCM id
    end %end if loop testing for an empty DCM
    
    %now get the maximum MLD for cruise; here no MLD = -999, but could have
    %four -999 values, so set that case to NaN
    m = max(makeSmall{:,useMLD});
    if m > 0
        unCru{a,'MLDmax'} = m;
    else 
        unCru{a,'MLDmax'} = NaN;
    end
    clear m
    
    %need to pull a date - just use the first date for each cruise
    unCru{a,'year'} = makeSmall.year(1);
    unCru{a,'month'} = makeSmall.month(1);
    unCru{a,'day'} = makeSmall.day(1);
    unCru{a,'datetime'} = datetime(datestr(makeSmall.mtime(1)));
    clear makeSmall   
end
clear a

save(NameOfFile)


