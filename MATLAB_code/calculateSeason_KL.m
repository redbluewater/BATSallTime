%use my version of label_seasons_ctd to find a season with the max values
%an dthen do some plotting
%KL 1 July 2024 - need to do some tidying up for certain
clear all
close all
load BATSdataForSeasonDefinitions.2024.07.01.mat 

uniqueCruises.season = nan(size(uniqueCruises,1),1);

for a = 1:size(uniqueCruises,1)
    %function [theCode] = label_seasons_ctd(DCMdepthMax,DCMdepthTop,mld,month)
    theCode = label_seasons_ctd_KLtesting(uniqueCruises.maxDCMallTime(a),...
        uniqueCruises.maxDCMallTime_depthTop(a),uniqueCruises.MLDmax(a),...
        uniqueCruises.month(a));
    uniqueCruises.season(a) = theCode;
    clear theCode
end
clear a

cmap = cbrewer('qual','Set1',4);
% figure
% subplot(211)
% gscatter(uniqueCruises.datetime,uniqueCruises.maxDCMallTime,uniqueCruises.season,cmap,[],30)
% 
% subplot(212)
% gscatter(uniqueCruises.month,uniqueCruises.maxDCMallTime,uniqueCruises.season,cmap,[],30)


%plot each year at a time
uy = unique(uniqueCruises.year);
ms = 15;
for a = 1:length(uy)
    figure(a)
    k = find(uniqueCruises.year == uy(a));
    
    gscatter(uniqueCruises.datetime(k),uniqueCruises.maxDCMallTime(k),uniqueCruises.season(k),cmap,'d',ms)
    hold on
    gscatter(uniqueCruises.datetime(k),uniqueCruises.MLDmax(k),uniqueCruises.season(k),cmap,'p',ms)
    title(strcat(string(uy(a)),{' '}, 'diamond=DCM and star = MLD'),'fontweight','bold')
    set(gcf,'position',[0.5623    1.2817    1.3393    0.5800]*1e3)
    hold on
    XL = xlim;
    line(XL,[100 100],'color','k')
    line(XL,[30 30],'color','k')
    ra
end
clear a