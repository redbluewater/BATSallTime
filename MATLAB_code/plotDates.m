%plot up the timing for each year...
clear all 
close all

T = readtable('seasons_wKLmanualEdits.xlsx ');
ms = 20;
figure
cmap = cbrewer('qual','Set2',4);
plot(T.year,dec_doy(T.mixed_2),'.','markersize',ms,'color',cmap(1,:))
hold on
plot(T.year,dec_doy(T.spring_2),'.','markersize',ms,'color',cmap(2,:))
plot(T.year,dec_doy(T.strat_2),'.','markersize',ms,'color',cmap(3,:))
plot(T.year,dec_doy(T.fall_2),'.','markersize',ms,'color',cmap(4,:))
legend('mixed','spring','strat','fall')
title('dates are ending dates in each year''s season')

