function test_example_CNN

%mnist_uint8在data文件夹下
load ./data/mnist_uint8.mat;
%60000*784转置784*60000再reshape成28*28
train_x = double(reshape(train_x',28,28,60000))/255;
%10000*784转置784*10000再reshape成28*28
test_x = double(reshape(test_x',28,28,10000))/255;
%取共轭转置60000*10转为10*60000；
train_y = double(train_y');
%取共轭转置10000*10转为10*10000
test_y = double(test_y');

%load('train_x.mat');
%load('train_y.mat');
%load('test_x.mat');
%load('test_y.mat');

%ex1 Train a 6c-2s-12c-2s Convolutional neural network 
%will run 1 epoch in about 200 second and get around 11% error. 
%With 100 epochs you'll get around 1.2% error

%设置随机数生成器的初始状态
rand('state',0)

% 设置各层feature maps个数及卷积模板大小等属性  
cnn.layers = {
    
    %该函数将生成一个具有指定字段名和相应数据的结构数组，
    %其包含的数据values1、valuese2等必须为具有相同维数的数据，
    %数据的存放位置域其他结构位置一一对应的
    struct('type', 'i') %input layer
    struct('type', 'c', 'outputmaps', 6, 'kernelsize', 5) %convolution layer
%     struct('type', 'c', 'outputmaps', 32, 'kernelsize', 5)
    struct('type', 's', 'scale', 2) %sub sampling layer
    struct('type', 'c', 'outputmaps', 12, 'kernelsize', 5) %convolution layer
%     struct('type', 'c', 'outputmaps', 64, 'kernelsize', 5)
    struct('type', 's', 'scale', 2) %subsampling layer
};

opts.alpha = 0.1; %迭代下降的速率  
opts.batchsize = 100; %每次选择50个样本进行更新  随机梯度下降，每次只选用50个样本进行更新  
opts.numepochs = 1; %迭代次数  

cnn = cnnsetup(cnn, train_x, train_y);   %对各层参数进行初始化 包括权重和偏置  
cnn = cnntrain(cnn, train_x, train_y, opts);%训练的过程，包括bp算法及迭代过程  

[er, bad] = cnntest(cnn, test_x, test_y);

%保存结果
save('./result/net.mat', 'cnn');
%plot mean squared error
figure; plot(cnn.rL);
assert(er<0.12, 'Too big error');
