%Working in a new repository to calculate the seasons in the past
%historical BATS data
%use my version of label_seasons_ctd to find a season with the max values
%and then do some plotting. This will get most years at least close for the
%season, but there will be some manual editing needed
%Krista Longnecker ; 3 July 2024
addpath(genpath('C:\Users\klongnecker\Documents\GitHub\BATSallTime\MATLAB_code\mfiles'));    
warning('off','MATLAB:table:RowsAddedExistingVars');

clear all
close all
load BATSdataForSeasonDefinitions.2024.07.01.mat 
NameOfFile = 'BATSdataForSeasonDefinitions_addSeasons.2024.07.01.mat'; %iterate to a new name
load Season_dates_all.mat

doPlotting = 0; %set this to zero if you do not want to see each year's plot

for a = 1:size(season_dates.mixed,1)
    dt.year(a,1) = year(datetime(datestr(season_dates.strat(a,1)))); %summer will be in year and always there
    dt.mixed(a,1) = datetime(datestr(season_dates.mixed(a,1)));
    dt.mixed(a,2) = datetime(datestr(season_dates.mixed(a,2)));

    dt.spring(a,1) = datetime(datestr(season_dates.spring(a,1)));
    dt.spring(a,2) = datetime(datestr(season_dates.spring(a,2)));

    dt.strat(a,1) = datetime(datestr(season_dates.strat(a,1)));
    dt.strat(a,2) = datetime(datestr(season_dates.strat(a,2)));

    dt.fall(a,1) = datetime(datestr(season_dates.fall(a,1)));
    dt.fall(a,2) = datetime(datestr(season_dates.fall(a,2)));
end
clear a 
seasons = struct2table(dt);
gliderYears = seasons.year;
clear season_dates dt

unCru.season = nan(size(unCru,1),1);

%will need time steps - sort what I have based on datetime
unCru = sortrows(unCru,'datetime');

%need to compare to the prior time step, so start outside the loop
a = 1;
priorSeason = NaN;
timeStep_days = NaN;
% KL wrote label_seasons_ctd_KL_v2 to get a first pass on dates
theCode = label_seasons_ctd_KL_v2(unCru.maxDCM(a),...
    unCru.maxDCM_depthTop(a), ...
    unCru.DCMinML(a),...
    unCru.MLDmax(a),...
    priorSeason,timeStep_days,unCru.month(a));
unCru.season(a) = theCode;

%now go through all the other cruises
for a = 2:size(unCru,1)
    timeStep_days = days(unCru.datetime(a) - unCru.datetime(a-1)); %in hours, convert to days
    priorSeason = unCru.season(a-1);
    theCode = label_seasons_ctd_KL_v2(unCru.maxDCM(a),...
        unCru.maxDCM_depthTop(a),...
        unCru.DCMinML(a),...
        unCru.MLDmax(a),...
        priorSeason,timeStep_days,unCru.month(a));
    unCru.season(a) = theCode;
    clear theCode timeStep_days priorSeason
end
clear a

i = isnan(unCru.season);
unCru.season(i) = -999; %need this to plot with gscatter, NaN will get skipped
clear i 

%plot each year at a time
uy = unique(unCru.year);

