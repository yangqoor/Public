
dirname='resdir'



sclk=4;
max_k_sz=25;
kL=zeros(max_k_sz,max_k_sz,8,4,7);


for i=1:4
    for j=1:8
          
       eval(sprintf('load %s/groundtruth_im%d_ker%d',dirname,i,j))
       errL(i,j,8)=ssde;
       k=k/max(k(:))*1.15;
       k_sz=size(k,1);
       kex=ex; kex(1:k_sz*sclk,1:k_sz*sclk)=imresize(k,sclk,'nearest');
       k=zero_pad(k,(max_k_sz-k_sz)/2,(max_k_sz-k_sz)/2);
       kL(:,:,j,i,8)=k/max(k(:))*1.15;
%        imwrite(ex,sprintf('%s/deconvedimgs/groundtruth_im%d_ker%d.bmp',dirname,i,j))
%        imwrite(kex,sprintf('%s/deconvedimgsandker/groundtruth_im%d_ker%d.bmp',dirname,i,j))
%        imwrite(ex,sprintf('%s/deconvedimgs/groundtruth_im%d_ker%d.jpg',dirname,i,j))
%        imwrite(kex,sprintf('%s/deconvedimgsandker/groundtruth_im%d_ker%d.jpg',dirname,i,j))
    end
  
end


for i=1:4
    for j=1:8
      
      mat_outname=sprintf('%s/diagfe_filt_sps_im%d_ker%d.mat',dirname,i,j);
      d=dir(mat_outname);
      if (length(d)==0)
         errL(i,j,4)=nan;
      else
          eval(['load ',mat_outname]);
          errL(i,j,4)=ssde;
          k=k/max(k(:))*1.15;
          k_sz=size(k,1);
          kex=ex; kex(1:k_sz*sclk,1:k_sz*sclk)=imresize(k,sclk,'nearest');
          k=zero_pad(k,(max_k_sz-k_sz)/2,(max_k_sz-k_sz)/2);
          kL(:,:,j,i,4)=k;
%           imwrite(ex,sprintf('%s/deconvedimgs/diagfe_filt_sps_im%d_ker%d.bmp',dirname,i,j))
%           imwrite(kex,sprintf('%s/deconvedimgsandker/diagfe_filt_sps_im%d_ker%d.bmp',dirname,i,j))
%           imwrite(ex,sprintf('%s/deconvedimgs/diagfe_filt_sps_im%d_ker%d.jpg',dirname,i,j))
%           imwrite(kex,sprintf('%s/deconvedimgsandker/diagfe_filt_sps_im%d_ker%d.jpg',dirname,i,j))
      
      end
      
   end;
end





for i=1:4
    for j=1:8
      
      mat_outname=sprintf('%s/smp_filt_sps_im%d_ker%d.mat',dirname,i,j);
      d=dir(mat_outname);
      if (length(d)==0)
         errL(i,j,5)=nan;
      else
          eval(['load ',mat_outname]);
          errL(i,j,5)=ssde;
          k=k/max(k(:))*1.15;
          k_sz=size(k,1);
          kex=ex; kex(1:k_sz*sclk,1:k_sz*sclk)=imresize(k,sclk,'nearest');
          k=zero_pad(k,(max_k_sz-k_sz)/2,(max_k_sz-k_sz)/2);
          kL(:,:,j,i,5)=k;
%           imwrite(ex,sprintf('%s/deconvedimgs/smp_filt_sps_im%d_ker%d.bmp',dirname,i,j))
%           imwrite(kex,sprintf('%s/deconvedimgsandker/smp_filt_sps_im%d_ker%d.bmp',dirname,i,j))
%           imwrite(ex,sprintf('%s/deconvedimgs/smp_filt_sps_im%d_ker%d.jpg',dirname,i,j))
%           imwrite(kex,sprintf('%s/deconvedimgsandker/smp_filt_sps_im%d_ker%d.jpg',dirname,i,j))
      
      end
    end;
end




  for i=1:4
    for j=1:8
      mat_outname=sprintf('%s/diagfe_img_sps_im%d_ker%d.mat',dirname,i,j);
      
      d=dir(mat_outname);
      if (length(d)==0)
         errL(i,j,2)=nan;
      else
          eval(['load ',mat_outname]);
          errL(i,j,2)=ssde;
          k=k/max(k(:))*1.15;
          k_sz=size(k,1);
          kex=ex; kex(1:k_sz*sclk,1:k_sz*sclk)=imresize(k,sclk,'nearest');
          k=zero_pad(k,(max_k_sz-k_sz)/2,(max_k_sz-k_sz)/2);
          kL(:,:,j,i,2)=k;
