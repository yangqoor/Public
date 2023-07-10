function [PSLR_r,ISLR_r,IRW_r, PSLR_a,ISLR_a,IRW_a] = target_analysis_2(s_ac,Fr,Fa,Vr)
% ��ֹ�� 2014.10.10 10:34 a.m.
% 
% 2014.10.10. �޸��ˣ� ָ����㺯�����ø��ĺ��: zhibiao_2( )
% 2014.10.10. �޸��ˣ� ��ά���㷽ʽ����Ϊ�� 2 �ַ������ȶ�ÿ�в��㣬�ٶ�ÿ�в��㡣
%
% ===============================================================
% �ó������˴�б�ӽ��£��Ե�Ŀ���Ť��
% �ֱ��Ǿ�����ͷ�λ��
% ���Ǿ�������ת�Ƕȣ�������������ת��ƽ����ˮƽ�ᣬ��ȡ������Ƭ
% ���Ƿ�λ����ת�Ƕȣ�����λ������ת��ƽ���ڴ�ֱ�ᣬ��ȡ������Ƭ
% ===============================================================
%
% ��������� s_ac  ��������Ҫ����ָ������ĵ�Ŀ���k��s_ac�������ڵ�һ��������ݡ�
% ��������� Fr  ���� �����������
% ��������� Fa  ���� ��λ�������
% ��������� Vr  ���� ƽ̨�ٶ�
% �ú�����������Ŀ��k�ĸ���ָ��
% ��Ŀ�����ĵ�����Ƭ�������򣩣���ֵ�԰��(PSLR)�������԰��(ISLR),����ֱ��ʣ�IRW����
% ��Ŀ�����ĵ�����Ƭ����λ�򣩣���ֵ�԰��(PSLR)�������԰��(ISLR),����ֱ��ʣ�IRW����
% ���ֵ�ֱ�������Ƭ������Ƭ�ĸ���ָ��
%
% ���㷽ʽ�ܹؼ�
% ������õķ��������У������ж�������Сֵλ�ã�Ȼ������Сֵλ�ô����в���
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       ȡ��Ŀ������ NN*NN ��Ƭ������������
%   ��ȡ��Ŀ�����ģ���������Ƭ����λ����Ƭ������������
%                   �����������ָ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
c = 3e8;                % ����

% ȡ��Ŀ���������Ƭ��NN*NN
% ���ж�ά������
NN = 32;        % ��Ƭ�ܳ��ȣ�NN*NN
[row,column] = size(s_ac);      % s_ac�ľ����С
[aa,p] = max(abs(s_ac));           
[bb,q] = max(max(abs(s_ac)));
 
row_max = p(q);    	% ��ά�������ֵ�����ڵڼ��С��� row_max��
column_max = q;     % ��ά�������ֵ�����ڵڼ��С��� column_max��
s_ac_max = bb;      % �������ֵ�ǡ��� x_max��

s_ac_test = s_ac(row_max-NN/2:row_max+NN/2-1,column_max-NN/2:column_max+NN/2-1);
% �õ�NN*NN����Ƭ

% ������ж�ά������
S_ac_test_1 = fft(s_ac_test,[],1);     % ��λ��fft
S_ac_test_2 = fft(S_ac_test_1,[],2);   % ������fft

