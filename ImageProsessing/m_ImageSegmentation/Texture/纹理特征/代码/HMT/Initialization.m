function [imPara] = Initialization(f,L)

parab = struct('es',[],'ps',[],'si',[],'u',[]);%£¿£¿£¿£¿£¿£¿£¿£¿£¿
imPara = repmat(parab,[L,1]);
for s=1:L
    es = [0.8 0.3;0.2 0.7];
    ps = [0.5;0.5];
    imPara(s).es = es;
    imPara(s).ps = ps;
    B = cat(3,f{s,:});[Hight,Width,Bands] = size(B);B = reshape(B,[Hight*Width Bands]);%f??????
    sib = cov(B);
    ub = mean(B);
    imPara(s).si = cat(3,sib/2,sib*2);
    imPara(s).u = cat(3,ub,ub);
end
