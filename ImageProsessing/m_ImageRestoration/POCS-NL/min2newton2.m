%% 采用行堆叠和频域方法，最小二乘newton法求解图像
% landweber is used ofr solve Ax=y, here A is cirulant matrix of psf(h)
% iteration format:  x(k+1)=x(k) + x(0)- alpha *conj(A)*A *x(k)

%th threhold of cutoff ,which means  xlast(xlast<th)=0;   
% 采用加速迭代方法，加速迭代式为：
%A(k)=A(k-1)(2I-AA(k-1));
%其中A(0)=(A*)=W * conj(H) * inv(W), (A*)是A的伴随算子，H是PSF行堆叠后的傅立叶变换， 另外inv(W)=fft; W=ifft,
% A(0)  ==  W * conj(H)  * inv(W) , 简单的映射关系可以看成  A(0)  <------>  S(0)   <----->conj(H)  
% A(1)  ==  W * { 2H(0)- S(0)* H *S(0) } * inv(W)   
%......................................................
% A(k)  ==  W * { 2S(k-1)- S(k-1)* conj(H) *S(k-1) } * inv(W)
% 对于A(k)，简单的映射关系可以看成  A(k)<------> S(k)=={ SH(k-1)- S(k-1)* conj(H) *S(k-1) }  
% 恢复图像为   x(k)=A(k) *yr';  yr为行堆叠后的降晰图像

% gamma: 稳定化泛函的强度因子
function [im_deblur,MSE,stop_time,performance]=min2newton2(bim,psf,gamma)
%%  准备h,y,Fh,Fy,alpha,S,S0,x0/xf， true_image_row
% h pad zeros;
h=padarray(psf,size(bim)-size(psf),'post');

% shift so as to center is (1,1)
h=circshift(h,-floor(size(psf)/2));

% row accumulation h and y(bim)
hr=h';
hr=transpose(h(:));

%2 order  laplace  smoothing function
c=1/8*[0 1 0;...
   1 -4 1;...
   0  1  0];

c1=padarray(c,size(bim)-size(c),'post');
c1=circshift(c1,-floor(size(psf)/2));
c1=c1';
c1=transpose(c1(:));

% get Fh=fft(hr), Fy=fft(yr) CFh=conj(Fh): Complex conjugate of Fh
yr=bim';
yr=transpose(yr(:));

% 稳定化泛函c1,psf，y的傅立叶变换
Fh=fft(hr);CFh=conj(Fh);
Fc=fft(c1);
Fy=fft(yr);

P0=abs(Fh).^2+gamma*(abs(Fc).^2);  

%取行和泛数,对于归一化的psf,alpha等于1
alpha=1/sum(psf(:));  

%% 标志和输出变量准备
%prepare for MSE;
iter=30;%程序内定30次迭代
TMSE=zeros(1,iter); %temporary of MSE

%停止判定标志，表示根据MSE，应当在此处停止；但是为了观测MSE的变大，所以程序继续运行完所有迭代
never_stop=1;      %never stopped before this iteration

%保留MSE的变换速率
gra_performance=zeros(1,iter);

%%  iteration 
%{ 2P(k-1)- P(k-1)* P0 *P(k-1) } 
Pk=P0;
for k=1:iter
   % 迭代的当前值为x0,上一个值为x1,这点与landweber15恰好相反
   x0=ifft(Pk.*Fy.*CFh)*alpha;
   x0=real(x0);                              %limitation of real
   mth=0;  x0(x0<mth)=0;                               %limitation of positive
   x0(x0>1)=1;                               %limitation of positive
   %imshow(reshape(x0,size(bim)),[])
   %获取下一个值
   
     Pk=Pk*2-Pk.*P0.*Pk;
   %计算MSE
    x2=reshape(x0,fliplr(size(bim)));
    x2=x2';                     %此处认为真实图像无效，采用的TMSE
   TMSE(k)=norm(imfilter(x2,psf)-bim,'fro');
   %TMSE(k)=norm(im_true_row-x0,'fro');

   if k==10
       watch=1;     %用于观测用的断点，并无实际意义
   end
   
   if never_stop & k>1
      if TMSE(k-1)<TMSE(k)                 %表示出现了半收敛点，此时是适当的停止时机   
             never_stop=0;
             im_opt=x1;
             stop_time=k-1;
      end
   end
   x1=x2;  %保存前次运算结果
end

if never_stop
    im_opt=x2;   
    stop_time=iter;
end
  
im_deblur=im_opt;
MSE=TMSE;  
performance=gra_performance;     %传递平坦运行收敛性能曲线