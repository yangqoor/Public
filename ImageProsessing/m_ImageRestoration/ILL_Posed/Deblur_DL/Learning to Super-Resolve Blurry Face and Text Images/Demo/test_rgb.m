flag_gpu=true;
data_name='face';
factor=4;

load(sprintf('../Models/%s.mat',data_name))

if strcmp(net_G.layers{end}.name,'loss')
    net_G.layers(end)=[];
end
net_G.layers{end}.forward = @f_tanh;

net_G=vl_simplenn_move(net_G,'cpu');
if flag_gpu
    net_G=vl_simplenn_move(net_G,'gpu');
end

idx=0;
pic=im2double(imread(sprintf('../Datasets/%s_input/%07d_degr.png',data_name,idx)));
gt=im2double(imread(sprintf('../Datasets/%s_gt/%07d_orig.png',data_name,idx)));
input=single(pic)*2-1;
if flag_gpu
    input=gpuArray(input);
end
res=vl_simplenn(net_G,input,[],[],'mode','test');
output=(res(end).x+1)/2;
output=double(output);
output=gather(output);
im_recons = reduce_artifact( pic, output, factor );

subplot(131),imshow(pic),title('input')
subplot(132),imshow(im_recons),title('ours')
subplot(133),imshow(gt),title('gt')
