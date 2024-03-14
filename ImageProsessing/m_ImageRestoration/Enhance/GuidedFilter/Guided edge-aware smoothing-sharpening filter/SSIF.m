function J = SSIF(I,G,radius,Epsilon,kappa,scale)
%An implementation of the "SSIF" filter published on the paper "A guided
%edge-aware smoothing-sharpening filter based on patch interpolation model 
% and generalized Gamma distribution"
%
%The algorithm description is here
%https://fergaletto.github.io/projects/2021-SSIF.html
%
% If you use this code, please cite the following paper:
%     @article{SSIF_Deng2021,
% 	    author={G. {Deng} and F. J. {Galetto} and M. {Al-nasrawi} and W. {Waheed}},
% 	    journal={IEEE Open Journal of Signal Processing}, 
% 	    title={A guided edge-aware smoothing-sharpening filter based on patch interpolation model and generalized Gamma distribution}, 
% 	    year={2021},
% 	    doi={10.1109/OJSP.2021.3063076}
%     }

padMethod = 'symmetric';
patchSize = 2*radius + 1;
h = ones(patchSize)/patchSize/patchSize;

mu = imfilter(I, h,padMethod);%patch mean of I
nu = imfilter(G, h,padMethod);%patch mean of G
phi = imfilter(I.*G, h,padMethod) - mu.*nu; %patch covariance
varSigma = max(0, imfilter(G.*G, h,padMethod) - nu.*nu); %patch var of G

a = phi./(varSigma + Epsilon);
Beta = (a + sign(phi).*sqrt(a.^2 + 4*kappa*Epsilon./(varSigma + Epsilon)))/2;

%weight calculation
w = varSigma./(scale*mean(varSigma(:)));
w = 1./(1+w.^2);
normalizeFactor = imfilter(w,h,padMethod);

%final output
A = imfilter(Beta.*w, h,padMethod);
B = imfilter((mu - Beta.*nu).*w, h,padMethod);
J = (G.*A + B)./normalizeFactor;
end

