dirname='resdir'

sig_noise=0.01;
load test_data/sizeL





for i=[1:4]
   for j=[5,3,2,1,6,7,8,4]
      [i,j]
      
      eval(sprintf('load test_data/im%02d_ker%02d',i,j))
      mat_outname=sprintf('%s/freq_img_gauss_im%d_ker%d.mat',dirname,i,j);
      bmp_outname=sprintf('%s/freq_img_gauss_im%d_ker%d',dirname,i,j);
                 
      d=dir(mat_outname);

      [k,ex,ssde]=deconv_freq_img_gauss(y,sizeL(j),sizeL(j),x,sig_noise,bmp_outname,0);

      eval(sprintf('save  %s k ex ssde' ,mat_outname))
      %keyboard
   end
end

