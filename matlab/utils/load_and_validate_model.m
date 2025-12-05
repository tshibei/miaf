function model = load_and_validate_model( model_filepath )
%%LOAD_AND_VALIDATE_MODEL Load and verify an HFO classification model from a JSON file
%
%  model = load_and_validate_model( model_filepath )
%
%  Loads and validates a JSON model file used for HFO classification.
%  Verifies presence and structure of the following fields:
%
%       model - struct with fields:
%           .coefficients - regression coefficients (m-by-1 vector)
%           .intercept    - scalar intercept term
%           .threshold    - classification threshold (scalar between 0 and 1)
%           .mean         - mean vector used for feature normalization (m-by-1)
%           .std          - standard deviation vector for normalization (m-by-1)
%
%  Input:
%       model_file  - Path to JSON file containing model parameters
%
%  Output:
%       model       - Struct with validated model fields
%
%  Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
%  Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

assert( isfile(model_filepath), 'Model file not found: %s', model_filepath );

model_txt = fileread( model_filepath );
assert( ~isempty(model_txt), 'Model file is empty.' );
model = jsondecode( model_txt );

% Validate required fields
required_fields = { 'coefficients', 'intercept', 'threshold', 'mean', 'std' };
for f = required_fields
    assert( isfield(model, f{1}), 'Model missing field: %s', f{1} );
end

% Validate scalar fields
assert( isscalar(model.intercept), 'Model intercept must be a scalar.' );
assert( isscalar(model.threshold) && model.threshold >= 0 && model.threshold <= 1, ...
    'Model threshold must be a scalar between 0 and 1.' );

% Validate vector fields and their sizes
coef = model.coefficients;
mu   = model.mean;
sig  = model.std;

assert( isvector(coef) && isnumeric(coef), 'Model.coefficients must be a numeric vector.' );
assert( isvector(mu) && isnumeric(mu),     'Model.mean must be a numeric vector.' );
assert( isvector(sig) && isnumeric(sig),   'Model.std must be a numeric vector.' );

assert( length(coef) == length(mu) && length(coef) == length(sig), ...
    'Model vectors (coefficients, mean, std) must be the same length.' );

% Convert row to column vectors
model.coefficients = model.coefficients(:);
model.mean         = model.mean(:);
model.std          = model.std(:);

end