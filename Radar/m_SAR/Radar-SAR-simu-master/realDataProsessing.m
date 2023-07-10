%% 
%    ��ά����SAR���񡪡�ʵ�����ݴ���
%    ���ߣ�Alex_Zikun
% 
%    ���ܣ�ʵ������Ϊ��άSAR�ز����ݣ���Ҫ�ֱ�Է�λ��;������Ͻ�������ѹ�����ó���ͼ�񾭹�
%    �򵥵�����ͼ�������

%%  �������������� 
    clc;clear all;close all;
    load('raw_data_4k4k.mat');
    v_c =3e+8;%����
    Tp =44.172e-6;%��������ʱ��
    Br=59.44e6;%���������
    lamda=0.055;%����
    f0=v_c/lamda;%��Ƶ
    vx=7200;%�״�ƽ̨�˶��ٶ�
    R0=820e3;%�����������б��
    Kr=Br/Tp;%��Ƶб��
    Nr=4096;%�������������,����Ҫ����Tp*Br
    Fr=66.72839509333333e6;%���������Ƶ��
    deta_t=1/Fr;%���������ʱ����
    tr=2*R0/v_c+((0:Nr-1)-Nr/2)*deta_t;%���������ʱ����
    fr=((-Nr/2):(Nr/2-1))/Nr*Fr;
    PRF=1925;%PRF
    Na=4096;%��λ���������
    ta=((0:(Na-1))-Na/2)/PRF;
    T_sar=Na/PRF;%��λ�����ʱ��
    fa=((-Na/2):(Na/2-1))/Na*PRF;
    theata_syn=2*atan(T_sar*vx/2/R0);%
    Ka=2*vx^2/(lamda*R0);
%%
    Echo=circshift(fft2(circshift(raw_data,[-Nr/2,-Na/2])),[Nr/2,Na/2]);% �任��Ƶ��
    fr_matrix=repmat(fr.',1,Na); % ����������ѹ��
    fa_matrix=repmat(fa,Nr,1); % ��λ������ѹ��
    ref=exp(1j*pi*fr_matrix.^2/Kr);
    COMP=ref.*Echo; % ���������������ѹ��

    Haz=exp(-1j*pi.*(fa_matrix.^2)./Ka);
    SAC=COMP.*Haz; % �����귽λ������ѹ��
    sac=circshift(ifft2(circshift(SAC,[-Nr/2,-Na/2])),[Nr/2,Na/2]);
    picture=abs(sac)/max(max(abs(sac)));
%% ͼ����
%     figure
%     imshow(raw_data);title('����ǰ')
    picture2=histeq(abs(picture)); % ֱ��ͼ���⻯
    picture2= filter2(fspecial('average',3),picture2)-0.3; % ƽ��ֵ�˲����봦��
    figure
    imshow(picture2);title('�����')
    imwrite(picture2,'SAR_image.jpg');