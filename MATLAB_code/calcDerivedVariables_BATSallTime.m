%Krista calculate Ruth's derived variables from all BATS cruises (e.g.,
%MLD, season, and VZ); starting with BATS cruise #1
%based on Ruth's prior code : create_biosscope_files_2022_2023.m
% Original code from Ruth Curry, BIOS / ASU
% Krista Longnecker; 8 February 2024
% Some notes from Krista (8 February 2024)
% (1) you will need to update the path information and file names
% up through row ~27 in this code. There should be no need to change
% anything past that point.
% (2) The output from this code will be a series CSV files, one per cruise,
%that will be saved in 'outdir', defined at line 22

clear all 
close all

%% >>>>>   % add ./BIOSSCOPE/CTD_BOTTLE/mfiles into matlab path
addpath(genpath('C:\Users\klongnecker\Documents\Dropbox\GitHub\data_pipeline\MATLAB_code\mfiles'));

%% update the folder information before getting started
rootdir = 'C:\Users\klongnecker\Documents\Dropbox\Current projects\Kuj_BIOSSCOPE\';
%Krista has put the next two folders outside the space accessible by GitHub
workdir = fullfile(rootdir,'_RCcalcBATS\data_temporary\');
outdir = fullfile(rootdir,'_RCcalcBATS\data_holdingZone\');

%set this to one if you want to see a plot for each cast (that will clearly
%be a ton of plots, so this is best used if you to look at a preset number
%of casts wihtin the full set of casts)
do_plots = 0;
   
%now do the calculations

%Ruth set this up for txt files, but the BATS txt files are a pain, use
%their *mat files
cd(workdir)
dirlist = dir('*.mat');

nfiles = length(dirlist);

% for ii = 1 %use for testing
for ii = 1:3;
% for ii = 1:nfiles %this will work for all files

   fname = dirlist(ii).name;
   infile = fullfile(workdir,fname);
   
   %use modified function from KL, 2/8/2024
   CTD = create_BIOSSCOPE_ctd_files_v2(infile,do_plots,outdir);
end

