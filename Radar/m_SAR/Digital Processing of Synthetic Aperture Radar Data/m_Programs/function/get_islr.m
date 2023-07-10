%% ��ȡ�����԰��
function [islr] = get_islr(Af,Nr)
    % �ҵ�Af�����λ��
    [~,locmax] = max(Af);
    % �ҵ�locmax�����ӽ�-3dB��λ��
    [~,locleft] = min(abs(Af(1:locmax-1)/max(abs(Af(1:locmax-1)))-0.707));
    % �ҵ�locmax�ұ���ӽ�-3dB��λ��
    [~,locright] = min(abs(Af(locmax+1:end)/max(abs(Af(locmax+1:end)))-0.707));
    locright = locright + locmax;
    % �����ܹ���
    P_total = sum(Af(locleft-Nr:locright+Nr).^2);
    % �������깦��
    P_main = sum(Af(locleft:locright).^2);
    % һά�����԰��
    islr = 10*log10((P_total-P_main)./P_main);
end