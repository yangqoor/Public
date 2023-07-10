% 解速度模糊
clc;
clear all;
close all;

v_target = 1;                       % 运动目标速度
lamda = 8e-3;                       % 发射信号波长
fd_th = 2 * v_target / lamda;       % 理论多普勒频率
N_PRF = 3;                          % 参差PRF个数
N_repeat = 2^4;                     % 一个CPI内脉冲数
fr_m = [10e3, 11e3, 12e3];          % 脉冲重复频率
fr_mKHz = [10e3, 11e3, 12e3] / 1e3; % 脉冲重复频率:单位KHz
fr = 10e3;

for N_PRF_i = 1:N_PRF
    fr = fr_m(N_PRF_i);             % 脉冲重复频率
    [x_axis, y_axis] = func_PRF(fr, v_target, N_repeat);
    x_axis_m(N_PRF_i) = x_axis;     % 距离单元（单位：km）
    y_axis_m(N_PRF_i) = y_axis;     % 多普勒频移（单位：KHz）
    %     if y_axis_m(N_PRF_i)>=0
    %         PRF_fd(N_PRF_i)=y_axis_m(N_PRF_i);
    %     else PRF_fd(N_PRF_i)=y_axis_m(N_PRF_i)+fr/1e3;
    %     end
end

kkk_i = 0; % 满足多普勒频移的个数

if abs(y_axis_m(1) - y_axis_m(2)) <= min(fr_m) / (1e3 * N_repeat) ... ,
        && abs(y_axis_m(1) - y_axis_m(3)) <= min(fr_m) / (1e3 * N_repeat) ... ,
        && abs(y_axis_m(2) - y_axis_m(3)) <= min(fr_m) / (1e3 * N_repeat) % 多普勒频移在每个fr_mKHz内
    fd_real = (y_axis_m(1) + y_axis_m(2) + y_axis_m(3)) / N_PRF; % 实际多普勒频移（单位：KHZ）
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

                if abs(Ax - Bx) <= min(fr_m) / (1e3 * N_repeat) && abs(Ax - Cx) <= min(fr_m) / ... , % ...,表续行
                        (1e3 * N_repeat) && abs(Bx - Cx) <= min(fr_m) / (1e3 * N_repeat)
                    kkk_i = kkk_i + 1;
                    k_i(kkk_i, 1) = k1;
                    k_i(kkk_i, 2) = k2;
                    k_i(kkk_i, 3) = k3;
                    fd_real(kkk_i) = ((fr_m(1) / 1e3) * k1 + y_axis_m(1) + (fr_m(2) / 1e3) * k2 ... ,
                        +y_axis_m(2) + (fr_m(3) / 1e3) * k3 + y_axis_m(3)) / N_PRF; % 实际多普勒频移（单位：KHZ）
                    break;
                end

            end

        end

    end

end
