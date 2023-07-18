clear all;

A = [-21,19,-20;
     19,-21,20;
     40,-40,-40];
 
x0 = [1; 0; -1];
h = 0.0001;
T = 0:h:1;

%% 
% 解析解
n = length(T); 

for i = 1:n
    x = expm(A*T(i))*x0;
    
    for j = 1:3
        x_analytic(j,i) = x(j);
    end
end

figure(1);
plot(T,x_analytic(1,:),'r',T,x_analytic(2,:),'g',T,x_analytic(3,:),'y');
title('解析法求解')
xlabel('时间')
ylabel('X的值')
legend('x(1)','x(2)','x(3)')

%%
%定步长法：选用RK4

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
title('采用定步长法RK4求解')
xlabel('时间')
ylabel('X的值')
legend('x(1)','x(2)','x(3)')

%%
%变步长法：选用变步长龙格库塔法(RKF45)，调用函数ode45

[T,x_ode45] = ode45('rigid',T,[1; 0; -1]);

figure(3);
plot(T,x_ode45(:,1),'r',T,x_ode45(:,2),'g',T,x_ode45(:,3),'y');
title('采用变步长法RKF4-5求解——ode45')
xlabel('时间')
ylabel('X的值')
legend('x(1)','x(2)','x(3)')


%%
%病态系统专用算法，选用吉尔法，调用函数ode15s
[T,x_ode15s] = ode15s('rigid',T,[1; 0; -1]);

figure(4);
plot(T,x_ode15s(:,1),'r',T,x_ode15s(:,2),'g',T,x_ode15s(:,3),'y');
title('采用病态系统专用方法求解——ode15s')
xlabel('时间')
ylabel('X的值')
legend('x(1)','x(2)','x(3)')


%%
%各方法的比较
figure(5);
plot(T, x_RK4(1,:) - x_analytic(1,:),'r', T,x_RK4(2,:) - x_analytic(2,:), 'g', T,x_RK4(3,:) - x_analytic(3,:),'y');
title('RK4法与解析解')
xlabel('时间')
ylabel('RK4-解析解')
legend('x(1)','x(2)','x(3)')

figure(6);
plot(T, (x_ode45(:,1))' - x_analytic(1,:),'r', T, (x_ode45(:,2))' - x_analytic(2,:), 'g', T, (x_ode45(:,3))' - x_analytic(3,:),'y');
title('ode45法与解析解')
xlabel('时间')
ylabel('ode45-解析解')
legend('x(1)','x(2)','x(3)')

figure(7);
plot(T, (x_ode15s(:,1))' - x_analytic(1,:),'r', T, (x_ode15s(:,2))' - x_analytic(2,:), 'g', T, (x_ode15s(:,3))' - x_analytic(3,:),'y');
title('ode15s法与解析解')
xlabel('时间')
ylabel('ode15s-解析解')
legend('x(1)','x(2)','x(3)')

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           