%           imwrite(ex,sprintf('%s/deconvedimgs/diagfe_img_sps_im%d_ker%d.bmp',dirname,i,j))
%           imwrite(kex,sprintf('%s/deconvedimgsandker/diagfe_img_sps_im%d_ker%d.bmp',dirname,i,j))
%           imwrite(ex,sprintf('%s/deconvedimgs/diagfe_img_sps_im%d_ker%d.jpg',dirname,i,j))
%           imwrite(kex,sprintf('%s/deconvedimgsandker/diagfe_img_sps_im%d_ker%d.jpg',dirname,i,j))
      
      end
      
    end;
  end




for i=1:4
   for j=1:8
      mat_outname=sprintf('%s/freq_img_gauss_im%d_ker%d.mat',dirname,i,j);
      
      d=dir(mat_outname);
      if (length(d)==0)
         errL(i,j,1)=nan;
      else
          eval(['load ',mat_outname]);
          errL(i,j,1)=ssde;
          k=k/max(k(:))*1.15;
          k_sz=size(k,1);
          kex=ex; kex(1:k_sz*sclk,1:k_sz*sclk)=imresize(k,sclk,'nearest');
          k=zero_pad(k,(max_k_sz-k_sz)/2,(max_k_sz-k_sz)/2);
          kL(:,:,j,i,1)=k/max(k(:))*1.15;
%           imwrite(ex,sprintf('%s/deconvedimgs/freq_img_gauss_im%d_ker%d.bmp',dirname,i,j))
%           imwrite(kex,sprintf('%s/deconvedimgsandker/freq_img_gauss_im%d_ker%d.bmp',dirname,i,j))
%           imwrite(ex,sprintf('%s/deconvedimgs/freq_img_gauss_im%d_ker%d.jpg',dirname,i,j))
%           imwrite(kex,sprintf('%s/deconvedimgsandker/freq_img_gauss_im%d_ker%d.jpg',dirname,i,j))
      
      end
      
    end;
  end

for i=1:4
   for j=1:8
      mat_outname=sprintf('%s/freq_filt_gauss_im%d_ker%d.mat',dirname,i,j);
      
      d=dir(mat_outname);
      if (length(d)==0)
         errL(i,j,3)=nan;
      else
          eval(['load ',mat_outname]);
          errL(i,j,3)=ssde;
          k=k/max(k(:))*1.15;
          k_sz=size(k,1);
          kex=ex; kex(1:k_sz*sclk,1:k_sz*sclk)=imresize(k,sclk,'nearest');
          k=zero_pad(k,(max_k_sz-k_sz)/2,(max_k_sz-k_sz)/2);
          kL(:,:,j,i,3)=k/max(k(:))*1.15;
%           imwrite(ex,sprintf('%s/deconvedimgs/freq_filt_gauss_im%d_ker%d.bmp',dirname,i,j))
%           imwrite(kex,sprintf('%s/deconvedimgsandker/freq_filt_gauss_im%d_ker%d.bmp',dirname,i,j))
%           imwrite(ex,sprintf('%s/deconvedimgs/freq_filt_gauss_im%d_ker%d.jpg',dirname,i,j))
%           imwrite(kex,sprintf('%s/deconvedimgsandker/freq_filt_gauss_im%d_ker%d.jpg',dirname,i,j))
      
      end
      
    end;
  end


for i=1:4
    for j=1:8
           
       eval(sprintf('load %s/fergus_im%d_ker%d',dirname,i,j))
       errL(i,j,6)=ssde;
       k=k/max(k(:))*1.15;
       k_sz=size(k,1);
       kex=ex; kex(1:k_sz*sclk,1:k_sz*sclk)=imresize(k,sclk,'nearest');
       k=zero_pad(k,(max_k_sz-k_sz)/2,(max_k_sz-k_sz)/2);
       kL(:,:,j,i,6)=k/max(k(:))*1.15;
%        imwrite(ex,sprintf('%s/deconvedimgs/fergus_im%d_ker%d.bmp',dirname,i,j))
%        imwrite(kex,sprintf('%s/deconvedimgsandker/fergus_im%d_ker%d.bmp',dirname,i,j))
    end
  
