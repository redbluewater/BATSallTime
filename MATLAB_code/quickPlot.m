

% gscatter(uniqueCruises.month,uniqueCruises.MLDmax,uniqueCruises.year,...
%     parula(length(unique(uniqueCruises.year))),[],10)

%consider what happens for each year
uy = unique(uniqueCruises.year);

for a = 3
    k = find(uniqueCruises.year == uy(a));
    
    gscatter(uniqueCruises.month(k),uniqueCruises.MLDmax(k),uniqueCruises.cruise(k),...
        parula(length(k)),[],20)
    hold on
    gscatter(uniqueCruises.month(k),uniqueCruises.maxDCMallTime(k),uniqueCruises.cruise(k),...
        'g',[],20)
    
    
end
clear a