%%% ��չĿ����(�������״�)
%%% ���ٶ�ģ��

function [x_axis, y_axis] = func_PRF(fr, v_target, N_repeat)
    %% ��������
    N_PRF = 3;                                            % �β�PRF����
       % N_repeat=2^4;                                    % һ��CPI��������
    c = 3e8;                                              % cΪ����
    B_f = 10e6;                                           % �״﷢�䲨�δ���
    delta_R_resolution = c / (2 * B_f);                   % ����ֱ���
       % v_target=640;                                    % Ŀ���˶��ٶ� m/s
    lamda = 8e-3;                                         % �����źŲ���
    fd = 2 * v_target / lamda;                            % ������Ƶ��
       % fr=10e3;                                         % �����ظ�Ƶ��
    tr = 1 / fr;
    fs = B_f;                                             % ����Ƶ��
    ts = 1 / fs;
    R_max = c / (2 * fr);                                 % �״�������þ���
    R = 10e3;                                             % Ŀ����״�ľ���
    N_delta_R = R_max / delta_R_resolution;               % ���뵥Ԫ����
    Size_target = 80;                                     % �˶�Ŀ��ߴ�
    Num_scatter = ceil(Size_target / delta_R_resolution); % Ŀ���Խ���뵥Ԫ��

    if Num_scatter <= 1
        N_scatter = 1;                                    % N_scatter��Ŀ��ɢ������
        R_target_delta = 0;                               % R_target_delta��ɢ��������Ŀ�����ĵľ���
    else N_scatter = Num_scatter;
        R_target_delta = linspace(-Size_target / 2, Size_target / 2, N_scatter); % ɢ��������Ŀ�����ĵľ���
    end

    SNR = 10 * randn(1, N_scatter); % ����Ŀ�������
    %     SNR=10*[1,0.4,0.6,0.9,1,0.1,0.6,1];

    %%     �����״�ز�
    Len_pulse = fix(fs / fr); % ���峤��
    sigma_2 = 1; % ��������
    t = 0:ts:tr - ts;

    for N_re = 1:N_repeat

        noise_I = sqrt(sigma_2) * randn(Len_pulse, 1);
        noise_Q = sqrt(sigma_2) * randn(Len_pulse, 1);
        noise = noise_I + 1i * noise_Q; % ����
        signal = zeros(Len_pulse, 1);

        for i = 1:N_scatter

            Ri(i) = R + R_target_delta(i); % ɢ���������״�ľ���
            Ki(i, N_re) = fix((Ri(i) - v_target * tr * (N_re - 1) / 2) / delta_R_resolution); % ɢ��㴦�ľ��뵥Ԫ
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
    xlabel('����/Km'); ylabel('����'); title('��չĿ��');
    figure();
    plot(t * c / (2 * 1e3), abs(xn(:, 1)));
    xlabel('����/Km'); ylabel('����'); title('��չĿ��');
    axis([(min(Ki(:, 1)) - 20) * ts * c / (2 * 1e3), (max(Ki(:, 1)) + 20) * ts * c / (2 * 1e3), 0, max(abs(xn(:, 1))) + 5]);

    %%     ��ʱ��ά��FFT�任
    for i = 1:Len_pulse % ��ʱ��ά��FFT�任
        xk(i, :) = fftshift(fft(xn(i, :)));
    end

    fd_real_k = fd / 1e3; % ������Ƶ��(��λ:KHz)
    fdi = -fr / (2 * 1e3):fr / (N_repeat * 1e3):fr / (2 * 1e3) - fr / (N_repeat * 1e3); % ��λKHz
    Rangei = t * c / (2 * 1e3); % ������ ��λKm
    figure();
    mesh(fdi, Rangei, abs(xk));
    xlabel('������Ƶ�� /KHz'); ylabel('������ /Km'); zlabel('��ֵ'); title('��չĿ��')
    % figure();
    % mesh(fdi,t,abs(xk));
    % xlabel('������Ƶ�� /KHz');ylabel('ʱ�� /s');zlabel('��ֵ');title('��չĿ��');

    [x_axis_i, y_axis_i] = find(abs(xk) == max(max(abs(xk)))); % �������ֵ
    x_axis = (x_axis_i - 1) * delta_R_resolution / 1e3; % ���뵥Ԫ
    y_axis = -fr / (2 * 1e3) + (y_axis_i - 1) * fr / (N_repeat * 1e3); % ������Ƶ��

end
