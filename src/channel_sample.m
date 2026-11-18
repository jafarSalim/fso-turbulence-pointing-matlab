function g = channel_sample(n, a, b, xi2)
%CHANNEL_SAMPLE  Monte Carlo draws of g = h_a h_p / A0: Gamma-Gamma as the product of two
%   unit-mean gamma variables (large- and small-scale eddies), pointing from a Rayleigh
%   radial displacement. randg is in base MATLAB and in Octave.
x = randg(a, n, 1) / a;
y = randg(b, n, 1) / b;
g = x .* y;
if ~isinf(xi2)
    % h_p/A0 = exp(-2 r^2/w_zeq^2) with r^2 ~ 2 sigma_s^2 Exp(1)  ->  U^(1/xi^2), U uniform
    g = g .* rand(n, 1).^(1/xi2);
end
end
