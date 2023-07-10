function PHY_after_unwrapping = Quality_Guided_Path_Follower(PHY_s_after_X_filtering,Coherence_imag)
% ���������á�����ָ����·�����ٷ���������λ�����
% �ο���
% 1�������ȵġ����غϳɿ׾��״�����������111ҳ����4.4.2�ڡ�����ָ����·�����ٷ�����
% 2����Two Dimensional Phase Unwrapping Theory Algorithms and Software����
%
% �������ݣ�
%   1��PHY_s_after_X_filtering  ��ʾ����ĳ���˲�������ĸ�����λͼ��
%   2��Cohorence_imag ����ͼ���Ҳ��õ��Ƿ������ϵ��ͼ��
% ������ݣ�
%   PHY_after_unwrapping  ��ʾ��λ����ƺ����λͼ��
%
% �����ֹ���� 2015.01.07. 20:33 p.m.

%%
disp('����ʹ�á�����ָ����·�����ٷ���������λ����ƣ���ȴ�');

[Naz,Nrg] = size(PHY_s_after_X_filtering);      % ���ݴ�С
PHY_after_unwrapping = zeros(Naz,Nrg);          % ��Ž������λ���  
% ------------------------------------------------------------------------
%                           ѡ����ʼ��
%               ���Ӹ���ʼ�㿪ʼ��λ����Ƶĵ�һ��
% ------------------------------------------------------------------------
% **********************************************************************
%                              ѡ����ʼ��
% **********************************************************************
Coherence_imag2 = zeros(Naz,Nrg);
Coherence_imag2(2:end-1,2:end-1) = Coherence_imag(2:end-1,2:end-1);

[corR1,cor_p] = max(Coherence_imag2);
[corR2,cor_q] = max(max(Coherence_imag2));
% �����ֵλ���ǣ���cor_p(cor_q)��cor_q��
clear Coherence_imag2;

% **********************************************************************
%                         �Դ���ʼ�㿪ʼ��λ�����
% **********************************************************************
% ��1�����ȴ���������
unwrap_start_x = cor_p(cor_q);
unwrap_start_y = cor_q;
% ������λ���������꣬Ҳ������ͼ���ֵλ��

% ��2��ֱ�ӽ����������λ�ģ�����ͼ���ֵλ������Ӧ��ֵ����ڽ���ƺ�Ľ����
%      ��Ϊ���
PHY_after_unwrapping(unwrap_start_x,unwrap_start_y) = ...
    PHY_s_after_X_filtering(unwrap_start_x,unwrap_start_y);

% ��3������һ���µľ����������״̬��������ƣ��ѽ���ƣ��ڽ��еȣ�
Unwrap_Mode = zeros(Naz,Nrg);   % ��ʼֵΪ0��������ʾ�������
Unwrap_Mode(unwrap_start_x,unwrap_start_y) = 1;
% ������Ӧ��λ�ø�ֵΪ1�������ѽ����

% **********************************************************************
%                           ������¡��ڽ��С�
% **********************************************************************
% ���ڵ�һ������ԣ������ڽ��кܼ򵥣�ֻ�轫��Χ�ĸ��㶼���Ϊ NaN ����
Unwrap_Mode(unwrap_start_x-1,unwrap_start_y) = NaN;
Unwrap_Mode(unwrap_start_x,unwrap_start_y-1) = NaN;
Unwrap_Mode(unwrap_start_x,unwrap_start_y+1) = NaN;
Unwrap_Mode(unwrap_start_x+1,unwrap_start_y) = NaN;

