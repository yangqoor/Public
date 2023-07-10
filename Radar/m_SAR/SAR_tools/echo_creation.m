function S = echo_creation(C,H,Yc,lambda,Lsar,Kr,Tr,Tau,Ra,Targets)

%C ����
%H  �״���и߶�
%Yc  ��������Y������
%lambda  �����źŲ���
%Lsar �ϳɿ׾�����
%Kr  �����źŵ�Ƶ��
%Tr �������ʱ��
%Tau ������ʱ������
%Ra ��λ���������
%Targets Ŀ����� ���� ��ʽΪ �У� x ��y��rcs  ���У�ÿ��Ŀ��

N = size(Targets,1);%Ŀ������
Nr = size(Tau,2); %�������������
Na = size(Ra,2); %��λ���������

S = zeros(Na,Nr); %��ʼ���ز�����
for i = 1:N
    delta_x = Ra - Targets(i,1); %ƽ̨��Ŀ���x������
    delta_y = Targets(i,2);%ƽ̨��Ŀ���y������
    range = sqrt(delta_x.^2 + H^2 + delta_y^2); % ÿ����λ������ �״ﵽĿ���б��
    rcs = Targets(i,3); %��Ŀ��ĺ���ɢ��ϵ��
    tau = ones(Na,1) * Tau - (2*range / C)' * ones(1,Nr); % ʱ������
    phase = pi * Kr * tau.^2 - 4 * pi / lambda * (range' * ones(1,Nr));%�����ź���λ
%     S = S + rcs * exp(1i * phase) .* ((abs(delta_x) < Lsar / 2)' * ones(1,Nr)) .* (tau > 0 & tau < Tr);
    S = S + rcs * exp(1i * phase) .* ((abs(delta_x) < Lsar / 2)' * ones(1,Nr)) .* (abs(tau) < Tr/2);
end

