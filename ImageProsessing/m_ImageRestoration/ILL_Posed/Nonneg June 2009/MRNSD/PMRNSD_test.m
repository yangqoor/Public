iters = input(' Number of iterations = ');

[x_PMRNSD, k, Rnrm, Xnrm, Enrm_PMRNSD] = ...
                          PMRNSD(S, P, b, b, iters, 0, scale_x_true);

[x_PMRNSD_wt, k, Rnrm, Xnrm, Enrm_PMRNSD_wt] = ...
               PMRNSD_wt(S, P, b, b, iters, 0, scale_x_true,noise_info);

figure(10)
  plot(Enrm_PMRNSD_wt,'g--')
  hold on
  plot(Enrm_PMRNSD,'g-')
  title('solid = PMRNSD, dashed = Weighted PMRNSD')
  hold off
