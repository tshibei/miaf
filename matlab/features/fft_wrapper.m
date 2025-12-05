function [ pxx, f, phi ] = fft_wrapper( x, fs, nFFT )
%% function [ pxx, f ] = fft_wrapper( x, fs, nFFT )
%
%  Wrapper for Matlab's fft function so that its outputs are formatted more like pwelch
%
% Written by S. Gliske (sgliske@unmc.edu, sgliske@umich.edu) before 2020
% Copyright © 2025 by S. Gliske is licensed under CC BY-NC 4.0

Y = fft( x, nFFT );
Y = Y(1:ceil(nFFT/2));

pxx = abs(Y);
pxx(:,2:end) = 2*pxx(:,2:end);
pxx = pxx / sqrt(length(x)) * 2; % normalization

f = 0:(fs/nFFT):(fs/2);
f = f(1:length(pxx))';

if nargout > 2
    phi = angle(Y);
end