idx = size(seasons,1)+1;
for a = 1:length(uy)
% for a = 29:length(uy) %this is the set for years with glider data
% for a = 13; %just run one year
% for a = 1:5;
    k = find(unCru.year == uy(a));
    
    %IF there is no season information from the gliders, enter it based on
    %the seasons I just calculated; subtract one day from the cruise date
    %so this will be found in a search for a given cruise
    %This uses 'ce' a function that KL wrote to put in NaT values as
    %needed (if there is no match, can have years without all seasons)

    %Only do this if there is no season from Ruth's glider(s)
    if isempty(find(uy(a)==gliderYears,1,'first'))   
        seasons.year(idx) = uy(a); 
        if ~isequal(unique(unCru.season(k)),-999)
            makeSmall = unCru(k,:);
            % the mixed season may begin at the end of a year or the beginning
            kd = find(makeSmall.season==1); %mixed
            if length(kd)==1; 
                %only one choice for this year so no need for extra steps
                seasons.mixed(idx,1) = ce(dateshift(makeSmall.datetime(kd),'start','day')-day(1),'t'); %drop h/m/s;
            elseif length(kd) > 1
                %prefer fall (11 or 12) over months early in the year...
                um = unique(makeSmall.month(kd));
                if sum(um==12,1)
                    km = find(makeSmall.month==12,1,'first');
                    ks = find(makeSmall.season==1);
                    kd = intersect(km,ks);
                    seasons.mixed(idx,1) = ce(dateshift(makeSmall.datetime(kd),'start','day')-day(1),'t'); %drop h/m/s;
                    clear km ks kd
                elseif sum(um==11,1)
                    km = find(makeSmall.month==11,1,'first');
                    ks = find(makeSmall.season==1);
                    kd = intersect(km,ks);
                    seasons.mixed(idx,1) = ce(dateshift(makeSmall.datetime(kd),'start','day')-day(1),'t'); %drop h/m/s;
                    clear km ks kd
                else 
                    kd = find(makeSmall.season==1,1,'first');
                    seasons.mixed(idx,1) = ce(dateshift(makeSmall.datetime(kd),'start','day')-day(1),'t'); %drop h/m/s;
                end  %end 11/12/1 date selection
            else 
                %put a stop in here in case there no is strat season for a year
                keyboard
            end%end loop for setting the date for mixed season  
            clear kd
    
            kd = find(makeSmall.season==2,1,'first'); %spring
            seasons.spring(idx,1) = ce(dateshift(makeSmall.datetime(kd),'start','day')-day(1),'t'); %drop h/m/s
            clear kd
            kd = find(makeSmall.season==3,1,'first'); %strat
            seasons.strat(idx,1) = ce(dateshift(makeSmall.datetime(kd),'start','day')-day(1),'t'); %drop h/m/s



            clear kd
            kd = find(makeSmall.season==4,1,'first'); %fall
            seasons.fall(idx,1) = ce(dateshift(makeSmall.datetime(kd),'start','day')-day(1),'t'); %drop h/m/s
            clear kd
        else
            seasons.year(idx) = uy(a);
        end
        %increment the counter
        idx = idx + 1;
    end %end If statement looking in gliderSeasons

    if doPlotting %set to one to make plot(s)
        ms = 15;
        %sColor = cbrewer('qual','Set1',5);
        sColor = [55 126 184; 77 175 74; 228 26 28 ; 152 78 163]./255;
        sColor(5,:) = 0.75*ones(1,3); %set -999 to gray
        sShape = ['s','o','>','d','^'];
        seasonNames = {'1','2','3','4','-999'}; %use this to set colors across years

        figure(a)
        h1 = gscatter(unCru.datetime(k),unCru.maxDCM_depthTop(k),unCru.season(k),sColor,'o',ms,'filled');
        for ac = 1:length(h1)
            dn = get(h1(ac),'DisplayName');
            st = strcmp(dn,seasonNames);
            kt = find(st==1);
            set(h1(ac),'markerfacecolor',sColor(kt,:),'markeredgecolor',sColor(kt,:));
            clear dn st kt
        end
        clear ac h1
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
        clear h2
        set(gcf,'position',[0.5623    1.2817    1.3393    0.5800]*1e3)
        hold on
        XL = xlim;
        %use this for the legend so I do not get nonsense labels for the lines
        L = legend;
        L.AutoUpdate = 'off';
        
        line(XL,[100 100],'color','k')
        line(XL,[30 30],'color','k')
        clear XL
        ky = find(seasons.year ==uy(a));
        if ~isempty(ky)
            g = 0.75*ones(1,3);
            line([seasons.mixed(ky,1) seasons.mixed(ky,1)],[0 250],'color',g)
            line([seasons.mixed(ky,2) seasons.mixed(ky,2)],[0 250],'color','k')
            line([seasons.spring(ky,1) seasons.spring(ky,1)],[0 250],'color',g)
            line([seasons.spring(ky,2) seasons.spring(ky,2)],[0 250],'color','k')
            line([seasons.strat(ky,1) seasons.strat(ky,1)],[0 250],'color',g)
            line([seasons.strat(ky,2) seasons.strat(ky,2)],[0 250],'color','k')
            line([seasons.fall(ky,1) seasons.fall(ky,1)],[0 250],'color',g)
            line([seasons.fall(ky,2) seasons.fall(ky,2)],[0 250],'color','k')
        end
        clear ky
        ra
        xtickformat('MM')
        clear k L ms 
    end %end plotting loop
end %end year loop
clear a 
clear uy ms sColor sShape seasonNames

%export the result, use CSV and not XLSX to skip the HH:MM details
seasons = sortrows(seasons,'year');
writetable(seasons,'seasonsExported.csv')

save(NameOfFile)