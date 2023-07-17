iters = input(' Number of iterations = ');

[x_MRNSD, k, Rnrm, Xnrm, Enrm_MRNSD] = MRNSD(S, b, b, iters, 0, scale_x_true);

[x_MRNSD_wt, k, Rnrm, Xnrm, Enrm_MRNSD_wt] = ...
                         MRNSD_wt(S, b, b, iters, 0, scale_x_true,noise_info);

figure(10)
  plot(Enrm_MRNSD_wt,'g--')
  hold on
  plot(Enrm_MRNSD,'g-')
  title('solid = MRNSD, dashed = Weighted MRNSD')
  hold off
