function events = load_and_validate_events( detected_events_file )
%LOAD_AND_VALIDATE_EVENTS Load and validate HFO event metadata from a .mat file.
%
%  Loads a .mat file containing HFO event metadata and validates that the
%  required fields ('start_idx', 'end_idx', 'chan_idx') are present. Also
%  ensures these fields are in integer format.
%
%  Inputs:
%    detected_events_file - String, path to a .mat file containing a struct with HFO events.
%                  The file must contain a struct with fields:
%                     - start_idx : Vector of start indices for each event
%                     - end_idx   : Vector of end indices for each event
%                     - chan_idx  : Vector of channel indices for each event
%
%  Outputs:
%    events - Struct containing validated and standardized HFO event fields.
%
%   Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
%   Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

assert( isfile(detected_events_file), 'Events file not found: %s', detected_events_file );
events = load( detected_events_file );

required_fields = { 'start_idx', 'end_idx', 'chan_idx' };
for f = required_fields
    assert( isfield(events, f{1}), 'Events missing field: %s', f{1} );
end

events = validateAndConvertIntFields( events, {'start_idx', 'end_idx', 'chan_idx'} );

end