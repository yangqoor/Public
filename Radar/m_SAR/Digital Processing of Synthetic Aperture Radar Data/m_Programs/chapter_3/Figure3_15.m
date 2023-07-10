clc
clear
close all

% ��������
TBP = 42;                % ʱ�����˻�
T = 7.2e-6;              % �������ʱ��
N_st = 2^11;                         
% ��������
B = TBP/T;               % �źŴ���
K = B/T;                 % ��ƵƵ��
alpha_os = 200;          % �������ʣ�ʹ�ù��ߵĹ���������Ϊ�˷����ʵ��������
F = alpha_os*B;          % ����Ƶ��
N = 2*ceil(F*T/2);       % ��������
dt = T/N;                % ����ʱ����
df = F/N;                % ����Ƶ�ʼ��
% ��������
t_c = 0e-6;              % ʱ��ƫ��
% ��������
f_c = -K*t_c;            % ����Ƶ��
% ��������
t1 = -T/2:dt:T/2-dt;     % ʱ�����
f1 = -F/2:df:F/2-df;     % Ƶ�ʱ���
% �źű��                             
st = exp(1j*pi*K*(t1-t_c).^2);          % �����ź�
% % ��ͼ
% H1 = figure;
% set(H1,'position',[100,100,600,300]);
% subplot(211),plot(t1,real(st),'k')
% subplot(212),plot(t1,imag(st),'k')
% suptitle('�����ź�')
% ��������
t_0 = 0e-6;              % �ز�ʱ��
% ��������
t2 = -T/2+t_0:dt:T/2+t_0-dt;            % ʱ�����
f2 = -F/2+f_c:df:F/2+f_c-df;            % Ƶ�ʱ���
% �źű��                                                                 
srt = exp(1j*pi*K*(t2-t_c-t_0).^2);     % �ز��ź�
% % ��ͼ
% H2 = figure;
% set(H2,'position',[100,100,600,300]);
% subplot(211),plot(t2,real(srt),'k')
% subplot(212),plot(t2,imag(srt),'k')
% suptitle('�ز��ź�')
%%
% % ������
% window_1 = kaiser(N,2.5)';              % ʱ��
% Window_1 = fftshift(window_1);          % Ƶ��
% % �źű任-->��ʽһ
% ht_1 = conj(fliplr(srt));               % ��ʱ�䷴�޺�ĸ�������ȡ������
% ht_window_1 = window_1.*ht_1;           % �Ӵ�
% Hf_1 = fftshift(fft(ht_1,N));           % ���㲹����ɢ����Ҷ�任
% % ��ͼ
% H3 = figure;
% set(H3,'position',[100,100,600,450]);
% subplot(311),plot(real(Hf_1),'k')
% axis([4000 4400,-1200 1600])
% subplot(312),plot(imag(Hf_1),'k')
% axis([4000 4400,-1200 1600])
% subplot(313),plot( abs(Hf_1),'k')
% suptitle('��ʽһ���ɵ�Ƶ��ƥ���˲���')
% axis([4000 4400,    0 1600])
% % ������ 
% window_2 = kaiser(N,2.5)';              % ʱ��
% Window_2 = fftshift(window_2);          % Ƶ��
% % �źű任-->��ʽ��
% ht_2 = srt;                             % �����ź�
% ht_window_2 = window_2.*ht_2;           % �Ӵ�
% Hf_2 = fftshift(conj(fft(ht_2,N)));     % ���㲹����ɢ����Ҷ�任
% % ��ͼ
% H3 = figure;
% set(H3,'position',[100,100,600,450]);
% subplot(311),plot(real(Hf_2),'k')
% axis([4000 4400,-1200 1600])
% subplot(312),plot(imag(Hf_2),'k')
% axis([4000 4400,-1200 1600])
% subplot(313),plot( abs(Hf_2),'k')
% axis([4000 4400,    0 1600])
% suptitle('��ʽ�����ɵ�Ƶ��ƥ���˲���')
% % ������
% window_3 = kaiser(N,2.5)';              % ʱ��
% Window_3 = fftshift(window_3);          % Ƶ��
% % �źű任-->��ʽ��
% Hf_3 = Window_3.*exp(1j*pi*f2.^2/K);    % ���㲹����ɢ����Ҷ�任
% % ��ͼ
% H3 = figure;
% set(H3,'position',[100,100,600,450]);
% subplot(311),plot(real(Hf_3),'k')
% axis([2000 6400,-1.2 1.2])
% subplot(312),plot(imag(Hf_3),'k')
% axis([2000 6400,-1.2 1.2])
% subplot(313),plot( abs(Hf_3),'k')
% axis([2000 6400,-0.2 1.2])
% suptitle('��ʽ�����ɵ�Ƶ��ƥ���˲���')
% �źű��
Srf = fftshift(fft(srt));
% % ��ͼ
% H4 = figure;
% set(H4,'position',[100,100,600,300]);
% subplot(211),plot(real(srt),'k')
% axis([0 N,-1.2 1.2])
% subplot(212),plot(abs(Srf),'k')
% axis([4000 4400,-50 1600])
% suptitle('�ز��źŵ�Ƶ�׷���')
% % �źű��
% Soutf_1 = Srf.*Hf_1;
% soutt_1 = ifft(ifftshift(Soutf_1));     % ��ʽһƥ���˲����
% soutt_1_nor = abs(soutt_1)./max(abs(soutt_1));               % ��һ��
% soutt_1_log = 20*log10(abs(soutt_1)./max(abs(soutt_1))+eps); % ������
% Soutf_2 = Srf.*Hf_2;
% soutt_2 = ifft(ifftshift(Soutf_2));     % ��ʽ��ƥ���˲����
% soutt_2_nor = abs(soutt_2)./max(abs(soutt_2));               % ��һ��
% soutt_2_log = 20*log10(abs(soutt_2)./max(abs(soutt_2))+eps); % ������
% Soutf_3 = Srf.*Hf_3;
% soutt_3 = ifft(ifftshift(Soutf_3));     % ��ʽ��ƥ���˲���� 
% soutt_3_nor = abs(soutt_3)./max(abs(soutt_3));               % ��һ��
% soutt_3_log = 20*log10(abs(soutt_3)./max(abs(soutt_3))+eps); % ������
% % ��������-->IRW
% [irw1,a1,b1] = get_irw(fftshift(soutt_1_nor));irw11 = irw1*dt;
% [irw2,a2,b2] = get_irw(fftshift(soutt_2_nor));irw12 = irw2*dt;
% [irw3,a3,b3] = get_irw(soutt_3_nor);irw13 = irw3*dt;
% % ��������-->ISLR
% [islr1] = get_islr(fftshift(soutt_1_nor),5);
% [islr2] = get_islr(fftshift(soutt_2_nor),5);
% [islr3] = get_islr(soutt_3_nor,5);
% % ��ͼ                                        
% H5 = figure;
% set(H5,'position',[100,100,600,600]);
% subplot(411),plot(real(srt),'k')
% axis([0 N,-1.2 1.2])
% subplot(412),plot(fftshift(soutt_1_nor),'k')
% axis([0 N,-0.1,1.2])
% line([4110,4110],[-0.1,1.2],'Color','r','LineStyle','--')
% line([4290,4290],[-0.1,1.2],'Color','r','LineStyle','--')
% text(1500,0.7,['IRW= ',num2str(irw11*1e+6),'\mus'],'HorizontalAlignment','center')
% text(7000,0.7,['ISLR= ',num2str(islr1),'dB'],'HorizontalAlignment','center')
% subplot(413),plot(fftshift(soutt_2_nor),'k')
% axis([0 N,-0.1,1.2])
% line([4111,4111],[-0.1,1.2],'Color','r','LineStyle','--')
% line([4291,4291],[-0.1,1.2],'Color','r','LineStyle','--')
% text(1500,0.7,['IRW= ',num2str(irw12*1e+6),'\mus'],'HorizontalAlignment','center')
% text(7000,0.7,['ISLR= ',num2str(islr2),'dB'],'HorizontalAlignment','center')
% subplot(414),plot(soutt_3_nor,'k')
% axis([0 N,-0.1,1.2])
% line([4113,4113],[-0.1,1.2],'Color','r','LineStyle','--')
% line([4289,4289],[-0.1,1.2],'Color','r','LineStyle','--')
% text(1500,0.7,['IRW= ',num2str(irw13*1e+6),'\mus'],'HorizontalAlignment','center')
% text(7000,0.7,['ISLR= ',num2str(islr3),'dB'],'HorizontalAlignment','center')
% % ��������-->PSLR
% [pslr1] = get_pslr(fftshift(soutt_1_log));
% [pslr2] = get_pslr(fftshift(soutt_2_log));
% [pslr3] = get_pslr(soutt_3_log);
% % ��ͼ                                        
% H6 = figure;
% set(H6,'position',[100,100,600,600]);
% subplot(411),plot(real(srt),'k')
% axis([0 N,-1.2 1.2])
% subplot(412),plot(fftshift(soutt_1_log),'k')
% axis([0 N,-35 0])
% text(7000,-10,['PSLR= ',num2str(pslr1),'dB'],'HorizontalAlignment','center')
% subplot(413),plot(fftshift(soutt_2_log),'k')
% axis([0 N,-35 0])
% text(7000,-10,['PSLR= ',num2str(pslr2),'dB'],'HorizontalAlignment','center')
% subplot(414),plot(soutt_3_log,'k')
% axis([0 N,-35 0])
% text(7000,-10,['PSLR= ',num2str(pslr3),'dB'],'HorizontalAlignment','center')
%%
% ��������
QPE = linspace(0,0.8*pi,N);            % ������λ���
dk = QPE/(pi*(T/2)^2);                 % ��Ƶ�����
% ��������
IRW1  = zeros(1,N);                    % ��ʼ���弤��Ӧ���
PSLR1 = zeros(1,N);                    % ��ʼ����ֵ�԰��
ISLR1 = zeros(1,N);                    % ��ʼ�������԰��
IRW2  = zeros(1,N);                    % ��ʼ���弤��Ӧ���
PSLR2 = zeros(1,N);                    % ��ʼ����ֵ�԰��
ISLR2 = zeros(1,N);                    % ��ʼ�������԰��
IRW3  = zeros(1,N);                    % ��ʼ���弤��Ӧ���
PSLR3 = zeros(1,N);                    % ��ʼ����ֵ�԰��
ISLR3 = zeros(1,N);                    % ��ʼ�������԰��
% ��ʾ����ʱ��
tic
% ��ʾ��������
wait_title = waitbar(0,'Program Initializing ...');                                            
% ��ͼ
H8 = figure;
set(H8,'position',[100,100,600,350]);
% ѭ������
pause(1);
for i = 1:N
    % ��������
    B_dk = (K+dk(i))*T;
    F_dk = alpha_os*B_dk;
    df_dk = F_dk/N;
    f3 = -F_dk/2+f_c:df_dk:F_dk/2+f_c-df_dk;           % Ƶ�ʱ���
    % �źű��                                                                 
    st_dk = exp(1j*pi*(K+dk(i))*t1.^2);                  
    Sf_dk = fftshift(fft(st_dk));
    % �źű任-->Ƶ��ʽһ
    window_1 = kaiser(N,2.5)';                         % ʱ��
    Window_1 = fftshift(window_1);                     % Ƶ��
    ht_dk_1 = conj(fliplr(st_dk));                     % ��ʱ�䷴�޺�ĸ�������ȡ������
    ht_window_dk_1 = window_1.*ht_dk_1;                % �Ӵ�
    Hf_dk_1 = fftshift(fft(ht_window_dk_1,N));         % ���㲹����ɢ����Ҷ�任
    % �źű任-->Ƶ��ʽ��
    window_2 = kaiser(N,2.5)';                         % ʱ��
    Window_2 = fftshift(window_2);                     % Ƶ��
    ht_dk_2 = st_dk;                                   % �����ź�
    ht_window_dk_2 = window_2.*ht_dk_2;                % �Ӵ�
    Hf_dk_2 = fftshift(conj(fft(ht_window_dk_2,N)));   % ���㲹����ɢ����Ҷ�任
    % �źű任-->Ƶ��ʽ��
    window_3 = kaiser(N,2.5)';                         % ʱ��
    Window_3 = fftshift(window_3);                     % Ƶ��
    Hf_dk_3 = Window_3.*exp(1j*pi*f3.^2/(K+dk(i)));    % ���㲹����ɢ����Ҷ�任
