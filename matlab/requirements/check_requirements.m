function check_requirements()
%CHECK_REQUIREMENTS Verify presence of required MATLAB toolboxes.
%
%   check_requirements() checks whether the required MATLAB toolboxes are
%   installed and available in the current environment. It displays a message
%   indicating which toolboxes are found or missing.
%
%   Required toolboxes:
%       - Signal Processing Toolbox
%       - Statistics and Machine Learning Toolbox
%
%   This function prints status messages to the command window.


requiredToolboxes = {
    'Signal Processing Toolbox', ...
    'Statistics and Machine Learning Toolbox', ...
    'Parallel Computing Toolbox'
    };

v = ver;
installedToolboxes = { v.Name };

fprintf( 'Checking MATLAB toolbox requirements:\n' );
for i = 1:numel( requiredToolboxes )
    if ismember( requiredToolboxes{i}, installedToolboxes )
        fprintf( '[OK] %s\n', requiredToolboxes{i} );
    else
        warning( '[MISSING] %s\n', requiredToolboxes{i} );
    end
end

end