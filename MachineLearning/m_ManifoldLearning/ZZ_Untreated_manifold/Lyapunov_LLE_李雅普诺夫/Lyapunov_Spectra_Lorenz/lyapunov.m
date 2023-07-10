function [Texp,Lexp]=lyapunov(n,rhs_ext_fcn,fcn_integrator,tstart,stept,tend,ystart,ioutp,params)
% lyapunov.m
% Adapted from lyapunov.m by Govorukhin V.N. from the Matlab File Exchange
% by Daniel Borrero - 8/18/2013
% ----------------------------------------------------------------------
% This function was modified to allow for ODE-system parameters to be 
% entered as inputs rather than hard coded into the function defining 
% the extended ODE system. The original documentation by Govorukhin 
% follows below:
%
%    Lyapunov exponent calcullation for ODE-system.
%
%    The alogrithm employed in this m-file for determining Lyapunov
%    exponents was proposed in
%
%         A. Wolf, J. B. Swift, H. L. Swinney, and J. A. Vastano,
%        "Determining Lyapunov Exponents from a Time Series," Physica D,
%        Vol. 16, pp. 285-317, 1985.
%
%    For integrating ODE system can be used any MATLAB ODE-suite methods. 
% This function is a part of MATDS program - toolbox for dynamical system investigation
%    See:    http://www.math.rsu.ru/mexmat/kvm/matds/
%
%    Input parameters:
%      n - dimension of original system
%      rhs_ext_fcn - function handle for right hand side of extended ODE-system.
%              This function must include RHS of ODE-system coupled with 
%              variational equation (n items of linearized systems (see example below).                   
%      fcn_integrator - handle of ODE integrator function, for example: @ode45                  
%      tstart - starting value of time t
%      stept - step on t-variable for Gram-Schmidt renormalization procedure.
%      tend - final value of t
%      ystart - initial condition for ODE system
%      ioutp - step of print to MATLAB main window. ioutp==0 - no print, 
%              if ioutp>0 then each ioutp-th point will be print.
%
%    Output parameters:
%      Texp - time values
%      Lexp - Lyapunov exponents to each time value.
%
%    Users have to write their own ODE functions for their specified
%    systems and use handle of this function as rhs_ext_fcn - parameter.      
%
%    Example. Lorenz system:
%               dx/dt = sigma*(y - x)     = f1
%               dy/dt = r*x - y - x*z = f2
%               dz/dt = x*y - b*z     = f3
%
%    The Jacobian of system: 
%        | -sigma  sigma  0 |
%    J = |   r-z    -1   -x |
%        |    y      x   -b |
%
%    Then, the variational equation has a form:
% 
%    F = J*Q
%    where Q is a square matrix with the same dimension as J.
%    Corresponding m-file:
%        function f=lorenz_ext(t,X)
%         SIGMA = 10; R = 28; BETA = 8/3;
%         x=X(1); y=X(2); z=X(3);
%
%         Q= [X(4), X(7), X(10);
%             X(5), X(8), X(11);
%             X(6), X(9), X(12)];
%         f=zeros(9,1);
%         f(1)=SIGMA*(y-x); f(2)=-x*z+R*x-y; f(3)=x*y-BETA*z;
%
%         Jac=[-SIGMA,SIGMA,0; R-z,-1,-x; y, x,-BETA];
%  
%         f(4:12)=Jac*Q;
%
%    Run Lyapunov exponent calculation:
%     
%    [T,Res]=lyapunov(3,@lorenz_ext,@ode45,0,0.5,200,[0 1 0],10);   
%   
%    See files: lorenz_ext, run_lyap.   
%  
% --------------------------------------------------------------------
% Copyright (C) 2004, Govorukhin V.N.
% This file is intended for use with MATLAB and was produced for MATDS-program
% http://www.math.rsu.ru/mexmat/kvm/matds/
% lyapunov.m is free software. lyapunov.m is distributed in the hope that it 
% will be useful, but WITHOUT ANY WARRANTY. 
%

% Integrator options
options = odeset('AbsTol',1e-8,'RelTol',1e-8);
%options = [];

%
%       n=number of nonlinear odes
%       n2=n*(n+1)=total number of odes
%

n1=n; n2=n1*(n1+1);

%  Number of steps

nit = round((tend-tstart)/stept);

% Memory allocation 

y=zeros(n2,1); cum=zeros(n1,1); y0=y;
gsc=cum; znorm=cum;

% Initial values

y(1:n)=ystart(:);

for i=1:n1 y((n1+1)*i)=1.0; end;

t=tstart;

% Main loop

for ITERLYAP=1:nit

% Solution of extended ODE system 
% This line was modified by DB to accept parameters as an input
% additional integrator options generated with odeset can be included 
% in the second-to-last input. Parameters are input in the last input.


  [T,Q] = feval(fcn_integrator,rhs_ext_fcn,[t t+stept],y,options,params);
  
  t=t+stept;
  y=Q(size(Q,1),:);

  for i=1:n1 
      for j=1:n1 y0(n1*i+j)=y(n1*j+i); end;
  end;

%
%  Construct new orthonormal basis by gram-schmidt
%

  znorm(1)=0.0;
  for j=1:n1 znorm(1)=znorm(1)+y0(n1*j+1)^2; end;

  znorm(1)=sqrt(znorm(1));

  for j=1:n1 y0(n1*j+1)=y0(n1*j+1)/znorm(1); end;

  for j=2:n1
      for k=1:(j-1)
          gsc(k)=0.0;
          for l=1:n1 gsc(k)=gsc(k)+y0(n1*l+j)*y0(n1*l+k); end;
      end;
 
      for k=1:n1
          for l=1:(j-1)
              y0(n1*k+j)=y0(n1*k+j)-gsc(l)*y0(n1*k+l);
          end;
      end;

      znorm(j)=0.0;
      for k=1:n1 znorm(j)=znorm(j)+y0(n1*k+j)^2; end;
      znorm(j)=sqrt(znorm(j));

      for k=1:n1 y0(n1*k+j)=y0(n1*k+j)/znorm(j); end;
  end;

%
%       update running vector magnitudes
%

  for k=1:n1 cum(k)=cum(k)+log(znorm(k)); end;

%
%       normalize exponent
%

  for k=1:n1 
      lp(k)=cum(k)/(t-tstart); 
  end;

% Output modification

  if ITERLYAP==1
     Lexp=lp;
     Texp=t;
  else
     Lexp=[Lexp; lp];
     Texp=[Texp; t];
  end;

  if (mod(ITERLYAP,ioutp)==0)
     fprintf('t=%6.4f',t);
     for k=1:n1 fprintf(' %10.6f',lp(k)); end;
     fprintf('\n');
  end;

  for i=1:n1 
      for j=1:n1
          y(n1*j+i)=y0(n1*i+j);
      end;
  end;

end;
