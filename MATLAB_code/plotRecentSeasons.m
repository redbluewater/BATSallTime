%plot up the seasons in recent years to see how I did
%this plots up the first pass season decisions 
%Krista Longnecker 12 February 2026
clear all 
close all

load BATSdataForSeasonDefinitions.2026.02.10.mat

k = find(unCru.year >= 2024);
small = unCru(k,:);

ms = 15;
%sColor = cbrewer('qual','Set1',5);
sColor = [55 126 184; 77 175 74; 228 26 28 ; 152 78 163]./255;
sColor(5,:) = 0.75*ones(1,3); %set -999 to gray
sShape = ['s','o','>','d','^'];
seasonNames = {'1','2','3','4','-999'}; %use this to set colors across years

% figure
% subplot(211)
% gscatter(small.datetime,small.maxDCM,small.season,[],[],30)
% 
% subplot(212)


figure(1)
h1 = gscatter(small.datetime,small.maxDCM,small.season,sColor,'o',ms,'filled');
for ac = 1:length(h1)
    dn = get(h1(ac),'DisplayName');
    st = strcmp(dn,seasonNames);
    kt = find(st==1);
    set(h1(ac),'markerfacecolor',sColor(kt,:),'markeredgecolor',sColor(kt,:));
    clear dn st kt
end
clear ac h1
hold on
h2 = gscatter(small.datetime,small.MLDmax,small.season,sColor,'p',ms,'filled');
for ac = 1:length(h2)
    dn = get(h2(ac),'DisplayName');
    st = strcmp(dn,seasonNames);
    kt = find(st==1);
    set(h2(ac),'markerfacecolor',sColor(kt,:),'markeredgecolor',sColor(kt,:));
    clear dn st kt
end

set(gca,'ydir','reverse')
ylabel('Depth (m)')
title(strcat('colors are season; circle = depth of DCMmax ; star = depth of MLD'),'fontweight','bold')
set(gcf,'position',[-1582 382 1558 593])

set(gcf,'paperpositionmode','auto')
saveas(gcf,['SeasonsAtBATS_2024to2025.jpg'],'jpg')
