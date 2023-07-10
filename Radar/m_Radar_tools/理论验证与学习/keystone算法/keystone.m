%--------------------------------------------------------------------------
%   keystone�㷨ע�ͣ����� 20181122
%   �ο�����:The Keystone Transformation for Correcting Range Migration
%   in Range-Doppler Processing
%--------------------------------------------------------------------------
% keystone
%
% Demo of keystone formatting for correcting range-Doppler
% measurements for range migration.
%
% This code closely follows the equations in the tech memo "The Keystone
% Transformation for Correcting Range Migration in Range-Doppler
% Processing" by Mark A. Richards, Mar. 2014, available at www.radarsp.com.
%
% Mark Richards
%
% March 2014
%--------------------------------------------------------------------------
clear;clc
close all

%--------------------------------------------------------------------------
%   ��������
%--------------------------------------------------------------------------
c = 3e8;                                                                    %����
L = 128;                                                                    %��ʱ���������
M = 101;                                                                    %��ʱ���������

K_L = 2^(nextpow2(128)+1);                                                  %��ʱ��FFT����
K_M = 2^(nextpow2(512)+1);                                                  %��ʱ��FFT����

Lref = 100;                                                                 %����Ŀ����뵥Ԫ ����Ŀ���ھ��뵥Ԫ����round(L/2)
F0 = 1e9;                                                                   %��Ƶ�ź�
B = 200e6;                                                                  %�źŲ��δ���
v = 1000;                                                                    %Ŀ���ٶ�

Fsft = 2.3*B;                                                               %��������Ϊ2.3���źŴ���,��ʱ��Ƶ�����
PRF = 10e3;                                                                 %�����ظ�Ƶ��

Nsinc = 11;                                                                 %sinc��������/����

%--------------------------------------------------------------------------
%   ��������
%--------------------------------------------------------------------------
lambda = c/F0;

m_end = (M-1)/2;
ms = (-m_end:m_end);                                                        %������ʱ������ϵ

Fd = 2*v/lambda;                                                            %������Ƶ��
Tft = 1/Fsft;                                                               %��ʱ��������
dr = c*Tft/2;                                                               %�����ų���
Tst = 1/PRF;                                                                %��ʱ��������

Dfd = 1/M;                                                                  %��һ�����������շֱ���
Drb = (1/B)/Tft;                                                            %���뵥Ԫ��������ʱ��ֱ���

%--------------------------------------------------------------------------
%   ��֪������ɶ������������
%--------------------------------------------------------------------------
if (PRF < abs(Fd)/2)
    fprintf('\n����: PRF < Fd/2. PRF = %g, Fd = %g.\n',PRF,Fd)
end
%--------------------------------------------------------------------------
%   ����һ��CPI�еĿ���뵥Ԫ����
%--------------------------------------------------------------------------
RM = v*Tst/dr;                                                              %һ��PRT��Ŀ������߶���Ԫ
RMtot = M*RM;                                                               %һ��CPI��Ŀ������߶���Ԫ

fprintf('\n�ܹ������߶� = %g �� = %g ���뵥Ԫ.\n',RMtot*dr,RMtot);

%--------------------------------------------------------------------------
%   �߶���Χ�о���Ŀ�����̫���ˣ��ܳ�����ά����
%--------------------------------------------------------------------------
if ( (floor(Lref-RMtot/2) < 0) || (ceil(Lref+RMtot/2) > L-1) )
    fprintf(['\n����: Ŀ���߳����뷶Χ', ...
    'RMtot = %g ���뵥Ԫ, Lref = %g, L = %g ���뵥Ԫ.\n'],RMtot,Lref,L)
end

%--------------------------------------------------------------------------
%   �����һ��������Ƶ��
%--------------------------------------------------------------------------
Fd = Fd*Tst;                                                                %��һ��������Ƶ��
fdn = mod(Fd + 0.5,1) - 0.5;                                                %ȡ�� ���ŵ�[-0.5 0.5]��Χ
disp('������ģ����')
amb_num = round(Fd - fdn)                                                   %������ģ����
amb_num = 0
%--------------------------------------------------------------------------
%   ���� �ٶȷֱ��ʳ߶ȷ�Χ
%--------------------------------------------------------------------------
L1 = Lref - Drb;
L2 = Lref + Drb;
fd1 = fdn - Dfd;
fd2 = fdn + Dfd;

