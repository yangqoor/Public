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
theta_r_c = 1.6*pi/180;           % ����б�ӽ�
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
for i = 1 : 1
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
    st_tt_tar = A0(i)*wr.*wa.*exp(-1j*4*pi*R0/lambda)...
                            .*exp(-1j*pi*Ka*t_eta_Y.^2)...
                            .*exp(+1j*pi*Kr*(t_tauX-2*R_eta/c).^2);
    %}                                                          
    st_tt = st_tt + st_tt_tar;  
    
    pause(0.001);
    Time_Trans   = Time_Transform(toc);
    Time_Disp    = Time_Display(Time_Trans);
    Display_Data = num2str(roundn(i/Ntarget*100,-1));
    Display_Str  = ['Computation Progress ... ',Display_Data,'%',' --- ',...
                    'Using Time: ',Time_Disp];
    waitbar(i/Ntarget,wait_title,Display_Str)
end
pause(1);
close(wait_title);
toc
%% �ź�����--��һ�ξ���ѹ��                  
%  �źű任-->��ʽ������������Ƶ������ֱ����Ƶ������Ƶ��ƥ���˲���
%  �Ӵ�����
window = kaiser(Nrg,2.5)';                              % ʱ��
Window = fftshift(window);                          	% Ƶ��
Hrf = (abs(f_tau_X)<=Bw/2).*Window.*exp(+1j*pi*f_tau_X.^2/Kr);  
%  ƥ���˲�
Sf_ft = fft(st_tt,Nrg,2);
Srf_tf = Sf_ft.*Hrf;
srt_tt = ifft(Srf_tf,Nrg,2);
%% �ź�����--����λ����Ҷ�任
Saf_tf = fft(srt_tt,Naz,1);
%% �ź�����--�������㶯У��
RCM = lambda^2*r_tauX.*f_etaY.^2/(8*Vr^2);              % ��ҪУ���ľ����㶯��
RCM = R0 + RCM - R_eta_c;                               % �������㶯��ת����ԭͼ������ϵ��
offset = RCM/rho_r;                                     % �������㶯��ת��Ϊ���뵥Ԫƫ����
%  �����ֵϵ����(�˵��ֵ)
x_tmp = repmat(-4:3,[16,1]);                            % ��ֵ����                          
x_tmp = x_tmp + repmat(((1:16)/16).',[1,8]);            % ����λ��
hx = sinc(x_tmp);                                       % ���ɲ�ֵ��
kwin = repmat(kaiser(8,2.5).',[16,1]);                  % �Ӵ�
hx = kwin.*hx;
hx = hx./repmat(sum(hx,2),[1,8]);                       % �˵Ĺ�һ��
%  ��ֵ��У��
tic
wait_title = waitbar(0,'��ʼ���о����㶯У��(�˵��ֵ) ...');  
pause(1);
Srcmf_tf_8 = zeros(Naz,Nrg);
for a_tmp = 1 : Naz
    for r_tmp = 1 : Nrg
        offset_ceil = ceil(offset(a_tmp,r_tmp));
        offset_frac = round((offset_ceil - offset(a_tmp,r_tmp)) * 16);
        if offset_frac == 0
           Srcmf_tf_8(a_tmp,r_tmp) = Saf_tf(a_tmp,ceil(mod(r_tmp+offset_ceil-0.1,Nrg))); 
        else
           Srcmf_tf_8(a_tmp,r_tmp) = Saf_tf(a_tmp,ceil(mod((r_tmp+offset_ceil-4:r_tmp+offset_ceil+3)-0.1,Nrg)))*hx(offset_frac,:).';
        end
    end
    
    pause(0.001);
    Time_Trans   = Time_Transform(toc);
    Time_Disp    = Time_Display(Time_Trans);
    Display_Data = num2str(roundn(a_tmp/Naz*100,-1));
    Display_Str  = ['Computation Progress ... ',Display_Data,'%',' --- ',...
                    'Using Time: ',Time_Disp];
    waitbar(a_tmp/Naz,wait_title,Display_Str)
end
pause(1);
close(wait_title);
toc
%% �ź�����--�������㶯У��
RCM = lambda^2*r_tauX.*f_etaY.^2/(8*Vr^2);              % ��ҪУ���ľ����㶯��
RCM = R0 + RCM - R_eta_c;                               % �������㶯��ת����ԭͼ������ϵ��
offset = RCM/rho_r;                                     % �������㶯��ת��Ϊ���뵥Ԫƫ����
%  �����ֵϵ����(��������ֵ)
x_tmp = repmat(-4:3,[16,1]);                            % ��ֵ����                          
x_tmp = x_tmp + repmat(((1:16)/16).',[1,8]);            % ����λ��
hx = sinc(x_tmp);                                       % ���ɲ�ֵ��
kwin = repmat(kaiser(8,2.5).',[16,1]);                  % �Ӵ�
hx = kwin.*hx;
hx = hx./repmat(sum(hx,2),[1,8]);                       % �˵Ĺ�һ��
%  ��ֵ��У��
tic
wait_title = waitbar(0,'��ʼ���о����㶯У��(��������ֵ) ...');  
pause(1);
Srcmf_tf_0 = zeros(Naz,Nrg);
for a_tmp = 1 : Naz
    for r_tmp = 1 : Nrg
        offset_ceil = ceil(offset(a_tmp,r_tmp));
        offset_frac = round((offset_ceil - offset(a_tmp,r_tmp)) * 16);
        if offset_frac == 0
           Srcmf_tf_0(a_tmp,r_tmp) = Saf_tf(a_tmp,ceil(mod(r_tmp+offset_ceil-0.1,Nrg))); 
        else
           Srcmf_tf_0(a_tmp,r_tmp) = Saf_tf(a_tmp,ceil(mod((r_tmp+offset_ceil-4:r_tmp+offset_ceil+3)-0.1,Nrg)))*hx(offset_frac,:).';
           % �������
           point = r_tmp + ceil(offset(a_tmp,r_tmp));
           if (point < 1)
               point = 1;
           elseif(point > Nrg)
               point = Nrg;
           end
               Srcmf_tf_0(a_tmp,r_tmp) = Saf_tf(a_tmp,point);
        end
    end
    
    pause(0.001);
    Time_Trans   = Time_Transform(toc);
    Time_Disp    = Time_Display(Time_Trans);
    Display_Data = num2str(roundn(a_tmp/Naz*100,-1));
    Display_Str  = ['Computation Progress ... ',Display_Data,'%',' --- ',...
                    'Using Time: ',Time_Disp];
    waitbar(a_tmp/Naz,wait_title,Display_Str)
end
pause(1);
close(wait_title);
toc
%% �ź�����--�������㶯У��
RCM = lambda^2*r_tauX.*f_etaY.^2/(8*Vr^2);              % ��ҪУ���ľ����㶯��
RCM = R0 + RCM - R_eta_c;                               % �������㶯��ת����ԭͼ������ϵ��
offset = RCM/rho_r;                                     % �������㶯��ת��Ϊ���뵥Ԫƫ����
%  �����ֵϵ����(�ĵ��ֵ)
x_tmp = repmat(-2:1,[16,1]);                            % ��ֵ����                          
x_tmp = x_tmp + repmat(((1:16)/16).',[1,4]);            % ����λ��
hx = sinc(x_tmp);                                       % ���ɲ�ֵ��
kwin = repmat(kaiser(4,2.5).',[16,1]);                  % �Ӵ�
hx = kwin.*hx;
hx = hx./repmat(sum(hx,2),[1,4]);                       % �˵Ĺ�һ��
%  ��ֵ��У��
tic
wait_title = waitbar(0,'��ʼ���о����㶯У��(�ĵ��ֵ) ...');  
pause(1);
Srcmf_tf_4 = zeros(Naz,Nrg);
for a_tmp = 1 : Naz
    for r_tmp = 1 : Nrg
        offset_ceil = ceil(offset(a_tmp,r_tmp));
        offset_frac = round((offset_ceil - offset(a_tmp,r_tmp)) * 16);
        if offset_frac == 0
           Srcmf_tf_4(a_tmp,r_tmp) = Saf_tf(a_tmp,ceil(mod(r_tmp+offset_ceil-0.1,Nrg))); 
        else
           Srcmf_tf_4(a_tmp,r_tmp) = Saf_tf(a_tmp,ceil(mod((r_tmp+offset_ceil-2:r_tmp+offset_ceil+1)-0.1,Nrg)))*hx(offset_frac,:).';
        end
    end
    
    pause(0.001);
    Time_Trans   = Time_Transform(toc);
    Time_Disp    = Time_Display(Time_Trans);
    Display_Data = num2str(roundn(a_tmp/Naz*100,-1));
    Display_Str  = ['Computation Progress ... ',Display_Data,'%',' --- ',...
                    'Using Time: ',Time_Disp];
    waitbar(a_tmp/Naz,wait_title,Display_Str)
end
pause(1);
close(wait_title);
toc
%% �ź�����--����λѹ��
%  ��������
Ka = 2*Vr^2*cos(theta_r_c)^2./(lambda*r_tauX); 
%  �����˲���
Haf = exp(-1j*pi*f_etaY.^2./Ka);
Haf_offset = exp(-1j*2*pi*f_etaY.*t_eta_c);
%  ƥ���˲�
Soutf_tf_8 = Srcmf_tf_8.*Haf.*Haf_offset;
soutt_tt_8 = ifft(Soutf_tf_8,Naz,1);
Soutf_tf_0 = Srcmf_tf_0.*Haf.*Haf_offset;
soutt_tt_0 = ifft(Soutf_tf_0,Naz,1);
Soutf_tf_4 = Srcmf_tf_4.*Haf.*Haf_offset;
soutt_tt_4 = ifft(Soutf_tf_4,Naz,1);
% %% ��ͼ
% H1 = figure();
% set(H1,'position',[100,100,600,300]); 
% subplot(121),imagesc(real(soutt_tt_8))
% %  axis([0 Naz,0 Nrg])
% xlabel('����ʱ��(������)��'),ylabel('����λʱ��(������)'),title('(a)ʵ��')
% subplot(122),imagesc( abs(soutt_tt_8))
% %  axis([0 Naz,0 Nrg])
% xlabel('����ʱ��(������)��'),ylabel('����λʱ��(������)'),title('(b)����')
% sgtitle('ͼ6.12 ��λѹ����ķ�����','Fontsize',16,'color','k')
% %% ��ͼ
% H2 = figure();
% set(H2,'position',[100,100,600,300]); 
% subplot(121),imagesc(real(soutt_tt_0))
% %  axis([0 Naz,0 Nrg])
% xlabel('����ʱ��(������)��'),ylabel('����λʱ��(������)'),title('(a)ʵ��')
% subplot(122),imagesc( abs(soutt_tt_0))
% %  axis([0 Naz,0 Nrg])
% xlabel('����ʱ��(������)��'),ylabel('����λʱ��(������)'),title('(b)����')
% sgtitle('ͼ6.12 ��λѹ����ķ�����','Fontsize',16,'color','k')
% %% ��ͼ
% H3 = figure();
% set(H3,'position',[100,100,600,300]); 
% subplot(121),imagesc(real(soutt_tt_4))
% %  axis([0 Naz,0 Nrg])
% xlabel('����ʱ��(������)��'),ylabel('����λʱ��(������)'),title('(a)ʵ��')
% subplot(122),imagesc( abs(soutt_tt_4))
% %  axis([0 Naz,0 Nrg])
% xlabel('����ʱ��(������)��'),ylabel('����λʱ��(������)'),title('(b)����')
% sgtitle('ͼ6.12 ��λѹ����ķ�����','Fontsize',16,'color','k')
%% �ź�����--����Ŀ�����
%  8���ֵ
srcmt_tt_8 = ifft(Srcmf_tf_8,Naz,1);
Arcm_8 = srcmt_tt_8(:,round(Nrg/2+1+2*(NPosition(1,1)-R0)/c*Fr));
Arcm_8 = abs(Arcm_8)/max(abs(Arcm_8));
%  ��������ֵ
srcmt_tt_0 = ifft(Srcmf_tf_0,Naz,1);
Arcm_0 = srcmt_tt_0(:,round(Nrg/2+1+2*(NPosition(1,1)-R0)/c*Fr));
Arcm_0 = abs(Arcm_0)/max(abs(Arcm_0));
%  4���ֵ
srcmt_tt_4 = ifft(Srcmf_tf_4,Naz,1);
Arcm_4 = srcmt_tt_4(:,round(Nrg/2+1+2*(NPosition(1,1)-R0)/c*Fr));
Arcm_4 = abs(Arcm_4)/max(abs(Arcm_4));
%  ��λ��Ƭ
%  8���ֵ
len_az = 16;
cut_az = -len_az/2:len_az/2-1;
out_az_8 = soutt_tt_8(round(Naz/2+1+NPosition(1,2)/Vr*Fa)+cut_az,...
                      round(Nrg/2+1+2*(NPosition(1,1)-R0)/c*Fr)).';
spec_az_8 = fft(out_az_8);
spec_up_az_8 = ifft(spec_az_8,len_az*16);
spec_up_az_8 = 20*log10(abs(spec_up_az_8)/max(abs(spec_up_az_8)));
%  ��λ��Ƭ
%  ��������ֵ
len_az = 16;
cut_az = -len_az/2:len_az/2-1;

out_az_0 = soutt_tt_0(round(Naz/2+1+NPosition(1,2)/Vr*Fa)+cut_az,...
                      round(Nrg/2+1+2*(NPosition(1,1)-R0)/c*Fr)).';
spec_az_0 = fft(out_az_0);
spec_up_az_0 = ifft(spec_az_0,len_az*16);
spec_up_az_0 = 20*log10(abs(spec_up_az_0)/max(abs(spec_up_az_0)));
%  ��λ��Ƭ
%  4���ֵ
len_az = 16;
cut_az = -len_az/2:len_az/2-1;

out_az_4 = soutt_tt_4(round(Naz/2+1+NPosition(1,2)/Vr*Fa)+cut_az,...
                      round(Nrg/2+1+2*(NPosition(1,1)-R0)/c*Fr)).';
spec_az_4 = fft(out_az_4);
spec_up_az_4 = ifft(spec_az_4,len_az*16);
spec_up_az_4 = 20*log10(abs(spec_up_az_4)/max(abs(spec_up_az_4)));
%  ��ͼ
H4 = figure();
set(H4,'position',[100,100,900,600]); 
subplot(231),plot(abs(wa(:,1))),axis([0 Naz,0 1])
xlabel('��λ��(������)'),ylabel('����'),title('(a)����ľ����㶯У��(8���ֵ)')
subplot(232),plot(Arcm_0),axis([0 Naz,0 1])
xlabel('��λ��(������)'),ylabel('����'),title('(b)��������ֵ�ľ����㶯У��')
subplot(233),plot(Arcm_4),axis([0 Naz,0 1])
xlabel('��λ��(������)'),ylabel('����'),title('(c)4���ֵ�ľ����㶯У��')
subplot(234),plot(spec_up_az_8),axis([0 Naz,-30 0])
xlabel('��λ��(������)'),ylabel('����(dB)')
subplot(235),plot(spec_up_az_0),axis([0 Naz,-30 0])
xlabel('��λ��(������)'),ylabel('����(dB)')
subplot(236),plot(spec_up_az_4),axis([0 Naz,-30 0])
xlabel('��λ��(������)'),ylabel('����(dB)')
sgtitle('ͼ6.8 �����㶯У������ȷʱ���ɵ�������ĳɶԻز�','Fontsize',16,'color','k')