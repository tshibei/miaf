function output = add_prefix( prefix, input )
%% function output = add_prefix( prefix, input )
%
% Add a prefix to every field name in the input structure
%
% Written by S. Gliske (sgliske@unmc.edu) in 2025
% Copyright © 2025 by S. Gliske is licensed under CC BY-NC 4.0

output = struct();
fn = fieldnames(input);
for i=1:length(fn)
    output.([ prefix '_' fn{i}]) = input.(fn{i});
end


