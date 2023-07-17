%  Plot.m
%
%  Plot pgrad v. ffts for preconditioned and non-preconditioned
%  Convex-GPCG and lbfgs-b.

%% Initial guess ones
if 1
  load LBFGS2
  load KNITRO1
  load PREC1
  load NONPREC
  load WLS1
  load Data_toep_psf073_128
else
  load LBFGS1
  %load KNITRO2
  load PREC2
  %load NONPREC2
end


figure(10)
     xx = hist_prec(9,:);
     yy = hist_prec(3,:);
     semilogy(xx,yy,'--')

hold on

     xx = hist_nonprec(9,:);
     yy = hist_nonprec(3,:);
     semilogy(xx(1:196),yy(1:196),'-.')

hold on

     xx = hist_lbfgs(2,:);
     yy = hist_lbfgs(4,:);
     semilogy(xx(1:2570),yy(1:2570),'-')

hold on

     xx = hist_knitro(2,:);
     yy = hist_knitro(4,:);
kmax = 50;
     semilogy(xx(1:kmax),yy(1:kmax),'-o')

hold off

%---------------------------------------------------
%  Plot reconstructions.
%---------------------------------------------------


figure(11)
     xx = [97:128]; 
     yy = [1:32];
     mesh(xx,yy,f_prec(xx,yy))

figure(12)
     mesh(xx,yy,f_wls(xx,yy))

figure(13)
     mesh(xx,yy,Data.object(xx,yy))

c_hat = Data.BTTB_kernel_fft;
d = Data.noisy_data;
const = Data.Poiss_bkgrnd + Data.gaussian_stdev^2;
alpha = input('Regularization parameter = ');
inv_hat = conj(c_hat) ./ (abs(c_hat).^2 + const*alpha);
f_0 = bttb_mult_fft(d,inv_hat);

figure(14)
     mesh(xx,yy,f_0(xx,yy))
     
figure(15)
     mesh(xx,yy,Data.noisy_data(xx,yy))
