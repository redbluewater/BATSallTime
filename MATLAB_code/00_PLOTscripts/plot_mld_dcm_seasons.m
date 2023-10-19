rootdir = '/Users/rcurry/GliderData/BIOSSCOPE/CTD_BOTTLE';
workdir = fullfile(rootdir,'00_CTD');

cd(workdir);
dirlist = dir('*_CTD.mat');

 nfiles = length(dirlist);

 figure; hold on; axis ij;
 
 for ii = 1:nfiles
  fname = dirlist(ii).name;
  infile = fullfile(workdir,fname);
  load(infile);
  nprof=length(CTD.BATS_id);
  CTD.MLD_bvfrq(CTD.MLD_bvfrq < -990) = NaN;
  CTD.MLD_dens125(CTD.MLD_dens125 < -990) = NaN;
  CTD.MLD_densT2(CTD.MLD_densT2 < -990) = NaN;
  CTD.DCM(CTD.DCM < -990) = NaN;
  for iprof = 1:nprof
      plot(CTD.mtime,CTD.MLD_bvfrq,'+m-');
      plot(CTD.mtime,CTD.MLD_dens125,'+c-');
      plot(CTD.mtime,CTD.MLD_densT2,'+k-');
      plot(CTD.mtime,CTD.DCM,'sg');
      switch CTD.Season(iprof)
          case 1
             plot(CTD.mtime(iprof),-5,'sb','MarkerSize',10,'MarkerFaceColor','b');
          case 2
             plot(CTD.mtime(iprof),-5,'sg','MarkerSize',10,'MarkerFaceColor','g');
          case 3
             plot(CTD.mtime(iprof),-5,'sr','MarkerSize',10,'MarkerFaceColor','r');
          case 4
             plot(CTD.mtime(iprof),-5,'sc','MarkerSize',10,'MarkerFaceColor','c');
      end
      
  end
 end
 datetick('x','m/dd')
 
 set(gca,'Fontsize',14)
 ylim([-10 350])
 ylabel('Depth(m)')
 xlabel('Month/Yr')
 