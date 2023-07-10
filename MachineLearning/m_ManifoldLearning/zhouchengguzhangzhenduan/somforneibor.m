% clear all;
% close all;
% %% SOM for graduate %% load swissroll
function [mappedX,M,conn] = somforneibor(X,k,d)

speed_up = 1; 
[N,D] = size(X);
f  = 1;  
% --> f is width of neighborhood function (neurons are one unit separated)
if d==1;        
    gr = [1:k]';
elseif d > 1;
    [x,y]=meshgrid(1:k,1:k);  
    gr = [ x(:) y(:)];  
end
%% 二维输出值 1,1 1,2 1,3 2,1 ,2,2 ,2,3 3,1, 3,2 ,3,3


%%计算各节点的拓扑distance
dd = L2_distance(gr',gr') ;
H = exp(-dd/(2*(f*k)^2)) ; %%统计各点的分布率，距离越近，H越大
k = size(gr,1);
H  = H ./repmat(sum(H,1),k,1); %%%规一化
conn =  (dd<=1); %%连接矩阵 拓扑网络
entr = sum(-H.*log(H+realmin),1); %% -exp(x) * x  每一点的距离熵值之和

%初始化神经元
W = floor (rand(N,1)*k) + 1; %%从H中随机选择权值输出
q = H(:,W); %% q  k2行 N 列  
M = diag(sum(q,2).^-1) * q * X ; 
sd = L2_distance(X',M') ;%% 计算 所有点到初始权的距离
SigmaS = mean(min(sd,[],2)); % 每一个点到所有初始权中最小的距离，再求均值
%初始计数器
iter = 0 ;
old_obj  = -sum(sd.*q',2)/(2*SigmaS)+ entr(W)' - D*log(SigmaS)/2;
F = [0]; first_bunch = 1 ;rate = 1.1; 
% fig = figure; aviobj = avifile('S曲面1.avi','compression','none');
while H(1,1) < .9999
    iter = iter +1 ;
    %迭代
    N = length(W) ;
    [tmp , order] = min(sd,[],2); 
    J = find(order~=W);
    order = order(J);%找出所有点对初始权值的距离中最小的点不是W的点 
    tmp_obj=  -sum(sd(J,:) .* H(:,order)',2) / (2*SigmaS) +entr(order)'-D*log(SigmaS)/2;
  %old_obj  = -sum(sd.*q',2)/(2*SigmaS)+ entr(W)' - D*log(SigmaS)/2; 熵最大？？
    I  = find( tmp_obj >= old_obj(J) );
     obj = old_obj ; 
     obj(J(I)) = tmp_obj(I);
    W(J(I))   = order(I); %%  W改变
   
    if abs(sum(obj)/sum(old_obj)-1)<1e-5; 
            H    = H.^rate;    % --> 收缩函数 nh-function rate = 1.1
            H    = H./repmat(sum(H),k,1)+realmin;
           entr = -sum(H.*log(H+realmin),1);fprintf('|');
            q    = H(:,W);
            obj  = -sum(sd.*q',2)/(2*SigmaS)+ entr(W)' - D*log(SigmaS)/2;
            F    = [F; -sum(obj)];  
    end
      %%保存获胜单元
      q = H(:,W); % q 改变
     %更新 M, sigmaS, sd, obj 
       M = diag(sum(q,2).^-1)*  q * X ;
       sd  = sqdist(X',M');
       SigmaS = sum(sum(sd'.*q))/(D*N);       
       if first_bunch & length(F)>2;
          F=F(2:end) ;
          first_bunch=0;
      end  % throw away first two values of F (possibly very high) since they may screw-up the plot
       %%画图
  plot_it(X,M,1*sqrt(SigmaS),conn); 
  %%生成动画
%   MM = getframe(fig);aviobj = addframe(aviobj,MM);
  old_obj = obj ;
end
%    aviobj = close(aviobj);
disp('construct the neigbor matrix...');
  neigbor = neigborselect(X,M,conn,d);
  disp('som ltsa ...');
  mappedX = somltsa(X,d,neigbor,'JDQR');
  disp('finished');
figure;
plot(mappedX(:,1),mappedX(:,2),'.');title('主流形结构');

 