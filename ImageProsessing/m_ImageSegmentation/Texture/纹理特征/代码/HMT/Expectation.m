function [P] = Expectation(f,imPara,P)
%计算小波系数w的H部分的期望
L = size(f,1);%行？？？？？
%定义中间变量
belt = repmat(struct('beltn',[]),[L,1]); %公式（10）变量
beltip = repmat(struct('beltipn',[]),[L,1]); %公式（11）变量
beltpi = repmat(struct('beltpin',[]),[L,1]); %公式（12）变量
alpha = repmat(struct('alphan',[]),[L,1]); %公式（13）变量
%最高分辨率尺度的初始化
n = 1;
fn = cat(3,f{n,:});
si = imPara(n).si; u = imPara(n).u;
tm1 = gauss(fn,si(:,:,1),u(:,:,1)); %公式（20）状态1
tm2 = gauss(fn,si(:,:,2),u(:,:,2)); %公式（20）状态2
tm = cat(3,tm1,tm2);
tm = shiftdim(tm,2);
belt(n).beltn = tm;
%up过程
for n=1:L-1
    fn = cat(3,f{n,:});
    [Widthn,Heightn,Bandn] = size(fn);
    es = imPara(n).es;
    fp = cat(3,f{n+1,:});
    [Widthp,Heightp,Bandp] = size(fp);
    %计算beltip
    beltn = belt(n).beltn;
    beltn = reshape(beltn,[2,Widthn*Heightn]);
    beltipn = es'*beltn; %公式（21）
    beltipn = reshape(beltipn,[2,Widthn,Heightn]);
    beltip(n).beltipn = beltipn;
    %计算belt（n+1）
    sp = imPara(n+1).si; up = imPara(n+1).u;
    tm1 = gauss(fp,sp(:,:,1),up(:,:,1));
    tm2 = gauss(fp,sp(:,:,2),up(:,:,2));    
    tm = cat(3,tm1,tm2);
    tm = shiftdim(tm,2);
    gausp = tm;
    tmm = ones(2,Widthp,Heightp);
    tmm = tmm.*beltipn(:,1:2:Widthn,1:2:Heightn);
    tmm = tmm.*beltipn(:,2:2:Widthn,1:2:Heightn);
    tmm = tmm.*beltipn(:,1:2:Widthn,2:2:Heightn);
    tmm = tmm.*beltipn(:,2:2:Widthn,2:2:Heightn);
    beltp = gausp.*tmm; %公式（22）
    belt(n+1).beltn = beltp;
    %计算beltpi
    tm = zeros(2,Widthn,Heightn);
    tm(:,1:2:Widthn,1:2:Heightn) = beltp;
    tm(:,2:2:Widthn,1:2:Heightn) = beltp;
    tm(:,1:2:Widthn,2:2:Heightn) = beltp;
    tm(:,2:2:Widthn,2:2:Heightn) = beltp;
    beltpi(n).beltpin = tm./beltipn; %公式（23）
end
%最高尺度初始化
n=L;
fn = cat(3,f{n,:});
[Widthn,Heightn,Bandn] = size(fn);
ps = imPara(n).ps;
alpha(n).alphan = repmat(ps,[1,Widthn,Heightn]); %公式（24）
%down过程
for n=L-1:-1:1
    fn = cat(3,f{n,:});
    [Widthn,Heightn,Bandn] = size(fn);
    es = imPara(n).es;
    %计算alphan
    beltpin = beltpi(n).beltpin;
    beltpin = reshape(beltpin,[2,Widthn*Heightn]);
    alphap = alpha(n+1).alphan;
    tm = zeros(2,Widthn,Heightn);
    tm(:,1:2:Widthn,1:2:Heightn) = alphap;
    tm(:,2:2:Widthn,1:2:Heightn) = alphap;
    tm(:,1:2:Widthn,2:2:Heightn) = alphap;
    tm(:,2:2:Widthn,2:2:Heightn) = alphap;
    alphap = tm;
    alphap = reshape(alphap,[2,Widthn*Heightn]);
    tm = es*(alphap.*beltpin); %公式（25）
    alpha(n).alphan = reshape(tm,[2,Widthn,Heightn]);
end
%计算P
for n=1:L-1
    fn = cat(3,f{n,:});
    [Widthn,Heightn,Bandn] = size(fn);
    es = imPara(n).es;
    %计算P1
    alphan = alpha(n).alphan;
    beltn = belt(n).beltn;
    tm = repmat(sum(alphan.*beltn,1),[2,1,1]);
    P(n).P1 = alphan.*beltn./(tm+realmin);
    %计算P2
    alphap = alpha(n+1).alphan;
    tm1 = zeros(2,Widthn,Heightn);
    tm1(:,1:2:Widthn,1:2:Heightn) = alphap;
    tm1(:,2:2:Widthn,1:2:Heightn) = alphap;
    tm1(:,1:2:Widthn,2:2:Heightn) = alphap;
    tm1(:,2:2:Widthn,2:2:Heightn) = alphap;
    alphap = tm1;
    alphap = reshape(alphap,[2,Widthn*Heightn]);
    beltpin = beltpi(n).beltpin;
    beltpin = reshape(beltpin,[2,Widthn*Heightn]);
    for s=1:2
        for p=1:2
            belts = beltn(s,:);
            esp = es(s,p);
            alphaps = alphap(p,:);
            beltpips = beltpin(p,:);
            fenmu = tm(s,:);
            tmp = belts*esp.*alphaps.*beltpips./(fenmu+realmin);
            tmp = reshape(tmp,[Widthn,Heightn]);
            P(n).P2(s,p,:,:) = tmp;
        end
    end
end
n=L;
alphan = alpha(n).alphan;
beltn = belt(n).beltn;
tm = repmat(sum(alphan.*beltn,1),[2,1,1]);
P(n).P1 = alphan.*beltn./(tm+realmin);
end