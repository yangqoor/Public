function s_ac = RDA_imaging(raw_data_type)
% ���������������ɵ�ԭʼ���ݳ���
% ���ã�
% 1������SRC�����ö�άƵ����λ��˵ķ������� RD �㷨
% 2����ѡ���Ƿ��������ʽ�˶�����
%
% ����ԭʼ����ʱ��
% 1��raw_data_type == 1���������� A ��Ӧ��ԭʼ���ݣ�
% 2��raw_data_type == 2���������� B ��Ӧ��ԭʼ���ݣ�
%
% ����汾��ֹ����
% 2014.12.16. 15:20 p.m.

%%
% ����ԭʼ����
if raw_data_type == 1
    load raw_data1_A;           % ��������A��Ӧ��ԭʼ����
%     load raw_data2_A
end
if raw_data_type == 2       
    load raw_data1_B;           % ��������B��Ӧ��ԭʼ����
%     load raw_data2_B;
end

%%
% --------------------------------------------------------------------
% ������LOS������˶������ǽ��С��˶�������������
% --------------------------------------------------------------------
r = tr_mtx.*c/2;        % �����˶��������б�� r��
% ��LOS������˶����
delta_r = delta_x_t.*( sqrt(r.^2-H^2)./r ) - delta_z_t.*(H./r); % ��LOS�����ܵ��˶����
delta_r = -delta_r*cos(sita_r_c);
delta_r_R0 = delta_x_t.*( sqrt(R0^2-H^2)/R0 ) - delta_z_t.*(H/R0); % ��LOS���򣬳������Ĵ����˶����ղ�����
delta_r_R0 = -delta_r_R0*cos(sita_r_c);

%%
% --------------------------------------------------------------------
% ����ѹ��������У����һ���˶�����
% --------------------------------------------------------------------
S_range = fft(s_echo,NFFT_r,2);     % ���о�������Ҷ�任����Ƶ�����ˡ�

%{
% ��ͼ
% ͼ2��������Ƶ�򣬷�λʱ��Ƶ�ף�δ����ѹ����
figure;
subplot(1,2,1);
imagesc(real(S_range));
title('��a��ʵ��');
xlabel('����Ƶ�򣨲����㣩');
ylabel('��λʱ�򣨲����㣩');
% text(1500,-60,'ͼ2������Ƶ��');       % ��ͼ2��������˵��
% text(1700,-20,'δѹ��');       
text(280,-60,'ͼ2������Ƶ��');       % ��ͼ2��������˵��
text(340,-10,'δѹ��');   

subplot(1,2,2);
imagesc(abs(S_range));
title('��b������');
xlabel('����Ƶ�򣨲����㣩');
ylabel('��λʱ�򣨲����㣩');
%}

