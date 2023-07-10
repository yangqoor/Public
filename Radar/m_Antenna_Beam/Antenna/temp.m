% clear;clf;
% c=3e8;%光速
% B=[3e9 4e9 6e9 8e9 10e9];
% lemda=c./B;
% res=1000;
% V=364;
% K=121;
% L=40;
% D(1:24)=[0 1 2 3 4 6 8 9 11 16 17 19 22 24 32 35 36 41 42 46 48 50 56 73];
% D(25:48)=[76 78 79 80 88 89 92 99 105 106 107 109 110 111 114 122 123 127 128 132 133 134 142 151];
% D(49:72)=[152 153 156 162 163 169 171 174 177 181 183 187 189 190 198 201 203 207 210 212 214 218 221 222];
% D(73:96)=[223 224 229 234 237 241 246 248 249 250 251 256 260 262 264 274 281 283 285 286 289 292 299 300];
% D(97:121)=[302 305 306 307 309 311 314 315 317 318 322 326 327 330 331 336 343 348 350 351 353 354 357 358 360];
% Dempty=zeros(1,V);
% Dfull=0:V-1;
% Dc=zeros(1,V-K);
% for m=1:length(D)
%     Dfull(D(m)+1)=0;
% end
% n=0;
% for m=2:V
%     if Dfull(m)~=0,n=n+1;Dc(n)=Dfull(m);end
% end
% s=17;
% Dc=mod(Dc+s,V);
% Dc=sort(Dc);
% 
% X=2;
% Y=13;
% Z=14;
% x=mod(Dc,X);y=mod(Dc,Y);z=mod(Dc,Z);
% I1=zeros(Y,Z);I3=zeros(Y,Z);
% for m=1:V-K
%     if (x(m)==0),I1(y(m)+1,z(m)+1)=1;end
%     if (x(m)==1),I3(y(m)+1,z(m)+1)=1;end
% end
% 
% dx=lemda(5)/4*(2*(1:Z)-1);
% dy=lemda(5)/4*(2*(1:Y)-1);
% I1=flipud(I1);I2=flipud(1-I1);
% I3=flipud(I3);I4=flipud(1-I3);
% k=2*pi./lemda;
% theta=linspace(-pi/2,pi/2,200);
% phi=linspace(0,2*pi,200);
% theta0=0;
% phi0=0;
% [U,V]=meshgrid(theta,phi);
% u=sin(U).*cos(V)-sin(theta0)*cos(phi0);
% v=sin(U).*sin(V)-sin(theta0)*sin(phi0);
% [r,l]=size(u);
% S1=zeros(r,l);S2=zeros(r,l);
% S3=zeros(r,l);S4=zeros(r,l);
% for m=1:Y
%     for n=1:Z
%         S1=S1+I1(m,n)*exp(i*k(4)*(dx(n)*u+dy(m)*v));
%         S2=S2+I2(m,n)*exp(i*k(3)*(dx(n)*u+dy(m)*v));
%         S3=S3+I3(m,n)*exp(i*k(2)*(-dx(n)*u+dy(m)*v));
%         S4=S4+I4(m,n)*exp(i*k(1)*(-dx(n)*u+dy(m)*v));
%     end
% end
% S1=abs(S1);S2=abs(S2);
% S3=abs(S3);S4=abs(S4);
% S1=20*log10(S1/max(max(S1)));S2=20*log10(S2/max(max(S2)));
% S3=20*log10(S3/max(max(S3)));S4=20*log10(S4/max(max(S4)));
% figure(1);
% plot(theta*180/pi,S1(1,:),'k');
% hold on;
% plot(theta*180/pi,S2(1,:),'k:');
% plot(theta*180/pi,S3(1,:),'r');
% plot(theta*180/pi,S4(1,:),'r:');
% grid on;
% axis([min(theta*180/pi),max(theta*180/pi),-30,0]);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%由差集确定的稀疏线阵的PSLL和NNBW随频率的变化特性
clear,clf;
%%%%%%%%%%%%%%%DS array
V=127;
K=64;
L=32;
D=[0 7	9	13	14	15	17	18	23	26	28	30	31	34	35	36 43	45	46	47	52	53	55	56	57	59	60	61	62	67	68	70 71	72	75	79	81	85	86	87	90	91	92	93	94	97	99	101	103 104	106	107	109	110	112	113	114	115	117	118	120	121	122	124];
%(127,64,31)[0 7	9	13	14	15	17	18	23	26	28	30	31	34	35	36 43	45	46	47	52	53	55	56	57	59	60	61	62	67	68	70 71	72	75	79	81	85	86	87	90	91	92	93	94	97	99	101	103 104	106	107	109	110	112	113	114	115	117	118	120	121	122	124];
%(63,32,16)[0 5 6 10 12 15 16 17 18 20 24 25 26 29 32 34 35 37 38 39 41 42 45 46 48 50 52 53 54 55 56 57];
D=mod(D+71,V);
D=sort(D);
c=3e8;%光速
B=20e9:-1e9:1e9;%工作于多个频率
fh=B(12);%floor(length(B)/2));
lemdah=c/fh;
I0=ones(1,K);
d0=lemdah/2*D;
%%%%%%%%%%%%%%%SA array
% N=101;
% K=25;
% c=3e8;%光速
% B=20e9:-1e9:1e9;%8e9:1e8:10e9 %工作于多个频率
% fh=B(12);%floor(length(B)/2));
% lemdah=c/fh;
% d0=lemdah*[0 19	21 21.5	22 22.5	23 23.5	24 24.5	26.5 27	28.5 29.5 30,...
%            32.5	33 34 34.5 36.5	37.5 40.5 41.5 46.5	50];
% I0=ones(1,K);
%%%%%%%%%%%%%%%%%%%%%%%%%full array
% K=101;
% c=3e8;%光速
% B=20e9:-1e9:1e9;%8e9:1e8:10e9 %工作于多个频率
% fh=B(12);%floor(length(B)/2));
% lemdah=c/fh;
% d0=lemdah/2*(0:(K-1));
% I0=ones(1,K);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%minimum redundancy array
% Na=23;
% K=8;
% Nr=5;
% A=[1 1 9 4 3 3 2];
% c=3e8;%光速
% B=20e9:-1e9:1e9;%8e9:1e8:10e9 %工作于多个频率
% fh=B(12);%floor(length(B)/2));
% lemdah=c/fh;
% x0=zeros(1,K);
% for m=1:length(A);
%     x0(m+1)=sum(A(1:m));
% end
% I0=ones(1,K);
% d0=x0*lemdah/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%DS_GA linear array
% N=63;%孔径长度为(N-1)*lemda/2
% D=[0 5 6 10 12 15 16 17 18 20 24 25 26 29 32 34 35 37 38 39,...
%    41 42 45 46 48 50 52 53 54 55 56 57];
% K=length(D);
% c=3e8;%光速
% B=20e9:-1e9:1e9;%8e9:1e8:10e9 %工作于多个频率
% fh=B(12);%floor(length(B)/2));
% lemdah=c/fh;
% d0=lemdah/2*D;
% I0=[0.6824	0.58622	0.38328	0.67302	0.9522	0.8783	0.5346	0.92874,...
%     0.90059	0.48299	0.87713	1.0273	1.1868	1.1023	1.1868	0.69413,...
%     0.97566	1.2103	1.1352	1.0742	1.1645	1.0132	0.79736	1.066,...
%     0.94282	0.95924	1.107	0.7129	0.70352	0.79267	1.1868	0.82082];
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theta0=pi/2;
res=501;
theta=linspace(0,pi,res);
mrsl=zeros(1,length(B));
mlbw=zeros(1,length(B));    