%%
% ------------------------------------------------------------------------
%             ������� while ѭ�����Զ���������ִ����λ�������
% ------------------------------------------------------------------------
NUM_while = 1;
while( any(any(isnan(Unwrap_Mode))) )
    % ��1����ʱҪ���������ڽ����У����NaN�ģ���Ѱ������ͼ����λ��
    %      ��ˣ����ȶ�λNaN��������Ѱ��NaN�İ취
    LR = isnan(Unwrap_Mode);
    % ��ʱ����LR�У�����NaN��λ�ñ����Ϊ1������ı��Ϊ0��
    % ===========================================================
    % �����ⲿ�ֳ�����룬�����������ڱ����NaN�������У����ڽ����У�
    % ���ֵ��λ�ã��Ա���к�������ơ�
    % ���ǣ������ⲿ�ִ���ֱ����forѭ����Ч��̫�ͣ�����Ľ���
    %{
    [rj,cj] = find(LR);
    
    m = length(rj);
    tmp = zeros(1,m);
    for pp = 1:m
        tmp(1,pp) = Coherence_imag(rj(pp),cj(pp));
    end
    [max_tmp,max_tmp_num] = max(tmp);
    %}
    % �ҽ�����Ľ�����иĽ�����ʹ��forѭ�������£�
    [rj,cj] = find(LR);
    [max_tmp,max_tmp_num] = max(Coherence_imag(find(LR)));
    % ===========================================================
    
    % ���� NaN ���ڽ����У����ϵ�����ģ�������Ϊ��
    %   ��rj(max_tmp_num),cj(max_tmp_num)��
    % ����ͨ��һ���ж���䣬ʹ��while����ѭ�������������������
    if rj(max_tmp_num) == 1 || rj(max_tmp_num) == Naz || ...
        cj(max_tmp_num) == 1 || cj(max_tmp_num) == Nrg
        % ��״̬�� NaN ��Ϊ 0���ų����ڽ���
        Unwrap_Mode(rj(max_tmp_num),cj(max_tmp_num)) = 0;
        % �����˴�ѭ��
        continue;
    end
    
    % ��2���ڽ����У���Ӧ����ͼ����Ԫ�أ�����������λ�ǣ�
    wait_unwrap = PHY_s_after_X_filtering(rj(max_tmp_num),cj(max_tmp_num));
    % λ���ڣ��� rj(max_tmp_num),cj(max_tmp_num) ��
    
    % ��3������һά����Ʒ���ֱ�ӽ��
    %      ����Ҫ�����ж�����һ����н��
    %      ��Ŀǰ�ķ����ǣ������жϸõ���Χ�ĵ㣬ֻҪ��һ�����״̬��Unwrap_Mode��
    %      ��ֵ��1���������������     �����Ƿ��и��õķ�������
    if Unwrap_Mode(rj(max_tmp_num)-1,cj(max_tmp_num)) == 1
        delta_unwrap = wait_unwrap - PHY_s_after_X_filtering(rj(max_tmp_num)-1,cj(max_tmp_num));
        if delta_unwrap > pi
            delta_unwrap = delta_unwrap - 2*pi;
        end
        if delta_unwrap < -1*pi
            delta_unwrap = delta_unwrap + 2*pi;
        end
        PHY_after_unwrapping(rj(max_tmp_num),cj(max_tmp_num)) = ...
            PHY_after_unwrapping(rj(max_tmp_num)-1,cj(max_tmp_num))...
            + delta_unwrap;
    else
        if Unwrap_Mode(rj(max_tmp_num),cj(max_tmp_num)-1) == 1
            delta_unwrap = wait_unwrap - PHY_s_after_X_filtering(rj(max_tmp_num),cj(max_tmp_num)-1);
            if delta_unwrap > pi
                delta_unwrap = delta_unwrap - 2*pi;
            end
            if delta_unwrap < -1*pi
                delta_unwrap = delta_unwrap + 2*pi;
            end            
            PHY_after_unwrapping(rj(max_tmp_num),cj(max_tmp_num)) = ...
                PHY_after_unwrapping(rj(max_tmp_num),cj(max_tmp_num)-1)...
                + delta_unwrap;
        else
            if Unwrap_Mode(rj(max_tmp_num),cj(max_tmp_num)+1) == 1
                delta_unwrap = wait_unwrap - PHY_s_after_X_filtering(rj(max_tmp_num),cj(max_tmp_num)+1);
                if delta_unwrap > pi
                    delta_unwrap = delta_unwrap - 2*pi;
                end
                if delta_unwrap < -1*pi
                    delta_unwrap = delta_unwrap + 2*pi;
                end  
                PHY_after_unwrapping(rj(max_tmp_num),cj(max_tmp_num)) = ...
                    PHY_after_unwrapping(rj(max_tmp_num),cj(max_tmp_num)+1)...
                    + delta_unwrap;
            else
                if Unwrap_Mode(rj(max_tmp_num)+1,cj(max_tmp_num)) == 1
                    delta_unwrap = wait_unwrap - PHY_s_after_X_filtering(rj(max_tmp_num)+1,cj(max_tmp_num));
                    if delta_unwrap > pi
                        delta_unwrap = delta_unwrap - 2*pi;
                    end
                    if delta_unwrap < -1*pi
                        delta_unwrap = delta_unwrap + 2*pi;
                    end    
                    PHY_after_unwrapping(rj(max_tmp_num),cj(max_tmp_num)) = ...
                        PHY_after_unwrapping(rj(max_tmp_num)+1,cj(max_tmp_num))...
                        + delta_unwrap;
                else
                    disp('����ƴ��󣬸õ���Χû���ѽ���ĵ�');
                    return;
                end
            end
        end
    end
    
    % ��4�������ڽ���
    %   1������������ս���Ľ������״̬����Ϊ1��
    Unwrap_Mode(rj(max_tmp_num),cj(max_tmp_num)) = 1;
    %   2������Χ�ĵ���½��ڽ��У�ͬʱҪ���������ж�
    %      ��Ϊ��ѭ���У��Ҳ�֪����Щ������Ρ������ġ�����ˣ�Ҫ�Ըõ���Χ�ĸ�
    %      �㶼����״̬�жϡ�����0�������Ϊ NaN��
    %                       ���� 1 ���� NaN�����ֲ��伴��
    if Unwrap_Mode(rj(max_tmp_num)-1,cj(max_tmp_num)) == 0
        Unwrap_Mode(rj(max_tmp_num)-1,cj(max_tmp_num)) = NaN;
    end
    if Unwrap_Mode(rj(max_tmp_num),cj(max_tmp_num)-1) == 0
        Unwrap_Mode(rj(max_tmp_num),cj(max_tmp_num)-1) = NaN;
    end
    if Unwrap_Mode(rj(max_tmp_num),cj(max_tmp_num)+1) == 0
        Unwrap_Mode(rj(max_tmp_num),cj(max_tmp_num)+1) = NaN;
    end
    if Unwrap_Mode(rj(max_tmp_num)+1,cj(max_tmp_num)) == 0
        Unwrap_Mode(rj(max_tmp_num)+1,cj(max_tmp_num)) = NaN;
    end
    
    % ��5���������������������������һ��ѭ�����������
    %      ��Щֵ��ÿһ��ѭ���ж�ֻ����Ϊ�м�������ڡ�
    clear LR;
    clear rj;clear cj;
    clear tmp;clear max_tmp;clear max_tmp_num;
    clear wait_unwrap;
    clear delta_unwrap;
    
    NUM_while
    NUM_while = NUM_while + 1;      % ���������ʾѭ�������������˽������������
    
    % ��6�����ˣ�whileѭ�������������ص�while������ͷ���������У�
    %     ֱ������������⣬����ɽ����

