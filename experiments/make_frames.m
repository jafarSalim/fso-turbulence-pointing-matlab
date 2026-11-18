function make_frames()
%MAKE_FRAMES  Frames for assets/beam_wander.gif: the beam footprint on the receiver plane
%   wanders (pointing jitter, AR(1) motion) and twinkles (turbulence, a log-normal speckle
%   field that drifts across the beam, Taylor frozen flow). The trace is the power the
%   lens collects. Illustration with a narrow beam (w_z = 4a, sigma_s = 1.5a).
c = palette();  rng(9);
nf = 60;  a = 1;  wz = 4;  sg = 1.5;
x = linspace(-9, 9, 241);  [X, Y] = meshgrid(x, x);
dx = x(2) - x(1);
% turbulence field: smoothed Gaussian noise -> log-normal, larger than the view so it can drift
big = randn(241, 241 + 3*nf);
k = exp(-((-12:12)'.^2 + (-12:12).^2) / (2*4^2));
Z = conv2(big, k, 'same');  Z = Z / std(Z(:));
lens = (X.^2 + Y.^2) <= a^2;
pos = zeros(nf, 2);  pw = zeros(nf, 1);
rho = 0.85;
for f = 1:nf
    if f == 1, pos(f,:) = [0 0]; else, pos(f,:) = rho*pos(f-1,:) + sqrt(1 - rho^2)*sg*randn(1, 2); end
end
here = fileparts(mfilename('fullpath'));
d = fullfile(here, '..', 'figures', 'frames');
if ~exist(d, 'dir'), mkdir(d); end
I0 = 2/(pi*wz^2);
ref = sum(sum(I0 * lens)) * dx^2;            % power on the lens at perfect alignment, no turbulence
for f = 1:nf
    sc = exp(0.55*Z(:, (1:241) + 3*f) - 0.55^2/2);
    I = I0 * exp(-2*((X - pos(f,1)).^2 + (Y - pos(f,2)).^2) / wz^2) .* sc;
    pw(f) = sum(I(lens)) * dx^2 / ref;
    h = figure('visible', 'off', 'position', [0 0 1100 460], 'color', [0.03 0.02 0.06]);
    axes('position', [0.02 0.06 0.40 0.86]);
    imagesc(x, x, I / (I0*1.6));  axis xy equal tight;  colormap(gca, c.heat);  caxis([0 1]);  hold on;
    t = linspace(0, 2*pi, 100);
    plot(a*cos(t), a*sin(t), '-', 'color', [0 0.9 1], 'linewidth', 2.5);
    plot(pos(1:f,1), pos(1:f,2), '-', 'color', [1 1 1]*0.8, 'linewidth', 1);
    plot(pos(f,1), pos(f,2), '+', 'color', 'w', 'markersize', 14, 'linewidth', 2);
    set(gca, 'xtick', [], 'ytick', [], 'color', 'k');
    title('receiver plane: beam wander + scintillation', 'color', 'w', 'fontsize', 13);
    axes('position', [0.52 0.16 0.44 0.70]);
    semilogy(1:f, pw(1:f), '-', 'color', [1 0.6 0.1], 'linewidth', 2.5); hold on;
    semilogy(f, pw(f), 'o', 'color', [1 0.6 0.1], 'markerfacecolor', [1 0.9 0.4], 'markersize', 9);
    semilogy([1 nf], [0.1 0.1], '--', 'color', [0.9 0.2 0.4], 'linewidth', 1.8);
    text(2, 0.075, 'outage threshold', 'color', [0.9 0.2 0.4], 'fontsize', 12);
    xlim([1 nf]);  ylim([0.01 3]);  grid on;
    set(gca, 'color', [0.06 0.05 0.10], 'xcolor', [0.8 0.8 0.85], 'ycolor', [0.8 0.8 0.85], 'fontsize', 12, 'gridcolor', [0.5 0.5 0.6]);
    xlabel('time [frames]'); ylabel('collected power / aligned');
    title(sprintf('power on the lens: %.2f', pw(f)), 'color', 'w', 'fontsize', 13);
    set(h, 'inverthardcopy', 'off', 'PaperPositionMode', 'auto');
    print(h, fullfile(d, sprintf('f%03d.png', f)), '-dpng', '-r90');
    close(h);
end
end
