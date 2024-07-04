%m-file to plot up each year to check on the bounds for seasons
%Krista Longnecker; 3 July 2024
k = find(stepThree.MLD_densT2==-999);
stepThree.MLD_densT2(k) = NaN;
clear k
close all

uy = unique(stepThree.year);

for a = 1:length(uy)
% for a = 10;
    k = find(unCru.year==uy(a));
    ms = 15;
    %sColor = cbrewer('qual','Set1',5);
    sColor = [55 126 184; 77 175 74; 228 26 28 ; 152 78 163]./255;
    sColor(5,:) = 0.75*ones(1,3); %set -999 to gray
    sShape = ['s','o','>','d','^'];
    seasonNames = {'1','2','3','4','-999'}; %use this to set colors across years

    figure(a)
    %h1 = gscatter(unCru.datetime(k),unCru.maxDCM_depthTop(k),unCru.season(k),sColor,'o',ms,'filled');
    h1 = gscatter(unCru.datetime(k),unCru.maxDCM(k),unCru.season(k),sColor,'o',ms,'filled');
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
    %title(strcat(string(uy(a)),{' '}, 'circle=DCM\_depthTop ; star = MLD'),'fontweight','bold')
    title(strcat(string(uy(a)),{' '}, 'circle=DCMmax ; star = MLD'),'fontweight','bold')
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
    seasons = trans_dates;
    ky = find(seasons.year ==uy(a));
    if ~isempty(ky)
        g = 0.75*ones(1,3);
        %have to convert the datenum to datetime...
        line([datetime(seasons.mixed(ky,1),'ConvertFrom','datenum'),...
            datetime(seasons.mixed(ky,1),'ConvertFrom','datenum')],[0 250],'color',g)
        line([datetime(seasons.mixed(ky,2),'ConvertFrom','datenum'),...
            datetime(seasons.mixed(ky,2),'ConvertFrom','datenum')],[0 250],'color',g)
        line([datetime(seasons.spring(ky,2),'ConvertFrom','datenum'),...
            datetime(seasons.spring(ky,2),'ConvertFrom','datenum')],[0 250],'color',g)
        line([datetime(seasons.strat(ky,2),'ConvertFrom','datenum'),...
            datetime(seasons.strat(ky,2),'ConvertFrom','datenum')],[0 250],'color',g)
        line([datetime(seasons.fall(ky,2),'ConvertFrom','datenum'),...
            datetime(seasons.fall(ky,2),'ConvertFrom','datenum')],[0 250],'color',g)
    end
    clear ky
    ra
    xtickformat('MM')
    clear k L ms 
end %end plotting loop


figure
dt = datetime(stepThree.year,stepThree.month,stepThree.day);
gscatter(dt,stepThree.MLD_densT2,stepThree.Season,[],[],20)
ra

% 
% 
% for a = 1:length(uy)
% % for a = 1
%     k = find(stepThree.year == uy(a));
%     ms = 15;
%     %sColor = cbrewer('qual','Set1',5);
%     sColor = [55 126 184; 77 175 74; 228 26 28 ; 152 78 163]./255;
%     sColor(5,:) = 0.75*ones(1,3); %set -999 to gray
%     sShape = ['s','o','>','d','^'];
%     seasonNames = {'1','2','3','4','-999'}; %use this to set colors across years
% 
%     figure(a)
%     h1 = gscatter(stepThree.doy(k),stepThree.DCM(k),stepThree.Season(k),sColor,'o',ms,'filled');
%     ra
%     for ac = 1:length(h1)
%         dn = get(h1(ac),'DisplayName');
%         st = strcmp(dn,seasonNames);
%         kt = find(st==1);
%         set(h1(ac),'markerfacecolor',sColor(kt,:),'markeredgecolor',sColor(kt,:));
%         clear dn st kt
%     end
%     clear ac h1
%     hold on
%     h2 = gscatter(stepThree.doy(k),stepThree.MLD_densT2(k),stepThree.Season(k),sColor,'p',ms,'filled');
%     for ac = 1:length(h2)
%         dn = get(h2(ac),'DisplayName');
%         st = strcmp(dn,seasonNames);
%         kt = find(st==1);
%         set(h2(ac),'markerfacecolor',sColor(kt,:),'markeredgecolor',sColor(kt,:));
%         clear dn st kt
%     end
%     %title(strcat(string(uy(a)),{' '}, 'circle=DCM\_depthTop ; star = MLD'),'fontweight','bold')
%     title(strcat(string(uy(a)),{' '}, 'circle=DCMmax ; star = MLD'),'fontweight','bold')
%     clear h2
%     set(gcf,'position',[0.5623    1.2817    1.3393    0.5800]*1e3)
%     hold on
% 
% end



% 
% 
% % gscatter(uniqueCruises.month,uniqueCruises.MLDmax,uniqueCruises.year,...
% %     parula(length(unique(uniqueCruises.year))),[],10)
% 
% %consider what happens for each year
% uy = unique(uniqueCruises.year);
% 
% for a = 3
%     k = find(uniqueCruises.year == uy(a));
% 
%     gscatter(uniqueCruises.month(k),uniqueCruises.MLDmax(k),uniqueCruises.cruise(k),...
%         parula(length(k)),[],20)
%     hold on
%     gscatter(uniqueCruises.month(k),uniqueCruises.maxDCMallTime(k),uniqueCruises.cruise(k),...
%         'g',[],20)
% 
% 
% end
% clear a