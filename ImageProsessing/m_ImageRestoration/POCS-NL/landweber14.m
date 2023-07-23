%% 采用行堆叠和频域方法求解landweber
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

function [im_deblur,MSE,stop_time,performance]=landweber14(bim,psf,iter,th,im_true)
%%  准备h,y,Fh,Fy,alpha,S,S0,x0/xf， true_image_row
% h pad zeros;
h=padarray(psf,size(bim)-size(psf),'post');

% shift so as to center is (1,1)
h=circshift(h,-floor(size(psf)/2));

% row accumulation h and y(bim)
hr=h';
hr=transpose(h(:));

yr=bim';
yr=transpose(yr(:));

% get Fh=fft(hr), Fy=fft(yr) CFh=conj(Fh): Complex conjugate of Fh
Fh=fft(hr);CFh=conj(Fh);
Fy=fft(yr);

S0=CFh;  
S=zeros(iter,prod(size(bim)));S(1,:)=S0;  %用于保存迭代格式

%取行和泛数,对于归一化的psf,alpha等于1
alpha=1/sum(psf(:));  

%真实图像的行堆叠排列
im_true_row=im_true';
im_true_row=transpose(im_true_row(:));  %row accumulation

%% 标志和输出变量准备
%prepare for MSE;
TMSE=zeros(1,iter); %temporary of MSE

%停止判定标志，表示根据MSE，应当在此处停止；但是为了观测MSE的变大，所以程序继续运行完所有迭代
never_stop=1;      %never stopped before this iteration

%保留MSE的变换速率
gra_performance=zeros(1,iter);

%%  iteration 
%{ 2S(k-1)- S(k-1)* conj(H) *S(k-1) } 
for k=1:iter
   % 迭代的当前值为x0,上一个值为x1,这点与landweber15恰好相反
   
   x0=ifft(S0.*Fy)*alpha;
   x0=real(x0);                              %limitation of real
   %mth=max(x0(:))/7;
   mth=0;
   x0(x0<mth)=0;                               %limitation of positive
   x0(x0>1)=1;                               %limitation of positive
   
   %获取下一个值
%    if k<8
      S(k+1,:)=2*S0-S0.*Fh.*S0;
      S0=S(k+1,:);
%    end
  
   %计算MSE
   TMSE(k)=norm(x0-im_true_row,'fro');
   
   if k>1
       gra_performance(k)=norm(x1-x0,'fro')/norm(x1,'fro');
   end

   if k==10
       watch=1;     %用于观测用的断点，并无实际意义
   end
   
   if never_stop & k>1
      if TMSE(k-1)<TMSE(k)                 %表示出现了半收敛点，此时是适当的停止时机   
             never_stop=0;
             im_opt=x1;
             stop_time=k-1;
      elseif gra_performance(k) > 1-th     %表示迭代在平缓区域运行，此时迭代已经没有明显的改善效果，因此停止迭代
             stop_time=k;
             never_stop=0;
             im_opt=x0;
      end   %end TMSE(k-1)<TMSE(k)
   end

   x1=x0;
 
end

if never_stop
    im_opt=x1;
    stop_time=iter;
end

im_deblur=reshape(im_opt,size(bim));
im_deblur=im_deblur';
MSE=TMSE/prod(size(bim));  
performance=gra_performance;     %传递平坦运行收敛性能曲线