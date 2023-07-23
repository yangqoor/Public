%% �����жѵ���Ƶ�򷽷�����С����newton�����ͼ��
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

% gamma: �ȶ���������ǿ������
function [im_deblur,MSE,stop_time,performance]=min2newton2(bim,psf,gamma)
%%  ׼��h,y,Fh,Fy,alpha,S,S0,x0/xf�� true_image_row
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

% �ȶ�������c1,psf��y�ĸ���Ҷ�任
Fh=fft(hr);CFh=conj(Fh);
Fc=fft(c1);
Fy=fft(yr);

P0=abs(Fh).^2+gamma*(abs(Fc).^2);  

%ȡ�кͷ���,���ڹ�һ����psf,alpha����1
alpha=1/sum(psf(:));  

%% ��־���������׼��
%prepare for MSE;
iter=30;%�����ڶ�30�ε���
TMSE=zeros(1,iter); %temporary of MSE

%ֹͣ�ж���־����ʾ����MSE��Ӧ���ڴ˴�ֹͣ������Ϊ�˹۲�MSE�ı�����Գ���������������е���
never_stop=1;      %never stopped before this iteration

%����MSE�ı任����
gra_performance=zeros(1,iter);

%%  iteration 
%{ 2P(k-1)- P(k-1)* P0 *P(k-1) } 
Pk=P0;
for k=1:iter
   % �����ĵ�ǰֵΪx0,��һ��ֵΪx1,�����landweber15ǡ���෴
   x0=ifft(Pk.*Fy.*CFh)*alpha;
   x0=real(x0);                              %limitation of real
   mth=0;  x0(x0<mth)=0;                               %limitation of positive
   x0(x0>1)=1;                               %limitation of positive
   %imshow(reshape(x0,size(bim)),[])
   %��ȡ��һ��ֵ
   
     Pk=Pk*2-Pk.*P0.*Pk;
   %����MSE
    x2=reshape(x0,fliplr(size(bim)));
    x2=x2';                     %�˴���Ϊ��ʵͼ����Ч�����õ�TMSE
   TMSE(k)=norm(imfilter(x2,psf)-bim,'fro');
   %TMSE(k)=norm(im_true_row-x0,'fro');

   if k==10
       watch=1;     %���ڹ۲��õĶϵ㣬����ʵ������
   end
   
   if never_stop & k>1
      if TMSE(k-1)<TMSE(k)                 %��ʾ�����˰������㣬��ʱ���ʵ���ֹͣʱ��   
             never_stop=0;
             im_opt=x1;
             stop_time=k-1;
      end
   end
   x1=x2;  %����ǰ��������
end

if never_stop
    im_opt=x2;   
    stop_time=iter;
end
  
im_deblur=im_opt;
MSE=TMSE;  
performance=gra_performance;     %����ƽ̹����������������