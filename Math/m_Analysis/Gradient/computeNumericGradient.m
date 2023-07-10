function numgrad = computeNumericGradient(J, theta)
n = length(theta);
numgrad = zeros(n, 1);
epsilon = 1e-4;
thetaMinus = bsxfun(@minus, theta, epsilon*eye(n)) ;
thetaPlus = bsxfun(@plus, theta, epsilon*eye(n));
for i = 1:n,
    numgrad(i) = (J(thetaPlus(:, i)) - J(thetaMinus(:, i)))/2/epsilon;
end