function preprocess_eeg_for_hfo_detection( varargin )
%PREPROCESS_EEG_FOR_HFO_DETECTION Preprocess raw EEG for HFO detection.
%
% This function loads raw EEG data and associated metadata, validates all
% inputs, and generates preprocessed EEG suitable for downstream
% high-frequency oscillation (HFO) detection and feature extraction.
%
% Processing steps:
%   1. Validates existence and formatting of all input files and variables.
%   2. Ensures raw EEG matrix is organized as time × channels.
%   3. Converts channel index fields to int32 and validates integer format.
%   4. Applies common average referencing (CAR), filtering, and preprocessing.
%   5. Saves preprocessed EEG and channel metadata to the output directory.
% 
% All inputs are provided as name-value pairs.
%
% Required name-value pair arguments:
%   'input_data_dir'                  - Path to directory containing input .mat files
%   'raw_eeg_file'                    - Filename of raw EEG .mat file (must contain variable `data`)
%   'channel_info_file'               - Filename of channel info .mat file
%   'sampling_rate_file'              - Filename of sampling rate .mat file (must contain variable `fs`)
%   'output_dir'                      - Path to directory for output files
%   'preprocessed_eeg_file'           - Output filename for preprocessed EEG .mat file
%   'preprocessed_channel_info_file'  - Output filename for preprocessed channel info .mat file
%
% Input file requirements:
%   Raw EEG file must contain:
%       - data : numeric matrix of size [time × channels]
%
%   Channel info file must contain:
%       - ecog_chan_idx  : 1-based indices of ECoG channels, or empty array []
%       - depth_chan_idx : 1-based indices of depth (SEEG) channels, or empty array []
%
%   Sampling rate file must contain:
%       - fs : sampling rate in Hz (float)
% 
% Output files:
%   - Preprocessed EEG data saved as a .mat file specified by 'preprocessed_eeg_file'
%   - Preprocessed channel information saved as a .mat file specified by 'preprocessed_channel_info_file'
%
% Example:
%   preprocess_eeg_for_hfo_detection( ...
%       'input_data_dir',                  'input_data', ...
%       'raw_eeg_file',                    'raw_eeg.mat', ...
%       'channel_info_file',               'channel_info.mat', ...
%       'sampling_rate_file',              'sampling_rate.mat', ...
%       'output_dir',                      'outputs', ...
%       'preprocessed_eeg_file',           'preprocessed_eeg.mat', ...
%       'preprocessed_channel_info_file',  'preprocessed_channel_info.mat' );
%
% Dependencies:
%   - validateAndCheckType.m
%   - validateAndConvertIntFields.m
%   - run_hfo_preprocessing.m
% 
%   Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
%   Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

disp("--- Step 1: EEG Preprocessing ---")
stepStart = tic;

%% Verify parameters
p = inputParser;

addParameter( p, 'input_data_dir', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'raw_eeg_file', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'channel_info_file', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'sampling_rate_file', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'output_dir', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'preprocessed_eeg_file', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'preprocessed_channel_info_file', [], @(x) ischar(x) || isstring(x) );

parse( p, varargin{:} );
args = p.Results;

% Enforce that all required parameters are provided
required_fields = fieldnames( args );
for i = 1:numel( required_fields )
    if isempty( args.(required_fields{i}) )
        error( 'Missing required parameter: %s', required_fields{i} );
    end
end

%% Setup paths
addpath( genpath('preprocessing')  );
addpath( genpath('features')       );
addpath( genpath('classification') );
addpath( genpath('requirements')   );
addpath( genpath('utils')          );

%% Load and validate data
% Load and validate raw EEG
raw_eeg_filepath = fullfile( '..', args.input_data_dir, args.raw_eeg_file );
raw_eeg = validateAndCheckType( raw_eeg_filepath, 'data', 'numeric');

% Check dimensions of raw EEG data
if size(raw_eeg, 1) < size(raw_eeg, 2)
    error('The number of time points (rows) must be greater than the number of channels (columns).');
end

% Load and validate sampling rate
sampling_rate_filepath = fullfile( '..', args.input_data_dir, args.sampling_rate_file );
fs = validateAndCheckType( sampling_rate_filepath, 'fs', 'float');

% Load and validate channel info struct
channel_info_filepath = fullfile( '..', args.input_data_dir, args.channel_info_file );
channel_info = validateAndConvertIntFields( channel_info_filepath,  {'ecog_chan_idx', 'depth_chan_idx'});

%% Preprocess data HFO detection
run_hfo_preprocessing( ...
    raw_eeg, fs, channel_info, args.output_dir, ...
    args.preprocessed_eeg_file, args.preprocessed_channel_info_file );

fprintf('Done in %.3f seconds.\n', toc(stepStart));

end
