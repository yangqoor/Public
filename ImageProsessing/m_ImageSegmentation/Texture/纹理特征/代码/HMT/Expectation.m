function [P] = Expectation(f,imPara,P)
%����С��ϵ��w��H���ֵ�����
L = size(f,1);%�У���������
%�����м����
belt = repmat(struct('beltn',[]),[L,1]); %��ʽ��10������
beltip = repmat(struct('beltipn',[]),[L,1]); %��ʽ��11������
beltpi = repmat(struct('beltpin',[]),[L,1]); %��ʽ��12������
alpha = repmat(struct('alphan',[]),[L,1]); %��ʽ��13������
%��߷ֱ��ʳ߶ȵĳ�ʼ��
n = 1;
fn = cat(3,f{n,:});
si = imPara(n).si; u = imPara(n).u;
tm1 = gauss(fn,si(:,:,1),u(:,:,1)); %��ʽ��20��״̬1
tm2 = gauss(fn,si(:,:,2),u(:,:,2)); %��ʽ��20��״̬2
tm = cat(3,tm1,tm2);
tm = shiftdim(tm,2);
belt(n).beltn = tm;
%up����
for n=1:L-1
    fn = cat(3,f{n,:});
    [Widthn,Heightn,Bandn] = size(fn);
    es = imPara(n).es;
    fp = cat(3,f{n+1,:});
    [Widthp,Heightp,Bandp] = size(fp);
    %����beltip
    beltn = belt(n).beltn;
    beltn = reshape(beltn,[2,Widthn*Heightn]);
    beltipn = es'*beltn; %��ʽ��21��
    beltipn = reshape(beltipn,[2,Widthn,Heightn]);
    beltip(n).beltipn = beltipn;
    %����belt��n+1��
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
    beltp = gausp.*tmm; %��ʽ��22��
    belt(n+1).beltn = beltp;
    %����beltpi
    tm = zeros(2,Widthn,Heightn);
    tm(:,1:2:Widthn,1:2:Heightn) = beltp;
    tm(:,2:2:Widthn,1:2:Heightn) = beltp;
    tm(:,1:2:Widthn,2:2:Heightn) = beltp;
    tm(:,2:2:Widthn,2:2:Heightn) = beltp;
    beltpi(n).beltpin = tm./beltipn; %��ʽ��23��
end
%��߳߶ȳ�ʼ��
n=L;
fn = cat(3,f{n,:});
[Widthn,Heightn,Bandn] = size(fn);
ps = imPara(n).ps;
alpha(n).alphan = repmat(ps,[1,Widthn,Heightn]); %��ʽ��24��
%down����
for n=L-1:-1:1
    fn = cat(3,f{n,:});
    [Widthn,Heightn,Bandn] = size(fn);
    es = imPara(n).es;
    %����alphan
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
    tm = es*(alphap.*beltpin); %��ʽ��25��
    alpha(n).alphan = reshape(tm,[2,Widthn,Heightn]);
end
%����P
for n=1:L-1
    fn = cat(3,f{n,:});
    [Widthn,Heightn,Bandn] = size(fn);
    es = imPara(n).es;
    %����P1
    alphan = alpha(n).alphan;
    beltn = belt(n).beltn;
    tm = repmat(sum(alphan.*beltn,1),[2,1,1]);
    P(n).P1 = alphan.*beltn./(tm+realmin);
    %����P2
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