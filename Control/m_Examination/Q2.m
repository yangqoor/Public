A = [0 2 0 0; 0 1 -2 0; 0 0 3 1; 1 0 0 0];
B = [2; 1; 0; 0];
C = [0 1 0 0];
D = [0];
[num, den] = ss2tf(A, B, C, D, 1); %��������
[z, p] = tf2zp(num, den); %��ȡ�㼫��
%�ж��ȶ���
ss = find(real(p) > 0);
tt = length(ss);

if (tt > 0)
    disp('ϵͳ���ȶ�')
else
    disp('ϵͳ�ȶ�')
end

%�ж���С��λ
xx = find(real(z) > 0);
yy = length(xx);

if (yy > 0)
    disp('ϵͳ������С��λϵͳ')
else
    disp('ϵͳ����С��λϵͳ')
end

%�жϿɿ���
ctrl_matrix = ctrb(A, B); %�������ϵͳ�Ŀɿ���

if (rank(ctrl_matrix) == 3) %�ܿؾ������Ϊ3
    disp('ϵͳ��ȫ�ɿأ�')
    [A, B, C, D] = ss2ss(A, B, C, D, inv(T)) %p263�ɿ�2��
else
    disp('ϵͳ����ȫ�ɿأ�')
end

%�������ʣ��жϿɹ���
observe_matrix = obsv(A, C); %�������ϵͳ�Ŀɹ���

if (rank(observe_matrix) == 3) %�������⣬��֪�ܿؾ������Ϊ3����A������ͬ����ϵͳ��ȫ�ɹ�p270
    disp('ϵͳ��ȫ�ɹۣ�')
    [A, B, C, D] = ss2ss(A, B, C, D, T) %p264�ɹ�1��
else
    disp('ϵͳ����ȫ�ɹۣ�')
end
