%�Ͳ�����
function [G_h,G_fwch]=hchwl(fw0,fw)   % fw0�ǵ��ź���ָ��fw��Ŀ��Ƕ�
% ����
%�Ͳ�������ͼ�������
G_h=abs(gain_l(fw0,fw)+gain_r(fw0,fw));
%�������ͼ������� 
G_fwch=abs(gain_r(fw0,fw)-gain_l(fw0,fw));
