function invalid = invalid_epoch_detector( data, fs )
%% function invalid = invalid_epoch_detector( data, fs )
%
% This function assess the data quality of the input data matrix (assumed
% to come from a single epoch of data) and returns a logical vector
% indicating which channels have invalid data
%
% Inputs
% - data: a <num_samples> x <num_channels> matrix
% - fs: the sampling rate
%
% It is expected that the number of samples will correspond to 10 minutes
% of data.  The data should be the raw data, referenced to the reference
% electrode (not bipolar, not common average reference, not filtered).
%
% Output valid: a <num_channels> x 1 logical vector indicating which
% channels are extimated to have invalid data (true values) versus those
% with sufficient data quality (false values).
%
% Originally written by S. Gliske (sgliske@unmc.edu) 2024
% Transcribed from C++ to Matlab by S. Gliske in 2025
% Copyright © 2025 by S. Gliske is licensed under CC BY-NC 4.0


%% check inputs

mustBeFloat( data );
[num_samples, num_channels] = size( data );
assert(num_samples > num_channels, 'data should have more samples than channels');
if( numel(data) == 0 )
    invalid = true(num_channels,0);
    return;
end

% Ensure fs is a non-empty scalar float
if ~isfloat( fs )
    fs = double( fs );   % auto-convert integer or other numeric types to double
end
mustBeFloat( fs );
mustBeScalarOrEmpty( fs );
assert( ~isempty(fs) );

%% fixed parameters

mad_multiplier = 10;
overall_threshold = 0.050;
window_width_in_seconds = 6.0;
window_threshold = 0.50;
diff_threshold = 0.80;

%% scaled parameters

window_width = floor(window_width_in_seconds * fs);
num_critical_overall = num_samples * overall_threshold;
num_critical_window  = window_width * window_threshold;
num_critical_diff    = window_width * diff_threshold;

%% compute acceptible range

nChan = size(data,2);
mu = zeros(1,nChan);
sigma = zeros(1,nChan);
parfor i=1:nChan
  mu(i) = median(data(:,i));
  sigma(i) = median( abs( data(:,i) - mu(i) ) ); % mad
end

low_thres  = mu - mad_multiplier * sigma;
high_thres = mu + mad_multiplier * sigma;

%% total number of out range values per channel

out_of_range = data > high_thres | data < low_thres;
num_outliers_overall = sum( out_of_range );

%% max number out of range per window, per channel

% compute the number of outliers per window, and then select the highest
% for each channel
num_epochs = floor( num_samples / window_width );
num_outliers_window = max(squeeze(sum(reshape( out_of_range(1:num_epochs*window_width,:), window_width, num_epochs, num_channels ))));

%% total number of out of range changes per channel

temp = abs(diff(data));
temp_median = zeros(1,size(temp,2));
parfor i=1:size(temp,2)
  temp_median(i) = median(temp(:,i));
end

diff_out_of_range = temp < temp_median;
num_outliers_diff = max(squeeze(sum(reshape( [diff_out_of_range(1:num_epochs*window_width-1,:);nan(1,size(diff_out_of_range,2))], window_width, num_epochs, num_channels ))));

%% compute invalid

invalid = ...
    num_outliers_overall > num_critical_overall | ...
    num_outliers_window  > num_critical_window | ...
    num_outliers_diff    > num_critical_diff;

invalid = invalid';

%% all done!
