%% ��ȡ��ֵ�԰��
function [pslr] = get_pslr(Af)
    % �ҵ����е�pesks
    peaks = findpeaks(Af);
    % ��peaks��������
    peaks = sort(peaks,'descend');
    % �õ���һ�԰�
    pslr = peaks(2);
end