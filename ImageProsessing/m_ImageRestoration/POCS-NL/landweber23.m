%% �����жѵ���Ƶ�򷽷����landweber
% landweber is used ofr solve Ax=y, here A is cirulant matrix of psf(h)
% iteration format:  x(k+1)=x(k) + x(0)- alpha *conj(A)*A *x(k)
% ����2-ϵ�е�ֹͣ���������б仯�����У�ֹͣ��||  x_real-x_restor ||, ��Ϊ min ||Ax-y ||
 
%th threhold of cutoff ,which means  xlast(xlast<th)=0;    
function [im_deblur,MSE,stop_time,performance]=landweber23(bim,psf,iter,th)

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
Fh=fft(hr);
CFh=conj(Fh);
Fy=fft(yr);

% make iteration initial value x0=conj(A)y;
alpha=1/sum(psf(:));  %ȡ�кͷ���
x0=ifft(CFh.*Fy)*alpha;

xf=x0; %x(k)

%prepare for MSE;
TMSE=zeros(1,iter); %temporary of MSE
never_stop=1;      %never stopped before this iteration
gra_performance=zeros(1,iter);

for k=1:iter
    xlast=xf+x0-alpha*ifft(fft(xf).*(abs(Fh).^2));  %xlast is x(k+1)
    xlast=real(xlast);                              %limitation of real
    xlast(xlast<th(1))=th(1);                               %limitation of positive
    xlast(xlast>th(2))=th(2);                               %limitation of positive
    
    x2d=reshape(xlast,size(bim))';
    delta_2d=imfilter(x2d,psf)-bim;
    TMSE(k)=norm(delta_2d,'fro');
    
    % ֹͣ�ж�
    if never_stop   
     if k>1
        if TMSE(k-1)<TMSE(k)
            never_stop=0;                  %��ʾ�����˰������㣬��ʱ���ʵ���ֹͣʱ��
            stop_time=k-1;
            im_opt=xf;
        
        elseif (norm(xf-xlast,'fro')/norm(xlast,'fro'))<th  %��ʾ������ƽ���������У���ʱ�����Ѿ�û�����Եĸ���Ч�������ֹͣ����
             stop_time=k;
             never_stop=0;
             im_opt=xlast;
             gra_performance(k)=norm(xf-xlast,'fro')/norm(xlast,'fro');
         end   %end TMSE(k-1)<TMSE(k)
      end   % end k
    end    %end never_stop
    
       xf=xlast;
end

%�����������������û��ֹͣ�����������xlast��Ϊ����ͼ��
if never_stop
    im_opt=xlast;
    stop_time=iter;
end
im_deblur=reshape(im_opt,size(bim))';
MSE=TMSE;
performance=gra_performance;









