%  ��������ƽ������ͼ�ۺ�
%������Ӧ������������С����������С��ĳһ��ƽֵ�������еķ��棬
%min abs��p(thetam)-pd(theta)��
%p(thetas)<=sigma
clc;
clear all;
close all;

%=================��������=====================%
ima=sqrt(-1);
C_num=41;                            % ��Ԫ��
f=10e9;                             %Ƶ��12GHz
lamda = 3e8/f;                        % ����
d = 0.5*lamda;                      % ��Ԫ���
theta0=0;                           % Ŀ��
main_width=10;                       % ��λ/��

deta=5;                              %���ɴ���
main_lobe_l=theta0-main_width/2;     %����Ƕ�����
main_lobe_u=theta0+main_width/2;     %����Ƕ�����
side_lobe_l=main_lobe_l-deta;        %�԰�Ƕ�����
side_lobe_u=main_lobe_u+deta;        %�԰�Ƕ�����


theta=[-90:90]';            %�ǶȾ��Ȼ���

A=exp( -ima*2*pi*d*sin(theta*pi/180)*[-(C_num-1)/2:(C_num-1)/2]/lamda );

ind=find(main_lobe_l<=theta & theta<=main_lobe_u);
L=length(ind);
Am = A(ind,:);                       %��Ӧ������

ind=find(-90<=theta & theta<=side_lobe_l | side_lobe_u<=theta & theta<=90);
As = A( ind,:);                      %��Ӧ�԰���
%===========================�Ż���ʽ==========================%
cvx_begin

  variable w(C_num) complex  
  minimize( ( Am*w-1 )'*( Am*w-1 )/L )    %����
  
  subject to    
    abs( As*w )<=10^(-30/20);
    
cvx_end

% check if problem was successfully solved
if ~strfind(cvx_status,'Solved')
    return
end
      
%====================����ͼ�γ�====================%
theta=[-90:0.5:90];
a0=exp(ima*2*pi*d*sin(theta0*pi/180)*[-(C_num-1)/2:(C_num-1)/2]'/lamda);
w0=a0/norm(a0)/norm(a0);
w1=w/norm(w)/norm(a0);                %����ͼ�ۺϵ�����Ȩ
% w1=w;                %����ͼ�ۺϵ�����Ȩ
% w0=a0/norm(a0);
% w1=w/norm(w);  
for j=1:length(theta)
    a=exp(ima*2*pi*d*sin(theta(j)*pi/180)*[-(C_num-1)/2:(C_num-1)/2]'/lamda);
    gain(j)=w0'*a;               %��ͨ��̬����ͼ��Ӧ
    gain_opt(j)=w1'*a;             %�ۺϷ���ͼ��Ӧ
end
max_value=1;

G=abs(gain)/max_value;
G=20*log10(G);                    %��ͨ����ͼ

Y=abs(gain_opt)/max_value;        %�Ż�����ͼ
Y=20*log10(Y);

figure(1);clf
ymin = -100; ymax = 5;
plot(theta,Y,'.-b',theta,G,'p-m',...
     [theta0 theta0],[ymin ymax],'k--');
   
grid on,hold on
xlabel('������/��'), ylabel('����/dB');
axis([-90 90 ymin ymax]);
legend('�Ż���','��ͨ��');
