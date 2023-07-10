function test_example_CNN

%mnist_uint8��data�ļ�����
load ./data/mnist_uint8.mat;
%60000*784ת��784*60000��reshape��28*28
train_x = double(reshape(train_x',28,28,60000))/255;
%10000*784ת��784*10000��reshape��28*28
test_x = double(reshape(test_x',28,28,10000))/255;
%ȡ����ת��60000*10תΪ10*60000��
train_y = double(train_y');
%ȡ����ת��10000*10תΪ10*10000
test_y = double(test_y');

%load('train_x.mat');
%load('train_y.mat');
%load('test_x.mat');
%load('test_y.mat');

%ex1 Train a 6c-2s-12c-2s Convolutional neural network 
%will run 1 epoch in about 200 second and get around 11% error. 
%With 100 epochs you'll get around 1.2% error

%����������������ĳ�ʼ״̬
rand('state',0)

% ���ø���feature maps���������ģ���С������  
cnn.layers = {
    
    %�ú���������һ������ָ���ֶ�������Ӧ���ݵĽṹ���飬
    %�����������values1��valuese2�ȱ���Ϊ������ͬά�������ݣ�
    %���ݵĴ��λ���������ṹλ��һһ��Ӧ��
    struct('type', 'i') %input layer
    struct('type', 'c', 'outputmaps', 6, 'kernelsize', 5) %convolution layer
%     struct('type', 'c', 'outputmaps', 32, 'kernelsize', 5)
    struct('type', 's', 'scale', 2) %sub sampling layer
    struct('type', 'c', 'outputmaps', 12, 'kernelsize', 5) %convolution layer
%     struct('type', 'c', 'outputmaps', 64, 'kernelsize', 5)
    struct('type', 's', 'scale', 2) %subsampling layer
};

opts.alpha = 0.1; %�����½�������  
opts.batchsize = 100; %ÿ��ѡ��50���������и���  ����ݶ��½���ÿ��ֻѡ��50���������и���  
opts.numepochs = 1; %��������  

cnn = cnnsetup(cnn, train_x, train_y);   %�Ը���������г�ʼ�� ����Ȩ�غ�ƫ��  
cnn = cnntrain(cnn, train_x, train_y, opts);%ѵ���Ĺ��̣�����bp�㷨����������  

[er, bad] = cnntest(cnn, test_x, test_y);

%������
save('./result/net.mat', 'cnn');
%plot mean squared error
figure; plot(cnn.rL);
assert(er<0.12, 'Too big error');
