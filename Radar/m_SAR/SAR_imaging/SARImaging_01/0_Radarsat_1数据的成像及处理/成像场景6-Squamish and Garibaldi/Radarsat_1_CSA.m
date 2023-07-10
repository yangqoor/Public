%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                       Radarsat_1 ����������
%                             CSA ����
%
%
%                               WD
%                       2014.10.31. 23:40 p.m.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����˵����
% �������ǣ�  Radarsat_1_CSA.m
%
% ��1��ԭʼ����˵����
% �ļ����е� data_1 �� data_2 ���Ѿ��������з����õ���ԭʼ���ݣ�
% ����ֱ�ӽ��к�������
% ----------------------------------------------------------
% ʹ���ֳɵĳ���compute.azim.spectra.m���ж������ݵķ�����
% ���ú��� 'laod_DATA_block.m'��ʵ��
%                - reads /loads data for a block 
%                - converts to floating point
%                - compansates for the receiver attenuation
% ���� b -- ��Ҫ��������ȡ���ĸ�����
%                - b = 1 , from CDdata1
%                - b = 2 , from CDdata2
% �õ�����Ҫ�����ݣ�Ҳ������ֱ�ӽ��к��� processing ������ data��
% ----------------------------------------------------------
% ��ˣ��ļ����е� data_1��data_2 �ֱ��Ƿ���1�ͷ���2�����ݣ��������±�Ƶ��
%       ת��Ϊ�˸�������������AGC���油�������ת��Ϊ��double˫���ȸ�������
%       ��ˣ�ֱ���������������ݾͿ��Խ��к�������
% ע��
%   ���ﻹ������һ������ԭʼ���ݽ��в��㣬�ٽ��к��������������Ƿǳ���Ҫ�ģ�����
%
% ��2�� ���ļ����л���һ���ļ���CD_run_params
%           �����������Ƿ�������Ҫ�õ���������ֱ�����뼴�ɡ�
%
% ��3���������˵����
%       ��CSA�ĵ�Ŀ������޸Ķ�����
%
% ��4���������̣�
%   ����ԭʼ����
%   ����������λ��FFT���任������������򣬽��С�����RCMC��
%   ��������������FFT���任����άƵ�򣬽��С�����ѹ��������SRC������һ��RCMC��
%   ��������������IFFT���任������������򣬽��С���λѹ�����͡�������λУ����
%   ����������λ��IFFT���ص�ͼ���򣬳��������
%
% ��5���ֱ���������ַ�ʽ������ɰߣ�
%       a��������3*3�Ĵ��ڣ����л���ƽ������������ɰߡ���
%       b�����С�4�ӵ��ӡ�����������ɰߣ�
%
% �������޸Ľ�ֹ���� 2014.10.31. 23:40 p.m.

%%
clear;
clc;
close all;
% ----------------------------------------------------------
% �õ����Խ��к����źŴ����ԭʼ����data��s_echo��
% ----------------------------------------------------------
% �������
load CD_run_params;

% ��������
b = 1;              % ѡ�������һ���ֳ���
% b = 1����Է���1����
% b = 2����Է���2����
% b = 3������������ݣ�����1�ͷ���2������

if b == 1
    load data_1;                % ����1������
    s_echo = data_1;            % ԭʼ���ݼ�Ϊs_echo�����ں�������
end
clear data_1;                   % ���data_1�����ڳ��ڴ�

if b == 2
    load data_2;                % ����2������
    s_echo = data_2;            % ԭʼ���ݼ�Ϊs_echo�����ں�������
end
clear data_2;                   % ���data_2�����ڳ��ڴ�

if b == 3
    load data_1;                % ����1������    
    s_echo1 = data_1;
    load data_2;                % ����2������
    s_echo2 = data_2;
    s_echo = [s_echo1;s_echo2]; % ������1�ͷ���2�����ݺϳ��������ݿ飬���ڳ���
end
clear data_1;clear data_2;clear s_echo1;clear s_echo2;

