function s = validateAndConvertIntFields( struct_file, fields )
%VALIDATEANDCONVERTINTFIELDS Validate specified struct fields are integers and convert to int32.
%
% Checks that the specified fields in struct contain only integer
% values, errors if not, then converts those fields to int32.
%
% Inputs:
%   struct_file - string, filepath of struct
%   fields      - cell array of strings, names of fields to check & convert
%
% Output:
%   s           - output struct with specified fields converted to int32
%
% Example usage:
%   channel_info = validateAndConvertIntFields( channel_info_file,  {'ecog_chan_idx', 'depth_chan_idx'});
%   events = validateAndConvertIntFields(events, {'start_idx', 'end_idx', 'chan_idx'});
%
% Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
% Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

assert(isfile(struct_file), 'File not found: %s', struct_file);
s = load(struct_file);

for i = 1:numel( fields )
    f = fields{i};
    if ~isfield( s, f )
        error( 'Field "%s" not found in input struct.', f );
    end
end

end