% Sample code of the paper:
% 
% Sayantan Dutta, Adrian Basarab, Bertrand Georgeot, and Denis Kouamé,
% “Quantum mechanics-based signal and image representation: Application
% to denoising,” IEEE Open Journal of Signal Processing, vol. 2, pp. 190–206, 2021.
% 
% MATLAB code prepard by Sayantan Dutta
% E-mail: sayantan.dutta@irit.fr and sayantan.dutta110@gmail.com
% 
% This script shows an example of calling our denoising algorithm 
% for image using Quantum adaptative basis (QAB)
%---------------------------------------------------------------------------------------


function [psi,psi_cols,E] = f_ondes2D(image,poids)
%
%the Hamiltonian associates with the signal and the associated eigenvalues
% The function calculates the eigenvectors and eigenvalues of the Hamiltonian of the image.
%A column of psi_cols contains an eigenvector.

%size of image
[N,M] = size(image); % On supposera N = M
dim = N^2;
imVect = reshape(image,[1 dim]);

% creat space to store data
psi_tmp = zeros(dim,dim);   %eigenvectors
E = zeros(dim,1);           %eigenvalues
   
% Construction of Hamiltonian matrice H
terme_hsm = ones(1,dim) * poids;
H = diag(imVect,0) + diag(terme_hsm,0)*4 ...
    - diag(terme_hsm(1:dim-1),-1) - diag(terme_hsm(1:dim-1),1) ...
    - diag(terme_hsm(1:dim-N),-N) - diag(terme_hsm(1:dim-N),N);% ...

% Effect of the boundary conditions
for bloc = 0:(N-1) % Boucle sur les lignes de l'image/ Loop on the lines of the image
    H(1+N*bloc,1+N*bloc) = H(1+N*bloc,1+N*bloc) - poids;
    H(N*(bloc+1),N*(bloc+1)) = H(N*(bloc+1),N*(bloc+1)) - poids;
end

for ligne = 1:N % Modification du 1er et dernier bloc/ Modification of the 1st and last block
    H(ligne,ligne) = H(ligne,ligne) - poids;
    H(dim + 1 - ligne,dim + 1 - ligne) = H(dim + 1 - ligne,dim + 1 - ligne) - poids;
end
    
for inter = 1:(N-1) % Boucle le coin des blocs (qui forment les lignes)/Loop the corner of the blocks (which form the lines)
    H(N*inter+1,N*inter) = 0;
    H(N*inter,N*inter+1) = 0;
end

% Calculation of eigenvalues and eigenvectors
 [vectP,valPmat] = eig(H);
%[vectP,valPmat] = eigs(H,(dim/2),0);

valPmat = diag(valPmat);
vpM = max(valPmat);

for g = 1:(dim/1) 
% Each iteration finds the "following" eigenvector
%(sorts the vectors in ascending order of the associated eigenvalues)
    
[E_min, i_min] = min(valPmat);
psi_tmp(:,g) = vectP(:,i_min);
E(g) = E_min;
valPmat(i_min) = vpM + 1;

end

psi = reshape(psi_tmp,N,N,dim);
psi_cols = psi_tmp;

end

    