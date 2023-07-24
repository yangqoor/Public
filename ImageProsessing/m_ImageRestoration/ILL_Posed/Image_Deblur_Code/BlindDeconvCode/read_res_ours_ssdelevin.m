clc;
clear;
close all;
dirname='resdir'

sclk=4;
max_k_sz=25;
kL=zeros(max_k_sz,max_k_sz,8,4,7);

load('SSDELEVIN68BCP003.mat');
load('SSDENOISE003.mat');
for i=1:4
    for j=1:8
        errL(i,j,8)=SSDE68(i,j);   
       %eval(sprintf('load %s/groundtruth_im%d_ker%d',dirname,i,j))
       %errL(i,j,8)=ssde;
       %errL(i,j,8)=SSDE(i,j);
    end 
end

  for i=1:4
    for j=1:8
%       mat_outname=sprintf('%s/diagfe_img_sps_im%d_ker%d.mat',dirname,i,j);
%       d=dir(mat_outname);
%       if (length(d)==0)
%          errL(i,j,2)=nan;
%       else
%           eval(['load ',mat_outname]);
          errL(i,j,7)=SSDE68(8+i,j);     
    %  end
      
    end;
  end

for i=1:4
   for j=1:8
     % mat_outname=sprintf('%s/freq_img_gauss_im%d_ker%d.mat',dirname,i,j);       
       %d=dir(mat_outname);
%       if (length(d)==0)
%          errL(i,j,1)=nan;
%       else
         % eval(['load ',mat_outname]);
         % errL(i,j,1)=ssde;
         eval(sprintf('load %s/fergus_im%d_ker%d',dirname,i,j))
       errL(i,j,6)=ssde;
     % end
      
    end;
  end

for i=1:4
   for j=1:8
     % mat_outname=sprintf('%s/freq_filt_gauss_im%d_ker%d.mat',dirname,i,j);      
     % d=dir(mat_outname);
%       if (length(d)==0)
%          errL(i,j,3)=nan;
%       else
          %eval(['load ',mat_outname]);
          %errL(i,j,3)=ssde;
;
     %     errL(i,j,1)=SSDE68(12+i,j);
     errL(i,j,1)=SSDEN(i+5,j);
     % end
      
    end;
  end

% for i=1:4
%     for j=1:8
%           errL(i,j,5)=SSDE68(16+i,j);
%       % eval(sprintf('load %s/fergus_im%d_ker%d',dirname,i,j))
%       % errL(i,j,5)=ssde;
%     end
%   
% end

for i=1:4
    for j=1:8
            
       load('ssde_L0.mat');
     %  errL(i,j,2)=ssde(i,j);
     errL(i,j,2)=SSDEN(i,j);
       % errL(i,j,7)=SSDE2(i,j);  
    end
  
end
for i=1:4
    for j=1:8
            
      load('ssde_pan.mat');
       errL(i,j,3)=ssde(i,j);
       % errL(i,j,7)=SSDE2(i,j);  
    end
  
end
for i=1:4
    for j=1:8
            
      load('ssde_krishnan3.mat');
       errL(i,j,4)=ssde(i,j);
       % errL(i,j,7)=SSDE2(i,j);  
    end
  
end
for i=1:4
    for j=1:8
            
%       load('ssde_cai.mat');
%       errL(i,j,7)=ssde(i,j);
      eval(sprintf('load %s/cho_im%d_ker%d',dirname,i,j))
      errL(i,j,5)=ssde
       
       % errL(i,j,7)=SSDE2(i,j);  
    end
  
end
for i=1:4
    for j=1:8
            
      load('ssde_cai.mat');
      errL(i,j,7)=ssde(i,j);

    end
  
end

 
 
% for i=1:8
%    kImg(:,:,i)=imresize(flat3DArray(kL(:,:,:,:,i),4),5,'nearest');
%    figure, imshow(kImg(:,:,i));    
% end
%    
% 
% imwrite(kImg(:,:,1),sprintf('%s/figs/kImg_imggauss.bmp',dirname));

%thrv=[2,2.25,2.5,2.75,3,3.25,3.5,3.75,4,4.25,4.5,4.75,5];
thrv=[1,1.5,2,2.5,3,3.5,4,4.5,5];

for j=1:7
   
    errLr(:,:,j)=errL(:,:,j)./errL(:,:,8);
    for i=1:length(thrv)
        cerrL(j,i)=sum(sum( errLr(:,:,j)<=thrv(i)))/32;
    end
    
end

cols='rgbkcmy'
figure('color','w'), hold on
for j=1:j
    plot(min(thrv,5), 100*cerrL(j,:),cols(j),'LineWidth',3)
end

le{1}='Ours';
le{2}='Xu et al';
le{3}='Pan et al';
le{4}='Krishnan et al';
le{5}='Cho et al';
le{6}='Fergus et al';
le{7}='Cai et al';

f=legend(le,'Location','NorthWest')
set(f,'FontSize',10)
axis([1 5 0 110])
%axis([1 5 0 199])
ylabel('Success percent','FontSize',15)
xlabel('Error ratios','FontSize',15)
set(gca,'FontSize',15)

% eval(sprintf('print -depsc %s/figs/error_ratios.jpg',dirname))