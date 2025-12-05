function save_classification_results( events, labels, scores, model, ...
    preprocessed_channel_info, output_dir, classified_hfo_events_file )
%SAVE_CLASSIFICATION_RESULTS Save HFO classification outputs to a CSV file.
%
% save_classification_results( events, labels, scores, model, preprocessed_channel_info, ...
%    output_dir, classified_hfo_events_filename )
% 
% Saves HFO classification results to a CSV file in the "{output_dir}/" folder.
%
% Steps:
%   - Ensure the "{output_dir}/" directory exists or creates it.
%   - Constructs a table with event indices, classification labels, and scores.
%   - Dynamically name the binary classification column based on the threshold.
%   - Save the table to "{output_dir}/{classified_hfo_events_file}.csv".
%
% Inputs:
%   events     - Struct containing validated and standardized HFO event fields.
%   labels     - Logical or binary vector (0 or 1) indicating whether each event
%                is classified as an HFO (1) or artifact (0) based on model threshold.
%   scores     - Vector of predicted probabilities or confidence scores for each event.
%   model      - Struct containing classification model parameters
%   preprocessed_channel_info  - Struct containing channel info and quality mask
%   output_dir - String containing folder name for saving output results
%   classified_hfo_events_file - String containing file name for saving output results
% 
% Outputs:
%   Writes a CSV file to:
%       {output_dir}/{classified_hfo_events_file}
%
%   The CSV contains the following columns:
%       - start_idx      : Sample index of event start
%       - end_idx        : Sample index of event end
%       - chan_idx       : Channel index of the event
%       - is_HFO_thresh_X_XX : Binary classification column where X_XX is the
%                              model threshold (e.g., is_HFO_thresh_0_95)
%       - prob_HFO       : Predicted probability that event is an HFO
%       - is_bad_chan    : True if event occurs on a bad channel
%       - is_nan_event   : True if label or score is NaN
%
% Example:
%   save_classification_results( events, predicted_labels, probabilities, ...
%      model, preprocessed_channel_info, output_dir, classified_hfo_events_file );
%
% Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
% Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

% Ensure results/ folder exists
if ~exist( fullfile('..', output_dir), 'dir' )
    mkdir( fullfile('..', output_dir) );
end

% Get threshold
threshold  = model.threshold;

% Format threshold
thresh_str = strrep( sprintf('%.2f', threshold), '.', '_' );

% Construct column name: 'is_HFO_thresh_{threshold}'
is_HFO_colname = [ 'is_HFO_thresh_' thresh_str ];

% Get bad channels
bad_chan_mask = ~preprocessed_channel_info.good_chan_mask;
is_bad_chan = bad_chan_mask(events.chan_idx);

% Set labels and scores as NaN for HFOs on bad channels
labels(is_bad_chan) = NaN;
scores(is_bad_chan) = NaN;

% Define NaN label or score as NaN event
is_nan_event = isnan(labels) | isnan(scores);

T = table( events.start_idx(:), ...
    events.end_idx(:), ...
    events.chan_idx(:), ...
    labels(:), ...
    scores(:), ...
    is_bad_chan(:), ...
    is_nan_event(:), ...
    'VariableNames', ...
    { 'start_idx', 'end_idx', 'chan_idx', is_HFO_colname, 'prob_HFO', 'is_bad_chan', 'is_nan_event' } );

writetable( T, fullfile('..', output_dir, classified_hfo_events_file) );
fprintf('Results saved to %s\n', fullfile('..', output_dir, classified_hfo_events_file));

end