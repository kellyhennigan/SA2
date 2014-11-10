% 
function snr = temporalSNR(data)


% regress out a line for each voxel's time series

% get the median of the absolute value of the difference between successive
% time-points

% divide it by the mean of the time series & multiply by 100

for each EPI run, we compute the temporal SNR.  this is performed by regressing
%     out a line from each voxel's time-series, computing the absolute value of the
%     difference between successive time points, computing the median of these absolute
%     differences, dividing the result by the mean of the original time-series, and then
%     multiplying by 100.  negative values (which result when the mean is negative) are
%     explicitly set to NaN.  we write out the temporal SNR as figures for inspection,
%     using MATLAB's jet colormap.  high values (red) are good and correspond to a
%     temporal SNR of 0%.  low values (blue) are bad, and correspond to a temporal SNR
%     of 5%.  (note that it would make some sense to take the reciprocal of the computed
%     metric such that the mean signal level is in the numerator, but we leave it as-is
%     since we believe having the median absolute difference in the numerator is simpler.)