% ��������-->��ʽһ                                         
    Soutf_dk_1 = Srf.*Hf_dk_1;
    soutt_dk_1 = ifft(ifftshift(Soutf_dk_1));          % ��ʽһƥ���˲���� 
    soutt_dk_1_nor = abs(soutt_dk_1)./max(abs(soutt_dk_1));               % ��һ��
    soutt_dk_1_log = 20*log10(abs(soutt_dk_1)./max(abs(soutt_dk_1))+eps); % ������
    % ��������-->IRW
    [irw_dk_1,~,~] = get_irw(fftshift(soutt_dk_1_nor));
    IRW1(i) = irw_dk_1;
    % ��������-->PSLR
    [pslr_dk_1] = get_pslr(fftshift(soutt_dk_1_log));
    PSLR1(i) = pslr_dk_1;
    % ��������-->ISLR
    [islr_dk_1] = get_islr(fftshift(soutt_dk_1_nor),5);
    ISLR1(i) = islr_dk_1;
     % ��ͼ
    if i == 2990
       figure(H8);
       subplot(121),plot(fftshift(soutt_dk_1_log),'k')
       axis([3600 4800,-25 -15])
       title('(a)|QPE|��С��0.28\pi����'),xlabel('����������'),ylabel('����/dB')
    end
    if i == 3100
       figure(H8);
       subplot(122),plot(fftshift(soutt_dk_1_log),'k')
       axis([3600 4800,-25 -15])
       title('(b)|QPE|�Դ���0.28\pi����'),xlabel('����������'),ylabel('����/dB')
       suptitle('ͼ3.15 ����԰�λ�ò�ͬ����������Ӧ����ʱ�����')
    end
