%
% Compile BATS/BIOSSCOPE CTD files in .csv and .mat formats
% Add fields to Master Bottle file 
%
% Ruth Curry, BIOS / ASU
% Uploaded for BIOS-SCOPE project 19 October 2023
% This will require the following toolboxes in MATLAB:
% Signal Processing Toolbox
% Curve Fitting Toolbox
%
%%   ADDPATH_biosscope  % add mfiles into matlab path
% KL note 10/19/2023: update these folders as needed for your computer
% rootdir = '/Users/rcurry/GliderData/BIOSSCOPE/CTD_BOTTLE';
rootdir_data = 'C:\Users\klongnecker\Documents\Dropbox\CTD_BOTTLE_kit\CTD_BOTTLE'; %KL working
rootdir_scripts = 'C:\Users\klongnecker\Documents\GitHub\data_pipeline\MATLAB_code';

batsdir = fullfile(rootdir_data,'00_CTD/FromBATS_2016-2020');
workdir = fullfile(rootdir_data,'00_CTD');
Bfile = fullfile(rootdir_data,'00_BTL/BATS_BS_COMBINED_MASTER_2020.5.30.xlsx');
%Bfile = fullfile(rootdir,'00_BTL/Workbook1.xlsx');  %had to rename the
%sheet to get readtable to work (for future reference)
sheetName = 'BATS_BS Bottle File';

%Ruth's scripts are in the mfiles folder
addpath(path,genpath(fullfile(rootdir_scripts,'mfiles')))
  
newfile = fullfile(rootdir_data,'ADD_to_MASTER_2023.10.19.csv');



%%  start by loading and labeling CTD data
cd(batsdir);
dirlist = dir('*_ctd.txt');
cd(workdir);

MAXZ = 2500;  % row dimension for CTD profiles

load('season_dates_all.mat'); %KL note: had to move this file
%KL note - uncommented out the following
trans_dates = [];  % initially set to empty; then fill in dates below
  trans_dates.mixed = [datenum('01-Jan-2019'), datenum('27-Mar-2019')];
  trans_dates.spring = [datenum('27-Mar-2019'), datenum('07-Apr-2019')];
  trans_dates.strat = [datenum('07-Apr-2019'), datenum('06-Nov-2019')];
  trans_dates.fall = [datenum('06-Nov-2019'), datenum('06-Dec-2019')];
 nfiles = length(dirlist);
 

    for ii = 1:nfiles

       fname = dirlist(ii).name;
       infile = fullfile(batsdir,fname);
       newdir = fullfile(workdir,fname(1:end-8));
       mkdir(newdir);
       cd(newdir);

       do_plots = 0;
       CTD = create_BIOSSCOPE_ctd_files(infile,MAXZ,trans_dates,do_plots);
       movefile('CRU*',workdir);

       cd(workdir)
       fmt = '%4d%02d%02d_%1d%04d_CTD.mat';
       outfile = sprintf(fmt,CTD.year(1),CTD.month(1),CTD.day(1),CTD.type(1),CTD.cruise(1));
       disp(['Writing ',outfile]);
       save(outfile,'CTD');
    end
    
%%  Do some editing of bad fluorometer and T-S profiles

run('/Users/rcurry/GliderData/BIOSSCOPE/CTD_BOTTLE/edit_BATS_profiles_2016-2020');

%%  Load the bottle file and create an output structure to store new info 
disp(['Loading ',Bfile]);

BB = readtable(Bfile,'sheet',sheetName,'ReadVariableNames',true);
varNames = BB.Properties.VariableNames';
[nrows,ncols] = size(BB);

% extract columns needed to match bottle and ctd casts
s=strcmp(varNames,'New_ID');
icol.batsID= find(s==1,1);
s=strcmp(varNames,'Cruise_ID');
icol.cruiseID= find(s==1,1);
s=strcmp(varNames,'Cast');
icol.cast= find(s==1,1);
s=strcmp(varNames,'Niskin');
icol.niskin= find(s==1,1);
s=strcmp(varNames,'yyyymmdd');
icol.idate= find(s==1,1);
s=strcmp(varNames,'latN');
icol.lat= find(s==1,1);
s=strcmp(varNames,'lonW');
icol.lon= find(s==1,1);
s=strcmp(varNames,'Depth');
icol.depth= find(s==1,1);

