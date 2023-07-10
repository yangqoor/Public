clc
clear
close all

% ��������
TBP = 42;              % ʱ������
T = 7.2e-6;            % �������ʱ��
% ��������
B = TBP/T;             % �źŴ���
K = B/T;               % ���Ե�ƵƵ��
alpha_os = 50;         % �������ʣ�ʹ�ýϸߵĹ���������Ϊ����߲���Ƶ��
F = alpha_os*B;        % ����Ƶ��
N = 2*ceil(F*T/2);     % ��������
dt = T/N;              % ����ʱ����
% ��������
t = -T/2:dt:T/2-dt;    % ʱ�����
t_out = linspace(2*t(1),2*t(end),2*length(t)-1);    % ѭ���������źų���    
% �źű��
st = exp(1j*pi*K*t.^2);               % Chirp�źŸ������ʽ
ht = conj(fliplr(st));                % ʱ��ƥ���˲���
% ���ź��м����˹�����������ַ�ʽ
st_noise = awgn(st,-2.5,'measured');
% st_noise = st+0.75*1*randn(1,N);
% �źű��
sout_noise = conv(st_noise,ht);                     % ƥ���˲������
% �źű任
sout_noise_nor = sout_noise/max(sout_noise);                          % ��λ��
sout_noise_log = 20*log10(abs(sout_noise)./max(abs(sout_noise))+eps); % ��һ��
% ��ͼ
figure
subplot(221),plot(t*1e+6,real(st_noise))
axis([-4 4,-3 3])
title('(a)ԭʼ�ź�ʵ��'),ylabel('����')

subplot(222),plot(t_out*1e+6,sout_noise_log)
axis([-1 1,-30 5])
title('(c)ѹ�����ź�(����չ)'),ylabel('����')
[pslr] = get_pslr(sout_noise_log);
text(0,3,['PSLR= ',num2str(pslr),'dB'],'HorizontalAlignment','center')

subplot(223),plot(t_out*1e+6,real(sout_noise_nor))
axis([-4 4,-0.3 1.3])
title('(b)ѹ�����ź�'),xlabel('�����t_0ʱ��(\mus)'),ylabel('����(dB)')
[hw,~,~] = get_hw(sout_noise_log);
hw = hw*dt;
text(0,1.2,['HW= ',num2str(hw*1e+6),'\mus'],'HorizontalAlignment','center')

subplot(224),plot(t_out*1e+6,angle(sout_noise_nor))
axis([-1 1,-5 5])
title('(d)ѹ�����ź���λ(����չ)'),xlabel('�����t_0ʱ��(\mus)'),ylabel('��λ(����)')
suptitle('ͼ3.7 ��������ʱ�������Ե�Ƶ�źŵ�ƥ���˲�')

%% HW����
function [hw,locleft,locright] = get_hw(Af)
    % �ҵ�Af�����λ��
    [~,locmax] = max(Af);
    % �ҵ�locmax�����ӽ�-3dB��λ��
    [~,locleft] = min(abs(Af(1:locmax)+3));
    % �ҵ�locmax�ұ���ӽ�-3dB��λ��
    [~,locright] = min(abs(Af(locmax:end)+3));
    locright = locright + locmax - 1;
    % �õ�3dB�������
    hw = locright-locleft;
end
%% PSLR����
function [pslr] = get_pslr(Af)
    % �ҵ����е�pesks
    peaks = findpeaks(Af);
    % ��peaks���н�������
    peaks = sort(peaks,'descend');
    % �õ���һ�԰�
    pslr = peaks(2);
end