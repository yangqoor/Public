load 'E plane.dat '
figure(1)
    t=E_plane(:,1)';
    FEA=E_plane(:,2)';
    plot(t,FEA);      
    grid on;
xlabel('\bf�ǶȦ�   ��λ����','FontSize',15);
ylabel('\bff(��)    ��λ��dB','FontSize',15);
title('������������ʵ�� E �淽��ͼ','FontName','��������',...
      'FontWeight','Bold','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
load 'H plane.dat '
figure(2)
    tt=H_plane(:,1)';
    FHA=H_plane(:,2)';
    plot(tt,FHA);      
    grid on;
xlabel('\bf�ǶȦ�   ��λ����','FontSize',15);
ylabel('\bff(��)    ��λ��dB','FontSize',15);
title('������������ʵ�� H �淽��ͼ','FontName','��������',...
      'FontWeight','Bold','FontSize',16)