% ���������ж�ά����
% =========================================================================
% ��������forѭ������ÿ�к�ÿ����Сֵ��λ�ô�����7*NN���㣬ʵ�ָ�Ƶ���㡣
%------------------------------------------------------------------
%{
% �� 1 �ַ����� �ȶ�ÿ�в��㣬�ٶ�ÿ�в��㡣
S_ac_test_buling_1 = zeros(NN,8*NN);  % �м����
S_ac_test_buling = zeros(8*NN,8*NN);
% �����ȶ�ÿ�в��㣬�ٶ�ÿ�в���
for pp = 1:NN           % ��ÿ�е���Сֵλ�ò���
    [C,I] = min(S_ac_test_2(pp,:));
    S_ac_test_buling_1(pp,1:I) = S_ac_test_2(pp,1:I);
    S_ac_test_buling_1(pp,8*NN-(NN-I)+1:8*NN) = S_ac_test_2(pp,I+1:NN);
end
% for qq = 1:8*NN         % ��ÿ�е���Сֵλ�ò���
%     [C,I] = min(S_ac_test_buling_1(:,qq));
%     S_ac_test_buling(1:I,qq) = S_ac_test_buling_1(1:I,qq);
%     S_ac_test_buling(8*NN-(NN-I)+1:8*NN,qq) = S_ac_test_buling_1(I+1:NN,qq);
% end
% �����������ÿ�е���Сֵλ�ò��㣬�õ��Ľ����������ģ������������޸�
% �޸ķ����ǣ�
%       ֱ�Ӷ�ÿһ�У����м䲹��
S_ac_test_buling(1:NN/2,:) = S_ac_test_buling_1(1:NN/2,:);
S_ac_test_buling(8*NN-NN/2+1:8*NN,:) = S_ac_test_buling_1(NN/2+1:NN,:);
%}
%------------------------------------------------------------------
%
% �� 2 �ַ����� �ȶ�ÿ�в��㣬�ٶ�ÿ�в��㡣
S_ac_test_buling_1 = zeros(8*NN,NN);  % �м����
S_ac_test_buling = zeros(8*NN,8*NN);
% �����ȶ�ÿ�в��㣬�ٶ�ÿ�в��㡪��ע�⣺����������к�����ȣ�����������ġ�
for pp = 1:NN           % ��ÿ�е���Сֵλ�ò���
    [C,I] = min(S_ac_test_2(:,pp));
    S_ac_test_buling_1(1:I,pp) = S_ac_test_2(1:I,pp);
    S_ac_test_buling_1(8*NN-(NN-I)+1:8*NN,pp) = S_ac_test_2(I+1:NN,pp);
end
for qq = 1:8*NN         % ��ÿ�е���Сֵλ�ò���
    [C,I] = min(S_ac_test_buling_1(qq,:));
    S_ac_test_buling(qq,1:I) = S_ac_test_buling_1(qq,1:I);
    S_ac_test_buling(qq,8*NN-(NN-I)+1:8*NN) = S_ac_test_buling_1(qq,I+1:NN);
end   
%}
%------------------------------------------------------------------
% =========================================================================
S_ac_test_1 = ifft(S_ac_test_buling,[],2);
s_ac_test = ifft(S_ac_test_1,[],1);         % ��ɶ�ά��������

% ��ͼ
figure;
imagesc(abs(s_ac_test));
title('��������������������Ч�����');

%% 
% ����ֱ�Ե�Ŀ�����ģ���ά���ֵ��������Ƭ��������Ƭ��
% ÿһ����Ƭ������ 16�� ��������
% ���ֱ�������һ���Ķ�������ͼ��
% -------------------------------------------------------
% ����ͼ��Ť��
% ��Ŀ�������ת��Ť������ʹ�󲿷��԰������ˮƽ��ʹ�ֱ��
% -------------------------------------------------------

%% 
% ȡ������Ƭ

% ��һ�����ҳ����������Ŀ�����ĵ�λ�úʹ�С
[row_test,column_test] = size(s_ac_test);      % s_ac_test�ľ����С
[aa_test,p_test] = max(abs(s_ac_test));           
[bb_test,q_test] = max(max(abs(s_ac_test)));

row_test_max = p_test(q_test);      % ��ά�������ֵ�����ڵڼ��С��� row_test_max��
column_test_max = q_test;           % ��ά�������ֵ�����ڵڼ��С��� column_test_max��
s_ac_test_max = bb_test;            % �������ֵ�ǡ��� x_max��

% �ڶ������ҳ���Ŀ���������2/3�����ڵ����ֵ���Դ�����������԰��Ť���Ƕ�
% ע�⵽�����ֱ�������2/3������Ѱ�����ֵ���п��ܻ����е���λ�԰��ϵĵ㣻
% ��ˣ�����б�ӽǵĹ�ϵ�����ľ����԰�һ����������б�ģ�
% ��������Ѱ���У���ֱ�ӹ涨Ϊ�ڵ�Ŀ�����������е��Ϸ���
[aa_test_2,p_test_2] = max(abs(s_ac_test(1:row_test_max,1:2*column_test_max/3)));           
[bb_test_2,q_test_2] = max(max(abs(s_ac_test(1:row_test_max,1:2*column_test_max/3))));

row_test_max_2 = p_test_2(q_test_2);  % ��ά�����Ŀ���������2/3���ȵ����ֵ�����ڵڼ���
column_test_max_2 = q_test_2;% ��ά�����Ŀ���������2/3���ȵ����ֵ�����ڵڼ���

% ����������������԰�Ť����ת��
range_theta = atan( abs((row_test_max_2-row_test_max)/(column_test_max_2-column_test_max)) );
% ����ǻ��ȣ�����ת�ɽǶ�
range_theta = range_theta/pi*180;   % ���Ǿ����԰�Ť���ĽǶ�

