%2016/12/13
%Liu Yakun

clc,clear,close all;

%%%%%%%%%%%%%%%%%%%%%%��������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C = 3e8;                  %����
Theta = 0 / 180 * pi;    %б�ӽ�
Rc = 41.7e3;              %��������б��
R0 = Rc * cos(Theta);     %���������������
lambda = 0.03;            %�����źŲ���
fc = C / lambda;          %�����ź�����Ƶ��
Tr = 2e-6;                %���� ����ʱ��
Br = 60e6;                %����
Kr = Br / Tr;             %�����Ƶ��
V = 1;                  %ƽ̨�����ٶ�
D = 5;                    %��λ�����߳���
Beta = lambda / D;        %�������
Lsar = lambda * Rc / D;   %�����Ӻϳɿ׾�����
Lsar_squint = R0 *(tan(Theta + Beta/2) - tan(Theta - Beta/2));
Tsar = Lsar_squint / V;
Dx = D / 2;
Dy = C / 2 / Br;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%��������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scene_center = [Rc*cos(Theta) Rc*sin(Theta)];
range_width = 500;
azimuth_width = 500;
Ymin = scene_center(1) - range_width/2;
Ymax = scene_center(1) + range_width/2;
Xmin = scene_center(2) - azimuth_width/2;
Xmax = scene_center(2) + azimuth_width/2;


targets = [ scene_center(1)       scene_center(2)        1
%             scene_center(1)+200   scene_center(2)        1
%             scene_center(1)-200   scene_center(2)        1
            scene_center(1)       scene_center(2)+200  1
            scene_center(1)       scene_center(2)-200  1
%             scene_center(1)+200   scene_center(2)+200  0.7
%             scene_center(1)-200   scene_center(2)-200  1
%             scene_center(1)+200   scene_center(2)-200  0.9
%             scene_center(1)-200   scene_center(2)+200  0.4
            ];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%��ʾ�����еĵ�����%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
plot(targets(:,1),targets(:,2),'b*');
xlabel('Range axis [m]');
ylabel('Azimuth axis [m]');
title('Targets in scene');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%��ʱ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ta_start = (Xmin - Ymax * tan(Theta + Beta/2)) / V;
ta_end = (Xmax - Ymin * tan(Theta - Beta/2)) / V;

Ka = -2*V^2*cos(Theta)^2/lambda/Rc;
Ba = abs(Ka*Tsar);
alpha_PRF = 1.3;

PRF =  2 * round(alpha_PRF * Ba);
Na = (ta_end - ta_start) * PRF; 
Na = 2^nextpow2(Na);

fdoc = 2 * V * sin(Theta) / lambda;
% Mamb = floor(fdoc / PRF);
% fdoc = fdoc - Mamb*PRF;
Tslow = [-Na/2:Na/2 - 1] / PRF;
distance_azimuth = Tslow * V;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%��ʱ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rnear = Ymin / cos(Theta - Beta/2);
Rfar = Ymax / cos(Theta + Beta/2);

PRFmin = Ba + 2*V*Kr*Tr*sin(Theta)/C;
RFmax = 1/(2*Tr+2*(Rfar-Rnear)/C);
Rmid = (Rnear + Rfar) / 2;
alpha_Fr = 1.2;
Fr = round(alpha_Fr * Br);
Nr = (2*(Rfar - Rnear)/C + Tr) * Fr;
Nr = 2^nextpow2(Nr);

