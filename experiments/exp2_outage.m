function out = exp2_outage()
%EXP2_OUTAGE  Outage probability P(gamma0 g^2 < gamma_th) versus the SNR at perfect
%   alignment, for the three regimes, without and with pointing jitter (sigma_s = 2a).
%   Lines: one-dimensional integral; markers: 10^6 Monte Carlo channel draws.
%   High-SNR slope (diversity order) = min(alpha, beta, xi^2) / 2.
p = fso_params();  c = palette();  rng(2);
gth_dB = 10;
snr = 0:2:70;
n = 1e6;
[~, xi2p] = pointing_params(p.wz_a, p.sig_a);
h = figure('visible', 'off', 'position', [0 0 1150 760]);
hl = [];  leg = {};
rows = [];
for r = 1:3
    [a, b] = gg_params(p.rytov(r));
    for jit = [0 1]
        if jit, xi2 = xi2p; ls = '-'; else, xi2 = Inf; ls = '--'; end
        t = sqrt(10.^((gth_dB - snr)/10));
        Pa = channel_cdf(t, a, b, xi2);
        hh = semilogy(snr, Pa, ls, 'color', c.reg{r}, 'linewidth', c.lw); hold on;
        s = channel_sample(n, a, b, xi2);
        Pm = arrayfun(@(v) mean(s <= v), t);
        ok = Pm > 20/n;
        mk = 'o'; if jit, mk = 's'; end
        semilogy(snr(ok), Pm(ok), mk, 'color', c.reg{r}, 'markerfacecolor', c.reg{r}*jit + [1 1 1]*(1-jit), 'markersize', 7, 'linewidth', 1.5);
        % high-SNR slope of the analytic curve, measured deep in the tail (1e-11 .. 1e-14)
        se = 0:1:300;
        Pe = channel_cdf(sqrt(10.^((gth_dB - se)/10)), a, b, xi2);
        sel = Pe < 1e-11 & Pe > 1e-14;
        q = polyfit(se(sel)/10, log10(Pe(sel)), 1);
        dpred = min([a b xi2]) / 2;
        rows = [rows; r jit a b xi2*jit -q(1) dpred]; %#ok<AGROW>
        hl(end+1) = hh; %#ok<AGROW>
        if jit, leg{end+1} = sprintf('%s + pointing  (slope %.2f, predicted %.2f)', p.regime{r}, -q(1), dpred);
        else,   leg{end+1} = sprintf('%s, aligned  (slope %.2f, predicted %.2f)', p.regime{r}, -q(1), dpred); end %#ok<AGROW>
    end
end
grid on; box on; set(gca, 'fontsize', 13);  ylim([1e-6 1]);  xlim([snr(1) snr(end)]);
xlabel('SNR at perfect alignment \gamma_0 [dB]  (threshold \gamma_{th} = 10 dB)'); ylabel('outage probability');
legend(hl, leg, 'location', 'southwest', 'fontsize', 10.5);
title('outage: lines 1-D integral, markers 10^6 Monte Carlo draws (\sigma_s = 2a, w_z = 10a)');
save_figure(h, 'fig2_outage');
write_csv('exp2_slopes', 'regime,pointing,alpha,beta,xi2,slope_measured,slope_predicted', rows);
out.rows = rows;
fprintf('exp2 slopes: %s\n', mat2str(rows(:, [1 2 6 7]), 3));
end