u=cos(theta')-cos(theta0);
for m=1:length(B)
    S=zeros(length(u),1);
    f=B(m);
    lemda=c/f;
    k=2*pi/lemda;
    for n=1:K
        S=S+I0(n)*exp(i*k*d0(n)*u);
    end
    S=abs(S);
    S=20*log10(S/max(S));
    for p=1:(res-1)/2
        if S(p)>S(p+1),brk=p;end
    end
    brk
    BS=S(1:brk);
    mrsl(m)=max(BS);
    mlbw(m)=2*(theta0-theta(brk));
end
figure(1);
plot(B/1e9,mrsl,'k','LineWidth',2);
hold on;
plot(B/1e9,mrsl,'ko','Markersize',6);
grid on;
xlabel('\fontsize{16}\bf频率(GHz)');
ylabel('\fontsize{16}\bfPSLL(dB)');
hold off;
axis([1,20,-16,0]);
set(gca,'Xtick',[1,5,10,15,20],'Ytick',[-16,-12,-8,-4,0]);
figure(2);
plot(B/1e9,mlbw*180/pi,'k','LineWidth',2);
hold on;
plot(B/1e9,mlbw*180/pi,'ko','Markersize',6);
grid on;
xlabel('\fontsize{16}\bf频率(GHz)');
ylabel('\fontsize{16}\bfNNBW(degree)');
hold off;
axis([1,20,0,50]);
set(gca,'Xtick',[1,4,8,12,16,20],'Ytick',[0 10 20 30 40 50]);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%由差集确定稀疏线阵的扫面特性
% clear,clf;
% V=127;
% K=64;
% L=32;
% D=[0	7	9	13	14	15	17	18	23	26	28	30	31	34	35	36	43	45	46	47	52	53	55	56	57	59	60	61	62	67	68	70	71	72	75	79	81	85	86	87	90	91	92	93	94	97	99	101	103	104	106	107	109	110	112	113	114	115	117	118	120	121	122	124];
% %(63,32,16)[0 5 6 10 12 15 16 17 18 20 24 25 26 29 32 34 35 37 38 39 41 42 45 46 48 50 52 53 54 55 56 57];
% D=mod(D+71,V);
% D=sort(D);
% N=2*K;
% c=3e8;%光速
% B=20e9:-1e9:1e9;%工作于多个频率
% fh=B(12);%floor(length(B)/2));
% lemdah=c/fh;
% I0=ones(1,K);
% d0=lemdah/2*D;
% 
% Theta0=[pi/4,pi/3,pi/2];
% res=2000;
% theta=linspace(0,pi,res);
% mrsl=zeros(1,length(B));
% mlbw=zeros(1,length(B));    
% k=2*pi/lemdah;
% for m=1:length(Theta0)
%     theta0=Theta0(m);
%     u=cos(theta')-cos(theta0);
%     %方向图
%     S=zeros(length(u),1);
%     for n=1:K
%         S=S+I0(n)*exp(i*k*d0(n)*u);
%     end
%     S=abs(S);
%     S=20*log10(S/max(S));
% %     for p=1:res/2
% %         if S(p)>S(p+1),brk=p;end
% %     end
% %     BS=S(1:brk);
% %     mrsl(m)=max(BS);
% %     mlbw(m)=2*(theta0-theta(brk));
%     plot(theta*180/pi,S);
%     hold on;
% end
% grid on;
% hold off;
% % figure(1);
% % plotyy(B/1e9,mrsl,B/1e9,mlbw*180/pi,'plot')
% % plot(B/1e9,mrsl,'ko');
% % hold on;
% % plot(B/1e9,mrsl,'k');
% % grid on;
% % hold off;
% % figure(2);
% % plot(B/1e9,mlbw*180/pi,'ko');hold on;
% % plot(B/1e9,mlbw*180/pi,'k');
% % grid on;
% % hold off;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% clear,clf;
% V=63;
% K=31;
% L=16;
% %阵列的参数
% M=7;N=9;%阵列的大小为M*N=V
% c=3e8;
% f=10e9;
% fh=9e9;%高频率
% fl=8e9;%低频率
% lemda=c/f;%网格尺寸对应波长
% lemdah=c/fh;
% lemdal=c/fl;
% dx=lemda/4*(2*(1:N)-1);
% dy=lemda/4*(2*(1:M)-1);
% I0=ones(M,N);
% %生成位置数组,决定放置阵元的位置
% P=zeros(M,N);
% Ph=zeros(M,N);
% D=[1 2 3 4 7 8 9 11 13 14 19 21 22 23 27 28 30 31 33 36 40 43 44 47 49 51 58 59 60 61 62];
% %[0	1	2	3	4	5	6	13	14	16	18	19	21	24	26	32	33	34	36	39	40	42	43	44	45	47	49	50	51	53	54	56	57	59	61	63	65	66	69	70	72	76	78	79	80	84	87	88	94	97	99	100	101	102	103	104	106	107	108	109	110	112	117	121	126	127	128	129	131	132	136	138	141	142	143	148	149	152	155	164	166	168	172	173	177	178	180	181	184	186	188	189	190	191	194	198	199	200	201	202	205	206	207	208	212	213	214	217	218	221	222	223	225	226	227	230	232	233	238	240	241	243	244	245	247	249	252];
% %[0	1	2	3	4	5	6	13	14	16	18	19	21	24	26	32	33	34	36	39	40	42	43	44	45	47	49	50	51	53	54	56	57	59	61	63	65	66	69	70	72	76	78	79	80	84	87	88	94	97	99	100	101	102	103	104	106	107	108	109	110	112	117	121	126	127	128	129	131	132	136	138	141	142	143	148	149	152	155	164	166	168	172	173	177	178	180	181	184	186	188	189	190	191	194	198	199	200	201	202	205	206	207	208	212	213	214	217	218	221	222	223	225	226	227	230	232	233	238	240	241	243	244	245	247	249	252];
% %[1 2 3 4 7 8 9 11 13 14 19 21 22 23 27 28 30 31 33 36 40 43 44 47 49 51 58 59 60 61 62];
% L=length(D);
% Ds=zeros(V,K);
% for s=0:V-1
%     Ds(s+1,:)=mod(D+s,V);
% end
% sh=8;
% for m=1:length(D)
%     P(mod(Ds(sh,m),M)+1,mod(Ds(sh,m),N)+1)=1;%经计算 对于D(63,31,15)sh=3,8,12,17,21,26,30,35,39,44,48,53,57,62msll<-10.8dB
% end                                          %对于D(255,127,63)sh=4,10,15,16,20,248,249,254msll<-12dB
% %Ph=[flipud(P(1:M-1,:));P(M,:)];             %对于D(15,7,3)sh=2,5,7,10,12,15msll<-8dB
% %Ph=[Ph(:,3:N),Ph(:,1:2)];Ph=flipud(Ph);
% Ph=P;Ph=flipud(Ph);
% Pl=1-Ph;
% 
% Ih=I0.*Ph;
% Il=I0.*Pl;
% 
% kh=2*pi/lemdah;
% kl=2*pi/lemdal;
% theta0=5*pi/18;
% phi0=0;
% res=200;
% theta=linspace(-pi/2,pi/2,res);
% phi=linspace(0,2*pi,res);
% [U,V]=meshgrid(theta,phi);
% u=sin(U).*cos(V)-sin(theta0)*cos(phi0);
% v=sin(U).*sin(V)-sin(theta0)*sin(phi0);
% Sh=zeros(size(u));
% Sl=zeros(size(u));
% for m=1:M
%     for n=1:N
%         Sh=Sh+Ih(m,n)*exp(i*kh*(dx(n)*u+dy(m)*v));
%         Sl=Sl+Il(m,n)*exp(i*kl*(dx(n)*u+dy(m)*v));
%     end 
% end
% Sh=abs(Sh);
% Sl=abs(Sl);
% Shlog=20*log10(Sh/max(max(Sh)));
% Sllog=20*log10(Sl/max(max(Sl)));
% figure(1);
% for m=1:res
%     plot(theta*180/pi,Shlog(m,:),'k');
%     grid on;
%     hold on;
% end
% hold off;
% figure(2)
% for m=1:res
%     plot(theta*180/pi,Sllog(m,:),'k');
%     grid on;
%     hold on;
% end
% [X,Y]=meshgrid(theta*180/pi,phi*180/pi);
% figure(2);
% surf(X,Y,Sh);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% clear,clf;
% M=10;
% N=10;
% c=3e8;
% f=3e9;
% lemda=c/f;
% dx=lemda/4*(2*(1:N/2)-1);
% dy=lemda/4*(2*(1:M/2)-1);
% I=ones(M/2,N/2);
% 
% res=200;
% k=2*pi/lemda;
% theta0=0;
% phi0=0;
% theta=linspace(-pi/2,pi/2,res);
% phi=linspace(0,2*pi,res);
% [U,V]=meshgrid(theta,phi);
% u=sin(U).*cos(V)-sin(theta0)*cos(phi0);
% v=sin(U).*sin(V)-sin(theta0)*sin(phi0);
% S=zeros(size(u));
% for m=1:M/2
%     for n=1:N/2
%         S=S+4*I(m,n)*cos(k*dy(m)*v)*cos(k*dx(n)*u);
%     end
% end
% S=abs(S);
% Slog=20*log10(S/max(max(S)));
% figure(1);
% for m=1:res
%     plot(theta*180/pi,Slog(m,:),'k');
%     hold on;
% end
% grid on;
% hold off;
% axis([min(theta*180/pi),max(theta*180/pi),-50,0]);
% [X,Y]=meshgrid(theta*180/pi,phi*180/pi);
% figure(2);
% surf(X,Y,S);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% clear,clf;
% c=3e8;f=3e9;
% lemda=c/f;
% N=17;
% d=lemda/2*(0:(N-1)/2);
% I=[1.1065	1.0921	1.0496	0.98161	0.89198	0.78576	0.66877	0.54715	1];%chebyshev
% k=2*pi/lemda;
% theta=linspace(0,pi,1000);
% theta0=pi/2;
% u=cos(theta)-cos(theta0);
% P=4;
% s=3;
% delta=4;
% 
% S=zeros(1,length(u));
% 
% for p=1:P
%     for n=1:(N+1)/2
%         S=S+(delta*s)^(1-p)*((n-1==0)+2*(delta*s)^(1-p)*(n-1~=0))*I(n)*cos(k*s^(p-1)*d(n)*u);
%     end
% end
% S=abs(S);
% S=20*log10(S/max(S));
% plot(theta*180/pi,S,'k');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% clear,clf;
% c=3e8;f=3e9;
% lemda=c/f;
% V=31;
% K=16;
% L=8;
% D=[1	2	3	5	7	11	12	13	14	16	17	19	20	21	24	27];
% 
% d=lemda/2*D;
% I=ones(1,K);
% k=2*pi/lemda;
% theta=linspace(0,pi,1000);
% theta0=pi/2;
% u=cos(theta)-cos(theta0);
% P=4;
% s=2;
% delta=5;
% 
% S=zeros(1,length(u));
% 
% for p=1:P
%     for n=1:K
%         S=S+(delta*s)^(1-p)*I(n)*exp(i*k*s^(p-1)*d(n)*u);
%     end
% end
% S=abs(S);
% S=20*log10(S/max(S));
% plot(theta*180/pi,S,'k');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% clear,clf;
% c=3e8;f=3e9;
% lemda=c/f;
% V=15;
% K=8;
% L=4;
% D=[0	1	2	3	5	7	8	11];
% d=lemda/2;
% x=d*D;
% I=ones(1,K);
% k=2*pi/lemda;
% theta=linspace(0,pi,1000);
% theta0=pi/2;
% u=cos(theta)-cos(theta0);
% delta=2/3;
% I=ones(1,K);
% for n=0:K-1
%     I(n+1)=0.75*(k*d/2/pi)*(delta/2)*(sin(k*x(n+1)*delta/2-pi/2+eps)/(k*x(n+1)*delta/2-pi/2+eps))...
%         +0.75*(k*d/2/pi)*(delta/2)*(sin(k*x(n+1)*delta/2+pi/2+eps)/(k*x(n+1)*delta/2+pi/2+eps))...
%         +0.25*(k*d/2/pi)*(delta/2)*(sin(k*x(n+1)*delta/2-3*pi/2+eps)/(k*x(n+1)*delta/2-3*pi/2+eps))...
%         +0.25*(k*d/2/pi)*(delta/2)*(sin(k*x(n+1)*delta/2+3*pi/2+eps)/(k*x(n+1)*delta/2+3*pi/2+eps));       
% end
% P=3;
% s=2;
% gama=4;
% S=zeros(1,length(u));
% for p=1:P
%     S=S+(gama*s)^(1-p)*I(1)*ones(1,length(u));
% end
% for p=1:P
%     for n=2:K
%         S=S+(gama*s)^(1-p)*2*I(n)*cos(k*s^(p-1)*x(n)*u);
%     end
% end
% S=abs(S);
% S=20*log10(S/max(S));
% plot(theta*180/pi,S,'k');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% clear;
% c=3e8;
% B=4e9:1e9:18e9;
% fh=B(6);
% lemdah=c/fh;
% lemda=c./B;
% d=lemdah/2;
% plcmnt=[1	1	0	1	0;0	1	0	1	0;1	0	1	0	1;1	0	0	1	0;...
%      0	0	1	0	1;0	0	1	1	0;1	1	1	1	0;1	0	0	0	1;...
%      0	1	0	0	1;0	1	1	0	1];
% Lengthx=size(plcmnt,2);Lengthy=size(plcmnt,1);
% 
% 
% k=2*pi./lemda;
% theta0=0;
% phi0=pi/2;
% res=201;
% theta=linspace(-pi/2,pi/2,res);
% phi=linspace(0,2*pi,res);
% [X,Y]=meshgrid(theta,phi);
% u=sin(X).*cos(Y)-sin(theta0)*cos(phi0);
% v=sin(X).*sin(Y)-sin(theta0)*sin(phi0);
% 
% 
% mrsl=zeros(1,length(B));
% nnbw=zeros(1,length(B));
% for s=1:length(B)
%     S1=zeros(size(u));
%     for m=1:Lengthy
%         for n=1:Lengthx
%             if (plcmnt(m,n)==1)
%                  S1=S1+exp(i*k(s)*((n-1)*d*u+(m-1)*d*v));
%             end
%         end
%     end
%     S1=abs(S1);S1=20*log10(S1/max(max(S1)));
% 
%     Mrsl=zeros(1,(res-1)/2);
%     for m=1:(res-1)/2
%         for n=1:(res-1)/2
%             if S1(m,n)>S1(m,n+1),brk=n;end
%         end
%         Mrsl(m)=max(S1(m,1:brk));
%     end
%     mrsl(s)=max(Mrsl);
%     for n=1:(res-1)/2
%         if S1(1,n)>S1(1,n+1),brk=n;end
%     end
%     nnbw(s)=2*180*(0-theta(brk))/pi;
%     s
% end
% figure(1)
% plot(B/1e9,mrsl,'ko');
% hold on;
% plot(B/1e9,mrsl,'k');
% hold off;
% grid on;
% axis tight;
% figure(2)
% plot(B/1e9,nnbw,'ko');
% hold on;
% plot(B/1e9,nnbw,'k');
% hold off;
% grid on;
% axis tight;