%�����ɾ�����ƥ���˲���
% ====================================================
% ���÷�ʽ2
% ��ѹ���Ҫȥ���������� ������λ��ÿһ�еĽ�β�����ֱ��ȡȡǰ N_rg�� ��
%{
% ʱ�������壬ĩ�˲��㣬fft����ȡ�����
t_ref = ( -Nr/2 : (Nr/2-1) )/Fr;    % �������ɾ���MF�ľ���ʱ����
t_ref_mtx = ones(Naz,1)*t_ref;      % ������ʽ
w_ref = kaiser(Nr,2.5);             % �����򣬹���Kaiser������Ϊ��������
w_ref = ones(Naz,1)*(w_ref.');      % ���ɾ�����ʽ��ÿһ�ж���ͬ�ļӴ���

s_ref = exp((1j*pi*Kr).*((t_ref_mtx).^2)); % ���ƣ����䣩���壬δ�Ӵ���
% s_ref = w_ref.*exp((1j*pi*Kr).*((t_ref_mtx).^2)); % ���ƣ����䣩���壬���˴���

s_ref = [s_ref,zeros(Naz,Nrg-Nr)];      % �Ը������壬��˲��㡣
S_ref = fft(s_ref,NFFT_r,2);            % ��������ľ��븵��Ҷ�任����Ƶ�����ˡ�
H_range = conj(S_ref);                  % ������ƥ���˲�������Ƶ�����ˡ�
% ====================================================
% �������� ����У�� �� һ���˶���� �Ĳο�����

% ����У�����ο�����
He_fr = exp(1j*4*pi/c.*delta_r_R0.*fr_mtx); % ������Ƶ������
He_fr = fftshift(He_fr,2);  % ������Ƶ������

% һ���˶��������ο�����
Hc1 = exp(1j*4*pi/lamda.*delta_r_R0);   % ������Ƶ������
Hc1 = fftshift(Hc1,2);      % ������Ƶ������
% ====================================================
% �Ծ���Ƶ�׽��У�����ѹ�� + ����У�� + һ���˶�����
S_range_c = S_range.*H_range;
% S_range_c = S_range.*H_range.*He_fr.*Hc1;	% ��Ƶ�����ˡ�      
s_rc = ifft(S_range_c,[],2);            % ��ɾ���ѹ��������У����һ���˲����ص���άʱ��
% s_rc�ĳ���Ϊ��Naz*Nrg��δȥ����������

% ��s_rc����ȥ���������Ĳ���
% ����������Ϊ��2*��Nr-1��
% ���ǽ�ȡ�ĳ��ȣ���Nrg-Nr+1������Ϊ N_rg��
N_rg = Nrg-Nr+1;                        % ��ȫ����ĳ���
s_rc_c = zeros(Naz,N_rg);               % �������ȥ���������������
s_rc_c = s_rc(:,1:N_rg);                % ȡǰ N_rg�С�
%}
%--------------------------------------------------------------------------
% ���÷�ʽ3
% ��ѹ�����ȥ��������
%
H_range = exp(1j*pi.*fr_mtx.^2./Kr); % ֱ���ھ���Ƶ�����ɾ�����ƥ���˲�������Ƶ�����ģ�
H_range = fftshift(H_range,2);          % ����fftshift����Ƶ������
% ====================================================
% �������� ����У�� �� һ���˶���� �Ĳο�����

% ����У�����ο�����
He_fr = exp(1j*4*pi/c.*delta_r_R0.*fr_mtx); % ������Ƶ������
He_fr = fftshift(He_fr,2);  % ������Ƶ������

% һ���˶��������ο�����
Hc1 = exp(1j*4*pi/lamda.*delta_r_R0);   % ������Ƶ������
Hc1 = fftshift(Hc1,2);      % ������Ƶ������
% ====================================================
% �Ծ���Ƶ�׽��У�����ѹ�� + ����У�� + һ���˶�����
S_range_c = S_range.*H_range;
% S_range_c = S_range.*H_range.*He_fr.*Hc1;	% ��Ƶ�����ˡ�      
s_rc = ifft(S_range_c,[],2);            % ��ɾ���ѹ��������У����һ���˲����ص���άʱ��
% s_rc�ĳ���Ϊ��Naz*Nrg��δȥ����������

N_rg = Nrg;         % ���÷�ʽ3�����ɾ���MFʱ��ѹ�������ȥ����������
s_rc_c = s_rc;
%}
% ====================================================

