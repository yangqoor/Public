function Y_test = grnnTest(Mu,Y_Mu,X_test,Sx)
% GRNN Algorithm - Testing 
% mu - set of input weights : L X D
% Y_Mu - set of output weights
% X_test : set of test patterns ; P X D : P is the number of patterns
% Sx : covariance of the trained input patterns

% number of test patterns
P_test = size(X_test,1);
L = size(Mu,1);
K = size(Y_Mu,2); % dimension of output Y
Y_test = zeros(P_test,K);

% Iterating through each pattern
for p = 1:1:P_test
    z = zeros(L,1); % declaring the ouput of the hidden nodes
    x = X_test(p,:);
    % applying to each hidden node (each cluster)
    for l = 1:1:L
        d = (x - Mu(l,:));
        di = Sx\d';
        val = sqrt(d*di) * 0.8326;
        z(l) = exp(-(val*val));
    end

    % if sum(z) == 0, then what?
    if(sum(z) == 0)
        z = z + 10^-23;
    end
    
    % applying the output 
    for k = 1:1:K
        y_mu = Y_Mu(:,k);
        Y_test(p,k) = sum(y_mu.*z)/sum(z);
    end
    
end


end

