figure
plot_polar_mvdr('run3');
title('�������²����γɷ���ͼ')
xlabel('�����10dB/����������20dB/LMS��������200/��������1e-9')



figure
plot_mvdr('run1'); hold on
plot_mvdr('run2');
plot_mvdr('run3');
hold off
title('LMS�㷨���������Բ����γɽ����Ӱ��')



figure
plot_mvdr('run4'); hold on
plot_mvdr('run5');
plot_mvdr('run6');
hold off
title('LMS�㷨�������ӶԲ����γɽ����Ӱ��')




figure
plot_mvdr('run7'); hold on
plot_mvdr('run8');
plot_mvdr('run9');
hold off
title('��ͬ�ĸ��������ȶԲ����γɽ����Ӱ��')