%{
% ��ͼ��ʾ
figure;
imagesc(abs(s_echo));
title('ԭʼ����');              % ԭʼ�ز����ݣ�δ�����ķ���ͼ��
% colormap(gray);
%}

%%
% --------------------------------------------------------------------
% ����һЩ����
% --------------------------------------------------------------------
Kr = -Kr;                       % ����Ƶ��Kr�ĳɸ�ֵ
BW_range = 30.111e+06;          % ������
Vr = 7062;                      % ��Ч�״�����
Ka = 1733;                      % ��λ��Ƶ��
fnc = -6900;                    % ����������Ƶ��
Fa = PRF;                       % ��λ�������
lamda = c/f0;                   % ����
T_start = 6.5959e-03;           % ���ݴ���ʼʱ��

Nr = round(Tr*Fr);              % ���Ե�Ƶ�źŲ�������
Nrg = Nrg_cells;                % �����߲�������
if b == 1 || b == 2
    Naz = Nrg_lines_blk;     	% ÿһ�����ݿ�ľ�������
else
    Naz = Nrg_lines;          	% �������ݿ飬�ܹ��ľ�������
end
NFFT_r = Nrg;                   % ������FFT����
NFFT_a = Naz;                   % ��λ��FFT����

R_ref = R0;                     % �ο�Ŀ��ѡ�ڳ������ģ������б��Ϊ R_ref  
fn_ref = fnc;                   % �ο�Ŀ��Ķ���������Ƶ��

%%
%
% --------------------------------------------------------------------
% ��ԭʼ���ݽ��в���
% --------------------------------------------------------------------
if b == 1 || b == 2 
    data = zeros(1*2048,3000);
else
    data = zeros(2*2048,3000);
end
data(1:Naz,1:Nrg) = s_echo;
clear s_echo;
s_echo = data;
clear data;
[Naz,Nrg] = size(s_echo);

NFFT_r = Nrg;               	% ������FFT����
NFFT_a = Naz;                   % ��λ��FFT����

% ��ͼ��ʾ
figure;
imagesc(abs(s_echo));
title('������ԭʼ����');       % ������ԭʼ�ز����ݣ�δ�����ķ���ͼ��
%}

%%
% --------------------------------------------------------------------
% ���루��λ����ʱ�䣬Ƶ����ض���
% --------------------------------------------------------------------
% ����
tr = 2*R0/c + ( -Nrg/2 : (Nrg/2-1) )/Fr;                % ����ʱ����
fr = ( -NFFT_r/2 : NFFT_r/2-1 )*( Fr/NFFT_r );          % ����Ƶ����
% ��λ
ta = ( -Naz/2: Naz/2-1 )/Fa;                            % ��λʱ����
fa = fnc + fftshift( -NFFT_a/2 : NFFT_a/2-1 )*( Fa/NFFT_a );	% ��λƵ����

% ���ɾ��루��λ��ʱ�䣨Ƶ�ʣ�����
tr_mtx = ones(Naz,1)*tr;    % ����ʱ������󣬴�С��Naz*Nrg
ta_mtx = ta.'*ones(1,Nrg);  % ��λʱ������󣬴�С��Naz*Nrg
fr_mtx = ones(Naz,1)*fr;    % ����Ƶ������󣬴�С��Naz*Nrg
fa_mtx = fa.'*ones(1,Nrg);  % ��λƵ������󣬴�С��Naz*Nrg

