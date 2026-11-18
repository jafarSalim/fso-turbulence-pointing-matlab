function out = exp1_pdfs()
%EXP1_PDFS  The fading itself: Gamma-Gamma densities for the three turbulence regimes
%   (closed form vs 10^6 Monte Carlo draws), then what pointing jitter adds.
p = fso_params();  c = palette();  rng(1);
n = 1e6;
h = figure('visible', 'off', 'position', [0 0 1500 600]);
subplot(1, 2, 1);
x = linspace(0.005, 3.5, 600)';
leg = {};
for r = 1:3
    [a, b] = gg_params(p.rytov(r));
    s = channel_sample(n, a, b, Inf);
    e = linspace(0, 3.5, 71);  ctr = (e(1:end-1) + e(2:end))/2;
    cnt = histc(s, e);  cnt = cnt(1:end-1);
    bar(ctr, cnt(:) / (n * (e(2)-e(1))), 1, 'facecolor', 0.35*c.reg{r} + 0.65*[1 1 1], 'edgecolor', 'none'); hold on;
    out.alpha(r) = a;  out.beta(r) = b;
    out.si_sim(r) = var(s) / mean(s)^2;
    out.si_th(r) = 1/a + 1/b + 1/(a*b);
end
hl = zeros(1,3);
for r = 1:3
    hl(r) = plot(x, gg_pdf(x, out.alpha(r), out.beta(r)), '-', 'color', c.reg{r}, 'linewidth', c.lw);
    leg{r} = sprintf('%s: \\sigma_R^2 = %.1f, \\alpha = %.2f, \\beta = %.2f', p.regime{r}, p.rytov(r), out.alpha(r), out.beta(r));
end
grid on; box on; set(gca, 'fontsize', 13);  xlim([0 3.5]);
xlabel('normalized irradiance h_a'); ylabel('probability density');
legend(hl, leg, 'location', 'northeast', 'fontsize', 11);
title('Gamma-Gamma turbulence: lines closed form, bars 10^6 draws');
subplot(1, 2, 2);
[a, b] = gg_params(p.rytov(2));
sg = [0 1 2 3];
cols = {c.grey, c.weak, c.mod, c.strong};
g = logspace(-4, 1, 800)';
hl = zeros(1, 4);  leg = {};
for k = 1:4
    [~, xi2] = pointing_params(p.wz_a, sg(k));
    F = channel_cdf(g, a, b, xi2);
    hl(k) = loglog(g, F, '-', 'color', cols{k}, 'linewidth', c.lw); hold on;
    s = channel_sample(2e5, a, b, xi2);
    gs = logspace(-2.6, 0.4, 13);
    pm = arrayfun(@(t) mean(s <= t), gs);  gs = gs(pm > 0);  pm = pm(pm > 0);
    loglog(gs, pm, 'o', 'color', cols{k}, 'markerfacecolor', cols{k}, 'markersize', 7, 'markeredgecolor', 'k');
    if sg(k) == 0, leg{k} = 'no pointing error'; else, leg{k} = sprintf('\\sigma_s = %d a  (\\xi^2 = %.2f)', sg(k), xi2); end
end
grid on; box on; set(gca, 'fontsize', 13);  xlim([1e-3 10]);  ylim([1e-5 1]);
xlabel('normalized channel g = h_a h_p / A_0'); ylabel('CDF  P(g \leq x)');
legend(hl, leg, 'location', 'southeast', 'fontsize', 11);
title('moderate turbulence + pointing jitter: lines 1-D integral, dots Monte Carlo');
save_figure(h, 'fig1_fading');
write_csv('exp1_regimes', 'rytov,alpha,beta,SI_theory,SI_sim', [p.rytov' out.alpha' out.beta' out.si_th' out.si_sim']);
fprintf('exp1: alpha %s beta %s SI th %s sim %s\n', mat2str(out.alpha,3), mat2str(out.beta,3), mat2str(out.si_th,3), mat2str(out.si_sim,3));
end
