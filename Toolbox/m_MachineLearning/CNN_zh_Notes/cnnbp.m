function net = cnnbp(net, y)  
    n = numel(net.layers);    %layers����  
    %   error  
    net.e = net.o - y;   % 10*50  ÿһ�б�ʾһ������ͼ�� 
    
    %  loss function   ������� 
    net.L = 1/2 * sum(net.e(:).^ 2) / size(net.e, 2);   %% cost function û�м���������ɱ�Ҷ˹ѧ�ɵĹ۵�  
    % backprop deltas  
    net.od = net.e .* (net.o .* (1 - net.o));   %  output delta ��������� �������  10*50  
    net.fvd = (net.ffW' * net.od);              %  feature vector delta  ���һ�����ز���� ������²����㣬����a=z������������������������Ϊ1�����Ƕ�z�󵼣�������Ǿ���㣬��ô��Ҫ����f(z)�ĵ��� 192*50  
    if strcmp(net.layers{n}.type, 'c')         %  only conv layers has sigm function  
        net.fvd = net.fvd .* (net.fv .* (1 - net.fv));     %% ������һ�����ز��Ǿ���㣬ֱ���øù�ʽ���ܵõ����  
    end  
  
    %  reshape feature vector deltas into output map style  
    sa = size(net.layers{n}.a{1});    %%layers{n}����12��a ÿ��a����4*4*50  50 Ϊ����ͼƬ�ĸ���   n��ʾ���һ�����ز�  
    fvnum = sa(1) * sa(2);  
    for j = 1 : numel(net.layers{n}.a)   %%���һ�����ز�һ���ж��ٸ�feature maps��ÿ��feature map����ʾΪd{j}���4*4*50����ʽ��50Ϊ����ͼƬ���������������ڼ���ǰ���ε����**** ת��  
        net.layers{n}.d{j} = reshape(net.fvd(((j - 1) * fvnum + 1) : j * fvnum, :), sa(1), sa(2), sa(3));   %�����һ�����ز���feature maps����ʽ�����������ǰһ�����Ľ��  
    end  
  
    for l = (n - 1) : -1 : 1      %ʵ���ǵ�2��ֹ�ˣ�1������㣬û�����Ҫ��  
        if strcmp(net.layers{l}.type, 'c')   %�����ļ��㷽ʽ  
            for j = 1 : numel(net.layers{l}.a)   %��n-1����е�feature maps�ĸ��������б��� ÿ��d{j}��8*8*50����ʽ�� ������һ��Ϊ�²����㣬�ʺ�һ��d{j}��չΪ8*8�ģ�ÿ���㸴�Ƴ�2*2�ģ�,����bp����ʽ�Ϳ��Եó�������Ȩ�ؾ�Ϊ1/4,  
                net.layers{l}.d{j} = net.layers{l}.a{j} .* (1 - net.layers{l}.a{j}) .* (expand(net.layers{l + 1}.d{j}, [net.layers{l + 1}.scale net.layers{l + 1}.scale 1]) / net.layers{l + 1}.scale ^ 2);  
            end  
        elseif strcmp(net.layers{l}.type, 's')   %�²�����ļ��㷽ʽ  
            for i = 1 : numel(net.layers{l}.a)   %�ò�feature maps�ĸ��� ÿ��a����12*12*50 �Ĵ�С������50Ϊ����ͼƬ�ĸ���  
                z = zeros(size(net.layers{l}.a{1}));      %��С���� ��ǰ��feature map�Ĵ�С  
                for j = 1 : numel(net.layers{l + 1}.a)     %���㹫ʽ���� Notes on Convolutional Neural Networks��pdf��������ǰ���²����������Ĳ�����ÿ��feature map�����ӣ� �ʰ���bp�Ĺ�ʽҪ�������  
                     z = z + convn(net.layers{l + 1}.d{j}, rot180(net.layers{l + 1}.k{i}{j}), 'full');   %%% ���Ծ�һ���򵥵����ӽ��н���  ���нڵ���˶�����ӵ�(��Ϊ�ý�������һ�����е�feature maps���������ӵ�),  
                end                                                                                      %% ��� full valid��ʲô��˼ ҪŪ�����������  
                net.layers{l}.d{i} = z;          %% ��Ϊ���²����㣬����a=z,��f(z)=z,�����͵���1�����������������ӽ��Ȩֵ���һ������  
            end  
        end  
    end  
  
    %  calc gradients    %% ��kij��ƫ��û�п��� ΪʲôҪ�������  
    for l = 2 : n  
        if strcmp(net.layers{l}.type, 'c')  
            for j = 1 : numel(net.layers{l}.a)  
                for i = 1 : numel(net.layers{l - 1}.a)  
                    net.layers{l}.dk{i}{j} = convn(flipall(net.layers{l - 1}.a{i}), net.layers{l}.d{j}, 'valid') / size(net.layers{l}.d{j}, 3);   % ���Կ������е��Ƶ������������Ƚ�k rot180��Ȼ����rot����Ч����һ���ġ�  
                end  
                net.layers{l}.db{j} = sum(net.layers{l}.d{j}(:)) / size(net.layers{l}.d{j}, 3);   %% ��ƫ�ò���b�ĵ���  
            end  
        end  
    end  
    net.dffW = net.od * (net.fv)' / size(net.od, 2);      %softmax�ع��в�������Ӧ�ĵ���  
    net.dffb = mean(net.od, 2);                %% softmax�ع���������b����Ӧ�ĵ���  
  
    function X = rot180(X)  
        X = flipdim(flipdim(X, 1), 2);  % flipdim(X, 1) �л���  flipdim(X, 2) �л���  
    end  
end  