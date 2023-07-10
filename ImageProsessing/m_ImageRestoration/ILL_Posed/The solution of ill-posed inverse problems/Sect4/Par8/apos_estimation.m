function [x9,ReR]=apos_estimation(ze,lb,ub,B,uv,nrU,delU,delA,h,zt,xs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ������������� ������ ������
% ze -- ����������� ����� �������;B -- ������� ����, uv -- ������ �����,
% nrU -- ����� ������ �����, delU,delA -- ������ ������ ������, h -- ��� ����� xs,
% lb,ub -- ������������� ������� ��������� ����������� ������� ze 
% zt -- ������ ������� ��� �������
% x9,ReR -- ���������� ������ ������ �������� � ������������� ������ ������
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
disp(['  ������������� ����������� ������������� ������ ������� = ' num2str(ReR)]);
figure(333);
plot(xs,zt,'k',xs,ze,'k.-',xs,x9,'ko-');set(gca,'FontName',FntNm);
legend('������ �������','����������� ������ ������������','���������� ������������� ������',2);
xlabel('s');ylabel('z(s), z_{\eta}(s)')
