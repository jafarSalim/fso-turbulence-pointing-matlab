function F = channel_cdf(g, a, b, xi2)
%CHANNEL_CDF  CDF of the normalized channel g = h_a h_p / A0 (turbulence x pointing).
%   With pointing, P(h_p/A0 <= x) = x^(xi^2) for x <= 1, so
%     F(g) = E_ha[ min(1, (g/h_a)^(xi^2)) ]
%   is a one-dimensional integral over the closed-form Gamma-Gamma density.
%   xi2 = Inf means no pointing error (F = Gamma-Gamma CDF).
ha = logspace(-16, 2.2, 7000)';
w = gg_pdf(ha, a, b) .* gradient(ha);          % quadrature weights on a log grid
w = w / sum(w);
F = zeros(size(g));
for i = 1:numel(g)
    if isinf(xi2)
        F(i) = sum(w(ha <= g(i)));
    else
        F(i) = sum(w .* min(1, (g(i)./ha).^xi2));
    end
end
end
