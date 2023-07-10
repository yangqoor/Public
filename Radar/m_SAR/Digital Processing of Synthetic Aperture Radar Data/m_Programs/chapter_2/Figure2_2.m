clc
close all
clear all

% ���������ξ���
M = 256;    % ����߶�
N2 = 256;   % ������
S0 = zeros(M,N2);
S0(M/8+1:M*7/8,N2/8+1:N2*7/8) = 1;

S0_ff = fftshift(fft2(fftshift(S0)));
S0_ff = abs(S0_ff);
S0_ff = S0_ff./max(max(S0_ff));
S0_ff = 20*log10(S0_ff+1e-4);

% figure
% imagesc(S0);colormap gray % Ԥ�������ɫͼ
% axis off image                     % ����ʾͼ�е�������
% % colormap parula
% % colormap jet
% % colormap hot
% % colormap cool
% % colormap spring
% % colormap summer
% % colormap autumn
% % colormap winter
% % ...
% 
% figure
% imagesc(S0_ff);colormap gray
% axis off image

% Ť���ź�
S1 = zeros(M,N2);
theta = -pi/12;
for ii = 1:M
    for jj = 1:N2
        x = jj-N2/2;
        y = ii-M/2;
        At = [1 0; sin(-theta) cos(-theta)]*[x y].';
        xx = round(At(1,1)+N2/2);
        yy = round(At(2,1)+M/2);
        % xx = round(x+N/2);
        % yy = round(x*sin(-theta)+y*cos(-theta)+M/2);
        if(xx>=1 && xx<= N2 && yy>=1 && yy<=N2)
            S1(ii,jj) = S0(yy,xx);
        end
    end
end

S1_ff = fftshift(fft2(fftshift(S1)));
S1_ff = abs(S1_ff);
S1_ff = S1_ff./max(max(S1_ff));
S1_ff = 20*log10(S1_ff+1e-4);

% figure
% imagesc(S1);colormap gray
% axis off image
% 
% figure
% imagesc(S1_ff);colormap gray
% axis off image

% ��ת�ź�
S2 = zeros(M,N2);
for ii = 1:M
    for jj = 1:N2
        x = jj-N2/2;
        y = ii-M/2;
        At = [cos(-theta) -sin(-theta); sin(-theta) cos(-theta)]*[x y].';
        xx = round(At(1,1)+N2/2);
        yy = round(At(2,1)+M/2);
        % xx = round(x*cos(-theta)-y*sin(-theta)+N/2);
        % yy = round(x*sin(-theta)+y*cos(-theta)+M/2);
        if(xx>=1 && xx<= N2 && yy>=1 && yy<=N2)
            S2(ii,jj) = S0(yy,xx);
        end
    end
end

S2_ff = fftshift(fft2(fftshift(S2)));
S2_ff = abs(S2_ff);
S2_ff = S2_ff./max(max(S2_ff));
S2_ff = 20*log10(S2_ff+1e-4);

% figure
% imagesc(S2);colormap gray
% axis off image
% 
% figure
% imagesc(S2_ff);colormap gray
% axis off image

%% ��ͼ
figure;colormap gray
subplot(2,3,1),imagesc(S0);axis off image
title('(a)ʱ��ԭʼ�ź�')
subplot(2,3,4),imagesc(S0_ff);axis off image
title('(b)ԭʼ�ź�Ƶ��')
subplot(2,3,2),imagesc(S1);axis off image
title('(c)ʱ��Ť���ź�')
subplot(2,3,5),imagesc(S1_ff);axis off image
title('(d)Ť���ź�Ƶ��')
subplot(2,3,3),imagesc(S2);axis off image
title('(e)ʱ����ת�ź�')
subplot(2,3,6),imagesc(S2_ff);axis off image
title('(f)��ת�ź�Ƶ��')
suptitle('ͼ2.2 ��������Ť������ת�ĸ���Ҷ�任��')