% ���������溯��
function R=gain_r(fw0,fw)   % fw0�ǵ��ź���ָ��fw��Ŀ��Ƕ�
%�״ﲨ�����
width_r=5;
% �������ֵƫ����ź���н�
c_max=1; 
% ����
d=2*pi/width_r;
g=fw0+c_max;
p=fw-g;  
R=abs(sinc(d*p/pi));