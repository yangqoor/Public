function leidaxitong
    %�ܵ��״�ϵͳ����
    figure(1);
    [h, s1, g, f0, fs, f1] = huibo; %,title('Ŀ��ز�');
    figure(2);
    y1 = gaofang(s1, f0, fs, f1); %,title('�߷�');
    figure(3);
    y2 = hunpin(y1, f0, fs, f1); %,title('��Ƶ');
    figure(4);
    y3 = zhongfang(y2, f0, fs, f1); %,title('�з�');
    figure(5);
    [I, Q] = xiangganjianbo(y3, fs, f0, f1); %,title('��ɼ첨');
    [x4, y4] = AD(I, Q);
    figure(6);
    [I1, Q1] = maichongyasuo(x4, y4, h); %,title('����ѹ��');
    figure(7);
    [y5, y6] = MTI(I1, Q1); %,title('MTI');
    figure(8);
    y7 = qumo(y5, y6), title('ȡģ');
    figure(9);
    y8 = jilei(y7), title('�������');
    figure(10);
    y9 = CFAR(y8), title('���龯');