%--------------------------------------------------------------------------
%   ģ��ز��źţ�����ϳ����ݣ����ȼ���������λ��Ȼ����ز��洢����ѭ������
%   ��ѹ�����ݼٶ�Ϊsinc������̬,�����1/B�룬��λ�ƶ�-(4*pi*F0/c)*R��
%   R = Rref - v*Tst*m ���� m ��ʾ�����������������˥����
%--------------------------------------------------------------------------
del_phi = -4*pi*(F0/c)*v*Tst;                                               %�ز���λ�仯��
y = zeros(L,M);                                                             %�ز�����

%--------------------------------------------------------------------------
%   �ز�����
%--------------------------------------------------------------------------
for m = 1:M                                                     
    mm = ms(m);                                                             %������ʱ������
    y(:,m) = exp(-1i*del_phi*mm)*sinc( B*Tft*((0:L-1)-Lref+v*Tst*mm/dr) );  %��λ��+������
end

%--------------------------------------------------------------------------
%   MTD
%--------------------------------------------------------------------------
Y_rD = fft(y,K_M,2);Y_rD = fftshift(Y_rD,2);
Y_rD_dB = db(Y_rD);
Y_rD_dB = Y_rD_dB - max(Y_rD_dB(:));
fD = (-K_M/2:K_M/2-1)/K_M;

%--------------------------------------------------------------------------
%   ���ӻ�
%--------------------------------------------------------------------------
f1 = figure(1);f1.Position = [273 501 1215 448];
subplot(121)
imagesc(ms,0:L-1,abs(y))
grid on
xlabel('������');ylabel('���뵥Ԫ');title('ԭʼ ��ʱ��/��ʱ������')

subplot(122)
fD = (-K_M/2:K_M/2-1)/K_M;
imagesc(fD,0:L-1,Y_rD_dB)

% %--------------------------------------------------------------------------
% %   ���ƾ��� �ٶȷֱ��ʵ�Ԫ
% %--------------------------------------------------------------------------
% line([fd1 fd1 fd2 fd2 fd1],[L1 L2 L2 L1 L1],'Color','k','LineWidth',1.5);
% disp(['figure2:һ��CPI�����߶� = ',num2str(RMtot),...
% ' ;��һ�������� = ',num2str(fdn),' cyc/samp'])
% title('MTD');xlabel('��һ��������');ylabel('���뵥Ԫ');colorbar

%%
%--------------------------------------------------------------------------
%   ���������ٶ���֪,��ô������Ĳ�������ͨ��Ƶ�����λ��ʵ�֣���˽��ز��ź�
%   �任��Ƶ����Ȼ�󲹳���λ�Ȼ�󷴱任�õ���ԭʼ��������������
%--------------------------------------------------------------------------
Y_Rd = fftshift(fft(y,K_L,1),1);
Fl = (-K_L/2:K_L/2-1)/K_L*Fsft;                                             %��ʱ��Ƶ��ֲ���Χ

%--------------------------------------------------------------------------
%   �������Կ��ӻ�
%--------------------------------------------------------------------------
% f2 = figure(2);f2.Position = [272 330 1214 420];
% subplot(121)
% imagesc(ms,F0+Fl,abs(Y_Rd))
% xlabel('��ʱ��')
% ylabel('��ʱ��Ƶ��')
% title('��ʱ��Ƶ������ͼ')
% colorbar
% subplot(122)
% imagesc(ms,F0+Fl,angle(Y_Rd))
% xlabel('��ʱ��')
% ylabel('��ʱ��Ƶ��')
% title('��ʱ��Ƶ�����λͼ(δ�����)')
% colorbar

