%MAIN  Runs every experiment of the FSO study and writes figures/ and results/.
%   Works in MATLAB (R2016b or newer, no toolboxes) and GNU Octave (6 or newer).
clear; close all;
here = fileparts(mfilename('fullpath'));
if isempty(here), here = pwd; end
addpath(fullfile(here, 'src'), fullfile(here, 'experiments'));
t0 = tic;
r1 = exp1_pdfs();
r2 = exp2_outage();
r3 = exp3_ook_ppm();
r4 = exp4_aperture();
r5 = exp5_diversity();
r6 = exp6_beamwidth();
make_frames();
fid = fopen(fullfile(here, 'results', 'summary.txt'), 'w');
fprintf(fid, 'Gamma-Gamma (alpha, beta): weak (%.2f, %.2f), moderate (%.2f, %.2f), strong (%.2f, %.2f)\n', [r1.alpha; r1.beta]);
fprintf(fid, 'Scintillation index theory %s, Monte Carlo %s\n', mat2str(r1.si_th, 3), mat2str(r1.si_sim, 3));
fprintf(fid, 'Outage slopes [regime pointing measured predicted]:\n%s\n', mat2str(r2.rows(:, [1 2 6 7]), 3));
fprintf(fid, 'SNR for BER 1e-4: OOK %.1f, 4-PPM %.1f, 8-PPM %.1f, 16-PPM %.1f dB\n', r3.need);
fprintf(fid, 'Aperture averaging at 2 km: SNR for BER 1e-5 %s dB for D = %s m\n', mat2str(r4.need, 3), mat2str(r4.Ds));
fprintf(fid, 'Diversity slopes [N measured predicted]: %s; SNR for 1e-3 outage %s dB\n', mat2str(r5.rows, 3), mat2str(r5.snr_1e3, 3));
fprintf(fid, 'Optimum beam (sigma_s/a, w_z/a, outage): %s\n', mat2str(r6.pick, 3));
fprintf(fid, 'Run time: %.0f s\n', toc(t0));
fclose(fid);
type(fullfile(here, 'results', 'summary.txt'));