%%
% --------------------------------------------------------------------
% �任������������򣬽��С�����RCMC��
% --------------------------------------------------------------------
s_rd = s_echo.*exp(-1j*2*pi*fnc.*(ta.'*ones(1,Nrg))); 	% ���ݰ���
S_RD = fft(s_rd,NFFT_a,1);  % ���з�λ����Ҷ�任���õ������������Ƶ��

D_fn_Vr = sqrt(1-lamda^2.*(fa.').^2./(4*Vr^2));     % ��б�ӽ��µ��㶯���ӣ�������
D_fn_Vr_mtx = D_fn_Vr*ones(1,Nrg);  % �γɾ��󣬴�С��Nrg*Naz

D_fn_ref_Vr = sqrt(1-lamda^2*fn_ref^2/(4*Vr^2));    % �ο�Ƶ��fn_ref�����㶯���ӣ��ǳ�����

K_src = 2*Vr^2*f0^3.*D_fn_Vr.^3./(c*R_ref*(fa.').^2);   % ��������ʹ��R_ref����ֵ 
K_src_mtx = K_src*ones(1,Nrg);  % �γɾ���
Km = Kr./(1-Kr./K_src_mtx);     % �������Ǳ任�������������ľ����Ƶ�ʡ�
                                % ʹ�� R_ref ����ֵ

% �������� ��귽�� s_sc
s_sc = exp(1j*pi.*Km.*(D_fn_ref_Vr./D_fn_Vr_mtx-1).*(tr_mtx-2*R_ref./(c.*D_fn_Vr_mtx)).^2);

% ���潫�������������ź����귽����ˣ�ʵ�֡�����RCMC��
S_RD_1 = S_RD.*s_sc;            % ��λ��ˣ�ʵ�֡�����RCMC��

disp(' �������������ɡ�����RCMC�� ');
%{
% ��ͼ
figure;
imagesc(abs(S_RD));
title('ԭʼ���ݱ任������������򣬷���');
figure;
imagesc(abs(S_RD_1));
title('����������򣬲���RCMC�󣬷���');
%}
clear S_RD;

%% 
% --------------------------------------------------------------------
% �任����άƵ�򣬽��С�����ѹ����SRC��һ��RCMC��
% --------------------------------------------------------------------
S_2df_1 = fft(S_RD_1,NFFT_r,2);         % ���о�����FFT���任����άƵ�򡣾�����Ƶ������

% ��ɾ���ѹ����SRC��һ��RCMC��������λ�������˲���Ϊ��
H1 = exp(1j*pi.*D_fn_Vr_mtx./(D_fn_ref_Vr.*Km).*fr_mtx.^2)...
    .*exp(1j*4*pi/c.*(1./D_fn_Vr_mtx-1/D_fn_ref_Vr).*R_ref.*fr_mtx);
% �����H1������Ƶ������
W_ref = ones(Naz,1)*(kaiser(Nrg,3).');	% �����򣬹���Kaiser������Ϊ������ʽ��������Ƶ�����ġ�
% H1 = W_ref.*H1;             % �������ƽ�������������԰꣬������Ƶ�����ġ�
% ����ͨ��fftshift��H1�ľ�����Ƶ����������
H1 = fftshift(H1,2);        % ���Ұ�߻�����������Ƶ�����ˡ�

S_2df_2 = S_2df_1.*H1;    	% �ڶ�άƵ����λ��ˣ�ʵ�־���ѹ����SRC��һ��RCMC

S_RD_2 = ifft(S_2df_2,NFFT_r,2);    % ���о���IFFT���ص������������������о��봦��

disp(' �ڶ�άƵ�������λ��ˣ���ɾ���ѹ����SRC��һ��RCMC�󣬻ص������������ ');
%{
% ��ͼ
figure;
imagesc(abs(S_2df_1));
title('�任����άƵ��');
figure;
imagesc(abs(S_2df_2));
title('��λ��ˣ�ʵ�־���ѹ����SRC��һ��RCMC�󣬶�άƵ��');
%
figure;
imagesc(abs(S_RD_2));
title('��ɾ���ѹ����SRC��һ��RCMC�󣬾����������');
%}
clear S_RD_1;
clear S_2df_1;
clear H1;
clear S_2df_2;

%%
% --------------------------------------------------------------------
% �������������ɡ���λѹ�����͡�������λУ����
% --------------------------------------------------------------------
R0_RCMC = (c/2).*tr;   % ������߱仯��R0����ΪR0_RCMC���������㷽λMF��

% ���ɷ�λ��ƥ���˲���
Haz = exp(1j*4*pi.*(D_fn_Vr*R0_RCMC).*f0./c);       % ��λMF

% ������λУ����
H2 = exp(-1j*4*pi.*Km./(c^2).*(1-D_fn_Vr_mtx./D_fn_ref_Vr)...
    .*((1./D_fn_Vr)*R0_RCMC-R_ref./D_fn_Vr_mtx).^2); 	% ������λУ����

% ���������λ��ˣ��ھ����������ͬʱ��ɷ�λMF�͸�����λУ��
S_RD_3 = S_RD_2.*Haz.*H2;           % �������������λ���

% ���ͨ��IFFT�ص�ͼ������ɷ�δ����
s_image = ifft(S_RD_3,NFFT_a,1); 	% ��ɳ�����̣��õ�������Ϊ��s_image

disp(' ��ɡ���λѹ�����͡�������λУ���� ');
disp(' ������� ');
%{
% ��ͼ
figure;
imagesc(abs(S_RD_3));
title('����������򣬽�������λ��˺󣨷�λMF�͸�����λУ����');
%}
clear S_RD_2;
clear Haz;
clear H2;
% clear S_RD_3;     % ������ж��ӵ�����Ҫ�����������Ƶ�ף�������ﲻҪ�����

%% 
% ��������Ƚ��з����Ա任����С�Աȶ�
sout = abs(s_image)/max(max(abs(s_image)));
G = 20*log10(sout+eps);             % dB��ʾ
clim = [-55 0];                     % ��̬��ʾ��Χ
%{
figure;
imagesc(((0:Nrg-1)+first_rg_cell)/Fr*c/2+R0,((0:Naz-1)+first_rg_line)/Fa*Vr,G,clim);
axis xy;
title('RADARSAT-1���ݣ�ʹ��CS�㷨��������')
xlabel('Range(m)')
ylabel('Azimuth(m)')
% colormap(gray);
%}

% ��ͼ��������λ��
%   ����CSA�㷨�ĳ���λ����ѹ���ο�Ƶ�ʶ�Ӧ�ľ��뵥Ԫ������ѹ��������մ�
%   �õ���ͼ���������ѹ��������գ�������ƫ�Ƶ�
% ��˽�������������λ
% ���⣬��Ҫ�������°�߻���
% �������ϲ����󣬵õ������
tmp = round(2*(R0/D_fn_ref_Vr-R0)/c*Fr);
s_tmp(:,1:Nrg-tmp+1) = G(:,tmp:end);
s_tmp(:,Nrg-tmp+1+1:Nrg) = G(:,1:tmp-1);

if b == 1 || b == 2 
    % �Ե�һ���������磬����1���߷���2����ʹ���ⲿ�ֳ�������ʾͼ��
    figure;
    imagesc(((0:Nrg-1)+first_rg_cell)/Fr*c/2+R0,((0:Naz-1)+first_rg_line)/Fa*Vr,fftshift(s_tmp,1),clim);
    axis xy;
    title('RADARSAT-1���ݣ�ʹ��CS�㷨��������')
    xlabel('Range(m)')
    ylabel('Azimuth(m)')
    colormap(gray)
end

if b == 3
    % ����������һ�����ʱ��ʹ���ⲿ������ʾͼ��
    % �����ǣ������²��ֽ���һ������λ
    %       �� ԭ����ͼ��ĵ�2900�е����һ��Ӧ������ͼ����ͷ ��
    ss_tmp(1:Naz-2900+1,:) = s_tmp(2900:Naz,:);
    ss_tmp(Naz-2900+1+1:Naz,:) = s_tmp(1:2900-1,:);
    figure;
    imagesc(((0:Nrg-1)+first_rg_cell)/Fr*c/2+R0,((0:Naz-1)+first_rg_line)/Fa*Vr,ss_tmp,clim);
    axis xy;
    title('RADARSAT-1���ݣ�ʹ��CS�㷨��������')
    xlabel('Range(m)')
    ylabel('Azimuth(m)')
    colormap(gray)
end


%%
% --------------------------------------------------------------------
% ���� 3*3 �Ĵ��ڣ����л���ƽ��
% �Դ���������ɰ�����
% --------------------------------------------------------------------
s_image_look = zeros(Naz,Nrg);      % ������Ż���ƽ����Ľ��

h = waitbar(0,'����3*3�Ĵ��ڣ����л���ƽ����please wait');
for p = 1 : Naz
    for q = 1 : Nrg
        count = 0;
        s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p,q));
        count = count + 1;
        if p>2 && p<(Naz-1) && q>2 && q<(Nrg-1)
            s_image_look(p,q) = s_image_look(p,q)+abs(s_image(p-1,q-1))+...
                abs(s_image(p-1,q))+abs(s_image(p-1,q+1))+abs(s_image(p,q-1))+...
                abs(s_image(p,q+1))+abs(s_image(p+1,q-1))+abs(s_image(p+1,q+1))+...
                abs(s_image(p+1,q+1));
            count = 9;
        else
            if (p-1) > 0
                s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p-1,q));
                count = count + 1;
                if (q-1) > 0
                    s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p-1,q-1));
                    count = count+1;
                end
                if (q+1) <= Nrg
                    s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p-1,q+1));
                    count = count+1;
                end
            end

            if (p+1) <= Naz
                s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p+1,q));
                count = count + 1;
                if (q-1) > 0
                    s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p+1,q-1));
                    count = count+1;
                end
                if (q+1) <= Nrg
                    s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p+1,q+1));
                    count = count+1;
                end
            end
            
            if (q-1) > 0
                s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p,q-1));
                count = count+1;
            end
            
            if (q+1) <= Nrg
                s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p,q+1));
                count = count+1;
            end
        end
        s_image_look(p,q) = s_image_look(p,q)/count;    % ȡƽ��
    end
    waitbar(p/Naz);
