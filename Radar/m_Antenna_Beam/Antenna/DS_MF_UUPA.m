% % 由差集确定的子阵列数为5的多频带阵列
% clear;
% c=3e8;%光速
% B=[6.5e9 7e9 7.5e9 8e9 8.5e9 9e9];
% lemda=c./B;
% %************************************************************************
% V=156;
% K=31;
% L=6;
% M=12;
% N=13;
% Nf=5;
% D=[0 1 2 4 13 20 23 24 29 31 34 38 41 44 46 58 72 73 77 88 89 95 97 98,...
% 111 120 124 139 144 150 152];
% %(156,31,6),12*13,5个子阵列,s=9,PSLL=-7.6122dB
% D=sort(mod(D+9,V));
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
% Dc=sort(Dc);
% P=zeros(M,N);index=zeros(1,V-K);
% for m=1:K
%     P(mod(D(m),M)+1,mod(D(m),N)+1)=1;
% end
% for m=1:(V-K)
%     index(m)=mod(m-1,Nf-1)+2;%Nf-floor((Nf-1)*rand);
%     P(mod(Dc(m),M)+1,mod(Dc(m),N)+1)=index(m);
% end
% % %************************************************************************* 
% dx=lemda(Nf)/2*(0:N-1);
% dy=lemda(Nf)/2*(0:M-1);
% res=201;
% k=2*pi./lemda;
% theta=linspace(-pi/2,pi/2,res);
% phi=linspace(0,2*pi,res);
% theta0=pi/4;
% phi0=pi/2;
% u=sin(theta')*cos(phi)-sin(theta0)*cos(phi0);
% v=sin(theta')*sin(phi)-sin(theta0)*sin(phi0);
% u=u';v=v';
% S1=zeros(size(u));S2=zeros(size(u));
% S3=zeros(size(u));S4=zeros(size(u));
% S5=zeros(size(u));
%**************************************************************************
% %search for the best shift
% mrsl=0; 
% for s=0:V-1%ceil(V/2)
%     D=mod(D+s,V);
%     Dempty=zeros(1,V);
%     Dfull=0:V-1;
%     Dc=zeros(1,V-K);
%     for m=1:length(D)
%         Dfull(D(m)+1)=0;
%     end
%     n=0;
%     for m=2:V
%         if Dfull(m)~=0,n=n+1;Dc(n)=Dfull(m);end
%     end
%     Dc=sort(Dc);
%     P=zeros(M,N);
%     for m=1:K
%         P(mod(D(m),M)+1,mod(D(m),N)+1)=1;
%     end
%     for m=1:(V-K)
%         P(mod(Dc(m),M)+1,mod(Dc(m),N)+1)=mod(m-1,Nf-1)+2;
%          %Nf-floor((Nf-1)*rand);        
%     end
%     Mrsl1=-100*ones(Nf,(res-1)/2);
%     Mrsl=-100*ones(1,Nf);
%     for r=1:Nf
%         S=zeros(size(u));
%         for m=1:M
%             for n=1:N
%                 if (P(m,n)==r),S=S+exp(i*k(1)*(dx(n)*u+dy(m)*v));end
%             end
%        end
%        S=abs(S);
%        S=20*log10(S/max(max(S))); 
%        for m=1:(res-1)/2
%            for n=1:(res-1)/2
%               if S(m,n)>S(m,n+1),brk=n;end
%            end
%            Mrsl1(r,m)=max(S(m,1:brk));
%        end
%        Mrsl(r)=max(Mrsl1(r,:));
%     end
%     if mrsl>max(Mrsl)
%        mrsl=max(Mrsl)
%        smin=s;
%     end
%     s
%     if mrsl<-8
%         break;
%     end
% end
%**************************************************************************
% %caculate the beam pattern
% for m=1:M
%     for n=1:N
%         if (P(m,n)==1),S1=S1+exp(i*k(1)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==2),S2=S2+exp(i*k(2)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==3),S3=S3+exp(i*k(3)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==4),S4=S4+exp(i*k(4)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==5),S5=S5+exp(i*k(5)*(dx(n)*u+dy(m)*v));end
%     end
% end
% S1=abs(S1);S2=abs(S2);S3=abs(S3);S4=abs(S4);S5=abs(S5);
% S1=20*log10(S1/max(max(S1)));S2=20*log10(S2/max(max(S2)));S3=20*log10(S3/max(max(S3)));
% S4=20*log10(S4/max(max(S4)));S5=20*log10(S5/max(max(S5)));
% %*************************************************************************
% S=S1;
% for m=1:res
%     for n=1:res
%     if (S(m,n)<-40),S(m,n)=-40; end
%     end
% end
% pla=-7*ones(size(u));
% surf(u,v,S);
% hold on
% surf(u,v,pla);
% Mrsl=-100*ones(1,(res-1)/2);
% for m=1:(res-1)/2
%     for n=1:(res-1)/2
%         if S(m,n)>S(m,n+1),brk=n;end
%     end
%      Mrsl(m)=max(S(m,1:brk));
% end
% mrsl=max(Mrsl)
% figure(1);
% surf(u,v,S);
% %define NNBW
% figure(2);
% plot(theta*180/pi,S(51,:));
% hold on
% plot(theta*180/pi,-3*ones(1,res));
% grid on;
% hold off
% figure(3);
% plot(phi*180/pi,S(:,151),'k');
% hold on;
% plot(phi*180/pi,-3*ones(res,1));
% grid on;
% hold off
%%*************************************************************************
% for m=1:length(D8)
%     for n=1:length(D8)
%         T(m,n)=mod(D8(m)-D8(n),4*V);
%     end
% end
% for m=1:4*V-1
%     num(m)=length(find(T==m));
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%由差集确定的子阵列数为4的多频带阵列
% clear;
% c=3e8;%光速
% B=[6.5e9 7e9 7.5e9 8e9 8.5e9 9e9];
% lemda=c./B;
%%*************************************************************************
% V=341;
% K=85;
% L=21;
% M=11;
% N=31;
% D=[0 1 2 3 5 7 8 11 15 17 20 23 24 31 32 35 40 41 42 47 49 58 63 65 68,...
% 71 76 80 81 83 85 95 99 117 120 127 128 130 131 132 137 142 143 153 161,...
% 163 167 170 171 174 180 182 186 190 191 199 204 208 210 230 234 235 236,...
% 241 255 257 260 261 263 265 272 274 275 285 287 288 300 306 307 314 320,...
% 323 327 330 335];
% D=sort(mod(D+0,V));
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
% Dc=sort(Dc);

% Nf=4;
% P=zeros(M,N);index=zeros(1,V-K);
% for m=1:K
%     P(mod(D(m),M)+1,mod(D(m),N)+1)=1;
% end
% for m=1:(V-K)
%     index(m)=mod(m-1,Nf-1)+2;
%     P(mod(Dc(m),M)+1,mod(Dc(m),N)+1)=index(m);
% end
%%*************************************************************************
% dx=lemda(Nf+1)/2*(0:N-1);
% dy=lemda(Nf+1)/2*(0:M-1);
% res=200;
% k=2*pi./lemda;
% theta=linspace(-pi/2,pi/2,1000);
% phi=linspace(0,2*pi,res);%[0,pi/2];
% theta0=pi/4;
% phi0=0;
% u=sin(theta')*cos(phi)-sin(theta0)*cos(phi0);
% v=sin(theta')*sin(phi)-sin(theta0)*sin(phi0);
% u=u';v=v';
% S1=zeros(size(u));S2=zeros(size(u));
% S3=zeros(size(u));S4=zeros(size(u));
% S5=zeros(size(u));
% for m=1:M
%     for n=1:N
%         if (P(m,n)==1),S1=S1+exp(i*k(1)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==2),S2=S2+exp(i*k(2)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==3),S3=S3+exp(i*k(3)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==4),S4=S4+exp(i*k(4)*(dx(n)*u+dy(m)*v));end
%     end
% end
% S1=abs(S1);S2=abs(S2);S3=abs(S3);S4=abs(S4);
% S1=20*log10(S1/max(max(S1)));S2=20*log10(S2/max(max(S2)));
% S3=20*log10(S3/max(max(S3)));S4=20*log10(S4/max(max(S4)));
%%*************************************************************************
% S=S1;
% for m=1:res
%     for n=1:res
%         if S(m,n)<-40,S(m,n)=-40;end
%     end
% end
% figure(1);
% surf(u,v,S);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%由差集确定的子阵列数为4的多频带阵列
% clear;
% c=3e8;%光速
% B=[6.5e9 7e9 7.5e9 8e9 8.5e9 9e9];
% lemda=c./B;
% %**************************************************************************
% V=255;
% K=127;
% L=63;
% M=15;
% N=17;
% D=[0 1 2 3 4 6 7 8 12 13 14 16 17 19 23 24 25 26 27 28 31 32 34 35 37,...
% 38 41 45 46 48 49 50 51 52 54 56 59 62 64 67 68 70 73 74 75 76 82 85,...
% 90 92 96 98 99 100 102 103 104 105 108 111 112 113 118 119 123 124 127,...
% 128 129 131 134 136 137 139 140 141 143 145 146 148 150 152 153 157 161,...
% 164 165 170 177 179 180 183 184 187 189 191 192 193 196 197 198 199 200,...
% 204 206 208 210 216 217 219 221 222 223 224 226 227 236 237 238 239 241,...
% 246 247 248 251 253 254];
% --------------------------------------------------------------------------
% V=323;
% K=161;
% L=80;
% M=17;
% N=19;
% D=[0 1 3 4 9 10 12 14 16 19 22 25 26 27 29 30 31 35 36 37 38 40 41 42,...
% 43 46 47 48 49 55 56 57 64 65 66 71 75 76 77 78 79 81 83 87 88 90 91 93,...
% 95 97 100 101 104 105 106 107 108 109 111 113 114 115 116 118 120 121,...
% 122 123 124 126 129 133 134 137 138 140 141 143 144 146 147 148 149 152,...
% 157 160 161 164 165 167 168 169 171 172 173 178 181 184 188 190 191 192,...
% 193 195 196 198 206 209 211 213 220 224 225 227 228 229 231 234 237 239,...
% 241 243 247 249 250 251 253 254 256 260 261 262 263 264 265 266 269 270,...
% 271 273 278 279 284 285 290 291 295 299 300 302 303 304 305 308 310 312,...
% 315 316 317 318 321];
% --------------------------------------------------------------------------
% D=sort(mod(D+0,V));
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
% Dc=sort(Dc);
% 
% Nf=4;
% P=zeros(M,N);index1=zeros(1,V);index2=zeros(1,V-K);
% for m=1:K
%     index1(m)=2*mod(m-1,Nf/2)+1;
%     P(mod(D(m),M)+1,mod(D(m),N)+1)=index1(m);
% end
% for m=1:(V-K)
%     index2(m)=2*mod(m-1,Nf/2)+2;
%     P(mod(Dc(m),M)+1,mod(Dc(m),N)+1)=index2(m);
% end
% %************************************************************************* 
% dx=lemda(Nf)/2*(0:N-1);
% dy=lemda(Nf)/2*(0:M-1);
% res=201;
% k=2*pi./lemda;
% theta=linspace(-pi/2,pi/2,res);
% phi=linspace(0,2*pi,res);%[0,pi/2];
% theta0=0;
% phi0=pi/2;
% u=sin(theta')*cos(phi)-sin(theta0)*cos(phi0);
% v=sin(theta')*sin(phi)-sin(theta0)*sin(phi0);
% u=u';v=v';
% S1=zeros(size(u));S2=zeros(size(u));
% S3=zeros(size(u));S4=zeros(size(u));
% S5=zeros(size(u));
% for m=1:M
%     for n=1:N
%         if (P(m,n)==1),S1=S1+exp(i*k(1)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==2),S2=S2+exp(i*k(2)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==3),S3=S3+exp(i*k(3)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==4),S4=S4+exp(i*k(4)*(dx(n)*u+dy(m)*v));end
%     end
% end
% S1=abs(S1);S2=abs(S2);S3=abs(S3);S4=abs(S4);
% S1=20*log10(S1/max(max(S1)));S2=20*log10(S2/max(max(S2)));
% S3=20*log10(S3/max(max(S3)));S4=20*log10(S4/max(max(S4)));
% %*************************************************************************
% S=S1;
% for m=1:res
%     for n=1:res
%     if (S(m,n)<-40),S(m,n)=-40; end
%     end
% end
% figure(1);
% surf(u,v,S);
% %*************************************************************************
% % %define NNBW
% plot(theta*180/pi,S(1,:),'k');
% hold on;
% plot(theta*180/pi,S(51,:));
% grid on;
% plot(theta*180/pi,-3*ones(1,res));
% hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 由差集确定的子阵列数为7的多频带阵列
clear;
c=3e8;%光速
B=[6.25e9 6.75e9 7.25e9 7.75e9 8.25e9 8.75e9 9.25e9];
lemda=c./B;
%**************************************************************************
V=400;
K=57;
L=8;
D=[0 1 2 4 14 19 20 31 35 38 42 47 48 64 66 73 80 94 103 105 114 128,...
162 164 167 168 177 186 189 199 206 214 222 226 243 257 259 264 265,...
279 283 291 308 311 313 314 321 324 332 334 360 364 375 387 390 395 396];
%(400,57,8),16*25,7个子阵列
D=sort(mod(D+0,V));
Dempty=zeros(1,V);
Dfull=0:V-1;
Dc=zeros(1,V-K);
for m=1:length(D)
    Dfull(D(m)+1)=0;
end
n=0;
for m=2:V
    if Dfull(m)~=0,n=n+1;Dc(n)=Dfull(m);end
end
Dc=sort(Dc);
M=16;
N=25;
Nf=7;
P=zeros(M,N);index=zeros(1,V-K);
for m=1:K
    P(mod(D(m),M)+1,mod(D(m),N)+1)=1;
end
for m=1:(V-K)
    index(m)=mod(m-1,Nf-1)+2;%2+floor((Nf-1)*rand);
    P(mod(Dc(m),M)+1,mod(Dc(m),N)+1)=index(m);
end
%**************************************************************************
dx=lemda(Nf)/2*(0:N-1);
dy=lemda(Nf)/2*(0:M-1);
res=401;
k=2*pi./lemda;
theta=linspace(-pi/2,pi/2,res);
phi=linspace(0,2*pi,res);
theta0=pi/4;
phi0=pi/2;
[X,Y]=meshgrid(theta,phi);
u=sin(X).*cos(Y)-sin(theta0)*cos(phi0);
v=sin(X).*sin(Y)-sin(theta0)*sin(phi0);
S1=zeros(size(u));S2=zeros(size(u));
S3=zeros(size(u));S4=zeros(size(u));
S5=zeros(size(u));S6=zeros(size(u));
S7=zeros(size(u));
for m=1:M
    for n=1:N
        if (P(m,n)==1),S1=S1+exp(i*k(1)*(dx(n)*u+dy(m)*v));end
        if (P(m,n)==2),S2=S2+exp(i*k(2)*(dx(n)*u+dy(m)*v));end
        if (P(m,n)==3),S3=S3+exp(i*k(3)*(dx(n)*u+dy(m)*v));end
        if (P(m,n)==4),S4=S4+exp(i*k(4)*(dx(n)*u+dy(m)*v));end
        if (P(m,n)==5),S5=S5+exp(i*k(5)*(dx(n)*u+dy(m)*v));end
        if (P(m,n)==6),S6=S6+exp(i*k(6)*(dx(n)*u+dy(m)*v));end
        if (P(m,n)==7),S7=S7+exp(i*k(7)*(dx(n)*u+dy(m)*v));end
    end
end
S1=abs(S1);S2=abs(S2);S3=abs(S3);S4=abs(S4);S5=abs(S5);S6=abs(S6);S7=abs(S7);
S1=20*log10(S1/max(max(S1)));S2=20*log10(S2/max(max(S2)));
S3=20*log10(S3/max(max(S3)));S4=20*log10(S4/max(max(S4)));
S5=20*log10(S5/max(max(S5)));S6=20*log10(S6/max(max(S6)));
S7=20*log10(S7/max(max(S7)));
%**************************************************************************
S=S1;
for m=1:res
    for n=1:res
        if S(m,n)<-40,S(m,n)=-40;end
    end
end
figure(1);
surf(u,v,S);
% PSLL
Mrsl=zeros(1,(res-1)/2);
for m=1:(res-1)/2
    for n=1:(res-1)/2
        if S(m,n)>S(m,n+1),brk=n;end
    end
     Mrsl(m)=max(S(m,1:brk));
end
mrsl=max(Mrsl)
S=S1;
for m=1:res
    for n=1:res
        if S(m,n)<-40,S(m,n)=-40;end
    end
end
figure(1);
surf(u,v,S);
% HPBW
figure(2);
plot(theta*180/pi,S(51,:));
hold on
plot(theta*180/pi,-3*ones(1,res));
grid on;
hold off
figure(3);
plot(phi*180/pi,S(:,151),'k');
hold on;
plot(phi*180/pi,-3*ones(res,1));
grid on;
hold off

% %**************************************************************************
% % for m=1:length(D8)
% %     for n=1:length(D8)
% %         T(m,n)=mod(D8(m)-D8(n),4*V);
% %     end
% % end
% % for m=1:4*V-1
% %     num(m)=length(find(T==m));
% % end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 由差集确定的子阵列数为11的多频带阵列
% clear;
% c=3e8;%光速
% B=[6e9 6.3e9 6.6e9 6.9e9 7.2e9 7.5e9 7.8e9 8.1e9 8.4e9 8.7e9 9e9];
% lemda=c./B;
% %**************************************************************************
% V=1464;
% K=133;
% L=121;
% D=[0 1 2 4 61 66 88 97 105 109 112 118 141 160 170 188 202 225 228,...
% 239 265 273 275 293 310 317 323 331 352 357 377 379 393 402 418 419,...
% 426 432 434 451 458 464 467 500 502 503 534 546 554 569 615 636 650,...
% 665 667 674 676 679 680 701 705 717 721 750 754 773 798 809 814 836,...
% 846 847 861 864 871 877 887 889 905 908 910 920 925 932 938 947 985,...
% 1000 1004 1008 1019 1039 1042 1050 1051 1062 1097 1101 1106 1128 1140,...
% 1157 1160 1164 1165 1170 1174 1181 1187 1188 1192 1194 1200 1214 1240,...
% 1245 1257 1259 1264 1267 1270 1285 1286 1319 1320 1330 1339 1340 1348,...
% 1358 1376 1387 1408];
% % %(1464,133,121),24*61,11个子阵列
% D=sort(mod(D+0,V));
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
% Dc=sort(Dc);
% M=24;
% N=61;
% Nf=11;
% % P=zeros(M,N);index=zeros(1,V-K);
% % for m=1:K
% %     P(mod(D(m),M)+1,mod(D(m),N)+1)=1;
% % end
% % for m=1:(V-K)
% %     index(m)=2+floor((Nf-1)*rand);%mod(m-1,Nf-1)+2;
% %     P(mod(Dc(m),M)+1,mod(Dc(m),N)+1)=index(m);
% % end
% P=[1	4	8	2	2	1	4	10	2	8	1	5	10	2	10	8	9	2	5	6	11	3	8	7	2	3	11	5	6	6	1	9	1	11	9	9	8	9	4	1	4	1	6	6	7	3	2	2	10	7	6	10	7	7	7	5	5	3	8	7	7
% 2	1	8	8	10	5	11	5	9	1	9	9	4	8	3	8	4	10	7	6	10	1	11	5	8	5	7	7	9	5	11	5	9	10	6	1	1	11	9	11	4	10	10	8	10	11	2	5	7	7	1	6	11	11	10	7	6	8	10	11	8
% 4	6	1	1	2	1	6	1	1	6	5	6	3	5	6	10	10	6	4	7	7	8	7	1	11	8	10	5	11	5	9	1	4	6	3	5	8	3	10	8	1	4	3	8	11	10	5	4	1	7	9	4	11	3	4	11	3	6	2	6	10
% 11	5	3	11	8	8	8	6	5	9	3	2	7	11	7	2	9	6	10	6	4	3	5	6	3	9	11	2	8	8	11	5	6	6	8	11	5	4	2	5	11	3	9	2	9	8	2	8	11	8	8	6	3	10	10	7	4	6	7	9	10
% 9	5	9	9	1	1	1	7	6	6	8	8	9	3	11	9	10	7	11	10	2	2	10	8	3	8	6	9	3	10	4	8	11	10	10	10	9	5	10	10	7	3	7	2	4	6	4	9	5	11	2	5	5	3	8	11	8	9	6	8	11
% 9	8	4	8	8	4	3	11	4	5	5	11	1	11	6	2	5	3	8	5	9	10	1	11	5	8	4	9	9	4	1	10	2	3	10	3	2	10	5	3	3	1	4	10	2	11	11	5	10	1	4	2	4	3	6	5	3	6	7	1	3
% 10	9	5	7	6	1	8	2	8	10	11	6	10	5	3	9	9	10	1	11	7	9	7	11	7	1	9	4	4	10	3	7	11	2	5	3	7	11	6	7	4	4	3	10	11	9	1	2	3	9	8	11	8	1	3	6	10	3	6	11	10
% 10	9	1	3	3	7	2	6	1	9	4	8	4	6	3	8	10	1	7	6	7	3	11	5	4	2	11	5	9	6	11	8	11	3	2	11	5	6	11	6	3	2	8	4	2	5	9	2	7	6	11	8	8	8	1	8	2	11	9	9	9
% 4	1	9	4	3	1	9	10	10	1	2	9	11	5	8	7	3	4	11	5	2	9	7	6	5	4	10	6	2	7	11	7	4	9	1	4	7	1	5	8	4	2	5	4	10	7	6	8	4	7	6	8	5	2	2	6	5	11	5	9	3
% 2	6	10	10	3	3	4	2	9	9	4	9	8	3	7	2	10	5	4	10	9	5	8	6	3	10	2	1	2	1	11	8	8	3	1	8	7	1	7	5	4	2	1	5	1	8	3	6	10	11	4	6	9	6	7	2	4	7	3	11	8
% 9	5	3	8	8	1	6	4	8	11	6	3	8	4	9	9	7	8	3	1	11	7	1	11	8	9	5	8	8	8	6	5	4	9	2	3	4	6	2	9	10	10	4	6	11	6	2	7	3	1	4	5	1	5	8	5	3	8	3	5	6
% 2	8	8	11	7	4	4	10	8	2	9	2	2	3	8	5	5	6	1	4	10	3	6	10	2	8	10	2	1	9	7	1	1	10	6	9	10	8	9	1	1	9	7	1	10	10	2	7	4	3	5	6	2	1	10	10	4	7	11	8	5
% 3	4	10	11	5	1	4	9	6	2	6	5	10	10	7	8	6	3	10	11	5	4	8	8	10	11	1	3	3	1	2	4	9	9	8	7	6	3	6	7	9	7	1	9	3	1	4	11	6	2	7	5	4	7	8	5	5	3	2	5	5
% 1	10	8	4	1	2	1	8	11	10	1	5	5	6	3	4	8	2	6	10	11	3	10	1	8	5	4	11	2	2	7	6	9	9	11	3	3	11	8	11	7	2	6	10	6	11	11	2	1	11	7	9	5	8	10	2	2	6	2	5	7
% 3	10	5	6	6	1	9	8	7	8	6	4	10	7	8	2	1	3	7	6	6	2	4	11	11	9	10	11	3	6	7	2	5	2	11	7	4	3	6	8	4	2	8	6	6	11	3	4	2	7	4	10	5	9	11	1	5	9	7	2	8
% 9	3	10	9	2	1	6	10	3	2	7	6	8	2	7	9	9	7	8	5	2	9	5	11	4	5	11	6	8	3	2	3	8	3	11	10	10	8	4	6	9	8	3	11	2	9	2	2	3	7	6	2	8	5	3	9	3	8	11	7	9
% 2	8	4	7	6	1	4	3	4	3	2	10	6	5	9	9	11	7	2	3	1	8	8	7	1	4	7	1	7	6	7	8	7	1	10	4	5	9	1	3	10	5	5	5	1	6	3	1	5	10	9	1	6	2	4	10	8	3	3	3	9
% 7	10	2	7	6	5	3	2	6	4	6	1	10	6	5	11	1	9	4	7	1	9	9	2	4	5	2	8	7	8	2	11	11	3	6	10	3	8	5	8	3	7	6	6	4	5	5	2	7	8	4	1	7	11	11	1	6	3	2	8	1
% 6	9	5	6	6	1	7	11	2	11	11	1	4	1	11	9	11	9	3	5	6	7	9	4	3	7	7	2	2	10	8	6	2	6	9	1	1	8	9	9	5	6	4	6	6	9	9	5	5	4	10	8	10	5	11	3	10	9	1	10	1
% 4	2	6	9	6	11	10	3	5	10	5	3	7	1	1	2	11	9	6	6	2	3	8	5	1	6	1	2	8	11	3	8	9	10	7	5	2	6	2	3	3	7	9	8	8	1	5	1	10	5	10	7	11	8	6	7	10	1	1	2	3
% 10	7	6	3	11	1	4	10	7	3	5	5	1	4	6	8	4	1	6	10	11	10	2	8	4	4	2	2	1	3	10	11	8	4	2	2	10	5	11	5	11	11	6	1	10	3	9	8	8	9	6	5	3	8	1	4	8	8	8	1	2
% 4	7	7	1	9	3	5	1	8	8	2	6	9	11	9	6	8	2	3	1	6	11	10	2	8	1	9	4	7	2	10	8	4	7	8	7	6	2	4	3	4	7	3	2	4	2	1	4	11	11	11	11	1	5	10	4	7	9	10	4	11
% 5	10	11	6	10	1	3	3	6	10	2	8	11	4	1	1	11	10	8	2	6	1	6	4	5	10	5	9	5	9	3	3	6	4	9	4	3	6	7	11	10	2	8	9	2	4	8	2	9	7	1	7	5	8	4	2	1	1	3	3	11
% 8	9	11	3	7	5	11	5	8	7	8	10	9	4	3	1	5	7	11	8	3	4	4	10	7	11	2	11	11	10	11	10	3	1	10	7	9	9	1	11	8	9	2	4	8	5	11	5	9	10	11	4	2	4	2	2	1	3	9	2	8
% ];
% %**************************************************************************
% dx=lemda(Nf)/2*(0:N-1);
% dy=lemda(Nf)/2*(0:M-1);
% res=201;
% k=2*pi./lemda;
% theta=linspace(-pi/2,pi/2,res);
% phi=linspace(0,2*pi,res);
% theta0=pi/4;
% phi0=pi/2;
% [X,Y]=meshgrid(theta,phi);
% u=sin(X).*cos(Y)-sin(theta0)*cos(phi0);
% v=sin(X).*sin(Y)-sin(theta0)*sin(phi0);
% S1=zeros(size(u));S2=zeros(size(u));S3=zeros(size(u));
% S4=zeros(size(u));S5=zeros(size(u));S6=zeros(size(u));
% S7=zeros(size(u));S8=zeros(size(u));S9=zeros(size(u));
% S10=zeros(size(u));S11=zeros(size(u));
% for m=1:M
%     for n=1:N
%         if (P(m,n)==1),S1=S1+exp(i*k(1)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==2),S2=S2+exp(i*k(2)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==3),S3=S3+exp(i*k(3)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==4),S4=S4+exp(i*k(4)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==5),S5=S5+exp(i*k(5)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==6),S6=S6+exp(i*k(6)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==7),S7=S7+exp(i*k(7)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==8),S8=S8+exp(i*k(8)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==9),S9=S9+exp(i*k(9)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==10),S10=S10+exp(i*k(10)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==11),S11=S11+exp(i*k(11)*(dx(n)*u+dy(m)*v));end
%     end
% end
% S1=abs(S1);S2=abs(S2);S3=abs(S3);S4=abs(S4);S5=abs(S5);S6=abs(S6);
% S7=abs(S7);S8=abs(S8);S9=abs(S9);S10=abs(S10);S11=abs(S11);
% S1=20*log10(S1/max(max(S1)));S2=20*log10(S2/max(max(S2)));
% S3=20*log10(S3/max(max(S3)));S4=20*log10(S4/max(max(S4)));
% S5=20*log10(S5/max(max(S5)));S6=20*log10(S6/max(max(S6)));
% S7=20*log10(S7/max(max(S7)));S8=20*log10(S8/max(max(S8)));
% S9=20*log10(S9/max(max(S9)));S10=20*log10(S10/max(max(S10)));
% S11=20*log10(S11/max(max(S11)));
% %**************************************************************************
% S=S1;
% for m=1:res
%     for n=1:res
%         if S(m,n)<-40,S(m,n)=-40;end
%     end
% end
% figure(1);
% surf(u,v,S);
% %PSLL
% % Mrsl=zeros(1,(res-1)/2);
% % for m=1:(res-1)/2
% %     for n=1:(res-1)/2
% %         if S(m,n)>S(m,n+1),brk=n;end
% %     end
% %      Mrsl(m)=max(S(m,1:brk));
% % end
% % mrsl=max(Mrsl)
% % figure(2);
% % plot(theta*180/pi,S(1,:),'k');
% % hold on;
% % plot(theta*180/pi,S(51,:));
% % plot(theta*180/pi,-3*ones(1,res));
% % grid on;
% % hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 由差集确定的子阵列数为3的多频带阵列
% clear;
% c=3e8;%光速
% B=[6.5e9 7e9 7.5e9 8e9 8.5e9 9e9];
% lemda=c./B;
% % %************************************************************************
% V=364;
% K=121;
% L=40;
% M=13;
% N=28;
% D=[0 1 2 3 4 6 8 9 11 16 17 19 22 24 32 35 36 41 42 46 48 50 56 73,...
% 76 78 79 80 88 89 92 99 105 106 107 109 110 111 114 122 123 127 128,...
% 132 133 134 142 151 152 153 156 162 163 169 171 174 177 181 183 187,...
% 189 190 198 201 203 207 210 212 214 218 221 222 223 224 229 234 237,...
% 241 246 248 249 250 251 256 260 262 264 274 281 283 285 286 289 292,...
% 299 300 302 305 306 307 309 311 314 315 317 318 322 326 327 330 331,...
% 336 343 348 350 351 353 354 357 358 360];
% %(364,121,40),14*26,3个子阵列
% D=sort(mod(D+0,V));
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
% Dc=sort(Dc);
% 
% Nf=3;
% P=zeros(M,N);index=zeros(1,V-K);
% for m=1:K
%     P(mod(D(m),M)+1,mod(D(m),N)+1)=1;
% end
% for m=1:(V-K)
%     index(m)=mod(m-1,Nf-1)+2;%Nf-floor((Nf-1)*rand);
%     P(mod(Dc(m),M)+1,mod(Dc(m),N)+1)=index(m);
% end
% %************************************************************************* 
% dx=lemda(Nf)/2*(0:N-1);
% dy=lemda(Nf)/2*(0:M-1);
% res=201;
% k=2*pi./lemda;
% theta=linspace(-pi/2,pi/2,res);
% phi=linspace(0,2*pi,res);
% theta0=0;
% phi0=pi/2;
% u=sin(theta')*cos(phi)-sin(theta0)*cos(phi0);
% v=sin(theta')*sin(phi)-sin(theta0)*sin(phi0);
% u=u';v=v';
% S1=zeros(size(u));S2=zeros(size(u));
% S3=zeros(size(u));
% for m=1:M
%     for n=1:N
%         if (P(m,n)==1),S1=S1+exp(i*k(2)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==2),S2=S2+exp(i*k(4)*(dx(n)*u+dy(m)*v));end
%         if (P(m,n)==3),S3=S3+exp(i*k(6)*(dx(n)*u+dy(m)*v));end
%     end
% end
% S1=abs(S1);S2=abs(S2);S3=abs(S3);
% S1=20*log10(S1/max(max(S1)));S2=20*log10(S2/max(max(S2)));
% S3=20*log10(S3/max(max(S3)));
% %*************************************************************************
% S=S1;
% for m=1:res
%     for n=1:res
%     if (S(m,n)<-40),S(m,n)=-40; end
%     end
% end
% figure(1)
% surf(u,v,S);
% Mrsl=-100*ones(1,(res-1)/2);
% for m=1:(res-1)/2
%     for n=1:(res-1)/2
%         if S(m,n)>S(m,n+1),brk=n;end
%     end
%      Mrsl(m)=max(S(m,1:brk));
% end
% mrsl=max(Mrsl)