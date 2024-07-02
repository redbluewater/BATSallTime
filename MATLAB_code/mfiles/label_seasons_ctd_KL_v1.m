function [theCode] = label_seasons_ctd(DCMdepth,DCMdepthTop,mld,month)
% function [theCode] = label_seasons_ctd(DCM,mld,month)
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

M = month;
%easiest to set this up as a series of cases (or least I hope it will be
%easier to follow the logic
    switch M
        case 1
            theCode = 1;
        case 2
            theCode = 1;        
        case 3
            if isnan(DCMdepthTop)
                theCode = 1;
            elseif ~isnan(DCMdepthTop) && (mld < 100 && mld > 30)
                theCode = 2;
            else
                theCode = NaN;
            end
        case 4
            theCode = 2;
        case 5
            theCode = 2;
        case 6
            theCode = 3;
        case 7
            theCode = 3;        
        case 8
            theCode = 3;
        case 9 
            theCode = 3;
        case 10
            theCode = 4;
        case 11
            theCode = 4;
        case 12
            if mld < 100
                theCode=4;
            else
                theCode=1;
            end    
    end %end switch/case
end%end function

