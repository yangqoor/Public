%% 测角
clc;close all;clear all;

%%%%%%%%%%%%工作参数%%%%%%%%%%%%%%
fm = 40e6;       %采样率  40MHz
T = 500e-6;      %脉冲重复周期  500
PRF = 1/T;
t = 0:1/fm:T-1/fm;
M = 32;            %发射脉冲数/脉冲积累数
fm1 = fm/4;
N_FFT = 2048;
f_x = -fm1/2:fm1/N_FFT:fm1/2-fm1/N_FFT;
t_x = 0:1/fm1:(N_FFT-1)/fm1;
t_x_ca_cut = 0:1/fm1:(107-1)/fm1;
f_x_ca = -PRF/2:PRF/M:PRF/2-PRF/M;

%%%%%%%%%%%%和平面%%%%%%%%%%%%%%
load CF_SUM_PC_data_yjgz.dat;
N = 107;
CF_SUM_PC_data_H_re = CF_SUM_PC_data_yjgz(1:2:end);
CF_SUM_PC_data_H_im = CF_SUM_PC_data_yjgz(2:2:end);
CF_SUM_PC_data_H_cf = CF_SUM_PC_data_H_re + 1j*CF_SUM_PC_data_H_im;
CF_SUM_PC_data_H_cf_mx = reshape(CF_SUM_PC_data_H_cf,32,N);
CF_SUM_PC_data_H_cf_mx_CA = zeros(32,N);
for i=1:1:N
    CF_SUM_PC_data_H_cf_mx_CA(:,i) = fft(CF_SUM_PC_data_H_cf_mx(:,i),32);
end
CF_SUM_PC_data_H_cf_mx_CA_abs = abs(CF_SUM_PC_data_H_cf_mx_CA).^2;
figure,mesh(t_x_ca_cut,f_x_ca,CF_SUM_PC_data_H_cf_mx_CA_abs);
title('和路信号');axis tight;
xlabel('时间/s','FontSize',12);ylabel('频率/Hz','FontSize',12);zlabel('幅度','FontSize',12);
[ind_F_SUM_H,ind_R_SUM_H] = find(CF_SUM_PC_data_H_cf_mx_CA_abs==max(max(CF_SUM_PC_data_H_cf_mx_CA_abs))) %%寻找
CF_SUM_Max_data = CF_SUM_PC_data_H_cf_mx_CA(ind_F_SUM_H,ind_R_SUM_H);
figure,plot(t_x_ca_cut,CF_SUM_PC_data_H_cf_mx_CA_abs(ind_F_SUM_H,:)),title('和平面最大值点');axis tight;
xlabel('时间/s','FontSize',12);ylabel('幅度','FontSize',12);

%%%%%%%%%%%%差平面%%%%%%%%%%%%%%
load CF_SUB_PC_data_yjgz.dat;
CF_SUB_PC_data_H_re = CF_SUB_PC_data_yjgz(1:2:end);
CF_SUB_PC_data_H_im = CF_SUB_PC_data_yjgz(2:2:end);
CF_SUB_PC_data_H_cf = CF_SUB_PC_data_H_re + 1j*CF_SUB_PC_data_H_im;
CF_SUB_PC_data_H_cf_mx = reshape(CF_SUB_PC_data_H_cf,32,N);
CF_SUB_PC_data_H_cf_mx_CA = zeros(32,N);
for i=1:1:N
    CF_SUB_PC_data_H_cf_mx_CA(:,i) = fft(CF_SUB_PC_data_H_cf_mx(:,i));
end
CF_SUB_PC_data_H_cf_mx_CA_abs = abs(CF_SUB_PC_data_H_cf_mx_CA).^2;

figure,mesh(t_x_ca_cut,f_x_ca,CF_SUB_PC_data_H_cf_mx_CA_abs);
title('差路信号');axis tight;
xlabel('时间/s','FontSize',12);ylabel('频率/Hz','FontSize',12);zlabel('幅度','FontSize',12);
[ind_F_SUB_H,ind_R_SUB_H]=find(CF_SUB_PC_data_H_cf_mx_CA_abs==max(max(CF_SUB_PC_data_H_cf_mx_CA_abs)))
CF_SUB_Max_data = CF_SUB_PC_data_H_cf_mx_CA(ind_F_SUB_H,ind_R_SUB_H);
figure,plot(t_x_ca_cut,CF_SUB_PC_data_H_cf_mx_CA_abs(ind_F_SUB_H,:)),title('方位差平面最大值点');axis tight;
xlabel('时间/s','FontSize',12);ylabel('幅度','FontSize',12);
