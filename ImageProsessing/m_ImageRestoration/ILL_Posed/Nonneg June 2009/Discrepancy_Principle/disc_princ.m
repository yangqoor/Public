function a = disc_princ(alpha,f_0,Opt_params,Cost_params,Data)

%
%  Evaluate (r(alpha)/n-1)^2 where
%  r(alpha) = ||C^(-1/2)(Tf_alpha-(d-b))||^2
%

Cost_params.reg_param=alpha;
t_hat = Cost_params.blurring_operator;
d     = Cost_params.data;
b     = Cost_params.Poiss_bkgrnd;
sig   = Cost_params.gaussian_stdev;
Tmult = Cost_params.Tmult_fn;

    [f] = gpnewton(f_0,Opt_params,Cost_params,Data);
    Kf = feval(Tmult,f,t_hat);
    W = 1./(Kf + b + sig^2);
    %W = 1./(d+sig^2); 
    resid_vec = Kf - (d-b);
      Wr = W .* resid_vec;
      F_alpha = resid_vec(:)'*Wr(:);
      n = Data.nx;
      n=n^2;
      a = (F_alpha/n-1)^2;