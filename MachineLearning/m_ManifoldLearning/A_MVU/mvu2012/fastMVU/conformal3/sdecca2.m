function  [P, newY, newE, cost, c]= sdecca2(Y, snn, regularizer, relative)
% doing semidefinitve embedding/MVU with output being parameterized by graph
% laplacian's eigenfunctions.. 
%
% the algorithm is same as conformal component analysis except that the scaling
% factor there is set as 1
%
%
% function [P, NY, NE, COST, C] = CDR2(X, Y, NEIGHBORS)  implements the 
% CONFORMAL DIMENSIONALITY REDUCTION of data X. It finds a linear map
% of Y -> L*Y such that X and L*Y is related by a conformal mapping.
%
% No tehtat  The algorithm use the formulation of only distances.
%
% Input:
%   Y: matrix of d'xN, with each column is a point in R^d'
%   NEIGHBORS: matrix of KxN, each column is a list of indices (between 1
%   and N) to the nearest-neighbor of the corresponding column in X
% Output:
%   P: square of the linear map L, ie, P = L'*L
%   NY: transformed data point, ie, NY = L*Y;
%   NE: eigenvalues of NY's covariance matrix 
%   COST: the value of the Conformal Dimensionality Reduction cost function
%   C:  a vector of length N, the optimal scaling factor for each data
%   point
%
% The algorithm finds L by solving a semidefinite programming problem. It
% calls csdp() SDP solver by default and assumes that it is on the path.
%
% written by feisha@cis.upenn.edu
% and by kedem.dor@wustl.edu


N = size(Y,2);
if length( sum(snn,1)) < N
    display('Your nearest neighbor graph is not connected!!!');
end


fprintf('===== collecting data needed for SDP formulation ========\n');
if exist('mexCCACollectData2') == 3
    fprintf('===> Use mexCCACollectData mex file \n');
    [erow, ecol,edist] = sparse_nn(snn);
    irow = int32(erow); icol = int32(ecol);
    [A,b, g] = mexCCACollectData2(Y, irow, icol, edist, int32(relative));
%    [A2,B2, g2] = mexCCACollectData(X,Y, irow, icol, int32(relative));
else
    error('Not implemented yet...exit..');
end
BG = 2*sum(b,2);
Q = A ;
[V, E] = eig(Q+eye(size(Q))); % adding an identity matrix to Q for numerical
E = E-eye(size(Q));           % stability
E(E<0) = 0;
if ~isreal(diag(E))
    warning('The matrix is not positive definite..forced to be positive definite...\n');
    E=real(E);
    V = real(V);
    S = sqrt(E)*V';
else
    S = sqrt(E)*V';
end

B = S;
B(~any(S,2),:) = []; % Referred as r in Wu, So, Li & Li


%clear Q;
% put the regularizer in there
BG = BG + regularizer*reshape(eye(size(Y,1)), size(Y,1)^2,1);

fprintf(' ==== formulating the problem as SQLP ======\n');
[AA, bb, cc, K] = formulateSQLP(B, size(Y,1), BG);
opts.printlevel = 1;

fprintf(' ===== Solve the SQLP problem =====\n');
[xx,yy,info] = sedumi(AA,bb, cc,K,opts);
fprintf('===== Solved the SQLP problem! =====\n' ); 

% Getting Y matrix from the solution.
P = reshape(xx(size(B,1) + 3:length(xx)), size(Y,1), size(Y,1));

% transform the original projection to the new
[V, E] = eig(P);
E(E<0) = 0; % make sure there is no very small negative eigenvalue
L = diag(sqrt(diag(E))) * V';
newY = L*Y;

% eigenvalue of the new projection, doing PCA using covariance matrix
% because the dimension of newY or Y is definitely less than the number of
% points
[newV, newE] = eig(newY *newY');
newE = diag(newE);
[dummy, idx] = sort(newE);
newE = newE(idx(end:-1:1));
newY = newV'*newY;
newY = newY(idx(end:-1:1),:);

cost = P(:)'*Q*P(:);
c = spdiags(1./sqrt(g),0, length(g),length(g))*b'*P(:);
return;


function[SedumiA, SedumiB, SedumiC, SedumiSettings] = formulateSQLP(B, m, bb)
% Formulating the problem as a Semidefinite–Quadratic–Linear Programming
% problem, according to "Fast Graph Laplacian Regularized Kernel Learning
% via Semidefinite–Quadratic–Linear Programming" by Wu, So, Li & Li,
% published on NIPS 2009:
% http://books.nips.cc/papers/files/nips22/NIPS2009_0792.pdf
%
% Written by Dor Kedem, kedem.dor@wustl.edu
% Washington University in St. Louis, 11/15/2010
%
    
    r = size(B,1);                                          % Referred as r in Wu, So, Li & Li
    
    % Building the SQLP in SeDuMi format
    %================================
    % Key concept: because there are two variables in the optimization problem
    % in the paper (u and y), we concatenate them together to one r+2+m^2
    % vector: [u; y].
    % Note that the output SeDuMi format is:
    %   Minimize c'x
    %     s.t. Ax = b
    
    % Setting up A = [ (e1 + e2)', 0; -C, B]
    SedumiA = sparse([],[],[],r+1, r + 2 + m^2, r+2 + r*(m^2));
    SedumiA(1,1:2) = [1; 1]; % e1 + e2 
    SedumiA(2:r+1, 3:r+2) = -eye(r); % -C
    SedumiA(2:r+1, r+3:r + 2 + m^2) = B; % B
    
    % Setting b = [1, 0, 0, ..., 0]
    SedumiB = zeros(r + 1, 1);
    SedumiB(1,1) = 1;
    
    % Setting c = [e1 - e2; b]
    SedumiC = zeros(r + 2 + m^2, 1);
    SedumiC(1:2, 1) = [1; -1];
    SedumiC(r+3:r + 2 + m^2) = -bb; 
    % IMPORTANT NOTE: the -bb above is because in Wu et. al (2009) the objective 
    % function is a minimization problem whereas in Weinberger et. al (2007)
    % it's a maximization problem.
    
    % Setting the additional constraints of the SQLP:
    SedumiSettings.q = [r + 2];     % u is a member of K.
    SedumiSettings.s = [m];           % Y is positive semidefinite.
    
return
