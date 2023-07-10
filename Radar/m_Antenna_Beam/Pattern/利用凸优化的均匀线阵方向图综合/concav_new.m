%  ����������ͼ�ۺϣ�ʹ��͹�Ż���������������ƽ����������
%һ����ȵİ��ڣ�ת����͹�Ż�����
clc;
clear all;
close all;

%  ��������
ima=sqrt(-1);
C_num=40;                            % ��Ԫ��
f=5.4e9;                             %Ƶ��12GHz
lamda = 3e8/f;                        % ����
d = 0.5*lamda;                      % ��Ԫ���
theta0=90;                           % Ŀ��
main_width=0.2;                       % ��λ/��
ripple = 0.3;                        % ��λ/dB
deta=5;                              %���ɴ���
main_lobe_l=theta0-main_width/2;     %����Ƕ�����
main_lobe_u=theta0+main_width/2;     %����Ƕ�����
side_lobe_l=main_lobe_l-deta;        %�԰�Ƕ�����
side_lobe_u=main_lobe_u+deta;        %�԰�Ƕ�����

%�Ż�����
m = 3600;
theta=linspace(0,180,m)';            %�ǶȾ��Ȼ���

A=exp( -ima*2*pi*d*cos(theta*pi/180)*[1-C_num:C_num-1]/lamda );

ind=find(main_lobe_l<=theta & theta<=main_lobe_u);
Am = A(ind,:);                       %��Ӧ������

ind=find(0<=theta & theta<=side_lobe_l | side_lobe_u<=theta & theta<=180);
As = A(ind,:);                      %��Ӧ�԰���

ind=find(145<=theta & theta<=150);
A_cave=A(ind,:);

cvx_begin

  variable r(2*C_num-1,1) complex  
  minimize( max( real( As*r ) ) )    %�԰�
  %minimize(norm(r))
  subject to    
    %(10^(-ripple/20))^2<=real( Am*r )<=(10^(+ripple/20))^2;
    real(As*r)<=(10^(-40/20))^2;
    real(A_cave*r)<=(10^(-30/20))^2;
    real( A*r ) >= 0;        
    imag(r(C_num)) == 0;
    r(C_num-1:-1:1) == conj(r(C_num+1:2*C_num-1));
cvx_end

% check if problem was successfully solved
if ~strfind(cvx_status,'Solved')
    return
end

% find antenna weights by computing the spectral factorization
w = spectral_fact(r);%�����Ӻ���spectral_fact

% divided by 2 since this is in PSD domain
min_sidelobe_level = 10*log10( cvx_optval );
fprintf(1,'The minimum sidelobe level is %3.2f dB.\n\n',...
          min_sidelobe_level);
      
 
      
%����ͼ�γ�
theta=[0:0.01:180];
w0=exp(ima*2*pi*d*cos(theta0*pi/180)*[0:C_num-1]'/lamda);
w1=w/max(abs(w));                %����ͼ�ۺϵ�����Ȩ
for j=1:length(theta)
    a=exp(ima*2*pi*d*cos(theta(j)*pi/180)*[0:C_num-1]'/lamda);
    gain(j)=w0'*a;               %��ͨ��̬����ͼ��Ӧ
    gain_opt(j)=w1'*a;             %�ۺϷ���ͼ��Ӧ
end
max_value=max(abs(gain));

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
axis([0 180 ymin ymax]);
legend('�Ż���','��ͨ��');
