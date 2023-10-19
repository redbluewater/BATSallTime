function [ Xfilt, bias ] = smooth_fluor(CTD, filt_width )
% Applies a 3rd order butterworth filter to the fluorometer profile.
%  
%   
 Xfilt = CTD.Fluor;
 bias = 0;
 
 igood = find(CTD.Pressure > 0 & CTD.Fluor > -990 & ~isnan(CTD.Fluor) & ~isnan(CTD.Pressure));
 if length(igood) < 10
     disp('Not enough points to filter Fluor profile')
     return
 end
 pvec = CTD.Pressure(igood);
 xvec = CTD.Fluor(igood);
 
 [b,a] = butter(3,1/filt_width);
 Xfilt(igood) = filtfilt(b,a,xvec);

 indx= find(CTD.Pressure > 400 & CTD.Pressure < 600);
 if ~isempty(indx)
     bias = nanmean(Xfilt(indx));
 end
end

