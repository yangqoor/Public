% Di You
% Oct 27, 2010
% Notes, this calculates the M matrix in the regularization term 
% for the RBF Kernel in
% X is nxp, for n samples
% DD is pairwise distance matrix 
%

function M = calcCurvPenaltyMatrixM( X, sigma, DD )


         
         [l,p]=size(X);
         K=exp(-DD/(2*sigma^2));
         M=zeros(l,l);
         for i=1:l

                 Q=(X-repmat(X(i,:),l,1)).^2/sigma^2-1;
               
                 temp=repmat(K(:,i),1,p).*Q;
                 U=zeros(l,p);
                 U(i,:)=1;
                 P=temp+U;
                 M=M+P*P';
                 
         end
         
         M=M/(2*l*sigma^4);
