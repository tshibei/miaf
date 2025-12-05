function channel_info = load_and_validate_channel_info(channel_info_file)
%% function channel_info = load_and_validate_channel_info_struct(channel_info_file)
%
%   Loads a .mat file and verifies that the channel info struct contains:
%       - data            : [time x channels] matrix
%       - fs              : sampling frequency (Hz)
%       - ecog_chan_idx   : indices of ECoG channels
%       - depth_chan_idx  : indices of SEEG channels
%
%   Converts ecog/depth channel indices to integers.
%
%   Input:
%       eeg_file    - Path to .mat file containing EEG struct
%
%   Output:
%       eeg_struct  - Validated EEG struct
% 
%   Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
%   Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

assert(isfile(eeg_file), 'EEG file not found: %s', eeg_file);
channel_info_struct = load(eeg_file);

required_fields = {'data', 'fs', 'ecog_chan_idx', 'depth_chan_idx'};
for f = required_fields
    assert(isfield(channel_info_struct, f{1}), 'EEG missing field: %s', f{1});
end

channel_info = validateAndConvertIntFields(channel_info_struct, {'ecog_chan_idx', 'depth_chan_idx'});

end