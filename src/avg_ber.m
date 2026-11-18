function pb = avg_ber(condfun, gamma0_dB, a, b, xi2)
%AVG_BER  Average BER over the fading: P_b = int P_b(g) dF(g), with F from CHANNEL_CDF.
g = logspace(-5, 1.5, 1500)';
F = channel_cdf(g, a, b, xi2);
gm = sqrt(g(1:end-1) .* g(2:end));
dF = diff(F);
pb = zeros(size(gamma0_dB));
for i = 1:numel(gamma0_dB)
    s = sqrt(10^(gamma0_dB(i)/10));
    pb(i) = sum(condfun(gm * s) .* dF) + condfun(g(1)*s/2) * F(1);
end
end
