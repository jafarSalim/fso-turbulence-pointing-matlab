function out = exp4_aperture()
%EXP4_APERTURE  Aperture averaging: a larger receiver lens averages over many turbulence
%   eddies and the scintillation index drops (Andrews and Phillips plane-wave model).
%   Fixed turbulence strength Cn^2 = 5e-14 m^(-2/3); links of 0.5, 1, 2 and 3 km.
p = fso_params();  c = palette();  rng(4);
Cn2 = 5e-14;
Ls = [500 1000 2000 3000];
D = linspace(0, 0.2, 81);
cols = {c.weak, c.mod, c.strong, [0.45 0.20 0.90]};
h = figure('visible', 'off', 'position', [0 0 1500 620]);
subplot(1, 2, 1);
SI = zeros(numel(Ls), numel(D));
hl = zeros(1, numel(Ls));  leg = {};
for i = 1:numel(Ls)
    s2 = rytov(Cn2, Ls(i), p.k);
    d2 = p.k * D.^2 / (4*Ls(i));
    [a, b] = gg_params(s2, d2);
    SI(i,:) = 1./a + 1./b + 1./(a.*b);
    hl(i) = semilogy(D*100, SI(i,:), '-', 'color', cols{i}, 'linewidth', c.lw); hold on;
    % Monte Carlo check of the index at three apertures
    for Dm = [0 0.05 0.15]
        [am, bm] = gg_params(s2, p.k*Dm^2/(4*Ls(i)));
        sm = channel_sample(4e5, am, bm, Inf);
        semilogy(Dm*100, var(sm)/mean(sm)^2, 'o', 'color', cols{i}, 'markerfacecolor', cols{i}, 'markeredgecolor', 'k', 'markersize', 8);
    end
    leg{i} = sprintf('L = %.1f km  (\\sigma_R^2 = %.2f, Fresnel zone %.1f cm)', Ls(i)/1e3, s2, 100*sqrt(Ls(i)/p.k));
end
grid on; box on; set(gca, 'fontsize', 13);
xlabel('receiver aperture diameter D [cm]'); ylabel('scintillation index \sigma_I^2');
legend(hl, leg, 'location', 'southwest', 'fontsize', 10.5);
title('C_n^2 = 5\times10^{-14} m^{-2/3}: lines model, dots 4\times10^5 draws');
subplot(1, 2, 2);
snr = 0:1:100;
Ds = [0 0.02 0.05 0.10];
L = 2000;  s2 = rytov(Cn2, L, p.k);
cc = {c.strong, c.mod, c.weak, [0.45 0.20 0.90]};
hl = zeros(1, numel(Ds));  leg = {};
need = zeros(1, numel(Ds));
for i = 1:numel(Ds)
    [a, b] = gg_params(s2, p.k*Ds(i)^2/(4*L));
    pb = avg_ber(@ber_ook, snr, a, b, Inf);
    hl(i) = semilogy(snr, pb, '-', 'color', cc{i}, 'linewidth', c.lw); hold on;
    k = find(pb <= 1e-5, 1);                          % first SNR reaching BER 1e-5
    if isempty(k) || k == 1, need(i) = NaN;
    else, need(i) = interp1(log10(pb(k-1:k)), snr(k-1:k), -5); end
    if Ds(i) == 0, leg{i} = 'point receiver'; else, leg{i} = sprintf('D = %g cm', 100*Ds(i)); end
end
semilogy(snr, ber_ook(sqrt(10.^(snr/10))), ':', 'color', c.grey, 'linewidth', 2);
leg{end+1} = 'no turbulence';
grid on; box on; set(gca, 'fontsize', 13);  ylim([1e-8 0.5]);  xlim([0 100]);
xlabel('SNR [dB]  (same collected power for every D)'); ylabel('OOK bit error rate');
legend(leg, 'location', 'northeast', 'fontsize', 12);
title(sprintf('L = 2 km (\\sigma_R^2 = %.1f): SNR for BER 10^{-5}: %.0f dB \\rightarrow %.0f dB', s2, need(1), need(end)));
save_figure(h, 'fig4_aperture_averaging');
write_csv('exp4_scintillation', 'D_m,SI_500m,SI_1km,SI_2km,SI_3km', [D' SI']);
out.need = need;  out.Ds = Ds;  out.SI0 = SI(:,1)';  out.SI10 = SI(:, D == 0.1)';
fprintf('exp4: SNR for 1e-5 vs D %s: %s; SI at D=0 %s, at 10 cm %s\n', mat2str(Ds), mat2str(need, 3), mat2str(out.SI0, 3), mat2str(out.SI10, 3));
end