%  create a struct with fields for new variables and unique cast/bottle id
%  from existing spreadsheet.  All fields are numeric values
XX = ones(nrows,1) .* -999;
BBadd = struct();
BBadd.New_ID = BB{:,icol.batsID};
BBadd.Cast = BB{:,icol.cast};
BBadd.Niskin = BB{:,icol.niskin};
BBadd.Depth = BB{:,icol.depth};
BBadd.yyyymmdd = BB{:,icol.idate};
BBadd.Sunrise = XX;
BBadd.Sunset = XX;
BBadd.MLD_dens125 = XX;
BBadd.MLD_bvfrq = XX;
BBadd.MLD_densT2 = XX;
BBadd.DCM = XX;
BBadd.VertZone = XX;
BBadd.Season = XX;
clear XX s

%%  Loop through file, cruise by cruise

cruises = BB{:,icol.cruiseID};  %string table var converts to cells
crulist = unique(cruises);
ncru = length(crulist);

for icru = 1:ncru
    theCru = crulist{icru};     % converts cell to a string
    isCru = strcmp(theCru,cruises);
    
    % open corresponding CTD cruise file

    ii = find(isCru == 1,1);
    theID = floor(BBadd.New_ID(ii) * 1e-5);

    cd(workdir)
    dirlist = dir(['*',num2str(theID),'_CTD.mat']);
    if isempty(dirlist)
        disp(['WARNING: No CTD cruise file for ',['CRU_',num2str(theID),'_CTD.mat']]);
        continue
    end
    fname = dirlist.name;
    disp(['Loading ',fname])
    load(fname);

    % use logical indexing to find cruise/cast match
    castlist = unique(BB{isCru,icol.cast});
    ncast = length(castlist);
    
    for icast = 1:ncast
        theCast = castlist(icast);
        castIndx = isCru & BBadd.Cast == theCast;
        ictd = find(CTD.cast == theCast);
        if isempty(ictd)
            disp(['WARNING: no CTD cast found for bottle cast ',theCru,' Cast #',num2str(theCast)]);
            continue
        end
        if ~isempty(ictd)
            CTD.DCM(isnan(CTD.DCM)) = -999;  % change any NaN values to missing 
            istart = find(castIndx == 1,1); 
            iend = find(castIndx == 1,1,'last');
            for ibtl = istart:iend
                zlev = BB{ibtl,icol.depth};  %
                if zlev > 0    % skip bottles where depth is undefined                
                    BBadd.Sunrise(ibtl) = floor(CTD.Sunrise(ictd));
                    BBadd.Sunset(ibtl) = floor(CTD.Sunset(ictd));
                    BBadd.Season(ibtl) = CTD.Season(ictd);
                    BBadd.MLD_dens125(ibtl) = CTD.MLD_dens125(ictd);
                    BBadd.MLD_bvfrq(ibtl) = CTD.MLD_bvfrq(ictd);
                    BBadd.MLD_densT2(ibtl) = CTD.MLD_densT2(ictd);
                    BBadd.DCM(ibtl) = CTD.DCM(ictd);

                    ictdlev = find(CTD.de(:,ictd) >= zlev,1,'first');
                    if isempty(ictdlev)
                        disp(['For bottle depth: ',num2str(zlev),' Using max CTDdepth: ', num2str(max(CTD.de(:,ictd))),' ',num2str(BBadd.New_ID(ibtl))]);
                        ictdlev = find(~isnan(CTD.de(:,ictd)),1,'last');
                    end
                    BBadd.VertZone(ibtl) = CTD.vertZone(ictdlev,ictd);
                    if isnan(CTD.vertZone(ictdlev,ictd))
                        disp('NaN value for vertZone')
                    end
                end
            end
        end
    end
    
      
    clear CTD
end  %for icru
disp(['writing table to ', newfile])
BBtab = struct2table(BBadd);
writetable(BBtab,newfile);


