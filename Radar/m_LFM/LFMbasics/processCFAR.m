%% CFAR

% 先运行 processCoherent.m文件

%%
%%%%%%%%%二维筛选%%%%%%%%%

N_ref_2D = M/4;  %参考区域大小
PC_data_ifft_CA_abs = abs(PC_data_ifft_CA);

N_point = length(PC_data_ifft_CA_abs);
%计算区域1的和
sum1 = sum(PC_data_ifft_CA_abs(1:N_ref_2D,1:N_ref_2D)); %按行相加
sum_ref_2D(1,1) = sum(sum1(1,:));            %按列相加
%计算区域2的和
sum2 = sum(PC_data_ifft_CA_abs(1:N_ref_2D,(N_point-N_ref_2D+1):N_point));
sum_ref_2D(1,2) = sum(sum2(1,:));
%计算区域3的和
sum3 = sum(PC_data_ifft_CA_abs((M-N_ref_2D+1):M,1:N_ref_2D));
sum_ref_2D(1,3) = sum(sum3(1,:));
%计算区域4的和
sum4 = sum(PC_data_ifft_CA_abs((M-N_ref_2D+1):M,(N_point-N_ref_2D+1):N_point));
sum_ref_2D(1,4) = sum(sum4(1,:));

%%%产生门限Threshold%%%
SNR_Threshold = 15;   % 检测门限 dB
Threshold = ((sum(sum_ref_2D(:,1:4)) - max(sum_ref_2D))/(N_ref_2D^2*3))*10^(SNR_Threshold/10);

%%%寻找 PC_data_ifft_CA 中大于门限的点并记录其位置%%%
location = zeros(M,N_point);  %填1表示该点大于门限
for i=1:1:M
    for j=1:1:N_point
        if(PC_data_ifft_CA_abs(i,j) >= (1*Threshold))
            location(i,j) = 1;
        else
            location(i,j) = 0;
        end
    end
end
% figure(4),mesh(location),title('二维筛选后的结果/location');axis tight;

%%%筛选结果显示%%%
selected = zeros(M,N_point);
for i=1:1:M
    for j=1:1:N_point
        if(location(i,j) == 1)
            selected(i,j) = PC_data_ifft_CA_abs(i,j);
        else
            selected(i,j) = 0;
        end
    end
end
figure(5),mesh(t_x_ca_cut,f_x_ca,selected),title('二维CFAR后的结果(信号1的SNR=-5,信号2的SNR=2)/selected');axis tight;
xlabel('时间/s','FontSize',12);ylabel('频率/Hz','FontSize',12);zlabel('检测结果(尖峰处为目标)','FontSize',12);
%%%%%%%%%%二维筛选结束%%%%%%%%%%%

%%%%%%%%%%一维筛选%%%%%%%%%%
%%%%距离维筛选%%%%
N_prot_R = 30; %保护单元覆盖第二旁瓣，次大点与次次大点
N_ref_R = 135;  %参考单元
threshold_R = zeros(M,N_point); %记录距离维每个观察点的门限值
for i=1:1:M
    for j=1:1:N_point
        if(location(i,j) == 1) %只筛选经过二维筛选之后的点
            if(j <= (N_prot_R + N_ref_R) ) %观察点过于偏左，左侧点数不足
                threshold_R(i,j) = (sum(PC_data_ifft_CA_abs(i,(j+N_prot_R+1):(j+N_prot_R+N_ref_R))))/N_ref_R; %观察点右侧参考点相加求平均
            elseif( j >= (N_point - N_prot_R - N_ref_R + 1)) %观察点过于偏右，右侧点数不足
                threshold_R(i,j) = (sum(PC_data_ifft_CA_abs(i,(j-N_prot_R-N_ref_R):(j-N_prot_R-1))))/N_ref_R; %观察点左侧参考点求平均
            else %观察点居中，左右点数均足够
                sum_R_left = sum(PC_data_ifft_CA_abs(i,(j-N_prot_R-N_ref_R):(j-N_prot_R-1)));
                sum_R_right = sum(PC_data_ifft_CA_abs(i,(j+N_prot_R+1):(j+N_prot_R+N_ref_R)));
                threshold_R(i,j) = max(sum_R_left,sum_R_right)/(N_ref_R); %观察点两侧取大的一侧求均值
            end
        else
            threshold_R(i,j) = 0;
        end
    end
