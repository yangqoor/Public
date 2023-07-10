function Coherence_imag = calculate_coherence(s_imag_A,s_imag_B)
% ������������������ͼ����������ԣ�
% ������
% 1��ֻ���÷�����Ϣ���㣻��˵õ����Ƿ������ϵ��ͼ��
% 2������3*3�Ĵ��ڼ���ÿһ��Ļ����ϵ����
% �������ݣ�
% 1��s_imag_A �����ͼ�� A��
% 2��s_imag_B �����ͼ�� B��
% ������ݣ�
% Cohorence_imag �Ƿ��صķ������ϵ��ͼ
%
% �ó����ֹ�� 2015.01.04. 22:15 p.m.

%%
% ------------------------------------------------------------------------
%                           ���㡰�������ϵ��ͼ��
% ------------------------------------------------------------------------
% �������ϵ��ͼѡ��Ĵ��ڴ�С����2N+1��*��2M+1������Ϊ��3*3�����£�
N = 1;
M = 1;

[Naz,Nrg] = size(s_imag_A);   % ���ݴ�С

disp('���ڼ��㡰�������ϵ��ͼ������ȴ�');
h = waitbar(0,'���ڼ��㡰�������ϵ��ͼ������ȴ�');
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
            tmp_A = s_imag_A(x_min:x_max,y_min:y_max);
            tmp_B = s_imag_B(x_min:x_max,y_min:y_max);
        else
            % �������ĸ������������㣬˵�����ڲ�λ�ھ���߽磬�����ȡ��ȫ��
            % ��2N+1��*��2M+1�����㣬���ֱ�������������
            tmp_A = s_imag_A(pp-N:pp+N,qq-M:qq+M);
            tmp_B = s_imag_B(pp-N:pp+N,qq-M:qq+M);
        end
        
        % �������õ㣨pp,qq���ķ������ϵ��ֵ��
        Coherence_imag(pp,qq) = sum(sum(abs(tmp_A).*abs(tmp_B)))/...
            ( sqrt(sum(sum(abs(tmp_A).^2)))*sqrt(sum(sum(abs(tmp_B).^2))) );
        clear tmp_A;clear tmp_B;
    end
    waitbar(pp/Naz);
end
close(h);

disp('��ɡ��������ϵ��ͼ������');


end