% ���Ĳ������������Ľ��s_ac_test�Խ�range_theta������ת����������ʱ����ת��
s_ac_range = imrotate(s_ac_test,range_theta,'bilinear');% ����'bilinear'��˫���Բ�ֵ�ķ�ʽ
% s_ac_range����ת���ͼ��
% ��������Ƭ���Դ������㡣

% ��ͼ
figure;
imagesc(abs(s_ac_range));
title('���������԰���ת��ƽ����ˮƽ���ĳ�����');

% ���岽���ҳ���ת������ֵ���ģ���ȡ����Ӧ������Ƭ
[aa_test_range,p_test_range] = max(abs(s_ac_range));           
[bb_test_range,q_test_range] = max(max(abs(s_ac_range)));
row_test_max_range = p_test_range(q_test_range); % ��ת�󣬵�Ŀ�����ģ����ڵڼ���
column_test_max_range = q_test_range;  % ��ת�󣬵�Ŀ�����ģ����ڵڼ���

s_ac_test_row_max = s_ac_range(row_test_max_range,column_test_max_range/3:5*column_test_max_range/3);
% s_ac_test_row_max��ȡ���ĵ�Ŀ����������Ƭ��
% ���У����ﲢû�а�s_ac_range��һ��ȫ��ȡ���������ǽ������������һ����ȥ���ˡ�

% �������16��������
S_AC_test_row_max_1 = fft(s_ac_test_row_max);   % �任��Ƶ��

% -----------------------------------------------------------------------
% ���·ֱ������ֲ��㷽ʽ��
% ��ʽ 1 ���ڸ�Ƶ���м䣩����
 S_AC_test_row_max = [S_AC_test_row_max_1(1,1:length(S_AC_test_row_max_1)/2),...
                        zeros(1, 15*length(S_AC_test_row_max_1)),...
                   S_AC_test_row_max_1(1,length(S_AC_test_row_max_1)/2+1:end)];

% ��ʽ 2 ������Сֵ����15������
% S_AC_test_row_max = zeros(1,16*length(S_AC_test_row_max_1));
% [C1,I1] = min(S_AC_test_row_max_1);
% S_AC_test_row_max(1,1:I1) = S_AC_test_row_max_1(1,1:I1);
% S_AC_test_row_max(1,16*length(S_AC_test_row_max_1)+1-(length(S_AC_test_row_max_1)-I1):end) = S_AC_test_row_max_1(1,I1+1:end);
% ------------------------------------------------------------------------- 
% ������Ϊֹ��Ƶ�������    
s_ac_test_row_max = ifft(S_AC_test_row_max);  % ����IFFT���ص�ʱ�򣬵õ����������������Ƭ��
% ������Ϊֹ�����������

% ��������һ���Ķ�������ͼ
s_ac_test_row_max_abs = abs(s_ac_test_row_max);             % ȡ����
s_ac_test_row_max_abs = 20*log10(s_ac_test_row_max_abs);    % ȡ����
s_ac_test_row_max_abs = s_ac_test_row_max_abs - max(s_ac_test_row_max_abs); % ��һ��

% ��ͼ
figure;
plot(s_ac_test_row_max_abs);
title('��Ŀ�����ģ�����Ƭ');


%%
% ȡ������Ƭ

% ��һ�����ҳ����������Ŀ�����ĵ�λ�úʹ�С
% �����ȡ������Ƭʱ��ͬ��

% �ڶ������ҳ���Ŀ�������Ϸ�����λ��2/3�����ڵ����ֵ���Դ������㷽λ�԰��Ť���Ƕ�
% ע�⵽�����ֱ�����Ϸ�2/3������Ѱ�����ֵ�����ھ����԰��ǿ�������п��ܻ����е������԰��ϵĵ㣻
% ��ˣ�����б�ӽǵĹ�ϵ���Ϸ��ķ�λ�԰�һ����������б�ģ�
% ��������Ѱ���У���ֱ�ӹ涨Ϊ�ڵ�Ŀ�����������е��Ҳࡣ
[aa_test_3,p_test_3] = max(abs(s_ac_test(1:2*row_test_max/3,column_test_max:end-10)));           
[bb_test_3,q_test_3] = max(max(abs(s_ac_test(1:2*row_test_max/3,column_test_max:end-10))));

