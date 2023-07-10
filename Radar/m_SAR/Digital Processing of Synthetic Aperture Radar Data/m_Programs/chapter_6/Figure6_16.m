clc
clear
close all
%% ��������
%  ��֪����--�����������
R_eta_c = 20e+3;                % ������б��
Tr = 2.5e-6;                    % ��������ʱ��
Kr = 20e+12;                    % �������Ƶ��
alpha_os_r = 1.2;               % �����������
Nrg = 320;                      % �����߲�������
%  �������--�����������
Bw = abs(Kr)*Tr;                % �����źŴ���
Fr = alpha_os_r*Bw;             % �����������
Nr = round(Fr*Tr);              % �����������(�������г���)
%  ��֪����--����λ�����
c = 3e+8;                       % ��Ŵ����ٶ�
Vr = 150;                       % ��Ч�״��ٶ�
Vs = Vr;                        % ����ƽ̨�ٶ�
Vg = Vr;                        % ����ɨ���ٶ�
f0 = 5.3e+9;                    % �״﹤��Ƶ��
Delta_f_dop = 80;               % �����մ���
alpha_os_a = 1.25;              % ��λ��������
Naz = 256;                      % ��������
theta_r_c = +21.9*pi/180;       % ����б�ӽ�
%  �������--����λ�����
lambda = c/f0;                  % �״﹤������
t_eta_c = -R_eta_c*sin(theta_r_c)/Vr;
                                % �������Ĵ�Խʱ��
f_eta_c = 2*Vr*sin(theta_r_c)/lambda;
                                % ����������Ƶ��
La = 0.886*2*Vs*cos(theta_r_c)/Delta_f_dop;               
                                % ʵ�����߳���
Fa = alpha_os_a*Delta_f_dop;    % ��λ�������
Ta = 0.886*lambda*R_eta_c/(La*Vg*cos(theta_r_c));
                                % Ŀ������ʱ��
R0 = R_eta_c*cos(theta_r_c);    % ���б��
Ka = 2*Vr^2*cos(theta_r_c)^2/lambda/R0;              
                                % ��λ���Ƶ��
theta_bw = 0.886*lambda/La;     % ��λ��3dB�������
theta_syn = Vs/Vg*theta_bw;     % �ϳɽǿ��
Ls = R_eta_c*theta_syn;         % �ϳɿ׾�����
%  ��������
rho_r = c/(2*Fr);               % ������ֱ���
rho_a = La/2;                   % ������ֱ���
Trg = Nrg/Fr;                   % ��������ʱ��
Taz = Naz/Fa;                   % Ŀ������ʱ��
d_t_tau = 1/Fr;                 % �������ʱ����
d_t_eta = 1/Fa;                 % ��λ����ʱ����
d_f_tau = Fr/Nrg;               % �������Ƶ�ʼ��    
d_f_eta = Fa/Naz;               % ��λ����Ƶ�ʼ��
%% Ŀ������
%  ����Ŀ�������ھ�����֮��ľ���
A_r =   0; A_a =   0;                                   % A��λ��
B_r = -50; B_a = -50;                                   % B��λ��
C_r = -50; C_a = +50;                                   % C��λ��
D_r = +50; D_a = C_a + (D_r-C_r)*tan(theta_r_c);        % D��λ��
%  �õ�Ŀ�������ھ����ĵ�λ������
A_x = R0 + A_r; A_Y = A_a;                              % A������
B_x = R0 + B_r; B_Y = B_a;                              % B������
C_x = R0 + C_r; C_Y = C_a;                              % C������
D_x = R0 + D_r; D_Y = D_a;                              % D������
NPosition = [A_x,A_Y;
             B_x,B_Y;
             C_x,C_Y;
             D_x,D_Y;];                                 % ��������
fprintf( 'A������Ϊ[%+3.3f��%+3.3f]km\n', NPosition(1,1)/1e3, NPosition(1,2)/1e3 );
fprintf( 'B������Ϊ[%+3.3f��%+3.3f]km\n', NPosition(2,1)/1e3, NPosition(2,2)/1e3 );
fprintf( 'C������Ϊ[%+3.3f��%+3.3f]km\n', NPosition(3,1)/1e3, NPosition(3,2)/1e3 );
fprintf( 'D������Ϊ[%+3.3f��%+3.3f]km\n', NPosition(4,1)/1e3, NPosition(4,2)/1e3 );
%  �õ�Ŀ���Ĳ������Ĵ�Խʱ��
Ntarget = 4;
Tar_t_eta_c = zeros(1,Ntarget);
for i = 1 : Ntarget
    DeltaX = NPosition(i,2) - NPosition(i,1)*tan(theta_r_c);
    Tar_t_eta_c(i) = DeltaX/Vs;
