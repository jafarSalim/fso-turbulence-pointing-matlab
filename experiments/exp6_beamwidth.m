function out = exp6_beamwidth()
%EXP6_BEAMWIDTH  The beam-width trade-off. A narrow beam puts more power on the lens
%   (larger A0) but a small sway pushes it off; a wide beam is robust but dim. For a fixed
%   transmit budget the outage has a minimum at an optimum beam width that grows with the
%   jitter. Map: outage over (w_z/a, sigma_s/a), moderate turbulence, analytic.
p = fso_params();  c = palette();
[a, b] = gg_params(p.rytov(2));
wz = logspace(log10(2), log10(60), 70);
sg = linspace(0.25, 6, 60);
budget_dB = 60;  gth_dB = 10;          % SNR if all transmitted power reached the detector
P = zeros(numel(sg), numel(wz));
for i = 1:numel(sg)
    for j = 1:numel(wz)
        [A0, xi2] = pointing_params(wz(j), sg(i));
        t = sqrt(10^((gth_dB - budget_dB)/10)) / A0;
        P(i, j) = channel_cdf(t, a, b, xi2);
    end
end
L = log10(max(P, 1e-12));
[~, jbest] = min(P, [], 2);
h = figure('visible', 'off', 'position', [0 0 1250 760]);
imagesc(log10(wz), sg, L);  axis xy;  colormap(gca, flipud(c.heat));  caxis([-6 0]);
hold on;
contour(log10(wz), sg, L, [-6 -4 -3 -2 -1], 'linecolor', [1 1 1]*0.95, 'linewidth', 1.1, 'showtext', 'on');
plot(log10(wz(jbest)), sg, '-', 'color', [0 0.85 1], 'linewidth', 3.5);
text(log10(wz(jbest(end))) + 0.03, sg(end) - 0.25, 'optimum beam width', 'color', [0 0.85 1], 'fontsize', 13, 'fontweight', 'bold');
cb = colorbar;  ylabel(cb, 'log_{10} outage probability');  set(cb, 'fontsize', 12);
set(gca, 'fontsize', 13, 'xtick', log10([2 3 5 10 20 30 60]), 'xticklabel', {'2', '3', '5', '10', '20', '30', '60'});
xlabel('beam radius at the receiver w_z / a'); ylabel('pointing jitter \sigma_s / a');

title(sprintf('outage map, moderate turbulence, %d dB budget, threshold %d dB', budget_dB, gth_dB));
save_figure(h, 'fig6_beamwidth_map');
best = [sg' wz(jbest)' min(P, [], 2)];
write_csv('exp6_optimum_beam', 'sigma_s_over_a,best_wz_over_a,min_outage', best);
out.best = best;
k = [find(sg >= 1, 1) find(sg >= 3, 1) find(sg >= 5, 1)];
out.pick = best(k, :);
fprintf('exp6 (sigma, best wz, outage): %s\n', mat2str(out.pick, 3));
end
