function [ im_recons ] = reduce_artifact( pic, output, factor )

pic_=imresize(pic,factor);
pic_=rgb2ycbcr(pic_);
im_recons=pic_;

y=rgb2ycbcr(output);
y=y(:,:,1);
im_recons(:,:,1)=y;
im_recons=ycbcr2rgb(im_recons);

end

