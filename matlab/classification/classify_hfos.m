function [ labels, scores ] = classify_hfos( X, model )
%CLASSIFY_HFOS Classify HFO events using logistic regression model.
%
%   [ labels, scores ] = classify_hfos( X, model ) takes feature matrix X and a
%   logistic regression model struct, and returns binary classification labels
%   and probabilities (scores) for each event.
%
% Inputs:
%   X     - n-by-m matrix of features (n events, m features)
%   model - struct with fields:
%           .coefficients - regression coefficients (m-by-1 vector)
%           .intercept    - scalar intercept term
%           .threshold    - classification threshold (scalar between 0 and 1)
%           .mean         - mean vector used for feature normalization (m-by-1)
%           .std          - standard deviation vector for normalization (m-by-1)
%
% Outputs:
%   labels - n-by-1 logical vector of predicted classes (1 = HFO, 0 = artifact)
%   scores - n-by-1 vector of logistic regression probabilities (range [0,1])
%
% Example:
%   [ labels, scores ] = classify_hfos( X, model );
%
% Written by Shi-Bei (Ashley) Tan (tashibei@umich.edu) in 2025
% Copyright © 2025 by Shi-Bei (Ashley) Tan is licensed under CC BY-NC 4.0

%% Extract model data

coef       = model.coefficients;
intercept  = model.intercept;
threshold  = model.threshold;
mu         = model.mean';
sigma      = model.std';

%% Normalize input

X_norm = (X - mu) ./ sigma;

%% Linear model

z = X_norm * coef + intercept;

%% Sigmoid function

scores = expit(z); % probabilities

%% Prediction

labels = NaN(size(scores)); % Initialize labels with NaN
labels(~isnan(scores)) = scores(~isnan(scores)) > threshold; % Set labels based on threshold for non-NaN scores
labels = double(labels); % Convert logical array to ones and zeros

end