%% �����жѵ���Ƶ�򷽷����landweber
% landweber is used ofr solve Ax=y, here A is cirulant matrix of psf(h)
% iteration format:  x(k+1)=x(k) + x(0)- alpha *conj(A)*A *x(k)

%th threhold of cutoff ,which means  xlast(xlast<th)=0;   
% ���ü��ٵ������������ٵ���ʽΪ��
%A(k)=A(k-1)(2I-AA(k-1));
%����A(0)=(A*)=W * conj(H) * inv(W), (A*)��A�İ������ӣ�H��PSF�жѵ���ĸ���Ҷ�任�� ����inv(W)=fft; W=ifft,
% A(0)  ==  W * conj(H)  * inv(W) , �򵥵�ӳ���ϵ���Կ���  A(0)  <------>  S(0)   <----->conj(H)  
% A(1)  ==  W * { 2H(0)- S(0)* H *S(0) } * inv(W)   
%......................................................
% A(k)  ==  W * { 2S(k-1)- S(k-1)* conj(H) *S(k-1) } * inv(W)
% ����A(k)���򵥵�ӳ���ϵ���Կ���  A(k)<------> S(k)=={ SH(k-1)- S(k-1)* conj(H) *S(k-1) }  
% �ָ�ͼ��Ϊ   x(k)=A(k) *yr';  yrΪ�жѵ���Ľ���ͼ��

function [im_deblur,MSE,stop_time,performance]=landweber14(bim,psf,iter,th,im_true)
%%  ׼��h,y,Fh,Fy,alpha,S,S0,x0/xf�� true_image_row
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
S=zeros(iter,prod(size(bim)));S(1,:)=S0;  %���ڱ��������ʽ

%ȡ�кͷ���,���ڹ�һ����psf,alpha����1
alpha=1/sum(psf(:));  

%��ʵͼ����жѵ�����
im_true_row=im_true';
im_true_row=transpose(im_true_row(:));  %row accumulation

%% ��־���������׼��
%prepare for MSE;
TMSE=zeros(1,iter); %temporary of MSE

%ֹͣ�ж���־����ʾ����MSE��Ӧ���ڴ˴�ֹͣ������Ϊ�˹۲�MSE�ı�����Գ���������������е���
never_stop=1;      %never stopped before this iteration

%����MSE�ı任����
gra_performance=zeros(1,iter);

%%  iteration 
%{ 2S(k-1)- S(k-1)* conj(H) *S(k-1) } 
for k=1:iter
   % �����ĵ�ǰֵΪx0,��һ��ֵΪx1,�����landweber15ǡ���෴
   
   x0=ifft(S0.*Fy)*alpha;
   x0=real(x0);                              %limitation of real
   %mth=max(x0(:))/7;
   mth=0;
   x0(x0<mth)=0;                               %limitation of positive
   x0(x0>1)=1;                               %limitation of positive
   
   %��ȡ��һ��ֵ
%    if k<8
      S(k+1,:)=2*S0-S0.*Fh.*S0;
      S0=S(k+1,:);
%    end
  
   %����MSE
   TMSE(k)=norm(x0-im_true_row,'fro');
   
   if k>1
       gra_performance(k)=norm(x1-x0,'fro')/norm(x1,'fro');
   end

   if k==10
       watch=1;     %���ڹ۲��õĶϵ㣬����ʵ������
   end
   
   if never_stop & k>1
      if TMSE(k-1)<TMSE(k)                 %��ʾ�����˰������㣬��ʱ���ʵ���ֹͣʱ��   
             never_stop=0;
             im_opt=x1;
             stop_time=k-1;
      elseif gra_performance(k) > 1-th     %��ʾ������ƽ���������У���ʱ�����Ѿ�û�����Եĸ���Ч�������ֹͣ����
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
performance=gra_performance;     %����ƽ̹����������������