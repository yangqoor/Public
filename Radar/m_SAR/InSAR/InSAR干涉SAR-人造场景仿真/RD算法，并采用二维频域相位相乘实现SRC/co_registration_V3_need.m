function s_B_new = co_registration_V3_need(s_A,s_B,N_UP)
% ������������ɡ�����׼������
% ���������� co_registration_V3�����������������С�����׼������Ҫ����
% ����ͼ��A�ʹ���׼���ͼ��B�ϴ�ֱ�ӽ���FFT�����㲻����ʵ�֣���ˣ�������
% �����˷ֿ飬���ֿ���ͼ����������������о���׼��Ȼ����׼������أ�
% ��������co_registration_V3�����У�ֻ��Ҫ���øú����������ٽ������ֿ����ϲ����ɡ�
% P.S.
%   ���ڽ���������������������׼ȡ���ʱ��Ҫ��ס���С���ֵ�ָ���������
%
% ���������
% 1��s_A �Ƿֿ������ A ��SLC-A��
% 2��s_B �Ƿֿ������ B �� SLC-B��
% 3��N_UP ���������ı�����
%
% ���������
% s_B_new ����ֿ���SLC-B���Ӧ�ģ���׼���ͼ��
%
% �ó����ֹ���� 2015.02.02. 17:44 p.m.
 
%%
% ------------------------------------------------------------------------
%                   ���ζ� s_A �� s_B ���ж�ά������
% ------------------------------------------------------------------------
[Naz,Nrg] = size(s_A);

% �� s_A ���ж�ά������
S_IMAG_A = fft2(s_A);      % ��SLC-A���ж�άFFT��������ж�άƵ���㡣
S_IMAG_A_UP = [S_IMAG_A(1:round(Naz/2),:);
               zeros((N_UP-1)*Naz,Nrg);
               S_IMAG_A(round(Naz/2)+1:end,:)];
S_IMAG_A_UP2 = [S_IMAG_A_UP(:,1:round(Nrg/2)),zeros(N_UP*Naz,(N_UP-1)*Nrg),S_IMAG_A_UP(:,round(Nrg/2)+1:end)];
s_A_UP = ifft2(S_IMAG_A_UP2);   % ifft�ص�ʱ����ɶ�SLC-A����������
clear S_IMAG_A;
clear S_IMAG_A_UP;
clear S_IMAG_A_UP2;

% �� s_B ���ж�ά������
S_IMAG_B = fft2(s_B);      % ��SLC-B���ж�άFFT��������ж�άƵ���㡣
S_IMAG_B_UP = [S_IMAG_B(1:round(Naz/2),:);
               zeros((N_UP-1)*Naz,Nrg);
               S_IMAG_B(round(Naz/2)+1:end,:)];
S_IMAG_B_UP2 = [S_IMAG_B_UP(:,1:round(Nrg/2)),zeros(N_UP*Naz,(N_UP-1)*Nrg),S_IMAG_B_UP(:,round(Nrg/2)+1:end)];
s_B_UP = ifft2(S_IMAG_B_UP2);   % ifft�ص�ʱ����ɶ�SLC-B����������
clear S_IMAG_B;
clear S_IMAG_B_UP;
clear S_IMAG_B_UP2;

%%
% ------------------------------------------------------------------------
%                               ������о���׼
% ------------------------------------------------------------------------
s_B_new = zeros(Naz,Nrg);       % s_B_new �д�Ÿ÷ֿ����׼�����
% Ϊ�˳���ļ�࣬�������Ƚ���������������ֱ�Ӵ��� s_B_new �С�
% ע�⣬�����Щ���ݲ�̫��Ҫ���������ڲ���ȫ������������������н�һ������
%      �������Щ����Ҳ����Ҫ����ô��Ҫ����Щ��������ݽ��е�������׼������
%      ������Һ������ⲿ�����ݵĴ���
s_B_new(1,:) = s_B(1,:);
s_B_new(end,:) = s_B(end,:);
s_B_new(:,1) = s_B(:,1);
s_B_new(:,end) = s_B(:,end);