end
%  �õ�Ŀ���ľ����������ʱ��
Tar_t_eta_0 = zeros(1,Ntarget);
for i = 1 : Ntarget
    Tar_t_eta_0(i) = NPosition(i,2)/Vr;
end
%% ��������
%  ʱ����� �Ծ����ĵ��������ʱ����Ϊ��λ�����
t_tau = (-Trg/2:d_t_tau:Trg/2-d_t_tau) + 2*R_eta_c/c;   % ����ʱ�����
t_eta = (-Taz/2:d_t_eta:Taz/2-d_t_eta) + t_eta_c;       % ��λʱ�����
%  ���ȱ���
r_tau = (t_tau*c/2)*cos(theta_r_c);                     % ���볤�ȱ���                                                     
%  Ƶ�ʱ��� 
f_tau = fftshift(-Fr/2:d_f_tau:Fr/2-d_f_tau);           % ����Ƶ�ʱ���
f_tau = f_tau - round((f_tau-0)/Fr)*Fr;                 % ����Ƶ�ʱ���(�ɹ۲�Ƶ��)                          
f_eta = fftshift(-Fa/2:d_f_eta:Fa/2-d_f_eta);           % ��λƵ�ʱ���
f_eta = f_eta - round((f_eta-f_eta_c)/Fa)*Fa;           % ��λƵ�ʱ���(�ɹ۲�Ƶ��)
%% ��������  
%  �Ծ���ʱ��ΪX�ᣬ��λʱ��ΪY��
[t_tauX,t_etaY] = meshgrid(t_tau,t_eta);                % ���þ���ʱ��-��λʱ���ά��������
%  �Ծ��볤��ΪX�ᣬ��λƵ��ΪY��                                                                                                            
[r_tauX,f_etaY] = meshgrid(r_tau,f_eta);                % ���þ���ʱ��-��λƵ���ά��������
%  �Ծ���Ƶ��ΪX�ᣬ��λƵ��ΪY��                                                                                                            
[f_tau_X,f_eta_Y] = meshgrid(f_tau,f_eta);              % ����Ƶ��ʱ��-��λƵ���ά��������
%% �ź�����--��ԭʼ�ز��ź�                                                        
tic
wait_title = waitbar(0,'��ʼ�����״�ԭʼ�ز����� ...');  
pause(1);
st_tt = zeros(Naz,Nrg);
for i = 1 : Ntarget
    %  ����Ŀ����˲ʱб��
    R_eta = sqrt( NPosition(i,1)^2 +...
                  Vr^2*(t_etaY-Tar_t_eta_0(i)).^2 ); 
    %{
    R_eta = NPosition(i,1) + Vr^2*t_etaY.^2/(2*NPosition(i,1));   
    %}
    %  ����ɢ��ϵ������
    A0 = [1,1,1,1]*exp(+1j*0);   
    %  ���������
    wr = (abs(t_tauX-2*R_eta/c) <= Tr/2);                               
    %  ��λ�����
    wa = sinc(0.886*atan(Vg*(t_etaY-Tar_t_eta_c(i))/NPosition(i,1))/theta_bw).^2;      
    %  �����źŵ���
    st_tt_tar = A0(i)*wr.*wa.*exp(-1j*4*pi*f0*R_eta/c)...
                            .*exp(+1j*pi*Kr*(t_tauX-2*R_eta/c).^2); 
    %{
    srt_tt_tar = A0(i)*wr.*wa.*exp(-1j*4*pi*R0/lambda)...
                             .*exp(-1j*pi*Ka*t_eta_Y.^2)...
                             .*exp(+1j*pi*Kr*(t_tauX-2*R_eta/c).^2);
    %}                                                          
    st_tt = st_tt + st_tt_tar;  
end
%%  ��ͼ
H = figure();
set(H,'position',[100,100,600,600]);                    
subplot(221),imagesc( real(st_tt))             
xlabel('����ʱ��(������)��'),ylabel('����λʱ��(������)'),title('(a)ʵ��')
subplot(222),imagesc( imag(st_tt))
xlabel('����ʱ��(������)��'),ylabel('����λʱ��(������)'),title('(b)�鲿')
subplot(223),imagesc(  abs(st_tt)) 
xlabel('����ʱ��(������)��'),ylabel('����λʱ��(������)'),title('(c)����')
subplot(224),imagesc(angle(st_tt))
xlabel('����ʱ��(������)��'),ylabel('����λʱ��(������)'),title('(d)��λ')
sgtitle('ͼ6.16 ��б�ӽ�����¶���״�ԭʼ�����ź�','Fontsize',16,'color','k')
pause(1);
close(wait_title);
toc