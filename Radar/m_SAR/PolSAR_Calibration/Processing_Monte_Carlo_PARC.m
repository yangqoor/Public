%% ��� PARC �㷨
%
% ���ؿ������ʵ��
%
% �������� N �������
% ������ͬ������£������������Ƿ���������������У׼��ļ�������
% ��Ҫ��������ˮƽ�����Ȳ�ƽ�����λ��ƽ��
%
% ��������2017.11.16. 21:06


%%
close all;
clear;
clc;


%% ����������ã�������Ҫ�޸ģ�
delta_dB = -500;% -500;-40;-35;-30;-25;-20;     	% ʧ������Ŵ�С����λ dB

f_dB = 0;% 0;1;2;3;     	% ʧ�������Ȳ�ƽ�⣬��λ dB


%% ����������ã���Ҫ�ģ���
f_phase = 0;          	% ʧ�������λ��ƽ�⣬��λ �ȣ��㣩
SNR_dB = 60 : -1 : 25;  % ��PARC��SNR�ϸߡ���������ģ��������ȴ�С����λ dB
% SNR_dB = 45;

Num_Monte_Carlo = 10000;      % ���ؿ���ʵ����������ĳһSNR�£�


%% ����
h = waitbar(0,'Please wait...');

for qq = 1 : length(SNR_dB)
    for pp = 1 : Num_Monte_Carlo
        % ��������
        [T,R,S1,S2,S3,S_test,M1,M2,M3,M_test] = Gen_Data_PARC(delta_dB,f_dB,f_phase,SNR_dB(qq));

        % �� PARC �㷨���ʧ�����
        [T1_gu,R1_gu, T2_gu,R2_gu] = My_PARC(M1,M2,M3);
        % �ɶ�ʹ��
        T_solve = T1_gu;
        R_solve = R1_gu;

        % ��"���������Ƿ�����"���м�������
        A_solve = 1; % �ڸ÷����У����Ը�ֵ��Ӱ�죬ʼ������ A_solve = 1;
        M_After_PC = M_Polarization(reshape(M_test.',1,[]),T_solve,R_solve,A_solve);

        % �����������л���,���ں�������
        %   1��zhenzhi_T_R_A ��ʾÿ�η�����ʧ��������ֵ
        zhenzhi_T_R_A(pp,1:4) = reshape(T.',1,[]);          % T
        zhenzhi_T_R_A(pp,4+1:4+4) = reshape(R.',1,[]);      % R
        zhenzhi_T_R_A(pp,4+4+1) = 1;                        % A��ʼ������Ϊ1
        %   2��Resolve_T_R_A ��ʾ��Whitt�㷨���õ���ʧ��������ֵ
        Resolve_T_R_A(pp,1:4) = reshape(T_solve.',1,[]);    % T_solve
        Resolve_T_R_A(pp,4+1:4+4) = reshape(R_solve.',1,[]);% R_solve
        Resolve_T_R_A(pp,4+4+1) = A_solve;                  % A_solve
        %   3��Result_M_test ��ʾ�����������Ƿ��������ļ���У׼���
        Result_M_test(pp,1:4) = M_After_PC;

        waitbar(((qq-1)*Num_Monte_Carlo+pp)/(length(SNR_dB)*Num_Monte_Carlo));
    end

    tmp = Result_M_test(:,1);
    guiyi_Result_M_test = Result_M_test./(tmp*ones(1,4));   % �� Result_M_test ��һ��
    clear tmp;
    
    %% ͳ�Ƹ�SNR�µġ����ָ�ꡱ
    dB_Result_M_test = 20*log10(abs(guiyi_Result_M_test));  % ȡ���ȣ�dB��
    zuicha_HV_VH(qq,1) = max(max(dB_Result_M_test(:,2:3))); % ���ţ�dB����HV��VHͨ��һ�����
    zuicha_f_abs(qq,1) = max(abs(dB_Result_M_test(:,4)));   % ���Ȳ�ƽ�⣨dB���������������Ļ�����ȡ����ֵ�õ������Ҳ����˵���Ȳ�ƽ���� [-XX��+XX]֮�䡣
    angle_guiyi_Result_M_test = angle(guiyi_Result_M_test)/pi*180;% ȡ��λ���㣩 
    zuicha_f_phase(qq,1) = max(abs(angle_guiyi_Result_M_test(:,4)));% ��λ��ƽ�⣨dB���������������Ļ�����ȡ����ֵ�õ���������Ʒ��Ȳ�ƽ�⡣
    clear dB_Result_M_test;
    
    %% ͳ�Ƹ�SNR�µġ�����+�ң�ָ�ꡱ
    abs_guiyi_Result_M_test = abs(guiyi_Result_M_test);% ȡ���ȣ���dB��
    temp = abs_guiyi_Result_M_test(:,2:3);
    temp = reshape(temp,[],1);
    miusigma_HV_VH(qq,1) = 20*log10( mean(temp) + 1 * std(temp) );% ���Ų�������̫�ֲ����ã���+�ң�����λdB
    clear temp;
    miusigma_f_abs(qq,1) = 20*log10( mean(abs_guiyi_Result_M_test(:,4)) + 2 * std(abs_guiyi_Result_M_test(:,4)) );% ���Ƚ�����̫�ֲ����ã���+2�ң���95%�������䣻��λdB
    miusigma_f_phase(qq,1) = ( mean(angle_guiyi_Result_M_test(:,4)) + 2 * std(angle_guiyi_Result_M_test(:,4)) );% ��λ��ƽ�������̫�ֲ����ã���+2�ң���95%�������䣻��λ��
   
    clear angle_Result_M_test;
    clear abs_guiyi_Result_M_test;
    clear guiyi_Result_M_test;
    
end
close(h);
clc;


%%
% �� SNR_dB ѡ��Ϊһ�鲻ͬǿ�ȵ������ʱ
% ���������������Ƿ�����������������������ȵı仯
%% �������� 1�������ָ��
%
figure;plot(SNR_dB,zuicha_HV_VH);grid on;
title('���ָ�꣬���Ŵ�С������ȵı仯');
xlabel('����ȣ���λ dB');ylabel('���Ŵ�С����λ dB');legend('�޴���,f=3dB');%legend('delta=-20dB,f=0dB');
figure;plot(SNR_dB,zuicha_f_abs);grid on;
title('���ָ�꣬���Ȳ�ƽ��������ȵı仯');
xlabel('����ȣ���λ dB');ylabel('���Ȳ�ƽ�⣬��λ dB');legend('�޴���,f=3dB');
figure;plot(SNR_dB,zuicha_f_phase);grid on;
title('���ָ�꣬��λ��ƽ��������ȵı仯');
xlabel('����ȣ���λ dB');ylabel('��λ��ƽ�⣬��λ ��');legend('�޴���,f=3dB');
%}
%% �������� 2��������+�ң�ָ��
%
figure;plot(SNR_dB,miusigma_HV_VH);grid on;
title('����+�ң�ָ�꣬���Ŵ�С������ȵı仯');
xlabel('����ȣ���λ dB');ylabel('���Ŵ�С����λ dB');legend('�޴���,f=3dB');
figure;plot(SNR_dB,miusigma_f_abs);grid on;
title('����+2�ң�ָ�꣬���Ȳ�ƽ��������ȵı仯');
xlabel('����ȣ���λ dB');ylabel('���Ȳ�ƽ�⣬��λ dB');legend('�޴���,f=3dB');
figure;plot(SNR_dB,miusigma_f_phase);grid on;
title('����+2�ң�ָ�꣬��λ��ƽ��������ȵı仯');
xlabel('����ȣ���λ dB');ylabel('��λ��ƽ�⣬��λ ��');legend('�޴���,f=3dB');
%}


%% ĳһSNR�µķ���
%
% �����������Ƿ�����������������
tmp = Result_M_test(:,1);
guiyi_Result_M_test = Result_M_test./(tmp*ones(1,4));   % �� Result_M_test ��һ��
clear tmp;

dB_Result_M_test = 20*log10(abs(guiyi_Result_M_test));  % ���ȣ���λ dB
figure;plot(dB_Result_M_test(:,2),'.');
title('HV ���Ŵ�С');xlabel('�������');ylabel('��С����λ dB')
hold on;plot(max(dB_Result_M_test(:,2)).*ones(Num_Monte_Carlo,1),'-r','LineWidth',2);hold off;
figure;plot(dB_Result_M_test(:,3),'.');
title('VH ���Ŵ�С');xlabel('�������');ylabel('��С����λ dB')
hold on;plot(max(dB_Result_M_test(:,3)).*ones(Num_Monte_Carlo,1),'-r','LineWidth',2);hold off;
figure;plot(dB_Result_M_test(:,4),'.');
title('���Ȳ�ƽ��');xlabel('�������');ylabel('��С����λ dB')
hold on;
plot(max(dB_Result_M_test(:,4)).*ones(Num_Monte_Carlo,1),'-r','LineWidth',2);
plot(min(dB_Result_M_test(:,4)).*ones(Num_Monte_Carlo,1),'-r','LineWidth',2);
hold off;

angle_guiyi_Result_M_test = angle(guiyi_Result_M_test)/pi*180;% ��λ����λ�ȣ��㣩 
figure;plot(angle_guiyi_Result_M_test(:,4),'.');
title('��λ��ƽ��');xlabel('�������');ylabel('��λ����λ �ȣ��㣩');
hold on;
plot(max(angle_guiyi_Result_M_test(:,4)).*ones(Num_Monte_Carlo,1),'-r','LineWidth',2);
plot(min(angle_guiyi_Result_M_test(:,4)).*ones(Num_Monte_Carlo,1),'-r','LineWidth',2);
hold off;

%%
% ���� T ����ֵ�����ֵ
figure;
suptitle('ʧ����� T �����ֵ����ֵ�Ա�')

subplot(2,2,1);
plot(20*log10(abs(Resolve_T_R_A(:,2)./Resolve_T_R_A(:,1))))
title('T �� HV ���Ŵ�С');xlabel('�������');ylabel('��С����λ dB')
hold on;plot(20*log10(abs(zhenzhi_T_R_A(:,2))),'r-','LineWidth',2);hold off;
subplot(2,2,2);
plot(20*log10(abs(Resolve_T_R_A(:,3)./Resolve_T_R_A(:,1))))
title('T �� VH ���Ŵ�С');xlabel('�������');ylabel('��С����λ dB')
hold on;plot(20*log10(abs(zhenzhi_T_R_A(:,3))),'r-','LineWidth',2);hold off;
subplot(2,2,3);
plot(20*log10(abs(Resolve_T_R_A(:,4)./Resolve_T_R_A(:,1))))
title('T �ķ��Ȳ�ƽ��');xlabel('�������');ylabel('��С����λ dB')
hold on;plot(20*log10(abs(zhenzhi_T_R_A(:,4))),'r-','LineWidth',2);hold off;
subplot(2,2,4);
plot((angle(Resolve_T_R_A(:,4)./Resolve_T_R_A(:,1)))/pi*180)
title('T ����λ��ƽ��');xlabel('�������');ylabel('��λ����λ �ȣ��㣩');
hold on;plot((angle(zhenzhi_T_R_A(:,4)))/pi*180,'r-','LineWidth',2);hold off;

%%
% ���� R ����ֵ�����ֵ
figure;
suptitle('ʧ����� R �����ֵ����ֵ�Ա�')

subplot(2,2,1);
plot(20*log10(abs(Resolve_T_R_A(:,4+2)./Resolve_T_R_A(:,4+1))))
title('R �� HV ���Ŵ�С');xlabel('�������');ylabel('��С����λ dB')
hold on;plot(20*log10(abs(zhenzhi_T_R_A(:,4+2))),'r-','LineWidth',2);hold off;
subplot(2,2,2);
plot(20*log10(abs(Resolve_T_R_A(:,4+3)./Resolve_T_R_A(:,4+1))))
title('R �� VH ���Ŵ�С');xlabel('�������');ylabel('��С����λ dB')
hold on;plot(20*log10(abs(zhenzhi_T_R_A(:,4+3))),'r-','LineWidth',2);hold off;
subplot(2,2,3);
plot(20*log10(abs(Resolve_T_R_A(:,4+4)./Resolve_T_R_A(:,4+1))))
title('R �ķ��Ȳ�ƽ��');xlabel('�������');ylabel('��С����λ dB')
hold on;plot(20*log10(abs(zhenzhi_T_R_A(:,4+4))),'r-','LineWidth',2);hold off;
subplot(2,2,4);
plot((angle(Resolve_T_R_A(:,4+4)./Resolve_T_R_A(:,4+1)))/pi*180)
title('R ����λ��ƽ��');xlabel('�������');ylabel('��λ����λ �ȣ��㣩');
hold on;plot((angle(zhenzhi_T_R_A(:,4+4)))/pi*180,'r-','LineWidth',2);hold off;

%%
% A ����ֵ�����ֵ
% figure;
% plot(Resolve_T_R_A(:,4+4+1));
% title('���Է������� A �Ĵ�С');xlabel('�������');
% hold on;plot(zhenzhi_T_R_A(:,4+4+1),'r-','LineWidth',2);hold off;

%}










