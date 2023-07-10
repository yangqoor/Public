load 'E plane.dat '
figure(1)
    t=E_plane(:,1)';
    FEA=E_plane(:,2)';
    plot(t,FEA);      
    grid on;
xlabel('\bf角度θ   单位：度','FontSize',15);
ylabel('\bff(θ)    单位：dB','FontSize',15);
title('矩形喇叭天线实测 E 面方向图','FontName','华文隶书',...
      'FontWeight','Bold','FontSize',16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
load 'H plane.dat '
figure(2)
    tt=H_plane(:,1)';
    FHA=H_plane(:,2)';
    plot(tt,FHA);      
    grid on;
xlabel('\bf角度θ   单位：度','FontSize',15);
ylabel('\bff(θ)    单位：dB','FontSize',15);
title('矩形喇叭天线实测 H 面方向图','FontName','华文隶书',...
      'FontWeight','Bold','FontSize',16)