%% 
%    ��ά����SAR�����㷨
%    ���ߣ�Alex_Zikun
% 
%     ���ܣ��ȸ��ݵ�Ŀ��ֲ����������Ӧ����ʱ���ٸ��ݱ��ʽ����ز����ݽ��з��档�ٶԻز�����
%    ���о�����ͷ�λ���ϵ�����ѹ�����ó���άͼ��
% 
%    ʵ��Ҫ���¼��
%     1.��ά�ز��źŷ��ȡ���λ
%     2.����������ѹ������Ķ�ά�ȸ���ͼ
%     3.��Ŀ�����������λ�ȸ���ͼ������ͷ�λ����
%     4.��Hamming�����Ƴ���������
%%  �������������� 
clc;clear all;close all;
    v_c =3e+8;%����
    T =10e-6;%��������ʱ��
    Br=60e6;%���������
    lamda=0.03;%����
    f0=v_c/lamda;%��Ƶ
    vx=150;%�״�ƽ̨�˶��ٶ�
    R0=15e3;%�����������б��
    Kr=Br/T;%��Ƶб��
    Nr=2048;%�������������,����Ҫ����T*Br
    Fr=100e6;%���������Ƶ��
    deta_t=1/Fr;%���������ʱ����
    tr=2*R0/v_c+((0:Nr-1)-Nr/2)*deta_t;%���������ʱ����
    fr=((-Nr/2):(Nr/2-1))/Nr*Fr;
    PRF=100;%PRF
    Na=60;%��λ���������
    ta=((0:(Na-1))-Na/2)/PRF;
    T_sar=Na/PRF;%��λ�����ʱ��
    fa=((-Na/2):(Na/2-1))/Na*PRF;
    Ka=2*vx^2/(lamda*R0);
     
