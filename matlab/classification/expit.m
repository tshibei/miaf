function y = expit(z)
%EXPIT Numerically stable implementation of the logistic sigmoid function following
% Python's expit from scipy.scpecial
    y = zeros(size(z));
    idx = z >= 0;
    y(idx)  = 1 ./ (1 + exp(-z(idx)));
    y(~idx) = exp(z(~idx)) ./ (1 + exp(z(~idx)));
end