end

for i=1:4
    for j=1:8
            
       eval(sprintf('load %s/cho_im%d_ker%d',dirname,i,j))
       errL(i,j,7)=ssde;
       k=k/max(k(:))*1.15;
       k_sz=size(k,1);
       kex=ex; kex(1:k_sz*sclk,1:k_sz*sclk)=imresize(k,sclk,'nearest');
       k=zero_pad(k,(max_k_sz-k_sz)/2,(max_k_sz-k_sz)/2);
       kL(:,:,j,i,7)=k/max(k(:))*1.15;
%        imwrite(ex,sprintf('%s/deconvedimgs/cho_im%d_ker%d.bmp',dirname,i,j))
%        imwrite(kex,sprintf('%s/deconvedimgsandker/cho_im%d_ker%d.bmp',dirname,i,j))
%        imwrite(ex,sprintf('%s/deconvedimgs/cho_im%d_ker%d.jpg',dirname,i,j))
%        imwrite(kex,sprintf('%s/deconvedimgsandker/cho_im%d_ker%d.jpg',dirname,i,j))
    
    
    end
  
end
% for i=1:8
%    kImg(:,:,i)=imresize(flat3DArray(kL(:,:,:,:,i),4),5,'nearest');
%    figure, imshow(kImg(:,:,i));    
% end
   

% imwrite(kImg(:,:,1),sprintf('%s/figs/kImg_imggauss.bmp',dirname));
% imwrite(kImg(:,:,2),sprintf('%s/figs/kImg_fe_diagcov_imgsps.bmp',dirname));
% imwrite(kImg(:,:,4),sprintf('%s/figs/kImg_fe_diagcov_filtsps.bmp',dirname));
% imwrite(kImg(:,:,5),sprintf('%s/figs/kImg_smp_filtsps.bmp',dirname));
% imwrite(kImg(:,:,6),sprintf('%s/figs/kImg_fergus.bmp',dirname));
% imwrite(kImg(:,:,7),sprintf('%s/figs/kImg_cho.bmp',dirname));
% imwrite(kImg(:,:,8),sprintf('%s/figs/kImg_groundtruth.bmp',dirname));
% imwrite(kImg(:,:,3),sprintf('%s/figs/kImg_filtgauss.bmp',dirname));
% 
% imwrite(kImg(:,:,1),sprintf('%s/figs/kImg_imggauss.jpg',dirname));
% imwrite(kImg(:,:,2),sprintf('%s/figs/kImg_fe_diagcov_imgsps.jpg',dirname));
% imwrite(kImg(:,:,4),sprintf('%s/figs/kImg_fe_diagcov_filtsps.jpg',dirname));
% imwrite(kImg(:,:,5),sprintf('%s/figs/kImg_smp_filtsps.jpg',dirname));
% imwrite(kImg(:,:,6),sprintf('%s/figs/kImg_fergus.jpg',dirname));
% imwrite(kImg(:,:,7),sprintf('%s/figs/kImg_cho.jpg',dirname));
% imwrite(kImg(:,:,8),sprintf('%s/figs/kImg_groundtruth.jpg',dirname));
% imwrite(kImg(:,:,3),sprintf('%s/figs/kImg_filtgauss.jpg',dirname));


thrv=[2,2.5,3,3.5,4,4.5,5];
for j=1:7
   
    errLr(:,:,j)=errL(:,:,j)./errL(:,:,8);
    for i=1:length(thrv)
        cerrL(j,i)=sum(sum( errLr(:,:,j)<=thrv(i)))/32;
    end
    
end

cols='rgbkcmy'
figure, hold on
for j=1:j
    plot(min(thrv,5), 100*cerrL(j,:),cols(j),'LineWidth',3)
end
le{1}='Gaussian, img spase';
le{2}='Sparse, FE, img space';
le{3}='Gaussian, filt spase';
le{4}='Sparse, FE, filt space';
le{5}='Sparse, Smp, filt space';
le{6}='Fergus';
le{7}='Cho';
f=legend(le,'Location','NorthWest')
set(f,'FontSize',20)
axis([2 5 0 199])
ylabel('Success percent','FontSize',25)
xlabel('Error ratios','FontSize',25)
set(gca,'FontSize',25)

eval(sprintf('print -depsc %s/figs/error_ratios.jpg',dirname))