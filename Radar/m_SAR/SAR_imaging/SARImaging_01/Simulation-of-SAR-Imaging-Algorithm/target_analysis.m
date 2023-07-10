function [PSLR_r,ISLR_r,IRW_r, PSLR_a,ISLR_a,IRW_a] = target_analysis(s_ac,Fr,Fa,Vr)
% ���㷽ʽ�ܹؼ�
% ������õķ��������У������ж�������Сֵλ�ã�Ȼ������Сֵλ�ô����в���

% ��������� s_ac  ��������Ҫ����ָ������ĵ�Ŀ���k��s_ac�������ڵ�һ��������ݡ�
% ��������� Fr  ���� �����������
% ��������� Fa  ���� ��λ�������
% ��������� Vr  ���� ƽ̨�ٶ�
% �ú�����������Ŀ��k�ĸ���ָ��
% ��Ŀ�����ĵ�����Ƭ�������򣩣���ֵ�԰��(PSLR)�������԰��(ISLR),����ֱ��ʣ�IRW����
% ��Ŀ�����ĵ�����Ƭ����λ�򣩣���ֵ�԰��(PSLR)�������԰��(ISLR),����ֱ��ʣ�IRW����
% ���ֵ�ֱ�������Ƭ������Ƭ�ĸ���ָ��


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       ȡ��Ŀ������ NN*NN ��Ƭ������������
%   ��ȡ��Ŀ�����ģ���������Ƭ����λ����Ƭ������������
%                   �����������ָ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% ȡ��Ŀ���������Ƭ��NN*NN
% ���ж�ά������������ν��ж�ά������������
% ��Ƶ���㣡��������������ˣ��ж������Ǹ�Ƶ������Ҫ����
c = 3e8;                % ����

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
S_ac_test_buling_1 = zeros(NN,8*NN);  % �м����
S_ac_test_buling = zeros(8*NN,8*NN);
% ====================================================================
% ��������forѭ������ÿ�к�ÿ����Сֵ��λ�ô�����7*NN���㣬ʵ�ָ�Ƶ���㡣
for pp = 1:NN           % ��ÿ�е���Сֵλ�ò���
    [C,I] = min(S_ac_test_2(pp,:));
    S_ac_test_buling_1(pp,1:I) = S_ac_test_2(pp,1:I);
    S_ac_test_buling_1(pp,8*NN-(NN-I)+1:8*NN) = S_ac_test_2(pp,I+1:NN);
end
for qq = 1:8*NN         % ��ÿ�е���Сֵλ�ò���
    [C,I] = min(S_ac_test_buling_1(:,qq));
    S_ac_test_buling(1:I,qq) = S_ac_test_buling_1(1:I,qq);
    S_ac_test_buling(8*NN-(NN-I)+1:8*NN,qq) = S_ac_test_buling_1(I+1:NN,qq);
end     
% ====================================================================
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

% ����û�п��ǵ�Ŀ�����������ת
% û�н����������ֵ���ڵ��к�����ת��x���y�᷽��

[row_test,column_test] = size(s_ac_test);      % s_ac_test�ľ����С
[aa_test,p_test] = max(abs(s_ac_test));           
[bb_test,q_test] = max(max(abs(s_ac_test)));

row_test_max = p_test(q_test);      % ��ά�������ֵ�����ڵڼ��С��� row_max��
column_test_max = q_test;           % ��ά�������ֵ�����ڵڼ��С��� column_max��
s_ac_test_max = bb_test;            % �������ֵ�ǡ��� x_max��

% ������Ƭ��������������һ����������ͼ
s_ac_test_row_max = (s_ac_test(row_test_max,:)); 	% ȡ�����ֵ���ڵ��У�������Ƭ��
S_AC_test_row_max_1 = fft(s_ac_test_row_max);

% ����Сֵ����15������
S_AC_test_row_max = zeros(1,16*length(S_AC_test_row_max_1));
[C1,I1] = min(S_AC_test_row_max_1);
S_AC_test_row_max(1,1:I1) = S_AC_test_row_max_1(1,1:I1);
S_AC_test_row_max(1,16*length(S_AC_test_row_max_1)+1-(length(S_AC_test_row_max_1)-I1):end) = S_AC_test_row_max_1(1,I1+1:end);
% ���16��������     

s_ac_test_row_max = ifft(S_AC_test_row_max);        % ���������������Ƭ��
s_ac_test_row_max_abs = abs(s_ac_test_row_max);             % ȡ����
s_ac_test_row_max_abs = 20*log10(s_ac_test_row_max_abs);    % ȡ����
s_ac_test_row_max_abs = s_ac_test_row_max_abs - max(s_ac_test_row_max_abs); % ��һ��


% ������Ƭ��������������һ����������ͼ
s_ac_test_column_max = (s_ac_test(:,column_test_max)); 	% ȡ�����ֵ���ڵ��У�������Ƭ��
s_ac_test_column_max = s_ac_test_column_max.';          % ת�ã���ʾ��������������ͳһ����
S_AC_test_column_max_1 = fft(s_ac_test_column_max);
    % ������Ƭ��������ʱ����֮ǰ�ĳ�����Ƭ��������ͬ��Ҫ���������ĸ�Ƶλ�á�
    % ���Ҫ�������������Ӧ������ģ�������ִ��������ֱ������Ӧ�Ĳ��㷽��
% ====================================================================
% ��Ӧ�ڴ��������ģ���ķ�����~~~�ƶ�Ƶ����
% ��Ƶ����fa_1��fa_2��ӵ���һ��

% ����Сֵ����15������
S_AC_test_column_max = zeros(1,16*length(S_AC_test_column_max_1));
[C2,I2] = min(S_AC_test_column_max_1);
S_AC_test_column_max(1,1:I2) = S_AC_test_column_max_1(1,1:I2);
S_AC_test_column_max(1,16*length(S_AC_test_column_max_1)+1-(length(S_AC_test_column_max_1)-I2):end) = S_AC_test_column_max_1(1,I2+1:end);
% ���16��������   
% ====================================================================

s_ac_test_column_max = ifft(S_AC_test_column_max);    	% ���������������Ƭ��
s_ac_test_column_max_abs = abs(s_ac_test_column_max);           % ȡ����   
s_ac_test_column_max_abs = 20*log10(s_ac_test_column_max_abs);  % ȡ����
s_ac_test_column_max_abs = s_ac_test_column_max_abs - max(s_ac_test_column_max_abs);% ��һ��

% ��ͼ
figure;
plot(s_ac_test_row_max_abs);
title('��Ŀ�����ģ�����Ƭ');
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

