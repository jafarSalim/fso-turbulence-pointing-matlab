function out = exp5_diversity()
%EXP5_DIVERSITY  Spatial diversity with 1, 2 and 4 apertures and equal-gain combining:
%   gamma = gamma0 (sum g_n)^2 / N (Tsiftsis et al., IEEE Trans. Wireless Commun. 2009).
%   Turbulence and jitter independent per aperture (apertures more than a coherence
%   length apart, each with its own mount). Outage by 10^6 Monte Carlo draws; N = 1 also
%   analytic. Predicted diversity order: N min(alpha, beta, xi^2) / 2.
p = fso_params();  c = palette();  rng(5);
[a, b] = gg_params(p.rytov(2));
[~, xi2] = pointing_params(p.wz_a, p.sig_a);
gth_dB = 10;  snr = 0:2:60;  n = 1e6;
Ns = [1 2 4];
cols = {c.strong, c.mod, c.weak};  mk = {'o', 's', 'd'};
h = figure('visible', 'off', 'position', [0 0 1100 720]);
t = sqrt(10.^((gth_dB - snr)/10));
semilogy(snr, channel_cdf(t, a, b, xi2), '-', 'color', [0.15 0.15 0.2], 'linewidth', 1.4); hold on;
hl = zeros(1, 3);  leg = {};  rows = zeros(3, 3);
for i = 1:3
    N = Ns(i);
    G = zeros(n, 1);
    for m = 1:N, G = G + channel_sample(n, a, b, xi2); end
    G = G / sqrt(N);
    P = arrayfun(@(v) mean(G <= v), t);
    ok = P > 30/n;
    hl(i) = semilogy(snr(ok), P(ok), ['-' mk{i}], 'color', cols{i}, 'linewidth', c.lw, 'markerfacecolor', cols{i}, 'markeredgecolor', 'k', 'markersize', 8);
    sel = ok & P < 3e-2;
    q = polyfit(snr(sel)/10, log10(P(sel)), 1);
    rows(i,:) = [N -q(1) N*min([a b xi2])/2];
    leg{i} = sprintf('%d aperture%s: slope %.2f here, asymptote %.2f', N, repmat('s', 1, N > 1), -q(1), rows(i,3));
    if any(P <= 1e-3)
        out.snr_1e3(i) = interp1(log10(P(ok)), snr(ok), -3);
    else
        out.snr_1e3(i) = NaN;
    end
end
grid on; box on; set(gca, 'fontsize', 13);  ylim([1e-5 1]);
xlabel('SNR at perfect alignment \gamma_0 per aperture [dB]'); ylabel('outage probability');
legend(hl, leg, 'location', 'southwest', 'fontsize', 12);
title('moderate turbulence + pointing, equal-gain combining (black: N = 1 analytic)');
save_figure(h, 'fig5_diversity');
write_csv('exp5_diversity', 'N,slope_measured,slope_predicted', rows);
out.rows = rows;
fprintf('exp5: %s; SNR for 1e-3 outage %s\n', mat2str(rows, 3), mat2str(out.snr_1e3, 3));
end
