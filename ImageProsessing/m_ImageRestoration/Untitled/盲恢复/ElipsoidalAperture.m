function [f] = ElipsoidalAperture(M,N,axisx,axisy)
%��ʵ���ǲ���һ��Բ�׾�����
%ElipsoidalAperture ����һ����Բ�׾�ͼ��
% MΪͼ��ֱ��������NΪͼ��ˮƽ������
% axisxΪ��Բˮƽ����������axisyΪ��Բ��������
% ���������ַ�ʽ������һ������FOR��䣬һ������MESHGRID����������
% �����ʼ�������ڴ棬FOR���Ҫ��MESHGRD��ʱ��Ķ࣬
% ���������ʼ�����ڴ棬FOR����MESHGRID��࣬��΢��Щ��
% close all;clc;clear;
%----------------------------------
% ��ʼֵ
% M=512;
% N=512;
% axisx=80;
% axisy=32;
%---------------------------------
f=zeros(M,N);
% ��ǿ�ж��Ƿ񳬹���һ������(���ÿɲ��ã�
% if(axisx>=M/2)
%     axisx=M/2;
% end
% if(axisy>=N/2)
%     axisy=N/2;
% end
%-----------------------------------
halfrow=ceil(M/2); % ȷ������ͼ���X�����ĵ�
halfcol=ceil(N/2); % ȷ������ͼ���Y�����ĵ�
% halfrow=M/2;
% halfcol=N/2;
%-------------------------------------------------------------------------
% ��FOR����������Բ
% tic;
% for i=1:1:N
%     for j=1:1:M
%         flxcen=i-halfcol;
%         flycen=j-halfrow;
%         flradius=(flxcen*flxcen)/(axisy*axisy)+(flycen*flycen)/(axisx*axisx);
%         if flradius<1
%             f(i,j)=1;
%         else
%             f(i,j)=0;
%         end
%     end
% end
% y=toc;
%-----------------------------------------------------------------------
% �þ��󷽷������Ŀ�����Բ����
% f=fftshift(lpfilter('ideal',63,63,32));
% tic;
[U,V]=meshgrid(1:M,1:N);%����һ����������ھ�������
U=U-halfrow;            %ȷ��ͼ����ÿ�����ص�X�����λ��
V=V-halfcol;            %ȷ��ͼ����ÿ�����ص�Y�����λ��
D=U.^2/axisx.^2+V.^2/axisy.^2;%ȷ��ͼ����ÿ�����ص���԰뾶
f=D<1;
f=im2double(f);
% x=toc;    
%------------------------------------------------------------------------
% y=x-y;
% imshow(ff);
%figure,imshow(f);
%figure,mesh(f(1:5:end,1:5:end));