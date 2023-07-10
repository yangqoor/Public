
%%cnn = cnnsetup(cnn, train_x, train_y); 
function net = cnnsetup(net, x, y)
    assert(~isOctave() || compare_versions(OCTAVE_VERSION, '3.8.0', '>='), ['Octave 3.8.0 or greater is required for CNNs as there is a bug in convolution in previous versions. See http://savannah.gnu.org/bugs/?39314. Your version is ' myOctaveVersion]);
    inputmaps = 1;   %输入图片数量 第一层为1幅 输入feature maps数量  
    mapsize = size(squeeze(x(:, :, 1)));% 特征图大小，就是输入样本的大小 squeeze 要不要都行28 28 

    for l = 1 : numel(net.layers)   %  layer  l=1 to 5 numel求layers中的元素数，前面设置了五层
        %初始化池化层，设置偏值为0
        if strcmp(net.layers{l}.type, 's')          %如果是池化层
            %mapsize/=2;
            %池化后的特征图大小为上层特征图除以池化尺度，这里是一半
            mapsize = mapsize / net.layers{l}.scale;    % sumsampling的featuremap长宽都是上一层卷积层featuremap的一半  
            %判断是否为整数，确保池化后的大小是整数值
            assert(all(floor(mapsize)==mapsize), ['Layer ' num2str(l) ' size must be integer. Actual: ' num2str(mapsize)]);
            %当前池化层有inputmaps个特征图,偏值个数与特征图个数是一样的，均初始化为0
            for j = 1 : inputmaps
                net.layers{l}.b{j} = 0;      % 将偏置初始化0, 权重weight，，这段代码subsampling层将weight设为1/4 而偏置参数设为0，故subsampling阶段无需参数  
            end
        end
        
        %初始化卷积层
        if strcmp(net.layers{l}.type, 'c')      %卷积层
            %mapsize = mapsize - 5 + 1
            % 卷积层特征图像大小，减去核大小加上1就好
            mapsize = mapsize - net.layers{l}.kernelsize + 1; % 得到当前层feature map的大小 
            %fan_out = 6*5^2 或者 fan_out = 12*5^2
            % 用来初始化卷积核，当前层特征图个数乘以当前层卷积核大小的平方
            fan_out = net.layers{l}.outputmaps * net.layers{l}.kernelsize ^ 2; % fan_out与fan_in都是用来初始化kernel的,不知道why  
            %遍历所有输出特征图
            for j = 1 : net.layers{l}.outputmaps  %  output map  当前层feature maps的个数  
                % fan_in = 1*6^2 或者 fan_in = 1*12^2
                % 输入特征图个数乘以卷积和大小的平方 用来初始化卷积核
                fan_in = inputmaps * net.layers{l}.kernelsize ^ 2;
                %遍历所有输入特征图
                for i = 1 : inputmaps  %  input map          共享权值，故kernel参数个数为inputmaps*outputmaps个数,每一个都是5*5  
                    % 初始化每个feature map对应的kernel参数 -0.5 再乘2归一化到[-1,1],最终归一化到[-sqrt(6 / (fan_in + fan_out)),+sqrt(6 / (fan_in + fan_out))] why??  
                    % 初始化第i个输入特征图的的第j个卷积核
                    net.layers{l}.k{i}{j} = (rand(net.layers{l}.kernelsize) - 0.5) * 2 * sqrt(6 / (fan_in + fan_out));
                end
                net.layers{l}.b{j} = 0;% 初始话feture map对应的偏置参数 初始化为0  
            end
            %下层的输入特征图是上层输出特征图
            inputmaps = net.layers{l}.outputmaps; % 修改输入feature maps的个数以便下次使用,??????  
        end
    end
    % 'onum' is the number of labels, that's why it is calculated using size(y, 1). If you have 20 labels so the output of the network will be 20 neurons.
    % 'fvnum' is the number of output neurons at the last layer, the layer just before the output layer.
    % 'fvnum'是输出层的前面一层的神经元个数
    % 'ffb' is the biases of the output neurons.
    % 'ffW' is the weights between the last layer and the output neurons. Note that the last layer is fully connected to the output layer, that's why the size of the weights is (onum * fvnum)
    % prod用来计算数组所有元素之积 此时的mapsize是最后一个卷积层输出特征图的大小 原例子中是4*4
    % 再乘以特征图个数，就是最后的特征向量维数，也是全连接层的神经元个数
    fvnum = prod(mapsize) * inputmaps; % S4最后结点个数即为特征的个数 用作全连接 12*4*4=192维特征 
    onum = size(y, 1);   %最终分类的个数，y的行数  10类  

    % 设置最后一层参数 softmax层
    net.ffb = zeros(onum, 1);  %softmaxt回归的偏置参数个数 
    % ffW 输出层前一层 与 输出层 连接的权值，这两层之间是全连接的  
    net.ffW = (rand(onum, fvnum) - 0.5) * 2 * sqrt(6 / (onum + fvnum)); %% softmaxt回归的权值参数 为10*192个 全连接
end
