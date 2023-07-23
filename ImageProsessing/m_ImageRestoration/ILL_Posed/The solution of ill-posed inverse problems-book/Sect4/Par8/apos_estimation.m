function [x9,ReR]=apos_estimation(ze,lb,ub,B,uv,nrU,delU,delA,h,zt,xs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Апостериорная оценка ошибки
% ze -- вычисленное ранее решение;B -- матрица СЛАУ, uv -- правая часть,
% nrU -- норма правой части, delU,delA -- уровни ошибок данных, h -- шаг сетки xs,
% lb,ub -- апостериорные пределы изменения полученного решения ze 
% zt -- точное решение для графика
% x9,ReR -- экстремаль задачи оценки точности и апостериорная оценка ошибки
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options=...
optimset('MaxIter',150,'Display','off','GradObj','off','GradConstr','off','MaxFunEvals',1e6);

rE=sqrt(norm(ze)^2*h+norm(diff(ze))^2/h);
C=1.;DDD=C*(delU*nrU+delA*norm(B)*norm(ze));
hhh = waitbar(0,'Please wait for error estimate');waitbar(1,hhh);pause(1)
tic
[x9,epsi]=fmincon('fun1_3',zt,[],[],[],[],lb,ub,'grfun1_3',options,B,uv,ze,rE,DDD,h);
toc
close(hhh)
Relative_apost_error_L2_Z=norm(x9-ze)/norm(ze);
ReR=Relative_apost_error_L2_Z;
disp(' ');
disp(['  Относительная равномерная апостериорная ошибка решения = ' num2str(ReR)]);
figure(333);
plot(xs,zt,'k',xs,ze,'k.-',xs,x9,'ko-');set(gca,'FontName',FntNm);
legend('Точное решение','Приближение метода квазирешений','Экстремаль апостериорной оценки',2);
xlabel('s');ylabel('z(s), z_{\eta}(s)')