[num_azi,num_rag] = size(s_B_UP);           % ��������ľ����С

mm = 1;
for pp = (1+N_UP) : N_UP : num_azi-N_UP      % ��1�к����һ�в��ü��㣬�����Ѿ���ֵ��
    nn = 2;
    mm = mm + 1;
    for qq = (1+N_UP) : N_UP : num_rag-N_UP  % ��1�к����һ�в��ü��㣬�����Ѿ���ֵ��
        s_A_UP_pp_qq = s_A_UP(pp-N_UP:pp+N_UP,qq-N_UP:qq+N_UP);
        s_B_UP_pp_qq = s_B_UP(pp-N_UP:pp+N_UP,qq-N_UP:qq+N_UP);
        % =================================================================
        %{
        % �������ϸ������ط�λ���б�������������ƽ�ƿ����ԣ����ƽ�������м��㡣
        % �������ǳ���
        R_pp_qq = zeros(2*N_UP+1,2*N_UP+1);
        
        for mov_azi = 1 : (2*N_UP+1)
            for mov_rag = 1 : (2*N_UP+1)
                tmp = circshift(s_B_UP_pp_qq,[mov_azi-21,mov_rag-21]);
                R_pp_qq(mov_azi,mov_rag) =  sum(sum(abs(s_A_UP_pp_qq).*abs(tmp)))/...
                    ( sqrt(sum(sum(abs(s_A_UP_pp_qq).^2)))*sqrt(sum(sum(abs(tmp).^2))) );
                clear tmp;
            end
        end
        
        [cor_R1,cor_p] = max(R_pp_qq);
        [cor_R2,cor_q] = max(max(R_pp_qq));
        % ���ֵλ���� �� cor_p(cor_q) , cor_q ��
        % ��Ӧ��ƽ����Ӧ���ǣ� �� cor_p(cor_q)-21 , cor_q-21 ��
        s_B_new(mm,nn) = s_B_UP(pp-(cor_p(cor_q)-21),qq-(cor_q-21));        
        %}
        %
        % �������ҵķ��������£������ڷ�λ�����λ�������ֻ������б�����ƽ�ƣ�
        % �򻯺�ĳ������£�
        R_pp_qq = zeros(1,2*N_UP+1);
        for mov_rag = 1 : (2*N_UP+1)           
            tmp = circshift(s_B_UP_pp_qq,[0,mov_rag-(N_UP+1)]);   
            R_pp_qq(1,mov_rag) =  sum(sum(abs(s_A_UP_pp_qq).*abs(tmp)))/...
                ( sqrt(sum(sum(abs(s_A_UP_pp_qq).^2)))*sqrt(sum(sum(abs(tmp).^2))) );
            clear tmp;
        end
        
        [cor_R1,cor_p] = max(R_pp_qq);
        % ���ֵλ���� �� cor_p ��
        % ��Ӧ��ƽ����Ӧ���ǣ� �� 0 , cor_p-(N_UP+1) ��
        s_B_new(mm,nn) = N_UP*N_UP*s_B_UP(pp,qq-(cor_p-(N_UP+1)));
        % ������� N_UP*N_UP ��Ŀ�ģ���Ϊ�ˡ���ֵ�ָ�����
        % ��Ϊ������N_UP*N_UP����������ʹ��ÿ����ķ�ֵ���͵�ԭ����1/(N_UP*N_UP)��
        % ������ѭ����ͬʱ�����˽���������һ����Ҫͬʱ���з�ֵ�ָ���ֻ��Ҫͨ��
        % ���� N_UP*N_UP ���ɣ�
        % =================================================================
        nn = nn+1;
    end
    mm              % ����Ϊ����ʾ���еĽ���
end

% s_B_new ��Ϊ����
% �� s_B_new ��Ϊ��������ֵ���õ��÷ֿ� s_B �ľ���׼�����

end