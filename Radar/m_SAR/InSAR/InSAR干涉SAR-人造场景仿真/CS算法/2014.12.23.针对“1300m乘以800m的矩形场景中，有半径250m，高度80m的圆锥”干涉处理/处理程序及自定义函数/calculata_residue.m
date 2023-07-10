function [PHY_residue,residue_count] = calculata_residue(PHY_s_after_X_filtering)
% �������������㾭��ǰ�沽������õ��ĸ�����λͼ�Ĳв�㣻
% �������ݣ�
%   PHY_s_after_X_filtering  ��ʾ����ĳ���˲�������ĸ�����λͼ��
% ������ݣ�
%   1��PHY_residue  ��ʾ����õ��Ĳв�㣻
%   2��residue_count ��ʾ�в����������������в�㣩��
%
% ˼·��
%   ������ĸ�����λͼΪ�������������У��ԣ�m,n��Ϊ��һ��ֵ��2*2���ڣ����ĸ����
%   ��·���ּ��㡣�������������±�ע��
%   1�����˳ʱ�뻷·���ּ�����Ϊ2�У���Ϊ���е㣬��(m,n)���Ϊ +1��
%   2�����˳ʱ�뻷·���ּ�����Ϊ-2�У���Ϊ���е㣬��(m,n)���Ϊ -1��
%   3�������·����Ϊ0����˵��û�ве㣬��(m,n)���Ϊ 0��
%   ȫ��������ɺ󣬷��� PHY_residue�����������¼�����б�ǽ�����Դ���Ϊ�в��
%   ��������
%
% �����ֹ���� 2014.12.18. 15:16 p.m.

%%
% ------------------------------------------------------------------------
%                               ����в��
% ------------------------------------------------------------------------
% ˼·��
%   ������ĸ�����λͼΪ�������������У��ԣ�m,n��Ϊ���ĵ�2*2���ڣ����ĸ����
%   ��·���ּ��㡣�������������±�ע��
%   1�����˳ʱ�뻷·���ּ�����Ϊ2�У���Ϊ���е㣬��(m,n)���Ϊ +1��
%   2�����˳ʱ�뻷·���ּ�����Ϊ-2�У���Ϊ���е㣬��(m,n)���Ϊ -1��
%   3�������·����Ϊ0����˵��û�ве㣬��(m,n)���Ϊ 0��
%   ȫ��������ɺ󣬷��� PHY_residue�����������¼�����б�ǽ�����Դ���Ϊ�в��
%   ��������

[Naz,Nrg] = size(PHY_s_after_X_filtering);   % ���ݴ�С
PHY_residue = zeros(Naz,Nrg);   % �� 0 ��ʼֵ
residue_count = 0;              % �Բв�㣨���������в�㣩����

disp('���ڽ��вв����㣬��ȴ�');
h = waitbar(0,'���ڽ��вв����㣬��ȴ�');
for pp = 1:Naz-1
    for qq = 1:Nrg-1
        delta_1 = PHY_s_after_X_filtering(pp,qq+1) - PHY_s_after_X_filtering(pp,qq);
        if delta_1 > pi
            delta_1 = delta_1 - 2*pi;
        end
        if delta_1 < -1*pi
            delta_1 = delta_1 + 2*pi;
        end
        
        delta_2 = PHY_s_after_X_filtering(pp+1,qq+1) - PHY_s_after_X_filtering(pp,qq+1);
        if delta_2 > pi
            delta_2 = delta_2 - 2*pi;
        end
        if delta_2 < -1*pi
            delta_2 = delta_2 + 2*pi;
        end
        
        delta_3 = PHY_s_after_X_filtering(pp+1,qq) - PHY_s_after_X_filtering(pp+1,qq+1);
        if delta_3 > pi
            delta_3 = delta_3 - 2*pi;
        end
        if delta_3 < -1*pi
            delta_3 = delta_3 + 2*pi;
        end
        
        delta_4 = PHY_s_after_X_filtering(pp,qq) - PHY_s_after_X_filtering(pp+1,qq);
        if delta_4 > pi
            delta_4 = delta_4 - 2*pi;
        end
        if delta_4 < -1*pi
            delta_4 = delta_4 + 2*pi;
        end
        
        delta = delta_1 + delta_2 + delta_3 + delta_4;
        if delta == 2*pi
            PHY_residue(pp,qq) = 1;
            residue_count = residue_count + 1;
        end
        if delta == -2*pi
            PHY_residue(pp,qq) = -1;
            residue_count = residue_count + 1;
        end
    end
    waitbar(pp/(Naz-1));
end
close(h);

disp('��ɲв�����');


end