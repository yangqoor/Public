function y = RCMC(signal_rD,C,lambda,V,R0,Fs,PRF,mode)

%signal_rD  RCMC�����ź� Ϊ��������ձ�ʾ
%C ����
%lambda ���岨��
%V �״�����ٶ�
%R0 �״ﺽ�ߵ��������ĵ����б��
%Fs �����������
%PRF �����ظ�����Ƶ��
%DY ������ֱ���
%mode ��ֵģʽ  1 Ϊ��������ֵ   2 Ϊsinc��ֵ
y = signal_rD;

Na = size(y,1);
Nr = size(y,2);

if mode == 1
    win = waitbar(0,'��������ֵ');
    for i = 1:Na
        for j = 1:Nr
            delta_R = (1/8)*(lambda/V)^2*(R0+(j-Nr/2)*C/2/Fs)*((j-Nr/2)/Nr*PRF)^2;%�����㶯��
            RCM = delta_R * 2 * Fs / C;%�㶯�˶��ٸ����뵥Ԫ
            delta_RCM = RCM - floor(RCM);%С������
            if round(RCM + j) > Nr
                y(i,j) = y(i,Nr/2);
            else
                if delta_RCM < 0.5
                    y(i,j) = y(i,j+floor(RCM));
                else
                    y(i,j) = y(i,j+ceil(RCM));
                end
            end
        end
        waitbar(i/Na);
    end
    close(win);
end

if mode == 2
    win = waitbar(0,'sinc��ֵ');
    N_core = 4;
    y = zeros(Na,Nr);
    for i = 1:Na
        for j = 1:Nr
            delta_R = 1/8*(lambda/V)^2*(R0+(j-Nr/2)*C/2/Fs)*((j-Nr/2)/Nr*PRF)^2;%�����㶯��
            RCM = delta_R / DY;%�㶯�˶��ٸ����뵥Ԫ
            delta_RCM = RCM - floor(RCM);%С������
            for k = -N_core/2 : N_core/2-1
                if j+k+RCM > Nr
                    y(i,j) = y(i,j) + signal_rD(i,j)*sinc(k+RCM);
                else
                    y(i,j) = y(i,j) + signal_rD(i,j+floor(RCM)+k)*sinc(k+delta_RCM);
                end
            end
        end
        waitbar(i/Na);
    end
    close(win);
end

    