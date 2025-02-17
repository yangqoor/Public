function out = NM(func,st)
st = st(:);
N = numel(st);
%--------------------------------------------------------------------------
%   存放输入输出矢量
%--------------------------------------------------------------------------
X = zeros(N,N+1);
Y = zeros(1,N+1);

%--------------------------------------------------------------------------
%   传入初值
%--------------------------------------------------------------------------
st(st==0)=0.00025;
X(:,1) = st;

%--------------------------------------------------------------------------
%   初始点生成
%--------------------------------------------------------------------------
for idx = 2:N+1
    X(:,idx) = X(:,1);
    X(idx-1,idx) = X(idx-1,1)*1.05;
end

%--------------------------------------------------------------------------
%   循环搜索
%--------------------------------------------------------------------------
for idx = 1:1000 idx
    %----------------------------------------------------------------------
    %   输出Y值
    %----------------------------------------------------------------------
    for jdx = 1:N+1
        Y(jdx) = func(X(:,jdx));
    end
    
    %----------------------------------------------------------------------
    %   排序
    %----------------------------------------------------------------------
    [Y,order] = sort(Y);
    X = X(:,order);
    
    %----------------------------------------------------------------------
    %   最差点与最佳点很接近,跳出循环
    %----------------------------------------------------------------------
    if norm(X(:,1)-X(:,end))<=1e-3
        disp("NM:最好与最差点距离 < 1e-3 退出")
        break;
    end    
    
    %----------------------------------------------------------------------
    %   计算质心
    %----------------------------------------------------------------------
    m = mean(X(:,1:end-1),2);
    
    %----------------------------------------------------------------------
    %   计算反射点
    %----------------------------------------------------------------------
    r = 2*m-X(:,end);fr = func(r);
    
    %----------------------------------------------------------------------
    %   落在最小最大之间,替换最大值
    %----------------------------------------------------------------------
    if Y(1)<= fr && fr<Y(end-1)
        X(:,end)=r;continue
    %----------------------------------------------------------------------
    %   比最小值还小,计算拓展点
    %----------------------------------------------------------------------
    elseif fr<Y(1)
        s = m + 2*(m-X(:,end));
        fs = func(s);
        %------------------------------------------------------------------
        %   拓展点还小，保留拓展点
        %------------------------------------------------------------------
        if fs<fr
            X(:,end)=s;continue
        %------------------------------------------------------------------
        %   拓展点一般，保留反射点
        %------------------------------------------------------------------
        else
            X(:,end)=r;continue
        end
    %----------------------------------------------------------------------
    %   落在次差之外情况
    %----------------------------------------------------------------------
    else
        %------------------------------------------------------------------
        %   如果落在次差和最差之间,延伸一半
        %------------------------------------------------------------------
        if fr < Y(end)
        c = m + (r-m)./2;
        %------------------------------------------------------------------
        %   如果落在最差之外,向内延展
        %------------------------------------------------------------------
        else
        c = m + (X(:,end)-m)./2;
        end
        fc = func(c);
        %------------------------------------------------------------------
        %   如果延展点小于最差点，替换
        %------------------------------------------------------------------
        if fc<=Y(end)
            X(:,end)=c;continue
        %------------------------------------------------------------------
        %   如果延展点还差，全部缩小一半
        %------------------------------------------------------------------
        else
            X(:,2:end) = X(:,2:end)*0.5;continue
        end
    end
end
out = X(:,1);
