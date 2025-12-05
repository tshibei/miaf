function classify_events( varargin )
%CLASSIFY_EVENTS Classify detected HFO events using a pre-trained model.
%
% This function loads detected HFO events and preprocessed EEG data,
% extracts HFO features, applies a pre-trained logistic regression model,
% and saves classification results and feature matrices to disk.
%
% Processing pipeline:
%   1. Load and validate detected HFO events.
%   2. Load sampling rate.
%   3. Load pre-trained classification model (fixed).
%   4. Load preprocessed EEG and channel metadata.
%   5. Extract feature matrix for all HFO events.
%   6. Apply logistic regression classifier.
%   7. Save classification results to CSV and feature matrix to .mat.
% 
% All inputs are provided as name-value pairs.
%
% Required name-value pair arguments:
%   'input_data_dir'                  - Directory containing input data files
%   'detected_hfo_events_file'        - Filename of detected HFO events (.mat)
%   'sampling_rate_file'              - Filename of sampling rate file (.mat, must contain `fs`)
%   'model_dir'                       - Directory containing the classification model
%   'model_file'                      - Model filename (e.g., model.json)
%   'output_dir'                      - Directory for output files
%   'preprocessed_eeg_file'           - Filename of preprocessed EEG data (.mat)
%   'preprocessed_channel_info_file'  - Filename of preprocessed channel info (.mat)
%   'classified_hfo_events_file'      - Output CSV filename for classification results
%   'hfo_event_features_file'         - Output .mat filename for extracted feature matrix
%
% Input data requirements:
%   Detected HFO events file must contain:
%       - start_idx : 1-based start indices for HFO events
%       - end_idx   : 1-based end indices for HFO events
%       - chan_idx  : 1-based channel indices corresponding to each event
%
%   Sampling rate file must contain:
%       - fs : Sampling rate in Hz (numeric scalar)
%
% Output files:
%   1. Classification results CSV:
%      Saved as: {output_dir}/{classified_hfo_events_file}
%      Contains predicted labels and probabilities for each HFO event.
%
%   2. Feature matrix file:
%      Saved as: {output_dir}/{hfo_event_features_file}
%      Contains features of each HFO event.
%
% Example usage:
%   classify_events( ...
%       'input_data_dir',                  'input_data', ...
%       'detected_hfo_events_file',        'detected_hfo_events.mat', ...
%       'sampling_rate_file',              'sampling_rate.mat', ...
%       'model_dir',                       'model', ...
%       'model_file',                      'model.json', ...
%       'output_dir',                      'outputs', ...
%       'preprocessed_eeg_file',           'preprocessed_eeg.mat', ...
%       'preprocessed_channel_info_file',  'preprocessed_channel_info.mat', ...
%       'classified_hfo_events_file',      'classified_hfo_events.csv', ...
%       'hfo_event_features_file',         'hfo_event_features.mat' );
%
% Dependencies:
%   validateAndConvertIntFields.m
%   validateAndCheckType.m
%   load_and_validate_model.m
%   extract_hfo_features.m
%   classify_hfos.m
%   save_classification_results.m
%
%   See also: load_and_validate_events, load_and_validate_model, extract_hfo_features, classify_hfos, save_classification_results
%
% Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
% Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

disp("--- Step 3: HFO Classification ---")
stepStart = tic;

%% Verify parameters
p = inputParser;

% Add all required parameters (no defaults)
addParameter( p, 'input_data_dir', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'detected_hfo_events_file', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'sampling_rate_file', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'model_dir', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'model_file', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'output_dir', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'preprocessed_eeg_file', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'preprocessed_channel_info_file', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'classified_hfo_events_file', [], @(x) ischar(x) || isstring(x) );
addParameter( p, 'hfo_event_features_file', [], @(x) ischar(x) || isstring(x) );

parse( p, varargin{:} );
args = p.Results;

% Enforce that all required parameters are provided
required_fields = fieldnames( args );
for i = 1:numel( required_fields )
    if isempty( args.(required_fields{i}) )
        error( 'Missing required parameter: %s', required_fields{i} );
    end
end

%% Load and validate HFO events

% Define path to HFO events file
detected_hfo_events_filepath = fullfile( '..', args.input_data_dir, args.detected_hfo_events_file );

% Load and validate events struct
events = validateAndConvertIntFields( detected_hfo_events_filepath, {'start_idx', 'end_idx', 'chan_idx'});

%% Load and validate sampling rate
sampling_rate_filepath = fullfile( '..', args.input_data_dir, args.sampling_rate_file );
fs = validateAndCheckType( sampling_rate_filepath, 'fs', 'float');

%% Load and validate model (fixed)

% Model is fixed and provided — do not change unless updating the model
model_filepath = fullfile( '..', args.model_dir, args.model_file );
model = load_and_validate_model( model_filepath );

%% Load and validate preprocessed data
% Load preprocessed eeg and channel info
preprocessed_eeg_filepath = fullfile( '..', args.output_dir, args.preprocessed_eeg_file );
preprocessed_eeg = load( preprocessed_eeg_filepath );

% Assert that each field in preprocessed_eeg is [time x channel] by 
% checking if they are either empty or size(1) > size(2)
field_names = fieldnames(preprocessed_eeg);
for i = 1:numel(field_names)
    data = preprocessed_eeg.(field_names{i});
    if isempty(data)
        continue;  % Empty is allowed
    end

    assert(size(data, 1) > size(data, 2), ...
        'Field ''%s'' must have size(1) > size(2), got size [%d, %d]', ...
        field_names{i}, size(data, 1), size(data, 2));
end

preprocessed_channel_info_filepath = fullfile('..', args.output_dir, args.preprocessed_channel_info_file);
preprocessed_channel_info = validateAndConvertIntFields( preprocessed_channel_info_filepath, {'ecog_chan_idx', 'depth_chan_idx'} );
% Validate that good_chan_mask is boolean
if ~islogical(preprocessed_channel_info.good_chan_mask)
    error('Field ''good_chan_mask'' must be a logical array.');
end

%% Feature extraction
X = extract_hfo_features( preprocessed_eeg, fs, events, preprocessed_channel_info, model.features );
save( fullfile('..', args.output_dir, args.hfo_event_features_file), 'X' ); % save features for optional classification in python
fprintf('Features saved to %s\n', fullfile('..', args.output_dir, args.hfo_event_features_file));

%% Classification

[ labels, scores ] = classify_hfos( X, model );

%% Save Results

save_classification_results( ...
    events, ...
    labels, ...
    scores, ...
    model, ...
    preprocessed_channel_info, ...
    args.output_dir, ...
    args.classified_hfo_events_file );

fprintf('Done in %.3f seconds.\n', toc(stepStart));

