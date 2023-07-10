%% I. ��ջ�������
clear all
clc

%% II. ѵ����/���Լ�����
%%
% 1. ��������
load spectra_data.mat

%%
% 2. �������ѵ�����Ͳ��Լ�
temp = randperm(size(NIR,1));

% ѵ��������50������
P_train = NIR(temp(1:50),:)';
T_train = octane(temp(1:50),:)';

% ���Լ�����10������
P_test = NIR(temp(51:end),:)';
T_test = octane(temp(51:end),:)';
N = size(P_test,2);

%% III. ���ݹ�һ��
%%
% 1. ѵ����
[Pn_train,inputps] = mapminmax(P_train);
Pn_test = mapminmax('apply',P_test,inputps);
%%
% 2. ���Լ�
[Tn_train,outputps] = mapminmax(T_train);
Tn_test = mapminmax('apply',T_test,outputps);

%% IV. ELM����/ѵ��
[IW,B,LW,TF,TYPE] = elmtrain(Pn_train,Tn_train,30,'sig',0);

%% V. ELM�������
tn_sim = elmpredict(Pn_test,IW,B,LW,TF,TYPE);
%%
% 1. ����һ��
T_sim = mapminmax('reverse',tn_sim,outputps);

%% VI. ����Ա�
result = [T_test' T_sim'];
%%
% 1. �������
E = mse(T_sim - T_test);

%%
% 2. ����ϵ��
N = length(T_test);
R2=(N*sum(T_sim.*T_test)-sum(T_sim)*sum(T_test))^2/((N*sum((T_sim).^2)-(sum(T_sim))^2)*(N*sum((T_test).^2)-(sum(T_test))^2)); 

%% VII. ��ͼ
figure(1)
plot(1:N,T_test,'r-*',1:N,T_sim,'b:o')
grid on
legend('��ʵֵ','Ԥ��ֵ')
xlabel('�������')
ylabel('����ֵ')
string = {'���Լ�����ֵ����Ԥ�����Ա�(ELM)';['(mse = ' num2str(E) ' R^2 = ' num2str(R2) ')']};
title(string)