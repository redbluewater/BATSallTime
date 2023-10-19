

%load('/Users/rcurry/GliderData/BIOSSCOPE/CTD_BOTTLE/00_CTD/MATfiles/20160709_91614_CTD.mat')
Bfile = '/Users/rcurry/GliderData/BIOSSCOPE/CTD_BOTTLE/00_BTL/BATS_BS_COMBINED_MASTER_2020.4.27.xlsx';
sheetName = 'BATS_BS Bottle File';
load('/Users/rcurry/GliderData/Analysis_2020/cmaps.mat');

BB = readtable(Bfile,'sheet',sheetName);
varNames = BB.Properties.VariableNames';
[nrows,ncols] = size(BB);


% extract columns from bottle table 
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
s=strcmp(varNames,'VertZone');
icol.vertZone= find(s==1,1);
s=strcmp(varNames,'sig_theta_kg_m_3_');
icol.sig0= find(s==1,1);
s=strcmp(varNames,'DCM');
icol.DCM= find(s==1,1);
s=strcmp(varNames,'MLD_dens125');
icol.MLD_dens125= find(s==1,1);
s=strcmp(varNames,'MLD_densT2');
icol.MLD_densT2= find(s==1,1);

%  create a struct with fields for new variables and unique cast/bottle id
%  from existing spreadsheet.  All fields are numeric values
Bbtl = struct();
Bbtl.New_ID = BB{:,icol.batsID};
Bbtl.Cast = BB{:,icol.cast};
Bbtl.Niskin = BB{:,icol.niskin};
Bbtl.Depth = BB{:,icol.depth};
Bbtl.sig0 = BB{:,icol.sig0};
Bbtl.vertZone = BB{:,icol.vertZone};
Bbtl.MLD_dens125 = BB{:,icol.MLD_dens125};
Bbtl.MLD_densT2 = BB{:,icol.MLD_densT2};
Bbtl.MLD_bvfrq = BB{:,icol.MLD_bvfrq};
Bbtl.DCM = BB{:,icol.DCM};
Bbtl.yyyymmdd = BB{:,icol.idate};

Bbtl.New_ID(Bbtl.New_ID < -990) = NaN;
Bbtl.Cast(Bbtl.Cast < -990) = NaN;
Bbtl.Niskin(Bbtl.Niskin < -990) = NaN;
Bbtl.Depth(Bbtl.Depth < -990) = NaN;
Bbtl.sig0(Bbtl.sig0 < -990) = NaN;
Bbtl.vertZone(Bbtl.vertZone < -990) = NaN;
Bbtl.MLD_densT2(Bbtl.MLD_densT2 < -990) = NaN;
Bbtl.MLD_dens125(Bbtl.MLD_dens125 < -990) = NaN;
Bbtl.MLD_bvfrq(Bbtl.MLD_bvfrq < -990) = NaN;
Bbtl.DCM(Bbtl.DCM < -990) = NaN;
Bbtl.yyyymmdd(Bbtl.yyyymmdd < -990) = NaN;

Bbtl.mtime = datenum(num2str(Bbtl.yyyymmdd),'yyyymmdd');

[~,nprof ] = size(CTD.de);
DE = 1:2:1000;
nz = length(DE);

Time = CTD.mtime(:)';
Zchlor = ones(nz,nprof).* NaN;

CTD.fluor_filt(CTD.fluor_filt < -900) = NaN;
CTD.de(CTD.de < -900) = NaN;
CTD.MLD_densT2(CTD.MLD_densT2 < -900) = NaN;
CTD.MLD_densT2(CTD.MLD_dens125 < -900) = NaN;

 figure; 
 subplot(3,1,1); hold on; axis ij;
 colormap(cmap.chlor)
 imagesc(Time,DE,Zchlor);
 caxis([.025 .2])
 ylim([0 400]);
 datetick('x','mm/dd')
 
 plot(Time,CTD.DCM,'+k')
 plot(Time,DCM.depth,'^b')
 plot(Time,CTD.MLD_dens125,'-','Linewidth',2)
 plot(Time,CTD.MLD_densT2,'-','Linewidth',2)
 
 plot(Time,DCM.de_top,'-k','Linewidth',2)
 plot(Time,DCM.de_bot,'-k','Linewidth',2)
 
 
  subplot(3,1,2); hold on; axis ij;
  ylim([0 400]);
plot(Time,CTD.DCM,'+k')
 plot(Time,DCM.depth,'^b')
 plot(Time,CTD.MLD_dens125,'-','Linewidth',2)
 plot(Time,CTD.MLD_densT2,'-','Linewidth',2)
 
 plot(Time,DCM.de_top,'-k','Linewidth',2)
 plot(Time,DCM.de_bot,'-k','Linewidth',2)
  datetick('x','mm/dd')

for ii = 1:nprof
 indx1 = find(CTD.vertZone(:,ii) == 1);
 if ~isempty(indx1) 
   plot(Time(ii),CTD.de(indx1,ii),'+r')
 end
  indx1 = find(CTD.vertZone(:,ii) == 2);
 if ~isempty(indx1) 
   plot(Time(ii),CTD.de(indx1,ii),'+g')
 end
 indx1 = find(CTD.vertZone(:,ii) == 3);
 if ~isempty(indx1) 
   plot(Time(ii),CTD.de(indx1,ii),'+b')
 end
end


%%  plot vs sig0

 