end

%%
% ------------------------------------------------------------------------
%                   ��󣬶������ִ����λ�����
% ------------------------------------------------------------------------
% ��1���ɵڶ��н���Ƶ�һ��
for jj = 2:(Nrg-1)
    delta_jj = PHY_s_after_X_filtering(1,jj) - PHY_s_after_X_filtering(2,jj);
    if delta_jj > pi
        delta_jj = delta_jj - 2*pi;
    end
    if delta_jj < -1*pi
        delta_jj = delta_jj + 2*pi;
    end
    PHY_after_unwrapping(1,jj) = PHY_after_unwrapping(2,jj) + delta_jj;
end

% ��2���ɵ����ڶ��н�����һ��
for jj = 2:(Nrg-1)
    delta_jj = PHY_s_after_X_filtering(Naz,jj) - PHY_s_after_X_filtering(Naz-1,jj);
    if delta_jj > pi
        delta_jj = delta_jj - 2*pi;
    end
    if delta_jj < -1*pi
        delta_jj = delta_jj + 2*pi;
    end
    PHY_after_unwrapping(Naz,jj) = PHY_after_unwrapping(Naz-1,jj) + delta_jj;
end

% ��3���ɵڶ��н����һ��
for jj = 1:Naz
    delta_jj = PHY_s_after_X_filtering(jj,1) - PHY_s_after_X_filtering(jj,2);
    if delta_jj > pi
        delta_jj = delta_jj - 2*pi;
    end
    if delta_jj < -1*pi
        delta_jj = delta_jj + 2*pi;
    end
    PHY_after_unwrapping(jj,1) = PHY_after_unwrapping(jj,2) + delta_jj;
end

% ��4���ɵ����ڶ��н�����һ��
for jj = 1:Naz
    delta_jj = PHY_s_after_X_filtering(jj,Nrg) - PHY_s_after_X_filtering(jj,Nrg-1);
    if delta_jj > pi
        delta_jj = delta_jj - 2*pi;
    end
    if delta_jj < -1*pi
        delta_jj = delta_jj + 2*pi;
    end
    PHY_after_unwrapping(jj,Nrg) = PHY_after_unwrapping(jj,Nrg-1) + delta_jj;
end

disp('�������λ�����');

end
