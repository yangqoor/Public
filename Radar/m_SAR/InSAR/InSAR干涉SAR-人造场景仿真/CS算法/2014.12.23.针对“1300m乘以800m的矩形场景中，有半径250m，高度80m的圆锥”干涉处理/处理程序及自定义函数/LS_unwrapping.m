function PHY_after_unwrapping = LS_unwrapping(PHY_s_after_X_filtering)
% ������������λ����ƣ����� ����С���˷�������
% �в�����Ϊ 0 ʱ�����߲����� 0 ʱ������ʹ�ã�
%           �����ο�������ġ��״����������8.6.3�ڣ������311ҳ����315ҳ��
%
% �������ݣ�
%   PHY_s_after_X_filtering  ��ʾ����ĳ���˲�������ĸ�����λͼ��
% ������ݣ�
%   PHY_after_unwrapping  ��ʾ��λ����ƺ����λͼ��
%
% �����ֹ���� 2014.12.22. 15:21 a.m.

%%
disp('���ڲ��á���С���˷�����������λ����ƣ���ȴ�');
% ------------------------------------------------------------------------
%                               ��λ�����
% ------------------------------------------------------------------------
% ���� 1 ��
% �ԡ�PHY_s_after_X_filtering���������䡣
% �ڶ�άƽ�棬����PHY_s_after_X_filtering������ m = Naz+1/2 Ϊ���������䣻
%                                         ���� n = Nrg+1/2 Ϊ���������䣻
% �õ���ν��������Գ�ͼ�񡱣�
[Naz,Nrg] = size(PHY_s_after_X_filtering);  % Naz*Nrg ��С�ľ���
PHY = zeros(2*Naz,2*Nrg);

PHY(1:Naz,1:Nrg) = PHY_s_after_X_filtering;
PHY(Naz+1:end,1:Nrg) = flipud(PHY_s_after_X_filtering);
PHY(1:Naz,Nrg+1:end) = fliplr(PHY_s_after_X_filtering);
PHY(Naz+1:end,Nrg+1:end) = fliplr(flipud(PHY_s_after_X_filtering));

% ���� 2 ��
% �ֱ��������������һ�ײ�֣�
% �����������ط�λ��Ĳ�֣�
delta_x = zeros(2*Naz,2*Nrg);
delta_x = circshift(PHY,[-1 0]) - PHY;
% �����������ж�
L_delta_x_pi = delta_x > pi;
delta_x(L_delta_x_pi) = delta_x(L_delta_x_pi) - 2*pi;
L_delta_x_minus_pi = delta_x < -pi;
delta_x(L_delta_x_minus_pi) = delta_x(L_delta_x_minus_pi) + 2*pi;

% ��������б����Ĳ��
delta_y = zeros(2*Naz,2*Nrg);
delta_y = circshift(PHY,[0 -1]) - PHY;
% �����������ж�
L_delta_y_pi = delta_y > pi;
delta_y(L_delta_y_pi) = delta_y(L_delta_y_pi) - 2*pi;
L_delta_y_minus_pi = delta_y < -pi;
delta_y(L_delta_y_minus_pi) = delta_y(L_delta_y_minus_pi) + 2*pi;

% ���� 3 ��
% ����ʽ��8.57����� ruo ��
ruo = zeros(2*Naz,2*Nrg);
ruo = (delta_x - circshift(delta_x,[1 0 ])) + (delta_y - circshift(delta_y,[0 1]));
% �ɴ˵õ� ruo�������С 2Naz * 2Nrg

% ���� 4 ��
% �� ruo ����άFFT���õ� P��
P = fft2(ruo);

% ���� 5 ��
% ��ʽ��8.60����� PHY_P 
k = 1:2*Naz;
% P1 = cos(pi*k/Naz);
P1 = cos(pi*(k-1)/Naz);
P1_mtx = (P1.')*ones(1,2*Nrg);

l = 1:2*Nrg;
% P2 = cos(pi*l/Nrg);
P2 = cos(pi*(l-1)/Nrg);
P2_mtx = ones(2*Naz,1)*P2;

PHY_P = P./(2*P1_mtx + 2*P2_mtx -4);
% PHY_P(2*Naz,2*Nrg) = 0;     % ��Ϊ��ĸΪ�㣬���Դ���Ĺ�ʽ������ΪNaN�����������¸�ֵ��
PHY_P(1,1) = 0;

% ���� 6 ��
% �� PHY_P ����ά IFFT��
phy_p = ifft2(PHY_P);

% ���� 7 ��
% ȡ�� phy_p ��ԭʼ���䲿�ֵ�ֵ�����õ���λ����ƵĽ��
PHY_after_unwrapping = phy_p(1:Naz,1:Nrg);

disp('��ɶ�ά��λ�����');


end