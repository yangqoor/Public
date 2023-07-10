function EstiPara_Gmrf=X_GmrfPara_2Order_Estimat(L,Maxgraylevel)
%L:input gray image
%Maxgraylevel:the bit depth of the input image
%output features: 6 dimension   %% 6维？ 应该是4维
%  Gmrf二阶模型的参数估计
%
% Order    Gmrf的阶次
% 邻域结构为：
%                
%             b22   b12   b21'        
%             b11    a    b11'  
%             b21   b12'  b22' 
%                
%
L=double(L);
s=0; 
G=zeros((size(L,1)-2)*(size(L,2)-2),4);
for i=2:size(L,1)-1
     for j=2:size(L,2)-1
       s=s+1;
       G(s,:)=X_Gmrf_ParaG(L(i-1:i+1,j-1:j+1),2);
       X(s)=L(i,j);
   end
end

Esita=inv(G'*G)*G'*X';
Edelta=( X*X' - 2*X*G*Esita  + Esita'*G'*G*Esita )/length(X);
meanL=mean2(L/(2^Maxgraylevel));   % L矩阵均值  
stdL=std2(L/(2^Maxgraylevel));     
%EstiPara_Gmrf=[Edelta,Esita']';
%output features: 6 dimension
%EstiPara_Gmrf=[meanL,stdL,Esita']';

%output features: 4 dimension
EstiPara_Gmrf=Esita;

       