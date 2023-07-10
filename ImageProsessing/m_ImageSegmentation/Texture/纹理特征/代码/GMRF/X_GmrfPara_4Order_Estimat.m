function EstiPara_Gmrf=X_GmrfPara_4Order_Estimat(L,Maxgraylevel)
%L:input gray image
%Maxgraylevel:the bit depth of the input image
%output features: 10 dimension
%  Gmrf四阶模型的参数估计
%
% Order    Gmrf的阶次
% 邻域结构为：
%                b44   b32   b41'
%          b43   b22   b12   b21'  b42'      
%          b31   b11    a    b11'  b31'
%          b42   b21   b12'  b22'  b43'
%                b41   b32'  b44'
%
L=double(L);
s=0;  G=zeros((size(L,1)-4)*(size(L,2)-4),10);
for i=3:size(L,1)-2
     for j=3:size(L,2)-2
       s=s+1;
       G(s,:)=X_Gmrf_ParaG(L(i-2:i+2,j-2:j+2),4);
       X(s)=L(i,j);
   end
end
meanL=mean2(L/(2^Maxgraylevel));
stdL=std2(L/(2^Maxgraylevel));
Esita=inv(G'*G)*G'*X';
Edelta=( X*X' - 2*X*G*Esita  + Esita'*G'*G*Esita )/length(X);

%EstiPara_Gmrf=[Edelta,Esita']';
%12维参数输出，多出meanL,stdL两个特征
%EstiPara_Gmrf=[meanL,stdL,Esita']';
%10维参数输出
EstiPara_Gmrf=Esita;