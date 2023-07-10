%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ļ�Ϊ��׶��������E�桢H�淽��ͼ
%
% E�淽��ͼ���������ǲ������ӺͲ���������µĶԱ�ͼ
% ɨ��Ƕȣ� -60��+60��
% �ο����ף�κ��Ԫ��������������ԭ��[M]. ������ҵ������, 1985.
% 17/1/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear
close all
%% %%%%%%%%%%%%    �����׶���Ƚṹ����      %%%%%%%%%%%%%%%%%%%%%%%
a = 23*10.^(-3);  %��������˿�� m��H�棩
b = 10*10.^(-3);  %��������˿�� m��E�棩
D1 = 238*10.^(-3);%��׶�ھ���� m��H�棩
D2 = 176*10.^(-3);%��׶�ھ���� m��E�棩
h = 465*10.^(-3); %��׶���ȳ���


%% %%%%%%%%%%%%%%      ���幤������  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = 9.375*10.^9;         %����Ƶ�� Hz
lamd = 3*10.^8/f;        %�������� m
k  = 2*pi/lamd;          %������  rad/m
R1 = h/(1-a/D1);         %H�������鶥�㵽�ھ����ľ��� 
R2 = h/(1-b/D2);         %E�������鶥�㵽�ھ����ľ��� 
theta1 = -60:0.2:60;     %�۲ⷶΧ
theta  = theta1.*pi/180; %�Ƕ�ת��Ϊ����

%% %%%%%%%%%%%%%%   H�淽��ͼ��ͼ     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = 0.5*sqrt(lamd*R1/2)*exp( 1i*(pi/4)*lamd*R1*(1/D1 + 2*sin(theta)/lamd).^2 ); 
N = 0.5*sqrt(lamd*R1/2)*exp( 1i*(pi/4)*lamd*R1*(1/D1 - 2*sin(theta)/lamd).^2 );
v1 = 0.707*(sqrt(lamd*R1)*(1/D1 + 2*sin(theta)/lamd) + D1/sqrt(lamd*R1));  
v2 = 0.707*(sqrt(lamd*R1)*(1/D1 + 2*sin(theta)/lamd) - D1/sqrt(lamd*R1));
v3 = 0.707*(sqrt(lamd*R1)*(1/D1 - 2*sin(theta)/lamd) + D1/sqrt(lamd*R1));
v4 = 0.707*(sqrt(lamd*R1)*(1/D1 - 2*sin(theta)/lamd) - D1/sqrt(lamd*R1));  
%%һ�����Ŵ���͵�����ȫ����������

FH = (1+cos(theta)).*(M.*Fresnel(v1,v2) + N.*Fresnel(v3,v4));  %����ͼ����

FH_M=abs(FH);         %ȡģֵ
FH_1=FH_M./max(FH_M); %��һ��
% FH_1=FH_M./1; %��һ��
FHdB=20*log10(FH_1);  %���÷ֱ���ʽ
% FHdB=FH_1;

figure(1)
hold on
plot(theta1,FHdB,'b','LineWidth',1.5);
%plot(t,FHA,'--r','LineWidth',1.6);  % %��Ҫ�Ƚ�ʵ��ȥ��ע�� ���Ѿ��ڱ����ռ����ʵ��ֵ
%legend('����H����ͼ','ʵ��H����ͼ');
grid on
title('��׶����H�淽��ͼ(����ʵ��Ƚ�)','FontName','��������',...
      'FontWeight','Bold','FontSize',16)
xlabel('\bf�ǶȦ�   ��λ����','FontSize',15);
ylabel('\bff(��)    ��λ��dB','FontSize',15);

%% %%%%%%%%%%%%%%   E�淽��ͼ��ͼ     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

G =sqrt(1-((lamd/(2*a))^2)); %��������
lamdg=lamd/G;

for n=1:2   %ѭ������������������Ϊ�������� ���޽��Ƶķ���ͼ�Ƚ�
    if n==2
        lamdg=lamd;
        G=1;
    end

    v5 = 0.707*(sqrt(lamdg*R2).*(2*sin(theta)/lamd) + D2/sqrt(lamdg*R2));
    v6 = 0.707*(sqrt(lamdg*R2).*(2*sin(theta)/lamd) - D2/sqrt(lamdg*R2));

    FE=(1+G*cos(theta)).*Fresnel(v5,v6); %����ͼ����
    FEM=abs(FE);        %ȡģֵ
    FE1=FEM./max(FEM);  %��һ��
    FEdB=20*log10(FE1); %���÷ֱ���ʽ

figure(2)
    hold on
    if n==1
        plot(theta1,FEdB,'--g','LineWidth',1.5);
    else
        plot(theta1,FEdB,'b','LineWidth',1.5); 
    end
%plot(tt,FEA,'--r','LineWidth',2);  %��Ҫ�Ƚ�ʵ��ȥ��ע��
%legend('����E����ͼ','����E����ͼ(G=1)','ʵ��E����ͼ');
    grid on
title('��׶����E�淽��ͼ������ʵ��Ƚϣ�','FontName','��������',...
      'FontWeight','Bold','FontSize',16)
xlabel('\bf�ǶȦ�   ��λ����','FontSize',15);
ylabel('\bff(��)    ��λ��dB','FontSize',15);
end


