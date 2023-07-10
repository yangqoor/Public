
%%cnn = cnnsetup(cnn, train_x, train_y); 
function net = cnnsetup(net, x, y)
    assert(~isOctave() || compare_versions(OCTAVE_VERSION, '3.8.0', '>='), ['Octave 3.8.0 or greater is required for CNNs as there is a bug in convolution in previous versions. See http://savannah.gnu.org/bugs/?39314. Your version is ' myOctaveVersion]);
    inputmaps = 1;   %����ͼƬ���� ��һ��Ϊ1�� ����feature maps����  
    mapsize = size(squeeze(x(:, :, 1)));% ����ͼ��С���������������Ĵ�С squeeze Ҫ��Ҫ����28 28 

    for l = 1 : numel(net.layers)   %  layer  l=1 to 5 numel��layers�е�Ԫ������ǰ�����������
        %��ʼ���ػ��㣬����ƫֵΪ0
        if strcmp(net.layers{l}.type, 's')          %����ǳػ���
            %mapsize/=2;
            %�ػ��������ͼ��СΪ�ϲ�����ͼ���Գػ��߶ȣ�������һ��
            mapsize = mapsize / net.layers{l}.scale;    % sumsampling��featuremap��������һ������featuremap��һ��  
            %�ж��Ƿ�Ϊ������ȷ���ػ���Ĵ�С������ֵ
            assert(all(floor(mapsize)==mapsize), ['Layer ' num2str(l) ' size must be integer. Actual: ' num2str(mapsize)]);
            %��ǰ�ػ�����inputmaps������ͼ,ƫֵ����������ͼ������һ���ģ�����ʼ��Ϊ0
            for j = 1 : inputmaps
                net.layers{l}.b{j} = 0;      % ��ƫ�ó�ʼ��0, Ȩ��weight������δ���subsampling�㽫weight��Ϊ1/4 ��ƫ�ò�����Ϊ0����subsampling�׶��������  
            end
        end
        
        %��ʼ�������
        if strcmp(net.layers{l}.type, 'c')      %�����
            %mapsize = mapsize - 5 + 1
            % ���������ͼ���С����ȥ�˴�С����1�ͺ�
            mapsize = mapsize - net.layers{l}.kernelsize + 1; % �õ���ǰ��feature map�Ĵ�С 
            %fan_out = 6*5^2 ���� fan_out = 12*5^2
            % ������ʼ������ˣ���ǰ������ͼ�������Ե�ǰ�����˴�С��ƽ��
            fan_out = net.layers{l}.outputmaps * net.layers{l}.kernelsize ^ 2; % fan_out��fan_in����������ʼ��kernel��,��֪��why  
            %���������������ͼ
            for j = 1 : net.layers{l}.outputmaps  %  output map  ��ǰ��feature maps�ĸ���  
                % fan_in = 1*6^2 ���� fan_in = 1*12^2
                % ��������ͼ�������Ծ���ʹ�С��ƽ�� ������ʼ�������
                fan_in = inputmaps * net.layers{l}.kernelsize ^ 2;
                %����������������ͼ
                for i = 1 : inputmaps  %  input map          ����Ȩֵ����kernel��������Ϊinputmaps*outputmaps����,ÿһ������5*5  
                    % ��ʼ��ÿ��feature map��Ӧ��kernel���� -0.5 �ٳ�2��һ����[-1,1],���չ�һ����[-sqrt(6 / (fan_in + fan_out)),+sqrt(6 / (fan_in + fan_out))] why??  
                    % ��ʼ����i����������ͼ�ĵĵ�j�������
                    net.layers{l}.k{i}{j} = (rand(net.layers{l}.kernelsize) - 0.5) * 2 * sqrt(6 / (fan_in + fan_out));
                end
                net.layers{l}.b{j} = 0;% ��ʼ��feture map��Ӧ��ƫ�ò��� ��ʼ��Ϊ0  
            end
            %�²����������ͼ���ϲ��������ͼ
            inputmaps = net.layers{l}.outputmaps; % �޸�����feature maps�ĸ����Ա��´�ʹ��,??????  
        end
    end
    % 'onum' is the number of labels, that's why it is calculated using size(y, 1). If you have 20 labels so the output of the network will be 20 neurons.
    % 'fvnum' is the number of output neurons at the last layer, the layer just before the output layer.
    % 'fvnum'��������ǰ��һ�����Ԫ����
    % 'ffb' is the biases of the output neurons.
    % 'ffW' is the weights between the last layer and the output neurons. Note that the last layer is fully connected to the output layer, that's why the size of the weights is (onum * fvnum)
    % prod����������������Ԫ��֮�� ��ʱ��mapsize�����һ��������������ͼ�Ĵ�С ԭ��������4*4
    % �ٳ�������ͼ����������������������ά����Ҳ��ȫ���Ӳ����Ԫ����
    fvnum = prod(mapsize) * inputmaps; % S4����������Ϊ�����ĸ��� ����ȫ���� 12*4*4=192ά���� 
    onum = size(y, 1);   %���շ���ĸ�����y������  10��  

    % �������һ����� softmax��
    net.ffb = zeros(onum, 1);  %softmaxt�ع��ƫ�ò������� 
    % ffW �����ǰһ�� �� ����� ���ӵ�Ȩֵ��������֮����ȫ���ӵ�  
    net.ffW = (rand(onum, fvnum) - 0.5) * 2 * sqrt(6 / (onum + fvnum)); %% softmaxt�ع��Ȩֵ���� Ϊ10*192�� ȫ����
end