% % ��������-->��ʽ��                                        
%     Soutf_dk_2 = Srf.*Hf_dk_2;
%     soutt_dk_2 = ifft(ifftshift(Soutf_dk_2));          % ��ʽ��ƥ���˲���� 
%     soutt_dk_2_nor = abs(soutt_dk_2)./max(abs(soutt_dk_2));               % ��һ��
%     soutt_dk_2_log = 20*log10(abs(soutt_dk_2)./max(abs(soutt_dk_2))+eps); % ������
%     % ��������-->IRW
%     [irw_dk_2,~,~] = get_irw(fftshift(soutt_dk_2_nor));
%     IRW2(i) = irw_dk_2;
%     % ��������-->PSLR
%     [pslr_dk_2] = get_pslr(fftshift(soutt_dk_2_log));
%     PSLR2(i) = pslr_dk_2;
%     % ��������-->ISLR
%     [islr_dk_2] = get_islr(fftshift(soutt_dk_2_nor),5);
%     ISLR2(i) = islr_dk_2;
% % ��������-->��ʽ��                                         
%     Soutf_dk_3 = Srf.*Hf_dk_3;
%     soutt_dk_3 = ifft(ifftshift(Soutf_dk_3));          % ��ʽ��ƥ���˲���� 
%     soutt_dk_3_nor = abs(soutt_dk_3)./max(abs(soutt_dk_3));               % ��һ��
%     soutt_dk_3_log = 20*log10(abs(soutt_dk_3)./max(abs(soutt_dk_3))+eps); % ������
%     % ��������-->IRW
%     [irw_dk_3,~,~] = get_irw(soutt_dk_3_nor);
%     IRW3(i) = irw_dk_3;
%     % ��������-->PSLR
%     [pslr_dk_3] = get_pslr(soutt_dk_3_log);
%     PSLR3(i) = pslr_dk_3;
%     % ��������-->ISLR
%     [islr_dk_3] = get_islr(soutt_dk_3_nor,5);
%     ISLR3(i) = islr_dk_3;           
    % ��������
    pause(0);
    Time_Trans   = Time_Transform(toc);
    Time_Disp    = Time_Display(Time_Trans);
    Display_Data = num2str(roundn(i/N*100,-1));
    Display_Str  = ['Computation Progress ... ',Display_Data,'%',' --- ',...
                    'Using Time: ',Time_Disp];

    waitbar(i/N,wait_title,Display_Str)