end
close(h);
% ����Ϊֹ�����ǵõ��˻���ƽ����Ľ���� s_image_look
disp('���� 3*3 �Ĵ��ڣ����л���ƽ�����õ�������ɰߺ�Ľ��');

% ���������ʾ
clear sout;clear G;clear clim;
clear tmp;clear s_tmp;clear ss_tmp
% ������ɰߺ�Ľ��
% �����Ƚ��з����Ա任����С�Աȶȣ���ʾͼ��
sout = abs(s_image_look)/max(max(abs(s_image_look)));
G = 20*log10(sout+eps);             % dB��ʾ
clim = [-55 0];                     % ��̬��ʾ��Χ

tmp = round(2*(R0/D_fn_ref_Vr-R0)/c*Fr);
s_tmp(:,1:Nrg-tmp+1) = G(:,tmp:end);
s_tmp(:,Nrg-tmp+1+1:Nrg) = G(:,1:tmp-1);
if b == 1 || b == 2
    % �Ե�һ���������磬����1���߷���2����ʹ���ⲿ�ֳ�������ʾͼ��
    figure;
    imagesc(((0:Nrg-1)+first_rg_cell)/Fr*c/2+R0,((0:Naz-1)+first_rg_line)/Fa*Vr,fftshift(s_tmp,1),clim);
    axis xy;
    title('����ƽ����Ľ��');
    xlabel('Range(m)')
    ylabel('Azimuth(m)')
    colormap(gray)
