function s2 = rytov(Cn2, L, k)
%RYTOV  Rytov variance of a plane wave: sigma_R^2 = 1.23 Cn^2 k^(7/6) L^(11/6).
s2 = 1.23 * Cn2 .* k.^(7/6) .* L.^(11/6);
end
