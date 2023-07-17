function a = errmin_fun(alpha,f_0,Opt_params,Cost_params,Data)

%
%  Evaluate the Generalized Cross Validation Functional
%  GCV(alpha)= n||C^(-1/2)(Af_alpha-(z-gamma)||^2/...
%               trace(I-C^(-1/2)AA_alpha)^2
%  where
%  A_alpha = (D_a(T'C^(-1)T+alphaL)D_a)^(dagger)D_aT'C^(-1/2)
%  Note that randomized trace estimation is used.

% Extract needed parameters
    Cost_params.reg_param=alpha;
    t_hat = Cost_params.blurring_operator;
    d     = Cost_params.data;
    b     = Cost_params.Poiss_bkgrnd;
    sig   = Cost_params.gaussian_stdev;
    Tmult = Cost_params.Tmult_fn;
    const = Data.Poiss_bkgrnd + Data.gaussian_stdev^2;
    %  W = 1./([T*f_true]_i + bkgrnd + stdev^2);
    W = 1./(Data.noisy_data+Data.gaussian_stdev^2);

% Solve for f_alpha
[f] = gpnewton(f_0,Opt_params,Cost_params,Data);

a= norm(f(:)-Data.object(:))/norm(Data.object(:));
