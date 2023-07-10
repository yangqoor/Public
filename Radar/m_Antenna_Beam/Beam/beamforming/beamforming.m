figure
plot_polar_mvdr('run3');
title('极坐标下波束形成方向图')
xlabel('信噪比10dB/干扰噪声比20dB/LMS迭代次数200/步长因子1e-9')



figure
plot_mvdr('run1'); hold on
plot_mvdr('run2');
plot_mvdr('run3');
hold off
title('LMS算法迭代次数对波束形成结果的影响')



figure
plot_mvdr('run4'); hold on
plot_mvdr('run5');
plot_mvdr('run6');
hold off
title('LMS算法步长因子对波束形成结果的影响')




figure
plot_mvdr('run7'); hold on
plot_mvdr('run8');
plot_mvdr('run9');
hold off
title('不同的干扰噪声比对波束形成结果的影响')




