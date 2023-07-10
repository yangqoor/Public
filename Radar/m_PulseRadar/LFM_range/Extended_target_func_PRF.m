% ���ٶ�ģ��
clc;
clear all;
close all;

v_target = 1;                       % �˶�Ŀ���ٶ�
lamda = 8e-3;                       % �����źŲ���
fd_th = 2 * v_target / lamda;       % ���۶�����Ƶ��
N_PRF = 3;                          % �β�PRF����
N_repeat = 2^4;                     % һ��CPI��������
fr_m = [10e3, 11e3, 12e3];          % �����ظ�Ƶ��
fr_mKHz = [10e3, 11e3, 12e3] / 1e3; % �����ظ�Ƶ��:��λKHz
fr = 10e3;

for N_PRF_i = 1:N_PRF
    fr = fr_m(N_PRF_i);             % �����ظ�Ƶ��
    [x_axis, y_axis] = func_PRF(fr, v_target, N_repeat);
    x_axis_m(N_PRF_i) = x_axis;     % ���뵥Ԫ����λ��km��
    y_axis_m(N_PRF_i) = y_axis;     % ������Ƶ�ƣ���λ��KHz��
    %     if y_axis_m(N_PRF_i)>=0
    %         PRF_fd(N_PRF_i)=y_axis_m(N_PRF_i);
    %     else PRF_fd(N_PRF_i)=y_axis_m(N_PRF_i)+fr/1e3;
    %     end
end

kkk_i = 0; % ���������Ƶ�Ƶĸ���

if abs(y_axis_m(1) - y_axis_m(2)) <= min(fr_m) / (1e3 * N_repeat) ... ,
        && abs(y_axis_m(1) - y_axis_m(3)) <= min(fr_m) / (1e3 * N_repeat) ... ,
        && abs(y_axis_m(2) - y_axis_m(3)) <= min(fr_m) / (1e3 * N_repeat) % ������Ƶ����ÿ��fr_mKHz��
    fd_real = (y_axis_m(1) + y_axis_m(2) + y_axis_m(3)) / N_PRF; % ʵ�ʶ�����Ƶ�ƣ���λ��KHZ��
else

    for k3_i = 1:fr_mKHz(1) * fr_mKHz(2)
        k3 = k3_i - 1;

        for k2_i = k3:fr_mKHz(1) * fr_mKHz(3)
            k2 = k2_i - 1;

            for k1_i = k2 - 1:fr_mKHz(2) * fr_mKHz(3)
                k1 = k1_i;
                Ax = (fr_m(1) / 1e3) * k1 + y_axis_m(1);
                Bx = (fr_m(2) / 1e3) * k2 + y_axis_m(2);
                Cx = (fr_m(3) / 1e3) * k3 + y_axis_m(3);

                if abs(Ax - Bx) <= min(fr_m) / (1e3 * N_repeat) && abs(Ax - Cx) <= min(fr_m) / ... , % ...,������
                        (1e3 * N_repeat) && abs(Bx - Cx) <= min(fr_m) / (1e3 * N_repeat)
                    kkk_i = kkk_i + 1;
                    k_i(kkk_i, 1) = k1;
                    k_i(kkk_i, 2) = k2;
                    k_i(kkk_i, 3) = k3;
                    fd_real(kkk_i) = ((fr_m(1) / 1e3) * k1 + y_axis_m(1) + (fr_m(2) / 1e3) * k2 ... ,
                        +y_axis_m(2) + (fr_m(3) / 1e3) * k3 + y_axis_m(3)) / N_PRF; % ʵ�ʶ�����Ƶ�ƣ���λ��KHZ��
                    break;
                end

            end

        end

    end

end
