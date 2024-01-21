function [k,ex,ssde]=Deblurring(y,k_sz1,k_sz2,sig_noise,iterN,precision,x)
%Deblurring Natural Image Using Super-Gaussian Fields
%Writen by: Yuhang Liu, Email:liuyuhang@whu.edu.cn (c)

prob.p_precision = precision;
prob.sig_noise = sqrt(sig_noise);
prob.iterN = iterN;
ret=0.5^0.5;

%make sure kernel size is odd
k_sz1=floor(k_sz1/2)*2+1; 
k_sz2=floor(k_sz2/2)*2+1; 

prob.k_sz1=k_sz1;
prob.k_sz2=k_sz2;
tf=zeros(k_sz1,k_sz2);
tf(ceil(k_sz1/2),ceil(k_sz2/2))=1;
tf(ceil(k_sz1/2),ceil(k_sz2/2)+1)=1;
tf=tf/sum(tf(:));
prob.k=tf;
prob.init_x_every_itr=1;
prob.y=y;

[prob1,kListItr]=Multi_deblurring(prob,ret);
k=prob1.k;
% k=k/sum(k(:));
k(k(:) < max(k(:))*0.04) = 0;%threshold:20
k = k/sum(k(:));

%% final non blind deconvolution with the estimated kernel 

[ex]=deconvSps(y,k,0.0068,70);
if ~isempty(x)
   [ssde]=comp_upto_shift(ex,x);
 else
     ssde=[];
end
















