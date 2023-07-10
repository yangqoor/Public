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
%
%
%

% This file is part of the Matlab Toolbox for Dimensionality Reduction v0.2b.
% The toolbox can be obtained from http://www.cs.unimaas.nl/l.vandermaaten
% You are free to use, change, or redistribute this code in any way you
% want. However, it is appreciated if you maintain the name of the original
% author.
%
% (C) Laurens van der Maaten
% Maastricht University, 2007

    N = size(Y,2);

    if exist('mexCCACollectData2') == 3
        [erow, ecol,edist] = sparse_nn(snn);
        irow = int32(erow); icol = int32(ecol);
        [A,B, g] = mexCCACollectData2(Y, irow, icol, edist, int32(relative));
    %    [A2,B2, g2] = mexCCACollectData(X,Y, irow, icol, int32(relative));
    else
        error('Make sure you have run MEXALL before attempting to use this technique.');
    end
    BG = 2*sum(B,2);
    Q = A ;
    [V, E] = eig(Q+eye(size(Q))); % adding an identity matrix to Q for numerical
    E = E-eye(size(Q));           % stability
    E(E<0) = 0;
    if ~isreal(diag(E))
        warning('The matrix is not positive definite. It is being made positive definite now...');
        E=real(E);
        V = real(V);
        S = sqrt(E)*V';
    else
        S = sqrt(E)*V';
    end

    %clear Q;
    % put the regularizer in there
    BG = BG + regularizer*reshape(eye(size(Y,1)), size(Y,1)^2,1);
    % formulate the SDP problem
    [AA, bb, cc] = formulateSDP(S, size(Y,1), BG);
    sizeSDP = size(Y,1)^2+1 + size(Y,1);
    pars.s = sizeSDP;
    opts.printlevel = 1;

    % solve it via csdp
    [xx, yy, zz, info] = csdp(AA, bb, cc, pars,opts);

    % the negate of yy is our solution
    yy = -yy;
    idx = 0;
    P = zeros(size(Y,1));
    for col=1:size(Y,1)
        for row = col:size(Y,1)
            idx=idx+1;
            P(row, col) = yy(idx);
        end
    end
    % convert P to a positive definite matrix
    P = P+P' - diag(diag(P));

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
    %c = spdiags(1./sqrt(g),0, length(g),length(g))*B'*P(:);
    c=[];
    return;



    function [A, b, c]=formulateSDP(S, D, bb)
    [F0, FI, c] = localformulateSDP(S, D, bb);
    [A, b, c] = sdpToSeDuMi(F0, FI, c);
    return

    function [F0, FI, c] = localformulateSDP(S, D, b)
    % formulate SDP problem
    % each FI that corresponds to the LMI for the quadratic cost function has
    % precisely 2*D^2 nonzero elements. But we need only D^2 storage for
    % indexing these elements since the FI are symmetric
    tempFidx = zeros(D^2, 3);
    dimF = (D^2+1) + D;
    idx= 0;
    for col=1:D
        for row=col:D
            idx = idx+1;
            lindx1 = sub2ind([D D], row, col);
            lindx2 = sub2ind([D D], col, row);
            tempFidx(:,1) = [1:D^2]';
            tempFidx(:,2) = D^2+1;
            if col==row
                tempFidx(:,3) = S(:, lindx1) ;
                FI{idx} = sparse([tempFidx(:,1); ...  % for cost function
                                    tempFidx(:,2); ... % symmetric
                                    row+D^2+1 ... % for P being p.s.d

                                ], ...
                                [tempFidx(:,2); ...  % for cost function
                                    tempFidx(:,1); ... % symmetric
                                    row+D^2+1; ... % for P being p.s.d

                                ],...
                                [tempFidx(:,3); ... % for cost function
                                    tempFidx(:,3); ... % symmetric
                                    1;                  % for P being p.s.d

                                ], dimF, dimF);
            else

                tempFidx(:,3) = S(:, lindx1) + S(:, lindx2);
                FI{idx} = sparse([tempFidx(:,1); ...  % for cost function
                                    tempFidx(:,2); ... % symmetric
                                    row+D^2+1; ... % for P being p.s.d
                                    col+D^2+1; ... % symmetric
                                ], ...
                                [tempFidx(:,2); ...  % for cost function
                                    tempFidx(:,1); ... % symmetric
                                    col+D^2+1; ... % for P being p.s.d
                                    row+D^2+1; ... % being symmetric
                                ],...
                                [tempFidx(:,3); ... % for cost function
                                    tempFidx(:,3); ... % symmetric
                                    1;                  % for P being p.s.d
                                    1;                  % symmetric
                                ], dimF, dimF);

            end
        end
    end
    idx=idx+1;
    % for the F matrix corresponding to t
    FI{idx} = sparse(D^2+1, D^2+1, 1, dimF, dimF);

    % now for F0
    F0 = sparse( [[1:D^2]], [[1:D^2]], [ones(1, D^2)], dimF, dimF);

    % now for c
    b = reshape(-b, D, D);
    b = b*2 - diag(diag(b)); 
    c = zeros(idx-1,1);
    kdx=0;
    %keyboard;
    for col=1:D
        for row=col:D
          kdx = kdx+1;
          c(kdx) = b(row, col);
        end
    end
    %keyboard;
    c = [c; 1]; % remember: we use only half of P
    return;


    function [A, b, c] = sdpToSeDuMi(F0, FI, cc)
    % convert the canonical SDP dual formulation:
    % (see  Vandenberche and Boyd 1996, SIAM Review)
    %  max -Tr(F0 Z)
    % s.t. Tr(Fi Z) = cci and Z is positive definite
    %
    % in which cc = (cc1, cc2, cc3,..) and FI = {F1, F2, F3,...}
    % 
    % to SeDuMi format (formulated as vector decision variables ):
    % min c'x
    % s.t. Ax = b and x is positive definite (x is a vector, so SeDuMi
    % really means that vec2mat(x) is positive definite)
    %
    % by feisha@cis.upenn.edu, June, 10, 2004

    if nargin < 3
        error('Cannot convert SDP formulation to SeDuMi formulation in sdpToSeDumi!');
    end

    [m, n] = size(F0);
    if m ~= n
        error('F0 matrix must be squared matrix in sdpToSeDumi(F0, FI, b)');
    end

    p = length(cc);
    if p ~= length(FI)
        error('FI matrix cellarray must have the same length as b in sdpToSeDumi(F0,FI,b)');
    end

    % should check every element in the cell array FI...later..

    % x = reshape(Z, n*n, 1);  % optimization variables from matrix to vector

    % converting objective function of the canonical SDP
    c = reshape(F0', n*n,1);

    % converting equality constraints of the canonical SDP
    zz= 0;
    for idx=1:length(FI)
        zz= zz + nnz(FI{idx});
    end
    A = spalloc( n*n, p, zz);
    for idx = 1:p
        temp = reshape(FI{idx}, n*n,1);
        lst = find(temp~=0);
        A(lst, idx) = temp(lst);
    end
    % The SeDuMi solver actually expects the transpose of A as in following
    % dual problem
    % max b'y
    % s.t. c - A'y is positive definite
    % Therefore, we transpose A
    % A = A';

    % b doesn't need to be changed
    b = cc;
    return;
