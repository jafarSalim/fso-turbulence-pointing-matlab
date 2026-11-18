function [a, b] = gg_params(s2, d2)
%GG_PARAMS  Gamma-Gamma alpha and beta for a plane wave (Andrews and Phillips, 2005),
%   with aperture averaging: d2 = k D^2 / (4 L) (d2 = 0 is a point receiver).
if nargin < 2, d2 = 0; end
s125 = s2.^(6/5);
a = 1 ./ (exp(0.49*s2 ./ (1 + 0.65*d2 + 1.11*s125).^(7/6)) - 1);
b = 1 ./ (exp(0.51*s2 .* (1 + 0.69*s125).^(-5/6) ./ (1 + 0.90*d2 + 0.62*d2.*s125).^(5/6)) - 1);
end