end

if b == 3
    % ����������һ�����ʱ��ʹ���ⲿ��������
    % �����ǣ������²��ֽ���һ������λ
    %       �� ԭ����ͼ��ĵ�2900�е����һ��Ӧ������ͼ����ͷ ��
    ss_tmp(1:Naz-2900+1,:) = s_tmp(2900:Naz,:);
    ss_tmp(Naz-2900+1+1:Naz,:) = s_tmp(1:2900-1,:);
    figure;
    imagesc(((0:Nrg-1)+first_rg_cell)/Fr*c/2+R0,((0:Naz-1)+first_rg_line)/Fa*Vr,ss_tmp,clim);
    axis xy;
    title('����ƽ����Ľ��');
    xlabel('Range(m)')
    ylabel('Azimuth(m)')
    colormap(gray)
end


%% 
% --------------------------------------------------------------------
% ���С�4�ӵ��ӡ�
% ������ɰ�
% --------------------------------------------------------------------
S_rd_c_fftshift = fftshift(S_RD_3,1);

% ����1
if b == 1 || b == 2
    S_rd_c_1 = S_rd_c_fftshift(1:569,:);
end
if b == 3
    S_rd_c_1 = S_rd_c_fftshift(1:1135,:);
end
s_ac1 = ifft(S_rd_c_1);
% figure;
% imagesc(abs(s_ac1));
% title('����1');