%--------------------------------------------------------------------------
%   ���ڶ���֪���ٶȶ�ÿ��������в�ֵ����
%--------------------------------------------------------------------------
yc = zeros(size(y));                                                        %�µĿ���ʱ��洢��
wl = 2*pi*(-K_L/2:K_L/2-1)'/K_L;                                            %�������ת���� ����������
wl = fftshift(wl);                                                          %����shiftһ����Ϊ�˶�Ӧmatlab fft����
%--------------------------------------------------------------------------
%   Ƶ����λ����-ʱ������ѭ�� У���ź� 
%--------------------------------------------------------------------------
for m = 1:M
    mm = ms(m);                                                             %�������
    Lm = v*Tst*mm/dr;                                                       %���뵥Ԫ�߶����,Ҳ����ƽ�Ʋ�������
    Y_shift = fft(y(:,m),K_L).*exp(-1i*wl*Lm);                              %ÿ�λز����ݲ�����λ������
    y_shift_temp = ifft(Y_shift);                                           %�õ��ز�����
    y_shift(:,m) = y_shift_temp(1:L);                                       %ȡ�����㳤������
end

%--------------------------------------------------------------------------
%   ���ӻ�
%--------------------------------------------------------------------------
% f3 = figure(3);f3.Position = [454 378 1203 413];
% subplot(121)
% imagesc(ms,0:L-1,abs(y_shift))
% grid
% xlabel('������')
% ylabel('���뵥Ԫ')
% title('���������߶�����״�ز�����')
% Y_shift = fft(y_shift,K_M,2);
% Y_shift = fftshift(Y_shift,2);
% Y_shift_dB = db(abs(Y_shift),'voltage');
% Y_shift_dB = Y_shift_dB - max(Y_shift_dB(:)); 
% Y_shift_dB(:) = max(-40,Y_shift_dB(:));
% colorbar
% subplot(122)
% imagesc(fD,0:L-1,Y_shift_dB)
% line([fd1 fd1 fd2 fd2 fd1],[L1 L2 L2 L1 L1],'Color','w','LineWidth',2)      %�ֱ洰
% box
% xlabel('��һ��������')
% ylabel('���뵥Ԫ')
% title('���벹����ľ��������ƽ��')
% colorbar

%--------------------------------------------------------------------------
%   ������������Կ��ӻ�
%--------------------------------------------------------------------------
Y_Rd_shift = fftshift(fft(y_shift,K_L,1),1);

%--------------------------------------------------------------------------
%   ���ӻ�
%--------------------------------------------------------------------------
% f4 = figure(4);f4.Position = [456 508 1199 420];
% subplot(121)
% imagesc(ms,F0+Fl,abs(Y_Rd_shift))
% xlabel('������')
% ylabel('��ʱ��Ƶ��')
% title('��ʱ��Ƶ������ͼ')
% colorbar
% subplot(1,2,2)
% imagesc(ms,F0+Fl,angle(Y_Rd_shift))
% xlabel('��ʱ��')
% ylabel('��ʱ��Ƶ��')
% title('��ʱ��Ƶ�����λͼ(�����)')
% colorbar
%%
%--------------------------------------------------------------------------
%   keystone�㷨
%--------------------------------------------------------------------------
%   ���¿�ʼ�������㷨���̣���Y_Rd���ݿ�ʼ(�����߶���Ƶ������,shift��)����ʱ��
%   ��Ƶ��ͼ+shift,��ʱ�䲻��������ÿһ����ʱ��Ƶ�����ݣ�����sinc��������ֵ
%--------------------------------------------------------------------------
% Now start over and correct by keystoning. Begin with Y_Rd, i.e. data
% DFT'ed in fast time but not in slow time. For each fast-time frequency
% bin, compute a new, interpolated slow-time sequence. Use the existing
% sinc_interp function for bandlimited, Hamming-weighted interpolation to
% do the work.
%--------------------------------------------------------------------------
Y_Rd_key = zeros(size(Y_Rd));
for k = 1:K_L
    %----------------------------------------------------------------------
%     [y_temp,mm_i] = sinc_interp(Y_Rd(k,:),ms,(F0/(F0+Fl(k)))*ms,Nsinc,1);
    %----------------------------------------------------------------------
