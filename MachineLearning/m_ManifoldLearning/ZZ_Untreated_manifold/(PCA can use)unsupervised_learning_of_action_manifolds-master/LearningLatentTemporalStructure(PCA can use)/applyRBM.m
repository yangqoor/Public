function a_out = applyRBM(rbm,X)
% This function computes the RBM outputs for an input x
a_out = 1./(1 + exp(-1 * (X * rbm.W' + repmat(rbm.bh',size(X,1),1))));


end

