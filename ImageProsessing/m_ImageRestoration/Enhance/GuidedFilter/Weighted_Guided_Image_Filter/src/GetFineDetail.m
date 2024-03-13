function L = GetFineDetail(I)
% Eq(35) in the paper
% I: [hei, wid, 3, N] = size(I);

[hei, wid, ~, num] = size(I);

I_gray = zeros(hei, wid, num);
var_I = zeros(hei, wid, num);      % local variance in log domain
omega = zeros(hei, wid, num);
for n = 1:num
    I_gray(:,:,n) = rgb2gray(I(:,:,:,n));
    %var_I(:,:,n) = GetLocalVariance(log(I_gray(:,:,n)), 1);     % �ֲ�����ļ������л����NaN ������ log �ڸ��
    var_I(:,:,n) = GetLocalVariance(I_gray(:,:,n), 1); 
    omega(:,:,n) = 77/255*FuncGamma(I(:,:,1,n)) + 150/255*FuncGamma(I(:,:,2,n)) + 29/255*FuncGamma(I(:,:,3,n));
end

% Eqn(32), overall local variance
sigma = sum(omega.*(var_I+0.001), 3) ./ (sum(omega, 3)+10e-13);

% Eqn(34)
Gamma = sum(sum(1./sigma/ hei / wid)) * sigma;

% fine details
Lk = zeros(hei, wid, num);
for n2 = 1:num
%     Lk(:,:,n2) = WGIF_(I_gray(:,:,n2), I_gray(:,:,n2), 16, 1/128, Gamma);
     Lk(:,:,n2) = I_gray(:,:,n2) - WeightedGuidedImageFilter(I_gray(:,:,n2), I_gray(:,:,n2), 16, 1/4, Gamma);
%    Lk(:,:,n2) = WeightedGuidedImageFilter(Gamma, I_gray(:,:,n2), 16, 1/4);
end

% ���������������wgif�㷨��ÿ��ͼ���л�ȡһ����ϸ�ڣ�Ȼ���ٽ����е�ϸ�ںϲ�
% ����õ������ع�����õ�ͼ��ϸ�ڣ������Щͼ��ϸ�����ϵ��м�ͼ���еõ����յ�ͼ��
L = sum(Lk.*omega, 3)./sum(omega, 3);  % Eqn(35)  

end

%% ------ utils ------

function var = GetLocalVariance(I, r)
% get local variance of a gray-scale image.
% I: a gray-scal image
% r: window radius

    [hei, wid] = size(I);
    N = boxfilter(ones(hei, wid), r);
    mean_I = boxfilter(I, r) ./ N;
    mean_II = boxfilter(I.*I, r) ./ N;
    var = mean_II - mean_I .* mean_I;
end

function gamma = FuncGamma(I)
% Eqn(33) in the paper
%                 / I(i,j) + 1 , if i<= 127
%   gamma(i,j) = |  
%                 \ 256 - I(i,j) , otherwise 
%{
I_bw = im2bw(I, 127/255);
gamma_0 = (I+1/255);
gamma_1 = (256/255-I);
%}
[hei, wid] = size(I);
gamma = zeros(hei, wid);
for h = 1:hei
   for w = 1:wid
       if(I(h,w) <= 127/255)
           gamma(h,w) = I(h,w) + 1/255;
       else
           gamma(h,w) = 256/255 - I(h,w);
       end
   end
end
end




