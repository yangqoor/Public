%% CFAR

% ������ processCoherent.m�ļ�

%%
%%%%%%%%%��άɸѡ%%%%%%%%%

N_ref_2D = M/4;  %�ο������С
PC_data_ifft_CA_abs = abs(PC_data_ifft_CA);

N_point = length(PC_data_ifft_CA_abs);
%��������1�ĺ�
sum1 = sum(PC_data_ifft_CA_abs(1:N_ref_2D,1:N_ref_2D)); %�������
sum_ref_2D(1,1) = sum(sum1(1,:));            %�������
%��������2�ĺ�
sum2 = sum(PC_data_ifft_CA_abs(1:N_ref_2D,(N_point-N_ref_2D+1):N_point));
sum_ref_2D(1,2) = sum(sum2(1,:));
%��������3�ĺ�
sum3 = sum(PC_data_ifft_CA_abs((M-N_ref_2D+1):M,1:N_ref_2D));
sum_ref_2D(1,3) = sum(sum3(1,:));
%��������4�ĺ�
sum4 = sum(PC_data_ifft_CA_abs((M-N_ref_2D+1):M,(N_point-N_ref_2D+1):N_point));
sum_ref_2D(1,4) = sum(sum4(1,:));

%%%��������Threshold%%%
SNR_Threshold = 15;   % ������� dB
Threshold = ((sum(sum_ref_2D(:,1:4)) - max(sum_ref_2D))/(N_ref_2D^2*3))*10^(SNR_Threshold/10);

%%%Ѱ�� PC_data_ifft_CA �д������޵ĵ㲢��¼��λ��%%%
location = zeros(M,N_point);  %��1��ʾ�õ��������
for i=1:1:M
    for j=1:1:N_point
        if(PC_data_ifft_CA_abs(i,j) >= (1*Threshold))
            location(i,j) = 1;
        else
            location(i,j) = 0;
        end
    end
end
% figure(4),mesh(location),title('��άɸѡ��Ľ��/location');axis tight;

%%%ɸѡ�����ʾ%%%
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
figure(5),mesh(t_x_ca_cut,f_x_ca,selected),title('��άCFAR��Ľ��(�ź�1��SNR=-5,�ź�2��SNR=2)/selected');axis tight;
xlabel('ʱ��/s','FontSize',12);ylabel('Ƶ��/Hz','FontSize',12);zlabel('�����(��崦ΪĿ��)','FontSize',12);
%%%%%%%%%%��άɸѡ����%%%%%%%%%%%

%%%%%%%%%%һάɸѡ%%%%%%%%%%
%%%%����άɸѡ%%%%
N_prot_R = 30; %������Ԫ���ǵڶ��԰꣬�δ����δδ��
N_ref_R = 135;  %�ο���Ԫ
threshold_R = zeros(M,N_point); %��¼����άÿ���۲�������ֵ
for i=1:1:M
    for j=1:1:N_point
        if(location(i,j) == 1) %ֻɸѡ������άɸѡ֮��ĵ�
            if(j <= (N_prot_R + N_ref_R) ) %�۲�����ƫ������������
                threshold_R(i,j) = (sum(PC_data_ifft_CA_abs(i,(j+N_prot_R+1):(j+N_prot_R+N_ref_R))))/N_ref_R; %�۲���Ҳ�ο��������ƽ��
            elseif( j >= (N_point - N_prot_R - N_ref_R + 1)) %�۲�����ƫ�ң��Ҳ��������
                threshold_R(i,j) = (sum(PC_data_ifft_CA_abs(i,(j-N_prot_R-N_ref_R):(j-N_prot_R-1))))/N_ref_R; %�۲�����ο�����ƽ��
            else %�۲����У����ҵ������㹻
                sum_R_left = sum(PC_data_ifft_CA_abs(i,(j-N_prot_R-N_ref_R):(j-N_prot_R-1)));
                sum_R_right = sum(PC_data_ifft_CA_abs(i,(j+N_prot_R+1):(j+N_prot_R+N_ref_R)));
                threshold_R(i,j) = max(sum_R_left,sum_R_right)/(N_ref_R); %�۲������ȡ���һ�����ֵ
            end
        else
            threshold_R(i,j) = 0;
        end
    end
end
%���þ���ά���޽���һάɸѡ
location_R = zeros(M,N_point);
for i=1:1:M
    for j=1:1:N_point
        if(location(i,j) == 1) %ֻɸѡ������άɸѡ֮��ĵ�
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
%%%ɸѡ�����ʾ%%%
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
title('��άCFAR���һάʱ��CFAR��Ľ��(�ź�1��SNR=-5,�ź�2��SNR=2)/selected');axis tight;
xlabel('ʱ��/s','FontSize',12);ylabel('Ƶ��/Hz','FontSize',12);zlabel('�����(��崦ΪĿ��)','FontSize',12);

%%%%%%%%%%%����άɸѡ����%%%%%%%%%%%%%

%%%%%Ƶ��άɸѡ%%%%%
N_prot_F = 5;
N_ref_F = 10;
threshold_F = zeros(M,N_point); %��¼����άÿ���۲�������ֵ
for j=1:1:N_point
    for i=1:1:M
        if(location_R(i,j) == 1) %ֻɸѡ������άɸѡ�;���άɸѡ֮��ĵ�
            if(i <= (N_prot_F + N_ref_F) ) %�۲�����ƫ������������
                threshold_F(i,j) = (sum(PC_data_ifft_CA_abs((i+N_prot_F+1):(i+N_prot_F+N_ref_F),j)))/N_ref_F; %�۲���Ҳ�ο��������ƽ��
            elseif( i >= (M - N_prot_F - N_ref_F + 1)) %�۲�����ƫ�ң��Ҳ��������
                threshold_F(i,j) = (sum(PC_data_ifft_CA_abs((i-N_prot_F-N_ref_F):(i-N_prot_F-1),j)))/N_ref_F; %�۲�����ο�����ƽ��
            else %�۲����У����ҵ������㹻
                sum_F_left = sum(PC_data_ifft_CA_abs((i-N_prot_F-N_ref_F):(i-N_prot_F-1),j));
                sum_F_right = sum(PC_data_ifft_CA_abs((i+N_prot_F+1):(i+N_prot_F+N_ref_F),j));
                threshold_F(i,j) = max(sum_F_left,sum_F_right)/(N_ref_F); %�۲������ȡ���һ�����ֵ
            end
        else
            threshold_F(i,j) = 0;
        end
    end
end
%����Ƶ��ά���޽���һάɸѡ
location_R_F = zeros(M,N_point);
for i=1:1:M
    for j=1:1:N_point
        if(location_R(i,j) == 1) %ֻɸѡ������άɸѡ�;���άɸѡ֮��ĵ�
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
%%%ɸѡ�����ʾ%%%
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
title('��άCFAR���һάʱ��CFAR��һάƵ��CFAR��Ľ��(�ź�1��SNR=-5,�ź�2��SNR=2)/selected');axis tight;
xlabel('ʱ��/s','FontSize',12);ylabel('Ƶ��/Hz','FontSize',12);zlabel('�����(��崦ΪĿ��)','FontSize',12);
