function features = fill_struct_with_nans( func, n )
%% function features = fill_struct_with_nans( func, n )
%
% Utility function.  Calls function "func" to get the names of the fields
% for the output structure.  Then the function sets all values to nan. The
% length parameter "n" should be set long enough to not cause infinite
% recursion but short enough to not cause an error.
%
% Written by S. Gliske (sgliske@unmc.edu) in 2025
% Copyright © 2025 by S. Gliske is licensed under CC BY-NC 4.0

%% run the function with junk data to get the set of feature names

narginchk(2,2);
mustBeScalarOrEmpty( n );
assert( ~isempty(n) );
features = func( 1:n, n );
names = fieldnames( features );

%% set all the values to nan
for i=1:length(names)
    features.( names{i} ) = nan;
end