end
%利用距离维门限进行一维筛选
location_R = zeros(M,N_point);
for i=1:1:M
    for j=1:1:N_point
        if(location(i,j) == 1) %只筛选经过二维筛选之后的点
            if(PC_data_ifft_CA_abs(i,j) >= (1*threshold_R(i,j)))
                location_R(i,j) = 1;
            else
                location_R(i,j) = 0;
            end
        else
            location_R(i,j) = 0;
        end
    end
end
%%%筛选结果显示%%%
selected_R = zeros(M,N_point);
for i=1:1:M
    for j=1:1:N_point
        if(location_R(i,j) == 1)
            selected_R(i,j) = PC_data_ifft_CA_abs(i,j);
        else
            selected_R(i,j) = 0;
        end
    end
end
figure(6),mesh(t_x_ca_cut,f_x_ca,selected_R),
title('二维CFAR后加一维时间CFAR后的结果(信号1的SNR=-5,信号2的SNR=2)/selected');axis tight;
xlabel('时间/s','FontSize',12);ylabel('频率/Hz','FontSize',12);zlabel('检测结果(尖峰处为目标)','FontSize',12);

%%%%%%%%%%%距离维筛选结束%%%%%%%%%%%%%

%%%%%频率维筛选%%%%%
N_prot_F = 5;
N_ref_F = 10;
threshold_F = zeros(M,N_point); %记录距离维每个观察点的门限值
for j=1:1:N_point
    for i=1:1:M
        if(location_R(i,j) == 1) %只筛选经过二维筛选和距离维筛选之后的点
            if(i <= (N_prot_F + N_ref_F) ) %观察点过于偏左，左侧点数不足
                threshold_F(i,j) = (sum(PC_data_ifft_CA_abs((i+N_prot_F+1):(i+N_prot_F+N_ref_F),j)))/N_ref_F; %观察点右侧参考点相加求平均
            elseif( i >= (M - N_prot_F - N_ref_F + 1)) %观察点过于偏右，右侧点数不足
                threshold_F(i,j) = (sum(PC_data_ifft_CA_abs((i-N_prot_F-N_ref_F):(i-N_prot_F-1),j)))/N_ref_F; %观察点左侧参考点求平均
            else %观察点居中，左右点数均足够
                sum_F_left = sum(PC_data_ifft_CA_abs((i-N_prot_F-N_ref_F):(i-N_prot_F-1),j));
                sum_F_right = sum(PC_data_ifft_CA_abs((i+N_prot_F+1):(i+N_prot_F+N_ref_F),j));
                threshold_F(i,j) = max(sum_F_left,sum_F_right)/(N_ref_F); %观察点两侧取大的一侧求均值
            end
        else
            threshold_F(i,j) = 0;
        end
    end
end
%利用频率维门限进行一维筛选
location_R_F = zeros(M,N_point);
for i=1:1:M
    for j=1:1:N_point
        if(location_R(i,j) == 1) %只筛选经过二维筛选和距离维筛选之后的点
            if(PC_data_ifft_CA_abs(i,j) >= (1*threshold_F(i,j)))
                location_R_F(i,j) = 1;
            else
                location_R_F(i,j) = 0;
            end
        else
            location_R_F(i,j) = 0;
        end
    end
end
%%%筛选结果显示%%%
selected_R_F = zeros(M,N_point);
for i=1:1:M
    for j=1:1:N_point
        if(location_R_F(i,j) == 1)
            selected_R_F(i,j) = PC_data_ifft_CA_abs(i,j);
        else
            selected_R_F(i,j) = 0;
        end
    end
end
figure(7),mesh(t_x_ca_cut,f_x_ca,selected_R_F),
title('二维CFAR后加一维时间CFAR与一维频率CFAR后的结果(信号1的SNR=-5,信号2的SNR=2)/selected');axis tight;
xlabel('时间/s','FontSize',12);ylabel('频率/Hz','FontSize',12);zlabel('检测结果(尖峰处为目标)','FontSize',12);
