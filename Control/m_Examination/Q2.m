A = [0 2 0 0; 0 1 -2 0; 0 0 3 1; 1 0 0 0];
B = [2; 1; 0; 0];
C = [0 1 0 0];
D = [0];
[num, den] = ss2tf(A, B, C, D, 1); %构建函数
[z, p] = tf2zp(num, den); %提取零极点
%判断稳定性
ss = find(real(p) > 0);
tt = length(ss);

if (tt > 0)
    disp('系统不稳定')
else
    disp('系统稳定')
end

%判断最小相位
xx = find(real(z) > 0);
yy = length(xx);

if (yy > 0)
    disp('系统不是最小相位系统')
else
    disp('系统是最小相位系统')
end

%判断可控性
ctrl_matrix = ctrb(A, B); %检验控制系统的可控性

if (rank(ctrl_matrix) == 3) %能控矩阵的秩为3
    disp('系统完全可控！')
    [A, B, C, D] = ss2ss(A, B, C, D, inv(T)) %p263可控2型
else
    disp('系统不完全可控！')
end

%（第三问）判断可观性
observe_matrix = obsv(A, C); %检验控制系统的可观性

if (rank(observe_matrix) == 3) %根据题意，可知能控矩阵的秩为3（于A满秩相同），系统完全可观p270
    disp('系统完全可观！')
    [A, B, C, D] = ss2ss(A, B, C, D, T) %p264可观1型
else
    disp('系统不完全可观！')
end