%{
% ��ͼ
% ͼ3��������Ƶ�򣬷�λʱ��Ƶ�ף��ѡ�����ѹ�� + ����У�� + һ���˶���������
figure;
subplot(1,2,1);
imagesc(real(S_range_c));
title('��a��ʵ��');
xlabel('����Ƶ�򣨲����㣩');
ylabel('��λʱ�򣨲����㣩');
% text(1500,-60,'ͼ3������Ƶ��');       % ��ͼ3��������˵��
% text(1300,-20,'����ɣ�����ѹ�� + ����У�� + һ���˶�����');       
text(280,-60,'ͼ3������Ƶ��');       % ��ͼ3��������˵��
text(230,-15,'����ɣ�����ѹ�� + ����У�� + һ���˶�����');       

subplot(1,2,2);
imagesc(abs(S_range_c));
title('��b������');
xlabel('����Ƶ�򣨲����㣩');
ylabel('��λʱ�򣨲����㣩');
%}
%{
% ��ͼ
% ͼ4������άʱ���ѡ�����ѹ�� + ����У�� + һ���˶���������
figure;
subplot(1,2,1);
imagesc(real(s_rc_c));  %���⼰�����£���ֱ��ʹ��ȥ����������Ľ��
title('��a��ʵ��');
xlabel('����ʱ�򣨲����㣩');
ylabel('��λʱ�򣨲����㣩');
% text(1350,-60,'ͼ4����άʱ��');       % ��ͼ4��������˵��
% text(1250,-20,'����ɣ�����ѹ�� + ����У�� + һ���˶�����');       
text(150,-60,'ͼ4����άʱ��');       % ��ͼ4��������˵��
text(140,-15,'����ɣ�����ѹ�� + ����У�� + һ���˶�����');       

subplot(1,2,2);
imagesc(abs(s_rc_c));
title('��b������');
xlabel('����ʱ�򣨲����㣩');
ylabel('��λʱ�򣨲����㣩');
%}

