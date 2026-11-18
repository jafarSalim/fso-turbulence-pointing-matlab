function out = exp3_ook_ppm()
%EXP3_OOK_PPM  Bit error rate of OOK and 4/8/16-PPM at the same average optical power and
%   bit rate, moderate turbulence with pointing jitter. Lines: analytic average of the
%   conditional BER over the channel; markers: bit-by-bit Monte Carlo with Gaussian noise.
%   PPM: Q slots per log2(Q) bits, so the slot is shorter (noise bandwidth x Q/log2 Q) but
%   the pulse is Q times the average power: u = g sqrt(gamma0) sqrt(Q log2 Q).
p = fso_params();  c = palette();  rng(3);
[a, b] = gg_params(p.rytov(2));
[~, xi2] = pointing_params(p.wz_a, p.sig_a);
snr = 0:3:54;
h = figure('visible', 'off', 'position', [0 0 1150 740]);
% AWGN references (no fading) as thin dashed lines
s = sqrt(10.^(snr/10));
semilogy(snr, ber_ook(s), ':', 'color', c.ook, 'linewidth', 1.4); hold on;
Qs = [4 8 16];
for i = 1:3
    semilogy(snr, ber_ppm(s*sqrt(Qs(i)*log2(Qs(i))), Qs(i)), ':', 'color', c.ppm{i}, 'linewidth', 1.4);
end
res = zeros(4, numel(snr));  mc = nan(4, numel(snr));
res(1,:) = avg_ber(@ber_ook, snr, a, b, xi2);
for i = 1:3
    Q = Qs(i);
    res(i+1,:) = avg_ber(@(u) ber_ppm(u*sqrt(Q*log2(Q)), Q), snr, a, b, xi2);
end
% Monte Carlo: slow fading, 20 symbols per channel draw
nd = 1e5;  ns = 20;
for j = 1:numel(snr)
    g = channel_sample(nd, a, b, xi2);
    G = repmat(g, 1, ns);
    bits = rand(nd, ns) > 0.5;
    y = 2*s(j)*G.*bits + randn(nd, ns);           % levels 0 and 2P (average P), noise 1
    mc(1, j) = mean(mean((y > s(j)*G) ~= bits));
    for i = 1:3
        Q = Qs(i);  k = log2(Q);
        nsym = floor(nd*ns/k);                     % same number of bits as OOK
        sym = randi(Q, nsym, 1);
        gg = g(floor((0:nsym-1)' * nd / nsym) + 1);  % consecutive symbols share a channel draw
        Y = randn(nsym, Q) * sqrt(Q/k);
        idx = sub2ind([nsym Q], (1:nsym)', sym);
        Y(idx) = Y(idx) + Q*s(j)*gg;
        [~, dec] = max(Y, [], 2);
        be = sum(dec2bin(bitxor(sym-1, dec-1), k) == '1', 2);
        mc(i+1, j) = sum(be) / (nsym*k);
    end
end
cols = [{c.ook} c.ppm];  mk = {'o', 's', 'd', '^'};
hl = zeros(1, 4);
for i = 1:4
    hl(i) = semilogy(snr, res(i,:), '-', 'color', cols{i}, 'linewidth', c.lw);
    ok = mc(i,:) > 0;
    semilogy(snr(ok), mc(i, ok), mk{i}, 'color', cols{i}, 'markerfacecolor', cols{i}, 'markeredgecolor', 'k', 'markersize', 8);
end
grid on; box on; set(gca, 'fontsize', 13);  ylim([1e-6 0.5]);  xlim([snr(1) snr(end)]);
xlabel('SNR at perfect alignment \gamma_0 = (P/\sigma)^2 [dB]'); ylabel('bit error rate');
legend(hl, {'OOK', '4-PPM', '8-PPM', '16-PPM'}, 'location', 'southwest', 'fontsize', 12);
title('moderate turbulence + pointing (\sigma_s = 2a): lines analytic, markers Monte Carlo, dotted no fading');
save_figure(h, 'fig3_ook_vs_ppm');
% SNR needed for BER 1e-4 (analytic)
need = zeros(1, 4);
for i = 1:4
    need(i) = interp1(log10(res(i,:)), snr, -4);
end
write_csv('exp3_ber', 'snr_dB,ook,ppm4,ppm8,ppm16,ook_mc,ppm4_mc,ppm8_mc,ppm16_mc', [snr' res' mc']);
out.need = need;  out.res = res;  out.mc = mc;
fprintf('exp3: SNR for BER 1e-4 [OOK 4 8 16-PPM]: %s dB\n', mat2str(need, 3));
end
