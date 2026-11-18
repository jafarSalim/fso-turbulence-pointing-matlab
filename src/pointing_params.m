function [A0, xi2, wzeq_a] = pointing_params(wz_a, sig_a)
%POINTING_PARAMS  Misalignment fading of a Gaussian beam on a circular aperture
%   (Farid and Hranilovic, J. Lightw. Technol. 2007):
%     h_p = A0 exp(-2 r^2 / w_zeq^2),  r ~ Rayleigh(sigma_s),  xi = w_zeq / (2 sigma_s)
%   wz_a: beam radius / aperture radius, sig_a: jitter std / aperture radius.
v = sqrt(pi) ./ (sqrt(2) * wz_a);
A0 = erf(v).^2;
wzeq_a = sqrt(wz_a.^2 .* sqrt(pi) .* erf(v) ./ (2*v.*exp(-v.^2)));
xi2 = (wzeq_a ./ (2*sig_a)).^2;
xi2(sig_a == 0) = Inf;
end
