function [PSLR,ISLR,IRW] = zhibiao(x,s_number,T)
% ����������ź�x���������� s_number��T���źŵ�ʱ�򳤶ȡ�
% �ú���������� x �ķ�ֵ�԰��(PSLR)�������԰��(ISLR),����ֱ��ʣ�IRW����
soo = x;                % �ź�x
N_buling = s_number;    % ��������

soo_abs = abs(soo);     % soo��ģ
[C,I] = max(soo_abs);   % ����� soo��ģ �е����ֵ C��λ�� I��
y = soo_abs.^2;         % �����ƽ���� y = soo^2��

x1 = 0;
while (soo_abs(I-x1-1)-soo_abs(I-x1))<0
    M1 = x1;
    x1 = x1+1;
end
x2 = 0;
while (soo_abs(I+x2+1)-soo_abs(I+x2))<0
    M2 = x2;
    x2 = x2+1;
end

P1 = I-1-M1;            % ������԰�ֽ�㣬��ߵ������� P1��
P2 = I+1+M2;            % ������԰�ֽ�㣬�ұߵ������ P2��

[D_left,Q_left] = max(soo_abs(1,1:P1));     % ����԰ֵ꣬Ϊ D_left��λ��Ϊ Q_left������ߵ���һ������
[D_right,Q_right] = max(soo_abs(1,P2:end)); % ����԰ֵ꣬Ϊ D_right��λ��Ϊ Q_right�����ұߵ���һ������
D = max(D_left,D_right);    % �Ƚ���ߺ��ұ������е����ֵ���õ������԰��������԰ֵ꣬Ϊ D��


PSLR = 20*log10(D/C);                       % ��ֵ�԰��
ISLR = 10*log10((sum(y(1,P1/20:P1))+sum(y(1,P2:end)))/sum(y(1,P1:P2)));% �����԰�ȡ�


%%%%%%%%%%%%%%%%%%%%%%%  �������� IRW  %%%%%%%%%%%%%%%%%%%%%%%%%
M = 0.7079*C;% 3dB �����ĺ���ȡֵ��
% ������Ϊ�����ҳ���ú���ֵ��ӽ���ֵ�Ĵ�С�����ꡣ
z1 = abs(soo_abs(P1)-M);
x1 = 1;
z1_x1 = 0;
for k1 = P1:I
    cha1 = abs(soo_abs(P1+x1)-M);
    if cha1<z1
        z1 = cha1;
        z1_x1 = x1; % z1_x1 ��������Ҫ�ģ�����ֵ������������ P1 ��ƫ�����������ģ�
    end
    x1 = x1+1;
end

z2 = abs(soo_abs(I)-M);
x2 =1;
z2_x2 = 0;
for k2 = I:P2
    cha2 = abs(soo_abs(I+x2)-M);
    if cha2<z2
        z2 = cha2;
        z2_x2 = x2;% z2_x2 ��������Ҫ�ģ�����ֵ������������ I ��ƫ���������Ҳ�ģ�
    end
    x2 = x2+1;
end

Th_x1 = P1+z1_x1;% Th_x1 ������������3dB���������Ǹ�������ꡣ
Th_x2 = I+z2_x2; % Th_x2 ���ǡ�������3dB������Ҳࡤ������������   
width = Th_x2-Th_x1;% width ����ͨ�����ַ�����õ� 3dB����
        
c = 3e8;% ���� c=3e8 m/s��
IRW = T/N_buling*width*c/2;% ע����SAR�У��ֱ����� C*T/2,����T�������ȡ�
% IRW_realΪͼ��ֱ��ʣ�ԭ����width�ĵ�λ�ǲ��������һ��ͼ��ֱ��ʵ�λȡ m��Ҫת����
% ע�⵽���������õ��� N_buling����ΪƵ������ЧΪ����������������ߣ���������Ӧ�ø���Ϊ N_buling��
