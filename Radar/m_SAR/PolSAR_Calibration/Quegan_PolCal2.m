function [u,v,w,z,alpha,r_Ohh_conjOvh,r_Ovv_conjOhv,r_Ohh_conjOvv] = Quegan_PolCal2(SLC_11,SLC_12,SLC_21,SLC_22)
% Polarization Calibration
%
% ���룺
%   1��SLC_11    ѡ������� HH ͨ���� SLC ����
%   2��SLC_12               HV
%   3��SLC_21               VH
%   4��SLC_22               VV
% ע������ʹ�������һ�£�����ǰ�պ󷢡�;
%
% �����
%   1��������� u,v,w,z,alpha
%   ע�⣺
%       ����û�жԽ���ͨ����ƽ�� k �� ����ϵͳ���� Y ���꣨��Ϊ��������Ҫ�Ƿ��������ݣ�
%       k �� Y ������ĳ�����������Ƿ��������ݽ�����⡣
%   2��ͬ�����ͽ��漫��ͨ��֮��Ĺ�һ�����漫�����ϵ��
%       r_Ohh_conjOvh �� r_Ovv_conjOhv
% 2016.12.05. ��� r_Ohh_conjOvv �ļ���
%   3������ͬ����ͨ�� HH �� VV ֮��Ĺ�һ�����ϵ��
%       r_Ohh_conjOvv
%
% ��������2017.11.28. 11:16


%%
% -------------------------------------------------------------------------
%                                Quegan �㷨
% -------------------------------------------------------------------------
%
% ���룺ĳһ�����򣨷ֲ�Ŀ�꣩��ȫ��������ͨ���� SLC ����
%
% ��������������������� u,v,w,z �� alpha�������� Y �� k��

%%
% ����۲����O������ؾ���C��4��4����
% C11 = < O11 * conj(O11) >
C11 = mean(mean(SLC_11.*conj(SLC_11)));
% C12 = < O11 * conj(O21) >
C12 = mean(mean(SLC_11.*conj(SLC_21)));
% C13 = < O11 * conj(O12) >
C13 = mean(mean(SLC_11.*conj(SLC_12)));
% C14 = < O11 * conj(O22) >
C14 = mean(mean(SLC_11.*conj(SLC_22)));

% C21 = < O21 * conj(O11) >
C21 = mean(mean(SLC_21.*conj(SLC_11)));
% C22 = < O21 * conj(O21) >
C22 = mean(mean(SLC_21.*conj(SLC_21)));
% C23 = < O21 * conj(O12) >
C23 = mean(mean(SLC_21.*conj(SLC_12)));
% C24 = < O21 * conj(O22) >
C24 = mean(mean(SLC_21.*conj(SLC_22)));

% C31 = < O12 * conj(O11) >
C31 = mean(mean(SLC_12.*conj(SLC_11)));
% C32 = < O12 * conj(O21) >
C32 = mean(mean(SLC_12.*conj(SLC_21)));
% C33 = < O12 * conj(O12) >
C33 = mean(mean(SLC_12.*conj(SLC_12)));
% C34 = < O12 * conj(O22) >
C34 = mean(mean(SLC_12.*conj(SLC_22)));

% C41 = < O22 * conj(O11) >
C41 = mean(mean(SLC_22.*conj(SLC_11)));
% C42 = < O22 * conj(O21) >
C42 = mean(mean(SLC_22.*conj(SLC_21)));
% C43 = < O22 * conj(O12) >
C43 = mean(mean(SLC_22.*conj(SLC_12)));
% C44 = < O22 * conj(O22) >
C44 = mean(mean(SLC_22.*conj(SLC_22)));

% ���ˣ��۲����O������ؾ���C��4��4�����Ѿ�������ϡ�

%%
% ���㶨����������� u,v,w,z �� alpha ��

% 1��The cross-talk ratios
C_delta = C11*C44 - abs(C14)^2;
%   a��u = r21 / r11
u = ( C44*C21 - C41*C24 )/C_delta;
%   b��v = t21 / t22
v = ( C11*C24 - C21*C14 )/C_delta;
%   c��w = r12 / r22
w = ( C11*C34 - C31*C14 )/C_delta;% ���޸ģ�ԭ���� z д���ˣ�!
%   d��z = t12 / t11
z = ( C44*C31 - C41*C34 )/C_delta;% ���޸ģ�ԭ���� w д���ˣ�!
% ���ˣ�u,v,w,z �Ѽ���õ���

% 2��The ratio of the receive and transmit channel imbalances
%      alpha = ( r22 / r11 )*( t11 / t22 )
alpha1 = ( C22 - u*C12 - v*C42 )/( C32 - z*C12 - w*C42 );
alpha2 = conj( C32 - z*C12 - w*C42 )/( C33 - conj(z)*C31 - conj(w)*C34 );
% �� alpha1 �� alpha2 ��ϵõ� alpha �Ľ�
abs_alpha = (abs(alpha1*alpha2) - 1 + sqrt( (abs(alpha1*alpha2)-1)^2 + 4*abs(alpha2)^2 ))...
    /( 2*abs(alpha2) );
    % �����ϣ�alpha1 �� alpha2 ����λ����ͬ�ģ���ѡһ����Ϊ alpha ����λ���ɣ�
    % ���������У���ȡ alpha1 �� alpha2 ����λ��ƽ��ֵ��Ϊ alpha ����λ��
    % 2016.11.01.ȡƽ������Ϊ�����һ�����⣬������Ϊ2�еĻ����ȡƽ�����ܻ����;���Ի�����ѡһ��;
% phase_alpha = ( angle(alpha1) + angle(alpha2) )/2;  % ȡƽ��ֵ
phase_alpha = angle(alpha1);  % ȡ alpha1 ����λ
alpha = abs_alpha*exp(1j*phase_alpha);
% ���ˣ�alpha �Ѽ���õ���


%%
% ͬ�����ͽ��漫��ɢ���ź�֮��Ĺ�һ�����漫�����ϵ��
% ����ͬ����ͨ���ͽ��漫��ͨ��������ϵ����Quegan�㷨�����������Ϊ0��
%
% �ο����ף�'Improvement of Polarimetric SAR Calibration based on the Quegan
% Algorithm'��ʽ��5����

% 1��Ohh �� Ovh ����
r_Ohh_conjOvh = C12/(sqrt(C11*C22));
% 2��Ovv �� Ohv ����
r_Ovv_conjOhv = C43/(sqrt(C44*C33));

% 2016.12.05. ����������
% 3��Ohh �� Ovv ����
r_Ohh_conjOvv = C14/(sqrt(C11*C44));


end