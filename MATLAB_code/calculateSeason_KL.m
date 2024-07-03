%use my version of label_seasons_ctd to find a season with the max values
%an dthen do some plotting
%KL 1 July 2024 - need to do some tidying up for certain
addpath(genpath('C:\Users\klongnecker\Documents\GitHub\data_pipeline\MATLAB_code\mfiles'));    


clear all
close all
load BATSdataForSeasonDefinitions.2024.07.01.mat 
load Season_dates_all.mat

for a = 1:size(season_dates.mixed,1)
    dt.year(a,1) = year(datetime(datestr(season_dates.fall(a,1))));
    dt.mixed(a,1) = datetime(datestr(season_dates.mixed(a,1)));
    dt.mixed(a,2) = datetime(datestr(season_dates.mixed(a,2)));
    
    dt.spring(a,1) = datetime(datestr(season_dates.spring(a,1)));
    dt.spring(a,2) = datetime(datestr(season_dates.spring(a,2)));

    dt.strat(a,1) = datetime(datestr(season_dates.strat(a,1)));
    dt.strat(a,2) = datetime(datestr(season_dates.strat(a,2)));
    
    dt.fall(a,1) = datetime(datestr(season_dates.fall(a,1)));
    dt.fall(a,2) = datetime(datestr(season_dates.fall(a,2)));
end
clear a season_dates

unCru.season = nan(size(unCru,1),1);

%will need time steps - sort based on datetime
unCru = sortrows(unCru,'datetime');

% for a = 1:size(unCru,1)
%     %function [theCode] = label_seasons_ctd(DCMdepthMax,DCMdepthTop,mld,month)
%     theCode = label_seasons_ctd_KL_v1(unCru.maxDCMallTime(a),...
%         unCru.maxDCMallTime_depthTop(a),unCru.MLDmax(a),...
%         unCru.month(a));
%     unCru.season(a) = theCode;
%     clear theCode
% end
% clear a

%will need to compare to the prior time step, so start outside the loop
%already brings up the point that I will need a case for priorTime = NaN;
a = 1;
priorSeason = NaN;
timeStep_days = NaN;
%function [theCode] = label_seasons_ctd_KL_v2(DCMdepth,DCMdepthTop,DCMinML,mld,priorSeason,timeStep_days,month)
theCode = label_seasons_ctd_KL_v2(unCru.maxDCM(a),...
    unCru.maxDCM_depthTop(a), ...
    unCru.DCMinML(a),...
    unCru.MLDmax(a),...
    priorSeason,timeStep_days,unCru.month(a));
unCru.season(a) = theCode;

for a = 2:size(unCru,1)
% for a = 433;
% if a==530
%     keyboard
% end
    %function [theCode] = label_seasons_ctd(DCMdepthMax,DCMdepthTop,mld,month)
    timeStep_days = days(unCru.datetime(a) - unCru.datetime(a-1)); %in hours, convert to days
    priorSeason = unCru.season(a-1);
    theCode = label_seasons_ctd_KL_v2(unCru.maxDCM(a),...
        unCru.maxDCM_depthTop(a),...
        unCru.DCMinML(a),...
        unCru.MLDmax(a),...
        priorSeason,timeStep_days,unCru.month(a));
    unCru.season(a) = theCode;
    clear theCode
end
clear a

i = isnan(unCru.season);
unCru.season(i) = -999; %need this to plot with gscatter
clear i 

%plot each year at a time
uy = unique(unCru.year);
ms = 15;
%sColor = [241 90 34; 0 168 117; 0 114 188; 239 91 161; 247 148 29;  218 111 171;  236 234 100]./255;
sColor = cbrewer('qual','Set1',5);
sColor = sColor([5 4 3 2 1],:); %order to red is -999
sShape = ['s','o','>','d','^'];

seasonNames = {'1','2','3','4','-999'};

for a = 1:length(uy)
% for a = 29:length(uy) %this is the set for years with glider data
% for a = 30;
    figure(a)
    k = find(unCru.year == uy(a));
    
    % gscatter(unCru.datetime(k),unCru.maxDCMallTime(k),unCru.season(k),cmap,'o',ms,'filled');
    h1 = gscatter(unCru.datetime(k),unCru.maxDCM_depthTop(k),unCru.season(k),sColor,'o',ms,'filled');
    for ac = 1:length(h1)
        dn = get(h1(ac),'DisplayName');
        st = strcmp(dn,seasonNames);
        kt = find(st==1);
        set(h1(ac),'markerfacecolor',sColor(kt,:),'markeredgecolor',sColor(kt,:));
        clear dn st kt
    end
    hold on
    h2 = gscatter(unCru.datetime(k),unCru.MLDmax(k),unCru.season(k),sColor,'p',ms,'filled');
    for ac = 1:length(h2)
        dn = get(h2(ac),'DisplayName');
        st = strcmp(dn,seasonNames);
        kt = find(st==1);
        set(h2(ac),'markerfacecolor',sColor(kt,:),'markeredgecolor',sColor(kt,:));
        clear dn st kt
    end
    title(strcat(string(uy(a)),{' '}, 'circle=DCM\_depthTop ; star = MLD'),'fontweight','bold')
    set(gcf,'position',[0.5623    1.2817    1.3393    0.5800]*1e3)
    hold on
    XL = xlim;
    %use these two lines so I do not get nonsense labels for the lines
    L = legend;
    L.AutoUpdate = 'off';
    
    line(XL,[100 100],'color','k')
    line(XL,[30 30],'color','k')
    clear XL
    if uy(a) >= 2015
        ky = find(dt.year ==uy(a));
        if ~isempty(ky)
            line([dt.mixed(ky,1) dt.mixed(ky,1)],[0 250],'color','k')
            line([dt.mixed(ky,2) dt.mixed(ky,2)],[0 250],'color','k')
            line([dt.spring(ky,1) dt.spring(ky,1)],[0 250],'color','k')
            line([dt.spring(ky,2) dt.spring(ky,2)],[0 250],'color','k')
            line([dt.strat(ky,1) dt.strat(ky,1)],[0 250],'color','k')
            line([dt.strat(ky,2) dt.strat(ky,2)],[0 250],'color','k')
            line([dt.fall(ky,1) dt.fall(ky,1)],[0 250],'color','k')
            line([dt.fall(ky,2) dt.fall(ky,2)],[0 250],'color','k')
        end
        clear ky
    end
    ra
    xtickformat('MM')
end
clear a uy 
