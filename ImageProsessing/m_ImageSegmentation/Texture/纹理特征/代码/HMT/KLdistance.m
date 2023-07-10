function [ Distance ] = KLdistance( imParaQ,imParaC )
% 计算查询图像和备选图像模型之间的KL距离
L = size(imParaQ,1);%imParaQ的行数
% 定义中间变量
Dbelt = repmat(struct('Dbeltn',[]),[L,1]);
% 最高分辨率尺度初始化
n = 1;
uQ = imParaQ(n).u; siQ = imParaQ(n).si; uC = imParaC(n).u; siC = imParaC(n).si;
tm1 = Dgauss(uQ(:,:,1),siQ(:,:,1),uC(:,:,1),siC(:,:,1));
tm2 = Dgauss(uQ(:,:,2),siQ(:,:,2),uC(:,:,2),siC(:,:,2));
tm = cat(1,tm1,tm2);
Dbelt(n).Dbeltn = tm;
% Induction
for n=1:L-1
    esQ = imParaQ(n).es; esC = imParaC(n).es;
    Dbeltn = Dbelt(n).Dbeltn;
    D2 = esQ'*Dbeltn;
    D11 = kld(esQ(:,1),esC(:,1));
    D12 = kld(esQ(:,2),esC(:,2));
    D1 = cat(1,D11,D12);
    uQ = imParaQ(n+1).u; siQ = imParaQ(n+1).si; uC = imParaC(n+1).u; siC = imParaC(n+1).si;
    tm1 = Dgauss(uQ(:,:,1),siQ(:,:,1),uC(:,:,1),siC(:,:,1));
    tm2 = Dgauss(uQ(:,:,2),siQ(:,:,2),uC(:,:,2),siC(:,:,2));
    tm = cat(1,tm1,tm2);
    Dbelt(n+1).Dbeltn = tm + 4*(D1+D2);
end
% Termination
n = L;
psQ = imParaQ(n).ps; psC = imParaC(n).ps;
Dbeltn = Dbelt(n).Dbeltn;
Distance = kld(psQ,psC)+psQ'*Dbeltn;
end

function [D] = kld(p,q)
% 计算两个离散概率分布之间的距离
n = length(p);
D = 0;
for i=1:n
    D = D+p(i)*log(p(i)/q(i));
end
end

function [D] = Dgauss(uQ,siQ,uC,siC)
% 计算两个高斯分布之间的距离
d = size(siQ,1);
u = uQ-uC;
D = 0.5*(log( det(siC)/det(siQ) ) - d + trace(inv(siC)*siQ) + u*inv(siC)*u');%trace：求对角线元素的和
end


