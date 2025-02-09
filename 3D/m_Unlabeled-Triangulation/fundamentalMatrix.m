function F = fundamentalMatrix(A1,A2)
F=matrixCrossProduct(A2*null(A1))*A2*pinv(A1);
% F=zeros(3,3);
% for i=1:3
%     for j=1:3
%     F(j,i)=(-1)^(i+j)*det([A1(setdiff([1,2,3],i),:);A2(setdiff([1,2,3],j),:)]);
%     end
% end
F=F./max(svd(F));

       