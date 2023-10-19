load('20160709_91614_CTD.mat')
C16=CTD;
C16.bvfilt = get_bvfilt(C16.bvfrq,5);

load('20170709_91712_CTD.mat')
C17=CTD;
C17.bvfilt = get_bvfilt(C17.bvfrq,5);

load('20180704_91819_CTD.mat')
C18=CTD;
C18.bvfilt = get_bvfilt(C18.bvfrq,5);

load('20190709_91916_CTD.mat')
C19=CTD;
C19.bvfilt = get_bvfilt(C18.bvfrq,5);

%%
iprof = 1;
XX=C16;

ii=iprof;
figure;
for jj=1:4;
    subplot(2,2,jj); hold on; axis ij;
    ylim([0 400]);
    xlim([-0.0001 0.0015]);
    plot(XX.bvfrq(:,ii),XX.de(:,ii),'-c')
    plot(XX.bvfilt(:,ii),XX.de(:,ii),'-k','Linewidth',1.5);
    i0 = find(XX.vertZone(:,ii) == 0,1,'last');
    i1 = find(XX.vertZone(:,ii) == 1,1,'last');
    i2 = find(XX.vertZone(:,ii) == 2,1,'last');
    i3 = find(XX.vertZone(:,ii) == 3,1,'last');
    plot(xlim(),[XX.de(i0,ii) XX.de(i0,ii)],'r','Linewidth',1.5)
    if ~isempty(i1)  plot(xlim(),[XX.de(i1,ii) XX.de(i1,ii)],'--r','Linewidth',1.5); end
    if ~isempty(i2)  plot(xlim(),[XX.de(i2,ii) XX.de(i2,ii)],'-r','Linewidth',1.5); end
    if ~isempty(i3)  plot(xlim(),[XX.de(i3,ii) XX.de(i3,ii)],'--r','Linewidth',1.5); end
    title([num2str(XX.year(ii)),'/',num2str(ii)]);
    ii=ii+1;
end
ii=iprof;
figure;
for jj=1:4;
    subplot(2,2,jj); hold on; axis ij;
    ylim([0 400]);
    xlim([0 0.5]);
    plot(XX.fluor(:,ii),XX.de(:,ii),'-g')
    plot(XX.fluor_filt(:,ii),XX.de(:,ii),'-b','Linewidth',1.5);
    i0 = find(XX.vertZone(:,ii) == 0,1,'last');
    i1 = find(XX.vertZone(:,ii) == 1,1,'last');
    i2 = find(XX.vertZone(:,ii) == 2,1,'last');
    i3 = find(XX.vertZone(:,ii) == 3,1,'last');
    plot(xlim(),[XX.de(i0,ii) XX.de(i0,ii)],'r','Linewidth',1.5)
    if ~isempty(i1)  plot(xlim(),[XX.de(i1,ii) XX.de(i1,ii)],'--r','Linewidth',1.5); end
    if ~isempty(i2)  plot(xlim(),[XX.de(i2,ii) XX.de(i2,ii)],'-r','Linewidth',1.5); end
    if ~isempty(i3)  plot(xlim(),[XX.de(i3,ii) XX.de(i3,ii)],'--r','Linewidth',1.5); end
    title([num2str(XX.year(ii)),'/',num2str(ii)]);
    ii=ii+1;
end
iprof = iprof+4;


