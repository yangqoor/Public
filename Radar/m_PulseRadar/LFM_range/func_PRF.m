%%% 扩展目标检测(简单脉冲雷达)
%%% 解速度模糊

function [x_axis, y_axis] = func_PRF(fr, v_target, N_repeat)
    %% 参数设置
    N_PRF = 3;                                            % 参差PRF个数
       % N_repeat=2^4;                                    % 一个CPI内脉冲数
    c = 3e8;                                              % c为光速
    B_f = 10e6;                                           % 雷达发射波形带宽
    delta_R_resolution = c / (2 * B_f);                   % 距离分辨率
       % v_target=640;                                    % 目标运动速度 m/s
    lamda = 8e-3;                                         % 发射信号波长
    fd = 2 * v_target / lamda;                            % 多普勒频率
       % fr=10e3;                                         % 脉冲重复频率
    tr = 1 / fr;
    fs = B_f;                                             % 采样频率
    ts = 1 / fs;
    R_max = c / (2 * fr);                                 % 雷达最大作用距离
    R = 10e3;                                             % 目标距雷达的距离
    N_delta_R = R_max / delta_R_resolution;               % 距离单元个数
    Size_target = 80;                                     % 运动目标尺寸
    Num_scatter = ceil(Size_target / delta_R_resolution); % 目标跨越距离单元数

    if Num_scatter <= 1
        N_scatter = 1;                                    % N_scatter表目标散射点个数
        R_target_delta = 0;                               % R_target_delta表散射点相对于目标中心的距离
    else N_scatter = Num_scatter;
        R_target_delta = linspace(-Size_target / 2, Size_target / 2, N_scatter); % 散射点相对于目标中心的距离
    end

    SNR = 10 * randn(1, N_scatter); % 单点目标信噪比
    %     SNR=10*[1,0.4,0.6,0.9,1,0.1,0.6,1];

    %%     产生雷达回波
    Len_pulse = fix(fs / fr); % 脉冲长度
    sigma_2 = 1; % 噪声功率
    t = 0:ts:tr - ts;

    for N_re = 1:N_repeat

        noise_I = sqrt(sigma_2) * randn(Len_pulse, 1);
        noise_Q = sqrt(sigma_2) * randn(Len_pulse, 1);
        noise = noise_I + 1i * noise_Q; % 噪声
        signal = zeros(Len_pulse, 1);

        for i = 1:N_scatter

            Ri(i) = R + R_target_delta(i); % 散射点相对于雷达的距离
            Ki(i, N_re) = fix((Ri(i) - v_target * tr * (N_re - 1) / 2) / delta_R_resolution); % 散射点处的距离单元
            pules = [zeros(1, Ki(i, N_re) - 1), 1, zeros(1, Len_pulse - Ki(i, N_re))];
            Ai = SNR(i);
            Signal_i(:, i) = Ai .* pules .* exp(-1i * 4 * pi * (Ri(i) - v_target .* (t + (N_re - 1) * tr)) / lamda);
            signal = signal + Signal_i(:, i);

        end

        Signal_matrix(:, N_re) = signal;
        xn(:, N_re) = signal + noise;

    end

    figure();
    plot(t * c / (2 * 1e3), abs(xn(:, 1)));
    xlabel('距离/Km'); ylabel('幅度'); title('扩展目标');
    figure();
    plot(t * c / (2 * 1e3), abs(xn(:, 1)));
    xlabel('距离/Km'); ylabel('幅度'); title('扩展目标');
    axis([(min(Ki(:, 1)) - 20) * ts * c / (2 * 1e3), (max(Ki(:, 1)) + 20) * ts * c / (2 * 1e3), 0, max(abs(xn(:, 1))) + 5]);

    %%     慢时间维做FFT变换
    for i = 1:Len_pulse % 慢时间维做FFT变换
        xk(i, :) = fftshift(fft(xn(i, :)));
    end

    fd_real_k = fd / 1e3; % 多普勒频移(单位:KHz)
    fdi = -fr / (2 * 1e3):fr / (N_repeat * 1e3):fr / (2 * 1e3) - fr / (N_repeat * 1e3); % 单位KHz
    Rangei = t * c / (2 * 1e3); % 距离门 单位Km
    figure();
    mesh(fdi, Rangei, abs(xk));
    xlabel('多普勒频移 /KHz'); ylabel('距离门 /Km'); zlabel('幅值'); title('扩展目标')
    % figure();
    % mesh(fdi,t,abs(xk));
    % xlabel('多普勒频移 /KHz');ylabel('时间 /s');zlabel('幅值');title('扩展目标');

    [x_axis_i, y_axis_i] = find(abs(xk) == max(max(abs(xk)))); % 查找最大值
    x_axis = (x_axis_i - 1) * delta_R_resolution / 1e3; % 距离单元
    y_axis = -fr / (2 * 1e3) + (y_axis_i - 1) * fr / (N_repeat * 1e3); % 多普勒频移

end
