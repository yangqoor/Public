function [ e YtrueMinusEst Yest ] = lasso( X, x, Y, y, params, modelFile )
%Code implemented by Samuel Rivera, sriveravi@gmail.com
%X = p x n matrix of n samples, p parameters
%Y = d x n matrix of corresponding outputs

 
lambda = params(1);
% sigma = params(2);

[d N ] = size( Y );
p = size( X,1);

%meat and potatoes
B0 = zeros( p ,2);
betaHat = zeros( p, d);

for i = 1: size(Y,1)
    
    fun = @(B) (Y(i,:)' - X'*(B(:,1) - B(:,2)))'*(Y(i,:)' - X'*(B(:,1) - B(:,2)))+ lambda.*ones(1,p)*B*ones(2,1);

    beta = fmincon(fun,B0, [],[],[], [],B0,inf );
    betaHat(:,i) = beta(:,1) - beta(:,2);
    
end

Yest = betaHat'*x; 

YtrueMinusEst = y - Yest;
e = ( mean(  YtrueMinusEst(:).^2 ,1));



