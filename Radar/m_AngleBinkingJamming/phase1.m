% ��λ�첨��ģ��
clear variables;
close all;
%% �������
%��Ų��ٶ�
c = 3e8;
%�״﷢�书��
Pt = 8e3;
% Ŀ�귽����ͷ������������
Gt = 40;
% ����ͷ������������
Gr = 40;
% ����ͷ��������
h = 0.03;
% Ŀ���״�����
rcs0 = 5;
%�״﷢����ͽ��ջ��ۺ����
ls1 = 1; ls2 = 1;
% ��Ŀ��ʼ����
R = 8e3;
% ����ͷ�ٶ�
v_r = 900;
%Ŀ���ٶ�
v_t = 300;
%�״������ظ�����
Tr = 6e-4;
%�״�����
tao = 2e-6;
%����ʱ�䲽��
fs = 1e8;
ts = 1 / fs;
% ����ʱ��
t = 0:ts:tao;
% �з����Ƶ��
fc = 1e7;
% �з�����
G = 1e6;
%Ŀ���������
rcs_k = 0;
rcs = qfmx(rcs_k, rcs0);
fd = 2 * (v_r + v_t) / h; %������Ƶ��
tr = 2 * R / c; %�ز�ʱ��
wc = 2 * pi * fc;
% ����
s = cos(2 * pi * fc * t);
fw = 8.5:0.001:15.5;
len = length(fw);

for j = 1:len
    [G_h, G_fwch] = hchwl(12, fw(j));
    % S_h_r=G*sqrt((Pt*Gt*Gr*(G_h^2)*(h)^2*rcs)/((4*pi)^3*R^4*ls1*ls2)).*s;     %��֧·
    % S_fwch_r=sign((fw-12))*G*sqrt((Pt*Gt*Gr*G_h*G_fwch*(h)^2*rcs)/((4*pi)^3*R^4*ls1*ls2)).*s;    %��λ��֧·
    A_h = G * sqrt((Pt * Gt * Gr * (G_h^2) * (h)^2 * rcs) / ((4 * pi)^3 * R^4 * ls1 * ls2));
    A_fwch = G * sqrt((Pt * Gt * Gr * G_h * G_fwch * (h)^2 * rcs) / ((4 * pi)^3 * R^4 * ls1 * ls2));
    S_h = A_h .* s; %��֧·
    S_fwch = sign((fw(j) - 12)) * A_fwch .* s; %��λ��֧·
    % S=max(abs(S_h));
    S_h_1 = S_h / A_h;
    S_fwch_1 = S_fwch / A_h;
    u(j) = xwjb_2(S_fwch_1, S_h_1, fs, tao, t, fc);
    % A=abs((A_h/A_h)-(A_fwch/A_h));
    % if A>0.5
    %    u(j)=xwjb(S_fwch_1,S_h_1,fs,tao,t,fc);
    % else
    %     u(j)=xwjb_2(S_fwch_1,S_h_1,fs,tao,t,fc);
    % end
    % if j==5000;
    %     pause;
    % end
end

f = -3.5:0.001:3.5;
figure;
plot(f, u);
% axis([-4 4 -0.3 0.3]);
grid;
xlabel('����(��)');
ylabel('����ѹ');
save shuju f u;