% ����2
if b == 1 || b == 2
    S_rd_c_2 = S_rd_c_fftshift(494:1062,:);
end
if b == 3
    S_rd_c_2 = S_rd_c_fftshift(988:2122,:);
end
s_ac2 = ifft(S_rd_c_2);
% figure;
% imagesc(abs(s_ac2));
% title('����2');

% ����3
if b == 1 || b == 2
    S_rd_c_3 = S_rd_c_fftshift(987:1555,:);
end
if b == 3
    S_rd_c_3 = S_rd_c_fftshift(1975:3109,:);
end
s_ac3 = ifft(S_rd_c_3);
% figure;
% imagesc(abs(s_ac3));
% title('����3');

% ����4
if b == 1 || b == 2
    S_rd_c_4 = S_rd_c_fftshift(1480:2048,:);
end
if b == 3
    S_rd_c_4 = S_rd_c_fftshift(2962:4096,:);
end
s_ac4 = ifft(S_rd_c_4);
% figure;
% imagesc(abs(s_ac4));
% title('����4');

% �������
s_ac_look = sqrt(abs(s_ac1).^2 + abs(s_ac2).^2 + abs(s_ac3).^2 + abs(s_ac4).^2);   
% �����ӷ���ƽ������ٿ���
% ����Ϊֹ�����ǵõ���4�ӵ��Ӻ�Ľ���� s_ac_look
disp('������4�ӵ��ӣ��õ�������ɰߺ�Ľ��');


% ���������ʾ
clear sout;clear G;clear clim;
clear tmp;clear s_tmp;clear ss_tmp
% ������ɰߺ�Ľ��
% �����Ƚ��з����Ա任����С�Աȶȣ���ʾͼ��
sout = abs(s_ac_look)/max(max(abs(s_ac_look)));
G = 20*log10(sout+eps);             % dB��ʾ
clim = [-55 0];                     % ��̬��ʾ��Χ

[Naz1,Nrg1] = size(s_ac_look);
tmp = round(2*(R0/D_fn_ref_Vr-R0)/c*Fr);
s_tmp(:,1:Nrg1-tmp+1) = G(:,tmp:end);
s_tmp(:,Nrg1-tmp+1+1:Nrg1) = G(:,1:tmp-1);
if b == 1 || b == 2
    % �Ե�һ���������磬����1���߷���2����ʹ���ⲿ�ֳ�������ʾͼ��
    figure;
    imagesc(((0:Nrg1-1)+first_rg_cell)/Fr*c/2+R0,((0:Naz1-1)+first_rg_line)/Fa*Vr,fftshift(s_tmp,1),clim);
    axis xy;
    title('4�ӵ��Ӻ�Ľ��');
    xlabel('Range(m)')
    ylabel('Azimuth(m)')
    colormap(gray)
end

if b == 3
    % ����������һ�����ʱ��ʹ���ⲿ��������
    % �����ǣ������²��ֽ���һ������λ
    %       �� ԭ����ͼ��ĵ�780�е����һ��Ӧ������ͼ����ͷ ��
    ss_tmp(1:Naz1-780+1,:) = s_tmp(780:Naz1,:);
    ss_tmp(Naz1-780+1+1:Naz1,:) = s_tmp(1:780-1,:);
    figure;
    imagesc(((0:Nrg1-1)+first_rg_cell)/Fr*c/2+R0,((0:Naz1-1)+first_rg_line)/Fa*Vr,ss_tmp,clim);
    axis xy;
    title('4�ӵ��Ӻ�Ľ��');
    xlabel('Range(m)')
    ylabel('Azimuth(m)')
    colormap(gray)
end




