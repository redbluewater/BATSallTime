%This will create a single text file for each cruise containing the 
%concatenated casts; naming convention is $cruise_ctd.txt
%modified from Ruth Curry's version
%Krista Longnecker, 19 October 2023; 2 January 2024

curdir = 'C:\Users\klongnecker\Documents\Dropbox\Current projects\Kuj_BIOSSCOPE\RawData\CTDdata\BSworking';
cd(curdir)
D = dir();
D(~[D.isdir]) = []; %syntax from MATLAB central, removes anything not a directory
dirlist = D(3:end); %this skips over the directories . and ..
clear D 

subdirinfo = cell(length(dirlist));
for a = 1 : length(dirlist)
  thisdir = dirlist(a).name;
  temp = dir(fullfile(thisdir, '*c*_QC.dat'));
  %argh, MATLAB on Windows is ignoring case, so this is trapping all the
  %files names *BIOSSCOPE* which we do not want
  
  for aa = 1:length(temp)
      %take the *dat file (all EXCEPT the one marked BIOS-SCOPE) and make
      %it a text file. Will put that text file (somewhere)
      one = strcat(temp(aa).folder,filesep,temp(aa).name);
      if ~contains(temp(aa).name,'BIOSSCOPE') %skip this file
          fid = fopen(strcat(thisdir,'_ctd.txt'),'a');
          riFile = fileread(one);
          fprintf(fid,'%s',riFile);  
          fclose(fid);
          clear riFile
      end
      clear one
  end
  clear aa 
end
clear a

%The following was Ruth's original example:
%Edit dirlist to reflect the list of cruises. set list = `ls -d 1* 9*` 
%Run the commands in a terminal window using a csh (shell interpreter).
% set curdir = `pwd` 
% set dirlist = (10367 10368 10369 10370 10371 10373 10374 10376 10376 10377 10378 10379 10381 10382 10383 10384 10385 10386 10387 10388 10389 20379 20380 92114 92123)
% for each dir ($dirlist)
% cd $dir
% echo $dir
% set list = `ls *c*_QC.dat` 
% cat $list > ../${dir}_ctd.txt
% cd $curdir
% end