row_test_max_3 = p_test_3(q_test_3);  % ��ά�����Ŀ�������Ϸ�2/3���ȵ����ֵ�����ڵڼ���
column_test_max_3 = q_test_3;% ��ά�����Ŀ�������Ϸ�2/3���ȵ����ֵ�����ڵڼ��У�����Ҫע�⣡��
% ע�⣺column_test_max_3 ������ֱ���ڵ�Ŀ�����������е��Ҳ�����жϵģ���������ֵ������ڵ�Ŀ�����������е����ֵ��

% �����������㷽λ�԰�Ť����ת��
azimuth_theta = atan( abs((column_test_max_3)/(row_test_max_3-row_test_max)) );
% ����ǻ��ȣ�����ת�ɽǶ�
azimuth_theta = azimuth_theta/pi*180;   % ���Ƿ�λ�԰�Ť���ĽǶ�

% ���Ĳ������������Ľ��s_ac_test�Խ�azimitu_theta������ת����������ʱ����ת��
s_ac_azimuth = imrotate(s_ac_test,azimuth_theta,'bilinear');% ����'bilinear'��˫���Բ�ֵ�ķ�ʽ
% s_ac_azimuth����ת���ͼ��
% ��λ����Ƭ���Դ������㡣

% ��ͼ
figure;
imagesc(abs(s_ac_azimuth));
title('����λ���԰���ת��ƽ���ڴ�ֱ���ĳ�����');

% ���岽���ҳ���ת������ֵ���ģ���ȡ����Ӧ������Ƭ
[aa_test_azimuth,p_test_azimuth] = max(abs(s_ac_azimuth));           
[bb_test_azimuth,q_test_azimuth] = max(max(abs(s_ac_azimuth)));
row_test_max_azimuth = p_test_azimuth(q_test_azimuth); % ��ת�󣬵�Ŀ�����ģ����ڵڼ���
column_test_max_azimuth = q_test_azimuth;  % ��ת�󣬵�Ŀ�����ģ����ڵڼ��С�

s_ac_test_column_max = s_ac_azimuth(row_test_max_azimuth/3:5*row_test_max_azimuth/3,column_test_max_azimuth);
% s_ac_test_column_max��ȡ���ĵ�Ŀ����������Ƭ��
% ���У����ﲢû�а�s_ac_azimuth��һ��ȫ��ȡ���������ǽ������������һ����ȥ���ˡ�
s_ac_test_column_max = s_ac_test_column_max.';  % תΪ������������ͳһ����

% �������16��������
S_AC_test_column_max_1 = fft(s_ac_test_column_max);
% ����Сֵ����15������
S_AC_test_column_max = zeros(1,16*length(S_AC_test_column_max_1));
[C2,I2] = min(S_AC_test_column_max_1);
S_AC_test_column_max(1,1:I2) = S_AC_test_column_max_1(1,1:I2);
S_AC_test_column_max(1,16*length(S_AC_test_column_max_1)+1-(length(S_AC_test_column_max_1)-I2):end) = S_AC_test_column_max_1(1,I2+1:end);
s_ac_test_column_max = ifft(S_AC_test_column_max);    	% ���������������Ƭ��
% ���16��������   

% ��������һ���Ķ�������ͼ
s_ac_test_column_max_abs = abs(s_ac_test_column_max);           % ȡ����   
s_ac_test_column_max_abs = 20*log10(s_ac_test_column_max_abs);  % ȡ����
s_ac_test_column_max_abs = s_ac_test_column_max_abs - max(s_ac_test_column_max_abs);% ��һ��

% ��ͼ
figure;
plot(s_ac_test_column_max_abs);
title('��Ŀ�����ģ�����Ƭ');

%%
% ����Ƭ����Ŀ�����ľ�����ָ��
[PSLR_r,ISLR_r,IRW_r] = zhibiao_2(s_ac_test_row_max,16*8*NN,NN/Fr);
parameter_r = [PSLR_r,ISLR_r,IRW_r];

% ����Ƭ����Ŀ�����ķ�λ��ָ��
[PSLR_a,ISLR_a,IRW_a] = zhibiao_2(s_ac_test_column_max,16*8*NN,NN/Fa);
IRW_a = (IRW_a/c*2)*Vr;
parameter_a = [PSLR_a,ISLR_a,IRW_a];

disp('------------------------------------------------------');
disp('����Ƭ����Ŀ�����ľ�����ָ��');
disp('      PSLR     ISLR       IRW');
disp(parameter_r);
disp('------------------------------------------------------');
disp('����Ƭ����Ŀ�����ķ�λ��ָ��');
disp('      PSLR     ISLR       IRW');
disp(parameter_a);
disp('------------------------------------------------------');

