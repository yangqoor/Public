function net = cnnbp(net, y)  
    n = numel(net.layers);    %layers个数  
    %   error  
    net.e = net.o - y;   % 10*50  每一列表示一个样本图像 
    
    %  loss function   均方误差 
    net.L = 1/2 * sum(net.e(:).^ 2) / size(net.e, 2);   %% cost function 没有加入参数构成贝叶斯学派的观点  
    % backprop deltas  
    net.od = net.e .* (net.o .* (1 - net.o));   %  output delta 输出层的误差 用来求解  10*50  
    net.fvd = (net.ffW' * net.od);              %  feature vector delta  最后一层隐藏层误差 如果是下采样层，由于a=z，所以误差就是这个结果（导数为1，就是对z求导），如果是卷积层，那么需要乘以f(z)的导数 192*50  
    if strcmp(net.layers{n}.type, 'c')         %  only conv layers has sigm function  
        net.fvd = net.fvd .* (net.fv .* (1 - net.fv));     %% 如果最后一个隐藏层是卷积层，直接用该公式就能得到误差  
    end  
  
    %  reshape feature vector deltas into output map style  
    sa = size(net.layers{n}.a{1});    %%layers{n}共有12个a 每个a都是4*4*50  50 为样本图片的个数   n表示最后一层隐藏层  
    fvnum = sa(1) * sa(2);  
    for j = 1 : numel(net.layers{n}.a)   %%最后一个隐藏层一共有多少个feature maps，每个feature map即表示为d{j}变成4*4*50的形式，50为样本图片数量，这样好用于计算前面层次的误差**** 转变  
        net.layers{n}.d{j} = reshape(net.fvd(((j - 1) * fvnum + 1) : j * fvnum, :), sa(1), sa(2), sa(3));   %将最后一层隐藏层变成feature maps的形式，这样易求解前一层卷积的结果  
    end  
  
    for l = (n - 1) : -1 : 1      %实际是到2终止了，1是输入层，没有误差要求  
        if strcmp(net.layers{l}.type, 'c')   %卷积层的计算方式  
            for j = 1 : numel(net.layers{l}.a)   %第n-1层具有的feature maps的个数，进行遍历 每个d{j}是8*8*50的形式， 由于下一层为下采样层，故后一层d{j}扩展为8*8的（每个点复制成2*2的）,按照bp求误差公式就可以得出，这里权重就为1/4,  
                net.layers{l}.d{j} = net.layers{l}.a{j} .* (1 - net.layers{l}.a{j}) .* (expand(net.layers{l + 1}.d{j}, [net.layers{l + 1}.scale net.layers{l + 1}.scale 1]) / net.layers{l + 1}.scale ^ 2);  
            end  
        elseif strcmp(net.layers{l}.type, 's')   %下采样层的计算方式  
            for i = 1 : numel(net.layers{l}.a)   %该层feature maps的个数 每个a都是12*12*50 的大小，其中50为样本图片的个数  
                z = zeros(size(net.layers{l}.a{1}));      %大小等于 当前层feature map的大小  
                for j = 1 : numel(net.layers{l + 1}.a)     %计算公式来自 Notes on Convolutional Neural Networks的pdf，，将当前层下采样层与后面的采样层每个feature map相连接， 故按照bp的公式要进行求和  
                     z = z + convn(net.layers{l + 1}.d{j}, rot180(net.layers{l + 1}.k{i}{j}), 'full');   %%% 可以举一个简单的例子进行讲解  所有节点相乘都是相加的(因为该结点是与后一层所有的feature maps都是有连接的),  
                end                                                                                      %% 卷积 full valid是什么意思 要弄清楚？？？？  
                net.layers{l}.d{i} = z;          %% 因为是下采样层，所以a=z,就f(z)=z,导数就等于1，所以误差就是所连接结点权值与后一层误差和  
            end  
        end  
    end  
  
    %  calc gradients    %% 对kij求偏导没有看懂 为什么要进行求和  
    for l = 2 : n  
        if strcmp(net.layers{l}.type, 'c')  
            for j = 1 : numel(net.layers{l}.a)  
                for i = 1 : numel(net.layers{l - 1}.a)  
                    net.layers{l}.dk{i}{j} = convn(flipall(net.layers{l - 1}.a{i}), net.layers{l}.d{j}, 'valid') / size(net.layers{l}.d{j}, 3);   % 可以看论文中的推导！与论文中先将k rot180，然后再rot整体效果是一样的。  
                end  
                net.layers{l}.db{j} = sum(net.layers{l}.d{j}(:)) / size(net.layers{l}.d{j}, 3);   %% 对偏置参数b的导数  
            end  
        end  
    end  
    net.dffW = net.od * (net.fv)' / size(net.od, 2);      %softmax回归中参数所对应的导数  
    net.dffb = mean(net.od, 2);                %% softmax回归中最后参数b所对应的导数  
  
    function X = rot180(X)  
        X = flipdim(flipdim(X, 1), 2);  % flipdim(X, 1) 行互换  flipdim(X, 2) 列互换  
    end  
end  