% --------------------------------------------------------------------------------------------------
%
%           Demo software for AI Radar ECG
%                 
%
%            Release ver. 1.0  (Feb 10, 2025)
%
% --------------------------------------------------------------------------------------------
%
% All rights reserved.
% This work should be used for nonprofit purposes only.
% --------------------------------------------------------------------------------------------


clc;clear;close all;
load("TraninedModels\TraninedRadarECGnets.mat")
load("Dataset\TestData.mat")

load("P_QRS_T\select_ecg_P.mat")
load("P_QRS_T\select_ecg_Q.mat")
load("P_QRS_T\select_ecg_R.mat")
load("P_QRS_T\select_ecg_S.mat")
load("P_QRS_T\select_ecg_T.mat")

load("P_QRS_T\select_radar_P.mat")
load("P_QRS_T\select_radar_Q.mat")
load("P_QRS_T\select_radar_R.mat")
load("P_QRS_T\select_radar_S.mat")
load("P_QRS_T\select_radar_T.mat")

%% Find the corresponding R points
min_distances = cell(1, length(TestData));
radar_min_indices = cell(1, length(TestData));
ecg_min_indices = cell(1, length(TestData));
threshold = 0.6832;
M = 1:length(TestData);
for TestDataindices = M
    fs = 200;
    radar = TestData{TestDataindices, 1};
    ecg = TestData{TestDataindices,2};   
    t = linspace(0,length(radar)/fs,length(radar));
    Reconstruction = predict(radar_ecg_net_4_input,radar);  
    X_radar = t(select_radar_R{1,TestDataindices});
    Y_radar = Reconstruction(select_radar_R{1,TestDataindices});
    X_ecg = t(select_ecg_R{1,TestDataindices});
    Y_ecg = ecg(select_ecg_R{1,TestDataindices});

    EM = zeros(length(Y_radar), length(Y_ecg));
    for i = 1:length(Y_radar)
        X_current_radar = X_radar(i);
        Y_current_radar = Y_radar(i);
        for j = 1:length(Y_ecg)
            X_current_ecg = X_ecg(j);
            Y_current_ecg = Y_ecg(j);
            EM(i,j) = sqrt((X_current_radar-X_current_ecg).^2+(Y_current_radar-Y_current_ecg).^2);
        end
    end

    current_min_distances = [];
    current_radar_min_indices = [];
    current_ecg_min_indices = [];
    for k= 1:size(EM, 1)
        [min_val, min_col_index] = min(EM(k, :));
        if min_val < threshold
            current_min_distances = [current_min_distances, min_val];
            current_radar_min_indices = [current_radar_min_indices, k];
            current_ecg_min_indices = [current_ecg_min_indices, min_col_index];
        end
    end

    min_distances{TestDataindices} = current_min_distances;
    radar_min_indices{TestDataindices} = current_radar_min_indices;
    ecg_min_indices{TestDataindices} = current_ecg_min_indices;

    X1_ecg{TestDataindices} = select_ecg_R{1, TestDataindices}(current_ecg_min_indices);
    X2_radar{TestDataindices} = select_radar_R{1, TestDataindices}(current_radar_min_indices);
end

%% Based on the R points, find the corresponding P, Q, S, and T points in the Radar ECG.
width = 162;
radar_Q = cell(1,length(select_radar_Q));
radar_R = cell(1,length(select_radar_R));
radar_S = cell(1,length(select_radar_S));
radar_P = cell(1,length(select_radar_P));
radar_T = cell(1,length(select_radar_T));
for i =M
    Q = select_radar_Q{1,i};
    R = X2_radar{1,i};
    S = select_radar_S{1,i};
    P = select_radar_P{1,i};
    T = select_radar_T{1,i};
    R_Q = [];
    R_R = [];
    R_S = [];
    R_P = [];
    R_T = [];
    for j = 1:length(R)
        index = R(j);
        window_start3 = index - width / 2;
        window_end3 = index + width / 2;
        R_indices = R(window_start3 <= R & R <= window_end3);
        Q_indices = Q(window_start3 <= Q & Q <= R_indices);       
        S_indices = S(R_indices <= S & S <= window_end3);
        P_indices = P(window_start3 <= P & P <= R_indices);
        T_indices = T(R_indices <= T & T <= window_end3);
        if ~isempty(Q_indices) & ~isempty(R_indices) & ~isempty(S_indices) & ~isempty(P_indices) & ~isempty(T_indices)
            R_Q = [R_Q,Q_indices];
            R_R = [R_R,R_indices];
            R_S = [R_S,S_indices];
            R_P = [R_P,P_indices];
            R_T = [R_T,T_indices];
        end
    end
    if ~isempty(R_Q)   
        radar_Q{i} = R_Q;
    end
    if ~isempty(R_R)
        radar_R{i} = R_R;
    end
    if ~isempty(R_S)
        radar_S{i} = R_S;
    end
    if ~isempty(R_P)
        radar_P{i} = R_P;
    end
    if ~isempty(R_T)
        radar_T{i} = R_T;
    end
