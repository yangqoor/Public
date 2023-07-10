%elements' position in each circle is defined by difference sets
% clear;
% c=3e8;%光速
% f=3e9;
% lemda=c/f;
% k=2*pi./lemda;
% V=341;
% K=85;
% L=21;
% D=[0 1 2 3 5 7 8 11 15 17 20 23 24 31 32 35 40 41 42 47 49 58 63 65 ...
% 68 71 76 80 81 83 85 95 99 117 120 127 128 130 131 132 137 142 143 153 ...
% 161 163 167 170 171 174 180 182 186 190 191 199 204 208 210 230 ...
% 234 235 236 241 255 257 260 261 263 265 272 274 275 285 287 288 300 ...
% 306 307 314 320 323 327 330 335];
% %(255,127,63)[0	1	2	3	4	5	6	13	14	16	18	19	21	24	26	32	33	34	36	39	40	42	43	44	45	47	49	50	51	53	54	56	57	59	61	63	65	66	69	70	72	76	78	79	80	84	87	88	94	97	99	100	101	102	103	104	106	107	108	109	110	112	117	121	126	127	128	129	131	132	136	138	141	142	143	148	149	152	155	164	166	168	172	173	177	178	180	181	184	186	188	189	190	191	194	198	199	200	201	202	205	206	207	208	212	213	214	217	218	221	222	223	225	226	227	230	232	233	238	240	241	243	244	245	247	249	252];
% %(63,32,16)[0 5 6 10 12 15 16 17 18 20 24 25 26 29 32 34 35 37 38 39 41 42 45 46 48 50 52 53 54 55 56 57];
% Nx=11;
% Ny=1;
% Nz=31;
% x=mod(D,Nx);
% y=mod(D,Ny);
% z=mod(D,Nz);
% P=zeros(Nx,Nz);
% for m=1:K
%     for n=0:Nx-1
%     if x(m)==n,P(x(m)+1,z(m)+1)=1;end
% %     if x(m)==1,P(x(m)+1,z(m)+1)=1;end
% %     if x(m)==2,P(x(m)+1,z(m)+1)=1;end
% %     if x(m)==3,P(x(m)+1,z(m)+1)=1;end
% %     if x(m)==4,P(x(m)+1,z(m)+1)=1;end
% %     if x(m)==5,P(x(m)+1,z(m)+1)=1;end
% %     if x(m)==6,P(x(m)+1,z(m)+1)=1;end
%     end
% end
% M=Nx;%number of circles
% N=Nz;%number of elements in each circle
% R=N*lemda/4/pi;%radius of the circle
% 
% k=2*pi/lemda;
% fai=(1:N)*2*pi/N;
% z=(0:M-1)*lemda/2;
% theta0=pi/2;
% phi0=pi/2;
% theta=linspace(0,pi,500);
% phi=linspace(0,2*pi,500);
% u=zeros(length(theta),length(theta));
% S0=zeros(length(theta),length(theta));
% S=zeros(length(theta),length(theta));
% for m=1:M
%     for n=1:N
%            u=meshgrid(sin(theta)).*(meshgrid(cos(phi-fai(n))))'-...
%              sin(theta0)*cos(phi0-fai(n));
% %         if P(m,n)==0
% %            S0=S0+exp(i*k*(R*u+z(m)*meshgrid(cos(theta))));
% %         end
%            S0=S0+exp(i*k*(R*u+z(m)*meshgrid(cos(theta))));
%         if P(m,n)==1
%            S=S+exp(i*k*(R*u+z(m)*meshgrid(cos(theta))));
%         end
%     end
% end
% S0=abs(S0);S=abs(S);
% S0=S0/max(max(S0));S=S/max(max(S));
% S0=20*log10(S0);S=20*log10(S);
% [X,Y]=meshgrid(theta,phi);
% figure(1);
% mesh(X,Y,S0);
% % for m=1:500
% % plot(theta/pi,S0(m,:));
% % hold on;
% % end
% figure(2);
% mesh(X,Y,S);
% % for m=1:500
% % plot(theta/pi,S(m,:));
% % hold on;
% % end
%--------------------------------------------------------------------------
%elements' position in each circle and circles'position in the linear array
%are defined by difference sets
clear;
c=3e8;%光速
f=3e9;
lemda=c/f;
k=2*pi./lemda;
Vl=13;
Kl=4;
Ll=1;
Dl=[0 1 3 9];
Vc=31;
Kc=6;
Lc=1;
Dc=[1 5 11 24 25 27];
Nx=Vl;
Ny=1;
Nz=Vc;
x=mod(Dl,Nx);
z=mod(Dc,Nz);
P=ones(Nx,Nz);
P(1:Nx,z(1:Kc)+1)=0;
P(x(1:Kl)+1,1:Nz)=0;

M=Nx;%number of circles
N=Nz;%number of elements in each circle
R=N*lemda/4/pi;%radius of the circle

k=2*pi/lemda;
fai=(1:N)*2*pi/N;
z=(0:M-1)*lemda/2;
theta0=pi/2;
phi0=pi/2;
theta=linspace(0,pi,500);
phi=linspace(0,2*pi,500);
u=zeros(length(theta),length(theta));
S0=zeros(length(theta),length(theta));
S=zeros(length(theta),length(theta));
for m=1:M
    for n=1:N
           u=meshgrid(sin(theta)).*(meshgrid(cos(phi-fai(n))))'-...
             sin(theta0)*cos(phi0-fai(n));
%         if P(m,n)==0
%            S0=S0+exp(i*k*(R*u+z(m)*meshgrid(cos(theta))));
%         end
           S0=S0+exp(i*k*(R*u+z(m)*meshgrid(cos(theta))));
        if P(m,n)==1
           S=S+exp(i*k*(R*u+z(m)*meshgrid(cos(theta))));
        end
    end
end
S0=abs(S0);S=abs(S);
S0=S0/max(max(S0));S=S/max(max(S));
S0=20*log10(S0);S=20*log10(S);
[X,Y]=meshgrid(theta,phi);
figure(1);
mesh(X,Y,S0);
% for m=1:500
% plot(theta/pi,S0(m,:));
% hold on;
% end
figure(2);
mesh(X,Y,S);
% for m=1:500
% plot(theta/pi,S(m,:));
% hold on;
% end