%   ����д��ֵ�������޸ĺ���y_temp = Y_Rd(k,:)*sinc_interp_mat�������ʵ��
%   keystone�㷨
%--------------------------------------------------------------------------
    [y_temp,sinc_interp_mat] = sinc_in(Y_Rd(k,:),ms,(F0/(F0+Fl(k)))*ms);
    % y_temp = interp1(ms,Y_Rd(k,:),(F0/(F0+Fl(k)))*ms,'spline');
    % Mi will always be odd the way I'm setting up the problem. Also, Mi <= M.
    Mi = length(y_temp);
    dM = M - Mi; % dM will be even so long as M and Mi are odd
%     Y_Rd_key(k,1+dM/2:1+dM/2+Mi-1) = y_temp; % center the interpolated data in slow
    Y_Rd_key(k,:) = y_temp; % center the interpolated data in slow
%     imagesc(db(Y_Rd_key));drawnow;
end

%--------------------------------------------------------------------------
%   keystone�㷨��ȱ�ݣ�������ģ����Ӱ��
%--------------------------------------------------------------------------
%   ���ڿ��Ƕ�����ģ����ɵ�Ӱ�죬���´��뿼�ǵ�һĿ��Ķ�����ģ�������������
%   �ڶ�Ŀ������Ĳ�ͬ��Ŀ����в�ͬ��ģ�������ͻ�У��ʧ�ܡ���˼���ģ������
%   ������в�������������շ�Χ
% Now correct the modified spectrum for the ambiguity number of the
% Doppler. This code uses the ambiguity number of the first target. So if
% the other targets have a different ambiguity number it won't be correct
% for them. The first version of the correction corresponds to the Li et al
% paper and is consistent with my memo. The second (commented out)
% corresponds to the Perry et al paper and can be obtained from the first
% using a binomial expansion approximation to (F0/(F0+Fl)). Either one
% works if done either after the keystone correction, as is done here, or
% before.
%--------------------------------------------------------------------------
for mp = 1:M
    for k = 1:K_L
        mmp = ms(mp); % counts from -(M-1/2) to +(M-1)/2
        Y_Rd_key(k,mp) = Y_Rd_key(k,mp)*exp(1i*2*pi*amb_num(1)*mmp*(F0/(F0+Fl(k))));
% Y_Rd_key(k,mp) = Y_Rd_key(k,mp)*exp(-1i*2*pi*amb_num(1)*mmp*(Fl(k)/F0));
    end
end
% Now IDFT in fast-time and DFT in slow time to get range-Doppler matrix
y_temp_key = ifft( ifftshift(Y_Rd_key,1),K_L,1 );
y_rd_key = y_temp_key(1:L,:);
Y_rD_key = fftshift( fft(y_rd_key,K_M,2),2 );
Y_rD_key_dB = db(abs(Y_rD_key),'voltage');
Y_rD_key_dB = Y_rD_key_dB - max(Y_rD_key_dB(:)); % normalize to 0 dB max
Y_rD_key_dB(:) = max(-40,Y_rD_key_dB(:)); % limit to 40 dB range
figure
imagesc(ms,0:L-1,abs(y_rd_key))
grid

xlabel('��ʱ��')
ylabel('��ʱ��')
title('Keystone�任��Ŀ���ʱ������')
% figure
% mesh(fD,0:L-1,Y_rD_key_dB)
% xlabel('normalized Doppler')
% ylabel('fast time')
% title('Keystoned Range-Doppler Matrix')

figure
imagesc(fD,0:L-1,Y_rD_key_dB)
% hline(Lref,':w'); vline(fdn,':w') % mark the correct spectrum center
xlabel('��һ��������')
ylabel('���뵥Ԫ')
title('Keystone�任���MTDƽ��')
shg
colorbar
figure
subplot(1,2,1)
imagesc(ms,F0+Fl,abs(Y_Rd_key))
xlabel('��ʱ��')
ylabel('��ʱ��Ƶ��')
title('��ֵ�����')
colorbar
subplot(1,2,2)
imagesc(ms,F0+Fl,angle(Y_Rd_key))
xlabel('��ʱ��')
ylabel('��ʱ��Ƶ��')
title('��ֵ����λ')
colorbar