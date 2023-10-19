
load('/Users/rcurry/GliderData/BIOSSCOPE/CTD_BOTTLE/00_CTD/20160709_91614_CTD.mat')
C16=CTD;
C16.bvfilt = get_bvfilt(C16.bvfrq,5);

load('/Users/rcurry/GliderData/BIOSSCOPE/CTD_BOTTLE/00_CTD/20170709_91712_CTD.mat')
C17=CTD;
C17.bvfilt = get_bvfilt(C17.bvfrq,5);

load('/Users/rcurry/GliderData/BIOSSCOPE/CTD_BOTTLE/00_CTD/20180704_91819_CTD.mat')
C18=CTD;
C18.bvfilt = get_bvfilt(C18.bvfrq,5);

figure;
% vs density
subplot(2,2,1); hold on; axis ij;
plot(C16.bvfilt,C16.sig0,'-b')
xlim([-0.0001 0.0015]);
plot(C17.bvfilt,C17.sig0,'-c')
ylim([23 27]);
plot(C18.bvfilt,C18.sig0,'-r')
title('2016(b) 2017(c) 2018(r)')
set(gca,'Fontsize',14);
xlabel('BVfilt')
ylabel('Density')
subplot(2,2,2); hold on; axis ij;
plot(C16.fluor_filt,C16.sig0,'-b')
xlim([-0.01 0.35]);
plot(C17.fluor_filt,C17.sig0,'-c')
ylim([23 27]);
plot(C18.fluor_filt,C18.sig0,'-r')
set(gca,'Fontsize',14);
xlabel('Fluor')

% vs depth
subplot(2,2,3); hold on; axis ij;
plot(C16.bvfilt,C16.de,'-b')
axis ij
xlim([-0.0001 0.0015]);
plot(C17.bvfilt,C17.de,'-c')
ylim([0 250]);
plot(C18.bvfilt,C18.de,'-r')
set(gca,'Fontsize',14);
xlabel('BVfilt')
ylabel('Depth')

subplot(2,2,4); hold on; axis ij;
plot(C16.fluor_filt,C16.de,'-b')
axis ij
xlim([-0.01 0.35]);
plot(C17.fluor_filt,C17.de,'-c')
ylim([0 250]);
plot(C18.fluor_filt,C18.de,'-r')
set(gca,'Fontsize',14);
xlabel('Fluor')
ylabel('Depth')



