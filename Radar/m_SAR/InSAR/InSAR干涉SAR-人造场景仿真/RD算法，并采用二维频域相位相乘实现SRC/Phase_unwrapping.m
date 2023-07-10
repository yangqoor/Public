function PHY_after_unwrapping = Phase_unwrapping(PHY_s_after_X_filtering)
% �����������ڲв�����Ϊ 0 ʱ������λ����ƣ�
% ����������    ע��   ����������
% ���в�����Ϊ 0 ʱ���ſ���ʹ�ñ�����������λ����ƣ�
% �������ݣ�
%   PHY_s_after_X_filtering  ��ʾ����ĳ���˲�������ĸ�����λͼ��
% ������ݣ�
%   PHY_after_unwrapping  ��ʾ��λ����ƺ����λͼ��
%
% ˼·��
%   ��ʱ���ֽ����·���޹أ��ʿ���ѡ�����·�����£�
%       a���ȴ������ҽ���Ƶ�һ�У��ٴ������·ֱ����Ƹ��У�
%       b���ȴ��ϵ��½���Ƶ�һ�У��ٴ������ҷֱ����Ƹ��У�
%   �������ѡ���������ֻ���·���е�ĳһ�ֽ�����λ�����
%  ע�⣺
%   �Ҿ���������֤�������ֻ���·���Ľ���ƽ��ֻ�����ԼΪ 10^(-14) �η�����
%   ��ˣ�������Ϊ�����ֻ���·���µĽ���ƽ������ͬ�ġ�
%   Ҳͬʱ˵�����в�����Ϊ 0 ʱ�����ֽ���������·���޹صġ�
%
% �����ֹ���� 2014.12.18. 16:35 p.m.

%%
% ------------------------------------------------------------------------
%                               ��λ�����
% ------------------------------------------------------------------------
% ע�⣺
% ���������·��������Ӧ����һ�µġ�
% ѡ�����е�һ��·��������λ����Ƶļ��㼴�ɡ�
% ��Ҫͬʱ������·����ѡ�ϣ���

[Naz,Nrg] = size(PHY_s_after_X_filtering);   % ���ݴ�С

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ·��1�� 
%   �ȴ������ҽ���Ƶ�һ�У��ٴ������·ֱ����Ƹ��У�
disp('���ڽ��ж�ά��λ����ƣ���ȴ�');

% �������Ƚ���һ��ֵ��ֵ������ƺ�ĵ�һ��ֵ���Դ�Ϊ����
PHY_after_unwrapping(1,1) = PHY_s_after_X_filtering(1,1);
% ����������ҽ���Ƶ�һ��
for qq = 2:Nrg
    delta_qq = PHY_s_after_X_filtering(1,qq) - PHY_s_after_X_filtering(1,qq-1);
    if delta_qq > pi
        delta_qq = delta_qq - 2*pi;
    end
    if delta_qq < -1*pi
        delta_qq = delta_qq +2*pi;
    end
    PHY_after_unwrapping(1,qq) = PHY_after_unwrapping(1,qq-1) + delta_qq;
end
% ����ֱ�������·ֱ����Ƹ���
for qq = 1:Nrg
    for pp = 2:Naz
        delta_qq_pp = PHY_s_after_X_filtering(pp,qq) - PHY_s_after_X_filtering(pp-1,qq);
        if delta_qq_pp > pi
            delta_qq_pp = delta_qq_pp - 2*pi;
        end
        if delta_qq_pp < -1*pi
            delta_qq_pp = delta_qq_pp + 2*pi;
        end 
        PHY_after_unwrapping(pp,qq) = PHY_after_unwrapping(pp-1,qq) + delta_qq_pp;
    end
end
disp('��ɶ�ά��λ�����')
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
% ·��2
%   �ȴ��ϵ��½���Ƶ�һ�У��ٴ������ҷֱ����Ƹ��У�
disp('���ڽ��ж�ά��λ����ƣ���ȴ�');

% �������Ƚ���һ��ֵ��ֵ������ƺ�ĵ�һ��ֵ���Դ�Ϊ����
PHY_after_unwrapping(1,1) = PHY_s_after_X_filtering(1,1);
% �ȴ��ϵ��½���Ƶ�һ��
for pp = 2:Naz
    delta_pp = PHY_s_after_X_filtering(pp,1) - PHY_s_after_X_filtering(pp-1,1);
    if delta_pp > pi
        delta_pp = delta_pp - 2*pi;
    end
    if delta_pp < -1*pi
        delta_pp = delta_pp + 2*pi;
    end
    PHY_after_unwrapping(pp,1) = PHY_after_unwrapping(pp-1,1) + delta_pp;
end
% ����ֱ�������ҷֱ����Ƹ���
for pp = 1:Naz
    for qq = 2:Nrg
        delta_pp_qq = PHY_s_after_X_filtering(pp,qq) - PHY_s_after_X_filtering(pp,qq-1);
        if delta_pp_qq > pi
            delta_pp_qq = delta_pp_qq - 2*pi;
        end
        if delta_pp_qq < -1*pi
            delta_pp_qq = delta_pp_qq + 2*pi;
        end 
        PHY_after_unwrapping(pp,qq) = PHY_after_unwrapping(pp,qq-1) + delta_pp_qq;
    end
end
disp('��ɶ�ά��λ�����')
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end