function net = cnnff(net, x)  
    n = numel(net.layers); % 层数  
    net.layers{1}.a{1} = x; % 网络的第一层就是输入，但这里的输入包含了多个训练图像  
    
    inputmaps = 1; % 输入层只有一个特征map，也就是原始的输入图像  
    
    for l = 2 : n   %  for each layer  
        if strcmp(net.layers{l}.type, 'c') % 卷积层  
            %  !!below can probably be handled by insane matrix operations  
            % 对每一个输入map，或者说我们需要用outputmaps个不同的卷积核去卷积图像  
            for j = 1 : net.layers{l}.outputmaps   %  for each output map  
                %  create temp output map 
                z = zeros(size(net.layers{l - 1}.a{1}) - [net.layers{l}.kernelsize-1 net.layers{l}.kernelsize-1 0]);  
                for i = 1 : inputmaps   %  for each input map  
                    %  convolve with corresponding kernel and add to temp output map  
                    % 将上一层的每一个特征map（也就是这层的输入map）与该层的卷积核进行卷积  
                    % 然后将对上一层特征map的所有结果加起来。也就是说，当前层的一张特征map，是  
                    % 用一种卷积核去卷积上一层中所有的特征map，然后所有特征map对应位置的卷积值的和  
                    % 另外，有些论文或者实际应用中，并不是与全部的特征map链接的，有可能只与其中的某几个连接  
                    z = z + convn(net.layers{l - 1}.a{i}, net.layers{l}.k{i}{j}, 'valid');  
                end  
                               
                %  add bias, pass through nonlinearity  
                % 加上对应位置的基b，然后再用sigmoid函数算出特征map中每个位置的激活值，作为该层输出特征map  
                net.layers{l}.a{j} = sigm(z + net.layers{l}.b{j});  
                
                
                %保存中间结果
%               imgSavePath = [savepath,'subImge', num2str(i),'.jpg'];
                ffout = net.layers{l}.a{j};
                savepath = strcat('./result/net.layers{',num2str(l),'}.a{',num2str(j),'}','.mat');
                if(mod(net.ffcnt,100)==0)
                    save(savepath,'ffout');
                end
                
            end  
            %  set number of input maps to this layers number of outputmaps  
            inputmaps = net.layers{l}.outputmaps;  
        elseif strcmp(net.layers{l}.type, 's') % 下采样层  
            %  downsample  
            for j = 1 : inputmaps  
                %  !! replace with variable  
                % 例如我们要在scale=2的域上面执行mean pooling，那么可以卷积大小为2*2，每个元素都是1/4的卷积核  
                z = convn(net.layers{l - 1}.a{j}, ones(net.layers{l}.scale) / (net.layers{l}.scale ^ 2), 'valid');   
                % 因为convn函数的默认卷积步长为1，而pooling操作的域是没有重叠的，所以对于上面的卷积结果  
                % 最终pooling的结果需要从上面得到的卷积结果中以scale=2为步长，跳着把mean pooling的值读出来  
                net.layers{l}.a{j} = z(1 : net.layers{l}.scale : end, 1 : net.layers{l}.scale : end, :);  
            end  
        end  
    end  
  
    %  concatenate all end layer feature maps into vector  
    % 把最后一层得到的特征map拉成一条向量，作为最终提取到的特征向量  
    net.fv = [];  
    for j = 1 : numel(net.layers{n}.a) % 最后一层的特征map的个数  
        sa = size(net.layers{n}.a{j}); % 第j个特征map的大小  
        % 将所有的特征map拉成一条列向量。还有一维就是对应的样本索引。每个样本一列，每列为对应的特征向量  
        net.fv = [net.fv; reshape(net.layers{n}.a{j}, sa(1) * sa(2), sa(3))];  
    end  
    %  feedforward into output perceptrons  
    % 计算网络的最终输出值。sigmoid(W*X + b)，注意是同时计算了batchsize个样本的输出值  
    net.o = sigm(net.ffW * net.fv + repmat(net.ffb, 1, size(net.fv, 2)));  
  
end  