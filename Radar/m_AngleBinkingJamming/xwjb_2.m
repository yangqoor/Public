% ��λ�첨
function u=xwjb_2(S_fwch,S_h,fs,tao,t1,fc)
s_u=1/2*S_fwch+S_h;
s_d=-1/2*S_fwch+S_h;
% �벨����
d=0:1/fc:tao;
y=pulstran(t1,d,'rectpuls',1/(2*fc));
su1=(s_u.*y).^2;
su2=(s_d.*y).^2;
% ��ͨ�˲�
Wn=5e5/(fs/2);
% freqz(b,a,128,1000);
[b,a]=butter(1,Wn);
s_ou=filter(b,a,su1);
s_od=filter(b,a,su2);
sout=s_ou-s_od;
u=mean(sout);