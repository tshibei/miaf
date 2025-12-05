function Hd = cauerfilt( Fpass1, Fpass2, fs )
%function Hd = cauerfilt( Fpass1, Fpass2, fs )
%
%CAUERFILT Returns a discrete-time filter object.
%
% Example:
%
% Hd = cauerfilt( 80, 500, 4096 );
% filteredWave = filtfilt(Hd.sosMatrix, Hd.ScaleValues, wave );
%

% Elliptic Bandpass filter designed using FDESIGN.BANDPASS.

% All frequency values are in Hz.

N      = 10;   % Order
Apass  = 0.5;  % Passband Ripple (dB)
Astop  = 65;   % Stopband Attenuation (dB)

assert( nargin == 3 )

% Construct an FDESIGN object and call its ELLIP method.
h  = fdesign.bandpass('N,Fp1,Fp2,Ast1,Ap,Ast2', N, Fpass1, Fpass2, ...
                      Astop, Apass, Astop, fs);
Hd = design(h, 'ellip');

