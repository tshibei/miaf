function X = extract_hfo_features( preprocessed_data, fs, events, preprocessed_channel_info, features )
%EXTRACT_HFO_FEATURES Extract feature matrix X for HFO event classification.
%
% Computes feature matrix X for HFO events
%
% Inputs:
%   preprocessed_data - struct containing preprocessed EEG data (ECoG and depth)
%   fs              - sampling rate in Hz (float)
%   events       - struct with fields: start_idx, end_idx, chan_idx for each event
%   preprocessed_channel_info    - struct with fields:
%                   - ecog_chan_idx: vector of ECoG channel indices
%                   - depth_chan_idx: vector of depth channel indices
%   features     - cell array of feature names to extract and order
%
% Output:
%   X            - n_samples x n_features matrix of extracted feature values
%
% Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
% Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

n_samples  = numel( events.start_idx );       % Number of HFO events
n_features = numel( features );               % Number of features to extract
X          = zeros( n_samples, n_features );  % Preallocate feature matrix
CAR_CH     = 1;

for i = 1:n_samples
    ch = events.chan_idx(i); % Get channel for current event

    assert( ismember(ch, preprocessed_channel_info.ecog_chan_idx) || ismember(ch, preprocessed_channel_info.depth_chan_idx), ...
    'Error: ch must be a member of either preprocessed_channel_info.ecog_chan_idx or preprocessed_channel_info.depth_chan_idx.' );
    
    if ismember( ch, preprocessed_channel_info.ecog_chan_idx )
        ecog_local_idx = find(preprocessed_channel_info.ecog_chan_idx == ch);
        hfo_raw  = extract_segment( preprocessed_data.ecog_hfo_raw, ...
            events.start_idx(i), events.end_idx(i), ecog_local_idx );
        hfo_filt = extract_segment( preprocessed_data.ecog_hfo_filt, ...
            events.start_idx(i), events.end_idx(i), ecog_local_idx );
        car_raw  = extract_segment( preprocessed_data.ecog_car_raw, ...
            events.start_idx(i), events.end_idx(i), CAR_CH ); % CAR: common avg ref
        car_filt = extract_segment( preprocessed_data.ecog_car_filt, ...
            events.start_idx(i), events.end_idx(i), CAR_CH );
    else
        depth_local_idx = find(preprocessed_channel_info.depth_chan_idx == ch);
        hfo_raw  = extract_segment( preprocessed_data.depth_hfo_raw, ...
            events.start_idx(i), events.end_idx(i), depth_local_idx );
        hfo_filt = extract_segment( preprocessed_data.depth_hfo_filt, ...
            events.start_idx(i), events.end_idx(i), depth_local_idx );
        car_raw  = extract_segment( preprocessed_data.depth_car_raw, ...
            events.start_idx(i), events.end_idx(i), CAR_CH );
        car_filt = extract_segment( preprocessed_data.depth_car_filt, ...
            events.start_idx(i), events.end_idx(i), CAR_CH );
    end

    % Compute features from current event
    x_struct = compute_features( hfo_raw, hfo_filt, car_raw, car_filt, fs );

    % Record the order of fields for consistent column ordering
    if i == 1
        x_fields = fieldnames( x_struct );
    end

    % Convert struct of features to vector and assign to X
    x_values  = struct2cell( x_struct );   % Convert to cell array
    x_values  = vertcat( x_values{:} );    % Concatenate values into column
    X(i, :)   = x_values;                  % Store in feature matrix
end

% Reorder columns of X to match requested feature order
[ ~, order_idx ] = ismember( features, x_fields );
X = X(:, order_idx);

end