end
pause(1);
close(wait_title);
toc
% % ��ͼ
% H7 = figure;
% set(H7,'position',[50,50,900,900]);
% subplot(331),plot(QPE/pi,(IRW1-IRW1(1))/IRW1(1)*100,'k')
% title('(a)IRW'),xlabel('|QPE|(\pi����)'),ylabel('չ��ٷֱ�')
% subplot(332),plot(QPE/pi,PSLR1,'k')
% title('(b)PSLR'),xlabel('|QPE|(\pi����)'),ylabel('PSLR/dB')
% subplot(333),plot(QPE/pi,ISLR1,'k')
% title('(c)ISLR'),xlabel('|QPE|(\pi����)'),ylabel('ISLR/dB')
% subplot(334),plot(QPE/pi,(IRW2-IRW2(1))/IRW2(1)*100,'k')
% title('(a)IRW'),xlabel('|QPE|(\pi����)'),ylabel('չ��ٷֱ�')
% subplot(335),plot(QPE/pi,PSLR2,'k')
% title('(b)PSLR'),xlabel('|QPE|(\pi����)'),ylabel('PSLR/dB')
% subplot(336),plot(QPE/pi,ISLR2,'k')
% title('(c)ISLR'),xlabel('|QPE|(\pi����)'),ylabel('ISLR/dB')
% subplot(337),plot(QPE/pi,(IRW3-IRW3(1))/IRW3(1)*100,'k')
% title('(a)IRW'),xlabel('|QPE|(\pi����)'),ylabel('չ��ٷֱ�')
% subplot(338),plot(QPE/pi,PSLR3,'k')
% title('(b)PSLR'),xlabel('|QPE|(\pi����)'),ylabel('PSLR/dB')
% subplot(339),plot(QPE/pi,ISLR3,'k')
% title('(c)ISLR'),xlabel('|QPE|(\pi����)'),ylabel('ISLR/dB')
% suptitle('��\beta=2.5ʱ��IRW��PSLR��ISLR��QPE֮��Ĺ�ϵ')
%% ��ȡ�����Ӧ���
function [irw,locleft,locright] = get_irw(Af)
    % �ҵ�Af�����λ��
    [~,locmax] = max(Af);
    % �ҵ�locmax�����ӽ�-3dB��λ��
    [~,locleft] = min(abs(Af(1:locmax-1)/max(abs(Af(1:locmax-1)))-0.707));
    % �ҵ�locmax�ұ���ӽ�-3dB��λ��
    [~,locright] = min(abs(Af(locmax+1:end)/max(abs(Af(locmax+1:end)))-0.707));
    locright = locright + locmax;
    % �õ�3dB�������
    irw = locright-locleft;
