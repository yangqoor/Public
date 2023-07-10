function [ix] = l_curve1(U,sm,b,L,V,riss)

%method='tsvd';
%disp(['  Нахождение параметра метода ' method ' с помощью L-кривой'])

%  Фрагменты аналогичного модуля Хансена
[m,n] = size(U); [p,ps] = size(sm);
locate = 1; 
beta = U'*b; beta2 = b'*b - beta'*beta;
if (ps==1)
  s = sm; beta = beta(1:p);
else
  s = sm(p:-1:1,1)./sm(p:-1:1,2); beta = beta(p:-1:1);
end
xi = beta(1:p)./s;
  eta = zeros(p,1); rho = eta;
  eta(1) = xi(1)^2;
  for k=2:p, eta(k) = eta(k-1) + xi(k)^2; end
  eta = sqrt(eta);
  if (m > n)
    if (beta2 > 0), rho(p) = beta2; else rho(p) = eps^2; end
  else
    rho(p) = eps^2;
  end
  for k=p-1:-1:1, rho(k) = rho(k+1) + beta(k+1)^2; end
  rho = sqrt(rho);
  reg_param = [1:p]'; marker = 'o-'; pos = .75;
  if (ps==1)
    U = U(:,1:p); txt = 'TSVD';
  else
    U = U(:,1:p); txt = 'TGSVD';
  end
  
%  l_corner  
  
  s_thr = eps;  % Neglect singular values less than s_thr.

% Set default parameters for treatment of discrete L-curve.
deg   = 2;  % Degree of local smooting polynomial.
q     = 2;  % Half-width of local smoothing interval.
order = 4;  % Order of fitting 2-D spline curve.
% Initialization.
if (length(rho) < order)
  error('Too few data points for L-curve analysis')
end

  [p,ps] = size(s); [m,n] = size(U);
  if (ps==2), s = s(p:-1:1,1)./s(p:-1:1,2); U = U(:,p:-1:1); end
  beta = U'*b; xi = beta./s;

% Restrict the analysis of the L-curve according to M (if specified)
% and s_thr.
%  index = find(eta < M);
%  rho = rho(index); eta = eta(index); reg_param = reg_param(index);
%  s = s(index); beta = beta(index); xi = xi(index);

    index = find(s > s_thr);
    rho = rho(index); eta = eta(index); reg_param = reg_param(index);
    s = s(index); beta = beta(index); xi = xi(index);

  lr = length(rho);
  lrho = log(rho); leta = log(eta); slrho = lrho; sleta = leta;

  % For all interior points k = q+1:length(rho)-q-1 on the discrete
  % L-curve, perform local smoothing with a polynomial of degree deg
  % to the points k-q:k+q.
  v = [-q:q]'; A = zeros(2*q+1,deg+1); A(:,1) = ones(length(v),1);
  for j = 2:deg+1, A(:,j) = A(:,j-1).*v; end;
  for k = q+1:lr-q-1;
    cr = A\lrho(k+v); slrho(k) = cr(1);
    ce = A\leta(k+v); sleta(k) = ce(1);
  end

D0=diff(leta)./diff(lrho);D=[D0;D0(end)];DD0=diff(D)./diff(lrho);DD=[DD0;DD0(end)];
kr=abs(DD)./(1+D.^2).^(3/2);[mm,ix]=max(kr);
if ix==1;ix=ix+1;end
if riss==1;
  figure(20);clf;subplot(2,2,1);plot(lrho,leta,'.-',lrho(ix),leta(ix),'*r')
  set(gca,'FontName','Arial Cyr','FontSize',9);
  title('L-кривая и выбранная ее точка (*)');
  xlabel('lg||Az_k-u_{\delta}||');ylabel('lg||z_k||');
  axis equal

  %subplot(2,1,1);plot(lrho,leta,'.-',lrho(ix),leta(ix),'or')
  %axis equal
  %subplot(2,1,2);plot(lrho,kr,'.-',lrho(ix),kr(ix),'or')
   % axis equal

end
