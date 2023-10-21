%This will create a single text file for each cruise containing the 
%concatenated casts; naming convention is $cruise_ctd.txt

%Edit dirlist to reflect the list of cruises. set list = `ls -d 1* 9*` 
%Run the commands in a terminal window using a csh (shell interpreter).

% Ruth was doing this in the command line; moving to MATLAB
% %Krista Longnecker, 19 October 2023
%this is more complicated because each cruise data folder seems to be 
%organized in a different way


% set curdir = `pwd` 
% set dirlist = (10367 10368 10369 10370 10371 10373 10374 10376 10376 10377 10378 10379 10381 10382 10383 10384 10385 10386 10387 10388 10389 20379 20380 92114 92123)
% for each dir ($dirlist)
% cd $dir
% echo $dir
% set list = `ls *c*_QC.dat` 
% cat $list > ../${dir}_ctd.txt
% cd $curdir
% end

curdir = 'C:\Users\klongnecker\Documents\Dropbox\1.0 ORIG from BATS\CTDrelease_20230626';
D = dir(curdir);
trim = [D.isdir]';
temp = {D.name}';
dirlist = temp(trim);
dirlist = dirlist(3:end);
clear D trim temp

for a = 1:length(dirlist)
    
end
clear a
