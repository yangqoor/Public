function Domain_isto
disp('-----------------------------------------------------------------------------');
disp(' ');disp('      Геометрия области ');
disp(' ');disp('      Нажмите любую клавишу для просмотра!');pause

figure(41);
[p,e,t]=initmesh('pryamg');
[p,e,t]=refinemesh('pryamg',p,e,t);[p,e,t]=refinemesh('pryamg',p,e,t);
pdemesh(p,e,t);axis equal;
xlabel('x');ylabel('y');
set(gca,'YTickLabel',num2str([-1.2:0.2:0.4]'+1))
set(gcf,'Name','Область и конечные элементы','NumberTitle','off')
pause(3);set(gcf,'Visible','off');