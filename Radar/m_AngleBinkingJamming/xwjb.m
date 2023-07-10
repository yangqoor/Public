% 相位检波
function u=xwjb(S_fwch,S_h,fs,tao,t1,fc)
s_u=1/2*S_fwch+S_h;
s_d=-1/2*S_fwch+S_h;
% 半波整流
d=0:1/fc:tao;
y=pulstran(t1,d,'rectpuls',1/(2*fc));
su1=s_u.*y;
su2=s_d.*y;
% 线性检波
% N1=length(t1);
% for i=1:N1
%     if(real(s_u(i))>=0)
%         su1(i)=real(s_u(i));
%     else su1(i)=0;
%     end
%     if(real(s_d(i))>=0)
%         su2(i)=real(s_d(i));
%     else su2(i)=0;
%     end
% end
% 低通滤波
Wn=5e5/(fs/2);
% freqz(b,a,128,1000);
[b,a]=butter(1,Wn);
s_ou=filter(b,a,su1);
s_od=filter(b,a,su2);
sout=s_ou-s_od;
u=mean(sout);
% det=u/n;