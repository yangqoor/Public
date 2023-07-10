%Samuel Rivera
%date: Nov 2, 2009
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
%
% notes:  This function does the gradient descent for a function with
% missing output values.  IT can deal with regular system as well as with
% kernels.  New kernels can easily be added by defining the Gram matrix
%
%first parameter is lambda
% second parameter is sigma for RBF kernel
%
% p is dimensionality of input data
% d is dimensionality of output data
% n is number of training samples

% X is a pxn matrix where each column is a training sample input
% Y is a dxn matrix where each column
%
% W0 or W is a pxd matrix corresponding to the parameters we want to the d
%   columns of p parameters we want to optimize.  each of the columns is the
%   linear function for a particular output.  W0 is start value, W is final
%
% M is a dxn matrix, where m_{ij} = 0 if ith output of jth sample unknown,
%   else = 1
% a is step size

function [e W k YtrueMinusEst Yest ] = gradDescMissing( X, x, Y, y, W0, ...
                                M, a, tol, maxIters, ridge, kernel, params, ...
                                forceGradientDescent)

%commont between the following two bars when running for real
% %------------------------------------------------------------------
% maxIters = 10000;
% a = 1; %step size
% tol = .5; % norm of gradient should be bigger than this
% n = 20;
% p = 5;
% d = 1;
% WTrue  = [ linspace( 2, 6, p)'; 1];
% X = [ 5*rand( p,n); ones(1,n) ];
% Y = WTrue'*X;
% 
% % M = ones( d,n);
% M =  rand(d,n); 
% M( M >= .2) = 1;
% M( M < .2 ) = 0;
% 
% ridge = 0;  
% W0 = rand(p+1,d ); %initialize W
% 
% kernel = 1;   %1 if RBF kernel space, 0 of regular space
% if kernel >= 1
%     W0 = rand( n,d);
% end
%     
% params = [ .001; .1]; 

%--------------------------------------------------------------------

if isempty( W0 )
   W0 = rand( size( X,1), size(Y,1) );  
end

%pad ones to end of X if its not already there
if X(end,:) ~= ones( 1, size(X,2) );
%     display( 'Padding input with ones before doing regression' );
    X =  [X ; ones( 1, size(X,2)) ];
    x =  [x ; ones( 1, size(x,2)) ];
    W0 = [W0; rand( 1, size(W0,2)) ];
end

if ridge
    lambda = params(1)/size(X,2);  %to account for different numbers of training data
                        % this has problems, so not using it.
else
    lambda = 0;
end
if kernel 
    sigma = params(2);
end

%must do before start iterations
[d n]  = size( Y );
updateSize = inf; %to ensure it starts, this should be large
k= 0;

if kernel >= 0
    
    if kernel == 0  %linear regression
        Gtemp = [X x]'*[X x];
        kvec = Gtemp( 1:n, n+1:end);
        K = Gtemp( 1:n, 1:n);
        clear Gtemp
    
    elseif kernel == 1
        Gtemp = rbf( [X x]', sigma );
        kvec = Gtemp( 1:n, n+1:end);
        K = Gtemp( 1:n, 1:n);
        clear Gtemp
           
    elseif kernel >= 1
        % K = X'*X;
        error( 'Wrongly specified Kernel' );
    end

    
    if  isempty(M) && ~forceGradientDescent
        W = (Y*((K + lambda.*eye(n))\eye(n)))';   %*inv( G + lambda.*eye(n));
        k = 1;
    
    else
        
        if sum( size( W0 ) ~= [ size( K,1) size(Y,1) ] )
           W0 = rand( size( K,1), size(Y,1) );  
        end    
            
        W = W0;  %in this case, the W is kind of like the A or alpha matrix
        Fold =  calcFKernel(K ,Y, W, M, ridge, lambda);
        while k <= maxIters && updateSize > tol
            %---------------------------------
            % calculate gradient, and update the estimate using steepest descent. 
            % since W is a matrix, we output it that way, but 
            %it can be vectorized no problem 

            dFdW = zeros( size(W));
            %check if no missing data, do this without loops
            if M == ones( size(M))
                %display( 'Calculating Fast Gradient');
                dFdW = -2*K'*Y' + 2*(K'*K)*W;
            else
                for i1 = 1:d
                    for j1 = 1:n
                        dFdWTemp = -2*M(i1,j1)*( Y(i1,j1) - W(:,i1)'*K(:,j1))*K(:,j1);
                        dFdW(:,i1) = dFdW(:,i1) + dFdWTemp;
                    end
                end
            end
            
            if ridge
                dFdW = dFdW + lambda*2*W;
            end
            

            updateSize = ( trace( dFdW'*dFdW ))^.5;
            dFdW = normc( dFdW );

            Wlast = W;
            W =  Wlast - a*dFdW;

            %make sure step size is working, otherwise reduce
            Fnew = calcFKernel(K ,Y, W, M, ridge, lambda);
            if Fnew > Fold
               a = .5*a; 
            end
            Fold = Fnew;

            k = k+1;

        end   
        
    end
    
    Yest =  W'*kvec;
    YtrueMinusEst = y - Yest;
    e = ( mean(  YtrueMinusEst(:).^2 ,1));
    
end


function F = calcF(X,Y, W, M, ridge, lambda )
%--------------------------------
% F is squared cost function for linear ridge regression  

F = 0; % total F
for j1 = 1:size(X,2)
    for i1 = 1:size(W,2)
        fTemp = M(i1,j1)*( Y(i1,j1) - W(:,i1)'*X(:,j1) )^2; 
        F = F + fTemp;
    end
end
if ridge
    F = F + lambda*trace( W'*W);
end

function F = calcFKernel(K ,Y, W, M, ridge, lambda)
%--------------------------------

% F is squared cost function for Kernel ridge regression  
F = 0; % total F
for j1 = 1:size(K,2)
    for i1 = 1:size(W,2)
        fTemp = M(i1,j1)*( Y(i1,j1) - W(:,i1)'*K(:,j1) )^2; 
        F = F + fTemp;
    end
end

if ridge
    F = F  + lambda*trace( W'*K*W);
  
end

% Wtrue3 = inv(X*X')*X*Y';  NEVER USE INV
% Wtrue2 = pinv(X')*Y';
% Wtrue1 = X'\Y';
