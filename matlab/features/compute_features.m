function features = compute_features( hfo_raw, hfo_filt, car_raw, car_filt, fs )
%% features = compute_features( hfo_raw, hfo_filt, car_raw, car_filt )
%
% This function is the main entry point for computing features and takes 5
% inputs:
%
% - hfo_raw: the waveform for the HFO, after referencing but before
% filtering.
%
% - hfo_filt: the waveform for the HFO, filtered from 80-500 Hz.
%
% - car_raw: the common average reference waveform at the same time as the
% HFO detection, after referencing but before filtering.
%
% - car_filt: the common average reference waveform at the same time as the
% HFO detection, filtered from 80-500 Hz.
%
% - fs: sampling rate in Hz.
%
% Originally written by S. Gliske (sgliske@unmc.edu) 2017-2024
% Transcribed to Matlab by S. Gliske in 2025
% Copyright © 2025 by S. Gliske is licensed under CC BY-NC 4.0

%% check inputs

narginchk( 5, 5 );
mustBeVector( hfo_raw );
mustBeVector( hfo_filt );
mustBeVector( car_raw );
mustBeVector( car_filt );
assert(isscalar(fs));
fs = double(fs);

n = length( hfo_raw );
assert( length(hfo_filt) == n );
assert( length(car_raw) == n );
assert( length(car_filt) == n );

%% compute the features

temp_features = cell(4,1);
temp_features{1} = add_prefix( 'hfo', compute_features_filt( hfo_filt, fs ) );
temp_features{2} = add_prefix( 'hfo', compute_features_raw( hfo_raw, fs ) );
temp_features{3} = add_prefix( 'car', compute_features_filt( car_filt, fs ) );
temp_features{4} = add_prefix( 'car', compute_features_raw( car_raw, fs ) );

%% merge

features = struct();
for i = 1:length(temp_features)
    fn = fieldnames(temp_features{i});
    fn(strcmp(fn, 'car_duration')) = []; % remove duplicated feature value
    for j = 1:length(fn)
        features.(fn{j}) = temp_features{i}.(fn{j});
    end
end
