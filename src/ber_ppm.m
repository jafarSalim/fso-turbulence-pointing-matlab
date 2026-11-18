function pb = ber_ppm(u, Q)
%BER_PPM  Q-ary pulse-position modulation with maximum-likelihood (largest slot) detection
%   in Gaussian noise. u = mean of the signal slot / noise std. Bit error rate:
%   SEP = 1 - int phi(x) Phi(x + u)^(Q-1) dx,   BER = SEP Q / (2 (Q-1)).
x = linspace(-9, 9, 721)';
phi = exp(-x.^2/2) / sqrt(2*pi);
pb = zeros(size(u));
for i = 1:numel(u)
    Phi = 0.5 * erfc(-(x + u(i)) / sqrt(2));
    sep = 1 - trapz(x, phi .* Phi.^(Q-1));
    pb(i) = max(sep, 0) * Q / (2*(Q-1));
end
end
