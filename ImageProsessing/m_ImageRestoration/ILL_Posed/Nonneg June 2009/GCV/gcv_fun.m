function a = gcv_fun(alpha,f_0,Opt_params,Cost_params,Data)

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
   
    W = 1./(Data.noisy_data+Data.gaussian_stdev^2);

% Solve for f_alpha
   [f] = gpnewton(f_0,Opt_params,Cost_params,Data);
    Kf = feval(Tmult,f,t_hat);
    Cost_params.WeightMat = W;
%--------------------------------------------------
% Evaluate GCV functional
%--------------------------------------------------
     resid_vec = Kf - (d-b);
      Wr = W .* resid_vec;
      F_alpha = resid_vec(:)'*Wr(:);
      n = Data.nx;
      n=n^2;
     v_vec = randn(Data.nx,Data.ny);
    L = Cost_params.reg_operator;
    D_alpha=(f>0);
    Cost_params.D_alpha = D_alpha;
    Cost_params.nx = Data.nx;
    
    %Set up CG parameters
     Cost_params.max_cg_iter = 100;%      Maximimum number of CG iterations.
    Cost_params.cg_step_tol = 1e-4; %      Stop CG when ||x_k+1 - x_k|| < step_tol.
    Cost_params.grad_tol_factor = 1e-4;%   Stop CG when ||g_k|| < grad_tol_factor*||g_0||.
    Cost_params.cg_io_flag = 0;%       Output CG info if ioflag = 1.
    Cost_params.cg_figure_no = 10;%     Figure number for CG output.
    
    
    
    %Use CG to solve w = A_alpha*v
    if Data.type == 'toep'
        AAtWv = feval(Tmult,(W.^(1/2)).*v_vec,conj(t_hat));
        bb = D_alpha.*AAtWv;
        w=cg_paramselect(ones(n,1),bb(:),Cost_params,'cg_bttb_mult_fft');
    elseif Data.type == 'circ'
        AAtWv = feval(Tmult,(W.^(1/2)).*v_vec,conj(t_hat));
        bb = D_alpha.*AAtWv;
         w=cg_paramselect(ones(n,1),bb(:),Cost_params,'cg_bccb_mult_fft');
    end
    w = reshape(w,Data.nx,Data.nx);
     Aw = feval(Tmult,w,t_hat);
   CAw = (W.^(1/2)).*Aw;
     a = n*F_alpha/(v_vec(:)'*v_vec(:)-v_vec(:)'*CAw(:))^2;
    