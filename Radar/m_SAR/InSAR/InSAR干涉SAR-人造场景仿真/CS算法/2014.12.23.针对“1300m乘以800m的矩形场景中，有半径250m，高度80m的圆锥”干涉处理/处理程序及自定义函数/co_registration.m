function  [s_imag_B_after_CoRe,R] = co_registration(s_imag_A,s_imag_B)
% ���������������ɵ����� SLC ���С�ͼ����׼��
% ������ A ��SLC-A��Ϊ�ο��������� B ��SLC-B����ͼ�񣩽��С���׼����
% ʵ�ַ�����
%   ��Ϊ����������׼�;���׼��
%   1������׼������������ϵ������
%      �ֱ����SLC-B�ز�ͬ��λ�;���ƽ�ƺ���SLC-A�����ϵ���������ϵ�����
%      ʱ����Ϊ����׼��Ҫ���õ�ƽ������
%   2������׼������δ��ɣ�
%
% ���������
% 1��s_imag_A������ A ��SLC-A��
% 2��s_imag_B ������ B �� SLC-B��
% ���������
% 1��s_imag_B_after_CoRegistration ��׼���SLC-Bͼ��
% 2��R �Ǵ���׼ʱ����õ��Ĳ�ͬƽ����ʱ�����ϵ����
%
% �ó����ֹ����2014.12.22. 17:05 p.m.

%%
disp('���ڽ��С�ͼ����׼������ȴ�')
%*************************************************************************
%                        �������Ƚ��С�����׼��
%*************************************************************************

% -----------------------------------------------------------------------
%           ��������ͼ���ڲ�ͬ��λ�;���ƫ�ƴ��Ļ����ϵ�� R
% -----------------------------------------------------------------------
% ���÷��ȼ��㣬�õ����Ȼ����Ϊ��
for pp = 1:5            % pp �����ط�λ�����ƫ��
    for qq = 1: 5       % qq ������б�෽���ƫ��
        tmp = circshift(s_imag_B,[pp-1,qq-1]);
        R(pp,qq) = sum(sum(abs(s_imag_A).*abs(tmp)))/...
            ( sqrt(sum(sum(abs(s_imag_A).^2)))*sqrt(sum(sum(abs(tmp).^2))) );
        clear tmp;
    end
end
[cor_R1,cor_p] = max(R);
[cor_R2,cor_q] = max(max(R));
% ע�⣺
%   1�����ǵõ��ģ�cor_p(cor_q)��cor_q�������ϵ�� R ���ֵ��λ�ã�
%   2��������׼��Ҫ�ƶ��Ĵ�С���������أ�
%   3����Ҫ�ƶ��Ĵ�С�ǣ���cor_p(cor_q)-1��cor_q-1��

% -----------------------------------------------------------------------
%                       ������ B �ĳ��������д���׼
% -----------------------------------------------------------------------
% s_imag_B_2 ���Ǿ�������׼��Ľ�������£�
s_imag_B_2 = circshift(s_imag_B,[cor_p(cor_q)-1,cor_q-1]); 

s_imag_B_after_CoRe = s_imag_B_2;
%%
%*************************************************************************
%                               ������׼��
%*************************************************************************
% �����ڴ���׼�Ļ����Ͻ��С�����׼��




%{
% ���� sinc ��ֵ�����ڶ���ͼ����С�������׼��
%       �������ƽ���RCMC��ֻ�����������ͼ�������ƽ����������ͬ�ģ�Ϊ delta_N��
R = 16;              % sinc��ֵ�˳���
[num_azi,num_rag] = size(s_imag_B);
s_imag_B_after_CoRegistration = zeros(num_azi,num_rag); % �������������׼���ֵ
disp('���ڽ��в�ֵ���㣬��ȴ�');
h = waitbar(0,'���ڽ��в�ֵ���㣬��ȴ�');
for pp = 1 : num_azi
    for qq = 1 : num_rag
        N_pp_qq = qq + delta_N;  
        N_pp_qq = rem(N_pp_qq,num_rag);   
        N_pp_qq_zheng = ceil(N_pp_qq);        % ceil������ȡ����
        ii = ( N_pp_qq-(N_pp_qq_zheng-R/2):-1:N_pp_qq-(N_pp_qq_zheng+R/2-1)  );        
        registration_sinc = sinc(ii);
        registration_sinc = registration_sinc/sum(registration_sinc);   % ��ֵ�˵Ĺ�һ��
        % ii ��sinc��ֵ���̵ı���;
        % g(x)=sum(h(ii)*g_d(x-ii)) = sum(h(ii)*g_d(ll));
               
        % ����s_imag_Bֻ��������ȡֵ���ҷ�Χ���ޡ���˲�ֵ��Ҫ��������ȡֵ����߽����⡣
        % �����Ҳ�ȡѭ����λ��˼�룬�������ȡֵ������⡣
        if (N_pp_qq_zheng-R/2) > num_rag    % ȫ����
            ll = (N_pp_qq_zheng-R/2-num_rag:1:N_pp_qq_zheng+R/2-1-num_rag);
        else
            if (N_pp_qq_zheng+R/2-1) > num_rag    % ��������
                ll_1 = (N_pp_qq_zheng-R/2:1:num_rag);
                ll_2 = (1:1:N_pp_qq_zheng+R/2-1-num_rag);
                ll = [ll_1,ll_2];
            else
                if (N_pp_qq_zheng+R/2-1) < 1    % ȫ���磨�����ܷ�����������Ҫ���ǣ�
                    ll = (N_pp_qq_zheng-R/2+num_rag:1:N_pp_qq_zheng+R/2-1+num_rag);
                else
                    if (N_pp_qq_zheng-R/2) < 1       % ��������
                        ll_1 = (N_pp_qq_zheng-R/2+num_rag:1:num_rag);
                        ll_2 = (1:1:N_pp_qq_zheng+R/2-1);
                        ll = [ll_1,ll_2];
                    else
                        ll = (N_pp_qq_zheng-R/2:1:N_pp_qq_zheng+R/2-1);
                    end                    
                end
            end
        end   
        rcmc_r_imag_B = s_imag_B(pp,ll);
        s_imag_B_after_CoRegistration(pp,qq) = sum( registration_sinc.*rcmc_r_imag_B );
    end
    waitbar(pp/num_azi);
end
close(h);
% s_imag_B_after_CoRegistration ���� s_imag_B ����������׼��Ľ��
%}


disp('��ɶ����� B �� SLC-B �ġ�ͼ����׼��');

end