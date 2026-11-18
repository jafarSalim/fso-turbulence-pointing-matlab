function p = fso_params()
%FSO_PARAMS  A 1550 nm terrestrial free-space optical link.
p.lambda = 1550e-9;              % wavelength [m]
p.k      = 2*pi/p.lambda;        % wave number
p.L      = 1000;                 % link length [m]
p.wz_a   = 10;                   % beam radius at the receiver / aperture radius
p.sig_a  = 2;                    % pointing-jitter std / aperture radius
% turbulence regimes by Rytov variance (plane wave, point receiver)
p.regime = {'weak', 'moderate', 'strong'};
p.rytov  = [0.2 1.0 4.0];
end
