function [data_Peak,SNR_tmp] = UpSampling_and_GetM(s_ac_test,Np)
% ������ĳ��������ĳͨ����������Ƭ���ж�ά��������Ȼ��ȡ����ֵ��ķ�����Ϣ
%
% ���������
%   1��s_ac_test ��ĳ��������ĳͨ���µ�������Ƭ
%   2��Np �Ǹ���Ƭ�Ĵ�С��Np��Np
%
% ���������
%   1��data_Peak �Ǹö������ķ�ֵ���ڸ�ͨ���µķ�����Ϣ
%   2��SNR_tmp   �Ǹö������ڸ�ͨ���µ� SNR ���ƽ��
%
% �ó����ֹ����2016.10.31. 15:49

%%
% ��1�����ж�ά������
Up_Sampling_Ratio = 16;                 % ��ά������ʱ��ÿһά������������

S_ac_test_1 = fft(s_ac_test,[],1);      % ��λ��fft
S_ac_test_2 = fft(S_ac_test_1,[],2);    % ������fft
clear s_ac_test;clear S_ac_test_1;

% ���������ж�ά����
S_ac_test_buling_1 = zeros(Np,Up_Sampling_Ratio*Np);% �м����
S_ac_test_buling = zeros(Up_Sampling_Ratio*Np,Up_Sampling_Ratio*Np);
% ========================================================================
S_ac_test_buling_1(:,1:Np/2) = S_ac_test_2(:,1:Np/2);
S_ac_test_buling_1(:,Up_Sampling_Ratio*Np-(Np-Np/2)+1:Up_Sampling_Ratio*Np) =...
    S_ac_test_2(:,Np/2+1:Np);
clear S_ac_test_2;
S_ac_test_buling(1:Np/2,:) = S_ac_test_buling_1(1:Np/2,:);
S_ac_test_buling(Up_Sampling_Ratio*Np-(Np-Np/2)+1:Up_Sampling_Ratio*Np,:) =...
    S_ac_test_buling_1(Np/2+1:Np,:);
clear S_ac_test_buling_1;
% figure;imagesc(abs(fftshift(S_ac_test_buling)));title('�����Ķ�άƵ��');
% ========================================================================

S_ac_test_1 = ifft(S_ac_test_buling,[],2);
s_ac_test = ifft(S_ac_test_1,[],1);         % ��ɶ�ά������
clear S_ac_test_buling;clear S_ac_test_1;

% ��ͼ
% figure;
% imagesc(abs(s_ac_test));
% title('��������Ŀ����Ƭ����ά������');

%%
% ��2����ȡ��ά��������ķ�ֵ�������Ϣ
[~,p] = max(abs(s_ac_test));
[~,q] = max(max(abs(s_ac_test)));

% ��ά�������ֵ�����ڵڼ��С��� row_max;
row_max = p(q);
% ��ά�������ֵ�����ڵڼ��С��� column_max;
column_max = q;
% �����ֵ��ķ�����Ϣ����data_Peak;
data_Peak = s_ac_test(row_max,column_max);


%%
%
% ����ÿ��ͨ���¶���㴦�������

tmp(1) = var(abs(reshape(s_ac_test(1:1+128-1,1:1+128-1),1,[])));
tmp(2) = var(abs(reshape(s_ac_test(1:1+128-1,end-128+1:end),1,[])));
tmp(3) = var(abs(reshape(s_ac_test(end-128+1:end,1:1+128-1),1,[])));
tmp(4) = var(abs(reshape(s_ac_test(end-128+1:end,end-128+1:end),1,[])));
% max(tmp)        % ѡ�������ڣ���������޵�λ��
SNR_tmp = 10*log10(abs(data_Peak)^2/max(tmp));	% ��������ȴ�С����λ dB

%}

end

