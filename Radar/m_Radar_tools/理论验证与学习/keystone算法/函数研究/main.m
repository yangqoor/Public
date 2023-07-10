clear;clc;
load data.mat
%--------------------------------------------------------------------------
%   Y_Rd �ز�����  F(ft)+st
%   ms �����������
%   F0��Ƶ����
%   Fl��������
%   Nsinc sinc�������� ���ߵ���
%   B = 200e6;                                                              %�źŲ��δ���
%   Fsft = 2.3*B;                                                           %��������Ϊ2.3���źŴ���
%   Fl = (-K_L/2:K_L/2-1)/K_L*Fsft;
M = 101;                                                                    %��ʱ���������
K_L = 2^(nextpow2(128)+1);                                                  %��ʱ��FFT����
%--------------------------------------------------------------------------

% k = 1;

% [A] = sinc_in(Y_Rd(k,:),ms,(F0/(F0+Fl(k)))*ms);
%--------------------------------------------------------------------------
%   �����һ��������Ƶ��
%--------------------------------------------------------------------------
c = 3e8;
L = 128;                                                                    %��ʱ���������
K_M = 2^(nextpow2(512)+1);                                                  %��ʱ��FFT����
F0 = 1e9;                                                                   %��Ƶ�ź�
lambda = c/F0;
v = 400;                                                                    %Ŀ���ٶ�
Fd = 2*v/lambda;                                                            %������Ƶ��
PRF = 10e3;                                                                 %�����ظ�Ƶ��
Tst = 1/PRF;                                                                %��ʱ��������
Fd = Fd*Tst;                                                                %��һ��������Ƶ��
fdn = mod(Fd + 0.5,1) - 0.5;                                                %ȡ�� ���ŵ�[-0.5 0.5]��Χ
amb_num = round(Fd - fdn);                                                  %������ģ������


for k = 1:K_L
    [y_temp,mm_i] = sinc_interp(Y_Rd(k,:),ms,(F0/(F0+Fl(k)))*ms,Nsinc,1);
    plot(ms,zeros(length(ms),1),'o','LineWidth',1.5);hold on
    plot((F0/(F0+Fl(k)))*ms,ones(length(ms),1),'o','LineWidth',1.5);
    plot(mm_i,1*ones(length(mm_i),1),'o','LineWidth',1.5);
    hold off;
    legend('ԭʼ��Χ','��ֵ��Χ','���շ�Χ')
    axis([-70 70 -1 3])
%     [y_temp] = sinc_in(Y_Rd(k,:),ms,(F0/(F0+Fl(k)))*ms);
    % y_temp = interp1(ms,Y_Rd(k,:),(F0/(F0+Fl(k)))*ms,'spline');
    % Mi will always be odd the way I'm setting up the problem. Also, Mi <= M.
    Mi = length(y_temp);
    dM = M - Mi; % dM will be even so long as M and Mi are odd
    Y_Rd_key(k,1+dM/2:1+dM/2+Mi-1) = y_temp; % center the interpolated data in slow
%     imagesc(db(Y_Rd_key))
%     drawnow
end

for mp = 1:M
    for k = 1:K_L
        mmp = ms(mp); % counts from -(M-1/2) to +(M-1)/2
        Y_Rd_key(k,mp) = Y_Rd_key(k,mp)*exp(1i*2*pi*amb_num(1)*mmp*(F0/(F0+Fl(k))));
% Y_Rd_key(k,mp) = Y_Rd_key(k,mp)*exp(-1i*2*pi*amb_num(1)*mmp*(Fl(k)/F0));
    end
end

y_temp_key = ifft( ifftshift(Y_Rd_key,1),K_L,1 );
y_rd_key = y_temp_key(1:L,:);
Y_rD_key = fftshift( fft(y_rd_key,K_M,2),2 );
Y_rD_key_dB = db(abs(Y_rD_key),'voltage');
Y_rD_key_dB = Y_rD_key_dB - max(Y_rD_key_dB(:)); % normalize to 0 dB max
Y_rD_key_dB(:) = max(-40,Y_rD_key_dB(:)); % limit to 40 dB range
figure
imagesc(ms,0:L-1,abs(y_rd_key))
grid
colormap(flipud(gray))
xlabel('slow-time')
ylabel('fast time')
title('Keystoned Fast-time/Slow-time Data Pattern')