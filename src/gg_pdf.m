function f = gg_pdf(h, a, b)
%GG_PDF  Gamma-Gamma irradiance density (unit mean), evaluated in logs for stability:
%   f(h) = 2 (ab)^((a+b)/2) / (G(a) G(b)) h^((a+b)/2-1) K_(a-b)(2 sqrt(ab h)).
z = 2*sqrt(a*b*h);
lf = log(2) + (a+b)/2*log(a*b) - gammaln(a) - gammaln(b) + ((a+b)/2 - 1)*log(h) ...
     + log(besselk(a - b, z, 1)) - z;
f = exp(lf);
f(h <= 0) = 0;
end
