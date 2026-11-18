function c = palette()
%PALETTE  "Infrared sunset" colours of the study.
c.weak   = [0.00 0.70 0.85];     % cyan
c.mod    = [1.00 0.55 0.00];     % orange
c.strong = [0.85 0.05 0.35];     % crimson
c.reg    = {c.weak, c.mod, c.strong};
c.ppm    = {[0.45 0.20 0.90], [0.10 0.55 1.00], [0.00 0.75 0.45]};
c.ook    = [0.85 0.05 0.35];
c.grey   = [0.35 0.35 0.40];
c.lw     = 2.6;
k = [0 0.02 0.02 0.08; 0.3 0.35 0.02 0.40; 0.6 0.95 0.30 0.10; 0.85 1.0 0.75 0.15; 1 1 1 0.85];
x = linspace(0, 1, 256)';
c.heat = [interp1(k(:,1),k(:,2),x) interp1(k(:,1),k(:,3),x) interp1(k(:,1),k(:,4),x)];
end
