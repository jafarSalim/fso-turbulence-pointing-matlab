function pb = ber_ook(u)
%BER_OOK  On-off keying, IM/DD, Gaussian noise, threshold set at half the received level:
%   P_b = Q(u), u = g sqrt(gamma0), gamma0 = (P/sigma)^2.
pb = 0.5 * erfc(u / sqrt(2));
end