end
 
%% Based on the R points, find the corresponding P, Q, S, and T points in the ground turth ECG.
width = 140;
ecg_Q = cell(1,length(select_ecg_Q));
ecg_R = cell(1,length(select_ecg_R));
ecg_S = cell(1,length(select_ecg_S));
ecg_P = cell(1,length(select_ecg_P));
ecg_T = cell(1,length(select_ecg_T));
for i =M
    Q1 = select_ecg_Q{1,i};
    R1 = X1_ecg{1,i};
    S1 = select_ecg_S{1,i};
    P1 = select_ecg_P{1,i};
    T1 = select_ecg_T{1,i};
    E_Q = [];
    E_R = [];
    E_S = [];
    E_P = [];
    E_T = [];
    for j = 1:length(R1)
        index = R1(j);
        window_start4 = index - width / 2;
        window_end4 = index + width / 2;
        Q_indices1 = Q1(window_start4 <= Q1 & Q1 <= window_end4);
        R_indices1 = R1(window_start4 <= R1 & R1 <= window_end4);
        S_indices1 = S1(window_start4 <= S1 & S1 <= window_end4);
        P_indices1 = P1(window_start4 <= P1 & P1 <= window_end4);
        T_indices1 = T1(window_start4 <= T1 & T1 <= window_end4);
        if ~isempty(Q_indices1) & ~isempty(R_indices1) & ~isempty(S_indices1) & ~isempty(P_indices1) & ~isempty(T_indices1)
            E_Q = [E_Q,Q_indices1];
            E_R = [E_R,R_indices1];
            E_S = [E_S,S_indices1];
            E_P = [E_P,P_indices1];
            E_T = [E_T,T_indices1];
        end
    end
    if ~isempty(E_Q)   
        ecg_Q{i} = E_Q;
    end
    if ~isempty(E_R)
        ecg_R{i} = E_R;
    end
    if ~isempty(E_S)
        ecg_S{i} = E_S;
    end
    if ~isempty(E_P)
        ecg_P{i} = E_P;
    end
    if ~isempty(E_T)
        ecg_T{i} = E_T;
    end
end

for TestDataindices = M
    fs = 200;
    radar = TestData{TestDataindices, 1};
    ecg = TestData{TestDataindices,2};   
    t = linspace(0,length(radar)/fs,length(radar));
    Reconstruction = predict(radar_ecg_net_4_input,radar);


    figure(123)
    subplot(211)
    plot(ecg);
    title('ECG')
    xlabel('Samples'); ylabel({'Normalized amplitude'});
    hold on
    plot(ecg_Q{1,TestDataindices},ecg(ecg_Q{1,TestDataindices}),'gs','MarkerFaceColor','g')
    plot(ecg_R{1,TestDataindices},ecg(ecg_R{1,TestDataindices}),'ro','MarkerFaceColor','r')
    plot(ecg_S{1,TestDataindices},ecg(ecg_S{1,TestDataindices}),'bv','MarkerFaceColor','b')
    plot(ecg_P{1,TestDataindices},ecg(ecg_P{1,TestDataindices}),'ms','MarkerFaceColor','m')
    plot(ecg_T{1,TestDataindices},ecg(ecg_T{1,TestDataindices}),'rv','MarkerFaceColor','k')
    xlim([0 2048])
    hold off;

    subplot(212)
    plot(Reconstruction);
    hold on
    plot(radar_Q{1,TestDataindices},Reconstruction(radar_Q{1,TestDataindices}),'gs','MarkerFaceColor','g');
    plot(radar_R{1,TestDataindices},Reconstruction(radar_R{1,TestDataindices}),'ro','MarkerFaceColor','r');
    plot(radar_S{1,TestDataindices},Reconstruction(radar_S{1,TestDataindices}),'bv','MarkerFaceColor','b');
    plot(radar_P{1,TestDataindices},Reconstruction(radar_P{1,TestDataindices}),'ms','MarkerFaceColor','m');
    plot(radar_T{1,TestDataindices},Reconstruction(radar_T{1,TestDataindices}),'rv','MarkerFaceColor','k');
    grid on
    title('Reconstructed ECG')
    xlim([0 2048])
    xlabel('Samples'); ylabel({'Normalized amplitude'});
    hold off;
    drawnow;
    pause(1)
end