end
%% ��ȡ��ֵ�԰��
function [pslr] = get_pslr(Af)
    % �ҵ����е�pesks
    peaks = findpeaks(Af);
    % ��peaks��������
    peaks = sort(peaks,'descend');
    % �õ���һ�԰�
    pslr = peaks(2);
end
%% ��ȡ�����԰��
function [islr] = get_islr(Af,Nr)
    % �ҵ�Af�����λ��
    [~,locmax] = max(Af);
    % �ҵ�locmax�����ӽ�-3dB��λ��
    [~,locleft] = min(abs(Af(1:locmax-1)/max(abs(Af(1:locmax-1)))-0.707));
    % �ҵ�locmax�ұ���ӽ�-3dB��λ��
    [~,locright] = min(abs(Af(locmax+1:end)/max(abs(Af(locmax+1:end)))-0.707));
    locright = locright + locmax;
    % �����ܹ���
    P_total = sum(Af(locleft-Nr:locright+Nr).^2);
    % �������깦��
    P_main = sum(Af(locleft:locright).^2);
    % һά�����԰��
    islr = 10*log10((P_total-P_main)./P_main);
end
%% ʱ��ת������
function y = Time_Transform(u)
    Time_in = u(1);
    Hours   = fix(Time_in/3600);
    Minutes = fix((Time_in-Hours*3600)/60);
    Seconds = fix(Time_in-Hours*3600-Minutes*60);
    Time_out = [Hours Minutes Seconds];
    y = Time_out;
end
%% ʱ����ʾ����
function y = Time_Display(u)
    Hours   = u(1);
    Minutes = u(2);
    Seconds = u(3);
    
    if Hours == 0
        if Minutes == 0
            Time_out = [num2str(Seconds),'','s'];
        else
            Time_out = [num2str(Minutes),'','m','',...
                            num2str(Seconds),'','s'];
        end 
    else
        Time_out = [num2str(  Hours),'','h','',...
                        num2str(Minutes),'','m','',...
                        num2str(Seconds),'','s'];
    end
    y = Time_out;
end