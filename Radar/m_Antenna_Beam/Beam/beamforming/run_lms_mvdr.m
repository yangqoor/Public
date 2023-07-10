function run_lms_mvdr(rp)

% MVDR adaptive beamforming using the LMS algorithm

Ninit   = rp.p;
Ndata   = Ninit + rp.Nsnaps;
seed    = 1;

% A_i, phi_l are target signal amplitude/elec- angle
% A_2, phi_2 are interference signal amplitude/elec- angle
% s is steering vector along elec. angle of look direction of interest

A_1 = sqrt(rp.var_v) * 10^(rp.TNRdB/20);
phi_1 = pi * rp.sin_theta_1;
A_2 = sqrt(rp.var_v) * 10^(rp.INRdB/20);
phi_2 = pi * rp.sin_theta_2;

s = exp(-j*[0:(rp.p-1)]'*phi_1);
e = s(2:rp.p);

% setup input/output sequences

for i = 1:Ndata,
   % setup random disturbances
   randn('seed', i);
   vr = sqrt(rp.var_v/2) * randn(1, rp.p) + rp.mean_v;
   vi = sqrt(rp.var_v/2) * randn(1, rp.p) + rp.mean_v;
   v  = vr + j*vi;
   rand('seed', i);
   Psi = 2*pi*rand(1);
   Xi(i, :) = A_1*exp(j*[1:rp.p]*phi_1) + A_2*exp(j*[1:rp.p]*phi_2 + Psi) + v;
end;

% setup effective desired output and input vectors from
% original data
g = 1;

d = g * Xi(:, 1);
u = diag(Xi(:, 1)) * (ones(Ndata, 1) * e.') - Xi(:, 2:rp.p);
   
[W, xp] = lms(u, d, rp.mu, rp.decay, rp.verbose);
Wo      = g - W * conj(e);
W       = [Wo W];

eval(['save ' rp.name])

