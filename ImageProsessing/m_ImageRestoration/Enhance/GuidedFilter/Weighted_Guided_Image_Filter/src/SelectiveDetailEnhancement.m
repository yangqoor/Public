function X_enhanced = SelectiveDetailEnhancement(X, r, lambda, theta)
% selective detail enhancment
% X:    img in, double
% r:    window radius (for wgif)
% lambda:   regularization parameter (for wgif)
% theta:    amplify factor

addpath('detail_enhancement');

[hei, wid, channels] = size(X);
r2 = floor(min(hei, wid) / 3);

Z = zeros(size(X));
gamma = zeros(size(X));
eta = zeros(size(X));
for a = 1:channels
    gamma(:,:,a) = EdgeAwareWeighting(X(:,:,a));
    gamma1 = gamma(:,:,a) / max(max(gamma(:,:,a)));     % ��һ��
    gamma_bw = AdaptiveThreshold(gamma1, r2, 4);        % �ֲ�����Ӧ��ֵ��
    eta(:,:,a) = gamma1 .* ~gamma_bw + gamma_bw;        % ����
    Z(:,:,a) = WeightedGuidedImageFilter(X(:,:,a), X(:,:,a), r, lambda, gamma(:,:,a));     % ͼ��ƽ��
end

X_enhanced = (X - Z) .* eta * theta + X;

end

%% ------------
%{
%% WGIF selective detail enhancement  gray

% I = imread('.\img\tulips.bmp');
I = imread('.\img\sky.jpg');
Ig = rgb2gray(I);
X = double(Ig)/255;

r = 16;
lambda = 1/128;

gamma0 = EdgeAwareWeighting(X);

Z = WGIF_(X,X,r,lambda, gamma0);

X_detail = X - Z;


% ͨ����ֵ������
[hei, wid] = size(X);
r2 = floor(min(hei, wid) / 3);
gamma1 = gamma0 / max(max(gamma0));
gamma_bw = AdaptiveThreshold(gamma1, r2, 4);
gamma_wb = ~gamma_bw;
gamma2 = gamma1 .* gamma_wb;
gamma3 = gamma2 + gamma_bw;

gamma = gamma3;


% v2, ��һ��
% ֻ����ǿ�ٲ��ֱ�Ե
% gamma = gamma0 / max(max(gamma0));

%{
1. ֻ��gamma���й�һ���� ֻ����ǿ�ٲ��ֱ�Ե
2. ͨ����ֵ1��gamma��ֵ��Ȼ�����壺����Ҳ�ᱻ��ǿ����Ч����ȫ����ǿû����
2.1. ֱ���ö�ֵ�����gamma, 
2.1.1. ����ֵ1��gamma���ж�ֵ����Ч�������룬��ȫ��û����
2.1.2. �þֲ�����Ӧ��ֵ����gamma��ֵ�����е�ϣ����������Щ��������Ҫ��һ������
3. ͨ��ȫ�ֶ�ֵ����gamma�������壺û�Թ�
4. ͨ���ֲ�����Ӧ��ֵ����gamma�������壺ĿǰЧ����ѣ�ֻ��ǿ���ֱ�Ե�� �����в�����ǲ�������Ҳ�ᱻ��ǿ,
����ͨ�������ֲ�����Ӧ��ֵ���Ĵ��ڰ뾶��������
%}


figure();
subplot(121);   imshow(gamma);     title('gamma');
subplot(122);   imhist(uint8(gamma*255));   title('histgram of gamma');

X_enhanced = X_detail * 4;
X_enhanced2 = X_detail .* gamma * 4;

figure('Name', 'WGIF');
imshow([X,Z]);
figure('Name', 'WGIF selective detail enhancement');
imshow([X_enhanced,X_enhanced2]);
%}