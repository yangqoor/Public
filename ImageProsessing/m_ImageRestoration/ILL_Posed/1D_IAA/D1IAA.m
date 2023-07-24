function x =  D1IAA(y, K)
% function w =  IAA(y, M, K)
 M = length(y);
 m = 0:M-1;
 k = 0:K-1;
 A_M = exp(1i*2*pi*m.'*k/K); 
 P = eye(K,K);
 not = 10;
 for run = 1:not
      R_M = A_M*P*A_M';
%       for k = 0:K-1
%       a_k = A_M(:,k+1);
%       b_k = a_k'/R_M;
%       x(k+1) = b_k*y/(b_k*a_k);
%       end
      b_k = A_M'/R_M;
      a_M = diag(b_k*A_M);
      x = (b_k*y)./a_M;
      p1 = abs(x).^2;
      P = diag(p1);
 end
 x1 =  x(1:K/2);
[max1,NH] = max((abs(x1)));
w = (NH-1)*2*pi/K;
% Y = abs(x)
% Y1 = max(Y)
% plot (k/K, Y, 'b--')
% [p q] = find(Y == Y1)
% NH = min(p);
% w = (NH-1)*2*pi/K;

      
        
     