function PHY_s_after_median_filtering = Median_Filtering(PHY_s_after_flat_earth,window_M,window_N)
% ������ԭ����ڣ�      ����ת��ֵ�˲���
% P.S. ��ֵ��Ϊ��λ������ʾ��С�������е�һ�����У��м���Ǹ����֣������м����������ƽ����
% 
% ������������ȥƽ����λ��ĸ�����λ������ת��ֵ�˲���
% �÷����ο�������״����������8�£�8.5.2�ڡ�
%            ����� 306 ҳ �������
%
% ��������ֵ��
% 1�� PHY_s_after_flat_earth      ����ȥƽ����λ��ĸ�����λ����������λ����
% 2�� window_M �� window_N        ��ʾ����ת��ֵ�˲�����ѡ���Ĵ��ڴ�С��
% ��������ֵ��
% 1��PHY_s_after_median_filtering   ��ʾ����ת��ֵ�˲�����ĸ�����λ��Ҳ�ǲ�����λ����
%
% �������ֹ����2014.12.18. 14:15 p.m.

%%
% ------------------------------------------------------------------------
%                               ��ת��ֵ�˲�
% ------------------------------------------------------------------------
M = window_M;      % б����ƽ�����ڴ�С�����������
N = window_N;      % ��λ��ƽ�����ڴ�С�����������

[Naz,Nrg] = size(PHY_s_after_flat_earth);   % ���ݴ�С

disp('���ڽ��С���ת��ֵ�˲�������ȴ�');
h = waitbar(0,'���ڽ��С���ת��ֵ�˲�������ȴ�');
for pp = 1:Naz
    for qq = 1:Nrg
        % ���Ƚ��������жϣ�������window�Ƿ񳬹��˾���ı߽磺
        if pp<(N+1) || pp>(Naz-N) || qq<(M+1) || qq>(Nrg-M)
            % ���������������е��κ�һ����˵������λ�ھ���߽磬�������½�һ���ж�
            if (pp-N) < 1
                x_min = 1;
            else
                x_min = pp - N;
            end
            if (pp+N) > Naz
                x_max = Naz;
            else
                x_max = pp + N;
            end
            if (qq-M) < 1
                y_min = 1;
            else
                y_min = qq - M;
            end
            if (qq+M) > Nrg
                y_max = Nrg;
            else
                y_max = qq + M;
            end
            PHY_window = PHY_s_after_flat_earth(x_min:x_max,y_min:y_max);
        else
            % �������ĸ������������㣬˵�����ڲ�λ�ھ���߽磬�����ȡ��ȫ��
            % ��2N+1��*��2M+1�����㣬���ֱ�������������
            PHY_window = PHY_s_after_flat_earth(pp-N:pp+N,qq-M:qq+M);
        end
        
        % ������ݡ���ת��ֵ�˲����ķ������д���
        f_pp_qq_window = sum(sum(exp(1j*PHY_window)));
        tmp = angle(exp(1j*PHY_window)./f_pp_qq_window);
        tmp2 = reshape(tmp,1,[]);      % �����һ��X�е�һ��������������λ����
        median_tmp = median(tmp2);
        
        PHY_s_after_median_filtering(pp,qq) = angle(f_pp_qq_window) + median_tmp;
    end
    waitbar(pp/Naz);
end
close(h);

disp('����ת��ֵ�˲��������');


end