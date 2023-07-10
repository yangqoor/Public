function net = cnntrain(net, x, y, opts)  
    m = size(x, 3);   %% 图片一共的数量 60000  
    %numbatches = m / 50 = 1200；
    % 一共m个样本，每次随机选其中batchsize个进行训练
    numbatches = m / opts.batchsize;    % 循环的次数 共1200次，每次使用50个样本进行  
    if rem(numbatches, 1) ~= 0  
        error('numbatches not integer');  
    end  
    
    %保存误差值  
    net.rL = [];  
    % 按设置的迭代次数进行迭代
    for i = 1 : opts.numepochs      
        %显示第几次迭代/总迭代次数
        disp(['epoch ' num2str(i) '/' num2str(opts.numepochs)]);  
        %计时
        tic;  
        % 产生1:m的一个随机排列
        kk = randperm(m);  % 随机产生m以内的不重复的m个数  
        
        net.ffcnt = 0;
        for l = 1 : numbatches    % 循环1200次，每次选取50个样本进行更新  
            
            net.ffcnt = net.ffcnt + 1;     %前向传播计数
            
            disp(['doing' num2str(l) 'iterator']); 
            % 取1:50，51:100,101:150.。。。这样取下去
            batch_x = x(:, :, kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));    %50个样本的训练数据  
            batch_y = y(:,    kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize));    %50个样本所对应的标签  
          
            % 在当前的网络权值和网络输入下计算网络的输出 
            net = cnnff(net, batch_x);        %计算前向传播  
            % 得到上面的网络输出后，通过对应的样本标签用bp算法来得到误差对网络权值（也就是那些卷积核的元素）的导数
            net = cnnbp(net, batch_y);        %bp算法更新参数  
            
            opts.i = i;  
            opts.l = l;  
            net = cnnapplygrads(net, opts);   % 运用梯度迭代更新参数  
            %rL是最小均方误差的平滑序列
            if isempty(net.rL)%为空
                net.rL(1) = net.L; %loss function的值
            end
            net.rL(end + 1) = 0.99 * net.rL(end) + 0.01 * net.L; 
            %相当于对每一个batch的误差进行累积（加权平均）  
        end  
        toc;  
    end  

end  
