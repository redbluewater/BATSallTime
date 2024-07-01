function [ theCode] = label_seasons_ctd(CTD,DCM,mld, trans_dates )
% function [ theCode] = add_seasons(CTD,DCM,mld,trans )
%   Assigns a season code based on depth of DCM and mld
%INPUT
% CTD : struct containing a single BIOSSCOPE CTD cast 
% DCM : struct containing depth, chlor_val, itop, ibot, de_top,de_bot
% mld : the mld depth to use
% trans_dates can be [] or a struct with fields:
%    .mixed  (n x 2 array of start/end dates)  
%    .spring 
%    .strat
%    .fall
%OUTPUT
% theCode:
%   1 :  Mixed  begins when top of CM layer no longer defined
%   2 :  Spring begins first day MLD shoals above top of CM layer
%   3 :  Strat  begins when MLD is consistently above top of CM
%   4 :  Fall   begins when MLD first goes below top of CM 
%
% Ruth Curry, BIOS / ASU
% Uploaded for BIOS-SCOPE project 19 October 2023
%
%KL editing - can have no MLD if the cast starts out too deep to calculate
%an MLD (See BATS cruise #220 as an example - BATS20220, first depth is
%10.5m); change the code to send out a NaN for season if this happens
%%save Ruth's script as: label_seasons_ctd_Ruth_v0.m
%%KL working here without the added version information so the file names
%%do not change
%KL 13 June 2024

mtime = decyear2dnum(CTD.decy(1));

%can use pre-defined dates to set the season (this comes from analysis of
%the glider data so is only available for a limited amount of time)
if isstruct(trans_dates)  % check the date of cast against the dates provided
    
    TD=trans_dates.mixed;
    [ndates,~] = size(TD);
    for ii=1:ndates
        if mtime >= TD(ii,1) && mtime < TD(ii,2)
            theCode = 1;
            return
        end
    end
    
    TD=trans_dates.spring;
    [ndates,~] = size(TD);
    for ii=1:ndates
        if mtime >= TD(ii,1) && mtime < TD(ii,2)
            theCode = 2;
            return
        end
    end
    
    TD=trans_dates.strat;
    [ndates,~] = size(TD);
    for ii=1:ndates
        if mtime >= TD(ii,1) && mtime < TD(ii,2)
            theCode = 3;
            return
        end
    end
    TD=trans_dates.fall;
    [ndates,~] = size(TD);
    for ii=1:ndates
        if mtime >= TD(ii,1) && mtime < TD(ii,2)
            theCode = 4;
            return
        end
    end
end %if (trans_dates)

%  if reach here, use mld / DCM / month to assign a season
[~,M,~] = datevec(mtime);

%The DCM will not be defined if there is no fluorescence data. In this 
%case CTD.Fluor will be all NaN. If that happens, set theCode (season) 
%to NaN; KL 14 June 2024
d = ~isnan(CTD.Fluor); %check - is this all NaN?
if sum(double(d))==0 %will sum to 0 if all NaN in fluorescence data
    theCode = NaN;
    return
elseif isnan(DCM.itop) && isequal(mld,-999) %no DCM and no MLD
    theCode = NaN; %set season to NaN;  KL 14 June 2024
    return
elseif isnan(DCM.itop)  % DCM not defined (but data are available)
    theCode = 1;  
    if M >= 12 && M < 4
        return        %mixed
    end
    if M >=4 && M <= 5 && mld > 30
        theCode = 2;  % spring
    end
    if M >=10 && M <=12 && mld < 100 %KL note - I don't think you can get here in December (see line 88)
        theCode = 4;  %fall
    end
end

%
if ~isnan(DCM.itop)  %DCM is defined, not mixed
    
    theCode = 3;   %assume it is strat
    if M >=6 && M < 10  
        return   % Jun - Sep  definitely strat
    end
    
    if M >=3 && M < 6   %Mar - May
        %add another step here - if there is no mld, set theCode to NaN
        %(hence setting season to NaN); KL 6/13/2024
       if isequal(mld,-999)
           theCode = NaN;
           return
       elseif mld < 100 && mld > 30
          theCode = 2;    %spring
          return
       end  
    end
    
    if isequal(mld,-999)
       theCode = NaN;
    elseif M >=10 && M < 12 && mld < 100
        theCode = 4;  % fall
        return
    end
end

end

