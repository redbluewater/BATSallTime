function [theCode] = label_seasons_ctd_KL_v2(DCMdepth,DCMdepthTop,DCMinML,mld,priorSeason,timeStep_days,month)
% function [theCode] = label_seasons_ctd_KL_v2(DCMdepth,DCMdepthTop,DCMinML,mld,priorSeason,timeStep_days,month)
%   Assigns a season code based on depth of DCM and mld
%INPUT
% DCM : struct containing depth, chlor_val, itop, ibot, de_top,de_bot
% mld : the mld depth to use
%OUTPUT
% theCode:
%   1 :  Mixed  begins when top of CM layer no longer defined
%   2 :  Spring begins first day MLD shoals above top of CM layer
%   3 :  Strat  begins when MLD is consistently above top of CM
%   4 :  Fall   begins when MLD first goes below top of CM 
%
% Original ideas from Ruth Curry, BIOS / ASU
% Uploaded for BIOS-SCOPE project 19 October 2023
% KL changing the logic for each month, but retain Ruth's framework
% KL 1 July 2024
% KL changing to be more strict, still based on Ruth's framework but only
% allow one month for spring spring and one month for fall transition.
% There is certainly a more elegant way to do this, but let's use this hack
% for now

M = month;
%essentially have three options, so setup three if statements:
tsAllow = 45; %may need to optimize this
theCode = NaN; %assume no season
% if timeStep_days is more than 45 days, calculate from the beginning - too far ahead to be useful
    if isnan(priorSeason) || isnan(timeStep_days) || timeStep_days >= tsAllow
        %just calculate? define based on month?
        if (mld < DCMdepthTop) && (M > 2 && M < 6)
            theCode = 2;
        elseif (mld < DCMdepthTop) && (M >= 5 && M < 8)
            theCode = 3;
        elseif (mld > DCMdepthTop) && (M >=9 && M <=12)
            theCode = 4;
        elseif (mld > DCMdepthTop) && (M >=1 && M <=4)
            theCode = 1;
        elseif DCMinML==1  && (M >=1 && M <=4) %DCM is not defined because it's in the ML
            theCode = 1;
        elseif DCMinML==1 && (mld < DCMdepth) && (M>=5 && M<=10)
            theCode = 3;
        elseif DCMinML==1
            %keyboard
        elseif isnan(DCMdepthTop) || isnan(DCMdepth)
            theCode = NaN;
        end
    elseif (mld < DCMdepthTop) && ~isnan(priorSeason) && timeStep_days < tsAllow && (M>=4 && M<=10)
        %make a decision partly based on what the prior time step was 
        if isequal(priorSeason,2)
            theCode = 3;
        elseif isequal(priorSeason,3)
            theCode = 3;
        elseif isequal(priorSeason,1)
            theCode = 2;
        end
    elseif (mld > DCMdepthTop) && ~isnan(priorSeason) && timeStep_days < tsAllow
        if isequal(priorSeason,4)
            theCode = 1;
        elseif isequal(priorSeason,1)
            theCode = 1;
        elseif isequal(priorSeason,3) && (M >=9 ) %add months so we don't get fall in the middle of summer
            theCode = 4;
        elseif isequal(priorSeason,3) && (M >= 6 && M < 9)
            theCode = 3;
        end
    elseif DCMinML==1 && ~isnan(priorSeason) && timeStep_days < tsAllow
        if isequal(priorSeason,4)
            theCode = 1;
        elseif isequal(priorSeason,1)
            theCode = 1;
        end        
    elseif isnan(DCMdepthTop) && isnan(DCMinML)
        theCode = NaN;
    end %end if statements

     if ~exist('theCode')
         keyboard
     end



end%end function

