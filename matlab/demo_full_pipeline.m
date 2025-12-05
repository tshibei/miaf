%% demo_full_pipeline.m - Demonstration of pipeline with example raw EEG and HFO events
%
% This script demonstrates the full HFO analysis pipeline using example data.
% It performs EEG preprocessing and HFO classification steps.
% The HFO detection step is skipped here, as example HFO events are provided.
%
% Steps:
%   1. Preprocess raw EEG data by applying referencing and filtering.
%   2. (Skipped) Detect HFO events from preprocessed EEG.
%   3. Classify HFO events using a pretrained model.
%
% Input files:
%   - Raw EEG at 'example_raw_eeg.mat' in 'input_data' folder
%   - Channel information at 'example_channel_info.mat' in 'input_data' folder
%   - Sampling rate at 'example_sampling_rate.mat' in 'input_data' folder
%   - Detected HFO events at 'example_hfo_event_features.mat' in
%     'input_data' folder
% 
% Output files:
%   - Preprocessed EEG saved as 'example_preprocessed_eeg.mat' in 'outputs' folder
%   - Preprocessed channel information saved as 'example_preprocessed_channel_info.mat' in 'outputs' folder
%   - Feature matrix saved as 'example_hfo_event_features.mat' in 'outputs' folder
%   - Classification results saved as 'example_classified_hfo_events.csv' in 'outputs' folder
%
% Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
% Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

clear; clc;

%% Step 1: EEG Preprocessing

preprocess_eeg_for_hfo_detection( ...
    'input_data_dir',                 'input_data', ...
    'raw_eeg_file',                   'example_raw_eeg.mat', ...
    'channel_info_file',              'example_channel_info.mat', ...
    'sampling_rate_file',             'example_sampling_rate.mat', ...
    'output_dir',                     'outputs', ...
    'preprocessed_eeg_file',          'example_preprocessed_eeg.mat', ...
    'preprocessed_channel_info_file', 'example_preprocessed_channel_info.mat');

%% Step 2: HFO Detection

% This step is skipped in the demonstration as the HFO events are provided.
disp("--- Step 2: HFO Detection (skipped) ---");

%% Step 3: HFO Classification

classify_events( ...
    'input_data_dir', 'input_data', ...
    'detected_hfo_events_file', 'example_detected_hfo_events.mat', ...
    'sampling_rate_file', 'example_sampling_rate.mat', ...
    'model_dir', 'model', ...
    'model_file', 'model.json', ...
    'output_dir', 'outputs', ...
    'preprocessed_eeg_file', 'example_preprocessed_eeg.mat', ...
    'preprocessed_channel_info_file', 'example_preprocessed_channel_info.mat', ...
    'classified_hfo_events_file', 'example_classified_hfo_events.csv', ...
    'hfo_event_features_file', 'example_hfo_event_features.mat');

disp( 'HFO classification pipeline completed successfully.' );