%%
% --------------------------------------------------------------------
% �任����άƵ�򣬽���SRC
% --------------------------------------------------------------------
s_rc_c = s_rc_c.*exp(-1j*2*pi*fnc.*(ta.'*ones(1,N_rg)));    % ���ݰ���
S_2df = fft(s_rc_c,NFFT_a,1);        % ��λ����Ҷ�任���������������
S_2df = fft(S_2df,N_rg,2);   	% ��������Ҷ�任������άƵ��
% ������ע�⣺��������Ƶ�����ˡ�
% ====================================================================
% ���÷�λƵ���ᡪ�����ǹؼ���
fa = fnc + fftshift(-NFFT_a/2:NFFT_a/2-1)/NFFT_a*Fa; 	% ��λƵ����������á�
% =====================================================================
D_fn_Vr = sqrt(1-lamda^2.*(fa.').^2./(4*Vr^2));         % ��б�ӽ��µ��㶯����
K_src = 2*Vr^2*f0^3.*D_fn_Vr.^3./(c*R0*(fa.').^2);      % ������
K_src_1 = 1./K_src;             % ��������Ϊ�˺�����ʹ�þ���˷�������������
fr = ( -N_rg/2 : N_rg/2-1 )*( Fr/N_rg );        % ȥ���������󣬾���Ƶ����
H_src = exp(-1j*pi.*K_src_1*(fr.^2));           % ���ξ���ѹ���˲�������������Ƶ���м䡣
% ���Ǿ��󣬴�СNaz*N_rg
H_src = fftshift(H_src,2);      % �����Ұ�߻�������������Ƶ�����ˡ� ��������ܹؼ�������

S_2df_src = S_2df.*H_src;       % ��һ�����ʱ��Ҫע�����ߵľ�����Ƶ����Ӧ�ö�Ӧ�ϣ���Ȼ�������
% �����Ϊʲô����� H_src Ҫ fftshift ��ԭ�򣡣�

S_rd = ifft(S_2df_src,[],2);    	% ��ɶ��ξ���ѹ����SRC�����ص������������

%{
% ��ͼ
figure;
imagesc(abs(S_rd));
title('SRC�󣬾����������');
%}

%%
% --------------------------------------------------------------------
% ����������򣬽��о����㶯У��
% --------------------------------------------------------------------
% ÿһ�����б�ࣨR0�������ž����ŵĲ�ͬ���ı䡣
tr_RCMC = 2*R0/c + ( -N_rg/2 : (N_rg/2-1) )/Fr;   % ���µľ����߳����µ�ʱ���ᡣ
R0_RCMC = (c/2).*tr_RCMC;   % ������߱仯��R0����ΪR0_RCMC����������RCM��Ka��
delta_Rrd_fn = ((1-D_fn_Vr)./D_fn_Vr)*R0_RCMC;      % ��б�ӽ��µ�RCM

num_range = c/(2*Fr);   % һ�����������Ԫ����Ӧ�ĳ���
delta_Rrd_fn_num = delta_Rrd_fn./num_range; % ÿһ����λ��Ƶ�ʣ���RCM��Ӧ�ľ��������Ԫ��

R = 8;  % sinc��ֵ�˳���
S_rd_rcmc = zeros(NFFT_a,N_rg); % �������RCMC���ֵ

h = waitbar(0,'RCMC, please wait');
for p = 1 : NFFT_a
    for q = 1 : N_rg   % ��ʱ������ĳ����� (Nrg-Nr+1)=N_rg        
        delta_Rrd_fn_p = delta_Rrd_fn_num(p,q);
        Rrd_fn_p = q + delta_Rrd_fn_p;
        
        Rrd_fn_p = rem(Rrd_fn_p,N_rg);  % ����RCM�ĳ��Ȼᳬ��N_rg��������������һ�¡�
        
        Rrd_fn_p_zheng = ceil(Rrd_fn_p);        % ceil������ȡ����
        ii = ( Rrd_fn_p-(Rrd_fn_p_zheng-R/2):-1:Rrd_fn_p-(Rrd_fn_p_zheng+R/2-1)  );        
        rcmc_sinc = sinc(ii);
        rcmc_sinc = rcmc_sinc/sum(rcmc_sinc);   % ��ֵ�˵Ĺ�һ��
        % ii ��sinc��ֵ���̵ı���;
        % g(x)=sum(h(ii)*g_d(x-ii)) = sum(h(ii)*g_d(ll));
               
        % ����S_rdֻ��������ȡֵ���ҷ�Χ���ޡ���˲�ֵ��Ҫ��������ȡֵ����߽����⡣
        % �����Ҳ�ȡѭ����λ��˼�룬�������ȡֵ������⡣
        if (Rrd_fn_p_zheng-R/2) > N_rg    % ȫ����
            ll = (Rrd_fn_p_zheng-R/2-N_rg:1:Rrd_fn_p_zheng+R/2-1-N_rg);
        else
            if (Rrd_fn_p_zheng+R/2-1) > N_rg    % ��������
                ll_1 = (Rrd_fn_p_zheng-R/2:1:N_rg);
                ll_2 = (1:1:Rrd_fn_p_zheng+R/2-1-N_rg);
                ll = [ll_1,ll_2];
            else
                if (Rrd_fn_p_zheng+R/2-1) < 1    % ȫ���磨�����ܷ�����������Ҫ���ǣ�
                    ll = (Rrd_fn_p_zheng-R/2+N_rg:1:Rrd_fn_p_zheng+R/2-1+N_rg);
                else
                    if (Rrd_fn_p_zheng-R/2) < 1       % ��������
                        ll_1 = (Rrd_fn_p_zheng-R/2+N_rg:1:N_rg);
                        ll_2 = (1:1:Rrd_fn_p_zheng+R/2-1);
                        ll = [ll_1,ll_2];
                    else
                        ll = (Rrd_fn_p_zheng-R/2:1:Rrd_fn_p_zheng+R/2-1);
                    end                    
                end
            end
        end   
        rcmc_S_rd = S_rd(p,ll);
        S_rd_rcmc(p,q) = sum( rcmc_sinc.*rcmc_S_rd );
    end
    waitbar(p/NFFT_a);
end
close(h);
% S_rd_rcmc ����RCMC��ľ����������Ƶ�ס�

%{
% ��ͼ
% ͼ5���������������δRCMC��
figure;
subplot(1,2,1);
imagesc(real(S_rd));
title('��a��ʵ��');
xlabel('����ʱ�򣨲����㣩');
ylabel('��λƵ�򣨲����㣩');
% text(1350,-60,'ͼ5�������������');       % ��ͼ5��������˵��
% text(1550,-20,'δRCMC');     
text(150,-60,'ͼ5�������������');       % ��ͼ5��������˵��
text(172,-10,'δRCMC'); 

subplot(1,2,2);
imagesc(abs(S_rd));
title('��b������');
xlabel('����ʱ�򣨲����㣩');
ylabel('��λƵ�򣨲����㣩');
%}
%{
% ��ͼ
% ͼ6���������������RCMC��Ľ��
figure;
subplot(1,2,1);
imagesc(real(S_rd_rcmc));
title('��a��ʵ��');
xlabel('����ʱ�򣨲����㣩');
ylabel('��λƵ�򣨲����㣩');
% text(1350,-60,'ͼ6�������������');       % ��ͼ6��������˵��
% text(1550,-20,'��RCMC');    
text(150,-60,'ͼ6�������������');       % ��ͼ6��������˵��
text(172,-10,'��RCMC');

subplot(1,2,2);
imagesc(abs(S_rd_rcmc));
title('��b������');
xlabel('����ʱ�򣨲����㣩');
ylabel('��λƵ�򣨲����㣩');
%}

%%
%{
% --------------------------------------------------------------------
% �ص�ʱ�򣬽��ж����˶�����
% --------------------------------------------------------------------
% ����ȥ����������������������ڶ����˶�������б�� r Ҫ���¼���
r = ones(Naz,1)*R0_RCMC;
% ��������Ӧȥ����������������˶����
delta_x_t = a*sin(2*pi*w/La*Vr.*(ta.'*ones(1,N_rg)));   % �����صؾ� x ����˶����
% delta_x_t = 0;
% delta_z_t = a*sin(2*pi*w/La*Vr.*(ta.'*ones(1,N_rg)));   % ������ z ����˶����
delta_z_t = 0;

% ���㣬��LOS������˶����
delta_r = delta_x_t.*( sqrt(r.^2-H^2)./r ) - delta_z_t.*(H./r);% ��LOS�����ܵ��˶����
delta_r = -delta_r*cos(sita_r_c);
delta_r_R0 = delta_x_t.*( sqrt(R0^2-H^2)/R0 ) - delta_z_t.*(H/R0); % ��LOS���򣬳������Ĵ����˶����ղ�����
delta_r_R0 = -delta_r_R0*cos(sita_r_c);

% �����ڶ�άʱ����ж����˶�����
Hc2 = exp(1j*4*pi/lamda.*(delta_r-delta_r_R0)); % �����˶��������ο�����
s_rd_rcmc = ifft(S_rd_rcmc,[],1);   % ��RCMC��Ľ���任��ʱ��
s_rd_rcmc_MoCo = s_rd_rcmc.*Hc2;    % ���ж����˶�����

S_rd_rcmc_MoCo = fft(s_rd_rcmc_MoCo,[],1);  % �����˶������󣬱任�������������

figure;
subplot(1,2,1);
imagesc(real(S_rd_rcmc_MoCo));
title('��a��ʵ��');
xlabel('����ʱ�򣨲����㣩');
ylabel('��λƵ�򣨲����㣩');
% text(1350,-60,'���������');
% text(1250,-20,'����˶����˶�����');       
text(150,-60,'���������');
text(172,-15,'����˶����˶�����');      

subplot(1,2,2);
imagesc(abs(S_rd_rcmc_MoCo));
title('��b������');
xlabel('����ʱ�򣨲����㣩');
ylabel('��λƵ�򣨲����㣩');
%}

%%
% --------------------------------------------------------------------
% ��λѹ��
% --------------------------------------------------------------------
fa_azimuth_MF = fa;         % ��λƵ���ᣬ���ú�RCMC�����õ�Ƶ������ͬ��
Haz = exp(1j*4*pi.*(D_fn_Vr*R0_RCMC).*f0./c);   % ��б�ӽ��£��Ľ��ķ�λ��MF
% ����Ҫע�⣬���ɵ�MF����Ƶ�Ȳ��������ˣ�Ҳ���������ĵġ�
% ������Ƶ������ʲô���ģ���ϵ������ע��fa�Ĺ��ɡ�
% �����Ƶ����;����������ķ�λƵ���Ƕ�Ӧ�ġ�

S_rd_c = S_rd_rcmc.*Haz;            % ����ƥ���˲���������û�н��ж����˶�����ʱ���õģ�
% S_rd_c = S_rd_rcmc_MoCo.*Haz;       % ����ƥ���˲���
s_ac = ifft(S_rd_c,[],1);       	% ��ɷ�λѹ�����䵽ͼ���򡣽�����

% ��ͼ
% ͼ7����������
figure;
imagesc(abs(s_ac));
title('��Ŀ�����');
xlabel('����ʱ�򣨲����㣩');
ylabel('��λʱ�򣨲����㣩');    

%%
%{
% ����ͨ�����ú������õ���Ŀ�����Ƭ��������������
% ͬʱ�Ե�Ŀ����������������Ƭ����λ����Ƭ
% �������Ӧ��ָ�꣺PSLR��ISLR��IRW
% �ֱ�õ�ÿ����Ŀ�����Ƭ�Ŵ�����Ƭ������Ƭ������Ӧ��ָ��
NN = 20;
Fr = 60e6;                  % ���������
Fa = 200;                   % ��λ������
Vr = 150;                   % �״���Ч�ٶ�
target_1 = target_analysis( s_ac(2716-NN:2716+NN,1124-NN:1124+NN),Fr,Fa,Vr);
%}


%%
%{
% --------------------------------------------------------------------
% ���� 3*3 �Ĵ��ڣ����л���ƽ��
% �Դ���������ɰ�����
% --------------------------------------------------------------------
Nrg = N_rg;             % ��Ϊȥ�����������������򳤶�����
s_image = s_ac;         % ������
s_image_look = zeros(Naz,Nrg);      % ������Ż���ƽ����Ľ��

h = waitbar(0,'����3*3�Ĵ��ڣ����л���ƽ����please wait');
for p = 1 : Naz
    for q = 1 : Nrg
        count = 0;
        s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p,q));
        count = count + 1;
        if p>2 && p<(Naz-1) && q>2 && q<(Nrg-1)
            s_image_look(p,q) = s_image_look(p,q)+abs(s_image(p-1,q-1))+...
                abs(s_image(p-1,q))+abs(s_image(p-1,q+1))+abs(s_image(p,q-1))+...
                abs(s_image(p,q+1))+abs(s_image(p+1,q-1))+abs(s_image(p+1,q+1))+...
                abs(s_image(p+1,q+1));
            count = 9;
        else
            if (p-1) > 0
                s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p-1,q));
                count = count + 1;
                if (q-1) > 0
                    s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p-1,q-1));
                    count = count+1;
                end
                if (q+1) <= Nrg
                    s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p-1,q+1));
                    count = count+1;
                end
            end

            if (p+1) <= Naz
                s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p+1,q));
                count = count + 1;
                if (q-1) > 0
                    s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p+1,q-1));
                    count = count+1;
                end
                if (q+1) <= Nrg
                    s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p+1,q+1));
                    count = count+1;
                end
            end
            
            if (q-1) > 0
                s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p,q-1));
                count = count+1;
            end
            
            if (q+1) <= Nrg
                s_image_look(p,q) = s_image_look(p,q) + abs(s_image(p,q+1));
                count = count+1;
            end
        end
        s_image_look(p,q) = s_image_look(p,q)/count;    % ȡƽ��
    end
    waitbar(p/Naz);
end
close(h);
% ����Ϊֹ�����ǵõ��˻���ƽ����Ľ���� s_image_look
disp('���� 3*3 �Ĵ��ڣ����л���ƽ�����õ�������ɰߺ�Ľ��');

% ���������ʾ
figure;
imagesc(abs(s_image_look));
title('���� 3*3 �Ĵ��ڣ����л���ƽ�����õ�������ɰߺ�ĳ�����');
%}

end



