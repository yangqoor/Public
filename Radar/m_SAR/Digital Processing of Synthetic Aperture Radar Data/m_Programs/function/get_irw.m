%% ��ȡ�����Ӧ���
function [irw,locleft,locright] = get_irw(Af)
    % �ҵ�Af�����λ��
    [~,locmax] = max(Af);
    % �ҵ�locmax�����ӽ�-3dB��λ��
    [~,locleft] = min(abs(Af(1:locmax-1)/max(abs(Af(1:locmax-1)))-0.707));
    % �ҵ�locmax�ұ���ӽ�-3dB��λ��
    [~,locright] = min(abs(Af(locmax+1:end)/max(abs(Af(locmax+1:end)))-0.707));
    locright = locright + locmax;
    % �õ�3dB�������
    irw = locright-locleft;
end