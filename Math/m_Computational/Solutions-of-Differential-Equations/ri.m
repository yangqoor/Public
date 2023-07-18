clear all;

A = [-21,19,-20;
     19,-21,20;
     40,-40,-40];
 
x0 = [1; 0; -1];
h = 0.0001;
T = 0:h:1;

%% 
% ������
n = length(T); 

for i = 1:n
    x = expm(A*T(i))*x0;
    
    for j = 1:3
        x_analytic(j,i) = x(j);
    end
end

figure(1);
plot(T,x_analytic(1,:),'r',T,x_analytic(2,:),'g',T,x_analytic(3,:),'y');
title('���������')
xlabel('ʱ��')
ylabel('X��ֵ')
legend('x(1)','x(2)','x(3)')

%%
%����������ѡ��RK4

x_RK4 = zeros(3,n);

x_RK4(1,1) = 1;
x_RK4(2,1) = 0;
x_RK4(3,1) = -1;


for i = 2:n 
    
    xc1(i-1) = x_RK4(1,i-1);
    xc2(i-1) = x_RK4(2,i-1);
    xc3(i-1) = x_RK4(3,i-1);
    
    for kk = 1:4
        k0 = A*[xc1(i-1);xc2(i-1);xc3(i-1)];
        
        for j = 1:3
            k(1,kk) = -21 * xc1(i-1) + 19 * xc2(i-1) - 20 * xc3(i-1);
            k(2,kk) = 19 * xc1(i-1) - 21 * xc2(i-1) + 20 * xc3(i-1);
            k(3,kk) = 40 * xc1(i-1) - 40 * xc2(i-1) - 40 * xc3(i-1);
        end
        
        
        if(kk == 1 | kk == 2)
            xc1(i) = xc1(i-1) + 0.5*k(1,kk);
            xc2(i) = xc2(i-1) + 0.5*k(2,kk);
            xc3(i) = xc3(i-1) + 0.5*k(3,kk);
        elseif(kk == 3)
            xc1(i) = xc1(i-1) + k(1,kk);
            xc2(i) = xc2(i-1) + k(2,kk);
            xc3(i) = xc3(i-1) + k(3,kk);
        end
        
        
    end

    for j = 1:3
        x_RK4(j,i) = x_RK4(j,i-1) + h*(k(j,1) + 2*k(j,2) + 2*k(j,3) + k(j,4))/6;
    end
 end

figure(2);
plot(T,x_RK4(1,:),'r',T,x_RK4(2,:),'g',T,x_RK4(3,:),'y');
title('���ö�������RK4���')
xlabel('ʱ��')
ylabel('X��ֵ')
legend('x(1)','x(2)','x(3)')

%%
%�䲽������ѡ�ñ䲽�����������(RKF45)�����ú���ode45

[T,x_ode45] = ode45('rigid',T,[1; 0; -1]);

figure(3);
plot(T,x_ode45(:,1),'r',T,x_ode45(:,2),'g',T,x_ode45(:,3),'y');
title('���ñ䲽����RKF4-5��⡪��ode45')
xlabel('ʱ��')
ylabel('X��ֵ')
legend('x(1)','x(2)','x(3)')


%%
%��̬ϵͳר���㷨��ѡ�ü����������ú���ode15s
[T,x_ode15s] = ode15s('rigid',T,[1; 0; -1]);

figure(4);
plot(T,x_ode15s(:,1),'r',T,x_ode15s(:,2),'g',T,x_ode15s(:,3),'y');
title('���ò�̬ϵͳר�÷�����⡪��ode15s')
xlabel('ʱ��')
ylabel('X��ֵ')
legend('x(1)','x(2)','x(3)')


%%
%�������ıȽ�
figure(5);
plot(T, x_RK4(1,:) - x_analytic(1,:),'r', T,x_RK4(2,:) - x_analytic(2,:), 'g', T,x_RK4(3,:) - x_analytic(3,:),'y');
title('RK4���������')
xlabel('ʱ��')
ylabel('RK4-������')
legend('x(1)','x(2)','x(3)')

figure(6);
plot(T, (x_ode45(:,1))' - x_analytic(1,:),'r', T, (x_ode45(:,2))' - x_analytic(2,:), 'g', T, (x_ode45(:,3))' - x_analytic(3,:),'y');
title('ode45���������')
xlabel('ʱ��')
ylabel('ode45-������')
legend('x(1)','x(2)','x(3)')

figure(7);
plot(T, (x_ode15s(:,1))' - x_analytic(1,:),'r', T, (x_ode15s(:,2))' - x_analytic(2,:), 'g', T, (x_ode15s(:,3))' - x_analytic(3,:),'y');
title('ode15s���������')
xlabel('ʱ��')
ylabel('ode15s-������')
legend('x(1)','x(2)','x(3)')

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           