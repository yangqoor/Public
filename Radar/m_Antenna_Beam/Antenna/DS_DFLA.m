clear;clf;
c=3e8;%光速
B=[6e9 9e9];
lemda=c./B;
k=2*pi./lemda;
theta0=pi/2;
V=63;
K=32;
L=16;
res=1000;
D=[0 5 6 10 12 15 16 17 18 20 24 25 26 29 32 34 35 37 38 39 41 42 45 46 48 50 52 53 54 55 56 57];
%(101,25,6)[1,5,16,19,24,25,31,36,37,52,54,56,58,68,71,78,79,80,81,84,87,88,92,95,97];
%(197,49,12)[1 16 23 24 28 29 34 36 37 40 42 49 51 53 54 59 60 61 63 70 76 81 85 88 90 100 101 104 105 114 132 133 135 142 150 154 156 158 164 171 172 175 178 182 187 188 190 191 193];
%(121,40,13)[1,3,4,7,9,11,12,13,21,25,27,33,34,36,39,44,55,63,64,67,68,70,71,75,80,81,82,83,85,89,92,99,102,103,104,108,109,115,117,119];
%(31,15,7)[1,2,4,5,7,8,9,10,14,16,18,19,20,25,28];
%(15,7,3)[0,1,2,7,9,12,13];
%(127,63,31)[1 2 3 4 5 6 8 10 11 12 16 19 20 21 22 24 25 27 29 32 33 37 38 39 40 41 42 44 48 49 50 51 54 58 63 64 65 66 69 73 74 76 77 78 80 82 83 84 88 89 95 96 98 100 102 105 108 111 116 119 123 125 126];
%(31,15,7)[1 2 4 5 7 8 9 10 14 16 18 19 20 25 28];
%(57,8,1)[1 6 7 9 19 38 42 49];
%(31,6,1)[0 1 6 18 27 29];
%(21,5,1)[3 6 7 12 14];
%(13,4,1)[0 1 5 11];
%(255,127,63)[0	1	2	3	4	5	6	13	14	16	18	19	21	24	26	32	33	34	36	39	40	42	43	44	45	47	49	50	51	53	54	56	57	59	61	63	65	66	69	70	72	76	78	79	80	84	87	88	94	97	99	100	101	102	103	104	106	107	108	109	110	112	117	121	126	127	128	129	131	132	136	138	141	142	143	148	149	152	155	164	166	168	172	173	177	178	180	181	184	186	188	189	190	191	194	198	199	200	201	202	205	206	207	208	212	213	214	217	218	221	222	223	225	226	227	230	232	233	238	240	241	243	244	245	247	249	252];
%(63,32,16)[0 5 6 10 12 15 16 17 18 20 24 25 26 29 32 34 35 37 38 39 41 42 45 46 48 50 52 53 54 55 56 57];
Dh=D;
Dempty=zeros(1,V);
Dfull=0:V-1;
Dempty(D+1)=D;
Dfull=Dfull-Dempty;
Dl=zeros(1,V-K);
n=0;
for m=1:V
    if Dfull(m)~=0
       n=n+1;
       Dl(n)=Dfull(m);
   end
end
Dl=sort(Dl);
Lh=K;Ll=V-K;

theta=linspace(0,pi,res);
u=cos(theta)-cos(theta0);

Dsh=zeros(V,K);
Dsl=zeros(V,V-K);
for s=0:V-1
    Dsh(s+1,:)=mod(Dh+s,V);
    Dsh(s+1,:)=sort(Dsh(s+1,:));
    Dsl(s+1,:)=mod(Dl+s,V);
    Dsl(s+1,:)=sort(Dsl(s+1,:));
    dh=Dsh(s+1,:)*lemda(2)/2;
    dl=Dsl(s+1,:)*lemda(2)/2;
    Ih=ones(1,Lh);
    Il=ones(1,Ll);
    Sh=zeros(1,length(u));
    Sl=zeros(1,length(u));
    for m=1:Lh
        Sh=Sh+Ih(m)*exp(i*k(2)*dh(m)*u);
    end
    for m=1:Ll
        Sl=Sl+Il(m)*exp(i*k(1)*dl(m)*u);
    end
    Sh=abs(Sh); Sl=abs(Sl);
    Sh=20*log10(Sh/max(Sh)+eps);Sl=20*log10(Sl/max(Sl)+eps);
    for m=1:res/2
        if Sh(m)>Sh(m+1),brkh=m;end
        if Sl(m)>Sl(m+1),brkl=m;end
    end
    
    mrslh(s+1)=max(Sh(1:brkh));
    mrsll(s+1)=max(Sl(1:brkl));
    mrsldifference(s+1)=abs(mrslh(s+1)-mrsll(s+1));
    s
end
fprintf('before sorting mrsldifference=%f\n',mrsldifference);
[difference_sort,num]=sort(mrsldifference);
fprintf('after sorting mrsldifference=%f\n',difference_sort);
fprintf('the best shift is shift=%f\n',num(1));

    
dh=Dsh(num(1),:)*lemda(2)/2;
dl=Dsl(num(1),:)*lemda(2)/2;
Sh=zeros(1,length(u));
Sl=zeros(1,length(u));
for m=1:Lh
    Sh=Sh+Ih(m)*exp(i*k(2)*dh(m)*u);
end
for m=1:Ll
    Sl=Sl+Il(m)*exp(i*k(1)*dl(m)*u);
end
Sh=abs(Sh); Sl=abs(Sl);
Sh=20*log10(Sh/max(Sh)+eps);Sl=20*log10(Sl/max(Sl)+eps);

plot(theta*180/pi,Sh,'k','LineWidth',2);
grid on;
hold on;
% plot(theta*180/pi,-12.73*ones(1,length(theta)),'k--','LineWidth',2);
axis([0,180,-40,0]);
set(gca,'Xtick',[0,30,60,90,120,150,180],'Ytick',[-40,-30,-20,-10,0]);
text(3,-11,'\fontsize{16}\bf-12.73');
xlabel('\fontsize{16}\bftheta(degree)');
ylabel('\fontsize{16}\bf方向图(dB)');
hold on;
plot(theta*180/pi,Sl,'k:','LineWidth',2);
axis([min(theta*180/pi),max(theta*180/pi),-40,0]);
% plot(theta*180/pi,-12.59*ones(1,length(theta)),'k--','LineWidth',2);
text(10,-13,'\fontsize{16}\bf-12.59');
hold off;