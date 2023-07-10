N_map=10; %the N-th feature map
N_sample=10; % Number of samples to visualize
N_start=500; % N_start to (N_start+N_sample-1) samples
load_mnist_all
load lenet.mat;
img=xtest(:,N_start:N_start+N_sample-1);
input.data=img;

%layers{2}
layer.type = 'CONV'; % second layer is conv layer
layer.num = 20; % number of output channel
layer.k = 5; % kernel size
layer.stride = 1; % stride size
layer.pad = 0; % padding size
layer.group = 1; 

%input
input.height=28;
input.width=28;
input.channel=1;
input.batch_size=N_sample;

%output
h_out=24;
w_out=24;

%do the filtering
output=conv_layer_forward(input,layer,params{1});

%reshape and pick the N-th map
output_image=reshape(output.data,h_out,w_out,layer.num,N_sample);
output_image_N=reshape(output_image(:,:,N_map,:),h_out,w_out,N_sample);

img_show=reshape(img,input.height,input.width,N_sample);
for l=1:N_sample
    subplot(5,4,l*2);
    imshow(output_image_N(:,:,l)')
    subplot(5,4,l*2-1);
    imshow(img_show(:,:,l)')
end
