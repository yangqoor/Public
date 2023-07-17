load ForFigs

figure(1)
  plot(x,f_em(:,32),'r-d',x,f_tik(:,32),'g-*',x,f_TV_poisson_1e_m_5(:,32),'b-o',x,f_true(:,32),'k-')
  %legend('RL','Tikhonov','Total Variation','True Image')
  
figure(2)
  plot(x,f_em(32,:),'r-d',x,f_tik(32,:),'g-*',x,f_TV_poisson_1e_m_5(32,:),'b-o',x,f_true(32,:),'k-')
  legend('RL','Tikhonov','Total Variation','True Image','Location','NorthWest')

figure(3)
  plot(x,f_TV_poisson_1e_m_4(32,:),'b-o',x,f_TV_ls_reg(32,:),'r-d',x,f_TV_ls_nonneg(32,:),'g-*',x,f_true(32,:),'k-')
  legend('Poisson','Least Squares','Least Squares no Constraints','True Image','Location','NorthWest')
  axis([-1 1 -100 3000])
  
figure(4)
  plot(x,f_TV_poisson_1e_m_4(:,32),'b-o',x,f_TV_ls_reg(:,32),'r-d',x,f_TV_ls_nonneg(:,32),'g-*',x,f_true(:,32),'k-')
  %legend('Poisson','LS','LS no Constraints','True Image')
  axis([-1 1 -50 1400])