Tfast = [-Nr/2:Nr/2 - 1]/Fr + 2 * Rmid / C;
R_range = Tfast * C / 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�ز�����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo = zeros(Na,Nr);
nTar = size(targets,1);
disp('*****************************************');
disp('������ӡ:');
disp(['��ʱ���������Ϊ:',poly2str(Na),'��']);
disp(['�����ظ�����Ƶ��Ϊ:',poly2str(PRF),'Hz']);
disp(['��ʱ���������Ϊ:',poly2str(Nr),'��']);
disp(['��ʱ�����Ƶ��Ϊ:',poly2str(Fr),'Hz']);
disp(['��λ��ϳɿ׾�����Ϊ:',poly2str(Lsar),'m']);
disp(['��λ��ֱ���Ϊ:',poly2str(Dx),'m']);
disp(['������ֱ���Ϊ:',poly2str(Dy),'m']);
disp('*****************************************');
disp('�����ز��ź�.....');
for i = 1:nTar
    range = sqrt(targets(i,1)^2 + (targets(i,2) - V*Tslow).^2);
    tau = 2 * range / C;
    D = ones(Na,1) * Tfast - tau.' * ones(1,Nr);
    phase = pi*Kr*D.^2 - 4*pi/lambda*(range.' * ones(1,Nr));
    sigma = targets(i,3);
    tci = (targets(i,2) - scene_center(2) + tan(Theta) * (targets(i,1) - scene_center(1))) / V;
    tsi = targets(i,1) * (tan(Theta + Beta/2) - tan(Theta)) / V;
    tei = targets(i,1) * (tan(Theta) - tan(Theta - Beta/2)) / V;
%     time_wave_center = (targets(i,2) - scene_center(2))/V;
    echo = echo + sigma * exp(1i * phase) .* (abs(D) < Tr/2) .* (((Tslow > (tci - tsi) & Tslow < (tci + tei)))' * ones(1,Nr));
end

R_ref = Rc;%�ο�����
fa = [-Na/2:Na/2 - 1]/Na * PRF;%��λ��Ƶ��
fr = [-Nr/2:Nr/2 - 1]/Nr * Fr;%������Ƶ��
D = sqrt(1-(lambda*fa/2/V).^2);%�㶯ϵ��
D_ref = sqrt(1 - (lambda*fdoc/2/V)^2);%�ο���λƵ�ʴ����㶯ϵ��
tau = ones(Na,1) * Tfast - 2*R_ref/C./(D' * ones(1,Nr));%������ʱ��ת��
Ksrc = 2*V^2*fc^3/C*(D'.^3 ./ fa'.^2 * ones(1,Nr)) ./ (ones(Na,1) * R_range);
Km = Kr ./ (1 - Kr./Ksrc);
Ssc = exp(1i*pi*Km .* ((D_ref./D - 1)' * ones(1,Nr)) .* tau.^2);%����RCM����

signal_rA = fftshift(fft(fftshift(echo))) .* Ssc;%�任��������������벹��RCM��λ���
signal_RA = fftshift(fft(fftshift(signal_rA).')).';%�任����άƵ��

range_match_phase = pi/D_ref *(D' * ones(1,Nr)) .* (ones(Na,1) * fr.^2) ./ Km; %����ѹ����λ
S_range = exp(1i*range_match_phase);
signal_RA_comp = signal_RA .* S_range;%��άƵ���н��о���ѹ��
bulk_rcm_phase = 4*pi/C*R_ref * ((1./D - 1/D_ref)' * ones(1,Nr)) .* (ones(Na,1) * fr);%һ��RCM��λ
S_bulk = exp(1i*bulk_rcm_phase);
signal_RA_bulk = signal_RA_comp .* S_bulk; %һ��RCMУ��

signal_RD = fftshift(ifft(fftshift(signal_RA_bulk).')).';%�任�������������
signal_RD1 = fftshift(ifft(fftshift(signal_RA_comp).')).';%�Ա�

azimuth_match_phase = 4*pi*fc/C*(ones(Na,1) * R_range) .* (D' * ones(1,Nr));%��λѹ����λ
S_azimuth = exp(1i*azimuth_match_phase);
signal_RD_comp = signal_RD .* S_azimuth;%���з�λѹ��
signal_RD_comp1 = signal_RD1 .* S_azimuth;

cor_phase = -4*pi/C^2*Km .* ((1 - D'/D_ref) * ones(1,Nr)) .* (ones(Na,1) * (R_range - R_ref).^2) ./ (D'.^2 * ones(1,Nr));%��λУ����λ
S_cor = exp(1i*cor_phase);
signal_RD_cor = signal_RD_comp .* S_cor;%��λУ��
signal_RD_cor1 = signal_RD_comp1 .* S_cor;

signal_final = fftshift(ifft(fftshift(signal_RD_cor)));
signal_final1 = fftshift(ifft(fftshift(signal_RD_cor1)));

figure;
imagesc(abs(signal_RD_comp));
colormap hot
% title('Final Signal1');
figure;
imagesc(abs(signal_final));
colormap hot
% title('Final Signal');

figure;
plot(abs(signal_final(512,:)));
title('����������');

figure;
plot(10*log(abs(signal_final(512,:)/max(signal_final(512,:)))));
title('��ֵ�԰��');


