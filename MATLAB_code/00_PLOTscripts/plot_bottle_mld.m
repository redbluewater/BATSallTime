rootdir = '/Users/rcurry/GliderData/BIOSSCOPE/CTD_BOTTLE';
batsdir = fullfile(rootdir,'00_CTD/FromBATS');
workdir = fullfile(rootdir,'00_CTD');
Bfile = fullfile(rootdir,'00_BTL/BATS_BS_COMBINED_MASTER_2020.4.27.xlsx');
sheetName = 'BATS_BS Bottle File';



BB = readtable(Bfile,'sheet',sheetName);
varNames = BB.Properties.VariableNames';
[nrows,ncols] = size(BB);

% extract columns needed for plotting
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
s=strcmp(varNames,'MLD');
icol.mld= find(s==1,1);
s=strcmp(varNames,'MLD_dens125');
icol.mld_dens125= find(s==1,1);
s=strcmp(varNames,'MLD_bvfrq');
icol.mld_bvfrq= find(s==1,1);
s=strcmp(varNames,'MLD_densT2');
icol.mld_densT2= find(s==1,1);

XX = struct();
XX.New_ID = BB{:,icol.batsID};
XX.Cast = BB{:,icol.cast};
XX.Niskin = BB{:,icol.niskin};
XX.Depth = BB{:,icol.depth};
XX.yyyymmdd = BB{:,icol.idate};
XX.mld = BB{:,icol.mld};
XX.mld_dens125 = BB{:,icol.mld_dens125};
XX.mld_bvfrq = BB{:,icol.mld_bvfrq};
XX.mld_densT2 = BB{:,icol.mld_densT2};

igood = find(XX.yyyymmdd > 0);
XX.New_ID = XX.New_ID(igood);
XX.Cast = XX.Cast(igood);
XX.Niskin = XX.Niskin(igood);
XX.Depth = XX.Depth(igood);
XX.yyyymmdd = XX.yyyymmdd(igood);
XX.mld = XX.mld(igood);
XX.mld_dens125 = XX.mld_dens125(igood);
XX.mld_bvfrq = XX.mld_bvfrq(igood);
XX.mld_densT2 = XX.mld_densT2(igood);

XX.mtime = datenum(num2str(XX.yyyymmdd),'yyyymmdd');
XX.mld(XX.mld < 0) = -9.;
XX.mld_dens125(XX.mld_dens125 < 0) = -9.;
XX.mld_densT2(XX.mld_densT2 < 0) = -9.;
XX.mld_bvfrq(XX.mld_bvfrq < 0) = -9.;


figure; 
subplot(2,1,1); hold on; axis ij;
plot(XX.mtime,XX.mld,'+k')
plot(XX.mtime,XX.mld_densT2,'sr','Markersize',3)
datetick('x','m/yy')
xlabel('Month/Year')
set(gca,'Fontsize',14);
title('BATS MLD (k+) vs MLD\_densT2(r) in Bottle file (-9=not defined)')
ylim([-10 350])


subplot(2,1,2); hold on; axis ij;
plot(XX.mtime,XX.mld_densT2,'sr','Markersize',3)
plot(XX.mtime,XX.mld_bvfrq,'^c','Markersize',3)
plot(XX.mtime,XX.mld_dens125,'+b','Markersize',3)
title('MLD\_densT2(r)   MLD\_bvfrq(c)  MLD\_dens125(b))')
datetick('x','m/yy')
set(gca,'Fontsize',14);
ylim([-10 350])
