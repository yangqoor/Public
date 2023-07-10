function neigbor = neigborselect(X,M,conn,dim)
% 邻自动划分
% 定义中心
n = size(X,1); d = size(X,2);
m =  size(M,1);
%计算中心矩阵
%[p,q] =  find(conn == 1) ;
%[ind,inc] = sort(dist,2) ; 
%%找出对每个M的connect 
    
for i = 1 : m 
     for j = 1 : m
         if  conn(i,j) == 1 
            d(i, j) = L2_distance (M(i,:)', M(j,:)') ;
         else 
            d(i, j) = 0 ;
         end    
     end
end
%%排序 定义邻域半径 最大拓扑半径
ind = sort(d,2,'descend') ; r = ind(:,1);
%% 邻域划分 找出ni 
dist = L2_distance(M',X') ;
%%节点与真实数据映射；
[a,b]  = sort(dist,2) ;
%%center
center = X(b(:,1),:);
%%center distance 
cendis = L2_distance(center',X');
ni = cell(1,m);
rate = 1.1 ;
for i = 1 : m 
   while length(ni{i}) <= dim
    ni{i} =  find (cendis(i,:) < r(i) ) ;
    r(i) = r(i) * rate;
   end
end 
neigbor = ni ;

    

