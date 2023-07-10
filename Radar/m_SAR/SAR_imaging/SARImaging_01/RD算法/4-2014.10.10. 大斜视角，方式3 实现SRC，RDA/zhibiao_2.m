function [PSLR,ISLR,IRW] = zhibiao_2(x,s_number,T)
%
% ��Ժ��� zhibiao(x,s_number,T) ���иĽ����Ľ���������ҪΪ��
% �ڼ���3dB������Ӧ������ʱ������������ �ֱ��ʣ�IRW��
% ���� zhibiao() �в��õ����ٽ�ȡ���İ취���ⲻ׼ȷ��
% �������õķ����ǽ��� 3dB �����������������Բ�ֵ�����õ���׼ȷ��3dB������Ӧ�����ꡣ
%
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
M = ( 10^(-3/20) )*C;       % 3dB �����ĺ���ȡֵ��
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

Th_x1 = P1+z1_x1;% Th_x1 ������������3dB���������Ǹ�������꣨����3dB����������㣩
Th_x2 = I+z2_x2; % Th_x2 ���ǡ�������3dB������Ҳࡤ����������������3dB����������㣩
% ------------------------------------------------------------------
% ͨ��������õľ���3dB����������� Th_x1 �� Th_x2
% �������Բ�ֵ���õ�3dB��������Ӧ�����ĸ�׼ȷ��ֵ
% �������3dB���Ǹ�����
if soo_abs(Th_x1)-M < 0
    x0_linear = Th_x1;
    x1_linear = Th_x1+1;
else
    x0_linear = Th_x1-1;
    x1_linear = Th_x1;
end
Th_x1_real = ...
  (M-soo_abs(x1_linear))/(soo_abs(x0_linear)-soo_abs(x1_linear))*x0_linear...              
+ (M-soo_abs(x0_linear))/(soo_abs(x1_linear)-soo_abs(x0_linear))*x1_linear;

% �����ұ�3dB���Ǹ�����
if soo_abs(Th_x2)-M > 0
    x0_linear = Th_x2;
    x1_linear = Th_x2+1;
else
    x0_linear = Th_x2-1;
    x1_linear = Th_x2;
end
Th_x2_real = ...
  (M-soo_abs(x1_linear))/(soo_abs(x0_linear)-soo_abs(x1_linear))*x0_linear...              
+ (M-soo_abs(x0_linear))/(soo_abs(x1_linear)-soo_abs(x0_linear))*x1_linear;
% ------------------------------------------------------------------
width = Th_x2_real-Th_x1_real;  % width ����ͨ�����ַ�����õ� 3dB����

c = 3e8;% ���� c=3e8 m/s��
IRW = T/N_buling*width*c/2;% ע����SAR�У��ֱ����� C*T/2,����T�������ȡ�
% IRW_realΪͼ��ֱ��ʣ�ԭ����width�ĵ�λ�ǲ��������һ��ͼ��ֱ��ʵ�λȡ m��Ҫת����
% ע�⵽���������õ��� N_buling����ΪƵ������ЧΪ����������������ߣ���������Ӧ�ø���Ϊ N_buling��
