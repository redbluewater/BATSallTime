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
%Change to using a set of season boundaries pre-defined based on the code
%in the BATSallTime GitHub repository, and edited manually by Krista,
%import the result here and define the seasons that way
%Krista Longnecker; 3 July 2024
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

elseif isequal(getenv('COMPUTERNAME'),'LONGNECKER-1650')
    %% add ./BIOSSCOPE/CTD_BOTTLE/mfiles into matlab path    
    addpath(genpath('C:\Users\klongnecker\Documents\Dropbox\GitHub\data_pipeline\MATLAB_code\mfiles'));

    %% update the folder information before getting started
    rootdir = 'C:\Users\klongnecker\Documents\Dropbox\Current projects\Kuj_BIOSSCOPE\RawData\';
    %Krista has put the next two folders outside the space accessible by GitHub
    %These files are too large to put into GitHub
    
    % workdir = fullfile(rootdir,'RCcalcBATS\data_temporary\');
    workdir = fullfile(rootdir,'RCcalcBATS\data_copySmall_testing\');
    
    outdir = fullfile(rootdir,'RCcalcBATS\data_holdingZone\');
end

gitdir = pwd;
%set this to one if you want to see a plot for each cast (that will clearly
%be a ton of plots, so this is best used if you to look at a preset number
%of casts within the full set of casts)
do_plots = 0;
   
NameOfFile = 'BATSdata_withManualSeasons.2024.07.05.mat';

%now do the calculations

%Use this function to make a MATLAB structure with transition dates
seasonsFile = fullfile('../','BATS_seasons_wKLedits.2024.07.05.xlsx');
%use this function to reformat the dates, set fName in calcDerivedVariables
trans_dates = reformat_season_dates(seasonsFile) ; 

%Ruth set this up for txt files, but the BATS txt files are a pain, use
%the BATS *mat files
cd(workdir)
dirlist = dir('*.mat');
%skip over some files
toSkip = {'YR','bats_ctd.mat','bval_ctd.mat','working.mat'};
s = contains({dirlist.name},toSkip);
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
   
   CTD = calculate_BATSderivedVariables_applyKnownSeasons(infile,do_plots,outdir,0,trans_dates);
   %make a table, easier to manipulate; have to write a custom script to
   %make a table given the complexity of these structures
   trim = 1; %set this to one to only keep the values that are one per cruise/cast
   T = convert_RCstructure2table(CTD,trim); %this is a new KL function 6/21/2024
   stepOne = [stepOne;T];
   
   clear idx T trim CTD infile fname
end
clear ii nfiles doFiles dirlist do_plots seasonsFile

%This is a messy way to get a look up table as I am changing types
stepTwo = cell2mat(table2array(stepOne));
%put in NaN for export - the -999 makes things harder in R for makeSynoptic
k = find(stepTwo==-999);
stepTwo(k) = NaN;
stepThree = array2table(stepTwo,'VariableNames',stepOne.Properties.VariableNames);
clear stepOne stepTwo


%Now export stepTwo as a CSV file for R
writetable(stepThree,fullfile(gitdir,'BATSderivedValues_lookupTable.2024.07.05.csv'))
cd(gitdir)
save(NameOfFile)

%do some housecleaning 
cd(gitdir)
clear gitdir outdir rootdir workdir
save(NameOfFile,'stepThree','NameOfFile')

%%% now move on and get the MLD and DCM information
useMLD = 'MLD_densT2'; %define up top, change as needed

%first parse out the five digit cruise detail (new function)
stepThree.cruise = id2cruise(stepThree.BATS_id);

%now that I have the BATS five digit cruises I can work on one cruise at a
%time (this is a case where R is easier than MATLAB); setup a table
unCru = array2table(unique(stepThree.cruise),'VariableNames',{'cruise'});
unCru.year = nan(size(unCru,1),1);
unCru.month = nan(size(unCru,1),1);
unCru.day = nan(size(unCru,1),1);
unCru.datetime = NaT(size(unCru,1),1);
unCru.maxDCM = nan(size(unCru,1),1); %will be a number, max DCM, any time
unCru.MLDmax = nan(size(unCru,1),1); %number, value
unCru.season = nan(size(unCru,1),1); %number, value

for a = 1:size(unCru,1)
    k = find(unCru.cruise(a) == stepThree.cruise); %find one cruise
    makeSmall = stepThree(k,:); %easier to work with small dataset
    clear k
    %find the max DCM for the cruise; 
    [maxDCM id] = max(makeSmall.DCM,[],'omitnan'); %need brackets or you get garbage (skipping dimension)
    %have three cruises with issues (10155, 50056, 50058) with DCM > 500
    %issues with fluorometer
    if ~isempty(maxDCM) && maxDCM < 250
        %get the DCM value 
        unCru.maxDCM(a) = maxDCM;
        clear maxDCM id
    end %end if loop testing for an empty DCM
    
    %now get the maximum MLD for cruise; here no MLD = -999
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
    unCru{a,'season'} = makeSmall.Season(1);
    clear makeSmall   

end
clear a

save(NameOfFile)

