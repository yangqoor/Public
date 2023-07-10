function [imPara] = Maximization(f,P,imPara)
%EM�㷨��M��
L = size(f,1);
band = size(f,2)*size(f{1,1},3);
ps=repmat(struct('psn',zeros(2,1)),[L,1]);
es=repmat(struct('esn',zeros(2)/2),[L,1]);
si=repmat(struct('sin',zeros(band,band,2)),[L,1]);
u=repmat(struct('un',zeros(1,band,2)),[L,1]);
%ִ�а󶨲���
%ִ�г߶��ڵİ�
[ps1,es1,si1,u1]=TyingWithinTrees(f,P);
%ִ�������
for n=1:L
    ps(n).psn=ps(n).psn+ps1(n).psn;
    es(n).esn=es(n).esn+es1(n).esn;
    si(n).sin=si(n).sin+si1(n).sin;
    u(n).un=u(n).un+u1(n).un;
end

%����es
for n=1:L-1
    psp=ps(n+1).psn;
    psp=repmat(psp',[2,1]);
    es(n).esn=es(n).esn./psp;
    es(n).esn=es(n).esn./repmat(sum(es(n).esn,1),[2,1]);
end
%����u
for n=1:L
    u(n).un(:,:,1)=u(n).un(:,:,1)/ps(n).psn(1);
    u(n).un(:,:,2)=u(n).un(:,:,2)/ps(n).psn(2);
end
%����si
for n=1:L
    psn=ps(n).psn;
    si_temp=si(n).sin;
    [width,hight,nstate]=size(si_temp);
    si_temp=shiftdim(si_temp,2);
    si_temp=reshape(si_temp,[2,width*hight]);
    psn=repmat(psn,[1,width*hight]);
    si_temp=si_temp./psn;
    si_temp=reshape(si_temp,[2,width,hight]);
    si(n).sin=shiftdim(si_temp,1);
end
%����imPara
for n=1:L
    imPara(n).es=es(n).esn;
    imPara(n).ps=ps(n).psn;
    imPara(n).si=si(n).sin;
    imPara(n).u=u(n).un;
end
end