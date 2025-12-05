function features = compute_features_filt( x, fs )
%% function features = compute_features_filt( x, fs )
%
% HFO features computed on the filtered HFO waveform
%
% See README.md for more details
%
% Originally written by S. Gliske (sgliske@unmc.edu) 2017-2024
% Transcribed to Matlab by S. Gliske in 2025
% Copyright © 2025 by S. Gliske is licensed under CC BY-NC 4.0

%% check inputs

narginchk(2,2);
mustBeVector(x);
assert(isscalar(fs));

min_size = 6;
if( length(x) < min_size )
    features = fill_struct_with_nans( @compute_features_filt, min_size );
    return
end

%% prep

% convert sampling rate to samples per millisecond
fs_msec = fs / 1000;

%% normalization

mu = median(x);
sigma = median( abs( x - mu ) )*1.486;
x = (x - mu) / sigma;

%% transforms

LL = abs(diff(x));
curv = abs(x(1:end-2) - 2*x(2:end-1) + x(3:end));
TKE = x(2:end-1).^2 - x(1:end-2).*x(3:end);

nFFT = length(x);
if( mod(nFFT,2) == 1 )
  nFFT = nFFT - 1;
end

[pxx,f] = fft_wrapper( x(1:nFFT), fs, nFFT );
I = f >= 80 & f <= 500;
f = f(I);
pxx = pxx(I);

%% features based on time domain

features.duration = length(x) / fs_msec;
features.TD_amplitude = 10*log10(sigma);
features.TD_skew = skewness(x);
features.TD_kurt = kurtosis(x)-3;

%% features based on line length

features.LL_mean = mean(LL)*fs_msec;
features.LL_var = var(LL,1)*fs_msec^2;
features.LL_skew = skewness(LL);
features.LL_kurt = kurtosis(LL)-3;


%% features based on curvature

features.curv_mean = mean(curv)*fs_msec^2;
features.curv_var = var(curv,1)*fs_msec^4;
features.curv_skew = skewness(curv);
features.curv_kurt = kurtosis(curv)-3;

%% features based on Teager Kaiser Energy

features.TKE_mean = mean(TKE)*fs_msec^2;
features.TKE_var = var(TKE,1)*fs_msec^4;
features.TKE_skew = skewness(TKE);
features.TKE_kurt = kurtosis(TKE)-3;

%% features based on power spectrum

[features.PSD_peak_amp, i] = max(pxx);
features.PSD_peak_freq = f(i);

% ensure correct orientation
pxx = pxx(:);
f = f(:);
sum_pxx = sum(pxx);
features.PSD_mean = sum(f.*pxx) / sum_pxx;  % weighted mean
features.PSD_var = var( f, pxx );

% code for weighted skewness and kurtosis based on John D'Errico's 15 Jul
% 2021 post: https://www.mathworks.com/matlabcentral/answers/10058-skewness-and-kurtosis-of-a-weighted-distribution

mom3 = sum( pxx.*(f - features.PSD_mean).^3 ) / sum_pxx;
mom4 = sum( pxx.*(f - features.PSD_mean).^4 ) / sum_pxx;

features.PSD_skew = mom3 ./ features.PSD_var^1.5;
features.PSD_kurt = mom4 ./ features.PSD_var^2 - 3;

% quantiles
temp = interp1( cumsum(pxx)/sum(pxx), f, [0.25 0.5 0.75]);
if isnan(temp(1))
    temp(1) = f(1);
end
if isnan(temp(3))
    temp(3) = f(end);
end

features.PSD_power_quartile_1 = temp(1);
features.PSD_power_median     = temp(2);
features.PSD_power_quartile_3 = temp(3);




