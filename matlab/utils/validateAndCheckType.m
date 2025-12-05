function variable = validateAndCheckType( file, field, type_check )
%VALIDATEANDCHECKTYPE Load a variable from a .mat file and validate its type.
%
%   variable = VALIDATEANDCHECKTYPE(file, field, type_check) loads the specified
%   MAT-file, extracts the variable named by 'field', and verifies that it
%   matches the expected data type.
%
%   Inputs:
%       file  - Path to a .mat file.
%       field - Name of the variable to extract from the file.
%       type_check  - Expected type of the variable. Supported values:
%               'numeric' : checks that the variable is numeric.
%               'float'   : checks that the variable is floating-point.
%
%   Output:
%       variable - The extracted variable if all validations pass.
%
%   The function throws an error if:
%       - The file does not exist.
%       - The specified field is not found in the MAT-file.
%       - The variable does not match the requested type.

assert(isfile(file), 'File not found: %s', file);
variable = load(file);

% Check and load field
if ~isfield(variable, field)
    error('Field %s does not exist in the loaded variable.', field);
end
variable = variable.(field);

% Check type of variable
if strcmp(type_check, 'numeric')
    assert(isnumeric(variable), 'Variable is not a numeric: %s', field);
end
if strcmp(type_check, 'float')
    assert(isfloat(variable), 'Variable is not a float: %s', field);
end