%% ����Ŀ�������ά�ز��ź�
    %%������õ�Ĳ���
    dot_num_a=1; % ��λ������
    deta_a=100; % ��λ�����
    dot_num_r=3; % ����������
    deta_r=600; % ���������
    dot_xy_cell=cell(1,dot_num_a);
    
    middle_point_r=ceil(dot_num_r/2);
    middle_point_a=ceil(dot_num_a/2);
    line_x=vx*ta;
    line_y=zeros(1,Na);
    
    for i_dot_num_a=1:dot_num_a
        dot_xy=zeros(dot_num_r,2);
     for i_dot_num_r=1:dot_num_r
      dot_xy(i_dot_num_r,2)=(i_dot_num_r-middle_point_r)*deta_r;
      dot_xy(i_dot_num_r,1)=(i_dot_num_a-middle_point_a)*deta_a;
     end
     dot_xy_cell{1,i_dot_num_a}=dot_xy;
    end

    slant_range_cell=cell(1,dot_num_a);
    %����ÿ���������з�λ��б��
    for i_dot_num_a=1:dot_num_a
        slant_range=zeros(dot_num_r,Na);%single
        dot_xy=dot_xy_cell{1,i_dot_num_a};
        for i_dot_num_r=1:dot_num_r
        slant_range(i_dot_num_r,:)=sqrt((line_y-(R0+dot_xy(i_dot_num_r,2))).^2+(line_x-dot_xy(i_dot_num_r,1)).^2);%???
        end
        slant_range_cell{1,i_dot_num_a}=slant_range;
    end
    %����ÿ���������з�λ��ʱ��
    t_delay_cell=cell(1,dot_num_a);
    for i_dot_num_a=1:dot_num_a
         slant_range=slant_range_cell{1,i_dot_num_a};
         t_delay=slant_range*2/v_c;%single
         t_delay_cell{1,i_dot_num_a}=t_delay;
    end
    echo_data=zeros(Nr,Na);
    tr_matrix=repmat(tr.',1,Na);%���󻯴���
    for i_dot_num_a=1:dot_num_a
        t_delay= t_delay_cell{1,i_dot_num_a};
       for i_dot_num_r=1:dot_num_r
       t_delay_matrix=repmat(t_delay(i_dot_num_r,:),Nr,1);%���󻯴���
       echo_data=echo_data+rect((tr_matrix-t_delay_matrix)/T).*exp(1j*pi*Kr*(tr_matrix-t_delay_matrix).^2).*exp(-1j*2*pi*f0*t_delay_matrix);
       end
    end
    echo_data_phase=unwrap(angle(echo_data));
% ���ͼ��
    figure;
    subplot(2,1,1)
    imagesc(abs(echo_data));title('��ά�źŵķ���');
    subplot(2,1,2)
    imagesc(echo_data_phase);title('��ά�źŵ���λ');
 %% ����ѹ��
 %����������ѹ��
    Echo=circshift(fft2(circshift(echo_data,[-Nr/2,-Na/2])),[Nr/2,Na/2]);
    ref=exp(1j*pi*fr.^2/Kr);
    ref_matrix=repmat(ref.',1,Na);% �������άƥ���˲���
    COMP=Echo.*ref_matrix; % ������ƥ���˲���Ƶ��

 %��λ������ѹ��
    fr_matrix=repmat(fr.',1,Na);
    fa_matrix=repmat(fa,Nr,1);
    Haz=exp(-1j*pi.*(fa.^2)./Ka);
    Haz_matrix=repmat(Haz,Nr,1); % ��λ���άƥ���˲���
    SAC=COMP.*Haz_matrix; % �پ���λ������ѹ����
    
%     [a b]=find(SAC==max(max(SAC))); % �ҳ����ֵ
%     figure;plot(abs(SAC(:,31)));
%     figure;plot(abs(SAC(1599,:)));
    sac=circshift(ifft2(circshift(SAC,[0,0])),[Nr/2,Na/2]); % ʱ��ͼ��
    figure;
    subplot(2,1,1)
    imagesc(abs(sac));title('��Ŀ�����ʱ����')
    subplot(2,1,2)
    imagesc(abs(SAC));title('��Ŀ�����Ƶ����')
%% ����Hamming��
    window=hamming(1151)*hamming(37).';
    window_hamming=zeros(2048,60);
    xx=10;
    window_hamming(450+xx:1600+xx,13:49)=window;
    WINDOW_data=window_hamming.*SAC;
    window_data=circshift(ifft2(circshift(WINDOW_data,[0,0])),[Nr/2,Na/2]);
    figure;
    subplot(2,1,1)
    imagesc(abs(window_data));title('��Hamming����ʱ��')
    subplot(2,1,2)
    imagesc(abs(WINDOW_data));title('��Hamming����Ƶ��')
%% ����ͼ
    i_x=1; % ��i����
    i_y=1;

    x=1025+300*(i_x-1);
    y=31+400*(i_y-1);
    pou=sac(x-10:x+9,y-10:y+9); % ��ȡ
    pou_range=pou(1:20,11);
    pou_azimuth=pou(11,1:20);
    range_db=ifft([fft(pou_range);zeros(980,1)]);
    tr_db=linspace(tr(x-10),tr(x+10),1000);

    azimuth_db=ifft([fft((pou_azimuth).');zeros(980,1)]);
    ta_db=linspace(ta(y-10),ta(y+10),1000);

    POU=fft2(pou);
    POU1=zeros(1000,1000);
    POU1(1:20,1:20)=POU;
    pou1=ifft2(POU1);
    a=max(abs(pou1));
    b=max(a);
    pou1_db=20*log10(abs(pou1)/b);
    c=max(pou1_db);
    dgx1=[-3 -13 -20 -30];
    figure;
    subplot(2,1,1)
    contour(pou1_db,dgx1);
    title('-3 -13 -20 -30(db)���Ӵ�ʱ��άͼ��');
    xlabel('��λ��(m)');ylabel('������(m)');
% �Ӵ�
    pou2=window_data(x-10:x+9,y-10:y+9);

    pou_range2=pou2(1:20,11);
    pou_azimuth2=pou2(11,1:20);
    range_db2=ifft([fft(pou_range2);zeros(980,1)]);
    tr_db=linspace(tr(x-10),tr(x+10),1000);

    azimuth_db2=ifft([fft((pou_azimuth2).');zeros(980,1)]);
    ta_db=linspace(ta(y-10),ta(y+10),1000);

    POU=fft2(pou2);
    POU1=zeros(1000,1000);
    POU1(1:20,1:20)=POU;
    pou1=ifft2(POU1);
    a=max(abs(pou1));
    b=max(a);
    pou1_db=20*log10(abs(pou1)/b);
    c=max(pou1_db);
    dgx2=[-3 -13 -20 -30];
    subplot(2,1,2)
    contour(pou1_db,dgx2);
    title('-3 -13 -20 -30(db)�Ӵ�ʱ��άͼ��');
    xlabel('��λ��(m)');ylabel('������(m)');
    
% �Ӵ��Ա����
    figure;
    subplot(2,2,1)
    plot(tr_db,20*log10(abs(range_db)/max(abs(range_db))));
    title('���Ӵ��ľ�����')
    subplot(2,2,2)
    plot(ta_db,20*log10(abs(azimuth_db)/max(abs(azimuth_db))));
    title('���Ӵ��ķ�λ��')
    subplot(2,2,3)
    plot(tr_db,20*log10(abs(range_db2)/max(abs(range_db2))));
    title('�Ӵ��ľ�����')
    subplot(2,2,4)
    plot(ta_db,20*log10(abs(azimuth_db2)/max(abs(azimuth_db2))));
    title('�Ӵ��ķ�λ��')
    
   






