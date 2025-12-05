function features = compute_features_raw( x, fs )
%% function features = compute_features_raw( x, fs )
%
% HFO features computed on the raw (post-referenced) HFO waveform
%
% See README.md for more details
%
% Originally written by S. Gliske (sgliske@unmc.edu) in 2024
% Based on Ibarz et al. (2010), doi:10.1523/JNEUROSCI.3357-10.2010
% Transcribed to Matlab by S. Gliske in 2025
% Copyright © 2025 by S. Gliske is licensed under CC BY-NC 4.0

%% check inputs

narginchk(2,2);
mustBeVector(x);
assert(isscalar(fs));
assert( fs > 0 );

min_size = 6;
if( length(x) < min_size )
    features = fill_struct_with_nans( @compute_features_filt, min_size );
    return
end

%% parameters

min_freq = 80;
mid_freq = 250;
max_freq = 500;

target_resolution = 8;

%% check parameters

nyquist = fs/2;
if( max_freq > nyquist )
    max_freq = nyquist;
    mid_freq = nyquist/2;
end
assert( mid_freq >= 100 );

%% prep

nFFT = 2^( max( 2, ceil( log2( fs / target_resolution ) ) ) );
delta_f = fs/nFFT;

i_low = ceil(   min_freq / delta_f )+1;
i_mid = floor(  mid_freq / delta_f )+1;
i_high = floor( max_freq / delta_f )+1;
assert( i_high < nFFT );

% zero padding
old_x = x;
x = zeros(nFFT,1);
x(1:length(old_x)) = old_x;

%% FFT

[pxx,f] = fft_wrapper( x, fs, nFFT );
assert( (f(2)-f(1)) == delta_f );

%% compute

F_low  = sum( pxx(i_low:i_mid) );
F_high = sum( pxx(i_mid+1:i_high) );

F = F_high + F_low;

% ensure zeros don't turn to -Inf
pxx(pxx==0) = 1;
pxx = pxx(i_low:i_high);
log2pxx = log2(pxx);

features.entropy = -sum( pxx.*log2pxx ) + F*sum( log2pxx );
features.fr_index   = F_high / F;





