function [res_image_RL,mse_RL]=RL(original,blured,OTF,iterations,denoise,project)
%Time���Ķ���2009.12.25   21:37
%--------------------------------------------------------------------------
%�޸��˽����������������Ժ��ͼ����Ϊ���ֱ�֮ǰ��bluredͼ�񡣽���������иĽ�
%--------------------------------------------------------------------------
%����RL�㷨��ͼ�񳬷ֱ��㷨
%original,blured�ֱ��ʾԭʼͼ����˻�ͼ�����OTFΪ�⴫�ݺ�����iterations�ǵ�
%������������ֱ��Ǹ�ԭͼ��res_image_RL�͵��������о������mse_RL�ı仯����
%--------------------------------------------------------------------------
%�򵥵ĳ�ʼ�������ݾ���Ԥ����
mse_RL=zeros(1,iterations+1);
front=zeros(size(blured));%������ŵ�����ǰ��ͼ��
back=front; %������ŵ����Ժ��ͼ��
%%% front=blured;    �˴�Ϊ12.25��
mse_RL(1)=MSE(original,blured);

win0=double(abs(OTF)<=1e-10);%�ҳ�OTF��ȫΪ���
win1=1-win0;%�ҳ�OTF�в�Ϊ��ĵ�
%--------------------------------------------------------------------------
%�Ƿ�ѡ���빦�ܣ���  denoise==1
if denoise==1
   G=fft2(blured).*win1;
   blured=IMRA(ifft2(G));%%%%%�˴�Ϊ12.25��
end
front=blured;

%�Ƿ�ͶӰ                     %project==1��ʾҪ����ͶӰ����
if project==1
    %----------------------------------------------------------------------
    %ά���˲�
    %snr=estsnr(blured);
    %r=5*10^(-snr/10);  
    G1=fft2(front).*conj(OTF)./(abs(OTF).^2+0.01);%ά���˲�����ԭͼ��ĵ�Ƶ�ɷ�
    %G1=fft2(front)./(OTF+eps);%ֱ�����˲����е�Ƶ�ָ�
    %G1=fft2(original);%��������ͼ��ĵ�Ƶ��Ϣ��ʵ��
    
end

for i=1:iterations
    f1=fft2(front).*OTF;
    t2=IMRA(ifft2(f1));
    t3=blured./t2;
    f4=fft2(t3).*conj(OTF);
    t5=IMRA(ifft2(f4));
    back=front.*t5;
    %----------------------------------------------------------------------
    %project onto convex set
    %Ƶ�򷴸�����
    if project==1
        %fback=win1.*G1+win0.*fft2(back);
        fback=OTF.*G1+(1-OTF).*fft2(back);
        back=IMRA(ifft2(fback));
        
    end
    %----------------------------------------------------------------------
    front=back;
    mse_RL(i+1)=MSE(original,front);
end
res_image_RL=front;
