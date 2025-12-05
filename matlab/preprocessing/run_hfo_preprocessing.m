function run_hfo_preprocessing( ...
    raw_eeg, fs, channel_info, output_dir, ...
    preprocessed_eeg_file, preprocessed_channel_info_file )
%RUN_HFO_PREPROCESSING Preprocess EEG for HFO detection.
%
% This function applies preprocessing steps required for high-frequency
% oscillation (HFO) detection, including:
%   - Detection of good-quality channels
%   - Common average referencing (CAR) for ECoG and depth channels
%   - Bandpass filtering between 80–500 Hz
%   - Export of preprocessed EEG and updated channel metadata
% 
% Inputs:
%   raw_eeg        - Numeric matrix of raw EEG signals [time × channels]
%   fs             - Sampling frequency in Hz (scalar)
%   channel_info   - Struct containing channel indices with fields:
%                     .ecog_chan_idx   : ECoG channel indices (1-based, vector or [])
%                     .depth_chan_idx  : Depth (SEEG) channel indices (1-based, vector or [])
%   output_dir     - Output directory path (string)
%   preprocessed_eeg_file - Filename for preprocessed EEG output (.mat)
%   preprocessed_channel_info_file - Filename for preprocessed channel info (.mat)
%
% Outputs:
%   1. Preprocessed EEG file:
%      Saved as: {output_dir}/{preprocessed_eeg_file}
%      Variables:
%         ecog_hfo_raw   - CAR-referenced ECoG signals (raw)
%         ecog_car_raw   - ECoG common average reference signal
%         ecog_hfo_filt  - Filtered ECoG signals (80–500 Hz)
%         ecog_car_filt  - Filtered ECoG CAR signal
%         depth_hfo_raw  - CAR-referenced depth signals (raw)
%         depth_car_raw  - Depth common average reference signal
%         depth_hfo_filt - Filtered depth signals (80–500 Hz)
%         depth_car_filt - Filtered depth CAR signal
%
%   2. Preprocessed channel info file:
%      Saved as: {output_dir}/{preprocessed_channel_info_file}
%      Variables:
%         ecog_chan_idx   - Original ECoG channel indices
%         depth_chan_idx  - Original depth channel indices
%         good_chan_mask  - Logical vector indicating valid channels
%                            (true = good, false = bad)
%
% Example:
%   run_hfo_preprocessing( ...
%       raw_eeg, fs, channel_info, 'outputs', ...
%       'preprocessed_eeg.mat', 'preprocessed_channel_info.mat' );
%
% Dependencies:
%   - invalid_epoch_detector.m
%   - cauerfilt.m
%   - apply_filter.m
%
% Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
% Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

ecog_chan_idx   = channel_info.ecog_chan_idx;
depth_chan_idx  = channel_info.depth_chan_idx;

% Detect good channels (logical mask)
bad_chan_mask = invalid_epoch_detector( raw_eeg, fs );
good_chan_mask = ~bad_chan_mask;

% CAR referencing for ECoG
if ~isempty( ecog_chan_idx )
    ecog_good    = ecog_chan_idx( good_chan_mask(ecog_chan_idx) );
    ecog_car_raw = mean( raw_eeg(:, ecog_good), 2 );
    ecog_hfo_raw = raw_eeg(:, ecog_chan_idx) - ecog_car_raw;
else
    ecog_hfo_raw = [];
    ecog_car_raw = [];
end

% CAR referencing for Depth
if ~isempty(depth_chan_idx)
    depth_good    = depth_chan_idx( good_chan_mask(depth_chan_idx) );
    depth_car_raw = mean( raw_eeg(:, depth_good), 2 );
    depth_hfo_raw = raw_eeg(:, depth_chan_idx) - depth_car_raw;
else
    depth_hfo_raw = [];
    depth_car_raw = [];
end

% Filter design
Hd = cauerfilt( 80, 500, fs );

% Filtering ECoG data
if ~isempty( ecog_chan_idx )
    ecog_car_filt = apply_filter( Hd, ecog_car_raw );
    ecog_hfo_filt = apply_filter( Hd, ecog_hfo_raw );
else
    ecog_car_filt = [];
    ecog_hfo_filt = [];
end

% Filtering Depth data
if ~isempty( depth_chan_idx )
    depth_car_filt = apply_filter( Hd, depth_car_raw );
    depth_hfo_filt = apply_filter( Hd, depth_hfo_raw );
else
    depth_car_filt = [];
    depth_hfo_filt = [];
end

% Save variables
out_path = fullfile('..', output_dir);
save( fullfile(out_path, preprocessed_eeg_file), ...
    'ecog_hfo_raw', 'ecog_car_raw', 'ecog_hfo_filt', 'ecog_car_filt', ...
    'depth_hfo_raw', 'depth_car_raw', 'depth_hfo_filt', 'depth_car_filt', ...
    '-v7.3' );
save( fullfile(out_path, preprocessed_channel_info_file), ...
    'ecog_chan_idx', 'depth_chan_idx', 'good_chan_mask' );

fprintf('Preprocessed EEG saved in %s\n', ...
    fullfile(out_path, preprocessed_eeg_file));
fprintf('Channel information saved in %s\n', ...
    fullfile(out_path, preprocessed_channel_info_file));

end