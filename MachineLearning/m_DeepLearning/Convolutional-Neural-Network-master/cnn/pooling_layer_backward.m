function [input_od] = pooling_layer_backward(output, input, layer)

%% Input:
% input: input of pooling_layer_forward
% output: output of pooling_layer_forward

% layer.k: kernel size of pooling operation
% layer.stride: stride of pooling operation
% layer.pad: pad of pooling operation

%% function output
% input_od: gradient w.r.t input.data

%% Dimensions
k=layer.k;
s=layer.stride;
h_in = input.height;
w_in = input.width;
c = input.channel;
batch = input.batch_size;

h_out = output.height;
w_out = output.width;

% Initialize
input_od = zeros(size(input.data));

switch layer.act_type
    case 'MAX'
        input_re = reshape(input.data, h_in, w_in, c, batch);
        output.diff = reshape(output.diff,h_out,w_out,c,batch);
        od_temp=zeros(h_in,w_in,c,batch);
        for n=1:batch
            for citer=1:c
                for i = 1:h_out
                    for j = 1:w_out
                        [max_tem,h_index]=max(input_re(s*(i-1)+1:s*(i-1)+k,s*(j-1)+1:s*(j-1)+k,citer,n));
                        [~,w_index]=max(max_tem);
                        h_max=h_index(w_index);
                        w_max=w_index;
                        a=od_temp((i-1)*s+h_max,(j-1)*s+w_max,citer,n);
                        od_temp((i-1)*s+h_max,(j-1)*s+w_max,citer,n)=a+output.diff(i,j,citer,n);
                        a=0;
                    end
                end
            end
        end
        input_od=reshape(od_temp,h_in*w_in*c,batch);
 
    case 'AVE'
        output.diff = reshape(output.diff,h_out, w_out,c,batch);
        input_od = zeros(h_in,w_in,c,batch);
        temp=zeros(h_in,w_in,c,batch);
        for i = 1:h_out
            for j = 1:w_out
                temp=zeros(h_in,w_in,c,batch);
                temp(s*(i-1)+1:s*(i-1)+k,s*(j-1)+1:s*(j-1)+k,:,:)= (1/k)/k;
                for n=1:batch
                    for citer=1:c
                        temp1=temp*output.diff(i,j,citer,n);
                        input_od(:,:,citer,n)=input_od(:,:,citer,n)+temp1(:,:,citer,n);
                        
                    end
                end
            end
        end
        input_od=reshape(input_od,h_in*w_in*c,batch);		
		    
end