function data_filt = apply_filter(Hd, data)
%APPLY_FILTER Apply zero-phase digital filter using SOS representation.
%
% data_filt = apply_filter(Hd, data)
%
% Applies a zero-phase digital filter to the input data using the
% second-order sections representation.
%
% Inputs:
%   Hd    - Digital filter object containing fields:
%             - sosMatrix: second-order section coefficients
%             - ScaleValues: scaling values for the filter
%   data  - 1D or 2D numeric array of signal data (time x channels or vector)
%
% Output:
%   data_filt - Filtered data of the same size as input
%
% Example usage:
%   Hd = design(...);                 % create filter
%   filtered = apply_filter(Hd, raw_eeg); % apply filter
%
% Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
% Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

data_filt = filtfilt(Hd.sosMatrix, Hd.ScaleValues, data);

end